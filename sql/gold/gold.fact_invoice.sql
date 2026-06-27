IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_invoices'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_invoices (
        invoice_key INT IDENTITY (1,1),
        invoice_id INT NOT NULL,
        client_id INT NOT NULL,
        invoice_date DATETIME,
        total_amount DECIMAL(10,2),
        status VARCHAR(50)
);

END;