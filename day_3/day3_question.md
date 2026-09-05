# Day 3 Questions: Databricks, Lakehouse, Delta, Unity Catalog, and Iceberg

## 1) What is a metastore in Databricks?

A metastore is the central metadata repository that keeps track of data objects such as databases, schemas, tables, columns, table locations, ownership, and permissions.

In Databricks, the metastore is the system that knows:
- what tables exist
- where they live in storage
- what schema each table has
- who can access them
- which catalog/schema they belong to

In older Hadoop-era systems, this was often the Hive Metastore (HMS). In modern Databricks, the recommended approach is Unity Catalog, which provides a more centralized and governance-friendly metastore.

---

## 2) What is the choice of data format?

The choice of format depends on the goal:

- Parquet: best default for analytic workloads, columnar, compressed, efficient reads.
- Delta Lake: best for lakehouse workloads that need ACID transactions, versioning, time travel, schema enforcement, and deletes/updates.
- Iceberg: best when you want an open table format that works across multiple engines and vendors.
- ORC/Avro: used in some legacy or specific workloads, but not the default for modern lakehouse analytics.

For Databricks, the most common modern answer is:
- storage in cloud object storage (ADLS/S3/GCS)
- file format usually Parquet or Delta
- table metadata managed by Delta Lake or Iceberg

---

## 3) What is Unity Catalog?

Unity Catalog is Databricks' unified governance layer for data and AI assets.

It provides a single place to manage:
- catalogs
- schemas (databases)
- tables
- views
- files/volumes
- models
- permissions and policies

Key capabilities:
- central catalog for all data assets
- fine-grained access control
- row-level and column-level security
- lineage tracking
- audit logs
- data discovery and governance across workspaces

Unity Catalog is the modern governance layer that replaces fragmented workspace-level permissions and older Hive-based metadata management.

---

## 4) What is Delta Lake?

Delta Lake is an open storage layer that sits on top of cloud object storage such as ADLS, S3, or GCS.

It adds reliability and warehouse-like features to a data lake:
- ACID transactions
- schema enforcement and evolution
- time travel / version history
- merge, update, delete support
- optimization and compaction
- checkpoints and transaction logs

Under the hood, Delta uses Parquet for data files and a transaction log to track changes.

So in simple terms:
- Data lake stores raw data cheaply
- Delta Lake makes that lake transactional and manageable for analytics

---

## 5) What is a Lakehouse?

A Lakehouse is a data architecture that combines:
- the low-cost storage of a data lake
- the governance, performance, and analytics features of a data warehouse

It stores data in cloud object storage while adding metadata and table management layers for:
- schema management
- transactions
- governance
- BI and SQL workloads

This gives organizations one system for:
- batch analytics
- streaming
- machine learning
- governance and auditability

Databricks is strongly associated with the Lakehouse architecture.

---

## 6) How is governance done in Databricks and in the open market?

### Databricks governance
In Databricks, governance is done through Unity Catalog and related controls:
- catalogs, schemas, tables, views
- role-based access control (RBAC)
- fine-grained permission model
- row-level and column-level security
- audit logging
- data lineage
- tags and policies
- compliance controls for enterprise workloads

### Open market governance
In the broader open ecosystem, governance is often done using a mix of:
- Hive Metastore for metadata
- AWS Glue Data Catalog
- Apache Atlas for metadata/governance
- Apache Ranger for security policies
- IAM / cloud-native ACLs
- external tools for lineage and discovery

So in the open market, governance is often spread across multiple tools, while Databricks tries to centralize it through Unity Catalog.

---

## 7) What does Databricks use for metastore?

Databricks uses a metastore service as part of Unity Catalog.

The modern approach is:
- Unity Catalog metastore = central metadata store
- connected to cloud storage
- managed by Databricks
- used across workspaces and accounts

For legacy systems, Databricks may also interact with Hive Metastore when working with older table metadata layouts, but the long-term modern direction is Unity Catalog metastore.

---

## 8) What is Iceberg and how does it fit in all this?

Apache Iceberg is an open table format for large analytic datasets.

It helps with:
- schema evolution
- partitioning
- time travel
- concurrent reads and writes
- compatibility across multiple query engines

