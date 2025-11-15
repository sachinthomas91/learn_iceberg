FROM tabulario/spark-iceberg:latest

# Install curl and gettext (for envsubst) for template processing
RUN apt-get update && apt-get install -y curl gettext-base && rm -rf /var/lib/apt/lists/*

# Copy Spark configuration template
COPY spark-defaults.conf.template /opt/spark/conf/spark-defaults.conf.template

# Create entrypoint script to process template with environment variables
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Process Spark configuration template with environment variables
envsubst < /opt/spark/conf/spark-defaults.conf.template > /opt/spark/conf/spark-defaults.conf

# Start Thrift Server in background, redirect to stderr to see output
echo "Starting Spark Thrift Server..."
$SPARK_HOME/sbin/start-thriftserver.sh --master "local[*]" 2>&1 &
THRIFT_PID=$!
echo "Thrift Server started with PID: $THRIFT_PID"

# Give Thrift Server time to start
sleep 8

# Check if Thrift Server is running
if kill -0 $THRIFT_PID 2>/dev/null; then
  echo "Thrift Server is running"
else
  echo "Warning: Thrift Server process exited"
fi

# Execute the main command (bash)
"$@"
EOF
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /home/iceberg

# Set AWS_REGION environment variable for Iceberg S3FileIO (AWS SDK v2)
ENV AWS_REGION=us-east-1

# Use custom entrypoint to process template
ENTRYPOINT ["/entrypoint.sh"]

# Default command - start bash with Spark SQL available
CMD ["/bin/bash", "--login"]
