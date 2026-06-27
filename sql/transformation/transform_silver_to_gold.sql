-- 1. dim_clients

INSERT INTO gold.dim_clients (
    client_id,
    client_name,
    email,
    address,
    phone
)
SELECT
    s.client_id,
    s.client_name,
    s.email,
    s.address,
    s.phone
FROM silver.clients s
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_clients g
    WHERE g.client_id = s.client_id
);

-- 2. dim_sites

INSERT INTO gold.dim_sites (
    site_id,
    client_key,
    location,
    status
) 
SELECT
    s.site_id,
    dc.client_key,
    s.location,
    s.status
FROM silver.sites s
JOIN gold.dim_clients dc
ON dc.client_id = s.client_id
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_sites g
    WHERE s.site_id = g.site_id
);

-- 3. dim_date

WITH date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS full_date
    UNION ALL
    SELECT DATEADD(DAY, 1, full_date)
    FROM date_series
    WHERE full_date < '2027-12-31'
)
INSERT INTO gold.dim_date (
    full_date,
    day,
    day_name,
    day_of_week,
    day_of_year,
    week_number,
    month_number,
    month_name,
    quarter,
    year,
    year_month,
    month_year,
    is_weekend
) 
SELECT 
    full_date, 
    DAY(full_date), -- day
    DATENAME(DAY, full_date), -- day name
    DATEPART(WEEKDAY, full_date), -- day of week
    DATEPART(DAYOFYEAR, full_date), -- day of year
    DATEPART(WEEK, full_date), -- week number
    MONTH(full_date), -- month
    DATENAME(MONTH, full_date), -- name of month
    DATEPART(QUARTER, full_date), -- quarter
    YEAR(full_date), -- year
    FORMAT(full_date, 'yyyy-MM'),  -- year_month → "2024-03"
    FORMAT(full_date, 'MM-yyyy'), -- month_year
    CASE WHEN DATENAME(WEEKDAY, full_date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END
FROM date_series
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_date g
    WHERE g.full_date = date_series.full_date
)
OPTION (MAXRECURSION 2000);

-- 4. dim_employees

INSERT INTO gold.dim_employees (
    worker_id,
    worker_name,
    email,
    phone,
    dob
)
SELECT 
    s.worker_id,
    s.worker_name,
    s.email,
    s.phone,
    s.dob
FROM silver.employees s
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_employees g
    WHERE g.worker_id = s.worker_id
);

-- 5. dim_materials 

INSERT INTO gold.dim_materials (
    material_id,
    material_name,
    material_manufacturer,
    unit,
    unit_cost
)
SELECT
    s.material_id,
    s.material_name,
    s.material_manufacturer,
    s.unit,
    s.unit_cost
FROM silver.materials s
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_materials g
    WHERE g.material_id = s.material_id
);

-- 6. fact_job

INSERT INTO gold.fact_jobs (
    job_id,
    site_key,
    job_description,
    start_date_key,
    end_date_key,
    status
)
SELECT
    s.job_id,
    ds.site_key,
    s.job_description,
    dd_start.date_key,
    dd_end.date_key,
    s.status
FROM silver.jobs s
JOIN gold.dim_sites ds
ON ds.site_id = s.site_id
JOIN gold.dim_date dd_start
ON dd_start.full_date = CAST(s.start_date AS DATE)
LEFT JOIN gold.dim_date dd_end
ON dd_end.full_date = CAST(s.end_date AS DATE)
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.fact_jobs g
    WHERE g.job_id = s.job_id
);

-- 7. fact_work_log

INSERT INTO gold.fact_work_log (
    work_log_id,
    employee_key,
    job_key,
    date_key,
    notes
)
SELECT
    s.work_log_id,
    ge.employee_key,
    gj.job_key,
    gd.date_key,
    s.notes
FROM silver.work_log s
JOIN gold.dim_employees ge
ON ge.worker_id = s.worker_id
JOIN gold.fact_jobs gj
ON gj.job_id = s.job_id
JOIN gold.dim_date gd
ON gd.full_date = CAST(s.work_date AS DATE)
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.fact_work_log g
    WHERE g.work_log_id = s.work_log_id
);

-- 8. fact_material_usage

INSERT INTO gold.fact_material_usage (
    material_usage_id,
    material_key,
    job_key,
    quantity,
    unit_cost_at_time
)
SELECT
    s.material_usage_id,
    gm.material_key,
    gj.job_key,
    s.quantity,
    s.unit_cost_at_time
FROM silver.material_usage s
JOIN gold.dim_materials gm
ON gm.material_id = s.material_id
JOIN gold.fact_jobs gj
ON gj.job_id = s.job_id
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.fact_material_usage g
    WHERE g.material_usage_id = s.material_usage_id
);

-- 9. fact_invoice

INSERT INTO gold.fact_invoices (
    invoice_id,
    client_key,
    job_key,
    date_key,
    total_amount,
    status
)
SELECT 
    s.invoice_id,
    gc.client_key,
    gj.job_key,
    CAST(FORMAT(s.invoice_date, 'yyyyMMdd') 
         AS INT),
    s.total_amount,
    s.status
FROM silver.invoices s
JOIN gold.dim_clients gc
    ON gc.client_id = s.client_id
JOIN silver.invoice_jobs ij
    ON ij.invoice_id = s.invoice_id 
JOIN gold.fact_jobs gj
    ON gj.job_id = ij.job_id
WHERE NOT EXISTS(
    SELECT 1
    FROM gold.fact_invoices g
    WHERE g.invoice_id = s.invoice_id
);

-- 10. fact_payments

INSERT INTO gold.fact_payments (
    payment_id,
    invoice_key,
    date_key,
    amount,
    method,
    reference
)
SELECT 
    s.payment_id,
    gi.invoice_key,
    gd.date_key,
    s.amount,
    s.method,
    s.reference
FROM silver.payments s
JOIN gold.fact_invoices gi
ON gi.invoice_id = s.invoice_id
JOIN gold.dim_date gd
ON gd.full_date = CAST(s.payment_date AS DATE)
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.fact_payments g
    WHERE g.payment_id = s.payment_id
)


-- SANITY CHECK

SELECT 'dim_clients'         AS tbl, COUNT(*) AS rows FROM gold.dim_clients
UNION ALL
SELECT 'dim_sites',                   COUNT(*)         FROM gold.dim_sites
UNION ALL
SELECT 'dim_employees',               COUNT(*)         FROM gold.dim_employees
UNION ALL
SELECT 'dim_materials',               COUNT(*)         FROM gold.dim_materials
UNION ALL
SELECT 'dim_date',                    COUNT(*)         FROM gold.dim_date
UNION ALL
SELECT 'fact_jobs',                   COUNT(*)         FROM gold.fact_jobs
UNION ALL
SELECT 'fact_work_log',               COUNT(*)         FROM gold.fact_work_log
UNION ALL
SELECT 'fact_material_usage',         COUNT(*)         FROM gold.fact_material_usage
UNION ALL
SELECT 'fact_invoices',               COUNT(*)         FROM gold.fact_invoices
UNION ALL
SELECT 'fact_payments',               COUNT(*)         FROM gold.fact_payments
ORDER BY tbl;