Why Iceberg matters:
- It is vendor-neutral and open
- It works across Spark, Trino, Flink, Presto, and other engines
- It is a strong alternative to Delta Lake in open lakehouse ecosystems

### How it fits with Databricks
Databricks is strongly built around Delta Lake, but Iceberg is still relevant because:
- some organizations want open-format portability
- they use multiple engines and platforms
- they want to avoid lock-in to one vendor's table format

### Relationship between Delta, Iceberg, and Unity Catalog
- Delta Lake = transactional table format used natively in Databricks
- Iceberg = open table format for portability and multi-engine interoperability
- Unity Catalog = governance layer that can manage metadata and access across data assets, including tables in different formats

So the big picture is:
- Lakehouse = architecture
- Delta Lake = transactional format often used inside Databricks
- Iceberg = open format used for portability and interoperability
- Unity Catalog = governance and metadata control layer
- Metastore = metadata registry that stores information about tables and data assets

---

## Short summary

Databricks is built around a Lakehouse model, where data is stored in cloud object storage and managed with high-level catalog and governance services.

The core concepts are:
- Metastore = metadata catalog
- Unity Catalog = governance and catalog layer
- Delta Lake = transactional lakehouse format
- Iceberg = open alternative for cross-engine portability
- Lakehouse = combination of data lake + warehouse features

This is the modern pattern used in Databricks and in much of the open data ecosystem.

---

## 9) Difference between Data Lake, Lakehouse, Data Warehouse, and Delta Table

### Data Lake
A data lake is a large storage repository for raw data in cloud object storage such as AWS S3, Azure ADLS, or GCS.

- Stores raw and unstructured data cheaply
- Great for scalability and cost
- Often used for big data and ML workloads
- Weakness: less structured and less governed than a warehouse

### Data Warehouse
A data warehouse is a structured, curated analytics system designed for business reporting and SQL queries.

- High performance for BI and dashboards
- Works best with cleaned and modeled data
- Strong governance and query optimization
- More expensive than a data lake

### Lakehouse
A lakehouse combines the low-cost storage of a data lake with the governance, structure, and query capabilities of a data warehouse.

- Uses cloud object storage as the foundation
- Adds metadata, tables, transactions, and governance
- Supports SQL, BI, streaming, ML, and batch analytics
- Modern architecture used by Databricks

### Delta Table
A Delta table is a table format built on top of a data lake.

- Stores data in files like Parquet
- Uses a transaction log to track changes
- Supports ACID transactions
- Enables schema enforcement and evolution
- Allows time travel, MERGE, UPDATE, DELETE, and optimization

### Simple comparison
- Data lake = cheap raw storage
- Data warehouse = curated analytical system
- Lakehouse = lake + warehouse features together
- Delta table = transactional table layer inside the lakehouse

### In simple words
A data lake is where data is stored cheaply, a warehouse is where business analytics happens, a lakehouse is the modern hybrid model, and a Delta table is the table format that makes the lakehouse reliable and transaction-safe.

---

## 10) Where do Apache NiFi and Kafka fit in?

Apache Kafka and Apache NiFi are part of the data ingestion and streaming layer, not the final analytics storage layer.

### Kafka
Kafka is a distributed event streaming platform used to move and buffer real-time data.

It is commonly used for:
- ingesting logs and events from applications
- streaming transactions or sensor data
- decoupling producers from consumers
- building event-driven pipelines

Typical flow:
- application sends events to Kafka topic
- Spark or Databricks consumes the topic
- processed data is written to Delta tables or other storage

### Apache NiFi
NiFi is a data flow automation tool used for building data pipelines with visual orchestration.

It is commonly used for:
- collecting files from sources
- cleaning and transforming data
- routing data between systems
- scheduling data movement
- handling data quality and logging

NiFi is often used for operational ingestion, while Kafka is used for event transport and streaming.

### Where they fit in a Lakehouse architecture
A typical modern architecture looks like this:

- source systems generate data
- NiFi or Kafka collects and moves it
- data is landed in a raw storage layer or Kafka topic
- Spark/Databricks processes and transforms it
- results are stored as Delta tables in the lakehouse
- Unity Catalog provides governance and access control

