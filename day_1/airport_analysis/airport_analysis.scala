import org.apache.spark.sql.SparkSession

val spark = SparkSession.builder()
  .appName("AirportAnalysis")
  .master("local[*]")
  .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

// ---------------------------------------------------------------------
// Read datasets from the AirportAnalysis folder
// ---------------------------------------------------------------------
val airports = spark.read
  .option("header", "false")
  .option("delimiter", "\t")
  .csv("file:///opt/DataSet/AirportAnalysis/airports_mod.dat")
  .toDF(
    "Airport_ID",
    "Name",
    "City",
    "Country",
    "IATA_FAA",
    "ICAO",
    "Latitude",
    "Longitude",
    "Altitude",
    "Timezone_Offset",
    "DST",
    "TZ"
  )

val airlines = spark.read
  .option("header", "false")
  .option("delimiter", "\t")
  .csv("file:///opt/DataSet/AirportAnalysis/Final_airlines")
  .toDF(
    "Airline_ID",
    "Name",
    "Alias",
    "IATA",
    "ICAO",
    "Callsign",
    "Country",
    "Active"
  )

val routes = spark.read
  .option("header", "false")
  .option("delimiter", "\t")
  .csv("file:///opt/DataSet/AirportAnalysis/routes.dat")
  .toDF(
    "Airline_IATA_ICAO",
    "Airline_ID",
    "Source_Airport_IATA_ICAO",
    "Source_Airport_ID",
    "Destination_Airport_IATA_ICAO",
    "Destination_Airport_ID",
    "Codeshare",
    "Stops",
    "Equipment"
  )

airports.createOrReplaceTempView("airports")
airlines.createOrReplaceTempView("airlines")
routes.createOrReplaceTempView("routes")

// ---------------------------------------------------------------------
// 1. Find list of Airports operating in the Country
//    Example: all airports in United States
// ---------------------------------------------------------------------
val selectedCountry = "United States"
val airportsByCountry = spark.sql(s"""
  SELECT
      Airport_ID,
      Name,
      City,
      Country,
      IATA_FAA,
      ICAO
  FROM airports
  WHERE Country = '$selectedCountry'
  ORDER BY City, Name
""")

airportsByCountry.show(false)

// ---------------------------------------------------------------------
// 2. Find the list of Airlines having zero stops
// ---------------------------------------------------------------------
val zeroStopAirlines = spark.sql("""
  SELECT DISTINCT
      a.Airline_ID,
      a.Name AS Airline_Name,
      a.Country AS Airline_Country,
      r.Stops
  FROM routes r
  JOIN airlines a
    ON r.Airline_ID = a.Airline_ID
  WHERE r.Stops = 0
  ORDER BY a.Name
""")

zeroStopAirlines.show(false)

// ---------------------------------------------------------------------
// 3. List of Airlines operating with code share
// ---------------------------------------------------------------------
val codeshareAirlines = spark.sql("""
  SELECT DISTINCT
      a.Airline_ID,
      a.Name AS Airline_Name,
      a.Country AS Airline_Country,
      r.Codeshare
  FROM routes r
  JOIN airlines a
    ON r.Airline_ID = a.Airline_ID
  WHERE r.Codeshare = 'Y'
  ORDER BY a.Name
""")

codeshareAirlines.show(false)

// ---------------------------------------------------------------------
// 4. Which country (or) territory has the highest number of Airports
// ---------------------------------------------------------------------
val topAirportCountry = spark.sql("""
  SELECT
      Country,
      COUNT(*) AS Total_Airports
  FROM airports
  GROUP BY Country
  ORDER BY Total_Airports DESC, Country ASC
  LIMIT 1
""")

topAirportCountry.show(false)

// ---------------------------------------------------------------------
// 5. Find the list of Active Airlines in the United States
// ---------------------------------------------------------------------
val activeAirlinesInUS = spark.sql("""
  SELECT
      Airline_ID,
      Name,
      IATA,
      ICAO,
      Country,
      Active
  FROM airlines
  WHERE Country = 'United States'
    AND Active = 'Y'
  ORDER BY Name
""")

activeAirlinesInUS.show(false)

spark.stop()
