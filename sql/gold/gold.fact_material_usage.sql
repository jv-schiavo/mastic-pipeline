IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_material_usage'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_material_usage (
        material_usage_key INT IDENTITY(1,1),
        material_usage_id INT,
        material_id INT NOT NULL,
        job_id INT NOT NULL,
        quantity DECIMAL(10,2) NOT NULL,
        unit_cost_at_time DECIMAL(10,2)
    )
END;