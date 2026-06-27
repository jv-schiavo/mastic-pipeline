IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_payments'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_payments (
        payment_key INT IDENTITY(1,1),
        payment_id INT NOT NULL,
        invoice_id INT NOT NULL,
        payment_date DATETIME,
        amount DECIMAL(10,2),
        method VARCHAR(50),
        reference VARCHAR(100)
);

END;