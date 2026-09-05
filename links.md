https://sourceforge.net/projects/getprathamos/files/Training/Resources/DataSet/

sshpass -p 'QDPSYV@mtxeh381' ssh -o StrictHostKeyChecking=no root@151.185.58.110
spark-shell --master spark://151.185.58.110:7077 --num-executors 8 --driver-memory 512m --executor-memory 512m --executor-cores 1 --total-executor-cores 8

Rakesh Khandelwal 12:36
http://151.185.58.110:8080/
sshpass -p 'WTTBVY@zuute996' ssh -o StrictHostKeyChecking=no root@151.185.58.111

sshpass -p 'TZHZQY@fazzh174' ssh -o StrictHostKeyChecking=no root@151.185.58.141
sshpass -p 'VFYSQD@hvjgr575' ssh -o StrictHostKeyChecking=no root@151.185.58.161

LOW LEVEL API
sc.textFile("file:///media/prathamos/Work/Work/Training/BigData/DataSet/EmployeesAll.csv").filter(!_.startsWith("emp_no")).map(X => (X.split(',')(2),X.split(',')(3),X.split(',')(4))).filter(x => (x._1.startsWith("Ara") && x._2.startsWith("Ba") && x._3.equals("M"))).collect()
DSL/PANDAS
val dfs = spark.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("file:///media/prathamos/Work/Work/Training/BigData/DataSet/EmployeesAll.csv")
dfs.filter(dfs("gender") === "M" && dfs("first_name").like("Ara%") && dfs("last_name").like("Ba%")).show()
ANSI SQL
val dfs = spark.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("file:///media/prathamos/Work/Work/Training/BigData/DataSet/EmployeesAll.csv")
dfs.createOrReplaceTempView("emps")
val EmpQuery = spark.sql("Select * from emps where gender ='M' and first_name like '%Ara%' and last_name like '%Ba%'");
EmpQuery.show(false)


------
/opt/Spark/bin/spark-shell --master spark://151.185.58.110:7077 --num-executors 1 --driver-memory 512m --executor-memory 512m --executor-cores 1 --total-executor-cores 1

---

