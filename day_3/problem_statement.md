I have some data in csv format like /media/prathamos/Work/Work/Training/BigData/DataSet/Property.csv
earlier we were involved in only datalake olap through apache spark but now the org is letting go of oracle and we are supposd to do oltp in the datalake itself
the prod e\nv wil eventually be databricks and hence we need to do dev on delta in local env.
i alreayd have apache spark set up on my local machine /media/prathamos/Work/Work/Training/Custom/15DayMDE/spark-4.2.0-bin-hadoop3
help me start pyspark with delta so that we can run crud operations on this propery data..
i think first we will have to store it in parquet..