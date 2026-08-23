# Day 2 Question

## Q: What is Spark?
Spark is a distributed data processing engine used for batch processing, streaming, SQL analytics, machine learning, and graph processing.

### Best short answer:
"Spark is a distributed compute engine for processing large datasets across clusters."

---

## Q: What is the difference between the driver and executor?
The driver coordinates the job and schedules tasks, while the executor runs the tasks and stores data in memory or on disk.

### Best short answer:
"The driver manages execution; executors do the actual work on cluster nodes."

---

## Q: What is lazy evaluation in Spark?
Lazy evaluation means Spark builds a logical execution plan and does not run transformations until an action is triggered.

### Why it matters
This lets Spark optimize the whole plan before execution.

### Best short answer:
"Spark delays execution until an action is called, allowing it to optimize the full transformation graph."

---

## Q: What is a transformation?
A transformation creates a new RDD, DataFrame, or Dataset from an existing one.

Examples:
- map
- filter
- join
- groupBy
- select

---

## Q: What is an action?
An action triggers execution and returns a result to the driver or writes data to storage.

Examples:
- count
- collect
- show
- save
- reduce

---

## Q: What is a partition in Spark?
A partition is a chunk of data that can be processed independently in parallel.

### Why it matters
Partitioning controls parallelism and affects performance, skew, and shuffle cost.

---

## Q: What is a narrow dependency?
A narrow dependency means each partition of the parent dataset is used by at most one partition of the child dataset.

### Example
- map
- filter
- flatMap

### Best short answer:
"A narrow dependency usually avoids shuffle because each input partition stays local to one output partition."

---

## Q: What is a wide dependency?
A wide dependency means data from many partitions must be combined, usually through a shuffle.

### Example
- groupByKey
- reduceByKey
- join
- distinct

---

## Q: What is network shuffle?
A network shuffle is the movement of data across cluster nodes so records with the same key are grouped together.

### Why it is expensive
- disk write
- network transfer
- serialization
- stage synchronization

### Best short answer:
"Shuffle is the expensive process of redistributing data across the cluster for operations that require grouping by key or combining partitions."

---

## Q: How do narrow and wide dependencies affect executor count and memory?
They affect how much data must be moved and how much memory is needed at each stage.

### Narrow dependency
A narrow dependency means each parent partition contributes to at most one child partition.

This usually means:
- no shuffle
- local processing
- lower network cost
- less memory pressure for intermediate data

So a job with mostly `map`, `filter`, and `select` can often work well with moderate executor count and moderate memory per executor.

### Wide dependency
A wide dependency means many parent partitions must be combined, usually through a shuffle.

This usually means:
- shuffle across the cluster
- stage barrier
- larger intermediate data set
- more memory for aggregation, sorting, and buffering

So jobs with `groupBy`, `join`, `distinct`, or `reduceByKey` usually need:
- more executors
- more memory per executor
- more headroom for shuffle and spill

### Simple rule
- Narrow dependency = less shuffle, lower memory pressure, fewer executors may be enough
- Wide dependency = more shuffle, more memory pressure, more executors usually needed

### Best short answer:
"Narrow dependencies keep work local and reduce shuffle, so fewer executors and less memory may be enough. Wide dependencies trigger shuffle and aggregation, so more executors and larger executor memory are usually needed to handle network traffic, merge cost, and spill risk."

---

## Q: What is job chaining in Spark?
Job chaining means multiple Spark actions in the same program create multiple jobs, one after another.

### Why it happens
Spark creates a new job whenever it sees an action such as:
- `count()`
- `collect()`
- `show()`
- `write()`
- `save()`

Each action triggers a new DAG of stages and tasks.

### Example
If a pipeline does:
- filter
- aggregate
- write output
- then another action like `count()`

Spark may run more than one job in sequence.

### Why it matters
Job chaining affects:
- total runtime
- executor utilization
- network shuffle cost
- memory pressure
- cloud cost

