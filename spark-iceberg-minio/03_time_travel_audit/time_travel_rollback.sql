-- -- 1. Create Monthly Revenue Table
-- CREATE TABLE s3_catalog.default.monthly_revenue (
--     month STRING,
--     revenue BIGINT
-- )
-- USING iceberg;

-- -- 2. Insert Data for Jan–Mar
-- INSERT INTO s3_catalog.default.monthly_revenue VALUES
-- ('2023-01', 100000),
-- ('2023-02', 120000),
-- ('2023-03', 110000);


-- -- Check Data
-- SELECT * FROM s3_catalog.default.monthly_revenue ORDER BY month;

-- -- 3. Simulate March Adjustment (correction)
-- -- Example: Revenue updated from 110000 → 115000
-- UPDATE s3_catalog.default.monthly_revenue
-- SET revenue = 115000
-- WHERE month = '2023-03';

-- -- 4. List Snapshots
-- SELECT * FROM s3_catalog.default.monthly_revenue.snapshots;

-- -- 5. Time-Travel Query
-- -- Option A — Query using snapshot_id
-- SELECT * FROM s3_catalog.default.monthly_revenue VERSION AS OF 8030722148209020319;

-- -- Option B — Query using timestamp
-- SELECT * FROM s3_catalog.default.monthly_revenue
--     TIMESTAMP AS OF TIMESTAMP '2025-11-14 03:42:31.849';


-- -- 6. Rollback to February Version
-- ALTER TABLE s3_catalog.default.monthly_revenue
-- SET TBLPROPERTIES (
--   'current-snapshot-id' = '8030722148209020319'
-- );

-- -- Check Data after Rollback
-- SELECT * FROM s3_catalog.default.monthly_revenue ORDER BY month;
-- SELECT * FROM s3_catalog.default.monthly_revenue.snapshots;

-- -- 7. Configure Snapshot Retention Policies
-- ALTER TABLE s3_catalog.default.monthly_revenue
-- SET TBLPROPERTIES (
--     -- Max age of snapshots before they become eligible for removal (3 days)
--     'history.expire.max-snapshot-age-ms' = '259200000',
--
--     -- Keep at least 3 snapshots at all times
--     'history.expire.min-snapshots-to-keep' = '3'
-- );

-- -- View properties to confirm
-- SHOW TBLPROPERTIES s3_catalog.default.monthly_revenue;