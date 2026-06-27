IF NOT EXISTS  (SELECT 1
               FROM sys.tables
               WHERE name = 'dim_date'
               AND schema_id = SCHEMA_ID('gold'))
BEGIN
    CREATE TABLE gold.dim_date (
        date_key INT IDENTITY(1,1),
        full_date DATE NOT NULL,
        day TINYINT NOT NULL,
        day_name VARCHAR(10) NOT NULL,
        day_of_wekk TINYINT NOT NULL,
        day_of_year SMALLINT NOT NULL,
        week_number TINYINT NOT NULL,
        month_number TINYINT NOT NULL,
        month_name VARCHAR(10) NOT NULL,
        quarter CHAR(2) NOT NULL,
        year SMALLINT NOT NULL,
        year_month CHAR(6) NOT NULL,
        month_year VARCHAR NOT NULL,
        is_weekend BIT NOT NULL
);

END;