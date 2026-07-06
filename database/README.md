# StudyU Database Legacy Files

Supabase CLI migrations in `../supabase/migrations/` are the canonical source of truth for the StudyU database schema and production-safe database changes.

## Directory structure

- `migration-legacy/`: historical manual migrations that were folded into `../supabase/migrations/0000000000001_studyu-schema.sql`.

## Workflow

Do not add new migrations in this directory. Create future database changes with the Supabase CLI:

```bash
supabase migration new <migration_name>
```

Then commit the generated SQL file under `../supabase/migrations/`.

Production deployments apply migrations only:

```bash
supabase link --project-ref "$PROJECT_REF"
supabase db push
```

Do not run development or test seeds in production.
