IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_work_log'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_work_log (
        work_log_key INT IDENTITY (1,1),
        work_log_id INT NOT NULL,
        worker_id INT NOT NULL,
        job_id INT NOT NULL,
        work_date DATE NOT NULL,
        notes VARCHAR(500)
);

END;