### How to plan for it
- reduce unnecessary actions
- combine transformations before writing
- avoid repeated scans of the same data
- size the cluster for the heaviest job in the chain
- use caching only when the data is reused enough to justify it

### Best short answer:
"Job chaining is when multiple Spark actions produce multiple sequential jobs. To plan for it, reduce repeated actions, combine transformations, and size the cluster for the most expensive stage in the chain so shuffle-heavy work does not create bottlenecks."

---

## Q: What is a DAG in Spark?
A DAG is a Directed Acyclic Graph of stages and tasks created from user transformations.

### Why it matters
It helps Spark plan execution, schedule parallel work, and identify where stages and shuffles are needed.

---

## Q: What is a stage in Spark?
A stage is a group of tasks that can run without a shuffle.

### Important idea
A shuffle creates a new stage boundary.

---

## Q: What is the difference between task and stage?
- task = smallest unit of work
- stage = collection of tasks that can run together without shuffle

---

## Q: What is the role of the cluster manager?
The cluster manager allocates resources to the Spark application.

Examples:
- YARN
- Kubernetes
- Mesos
- standalone mode

---

## Q: What is a cache in Spark?
Caching stores intermediate data in memory or disk so it can be reused in later computations.

### When it helps
- iterative algorithms
- repeated queries
- multi-step ETL

### Best short answer:
"Caching is useful when the same data is reused multiple times and memory is available."

---

## Q: What is data skew?
Data skew happens when some partitions have much more data than others.

### Effects
- long-running tasks
- uneven workload distribution
- poor performance

---

## Q: What is a broadcast join?
A broadcast join sends the smaller table to all executors so the join can happen locally without a large shuffle.

### Best short answer:
"A broadcast join is useful when one side of the join is small enough to be copied to each worker."

---

## Q: What is Py4J?
Py4J is the library that allows Python to communicate with the JVM-based Spark runtime.

### Best short answer:
"Py4J is the bridge between Python and Spark's JVM engine."

---

## Q: Does Py4J make Python fast?
No. It only enables communication with the JVM. It does not remove serialization cost or Python overhead.

### Best short answer:
"Py4J enables Python to talk to Spark, but it does not make Python code automatically fast."

---

## Q: Why do Scala and Python code in Spark have different shuffle time?
Scala code runs natively on the JVM, while Python code in PySpark has extra serialization and worker overhead.

### Best short answer:
"Scala is usually faster because it runs natively on the JVM with less serialization overhead."

---

## Q: What is Spark SQL?
Spark SQL is Spark's structured query engine that supports SQL and DataFrame APIs.

### Why it is important
It gives a high-level, optimized way to work with structured data.

---

## Q: What is the Catalyst optimizer?
Catalyst is Spark SQL's optimizer. It rewrites logical plans into more efficient execution plans.

### Example optimizations
- filter pushdown
- join optimization
- reduction of unnecessary scans

---

## Q: What is CBO?
CBO stands for Cost-Based Optimizer.

### Purpose
It compares estimated execution costs and chooses the best plan.

---

## Q: Why are executors and cores important from a business perspective?
They indicate the amount of parallel compute available in the cluster, which affects speed, cost, and SLA compliance.

### Best short answer:
"Executors and cores tell us the cluster's processing capacity, which directly affects performance, cloud cost, and business deadlines."

---

## Q: Does the number of executors depend on workers or on the whole cluster?
Yes. Executors run on worker nodes, so the number of executors depends on the cluster's worker resources as well as the overall cluster size.

### Main idea
- Cluster = all the machines or VMs
- Worker node = a machine in the cluster
- Executor = a JVM process that runs on a worker
- Core = CPU resource used by that executor

So the real formula is:
- executor count depends on worker count
- worker count depends on cluster capacity
- executor size depends on memory and cores available on each worker

### Example
Suppose the cluster has:
- 6 workers
- 8 cores per worker
- 32 GB memory per worker

If you choose:
- 4 cores per executor
- 16 GB memory per executor

Then each worker can host about 2 executors.

Total executors ≈ 6 × 2 = 12 executors.

