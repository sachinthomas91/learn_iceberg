# Spark + Iceberg + MinIO Setup

A simplified Docker setup for learning Apache Iceberg with Spark and MinIO S3 storage.

## Architecture

```
┌──────────────────┐
│  Spark + Iceberg │
│  (Local catalog) │
└────────┬─────────┘
         │
         ├─► /home/iceberg/warehouse (Default local storage)
         │
         └─► s3a://warehouse (MinIO S3 - configured but optional)
                    ↓
            ┌───────────────┐
            │    MinIO      │
            │ (S3-compatible)
            └───────────────┘
```

## Quick Start

### Start Services
```bash
docker-compose up -d
```

This starts:
- **Spark** - With Iceberg + S3A support
- **MinIO** - S3-compatible object storage (http://localhost:9000)
- **MinIO Console** - Web UI (http://localhost:9001)
- **mc (MinIO Client)** - Creates the warehouse bucket on startup

### Connect to Spark SQL
```bash
docker exec -it iceberg-spark spark-sql
```

### Create Iceberg Table (Local Storage)
```sql
CREATE TABLE spark_catalog.default.sales_daily (
    sale_id INT,
    sale_date DATE,
    product STRING,
    amount DOUBLE
)
USING iceberg
PARTITIONED BY (sale_date);

INSERT INTO spark_catalog.default.sales_daily VALUES
(1, DATE '2025-11-08', 'Apple', 100.0),
(2, DATE '2025-11-08', 'Banana', 50.0);

SELECT * FROM spark_catalog.default.sales_daily;
```

Table data is stored in `/home/iceberg/warehouse` (local container filesystem).

### Create Iceberg Table in MinIO S3
```sql
CREATE TABLE s3_catalog.default.sales_daily (
    sale_id INT,
    sale_date DATE,
    product STRING,
    amount DOUBLE
)
USING iceberg
PARTITIONED BY (sale_date);

INSERT INTO s3_catalog.default.sales_daily VALUES
(1, DATE '2025-11-08', 'Apple', 100.0),
(2, DATE '2025-11-08', 'Banana', 50.0);

SELECT * FROM s3_catalog.default.sales_daily;
```

Table data is stored in `s3a://warehouse` (MinIO S3 bucket) at `http://localhost:9000`.

## Catalogs

### `spark_catalog` (Default - Local Storage)
- **Type**: Hadoop
- **Warehouse**: `/home/iceberg/warehouse`
- **Best for**: Learning, development, testing
- **Data location**: Local container filesystem

### `s3_catalog` (MinIO S3) ✅ Working
- **Type**: Hadoop with S3FileIO
- **Warehouse**: `s3a://warehouse`
- **Endpoint**: MinIO at `http://minio:9000`
- **Best for**: Production-like scenarios
- **Status**: Fully configured and tested

## Files

| File | Purpose |
|------|---------|
| `Dockerfile` | Custom image with Spark + Iceberg + entrypoint for config generation |
| `docker-compose.yml` | Service definitions |
| `spark-defaults.conf.template` | Spark & Iceberg configuration template with variable placeholders |
| `.env` | Environment variables (credentials, ports) - **single source of truth** |
| `examples/test_local_catalog.sql` | Test script for local catalog |
| `examples/test_s3_catalog.sql` | Test script for S3 catalog |
| `examples/query_iceberg_metadata.py` | Python script to view table metadata (snapshots, files, history) |

## Configuration Details

### spark-defaults.conf.template

This is a **template file** with variable placeholders that are substituted at container startup:

```properties
# Values substituted from .env at runtime
spark.sql.catalog.s3_catalog.s3.access-key-id ${MINIO_ACCESS_KEY}
spark.sql.catalog.s3_catalog.s3.secret-access-key ${MINIO_SECRET_KEY}
spark.sql.catalog.s3_catalog.s3.endpoint ${AWS_S3_ENDPOINT}

spark.hadoop.fs.s3a.access.key ${MINIO_ACCESS_KEY}
spark.hadoop.fs.s3a.secret.key ${MINIO_SECRET_KEY}
spark.hadoop.fs.s3a.endpoint ${AWS_S3_ENDPOINT}
```

**How it works:**
1. `.env` file contains all credentials and configuration values
2. `docker-compose.yml` passes `.env` variables to the Spark container
3. Dockerfile creates `/entrypoint.sh` that uses `envsubst` to substitute variables
4. Container startup generates final `spark-defaults.conf` from the template

**Benefit:**
- Secrets are only in `.env` (which is gitignored)
- No hardcoded credentials in config files
- Easy to change credentials by updating `.env`
- Single source of truth for all configuration

## MinIO Browser

Access the MinIO console at **http://localhost:9001**
- Username: `minioadmin`
- Password: `minioadmin123`
- Bucket: `warehouse` (auto-created)

## Simplifications Made

This setup removes the original complexity:

❌ **Removed:**
- Dynamic configuration in `entrypoint.sh`
- Unused `spark-startup.sh`
- Duplicate config sources
- Runtime environment variable overrides

✅ **Simplified:**
- Single `spark-defaults.conf` = single source of truth
- Custom Dockerfile embeds config at build time
- Cleaner docker-compose.yml
- All configuration in one place

## Testing

### Test Local Catalog
```bash
docker cp examples/test_local_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_local_catalog.sql
```

Expected output:
- Table created with 4 rows
- Partitioned by `sale_date`
- Location: `/home/iceberg/warehouse/default/sales_daily`
- Format: Iceberg/Parquet (format-version=2)

### Test S3 Catalog
```bash
docker cp examples/test_s3_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_s3_catalog.sql
```

Expected output:
- Table created in MinIO S3
- Location: `s3a://warehouse/default/sales_daily`
- Data accessible at `http://localhost:9000/warehouse`

### View Table Metadata (Snapshots, Files, History)
```bash
docker cp examples/query_iceberg_metadata.py iceberg-spark:/tmp/
docker exec iceberg-spark python3 /tmp/query_iceberg_metadata.py
```

This displays:
- **TABLE DATA** - Current table records
- **SNAPSHOTS** - All versions/commits of the table
- **HISTORY** - Timeline of snapshot changes
- **FILES** - Physical parquet files stored in S3
- **MANIFESTS** - Metadata index files
- **SCHEMA** - Table structure and partitions

## Troubleshooting

### mc container exits immediately
✅ This is expected - it's a one-time setup container that creates the bucket and exits

### Spark pod won't start
Check logs: `docker logs iceberg-spark`

### Can't access MinIO
- Ensure MinIO is healthy: `docker ps` (should show healthy)
- Check credentials in `.env`

## Key Implementation Details

### S3FileIO Configuration
The `s3_catalog` uses Iceberg's S3FileIO with AWS SDK v2. Key settings in `spark-defaults.conf`:

```properties
# Catalog definition
spark.sql.catalog.s3_catalog.io-impl org.apache.iceberg.aws.s3.S3FileIO

# S3 credentials and endpoint
spark.sql.catalog.s3_catalog.s3.access-key-id minioadmin
spark.sql.catalog.s3_catalog.s3.secret-access-key minioadmin123
spark.sql.catalog.s3_catalog.s3.endpoint http://minio:9000
spark.sql.catalog.s3_catalog.s3.path-style-access true
```

**Critical**: AWS SDK v2 requires `AWS_REGION` environment variable to be set (configured in Dockerfile as `us-east-1`).

## Next Steps

- Use `s3_catalog` for multi-node deployments
- Add Iceberg REST catalog for production
- Implement table evolution (schema changes)
- Set up Spark jobs for batch processing
- Monitor tables in MinIO console: http://localhost:9001 (minioadmin/minioadmin123)
