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