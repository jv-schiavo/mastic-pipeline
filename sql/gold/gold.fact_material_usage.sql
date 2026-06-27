IF NOT EXISTS (SELECT 1
               FROM sys.tables
               WHERE name = 'fact_material_usage'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.fact_material_usage (
        material_usage_key INT IDENTITY(1,1),
        material_usage_id INT,
        material_key INT NOT NULL,
        job_key INT NOT NULL,
        quantity DECIMAL(10,2) NOT NULL,
        unit_cost_at_time DECIMAL(10,2),

        CONSTRAINT PK_materialusage_fact
        PRIMARY KEY (material_usage_key),
        CONSTRAINT FK_materialusage_materials
            FOREIGN KEY (material_key)
            REFERENCES gold.dim_materials(material_key),
        CONSTRAINT FK_materialusage_jobs
            FOREIGN KEY (job_key)
            REFERENCES gold.fact_jobs       
    )
END;