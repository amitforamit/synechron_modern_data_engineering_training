# Addendum / Spark Performance Cheat Sheet Lab

Compact addendum for the completed Advanced PySpark Examples 1–50 series.

## What it closes

### Training curriculum gaps
- coalesce
- file sizes
- small-file problem
- data locality
- Spark UI walkthrough
- Jobs / Stages / Tasks / Executors / SQL tab
- execution metrics
- stragglers
- GC and memory diagnosis
- Tungsten / Whole-Stage Code Generation

### Cheat-sheet-specific additions
- AQE parallelismFirst
- advisory partition size
- initial partition count
- dynamic partition overwrite
- skew factor
- skew threshold
- force optimize skew join
- REBALANCE hint
- storage-partitioned join concept

## Contents
- Addendum_Spark_Performance_Cheat_Sheet_Lab.ipynb
- data/customers.csv
- data/orders.csv
- data/products.csv

## Important
The data is intentionally tiny. Use execution plans and the Spark UI to teach mechanics. Use larger data/cluster environments when demonstrating real spill, GC pressure, AQE skew splitting, locality, or storage-partitioned joins.
