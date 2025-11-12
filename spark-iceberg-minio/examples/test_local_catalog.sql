-- Create Iceberg table with sales data
CREATE TABLE IF NOT EXISTS spark_catalog.default.sales_daily (
    sale_id INT,
    sale_date DATE,
    product STRING,
    amount DOUBLE
)
USING iceberg
PARTITIONED BY (sale_date);

-- Insert test data
INSERT INTO spark_catalog.default.sales_daily VALUES (1, CAST('2025-01-01' AS DATE), 'Chair', 100.50);
INSERT INTO spark_catalog.default.sales_daily VALUES (2, CAST('2025-01-01' AS DATE), 'Table', 250.75);
INSERT INTO spark_catalog.default.sales_daily VALUES (3, CAST('2025-01-02' AS DATE), 'Bed Frame', 175.25);
INSERT INTO spark_catalog.default.sales_daily VALUES (4, CAST('2025-01-02' AS DATE), 'Chest', 50.00);

-- Query the table
SELECT * FROM spark_catalog.default.sales_daily;

-- Show table info
SHOW TABLES;

-- Describe table structure
DESCRIBE FORMATTED spark_catalog.default.sales_daily;