val dfs = spark.read.format("com.databricks.spark.csv").option("header", "true").option("inferSchema", "true").load("file:///opt/DataSet/Property.csv")
dfs.createOrReplaceTempView("properties")
val EmpQuery = spark.sql("WITH filtered AS (SELECT , price  1.0 / sqft AS price_per_sqft FROM properties WHERE beds = 2 AND price BETWEEN 50000 AND 75000), scored AS (SELECT , (1 - (price_per_sqft - MIN(price_per_sqft) OVER ()) / NULLIF(MAX(price_per_sqft) OVER () - MIN(price_per_sqft) OVER (), 0))  40 AS sqft_value_score, ((sqft - MIN(sqft) OVER ()) / NULLIF(MAX(sqft) OVER () - MIN(sqft) OVER (), 0))  30 AS size_score, CASE WHEN baths >= 2 THEN 20 ELSE 10 END AS bath_score, (1 - (price - MIN(price) OVER ()) / NULLIF(MAX(price) OVER () - MIN(price) OVER (), 0))  10 AS price_score FROM filtered) SELECT street, city, zip, state, beds, baths, sqft, type, price, ROUND(price_per_sqft, 2) AS price_per_sqft, ROUND(sqft_value_score + size_score + bath_score + price_score, 2) AS value_score FROM scored ORDER BY value_score


https://codeshare.io/2EjYBN

./spark-4.2.0-bin-hadoop3/bin/spark-shell --master local[*] --jars /media/prathamos/Work/Work/Training/Custom/15DayMDE/Stuff/mysql-connector-j-9.0.0.jar

/opt/DataSet/AirportAnalysis/

https://sourceforge.net/projects/getprathamos/files/Training/Resources/DataSet/AirportAnalysis/


val Df_xml=spark.read.format("com.databricks.spark.xml").option("rootTag","Employees").option("rowTag","Employee").load("file:///opt/DataSet/employees.xml")
Df_xml.show(false)
Df_xml.createOrReplaceTempView("employeexml")
Df_xml.printSchema()

val Df_json=spark.read.option("multilines","true").json("file:///opt/DataSet/employees.json")
Df_json.show(false)
Df_json.createOrReplaceTempView("employeejson")
Df_json.printSchema()

val Df_csv=spark.read.option("header", "true").option("delimiter", ",").csv("file:///opt/DataSet/employees.csv")
Df_csv.show(false)
Df_csv.createOrReplaceTempView("employeecsv")
Df_csv.printSchema()

val Df_mysql=spark.read.format("jdbc").option("url", "jdbc:mysql://192.168.1.11:6674/sanatan").option("driver", "com.mysql.jdbc.Driver").option("dbtable", "emps").option("user", "root").option("password", "qDKuB7m663771579CozfO").load()
Df_mysql.show(false)
Df_mysql.createOrReplaceTempView("employeesql")
Df_mysql.printSchema()

val DF_res=spark.sql("select a.empId as EmployeeId,c.first_name as FirstName,a.lastName as LastName,a.gender as Gender,b.emailAddress as Email,b.phoneNumber as Contact,d.dept as Department,a.salary as Salary from employeexml a inner join employeejson b on a.empId=b.empId inner join employeecsv c on c.emp_no=b.empId inner join employeesql d on d.empno=c.emp_no")
DF_res.show(false)
DF_res.printSchema()


DF_res.write.mode("Overwrite").option("header", "true").csv("file:///home/prathamos/Downloads/res/1")
DF_res.write.mode("Overwrite").option("header", "true").json("file:///home/prathamos/Downloads/res/2")
DF_res.write.mode("Overwrite").option("header", "true").format("com.databricks.spark.xml").option("rootTag", "Employees").option("rowTag", "Employee").save("file:///home/prathamos/Downloads/res/3")
DF_res.write.mode("Overwrite").option("header", "true").parquet("file:///home/prathamos/Downloads/res/4")
DF_res.write.mode("Overwrite").option("header", "true").orc("file:///home/prathamos/Downloads/res/5")
DF_res.write.mode("Overwrite").option("header", "true").format("com.databricks.spark.avro").save("file:///home/prathamos/Downloads/res/6")

val resdf1=spark.read.parquet("file:///home/prathamos/Downloads/res/4/*")
resdf1.createOrReplaceTempView("emps1")
spark.sql("select * from emps1").show(false)

val resdf2=spark.read.orc("file:///home/prathamos/Downloads/res/5/*")
resdf2.createOrReplaceTempView("emps2")
spark.sql("select * from emps2").show(false)

val resdf3=spark.read.format("com.databricks.spark.avro").load("file:///home/prathamos/Downloads/res/6/*")
resdf3.createOrReplaceTempView("emps3")
spark.sql("select * from emps3").show(false)


Airline Data Analysis 
Industry: Aviation 
Data: Publicly available dataset which contains the flight details of various airlines like: Airport id, Name of the airport, Main city served by airport, Country or territory where airport is located, Code of Airport, Decimal degrees, Hours offset from UTC, Time zone, etc. 

Problem Statement: Analyze the airlines data to: 
1. Find list of Airports operating in the Country 
2. Find the list of Airlines having zero stops 
3. List of Airlines operating with code share 
4. Which country (or) territory has the highest number of Airports 
5. Find the list of Active Airlines in the United States

Data set Description:
In this use case there are 3 data sets.

Final_airlines
routes.dat
airports_mod.dat
** Air Ports data set i.e. airports_mod.dat **

It contains the following fields

Airport ID	: Unique OpenFlights identifier for this airport.
Name	: Name of airport. May or may not contain the City name.
City	: Main city served by airport. May be spelled differently from Name.
Country	: Country or territory where airport is located.
IATA/FAA	: 3-letter FAA code, for airports located in Country "United States of America". 3-letter IATA code, for all other airports. Blank if not assigned.
ICAO	: 4-letter ICAO code. Blank if not assigned.
Latitude	: Decimal degrees, usually to six significant digits. Negative is South, positive is North.
Longitude	: Decimal degrees, usually to six significant digits. Negative is West, positive is East.
Altitude	: In feet.
Timezone	: Hours offset from UTC. Fractional hours are expressed as decimals, eg. India is 5.5.
DST	: Daylight savings time. One of E (Europe), A (US/Canada), S (South America), O (Australia), Z (New Zealand), N (None) or U (Unknown)
Timezone	: in "tz" (Olson) format, eg. "America/Los_Angeles". zone
** Air Lines Data set i.e. Final_airlines **

It contains the following fields:

Airline ID	: Unique OpenFlights identifier for this airline.
Name	: Name of the airline.
Alias	: Alias of the airline. For example, All Nippon Airways is commonly known as "ANA".
IATA	: 2-letter IATA code, if available.
ICAO	: 3-letter ICAO code, if available.
Callsign Airline: callsign.
Country	: Country or territory where airline is incorporated.
Active	: "Y" if the airline is or has until recently been operational. "N" if it is defunct.
** Routes Data set i.e routes.dat **

It contains the following fields:

Airline IATA/ICAO	: 2-letter (IATA) or 3-letter (ICAO) code of the airline.
Airline ID	: Unique Open Flights identifier for airline (see Airline).
Source Airport IATA/ICAO: 3-letter (IATA) or 4-letter (ICAO) code of the source airport.
Source Airport ID	: Unique OpenFlights identifier for source airport (see Airport)
Destination Airport IATA/ICAO: 3-letter (IATA) or 4-letter (ICAO) code of the destination airport.
Destination Airport ID: Unique OpenFlights identifier for destination airport (see Airport)
Codeshare	: "Y" if this flight is a codeshare (that is, not operated by Airline, but another carrier), empty otherwise.
Stops	: Number of stops on this flight ("0" for direct)
Equipment	: 3-letter codes for plane type(s) generally used on this flight, separated by spaces


https://sourceforge.net/projects/getprathamos/files/Training/Resources/

https://sourceforge.net/projects/getprathamos/files/Training/Resources/15Day_MDE_Share1.zip