# Spark + Iceberg + MinIO Learning Platform

A Docker-based learning platform for Apache Iceberg with Spark and MinIO S3 storage. Includes practical scenarios covering basic lake tables, SCD Type 2, and time travel auditing.

## Architecture

```
┌──────────────────┐
│  Spark + Iceberg │
│  (Local catalog) │
└────────┬─────────┘
         │
         ├─► /home/iceberg/warehouse (Local storage)
         │
         └─► s3a://warehouse (MinIO S3)
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

## Learning Scenarios

### 01 - Basic Lake Table
Learn the fundamentals of Apache Iceberg with simple table operations.

**Files:**
- `01_basic_lake_table/test_local_catalog.sql` - Create and query tables using local storage
- `01_basic_lake_table/test_s3_catalog.sql` - Create and query tables using MinIO S3
- `01_basic_lake_table/query_iceberg_metadata.py` - Inspect table metadata, snapshots, and files

**Run Local Catalog Test:**
```bash
docker cp 01_basic_lake_table/test_local_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_local_catalog.sql
```

**Run S3 Catalog Test:**
```bash
docker cp 01_basic_lake_table/test_s3_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_s3_catalog.sql
```

**Query Table Metadata:**
```bash
docker cp 01_basic_lake_table/query_iceberg_metadata.py iceberg-spark:/tmp/
docker exec iceberg-spark python3 /tmp/query_iceberg_metadata.py
```

### 02 - SCD Type 2 (Slowly Changing Dimensions)
Implement slowly changing dimensions using Iceberg's versioning capabilities.

**Files:**
- `02_scd_type2/scd2_basics.sql` - SCD Type 2 implementation with effective/end dates

**Run SCD2 Examples:**
```bash
docker cp 02_scd_type2/scd2_basics.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/scd2_basics.sql
```

### 03 - Time Travel & Audit
Explore Iceberg's time travel capabilities for data auditing and historical analysis.

**Files:**
- `03_time_travel_audit/` - Scenario for time travel queries and audit trails (in development)

**Status:** Coming soon

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

## Project Structure

```
.
├── Dockerfile                           # Custom image with Spark + Iceberg
├── docker-compose.yml                   # Service definitions
├── spark-defaults.conf.template         # Spark & Iceberg configuration template
├── .env                                 # Environment variables (single source of truth)
├── 01_basic_lake_table/                 # Basic Iceberg operations
│   ├── test_local_catalog.sql          # Local storage example
│   ├── test_s3_catalog.sql             # MinIO S3 example
│   └── query_iceberg_metadata.py       # Inspect table metadata
├── 02_scd_type2/                        # SCD Type 2 implementation
│   └── scd2_basics.sql                 # Slowly changing dimensions example
└── 03_time_travel_audit/                # Time travel & audit (in development)
```

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

## Running the Scenarios

See the **Learning Scenarios** section above for specific instructions for each scenario.

### Quick Test All Scenarios
```bash
# Start services
docker-compose up -d

# Run basic lake table tests
docker cp 01_basic_lake_table/test_local_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_local_catalog.sql

# Run S3 catalog test
docker cp 01_basic_lake_table/test_s3_catalog.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/test_s3_catalog.sql

# Query metadata
docker cp 01_basic_lake_table/query_iceberg_metadata.py iceberg-spark:/tmp/
docker exec iceberg-spark python3 /tmp/query_iceberg_metadata.py

# Run SCD Type 2 example
docker cp 02_scd_type2/scd2_basics.sql iceberg-spark:/tmp/
docker exec iceberg-spark spark-sql -f /tmp/scd2_basics.sql
```

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

## Learning Path

1. **Start with Scenario 01** - Understand basic Iceberg table creation, writes, and queries
2. **Explore metadata** - Use the metadata inspection script to understand snapshots and versioning
3. **Learn SCD Type 2** - See how Scenario 02 implements slowly changing dimensions
4. **Prepare for Scenario 03** - Understand time travel concepts before the time travel scenario

## Next Steps & Advanced Topics

- Experiment with schema evolution (ALTER TABLE ADD COLUMN)
- Implement custom partitioning strategies
- Build Spark jobs for batch processing with Iceberg
- Add Iceberg REST catalog for production deployments
- Set up data quality checks with Iceberg metadata
- Monitor tables in MinIO console: http://localhost:9001 (minioadmin/minioadmin123)
