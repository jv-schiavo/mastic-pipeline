CREATE TABLE silver.work_log (
    work_log_id INT IDENTITY(1,1) PRIMARY KEY,
    worker_id INT NOT NULL,
    job_id INT NOT NULL,
    work_date DATE NOT NULL,
    notes VARCHAR(500),

    CONSTRAINT FK_worklog_workers
        FOREIGN KEY (worker_id)
        REFERENCES silver.employees(worker_id),

    CONSTRAINT FK_worklog_jobs
        FOREIGN KEY (job_id)
        REFERENCES silver.jobs(job_id)
);