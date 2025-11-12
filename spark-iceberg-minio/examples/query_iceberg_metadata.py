#!/usr/bin/env python3
"""
Query Iceberg table metadata and display in a readable format.
Run from Spark container or with PySpark installed.

Usage:
  docker exec iceberg-spark python3 /path/to/query_iceberg_metadata.py

Or run locally with:
  pyspark --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.6.0
"""

from pyspark.sql import SparkSession
import pandas as pd

# Initialize Spark Session with Iceberg support
spark = SparkSession.builder \
    .appName("iceberg-metadata-viewer") \
    .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
    .config("spark.sql.catalog.s3_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.s3_catalog.type", "hadoop") \
    .config("spark.sql.catalog.s3_catalog.warehouse", "s3a://warehouse") \
    .config("spark.sql.catalog.s3_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minioadmin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minioadmin123") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.aws.region", "us-east-1") \
    .getOrCreate()

# Suppress verbose logging
spark.sparkContext.setLogLevel("WARN")

def display_table(title, df):
    """Display a DataFrame in a readable format."""
    print(f"\n{'='*80}")
    print(f"  {title}")
    print(f"{'='*80}\n")

    # Convert to Pandas for better display
    pandas_df = df.toPandas()

    if pandas_df.empty:
        print("  (No data)")
    else:
        # Display with nice formatting
        pd.set_option('display.max_columns', None)
        pd.set_option('display.max_rows', None)
        pd.set_option('display.width', None)
        pd.set_option('display.max_colwidth', None)
        print(pandas_df.to_string(index=False))
        print(f"\n  Total rows: {len(pandas_df)}")

def main():
    """Query and display Iceberg metadata."""

    table_name = "s3_catalog.default.sales_daily"

    print("\n" + "="*80)
    print(f"  Iceberg Table Metadata Viewer")
    print(f"  Table: {table_name}")
    print("="*80)

    try:
        # 1. Table Contents
        df_data = spark.sql(f"SELECT * FROM {table_name} ORDER BY sale_id")
        display_table("TABLE DATA", df_data)

        # 2. Snapshots
        df_snapshots = spark.sql(f"SELECT * FROM {table_name}.snapshots")
        display_table("SNAPSHOTS (Versions)", df_snapshots)

        # 3. History
        df_history = spark.sql(f"SELECT * FROM {table_name}.history")
        display_table("HISTORY (Timeline)", df_history)

        # 4. Files
        df_files = spark.sql(f"SELECT * FROM {table_name}.files")
        display_table("FILES (Physical Data Files)", df_files)

        # 5. Manifests
        df_manifests = spark.sql(f"SELECT * FROM {table_name}.manifests")
        display_table("MANIFESTS (Metadata Index)", df_manifests)

        # 6. Schema
        schema_df = spark.sql(f"DESCRIBE {table_name}")
        display_table("SCHEMA", schema_df)

        print("\n" + "="*80)
        print("  Metadata queries completed successfully!")
        print("="*80 + "\n")

    except Exception as e:
        print(f"\nError: {e}")
        print("\nMake sure:")
        print("  1. MinIO is running (docker-compose up)")
        print("  2. The table exists (run test_s3_catalog.sql first)")
        print("  3. Environment variables are set correctly")

if __name__ == "__main__":
    main()
