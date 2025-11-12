FROM tabulario/spark-iceberg:latest

# Install curl and gettext (for envsubst) for template processing
RUN apt-get update && apt-get install -y curl gettext-base && rm -rf /var/lib/apt/lists/*

# Copy Spark configuration template
COPY spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf.template

# Create entrypoint script to process template with environment variables
RUN echo '#!/bin/bash\n\
envsubst < /opt/spark/conf/spark-defaults.conf.template > /opt/spark/conf/spark-defaults.conf\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/iceberg

# Set AWS_REGION environment variable for Iceberg S3FileIO (AWS SDK v2)
ENV AWS_REGION=us-east-1

# Use custom entrypoint to process template
ENTRYPOINT ["/entrypoint.sh"]

# Default command - start bash with Spark SQL available
CMD ["/bin/bash", "--login"]
