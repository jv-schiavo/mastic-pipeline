# Mastic Data Pipeline & Power BI Project

## Project Overview

An end-to-end data pipeline for a mastic and construction services business, built on
Azure SQL and Power BI. Raw operational job data flows through a three-layer medallion
architecture — Bronze, Silver, Gold — into an analytics-ready star schema that powers
a Power BI dashboard for job performance and revenue reporting.

## Architecture

```
Python seed generator
        ↓
Bronze Layer (Azure SQL)
        ↓  SQL transformation
Silver Layer (Azure SQL)
        ↓  SQL transformation
Gold Layer — Star Schema (Azure SQL)
        ↓  Power BI Import
Power BI Dashboard
```

## Business Context

A mastic contracting business generates operational records across jobs, sites, clients,
workers, materials, invoices, and payments. This project structures that data into a
reliable reporting model, enabling the business to track job performance, monitor
outstanding invoices, and analyse material costs by client and site.

---

## Data Pipeline Layers

### Bronze Layer

Raw landing zone. Stores operational records exactly as received from the source system
with no transformation. Acts as an immutable audit trail.

```
bronze.raw_jobs
```

Populated by a Python seed generator (`sql/scripts/generate_bronze_seed.py`) that
produces realistic mastic business data — clients, sites, jobs, workers, materials,
invoices, and payments.

### Silver Layer

Cleaned and normalised business entities. Bronze data is decomposed into proper
relational tables with foreign key constraints and deduplication. Transformation is
idempotent — safe to re-run without creating duplicate records.

```
silver.clients
silver.sites
silver.jobs
silver.employees
silver.employee_assignment
silver.materials
silver.material_usage
silver.work_log
silver.invoices
silver.invoice_jobs
silver.payments
```

**Transformation:** `sql/transformation/transform_bronze_to_silver.sql`
**Validation:** `sql/validation/validate_silver_integrity.sql`

### Gold Layer — Star Schema

Analytics-ready dimensional model. Silver data is transformed into fact and dimension
tables with surrogate keys, optimised for Power BI reporting.

**Fact tables:**
```
gold.fact_jobs              — one row per job
gold.fact_work_log          — one row per employee per job per day
gold.fact_material_usage    — one row per material used per job
gold.fact_invoices          — one row per invoice
gold.fact_payments          — one row per payment
```

**Dimension tables:**
```
gold.dim_clients
gold.dim_sites
gold.dim_employees
gold.dim_materials
gold.dim_date
```

**Transformation:** `sql/transformation/transform_silver_to_gold.sql`

All transformations use `WHERE NOT EXISTS` for idempotent loading. Surrogate keys
(`_key` columns) are generated in the Gold layer and used in fact tables. Natural keys
(`_id` columns) are retained for traceability back to Silver.

---

## Power BI Dashboard

Connected to the Gold layer via Azure SQL in Import mode.

**Model:** Star schema with 11 relationships. Dimensions connect directly to facts.
Role-playing date dimension — `dim_date` serves multiple fact tables with inactive
relationships activated via `USERELATIONSHIP()` in DAX where needed.

**KPI Measures:**
- Total Jobs
- Jobs Completed
- Total Revenue (paid invoices)
- Outstanding Balance (issued but unpaid invoices)
- Total Material Cost
- Jobs by Employee
- Revenue by Client

**Pages:**
- **Job Performance** — total jobs, jobs by status, jobs by site, monthly trend
- **Revenue & Materials** — revenue by client, material cost by material, top jobs by cost

---

## Repository Structure

