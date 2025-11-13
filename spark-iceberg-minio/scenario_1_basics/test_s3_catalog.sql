-- Use the pre-configured s3_catalog from spark-defaults.conf
-- This catalog is configured to use MinIO S3

-- Create table in S3 catalog
CREATE TABLE IF NOT EXISTS s3_catalog.default.sales_daily (
    sale_id INT,
    sale_date DATE,
    product STRING,
    amount DOUBLE
)
USING iceberg
PARTITIONED BY (sale_date);

-- Insert sample data
INSERT INTO s3_catalog.default.sales_daily VALUES
(1, DATE '2025-11-08', 'Apple', 100.0),
(2, DATE '2025-11-08', 'Banana', 50.0),
(3, DATE '2025-11-09', 'Cherry', 75.5),
(4, DATE '2025-11-09', 'Date', 120.0);

-- Query the table
SELECT * FROM s3_catalog.default.sales_daily ORDER BY sale_id;

-- Show table details
DESCRIBE FORMATTED s3_catalog.default.sales_daily;
