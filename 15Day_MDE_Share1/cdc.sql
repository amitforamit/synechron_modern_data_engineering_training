CREATE DATABASE IF NOT EXISTS retaildb;
USE retaildb;

-- 1. Create source table
CREATE TABLE IF NOT EXISTS customers1 (
  customer_id INT,
  name STRING,
  email STRING,
  status STRING,
  last_updated TIMESTAMP
)
USING DELTA;

-- 2. Populate initial dataset into source
INSERT INTO customers1 VALUES
  (1, 'Alice Smith', 'alice@example.com', 'active', TIMESTAMP '2023-01-01 10:00:00'),
  (2, 'Bob Johnson', 'bob@example.com', 'active', TIMESTAMP '2023-01-01 11:00:00'),
  (3, 'Charlie Brown', 'charlie@example.com', 'active', TIMESTAMP '2023-01-01 12:00:00');

-- 3. Create target table and sync initial state
CREATE TABLE IF NOT EXISTS customers2 (
  customer_id INT,
  name STRING,
  email STRING,
  status STRING,
  last_updated TIMESTAMP
)
USING DELTA;

INSERT INTO customers2 SELECT * FROM customers1;

-- 4. Perform modifications on source table
INSERT INTO customers1 VALUES
  (4, 'Diana Prince', 'diana@example.com', 'active', TIMESTAMP '2023-01-02 09:00:00');

UPDATE customers1 SET
  status = 'inactive',
  last_updated = TIMESTAMP '2023-01-02 10:00:00'
WHERE customer_id = 2;

DELETE FROM customers1 WHERE customer_id = 1;

-- 5. Calculate diff between VERSION AS OF 1 and current state
CREATE OR REPLACE TEMPORARY VIEW customer_changes AS
WITH
  customers1_before AS (
    SELECT customer_id, name, email, status, last_updated FROM customers1 VERSION AS OF 1
  ),
  customers1_after AS (
    SELECT customer_id, name, email, status, last_updated FROM customers1
  )
SELECT
  COALESCE(after.customer_id, before.customer_id) AS customer_id,
  CASE
    WHEN after.customer_id IS NULL THEN before.name
    ELSE after.name
  END AS name,
  CASE
    WHEN after.customer_id IS NULL THEN before.email
    ELSE after.email
  END AS email,
  CASE
    WHEN after.customer_id IS NULL THEN before.status
    ELSE after.status
  END AS status,
  CASE
    WHEN after.customer_id IS NULL THEN before.last_updated
    ELSE after.last_updated
  END AS last_updated,
  CASE
    WHEN after.customer_id IS NULL THEN 'DELETE'
    WHEN before.customer_id IS NULL THEN 'INSERT'
    WHEN after.name != before.name OR
         after.email != before.email OR
         after.status != before.status OR
         after.last_updated != before.last_updated THEN 'UPDATE'
    ELSE 'NO_CHANGE'
  END AS operation
FROM customers1_before AS before
FULL OUTER JOIN customers1_after AS after
  ON before.customer_id = after.customer_id
WHERE
  CASE
    WHEN after.customer_id IS NULL THEN 'DELETE'
    WHEN before.customer_id IS NULL THEN 'INSERT'
    WHEN after.name != before.name OR
         after.email != before.email OR
         after.status != before.status OR
         after.last_updated != before.last_updated THEN 'UPDATE'
    ELSE 'NO_CHANGE'
  END != 'NO_CHANGE';

-- 6. Apply merged changes to target table
MERGE INTO customers2 AS target
USING customer_changes AS source
ON target.customer_id = source.customer_id
WHEN MATCHED AND source.operation = 'UPDATE' THEN
  UPDATE SET
    target.name = source.name,
    target.email = source.email,
    target.status = source.status,
    target.last_updated = source.last_updated
WHEN MATCHED AND source.operation = 'DELETE' THEN
  DELETE
WHEN NOT MATCHED AND source.operation = 'INSERT' THEN
  INSERT (customer_id, name, email, status, last_updated) VALUES
  (source.customer_id, source.name, source.email, source.status, source.last_updated);

-- 7. Verification and Cleanup
SELECT * FROM customers1 ORDER BY customer_id;
SELECT * FROM customers2 ORDER BY customer_id;

DROP TABLE IF EXISTS customers1;
DROP TABLE IF EXISTS customers2;