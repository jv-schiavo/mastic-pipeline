IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_jobs'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_jobs (
        job_key INT IDENTITY(1,1) NOT NULL,
        job_id INT NOT NULL,
        job_description VARCHAR(500),
        start_date DATETIME,
        end_date DATETIME,
        status VARCHAR(50)
    );

END;