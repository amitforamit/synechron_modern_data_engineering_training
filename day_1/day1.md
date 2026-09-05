# Day 1 Notes

## 2026-08-22

### Topics

- Modern Data Engineering — Day 1
- OLTP vs OLAP

### Keywords

- Day 1
- Modern Data Engineering
- OLTP (Online Transaction Processing)
- OLAP (Online Analytical Processing)
- Transactional workloads
- Analytical workloads
- Row-oriented databases
- Column-oriented databases
- Normalization and denormalization
- Real-time transactions
- Historical analysis
- ACID
- Atomicity
- Consistency
- Isolation
- Durability
- Normalization
- 1NF
- First Normal Form
- 2NF
- Second Normal Form
- 3NF
- Third Normal Form

---

## Topic Details

### OLTP vs OLAP

#### OLTP — Online Transaction Processing

OLTP systems run the day-to-day operations of an application or business. They process a large number of short, real-time transactions such as inserting an order, updating an account balance, booking a ticket, or recording a payment.

**Main characteristics:**

- Handles frequent `INSERT`, `UPDATE`, and `DELETE` operations.
- Usually serves many concurrent users.
- Requires fast response times, often measured in milliseconds.
- Stores current, detailed operational data.
- Commonly uses normalized tables to reduce duplication and maintain consistency.
- Transactions are expected to follow ACID properties: Atomicity, Consistency, Isolation, and Durability.
- Typically uses row-oriented storage because an operation often reads or changes a complete row.

### ACID concept

ACID is a set of properties that ensure database transactions are reliable and safe, especially in OLTP systems.

- **Atomicity:** A transaction is treated as a single unit. Either all changes are committed, or none are applied.
- **Consistency:** The database moves from one valid state to another valid state after the transaction.
- **Isolation:** Transactions are kept separate from each other so concurrent transactions do not interfere with one another.
- **Durability:** Once a transaction is committed, its changes remain saved even if the system crashes afterward.

**Example:** When transferring money between two accounts, the debit from one account and the credit to another account must both succeed together. If the system fails midway, the transaction should not leave the database in a partial state.

**Examples:**

- Banking transaction system
- E-commerce ordering system
- Airline or railway reservation system
- Point-of-sale system
- Customer relationship management application

**Example transaction:**

When a customer places an online order, the OLTP system creates the order, reduces available inventory, records the payment, and updates the order status.

### 1NF (First Normal Form)

A table is in 1NF if it has no repeating groups and each column stores only one value.

**Rules:**

- Each column contains atomic values.
- Each row is unique.
- No multiple values in one cell.
- Each record stores one value for each field.

**Example:**

Instead of having a single cell like `Phone = 99887766, 88990011`, store them in separate rows or a separate linked table.

### 2NF (Second Normal Form)

A table is in 2NF if:

1. It is already in 1NF.
2. Every non-key attribute is fully dependent on the entire primary key.

This mainly applies to tables with composite keys (keys made of more than one column).

**Meaning:**

No column should depend only on part of a composite key.

**Example:**

If a table has `(StudentID, CourseID)` as the primary key, then `StudentName` depends only on `StudentID`, not on the full composite key. That violates 2NF.

To fix it, split the data into separate tables: one for students and one for course enrollments.

### 3NF (Third Normal Form)

Third Normal Form is a database normalization rule used to reduce duplication and improve data integrity.

A table is in 3NF if:

1. It is already in 2NF.
2. All non-key attributes are dependent only on the primary key.
3. There are no transitive dependencies, meaning no non-key column depends on another non-key column.

In simple words, every piece of data should be stored in only one place and should be directly related to the entity it belongs to.

**Example:**

Instead of storing customer city and state in both the Orders table and the Customers table, keep them in the Customers table and reference the customer using a key.

**Why 3NF matters:**

- Reduces duplicate data
- Makes updates easier and safer
- Prevents inconsistent records
- Improves data quality in OLTP systems

**Example of violation:**

If a table contains `StudentID`, `StudentName`, `DepartmentName`, and `HODName`, then `HODName` depends on `DepartmentName`, not directly on `StudentID`. This is a transitive dependency and violates 3NF.

#### OLAP — Online Analytical Processing

OLAP systems are designed to analyze large volumes of data for reporting, planning, and decision-making. Instead of recording individual business transactions, they answer analytical questions using current and historical data collected from one or more operational systems.

**Main characteristics:**

- Handles complex, read-heavy queries with aggregations and joins.
- Usually serves analysts, data scientists, managers, and reporting tools.
- Queries may scan millions or billions of records.
- Stores integrated historical data from multiple sources.
- Often uses denormalized models such as star and snowflake schemas.
- Commonly uses column-oriented storage because analytical queries usually read selected columns across many rows.
- Data is generally loaded through ETL or ELT pipelines in batches or streams.

**Examples:**

- Enterprise data warehouse
- Sales performance dashboard
- Customer-behaviour analytics platform
- Financial forecasting system
- Business intelligence reporting system

**Example analysis:**

A business may use an OLAP system to calculate monthly revenue by product category, customer segment, and region over the previous five years.

#### Comparison

| Area | OLTP | OLAP |
|---|---|---|
| Primary purpose | Run business operations | Analyze business performance |
| Typical users | Customers and operational staff | Analysts, managers, and data scientists |
| Workload | Many short transactions | Fewer but complex analytical queries |
| Main operations | Insert, update, delete, and point lookup | Read, aggregate, join, and scan |
| Data | Current and detailed | Historical, integrated, and often aggregated |
| Data model | Usually normalized | Usually denormalized or dimensional |
| Storage orientation | Commonly row-oriented | Commonly column-oriented |
| Response expectation | Milliseconds or seconds | Seconds to minutes, depending on query size |
| Examples | PostgreSQL, MySQL, SQL Server | Snowflake, BigQuery, Redshift, Databricks SQL |

#### How they work together

OLTP and OLAP are complementary systems. Operational applications first create data in OLTP databases. Data pipelines then extract and transform that data before loading it into an OLAP platform for reporting and analysis.

```text
Customer action
      ↓
OLTP application/database
      ↓
ETL or ELT data pipeline
      ↓
OLAP warehouse/lakehouse
      ↓
Dashboard, report, or machine-learning analysis
```

#### Simple way to remember

- **OLTP asks:** What is happening right now?
- **OLAP asks:** What happened over time, why did it happen, and what can we learn from it?