### In simple words
- Kafka = high-speed event streaming backbone
- NiFi = pipeline orchestration and data movement tool
- Databricks/Lakehouse = storage, processing, analytics, and governance layer

So Kafka and NiFi sit before the lakehouse, feeding data into the analytics platform.

---

## 11) Is Apache NiFi more like Alteryx, Informatica, or Talend?

Yes, conceptually it is in the same family of tools.

Apache NiFi is similar to Alteryx, Informatica, and Talend because all of them are used to:
- move data between systems
- clean and transform data
- orchestrate data pipelines
- schedule and automate ETL/ELT workflows

### Main difference
NiFi is more focused on:
- flow-based data movement
- streaming and event-driven pipelines
- low-level ingestion and routing
- real-time or near-real-time processing

Alteryx, Informatica, and Talend are generally more enterprise ETL/data integration platforms with stronger business-oriented transformation and integration features.

### Simple understanding
- NiFi = data flow engine for ingestion and orchestration
- Alteryx / Informatica / Talend = enterprise ETL/data integration tools

So NiFi is similar in purpose, but more engineering-centric and pipeline-focused.

---

## 12) What is HTAP?

HTAP stands for Hybrid Transactional and Analytical Processing.

It is a system design where the same platform supports both:
- transactional workloads (OLTP) like inserts, updates, deletes, user-facing operations
- analytical workloads (OLAP) like reports, dashboards, aggregations, and BI

### Example
A banking or e-commerce system may need:
- fast online transactions from users
- real-time analytics on the same data

### Why it matters
Traditional systems often split these into separate databases: one for transactions and one for analytics.
HTAP tries to reduce that split by supporting both in one system.

### In simple words
HTAP = one system handling both live business transactions and analytics together.

---

## 13) What is LTAP?

LTAP stands for Lakehouse Transactional and Analytical Processing.

It is the modern idea that a lakehouse can support both:
- transactional operations on data
- analytical processing on the same lakehouse data

### Why LTAP is important
Delta Lake and other lakehouse table formats add ACID transactions and more warehouse-like behavior to lake storage.
This means the data lake can support operations that were once only possible in a warehouse.

### Relationship to HTAP
- HTAP = hybrid transactional + analytical processing, often in a database context
- LTAP = lakehouse-style transactional + analytical processing, built on cloud lake storage

So LTAP is more aligned with Databricks / Delta Lake / Lakehouse platforms.

---

## 14) What is Lakebase?

Lakebase is a concept tied to modern lakehouse architectures where the data platform tries to combine:
- cheap data lake storage
- transactional capabilities
- analytics performance
- easy SQL access

In Databricks context, Lakebase is often understood as the next evolution of lakehouse systems to make the platform more database-like while still keeping the lake storage foundation.

### Main idea
Lakebase aims to provide:
- low-cost cloud storage
- transactions and consistency
- SQL-focused analytics
- better support for operational and analytic workloads together

### In simple words
Lakebase = a more database-like lakehouse layer that brings transactional behavior closer to the data lake.

---

## Short concept map

- HTAP = database system doing both OLTP and OLAP
- LTAP = lakehouse doing both transactional and analytical work
- Lakebase = lakehouse/platform evolution toward database-like transactional capabilities
- Delta Lake = the transactional storage layer often used in a lakehouse
- Unity Catalog = governance and metadata layer

---

## 15) How does Flink + Iceberg fit in?

Apache Flink and Apache Iceberg fit together as a streaming + table-format combination for modern lakehouse architectures.

### Flink
Flink is a distributed stream processing engine.
It is used for:
- real-time processing
- event-driven pipelines
- stateful streaming applications
- continuous transformations and aggregations

### Iceberg
Iceberg is an open table format for analytic data.
It is used for:
- managing large datasets in object storage
- schema evolution
- partitioning and compaction
- time travel and snapshot-based reads
- multi-engine compatibility

### Why they fit well together
Flink is great at processing incoming data in real time, and Iceberg is great at storing and managing the resulting tables in an open, lakehouse-friendly way.

Typical pattern:
- Kafka or other streaming source sends events
- Flink processes the stream
- Flink writes results into an Iceberg table in S3/ADLS/GCS
- Spark, Trino, or other engines can read that Iceberg table for analytics

