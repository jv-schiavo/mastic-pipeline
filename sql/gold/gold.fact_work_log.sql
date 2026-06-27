IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_work_log'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_work_log (
        work_log_key INT IDENTITY (1,1),
        work_log_id INT NOT NULL,
        employee_key INT NOT NULL,
        job_key INT NOT NULL,
        date_key INT NOT NULL,
        notes VARCHAR(500),

        CONSTRAINT PK_worklog_fact
        PRIMARY KEY (work_log_key),

        CONSTRAINT FK_worklog_employee
        FOREIGN KEY (employee_key) REFERENCES gold.dim_employees(employee_key),

        CONSTRAINT FK_worklog_job
        FOREIGN KEY (job_key) REFERENCES gold.fact_jobs(job_key),
        
        CONSTRAINT FK_worklog_date
        FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key) 
);

END;