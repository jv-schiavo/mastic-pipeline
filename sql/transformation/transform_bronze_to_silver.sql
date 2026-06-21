-- 1. Load clients
INSERT INTO silver.clients (
    client_name,
    email,
    address,
    phone
)
SELECT DISTINCT
    LTRIM(RTRIM(client_name)),
    LTRIM(RTRIM(client_email)),
    LTRIM(RTRIM(client_address)),
    LTRIM(RTRIM(client_phone))
FROM bronze.raw_jobs r
WHERE client_name IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.clients c
    WHERE c.client_name = LTRIM(RTRIM(r.client_name))
);

/*
Look at bronze.raw_jobs
Find all client names, emails, address and phone
Clean spaces
Remove duplicates
Ignore NULLs
Insert only new clients into silver.clients
*/


-- 2. Load sites
INSERT INTO silver.sites (
    client_id,
    location,
    status
)
SELECT DISTINCT
    c.client_id,
    LTRIM(RTRIM(r.site_location)),
    LTRIM(RTRIM(r.site_status))
FROM bronze.raw_jobs r
JOIN silver.clients c
ON c.client_name = LTRIM(RTRIM(r.client_name))
WHERE r.site_location IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.sites s
    WHERE s.client_id = c.client_id
     AND s.location = LTRIM(RTRIM(r.site_location))
);

/*
Look at bronze.raw_jobs
JOIN with silver.clients to retrieve client_id
Find client_id
Find all locations
Clean spaces
Remove duplicates
Give status = 'active'
Ignore NULLS
Insert only new sites
*/

-- 3. Load jobs

INSERT INTO silver.jobs (
    site_id,
    job_description,
    start_date,
    end_date,
    status
)
SELECT DISTINCT
    s.site_id,
    LTRIM(RTRIM(r.job_description)),
    r.start_date,
    r.end_date,
    LTRIM(RTRIM(r.job_status))
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.site_location))
WHERE r.job_description IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.jobs j
    WHERE j.site_id = s.site_id
    AND j.job_description = LTRIM(RTRIM(r.job_description))
    AND j.start_date = r.start_date
);


-- 4. Load employees
INSERT INTO silver.employees (
    worker_name,
    email,
    phone,
    dob
)
SELECT DISTINCT
    LTRIM(RTRIM(r.worker_name)),
    LTRIM(RTRIM(r.worker_email)),
    LTRIM(RTRIM(r.worker_phone)),
    r.worker_dob
FROM bronze.raw_jobs r
WHERE r.worker_name IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.employees e
    WHERE e.worker_name = LTRIM(RTRIM(r.worker_name))
);


-- 5. Load work log
INSERT INTO silver.work_log (
    worker_id,
    job_id,
    work_date,
    notes
)
SELECT DISTINCT
    e.worker_id,
    j.job_id,
    r.work_date,
    LTRIM(RTRIM(r.work_notes))
FROM bronze.raw_jobs r
JOIN silver.employees e
    ON e.worker_name = LTRIM(RTRIM(r.worker_name))
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.site_location))
JOIN silver.jobs j
    ON j.site_id = s.site_id
    AND j.job_description = LTRIM(RTRIM(r.job_description))
    AND j.start_date = r.start_date
WHERE r.worker_name IS NOT NULL
AND r.work_date IS NOT NULL
AND r.job_description IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.work_log wl
    WHERE wl.worker_id = e.worker_id
    AND wl.job_id = j.job_id
    AND wl.work_date = r.work_date
);



-- 6. Load materials
INSERT INTO silver.materials (
    material_name,
    material_manufacturer,
    unit,
    unit_cost
)
SELECT DISTINCT
    LTRIM(RTRIM(r.material_name)),
    LTRIM(RTRIM(r.material_manufacturer)),
    LTRIM(RTRIM(r.material_unit)),
    r.material_unit_cost
FROM bronze.raw_jobs r
WHERE r.material_name IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.materials m
    WHERE m.material_name = LTRIM(RTRIM(r.material_name))
    AND ISNULL(m.material_manufacturer, '') = ISNULL(LTRIM(RTRIM(r.material_manufacturer)), '')
);

-- 7. Load material usage
INSERT INTO silver.material_usage (
    material_id,
    job_id,
    quantity,
    unit_cost_at_time
)
SELECT DISTINCT
    m.material_id,
    j.job_id,
    r.quantity_used,
    r.unit_cost_at_time
FROM bronze.raw_jobs r
JOIN silver.materials m
    ON m.material_name = LTRIM(RTRIM(r.material_name))
    AND ISNULL(m.material_manufacturer, '') = ISNULL(LTRIM(RTRIM(r.material_manufacturer)), '')
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.site_location))
JOIN silver.jobs j
    ON j.site_id = s.site_id
    AND j.job_description = LTRIM(RTRIM(r.job_description))
    AND j.start_date = r.start_date
WHERE r.material_name IS NOT NULL
AND r.quantity_used IS NOT NULL
AND r.job_description IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.material_usage mu
    WHERE mu.material_id = m.material_id
    AND mu.job_id = j.job_id
);


-- 8. Load invoices
INSERT INTO silver.invoices (
    client_id,
    invoice_date,
    total_amount,
    status
)
SELECT DISTINCT
    c.client_id,
    r.invoice_date,
    r.invoice_total_amount,
    LTRIM(RTRIM(r.invoice_status))
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
WHERE r.invoice_date IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.invoices i
    WHERE i.client_id = c.client_id
    AND i.invoice_date = r.invoice_date
    AND ISNULL(i.total_amount, 0) = ISNULL(r.invoice_total_amount, 0)
);

-- 9. Load invoice jobs
INSERT INTO silver.invoice_jobs (
    invoice_id,
    job_id,
    amount
)
SELECT DISTINCT
    i.invoice_id,
    j.job_id,
    r.invoice_job_amount
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.invoices i
    ON i.client_id = c.client_id
    AND i.invoice_date = r.invoice_date
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.site_location))
JOIN silver.jobs j
    ON j.site_id = s.site_id
    AND j.job_description = LTRIM(RTRIM(r.job_description))
    AND j.start_date = r.start_date
WHERE r.invoice_date IS NOT NULL
AND r.job_description IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.invoice_jobs ij
    WHERE ij.invoice_id = i.invoice_id
    AND ij.job_id = j.job_id
);

-- 10. Load payments
INSERT INTO silver.payments (
    invoice_id,
    payment_date,
    amount,
    method,
    reference
)
SELECT DISTINCT
    i.invoice_id,
    r.payment_date,
    r.payment_amount,
    LTRIM(RTRIM(r.payment_method)),
    LTRIM(RTRIM(r.payment_reference))
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.invoices i
    ON i.client_id = c.client_id
    AND i.invoice_date = r.invoice_date
WHERE r.payment_amount IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.payments p
    WHERE p.invoice_id = i.invoice_id
    AND ISNULL(p.reference, '') = ISNULL(LTRIM(RTRIM(r.payment_reference)), '')
);