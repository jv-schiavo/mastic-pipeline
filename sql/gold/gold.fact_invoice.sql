IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_invoices'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_invoices (
        invoice_key INT IDENTITY (1,1),
        invoice_id INT NOT NULL,
        client_key INT NOT NULL,
        job_key INT NOT NULL,
        date_key INT NOT NULL,
        total_amount DECIMAL(10,2),
        status VARCHAR(50),
        
        CONSTRAINT PK_fact_invoices
            PRIMARY KEY (invoice_key),
        CONSTRAINT FK_factinvoices_client
            FOREIGN KEY (client_key) REFERENCES gold.dim_clients(client_key),
         CONSTRAINT FK_factinvoices_job
            FOREIGN KEY (job_key)    REFERENCES gold.fact_jobs(job_key),
        CONSTRAINT FK_factinvoices_date
            FOREIGN KEY (date_key)   REFERENCES gold.dim_date(date_key)
    );
END;
