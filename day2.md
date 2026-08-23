# Day 2

## Spark fundamentals and execution model

### 1. What is Spark?
Spark is a distributed computing engine for large-scale data processing. It is designed for batch processing, streaming, SQL analytics, machine learning, and graph processing.

### 2. Spark components
- Driver: the program that creates the SparkContext and coordinates execution.
- Executor: a worker process that runs tasks on data partitions.
- Cluster Manager: allocates resources such as YARN, Kubernetes, Mesos, or standalone mode.
- Task: a unit of work executed by an executor.
- Stage: a set of tasks that can run without a shuffle.

### 3. Driver and executor roles
- Driver decides what work to do and schedules tasks.
- Executors run tasks and hold data in memory or on disk.
- A cluster is only as fast as the coordination between driver, executors, and storage.

### 4. Lazy evaluation
Spark does not execute transformations immediately. It builds a logical plan and executes only when an action is triggered.

Examples of transformations:
- map
- filter
- select
- join
- groupBy

Examples of actions:
- collect
- count
- show
- save
- reduce

### 5. Narrow vs wide dependencies
- Narrow dependency: each partition of parent data contributes to at most one child partition. Usually no shuffle.
- Wide dependency: data from multiple partitions must be combined, often requiring a shuffle.

Examples:
- narrow: map, filter, flatMap
- wide: groupByKey, reduceByKey, join, distinct

### 6. Network shuffle
Shuffle is the expensive process of redistributing data across cluster nodes so records with the same key end up together.

Why expensive:
- writes intermediate data to disk
- serializes data over the network
- reads data again on receiving side
- creates stage boundaries and synchronization overhead

### 7. DAG scheduler
Spark converts user code into a DAG (Directed Acyclic Graph) of stages and tasks.

It decides:
- execution ordering
- parallelism
- stage boundaries
- where work is placed on the cluster

### 8. Partitions
A partition is a logical chunk of data.

More partitions can improve parallelism, but too many partitions can cause overhead.

Important idea:
- data locality matters
- cluster resources are used most efficiently when work is balanced across partitions

### 9. Persistence and caching
Spark allows caching intermediate results using memory or disk.

Use cases:
- iterative algorithms
- repeated queries on same dataset
- multi-step transformations

Caching helps if data is reused many times, but it costs memory.

### 10. Serialization and performance
Spark often serializes data when moving between processes, nodes, or Python and JVM boundaries.

This matters a lot in PySpark:
- Python objects are heavier than JVM-native objects
- serialization adds CPU and memory cost
- UDFs and Python-heavy code are usually slower than native Spark SQL and DataFrame operations

### 11. PySpark and Py4J
- PySpark is the Python API for Spark.
- Py4J is the bridge that allows Python to communicate with Spark's JVM runtime.
- Py4J does not make Python automatically fast; it only enables the connection.

### 12. DataFrame and SQL engine
Spark SQL provides a query engine built on top of Catalyst.

Benefits:
- declarative SQL queries
- query optimization
- logical and physical plan optimization
- better performance than many hand-written RDD transformations

### 13. Catalyst optimizer
Catalyst is Spark SQL's query optimizer.

It rewrites queries by:
- pushing filters down
- choosing join strategies
- reordering operations when possible
- reducing unnecessary work

### 14. CBO (Cost-Based Optimizer)
CBO estimates the cost of different execution plans and chooses the lowest-cost one based on statistics.

It considers:
- row counts
- file sizes
- join types
- index or partition information
- estimated I/O and CPU cost

### 15. Data formats and storage
Common formats in modern data engineering:
- Parquet: columnar and efficient for analytics
- ORC: columnar with good compression and query performance
- CSV/JSON: easier but less efficient for large analytics workloads
- Delta Lake: ACID, versioning, schema handling on lake storage
- Iceberg and Hudi: open table formats for lakehouse workloads

### 16. File layout and partitioning
Partitioning helps prune data by relevant columns.

Example:
- by date
- by country
- by tenant
- by event type

Good partitioning can make queries much faster, but poor partitioning can create skew and hotspots.

### 17. Data skew
Data skew means some partitions have much more data than others.

Causes:
- uneven key distribution
- hot keys
- poor partitioning strategy

Effects:
- slower tasks
- long-tail latency
- shuffle imbalance

### 18. Broadcast joins
A broadcast join sends a smaller dataset to every node so large tables can be joined without a full shuffle.

Very useful when one side of the join is small enough to fit in memory.

### 19. Fault tolerance
Spark achieves fault tolerance through lineage.

If a partition is lost, Spark can recompute it from the original source and earlier transformations.

This makes distributed processing robust without requiring constant full replication.

### 20. Why Spark matters in modern data engineering
Spark is important because it sits in the compute layer between data ingestion and analytical consumption.

Typical flow:
- source systems produce events or bulk data
- Kafka moves streaming data
- Spark processes, transforms, enriches, and aggregates
- output goes to lakehouse, warehouse, or downstream applications

---

## Day 2 summary
Spark is not just a tool for SQL; it is a distributed compute engine that provides the processing layer for modern data platforms. The most important concepts are execution planning, partitions, shuffle, DAG, memory, fault tolerance, optimization, and distributed data movement.
