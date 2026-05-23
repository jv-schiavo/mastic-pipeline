# Mastic Data Pipeline & Power BI Project

## Project Overview

This project simulates an end-to-end data pipeline for a mastic/construction services business.

The goal is to move operational job data from a raw landing table into a clean, normalised database model, then later transform it into an analytics-ready gold layer for Power BI reporting.

## Business Context

The business currently relies on operational job records that may contain repeated, inconsistent, or unstructured information.

This project demonstrates how raw job data can be structured into a reliable data model for reporting and decision-making.

## Data Pipeline Architecture

```text
Bronze Layer → Silver Layer → Gold Layer → Power BI
```

### Bronze Layer

The bronze layer stores raw operational data as it is received from the source system.

Current table:

```text
bronze.raw_jobs
```

### Silver Layer

The silver layer contains cleaned and normalised business entities.

Current tables include:

```text
silver.clients
silver.sites
silver.jobs
silver.employees
silver.employee_assignment
silver.materials
silver.material_usage
silver.work_records
silver.invoices
silver.invoice_jobs
silver.payments
```

### Gold Layer

The gold layer will contain analytics-ready fact and dimension tables.

Planned examples:

```text
gold.fact_jobs
gold.fact_invoices
gold.dim_clients
gold.dim_sites
gold.dim_employees
gold.dim_materials
```

## Repository Structure

```text
mastic-pipeline/
│
├── docs/
│   └── scope.docx
│
├── sql/
│   ├── bronze/
│   │   └── bronze.raw_jobs.sql
│   │
│   └── silver/
│       ├── silver.clients.sql
│       ├── silver.sites.sql
│       ├── silver.jobs.sql
│       ├── silver.employees.sql
│       ├── silver.employee_assignment.sql
│       ├── silver.materials.sql
│       ├── silver.material_usage.sql
│       ├── silver.work_records.sql
│       ├── silver.invoices.sql
│       ├── silver.invoice_jobs.sql
│       └── silver.payments.sql
│
└── README.md
```

## Current Project Status

Completed:

- Designed the bronze raw data table
- Created the normalised silver layer
- Created SQL scripts for bronze and silver tables
- Removed unnecessary reference layer to keep the model clean

In progress:

- Creating sample data
- Building the transformation logic from bronze to silver

Planned:

- Create the gold star schema
- Build Power BI dashboards
- Add pipeline automation
- Document business rules and assumptions

## Key Skills Demonstrated

- SQL Server database design
- Data modelling
- Normalisation
- Bronze/Silver/Gold architecture
- OLTP to OLAP thinking
- Portfolio-level documentation
- Power BI preparation

## Next Steps

1. Generate sample operational data
2. Load data into `bronze.raw_jobs`
3. Transform bronze data into silver tables
4. Create gold fact and dimension tables
5. Connect Power BI to the gold layer
6. Build reporting dashboards

## Project Goal

The final goal is to demonstrate a practical data engineering and analytics workflow:

```text
Raw business data → Clean relational model → Analytics model → Business dashboard
```
