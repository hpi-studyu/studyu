#!/usr/bin/env bash

default_username="postgres"
env_file="../.env"

# Check if the .env file exists
if [ -f "$env_file" ]; then
  # Source the .env file to set environment variables
  set -a
  # shellcheck disable=SC1090
  . "$env_file"
  set +a
else
  echo "Error: .env file not found."
  exit 1
fi

db_username="${POSTGRES_USERNAME:-$default_username}"

# Check if the Docker container is running
if ! docker ps -a --format '{{.Names}}' | grep -q "^$POSTGRES_HOST$"; then
  echo "Docker container '$POSTGRES_HOST' is not running."
  exit 1
fi

# Get the container's IP address
container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$POSTGRES_HOST")

# Extract the SQL file from the script argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/your/sqlfile.sql"
  exit 1
fi

sql_file="$1"

# Copy the SQL file to the container
docker cp "$sql_file" "$POSTGRES_HOST:/tmp/"

# Connect to the PostgreSQL database and execute the SQL file from within the container
if docker exec -i "$POSTGRES_HOST" psql -h "$container_ip" -U "$db_username" -d "$POSTGRES_DB" -c "\i /tmp/$(basename "$sql_file")" > execute_supabase_sql_output.txt 2>&1; then
  echo "SQL script executed successfully."
else
  echo "SQL script execution failed."
  exit 1
fi
