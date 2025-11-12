# Learn Iceberg

A learning project for Apache Iceberg - an open table format for huge analytic datasets.

## Project Structure

```
learn_iceberg/
├── spark-iceberg-minio/       # Spark + Iceberg + MinIO integration
│   └── docker-compose.yml      # Docker Compose configuration for local setup
├── README.md                   # This file
├── .env                        # Environment configuration
├── .gitignore                  # Git ignore rules
└── .git/                       # Git repository metadata
```

## Overview

This project provides a hands-on learning environment for Apache Iceberg, designed to help you understand:

- **Apache Iceberg fundamentals** - An open-source table format designed for large-scale analytic datasets
- **Integration with Spark** - Using PySpark to interact with Iceberg tables
- **MinIO as Object Storage** - S3-compatible object storage for development and testing
- **Docker-based Setup** - Containerized local development environment

## Technologies

- **Apache Iceberg** - Modern table format with ACID transactions and time-travel queries
- **Apache Spark** - Distributed data processing framework
- **MinIO** - S3-compatible object storage
- **Docker & Docker Compose** - Containerization and orchestration

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your system
- Python 3.7+ (for local development)
- Basic understanding of data engineering concepts

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd learn_iceberg
   ```

2. **Configure environment variables**
   Copy the example environment file and customize as needed:
   ```bash
   cp .env.example .env
   ```

   Key variables you may want to update:
   - `MINIO_ACCESS_KEY` and `MINIO_SECRET_KEY` - MinIO credentials (default: minioadmin/minioadmin123)
   - `SPARK_DRIVER_MEMORY` and `SPARK_EXECUTOR_MEMORY` - Adjust based on your system resources
   - `MINIO_API_PORT` and `MINIO_CONSOLE_PORT` - Change if ports are already in use
   - See `.env.example` for all available configuration options

3. **Start the local environment**
   Navigate to the spark-iceberg-minio directory and start the Docker containers:
   ```bash
   cd spark-iceberg-minio
   docker-compose up -d
   ```

   This will start:
   - **MinIO** (API on port 9000, Console on port 9001)
   - **MinIO Client (mc)** - Automatically creates the warehouse bucket
   - **Spark with Iceberg** - Interactive bash environment with Iceberg support

   For detailed instructions and examples, see `spark-iceberg-minio/README.md`

### Running Examples

Once your environment is up, you can:
- Execute Spark jobs against Iceberg tables
- Explore S3 storage via MinIO UI
- Test ACID transactions and time-travel queries
- Experiment with data versioning and schema evolution

## Learning Resources

### What You'll Learn

1. **Iceberg Basics**
   - Table formats and metadata management
   - Snapshots and time-travel
   - Schema evolution and partitioning

2. **Spark Integration**
   - Reading and writing Iceberg tables
   - Querying across table versions
   - Performance optimization

3. **Object Storage**
   - S3 compatibility with MinIO
   - File organization in cloud storage
   - Catalog management

## Project Files

| File | Purpose |
|------|---------|
| `spark-iceberg-minio/docker-compose.yml` | Defines services for Spark, Iceberg, and MinIO |
| `spark-iceberg-minio/Dockerfile` | Custom image with Spark + Iceberg + S3A support |
| `spark-iceberg-minio/spark-defaults.conf.template` | Spark & Iceberg configuration template with variable placeholders |
| `spark-iceberg-minio/README.md` | Detailed setup guide and examples for the local environment |
| `spark-iceberg-minio/examples/` | Example SQL scripts and Python utilities for testing Iceberg |
| `.env` | Environment variables for configuration (⚠️ contains secrets, never commit to git) |
| `.env.example` | Template file showing all available environment variables |
| `.gitignore` | Specifies files to exclude from version control |

## Next Steps

1. Review the `docker-compose.yml` configuration
2. Explore Iceberg documentation at [https://iceberg.apache.org](https://iceberg.apache.org)
3. Start with basic Spark-Iceberg operations
4. Experiment with advanced features like time-travel and schema evolution

## Troubleshooting

- **Docker issues**: Ensure Docker daemon is running
- **Port conflicts**: Check if required ports (MinIO UI, Spark ports) are available
- **Memory issues**: Increase Docker resource limits if needed

## Additional Resources

- [Apache Iceberg Documentation](https://iceberg.apache.org/docs/)
- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [MinIO Documentation](https://docs.min.io/)

## License

This learning project is provided as-is for educational purposes.

## Contributing

Contributions and improvements are welcome! Feel free to submit issues or pull requests.