### Why this matters
If you decide executor count without checking workers, you will overestimate capacity and underutilize or overload the cluster.

### Best short answer:
"Executors are created on worker nodes, so the number of executors depends on the number of workers and the CPU/RAM available on each worker, not just on the cluster name or total node count."

---

## Q: How do we decide the number of executors and executor memory?
Use this simple planning method.

### Step 1: Check worker resources
For each worker, ask:
- how many cores does it have?
- how much memory does it have?

### Step 2: Choose cores per executor
A common starting point is:
- 3 to 5 cores per executor

### Step 3: Choose memory per executor
A common starting point is:
- 4 to 8 GB memory per core

Example:
- 4 cores per executor
- 16 GB memory per executor
- 2 executors per worker
- 6 workers

Total cluster capacity:
- 12 executors
- 48 total cores
- 192 GB total executor memory

### Step 4: Adjust for workload
Increase memory if the job has:
- large joins
- heavy aggregation
- lots of shuffle
- large cache
- frequent spills to disk

### Step 5: Balance cost and performance
If you make executors too small, you get too much overhead. If you make them too large, you underuse the cluster and lose parallelism.

### Best short answer:
"Choose executor count based on target parallelism and worker capacity, then choose executor memory based on the largest intermediate working set and shuffle pressure. A common starting point is 3–5 cores per executor and 4–8 GB per core, adjusted for join-heavy and shuffle-heavy jobs."

---

## Q: Should we avoid a single point of failure when sizing Spark resources?
Yes. A Spark cluster should not be designed so that one worker or one executor is critical for the whole job.

### Why this matters
If one node fails and it holds too much work, the job becomes slow or fails. This creates a single point of failure.

### Example
If a cluster has only:
- 2 workers
- 1 executor per worker

then losing one worker may cut your compute capacity by 50%.

This is fragile. A better design is to spread executors across multiple workers and keep some headroom.

### Good design practice
- distribute executors across multiple workers
- avoid putting too much work into a single executor
- keep enough spare capacity for failure and retry
- avoid extreme data skew on one node

### Best short answer:
"Yes, avoid a single point of failure by distributing executors across multiple workers and not overloading one node. A resilient Spark cluster should have enough redundancy and headroom so one failed worker does not collapse the whole job."

---

## Q: Why is Spark important in modern data engineering?
Spark sits in the compute layer between ingestion, processing, and analytics. It is used to transform raw data into curated tables for warehousing, lakehouse, and ML use cases.

---

## Q: What is the main idea of Day 2?
Day 2 focuses on Spark internals: execution model, partitions, shuffle, DAG, optimization, memory, and cluster capacity.

### Best short answer:
"Day 2 is about how Spark actually executes work across a cluster and why performance depends on planning, partitioning, and resource sizing."

---

## Q: How much memory do we want per Spark executor, and how do we decide it?

The memory per executor should be enough to handle the task workload, shuffle buffers, and garbage collection overhead without spilling too much data to disk.

### Main idea

If the executor has too little memory, tasks will spill to disk, GC will slow down, and performance will degrade badly. If it has too much memory, you may underutilize the cluster and waste resources.

### Practical rule of thumb

A common starting point is:

- 3 to 5 cores per executor
- 4 to 8 GB memory per core is a common planning range
- but final sizing depends heavily on shuffle and join behavior

For example:

- 4 cores per executor
- 16 GB memory per executor
- total of 10 executors

This often works well for moderate ETL workloads.

### Why memory matters

Memory is used for:

- task execution
- shuffle buffers
- join and aggregation state
- intermediate data
- JVM overhead
- garbage collection

If a job does a large `groupBy`, `join`, or `sort`, it may need much more memory than a simple filter-and-map job.

### Example

Suppose a job reads 100 GB of raw data, filters it down, and then joins it with a small customer table before aggregating sales by month.

This job needs enough executor memory to:

- hold the shuffled data temporarily
- hold aggregation state
- avoid excessive spilling to disk
- survive JVM GC overhead

