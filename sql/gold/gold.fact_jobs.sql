IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_jobs'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_jobs (
        job_key INT IDENTITY(1,1) NOT NULL,
        job_id INT NOT NULL,
        site_key INT NOT NULL,
        job_description VARCHAR(500),
        start_date_key INT NOT NULL,
        end_date_key INT,
        status VARCHAR(50),

        CONSTRAINT PK_fact_jobs
        PRIMARY KEY (job_key),
        CONSTRAINT FK_job_sites
            FOREIGN KEY (site_key)
            REFERENCES gold.dim_sites(site_key),
        CONSTRAINT FK_factjobs_startdate
            FOREIGN KEY (start_date_key)
            REFERENCES gold.dim_date(date_key),
        CONSTRAINT FK_factjobs_enddate
            FOREIGN KEY (end_date_key)
            REFERENCES gold.dim_date(date_key)
        
    );

END;