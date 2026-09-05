CREATE DATABASE IF NOT EXISTS retaildb;
USE retaildb;

-- 1. Create source table with CDF enabled
CREATE TABLE IF NOT EXISTS customers1 (
  customer_id INT,
  name STRING,
  email STRING,
  status STRING,
  last_updated TIMESTAMP
)
USING DELTA
TBLPROPERTIES (delta.enableChangeDataFeed = true);

-- 2. Populate initial dataset into source
INSERT INTO customers1 VALUES
  (1, 'Alice Smith', 'alice@example.com', 'active', TIMESTAMP '2023-01-01 10:00:00'),
  (2, 'Bob Johnson', 'bob@example.com', 'active', TIMESTAMP '2023-01-01 11:00:00'),
  (3, 'Charlie Brown', 'charlie@example.com', 'active', TIMESTAMP '2023-01-01 12:00:00');

-- 3. Create target table and sync initial data
CREATE TABLE IF NOT EXISTS customers2 (
  customer_id INT,
  name STRING,
  email STRING,
  status STRING,
  last_updated TIMESTAMP
)
USING DELTA;

INSERT INTO customers2 SELECT * FROM customers1;

-- 4. Perform modifications (Insert, Update, Delete) on source table
INSERT INTO customers1 VALUES
  (4, 'Diana Prince', 'diana@example.com', 'active', TIMESTAMP '2023-01-02 09:00:00');

UPDATE customers1 SET
  status = 'inactive',
  last_updated = TIMESTAMP '2023-01-02 10:00:00'
WHERE customer_id = 2;

DELETE FROM customers1 WHERE customer_id = 1;

-- 5. Extract latest changes from CDF starting from commit version 0
CREATE OR REPLACE TEMPORARY VIEW customer_cdf_changes AS
WITH raw_cdf AS (
  SELECT
      customer_id,
      name,
      email,
      status,
      last_updated,
      _change_type,
      _commit_version,
      _commit_timestamp
  FROM table_changes('customers1', 0)
),
latest_relevant_changes AS (
  SELECT
    customer_id,
    name,
    email,
    status,
    last_updated,
    _change_type,
    _commit_version,
    _commit_timestamp,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY _commit_version DESC, _commit_timestamp DESC) as rn
  FROM raw_cdf
  WHERE _change_type IN ('insert', 'delete', 'update_postimage')
)
SELECT
  customer_id,
  name,
  email,
  status,
  last_updated,
  _change_type,
  _commit_version,
  _commit_timestamp
FROM latest_relevant_changes
WHERE rn = 1;

-- 6. Apply CDC updates to target table using MERGE INTO
MERGE INTO customers2 AS target
USING customer_cdf_changes AS source
ON target.customer_id = source.customer_id
WHEN MATCHED AND source._change_type = 'update_postimage' THEN
  UPDATE SET
    target.name = source.name,
    target.email = source.email,
    target.status = source.status,
    target.last_updated = source.last_updated
WHEN MATCHED AND source._change_type = 'delete' THEN
  DELETE
WHEN NOT MATCHED AND source._change_type = 'insert' THEN
  INSERT (customer_id, name, email, status, last_updated) VALUES
  (source.customer_id, source.name, source.email, source.status, source.last_updated);

-- 7. Verification and Cleanup
SELECT * FROM customers1 ORDER BY customer_id;
SELECT * FROM customers2 ORDER BY customer_id;

DROP TABLE IF EXISTS customers1;
DROP TABLE IF EXISTS customers2;