If each executor has only 4 GB, the job may spill constantly and become slow.

If each executor has 16 GB or 24 GB, it can often complete more smoothly.

### Good planning approach

- start with enough memory for the largest intermediate step
- if there is heavy shuffle, increase memory per executor
- if there are many small tasks, keep the executor count reasonable and avoid too many tiny partitions
- balance memory and core count so each executor has enough to execute tasks without becoming memory-limited

### Best short answer:

"Memory per executor should be large enough to handle task execution, shuffle, and aggregation, but not so large that the cluster is underutilized; a common starting point is around 4–8 GB per core, adjusted according to shuffle-heavy and join-heavy workloads."

---

## Q: What do the 128 MB and 60:40 memory rules mean in Spark?

These are common tuning heuristics, not strict universal laws.

### 128 MB idea

The 128 MB value is often used as a practical default when discussing per-task or per-block memory assumptions in Spark tuning examples.

It is useful as a rough starting point because:

- it is small enough to encourage careful memory planning
- it helps avoid oversized tasks
- it gives a starting mental model for memory pressure

But in real systems, the right value depends on:

- executor memory size
- shuffle intensity
- join size
- cache usage
- JVM overhead
- data skew

### 60:40 idea

The 60:40 rule usually refers to Spark memory split, where roughly:

- 60% of the memory pool is for execution
- 40% is for storage/caching

This is a common rule of thumb because Spark needs memory for both:

- running tasks and shuffle buffers
- cached or persisted data

### Why this matters

If the job is shuffle-heavy, execution memory matters more.
If the job caches a lot of data, storage memory matters more.
If the split is wrong, Spark may spill to disk or trigger heavy GC.

### Best short answer:

"128 MB and 60:40 are useful rules of thumb for Spark memory planning, but the real numbers should be adjusted to the workload; if shuffle or caching dominates, the memory split and executor size should be tuned accordingly."

---

## Q: If my file size is 1 GB, how much memory is required in Spark, and is it okay to think in terms of 128 MB blocks?

A 1 GB file does not automatically mean you need 1 GB of memory.

### Key idea

Spark memory is not based only on file size. It is based on:

- how the data is partitioned
- whether there are joins or aggregations
- whether there is shuffle
- whether data is cached
- whether task execution spills to disk
- how much memory is needed for JVM overhead and GC

### Example with 128 MB blocks

If your file is 1 GB and your chunk/block size is 128 MB:

```text
1 GB / 128 MB ≈ 8 blocks
```

So you might think of 8 blocks or 8 partitions.

This is a useful mental model, but it does not mean memory must be 8 × 128 MB = 1 GB or 8 × 256 MB ≈ 2 GB.

The 60:40 memory split is inside executor memory, not a direct formula for raw input size.

### Why the estimate is larger in practice

A simple file read may use close to the raw size, but a job with:

- `groupBy`
- `join`
- `sort`
- aggregation
- shuffle
- cache

can easily require several times the raw data size in memory.

### Practical estimate

For a 1 GB workload, a common starting point is:

- simple job: around 16–32 GB cluster memory
- moderate ETL job: around 32–64 GB cluster memory
- shuffle-heavy job: 64 GB or more

### Good interview answer

"A 1 GB file roughly becomes 8 blocks at 128 MB each, but Spark memory planning depends on the largest intermediate working set, not just the raw file size. The 60:40 split is inside executor memory, so the real memory requirement is usually several times the raw data size when there are joins, aggregations, and shuffle."

---

## Q: How do you decide how many cores are needed in Spark?

The usual approach is to decide based on how many tasks you want to run in parallel, not based only on file size.

### Basic idea

Spark can generally run as many tasks in parallel as there are available cores.

So a simple rule is:

```text
Total cores needed ≈ number of tasks you want to run simultaneously
```

### Common planning rule

A common starting point is:

- 3 to 5 cores per executor
- 2 to 4 tasks per core is often a healthy target

Example:

- 4 cores per executor
- 5 executors
- total cores = 20

