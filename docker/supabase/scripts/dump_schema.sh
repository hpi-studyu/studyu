#!/usr/bin/env bash

# Ensure that postgres db docker container is accessible from host and ports are forwarded
# before running this script.

# Issues that have to be manually corrected after running this script:
# - extension is not included
# - create schema public should not be included
# - TRIGGER on_auth_user_created is not included
# - Policies are sorted alphabetically, which does not make sense

DB_HOST=localhost
DB_PASS=your-super-secret-and-long-postgres-password
DB_PORT=5433

# Default case for Linux sed, just use "-i"
#sedi=(-i)
#case "$(uname)" in
#  # For macOS, use two parameters
#  Darwin*) sedi=(-i "")
#esac

pg_dump postgres://postgres:"$DB_PASS"@"$DB_HOST":"$DB_PORT"/postgres \
  --schema 'public' \
  --schema-only \
  --no-privileges \
  > schema.sql

# We could use sed in the future to correct some of the issues automatically

#sed "${sedi[@]}" -e 's/^DROP SCHEMA IF EXISTS "auth";$/-- DROP SCHEMA IF EXISTS "auth";/' dump.sql
#sed "${sedi[@]}" -e's/^DROP SCHEMA IF EXISTS "storage";$/-- DROP SCHEMA IF EXISTS "storage";/' dump.sql
#sed "${sedi[@]}" -e 's/^CREATE SCHEMA "auth";$/-- CREATE SCHEMA "auth";/' dump.sql
#sed "${sedi[@]}" -e 's/^CREATE SCHEMA "storage";$/-- CREATE SCHEMA "storage";/' dump.sql
#sed "${sedi[@]}" -e 's/^ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin"/-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin"/' dump.sql
