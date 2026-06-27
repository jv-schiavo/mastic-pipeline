IF NOT EXISTS  (SELECT 1
               FROM sys.tables
               WHERE name = 'dim_materials'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_materials (
        material_key INT IDENTITY(1,1) NOT NULL,
        material_id INT NOT NULL,
        material_name VARCHAR(100) NOT NULL,
        material_manufacturer VARCHAR(100),
        unit VARCHAR(50),
        unit_cost DECIMAL(10,2)
);
END;
