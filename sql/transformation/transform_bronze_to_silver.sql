-- 1. Load clients

INSERT INTO silver.clients (client_name)
SELECT DISTINCT
    LTRIM(RTRIM(client_name)) AS client_name
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




-- 5. Load jobs







-- 6. Load employee assignments





-- 7. Load material usage 




-- 8. Load work records



-- 9. Load invoices




-- 10. Load invoice jobs



-- 11. Load payments