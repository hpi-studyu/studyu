#!/usr/bin/env bash

dump_file="studyu_data_dump.sql"
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
# todo include option to connect to external db via host and password specified in this file
# todo same for dump_schema.sh


# Check if the Docker container is running
if ! docker ps -a --format '{{.Names}}' | grep -q "^$POSTGRES_HOST$"; then
  echo "Docker container '$POSTGRES_HOST' is not running."
  exit 1
fi

# Dump database to file
# Specify certain schema to dump with pg_dump by using -n <schema_name> e.g. -n "public"
pg_dump postgres://"$db_username":"$POSTGRES_PASSWORD"@"$POSTGRES_HOST":"$POSTGRES_PORT"/"$POSTGRES_DB" --column-inserts --data-only > "$dump_file"

echo "SET session_replication_role = replica;" | cat - "$dump_file" > temp_file && mv temp_file "$dump_file"
echo "SET session_replication_role = DEFAULT;" >> "$dump_file"

# If necessary, migration code can be manually inserted into the dump at the beginning of the file
# after the SET options