```
Pipeline Automation/
│
├── docs/
│   └── Scope 1.0.docx
│
├── sql/
│   ├── bronze/
│   │   └── bronze.raw_jobs.sql
│   │
│   ├── silver/
│   │   ├── silver.clients.sql
│   │   ├── silver.sites.sql
│   │   ├── silver.jobs.sql
│   │   ├── silver.employees.sql
│   │   ├── silver.materials.sql
│   │   ├── silver.material_usage.sql
│   │   ├── silver.work_log.sql
│   │   ├── silver.invoices.sql
│   │   ├── silver.invoice_jobs.sql
│   │   └── silver.payments.sql
│   │
│   ├── gold/
│   │   ├── gold.dim_clients.sql
│   │   ├── gold.dim_sites.sql
│   │   ├── gold.dim_employees.sql
│   │   ├── gold.dim_materials.sql
│   │   ├── gold.dim_date.sql
│   │   ├── gold.fact_jobs.sql
│   │   ├── gold.fact_work_log.sql
│   │   ├── gold.fact_material_usage.sql
│   │   ├── gold.fact_invoices.sql
│   │   └── gold.fact_payments.sql
│   │
│   ├── transformation/
│   │   ├── transform_bronze_to_silver.sql
│   │   └── transform_silver_to_gold.sql
│   │
│   ├── validation/
│   │   └── validate_silver_integrity.sql
│   │
│   ├── scripts/
│   │   └── generate_bronze_seed.py
│   │
│   └── seed/
│       └── seed_bronze_raw_jobs.sql
│
├── powerbi/
│   └── mastic_pipeline.pbix
│
└── README.md
```

---

## Running the Pipeline

### 1. Generate seed data
```bash
python sql/scripts/generate_bronze_seed.py
```
Generates realistic mastic business data and writes to `sql/seed/seed_bronze_raw_jobs.sql`.

### 2. Load Bronze
Execute `sql/seed/seed_bronze_raw_jobs.sql` against your Azure SQL database.

### 3. Transform Bronze → Silver
Execute `sql/transformation/transform_bronze_to_silver.sql`.
Idempotent — safe to re-run.

### 4. Validate Silver
Execute `sql/validation/validate_silver_integrity.sql`.
Checks row counts, duplicates, and orphan foreign keys.

### 5. Transform Silver → Gold
Execute `sql/transformation/transform_silver_to_gold.sql`.
Populates all dimension and fact tables in order. Idempotent — safe to re-run.

### 6. Refresh Power BI
Open `powerbi/mastic_pipeline.pbix` in Power BI Desktop and refresh the dataset.

---

## Key Engineering Decisions

**Idempotent transformations** — all SQL transformation scripts use `WHERE NOT EXISTS`
matching on natural keys. Re-running any script produces the same result as running it
once. No duplicate records are created.

**Surrogate keys in Gold** — fact tables reference surrogate keys (`_key`) from
dimension tables, not natural keys from Silver. This decouples the analytical model
from source system IDs and enables Slowly Changing Dimensions in future.

**Flat star schema in Power BI** — dimensions connect only to fact tables, never to
each other. This prevents ambiguous filter paths and cyclic reference errors. Client
context on dim_sites is accessed through fact tables rather than a
dimension-to-dimension relationship.

**Role-playing date dimension** — `dim_date` serves multiple fact tables.
The `fact_jobs (start_date_key)` relationship is active. All other date relationships
are inactive and activated with `USERELATIONSHIP()` in DAX when needed.

---

## Skills Demonstrated

- Medallion architecture (Bronze / Silver / Gold)
- SQL Server schema design and normalisation
- Idempotent ETL transformation patterns
- Surrogate key design and natural key traceability
- Dimensional modelling — star schema, fact and dimension tables
- Data quality validation — referential integrity, duplicate detection
- Power BI data modelling — star schema, role-playing dimensions
- DAX measures — CALCULATE, SUMX, DISTINCTCOUNT
- Azure SQL Database — schema design, firewall, connection management
- Python — synthetic data generation with realistic business domain
- Git — incremental commits reflecting genuine iterative development

## Planned

- Python ingestion layer (`ingest_to_bronze.py`) — reads from CSV, validates, loads to Bronze
- Streamlit form application — data entry interface replacing the seed generator
- Additional KPIs — average job duration, margin percentage, payment lag analysis
