#!/usr/bin/env bash

# Ensure that postgres db docker container is accessible from host and ports are forwarded
# before running this script.

# Issues that have to be manually corrected after running this script:
# - extension is not included
# - create schema public should not be included
# - TRIGGER on_auth_user_created is not included
# - Policies are sorted alphabetically, which does not make sense

dump_file="studyu_schema_dump.sql"
dump_schema_name="public"
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

# Default case for Linux sed, just use "-i"
#sedi=(-i)
#case "$(uname)" in
#  # For macOS, use two parameters
#  Darwin*) sedi=(-i "")
#esac

pg_dump postgres://"$db_username":"$POSTGRES_PASSWORD"@"$POSTGRES_HOST":"$POSTGRES_PORT"/"$POSTGRES_DB" \
  --schema "$dump_schema_name" \
  --schema-only \
  --no-privileges \
  > "$dump_file"

# We could use sed in the future to correct some of the issues automatically

#sed "${sedi[@]}" -e 's/^DROP SCHEMA IF EXISTS "auth";$/-- DROP SCHEMA IF EXISTS "auth";/' dump.sql
#sed "${sedi[@]}" -e's/^DROP SCHEMA IF EXISTS "storage";$/-- DROP SCHEMA IF EXISTS "storage";/' dump.sql
#sed "${sedi[@]}" -e 's/^CREATE SCHEMA "auth";$/-- CREATE SCHEMA "auth";/' dump.sql
#sed "${sedi[@]}" -e 's/^CREATE SCHEMA "storage";$/-- CREATE SCHEMA "storage";/' dump.sql
#sed "${sedi[@]}" -e 's/^ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin"/-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin"/' dump.sql
