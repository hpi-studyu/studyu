#!/usr/bin/env bash

#DB_HOST=localhost
#DB_PASS=your-super-secret-and-long-postgres-password
#DB_PORT=5432

EXPORT_FILE=data.sql

# Dump database to file
# Specify certain schema to dump with pg_dump by using -n <schema_name> e.g. -n "public"
pg_dump postgres://postgres:"$DB_PASS"@"$DB_HOST":"$DB_PORT"/postgres --column-inserts --data-only > $EXPORT_FILE

echo "SET session_replication_role = replica;" | cat - $EXPORT_FILE > temp_file && mv temp_file $EXPORT_FILE
echo "SET session_replication_role = DEFAULT;" >> $EXPORT_FILE

# If necessary, migration code can be manually inserted into the dump at the beginning of the file
# after the SET options
