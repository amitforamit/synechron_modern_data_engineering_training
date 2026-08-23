val propertiesDf = spark
  .read
  .option("header", "true")
  .option("inferSchema", "true")
  .csv("file:///opt/DataSet/Property.csv")

propertiesDf.createOrReplaceTempView("properties")

val bestValueQuery = spark.sql("""
  WITH filtered AS (
      SELECT
          street,
          city,
          zip,
          state,
          beds,
          baths,
          sqft,
          type,
          price,
          CAST(price AS DOUBLE) / sqft AS price_per_sqft
      FROM properties
      WHERE beds = 2
        AND price BETWEEN 50000 AND 75000
  ),
  scored AS (
      SELECT
          *,
          (1 - (
              (price_per_sqft - MIN(price_per_sqft) OVER()) /
              NULLIF(MAX(price_per_sqft) OVER() - MIN(price_per_sqft) OVER(), 0)
          )) * 40 AS sqft_value_score,
          ((sqft - MIN(sqft) OVER()) /
              NULLIF(MAX(sqft) OVER() - MIN(sqft) OVER(), 0)) * 30 AS size_score,
          CASE
              WHEN baths >= 2 THEN 20
              ELSE 10
          END AS bath_score,
          (1 - (
              (price - MIN(price) OVER()) /
              NULLIF(MAX(price) OVER() - MIN(price) OVER(), 0)
          )) * 10 AS price_score
      FROM filtered
  )
  SELECT
      street,
      city,
      zip,
      state,
      beds,
      baths,
      sqft,
      type,
      price,
      ROUND(price_per_sqft, 2) AS price_per_sqft,
      ROUND(sqft_value_score + size_score + bath_score + price_score, 2) AS value_score
  FROM scored
  ORDER BY value_score DESC
  LIMIT 10
""")

bestValueQuery.show(false)
