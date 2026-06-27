-- Basic row counts
SELECT COUNT(*) AS client_count FROM silver.clients;
SELECT COUNT(*) AS site_count FROM silver.sites;
SELECT COUNT(*) AS job_count FROM silver.jobs;
SELECT COUNT(*) AS employee_count FROM silver.employees;
SELECT COUNT(*) AS material_count FROM silver.materials;

-- Duplicate clients
SELECT client_name, COUNT(*)
FROM silver.clients
GROUP BY client_name
HAVING COUNT(*) > 1;

-- Duplicate employees
SELECT worker_name, COUNT(*)
FROM silver.employees
GROUP BY worker_name
HAVING COUNT(*) > 1;

-- Work logs with invalid employees
SELECT wl.*
FROM silver.work_log wl
LEFT JOIN silver.employees e
    ON wl.worker_id = e.worker_id
WHERE e.worker_id IS NULL;

-- Material usage with invalid jobs
SELECT mu.*
FROM silver.material_usage mu
LEFT JOIN silver.jobs j
    ON mu.job_id = j.job_id
WHERE j.job_id IS NULL;