### Why this matters
This gives a modern open lakehouse pattern:
- Flink for streaming processing
- Iceberg for table format and metadata management
- cloud object storage for cheap storage
- multiple engines reading the same data

### In simple words
Flink handles the real-time stream processing, and Iceberg provides the open table format that makes that data manageable and portable in a lakehouse.

---

## 16) What is Apache Gravitino?

Apache Gravitino is an open-source metadata and data catalog project.

It helps manage and organize metadata such as:
- catalogs
- schemas
- tables
- data assets
- governance and discovery information

### Why it matters
Gravitino helps organizations:
- discover datasets more easily
- manage metadata across different systems
- keep governance and catalog information centralized
- support modern data platform architecture

### Where it fits
It sits in the metadata/governance layer, alongside ideas similar to:
- data catalog
- metadata management
- governance tools

### Relationship to Databricks and Unity Catalog
- Unity Catalog is Databricks’ governance/catalog layer
- Apache Gravitino is a broader open-source metadata catalog project
- both aim to provide organization, discovery, and governance over data assets

### In simple words
Gravitino is about metadata management and data cataloging, not storage or compute.

---

## 17) What is OLTP, batch processing, and real-time OLTP?

### OLTP
OLTP stands for Online Transaction Processing.

It is used for live transactional systems where many small operations happen consistently and quickly, such as:
- inserting orders
- updating balances
- saving customer records
- processing payments

Typical features:
- low latency
- high concurrency
- row-level updates and inserts
- strong transaction consistency

### Batch processing
Batch processing means processing data in groups or scheduled jobs instead of instantly.

Examples:
- nightly sales summary
- end-of-day reports
- ETL jobs
- warehouse refreshes

Typical features:
- large volumes
- scheduled execution
- high throughput
- not real-time

### Real-time OLTP
Real-time OLTP is OLTP where transactions must be processed immediately.

Examples:
- online banking transactions
- airline booking systems
- stock trading systems
- e-commerce order placement

Typical features:
- instant response
- immediate consistency
- user-facing transaction handling

### Data lake vs OLTP
A data lake is mainly built for:
- large-scale storage
- analytics
- batch processing
- machine learning
- historical analysis

It is usually not designed for classic OLTP workloads such as:
- frequent row-level updates
- very low-latency user transactions
- strict online business operations

### In simple words
- OLTP = live business transactions
- Batch = delayed processing in groups
- Real-time OLTP = immediate transaction processing
- Data lake = large-scale analytics and storage, not the classic OLTP system

---

## 18) What are the common lakehouse challenges?

Lakehouse architectures are powerful, but they also come with practical challenges.

### 1) File fragmentation
As data is written continuously, many small files may be created.

This can cause:
- slower reads
- more metadata overhead
- higher cost
- poor performance for queries

Typical fix:
- compact small files
- optimize tables
- write larger files
- use proper partitioning

### 2) Trash / rollback / version cleanup
Lakehouse tables keep transaction history and versions because of:
- updates
- deletes
- merges
- time travel
- rollback support

This can create:
- extra storage usage
- stale files remaining in storage
- metadata overhead

Typical fix:
- clean old snapshots
- configure retention periods
- run vacuum/cleanup jobs

### 3) CDC (Change Data Capture)
CDC means capturing changes from source systems as they happen.

Challenges include:
- duplicate events
- late-arriving data
- schema drift
- merge conflicts
- ordering issues
- idempotency

Typical fix:
- use Kafka or event stream for change events
- apply deduplication
- use merge logic into Delta/Iceberg tables
- track source offsets and checkpoints

### Why this matters
A lakehouse stores huge amounts of data in cloud object storage, so performance, cleanup, and change tracking become critical operational concerns.

### In simple words
The main lakehouse challenges are:
- too many small files
- cleanup of old versions and deleted data
- handling CDC safely and consistently

---

## 19) What is MPP and OLAP? What is real-time OLAP?

### MPP
MPP stands for Massively Parallel Processing.

It is a distributed computing architecture where a query is split across many nodes, and each node processes a part of the data in parallel.

