-- Assumes the CSV has already been loaded into a table named property_data
-- with columns: street, city, zip, state, beds, baths, sqft, type, price

SELECT
    street,
    city,
    beds,
    baths,
    sqft,
    price,
    ROUND(CAST(price AS DECIMAL(10, 2)) / sqft, 2) AS price_per_sqft
FROM property_data
WHERE type = 'Residential'
  AND beds = 2
  AND price BETWEEN 50000 AND 75000
ORDER BY price_per_sqft ASC
LIMIT 10;

-- Optional: if you want a table definition first
-- CREATE TABLE property_data (
--     street VARCHAR(255),
--     city VARCHAR(100),
--     zip VARCHAR(20),
--     state CHAR(2),
--     beds INT,
--     baths INT,
--     sqft INT,
--     type VARCHAR(50),
--     price INT
-- );