This means the job can run roughly 20 tasks in parallel at a time.

### Why not use all the cluster resources?

Even if a cluster has many cores, a stage may not use all of them if:

- there are not enough partitions
- a join or groupBy creates a shuffle boundary
- there is data skew
- I/O or memory is the bottleneck

### Example

If the cluster has 48 cores, but the stage only has 12 partitions, Spark cannot run more than about 12 tasks at that moment.

So the real parallelism is limited by both:

- total cluster cores
- available partitions and stage structure

### Practical decision method

1. Estimate the job type
2. Decide target parallelism
3. Set executor count and cores per executor
4. Keep task count around 2–4 per core
5. Adjust for shuffle and skew
6. Monitor actual task concurrency and bottlenecks

### Best short answer:

"Choose the number of cores based on the number of tasks you want to run in parallel, usually around 2–4 tasks per core, while also checking partitions, shuffle boundaries, and memory pressure."

---

## Q: Does 1 task require 1 core?

Usually, yes. In normal Spark planning, one task is typically assigned to one core at a time.

### Main idea

If an executor has 4 cores, it can run about 4 tasks concurrently.

If you have 10 executors with 4 cores each, the cluster can run roughly 40 tasks at the same time.

### Important nuance

This is a good rule of thumb, but not a strict law. The actual concurrency also depends on:

- number of partitions
- stage boundaries
- shuffle
- data skew
- memory pressure
- I/O bottlenecks

### Example

A cluster with:

- 6 executors
- 4 cores each

has about 24 total cores. The job can usually run around 24 tasks in parallel, assuming enough partitions and no major bottleneck.

### Best short answer:

"Yes, in normal Spark planning, one task usually uses one core, and total parallel tasks are roughly equal to total available cluster cores."

---

## Q: What does 'waves of parallelism' mean in Spark?

This phrase refers to the fact that Spark does not usually schedule all tasks in one giant burst. It schedules tasks in waves as dependencies are satisfied.

### Main idea

A wave is a group of tasks that can start together because their inputs are available and the cluster has capacity.

### Example

Suppose a job has:

- Stage 1: read and filter data
- shuffle
- Stage 2: group by key and aggregate
- Stage 3: write output

Spark may run:

- wave 1: all tasks in stage 1
- wave 2: tasks in stage 2 after the shuffle completes
- wave 3: final output tasks

The next wave only starts after previous dependencies are complete.

### Why this matters

This explains why Spark may look only partially parallel at times. It is not because Spark is slow; it is because:

- stages depend on each other
- shuffle creates a barrier
- tasks wait until the previous step finishes

### Best short answer:

"Waves of parallelism means Spark schedules tasks in groups as dependencies are resolved, so work proceeds stage by stage rather than all tasks running simultaneously."

---

## Q: Final summary: how do you decide the amount of parallelism, memory, and cores required in Spark?

Use a simple workload-based planning method:

### Step 1: estimate workload type

Ask whether the job is:

- simple read/filter/transform
- join-heavy
- aggregation-heavy
- shuffle-heavy
- cached or iterative

### Step 2: estimate parallelism needed

A good starting target is:

- 2–4 tasks per core
- total parallel tasks roughly equal to total cluster cores

### Step 3: choose executor size

Common starting point:

- 3–5 cores per executor
- 4–8 GB memory per core

Example:

- 4 cores per executor
- 16 GB memory per executor
- 3 executors
- total = 12 cores and 48 GB

### Step 4: decide memory by intermediate work

Memory should cover:

- task execution
- shuffle buffers
- aggregation state
- cache and storage
- GC overhead

If there are joins, groupBy, sort, or large shuffles, increase memory.

### Step 5: leave headroom

Do not allocate all cluster resources to one job. Keep some capacity free for other workloads.

### Final answer

"For Spark, parallelism is decided by target concurrent tasks, memory is decided by the largest intermediate working set, and cores are chosen to match the executor count and task concurrency. A common starting point is 3–5 cores per executor and 4–8 GB memory per core, then adjust upward for shuffle-heavy or join-heavy workloads."

