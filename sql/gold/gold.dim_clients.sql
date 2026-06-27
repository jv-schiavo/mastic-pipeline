IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'dim_clients'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_clients (
    client_key INT IDENTITY(1,1) PRIMARY KEY,
    client_id INT NOT NULL,
    client_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(50)
);

END;