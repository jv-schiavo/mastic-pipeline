IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'dim_sites'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_sites (
        site_key INT IDENTITY(1,1) NOT NULL,
        site_id INT NOT NULL,
        client_key INT NOT NULL,
        location VARCHAR(255) NOT NULL,
        status VARCHAR(50)

        CONSTRAINT PK_dim_sites
            PRIMARY KEY (site_key),
        CONSTRAINT FK_dimsites_client
            FOREIGN KEY (client_key) REFERENCES gold.dim_clients(client_key)
    );

END;
