-- Create a Slowly Changing Dimension Type 2 (SCD2) table for employee data
-- This table tracks historical changes to employee roles over time
CREATE TABLE s3_catalog.default.employee_dim (
  emp_id INT,
  emp_name STRING,
  role STRING,
  effective_start_date DATE,
  effective_end_date DATE,
  is_current BOOLEAN
)
USING iceberg
TBLPROPERTIES (
  'format-version'='2',
  'write.delete.mode'='merge-on-read',
  'write.update.mode'='merge-on-read'
);

-- Insert initial employee records into the SCD2 table
INSERT INTO s3_catalog.default.employee_dim VALUES
  (1, 'Alice', 'Engineer', DATE('2023-01-01'), DATE('9999-12-31'), TRUE),
  (2, 'Bob', 'Analyst', DATE('2023-02-01'), DATE('9999-12-31'), TRUE),
  (3, 'Charlie', 'Manager', DATE('2023-03-01'), DATE('9999-12-31'), TRUE);

-- Query the employee_dim table to verify initial inserts
SELECT * FROM s3_catalog.default.employee_dim;

-- Update Alice's role from 'Engineer' to 'Senior Engineer' effective from 2024-04-02
-- This involves closing the current record and inserting a new record
MERGE INTO s3_catalog.default.employee_dim t
USING (
SELECT 1 AS emp_id, 'Alice' AS emp_name, 'Senior Engineer' AS role,
        DATE('2024-04-02') AS effective_start_date,
        DATE('9999-12-31') AS effective_end_date,
        TRUE AS is_current
) s
ON t.emp_id = s.emp_id AND t.is_current = TRUE

WHEN MATCHED THEN
UPDATE SET
    t.effective_end_date = s.effective_start_date - INTERVAL 1 DAY,
    t.is_current = FALSE

WHEN NOT MATCHED THEN
INSERT (emp_id, emp_name, role, effective_start_date, effective_end_date,
is_current)
VALUES (s.emp_id, s.emp_name, s.role, s.effective_start_date,
s.effective_end_date, s.is_current);

-- Insert the new record for Alice with the updated role
INSERT INTO s3_catalog.default.employee_dim
  VALUES (1, 'Alice', 'Senior Engineer', DATE('2024-04-02'), DATE('9999-12-31'),
  TRUE);

-- Query the employee_dim table to verify the SCD2 update for Alice
SELECT * FROM s3_catalog.default.employee_dim
ORDER BY emp_id, effective_start_date;

-- -- Clean up: Drop the employee_dim table
-- DROP TABLE s3_catalog.default.employee_dim PURGE;
