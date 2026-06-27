CREATE TABLE silver.clients (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(50)
);