---

## Q: How do you evaluate data and plan for parallel processing without hogging all the Spark cluster resources?

The right answer is to estimate the workload first and then size the job for useful parallelism, not maximum possible parallelism.

### Step 1: Understand the workload

Ask:

- How large is the dataset?
- How many partitions are there?
- Are there joins, groupings, or aggregations?
- Are we reading from object storage, a warehouse, or Kafka?
- Is the bottleneck CPU, memory, or shuffle?

### Step 2: Measure the data pattern

Suppose a company has a daily ETL job reading 1 TB of sales events.

The job performs:

- filter for the last 30 days
- join with a small customer dimension table
- aggregate total sales by store and date

This is not a simple row scan. It includes:

- reading a lot of raw data
- join logic
- aggregation
- shuffle because of grouping by store and date

So the system is likely shuffle-heavy and memory-sensitive, not just CPU-heavy.

### Step 3: Check cluster size and resource balance

Assume the cluster has:

- 12 executors
- 4 cores per executor
- 16 GB memory per executor

That gives about 48 cores total. In a balanced configuration, that is useful parallelism, but not enough to give every workload all resources at once.

If this ETL job gets all 12 executors, it may finish faster, but it will also consume most of the cluster and block other jobs.

### Step 4: Use a reasonable parallelism target

A good rule is to aim for a modest number of tasks per core, such as 2 to 4 tasks per core, rather than using every possible slot.

If the cluster has 48 cores:

- 48 cores × 2 tasks/core = around 96 tasks
- 48 cores × 4 tasks/core = around 192 tasks

This is often a better target than creating thousands of tiny partitions that increase scheduling overhead.

### Step 5: Tune partitions

If the input is read as a single huge file, Spark may create only a few partitions, resulting in poor parallelism.

If it is split too finely, it may create too many small tasks.

A better plan might be:

- start with a partition count near the cluster capacity
- avoid very large partitions
- avoid tiny partitions that cause overhead
- set repartition only where necessary

### Step 6: Reduce shuffle where possible

This job joins a large fact table with a small dimension table. Instead of shuffling the entire fact table, the best strategy is:

- filter the raw data early
- select only required columns
- use broadcast join if the dimension table is small enough

Without this, Spark may shuffle huge amounts of data across nodes to complete the aggregation.

### Step 7: Reserve headroom

Even if the cluster is big enough to run the job quickly, you should not assign all resources permanently.

For example:

- keep some executors for other jobs
- use dynamic allocation
- set min and max executors
- maintain fairness across workloads

This prevents one ETL job from starving the rest of the cluster.

### Step 8: Watch the bottlenecks

After running the job, examine:

- executor CPU utilization
- shuffle read/write
- executor memory usage
- GC time
- spill to disk
- skewed tasks

If the job is spending time in shuffle, the issue may be:

- poor key distribution
- too much aggregation
- no broadcast optimization
- skewed join keys

If tasks are spilling to disk, the issue may be:

- too little memory per executor
- too many rows per partition
- too strong a parallelism setting

### Example of a balanced plan

For the 1 TB ETL example:

- 12 executors
- 4 cores each
- memory tuned for aggregation and shuffle
- filter before join
- broadcast the small dimension table
- partition by date and store key if reused repeatedly
- leave some executors available for other jobs

This gives good throughput without consuming the whole cluster.

### Best short answer:

"Evaluate the dataset, understand whether the job is CPU-, memory-, or shuffle-bound, then choose a moderate executor/core configuration, tune partitions, reduce shuffle, and reserve headroom so the job runs efficiently without monopolizing the entire cluster."

---

## Q: What is the main idea of Day 2?
Day 2 focuses on Spark internals: execution model, partitions, shuffle, DAG, optimization, memory, and cluster capacity.

### Best short answer:
"Day 2 is about how Spark actually executes work across a cluster and why performance depends on planning, partitioning, and resource sizing."