This is commonly used in:
- data warehouses
- distributed SQL systems
- analytics engines
- big data processing platforms

### OLAP
OLAP stands for Online Analytical Processing.

It is used for analytical queries like:
- aggregations
- dashboards
- trend analysis
- reporting
- historical analysis

Typical features:
- read-heavy workload
- large scans
- BI and business intelligence use
- optimized for analytical queries rather than transactions

### Real-time OLAP
Real-time OLAP means analytical queries run on fresh data with very low delay.

This is used for:
- live dashboards
- operational analytics
- monitoring dashboards
- near real-time KPI reporting

### Relationship between MPP and OLAP
MPP is often the underlying architecture used to scale OLAP systems.

So the pattern is:
- OLAP = the type of workload
- MPP = the distributed architecture that powers it
- real-time OLAP = OLAP on fresh, recent data with low latency

### In simple words
MPP is how the system scales, OLAP is what the workload is doing, and real-time OLAP is doing analytics on near-live data.

---

## 20) What is StarRocks?

StarRocks is a high-performance analytical database built for fast SQL queries on large datasets.

It is commonly used for:
- OLAP workloads
- dashboards
- real-time analytics
- ad hoc query reporting

### Why it is used
StarRocks is optimized for:
- fast analytical queries
- columnar storage
- distributed computation
- low-latency SQL on large data

### Where it fits
It sits in the analytics layer, where users need quick query responses on big tables.

### Relationship with lakehouse
StarRocks is not a lakehouse table format like Delta or Iceberg.
It is more like a fast analytical engine that can query data efficiently from storage layers or data sources.

### In simple words
StarRocks is a fast OLAP database used for real-time and near real-time analytics.

---

## 21) What is Apache Doris?

Apache Doris is an open-source real-time analytical database.

It is used for:
- OLAP workloads
- interactive dashboards
- near real-time reporting
- high-concurrency analytical queries

### Why it matters
Doris is optimized for:
- fast SQL analytics
- low-latency query response
- distributed analytical processing
- large-scale BI workloads

### Where it fits
It sits in the analytics layer, similar to other fast OLAP engines for dashboard and reporting workloads.

### In simple words
Apache Doris is a fast analytical engine for near real-time SQL queries.

---

## 22) What is real-time analytics?

Real-time analytics means analyzing data almost immediately after it is generated.

Examples:
- live sales dashboards
- fraud detection alerts
- monitoring dashboards
- user activity analysis
- streaming KPI tracking

### Characteristics
- low latency
- continuous data processing
- near-instant query results
- often based on streaming data

### Difference from batch analytics
- Batch analytics = process data later in scheduled jobs
- Real-time analytics = process and query data continuously with little delay

### Typical architecture
- source systems generate events
- Kafka or stream processing handles ingestion
- Flink or Spark Streaming processes events
- analytical engine like StarRocks or Doris queries fresh data
- dashboards and BI tools display results

### In simple words
Real-time analytics means making decisions from fresh data, not from old reports.

---

## 23) What is ClickHouse?

ClickHouse is an open-source columnar database built for very fast analytical queries.

It is commonly used for:
- dashboards
- BI analytics
- log analysis
- observability
- large-scale aggregation queries

### Why it is used
ClickHouse is optimized for:
- columnar storage
- fast aggregations
- large analytical scans
- low-latency SQL on big data

### Where it fits
It belongs in the OLAP / analytics layer, alongside other fast query engines like StarRocks and Apache Doris.

### Relationship to lakehouse
ClickHouse is not a lakehouse storage format like Delta or Iceberg. It is more of a high-performance analytical database that can query large datasets efficiently.

### In simple words
ClickHouse is a very fast analytical database for dashboards and large query workloads.

---

## 24) What is data mesh architecture?

Data mesh is an architectural approach where data ownership is distributed by business domain instead of being centralized in one data team.

### Core idea
Each domain owns its data as a product and is responsible for:
- producing high-quality data
- maintaining data contracts
- making data discoverable
- providing access to other teams

### Main principles
- domain-oriented ownership
- data as a product
- self-serve data infrastructure
- federated governance

### Why it matters
In large organizations, a central data team alone may become a bottleneck.
Data mesh helps scale data operations by distributing responsibility across domains.

