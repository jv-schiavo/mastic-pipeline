IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'dim_employees'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_employees (
        employee_key INT IDENTITY(1,1) NOT NULL,
        worker_id INT NOT NULL,
        worker_name VARCHAR(100) NOT NULL,
        email VARCHAR(100),
        phone VARCHAR(50),
        dob DATE
);

END;