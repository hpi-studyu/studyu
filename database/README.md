# Database

This directory contains the StudyU database schema and migration scripts.

Do not make any changes to the `studyu-schema.sql` file directly. Instead, create a new migration
script in the `migrations` directory. The schema file will be updated automatically by the CI/CD pipeline.

## Migrations

Any new database schema changes should be added as a new migration script in the `migrations` directory.
The migration script should be named `{timestamp}__{description}.sql`, where `{timestamp}` is the current
timestamp and `{description}` is a short description of the migration.
