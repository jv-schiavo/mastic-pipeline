IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_payments'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_payments (
        payment_key INT IDENTITY(1,1),
        payment_id INT NOT NULL,
        invoice_key INT NOT NULL,
        date_key INT NOT NULL,
        amount DECIMAL(10,2),
        method VARCHAR(50),
        reference VARCHAR(100),

        CONSTRAINT PK_payments_fact
        PRIMARY KEY (payment_key),
        CONSTRAINT FK_payment_invoice
        FOREIGN KEY (invoice_key) REFERENCES gold.fact_invoices(invoice_key),
        CONSTRAINT FK_payments_date
        FOREIGN KEY (date_key) REFERENCES gold.dim_date(date_key)
);

END;