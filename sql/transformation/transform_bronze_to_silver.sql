-- 1. Load clients

INSERT INTO silver.clients (client_name)
SELECT DISTINCT
    LTRIM(RTRIM(client_name)) AS client_name,
    NULL AS 
FROM bronze.raw_jobs r
WHERE client_name IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.clients c
    WHERE c.client_name = LTRIM(RTRIM(r.client_name))
);

/*
Look at bronze.raw_jobs
Find all client names
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
    LTRIM(RTRIM(location)) as location,
    'active' AS status
FROM bronze.raw_jobs r
JOIN silver.clients c
ON c.client_name = LTRIM(RTRIM(r.client_name))
WHERE r.location IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.sites s
    WHERE s.client_id = c.client_id
    AND s.site_name = LTRIM(RTRIM(r.location))
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


-- 3. Load employees

INSERT INTO silver.employees (employee_name)
SELECT DISTINCT
    LTRIM(RTRIM(operative_name)) as employee_name
FROM bronze.raw_jobs r
WHERE operative_name IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.employees e
    WHERE e.employee_name = LTRIM(RTRIM(r.operative_name))
)

/*
Look at bronze.raw_jobs
Find all operative names
Clean spaces
Remove duplicates
Ignore NULLs
Insert only new employees into silver.employees
*/


-- 4. Load materials

INSERT INTO silver.materials (
    material_name,
    material_manufacturer
)
SELECT DISTINCT
    LTRIM(RTRIM(material_name)) AS material_name,
    LTRIM(RTRIM(manufacturer)) AS material_manufacturer
FROM bronze.raw_jobs r
WHERE r.material_name IS NOT NULL
AND r.manufacturer IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.materials m
    WHERE m.material_name = LTRIM(RTRIM(r.material_name))
    AND m.material_manufacturer = LTRIM(RTRIM(r.manufacturer))
);

-- 5. Load jobs

INSERT INTO silver.jobs (
    site_id,
    job_title,
    job_description,
    start_date,
    end_date,
    status
)
SELECT DISTINCT
    s.site_id,
    CONCAT('Mastic job - ', LTRIM(RTRIM(r.location)), ' - ', CONVERT(VARCHAR(10), r.job_date, 120)) AS job_title,
    NULL AS job_description,
    r.job_date AS start_date,
    NULL AS end_date,
    LTRIM(RTRIM(r.job_status)) AS status
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.location))
WHERE r.location IS NOT NULL
AND r.job_date IS NOT NULL
AND r.job_status IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.jobs j
    WHERE j.site_id = s.site_id
    AND j.start_date = r.job_date
    AND j.status = LTRIM(RTRIM(r.job_status))
);


-- 6. Load employee assignments

INSERT INTO silver.employee_assignment (
    employee_id,
    job_id,
    assignment_date
)
SELECT DISTINCT
    e.employee_id,
    j.job_id,
    r.job_date
FROM bronze.raw_jobs r
JOIN silver.clients c
    ON c.client_name = LTRIM(RTRIM(r.client_name))
JOIN silver.sites s
    ON s.client_id = c.client_id
    AND s.location = LTRIM(RTRIM(r.location))
JOIN silver.jobs j
    ON j.site_id = s.site_id
    AND j.start_date = r.job_date
JOIN silver.employees e
    ON e.employee_name = LTRIM(RTRIM(r.operative_name))
WHERE r.operative_name IS NOT NULL
AND r.location IS NOT NULL
AND r.job_date IS NOT NULL
AND NOT EXISTS (
    SELECT 1
    FROM silver.employee_assignment ea
    WHERE ea.employee_id = e.employee_id
    AND ea.job_id = j.job_id
);

-- 7. Load material usage 




-- 8. Load work records



-- 9. Load invoices




-- 10. Load invoice jobs



-- 11. Load payments