from pyspark.sql import SparkSession
from pyspark.sql.functions import col, round as spark_round
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

spark = SparkSession.builder.appName("PropertyAnalysis").getOrCreate()

schema = StructType([
    StructField("street", StringType(), True),
    StructField("city", StringType(), True),
    StructField("zip", StringType(), True),
    StructField("state", StringType(), True),
    StructField("beds", IntegerType(), True),
    StructField("baths", IntegerType(), True),
    StructField("sqft", IntegerType(), True),
    StructField("type", StringType(), True),
    StructField("price", IntegerType(), True),
])

# Read only the necessary columns up front and cast once to avoid repeated conversions.
df = (
    spark.read
    .schema(schema)
    .option("header", True)
    .csv("Property.csv")
    .select("street", "city", "beds", "baths", "sqft", "type", "price")
)

# Cost-optimized filtering: narrow to target segment before sorting and writing.
result = (
    df.filter(
        (col("type") == "Residential") &
        (col("beds") == 2) &
        (col("price").between(50000, 75000))
    )
    .withColumn("price_per_sqft", col("price") / col("sqft"))
    .orderBy(col("price_per_sqft").asc())
    .limit(10)
    .withColumn("price_per_sqft", spark_round(col("price_per_sqft"), 2))
)

result.show(10, truncate=False)

result.write.mode("overwrite").option("header", True).csv("output/top_2bhk_best_value")

spark.stop()