### Data mesh vs lakehouse
They are different layers:
- data lakehouse = storage and analytics architecture
- data mesh = organizational and ownership model

A company can use both together:
- lakehouse for technical architecture
- data mesh for team structure and governance

### In simple words
Data mesh is about organizing data by business domain, instead of centralizing everything in one team.

---

## 25) What are the expectations from a modern data engineer?

A modern data engineer is expected to do much more than move files from one place to another.

### Core expectations
- Build and maintain data pipelines for batch and streaming workloads
- Work with cloud storage and object storage systems
- Understand lakehouse architecture and modern table formats like Delta and Iceberg
- Work with Spark, SQL, and distributed processing systems
- Handle real-time and near-real-time data processing
- Manage data quality, validation, and schema evolution
- Ensure governance, lineage, and access control
- Design scalable and reliable systems with retries, checkpoints, and monitoring
- Understand orchestration tools such as Airflow or workflow automation
- Know when to use Kafka, NiFi, Flink, Spark, and analytical databases

### Business-level expectations
A modern data engineer must also connect technical work to business needs:
- what data is required?
- how quickly does it need to be available?
- who should access it?
- how trustworthy is it?
- how do we make it usable for analytics and AI?

### In simple words
A modern data engineer is expected to build production-grade, governed, scalable, and reliable data platforms for both analytics and real-time use cases.

---

## 27) What is the difference between a data lake, a query engine, and a lakehouse?

### Data lake
A data lake is the storage layer.

It stores raw data in low-cost object storage such as:
- S3
- ADLS
- GCS

It is used for:
- raw data capture
- large-scale historical storage
- ML and analytics workloads
- cheap and scalable retention

### Query engine
A query engine is the processing layer.

It reads the stored data and executes queries, such as:
- Spark SQL
- Trino
- Presto
- Flink
- StarRocks
- ClickHouse

It is responsible for:
- filtering
- joining
- aggregation
- transformations
- returning results to dashboards or applications

### Lakehouse
A lakehouse is the architecture that combines the best of a data lake and a warehouse.

It adds:
- transaction support
- metadata and governance
- SQL/BI-friendly structure
- better analytics and reliability

### Simple comparison
- Data lake = storage
- Query engine = compute / execution layer
- Lakehouse = storage + table metadata + analytics + governance

### Example
A company may store raw files in S3:
- S3 = data lake
- Spark/Trino = query engines
- Delta/Iceberg on top = lakehouse architecture

---

## 28) What is liquid clustering?

Liquid clustering is a Delta Lake optimization technique that helps organize table data more efficiently for query performance.

### Why it is used
Traditional partitioning can become inefficient when:
- partitions are too small
- data is skewed
- query patterns change over time
- large tables are updated frequently

Liquid clustering helps by better arranging files and data layout based on common access patterns.

### Main idea
Instead of relying only on static partitioning, Delta can cluster data more dynamically to reduce unnecessary reads and improve performance.

### Typical use case
If queries often filter on columns like:
- customer_id
- date
- region
- product_id

liquid clustering can make those reads faster.

### In simple words
Liquid clustering is a smarter way to organize large Delta tables so queries read less data and run faster.

---

## 26) What is delta.checkpointInterval?

`delta.checkpointInterval` is a Delta Lake setting that controls how often Delta writes a checkpoint file.

### Why it matters
Delta stores transaction history in a transaction log. Checkpoints are compact summaries of that log and help speed up reads and recovery.

### Effect of the setting
- Lower value = more frequent checkpoints, faster recovery, more checkpoint files
- Higher value = fewer checkpoints, less overhead, but slower recovery or reads after long history

### In simple terms
It decides how often Delta saves a compact snapshot of table changes so the table can be recovered and read efficiently.

### Typical use
This is usually tuned in production when dealing with large Delta tables and performance-sensitive workloads.

### Example
Imagine a Delta table receives 100 transactions in a day.

- Delta writes transaction history for all 100 updates
- if `delta.checkpointInterval` is 10, Delta writes a checkpoint after every 10 transactions
- the system can recover from the latest checkpoint instead of reading the full old log history

This is similar to saving a game every few minutes so you do not lose progress.

---
