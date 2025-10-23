# StudyU Database

This directory contains database schema and migration files for the StudyU application.

## Directory Structure

- **`migration/`** - Contains migration files that need to be applied manually when updating an
  existing StudyU instance. Each migration is dated and describes specific schema changes or
  security improvements.

- **`studyu-schema.sql`** - Contains the complete, up-to-date database schema that is applied to
  every new StudyU instance. This file represents the current state of the database after all
  migrations have been applied.

## Development

### Creating a New Migration

When making changes to the database schema, security policies, or functions:

1. **Filename Convention**: Use the format `YYYYMMDD_descriptive_name.sql`
    - The date should reflect when the migration was created
    - Use descriptive names that clearly indicate the migration's purpose

2. **Migration Content**: Structure your migration file as follows:
   ```sql
   -- ============================================================================
   -- Migration: [Brief Title]
   -- Date: [Month Day, Year]
   -- ============================================================================
   --
   -- OVERVIEW:
   -- Brief description of what this migration does and why
   --
   -- ============================================================================

   BEGIN;

   -- Your migration SQL code here
   -- Use clear comments to explain each section

   COMMIT;
   ```

3. **Best Practices**:
    - Always wrap migrations in `BEGIN;` and `COMMIT;` transactions
    - Make migrations idempotent when possible (use `IF EXISTS`, `IF NOT EXISTS`, etc.)
    - Include clear documentation explaining the purpose of each change
    - Test migrations on a local/staging environment before applying to production
    - Group related changes into logical sections with header comments

### Exporting the Current Schema

After applying migrations, update `studyu-schema.sql` to reflect the current database state:

#### Step 1: Dump the Schema Using Supabase CLI

```bash
supabase db dump -f studyu_schema_dump.sql --local --schema public
```

This exports the current database schema from your local Supabase instance.

#### Step 2: Process the Dump File

The raw dump file needs several manual modifications before it can be used as `studyu-schema.sql`:

1. **Add transaction wrapper**: Add `BEGIN;` at the beginning and `COMMIT;` at the end of the file

2. **Remove public schema creation**: Remove lines at the beginning that create the public schema (
   these are redundant and can cause issues)
   ```sql
   -- Remove lines like:
   CREATE SCHEMA IF NOT EXISTS "public";
   ALTER SCHEMA "public" OWNER TO "postgres";
   ```

3. **Remove Supabase-specific grants**: Remove lines at the end that grant privileges to
   Supabase-specific roles
   ```sql
   -- Remove lines like:
   GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
   GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
   -- etc.
   ```

4. **Add auth trigger**: Add the trigger that creates user records on signup:
   ```sql
   CREATE TRIGGER on_auth_user_created 
   AFTER INSERT ON auth.users 
   FOR EACH ROW 
   EXECUTE FUNCTION public.handle_new_user();
   ```

5. **Add privilege revocations**: Add all `REVOKE EXECUTE ON FUNCTION` statements to restrict
   function access:
   ```sql
   -- REVOKING EXECUTE PRIVILEGES

   -- Functions used in RLS policies
   REVOKE EXECUTE ON FUNCTION public.can_edit(uuid, public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.has_results_public(uuid) FROM public, anon;

   -- Computed field functions (PostgREST calls these with elevated privileges)
   REVOKE EXECUTE ON FUNCTION public.active_subject_count(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.has_study_ended(public.study_subject) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_active_days(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_ended_count(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_length(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_missed_days(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_participant_count(public.study) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.study_total_tasks(public.study_subject) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.subject_current_day(public.study_subject) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.subject_total_active_days(public.study_subject) FROM public, anon;

   -- Utility functions
   REVOKE EXECUTE ON FUNCTION public.is_active_subject(uuid, integer) FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.last_completed_task(uuid) FROM public, anon;

   -- RPC/API functions
   REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM public, anon;

   -- Trigger functions
   REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM public, anon;
   REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM public, anon;

   -- Additional revocations for authenticated users
   REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;
   REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM authenticated;
   ```

6. **Add RESET ALL**: Add `RESET ALL;` before the final `COMMIT;` to reset any session settings

#### Step 3: Verify and Replace

1. Review the processed file to ensure all changes are correct
2. Test the schema file on a fresh local instance
3. Replace `studyu-schema.sql` with your processed dump file and review the differences in version
   control

## Migration Workflow

### For Existing Instances

1. Identify which migrations need to be applied
2. Review each migration file to understand the changes
3. Apply migrations in chronological order (by date in filename)
4. Test thoroughly after each migration
5. Document which migrations have been applied to the instance

### For New Instances

No additional migrations are needed - the `studyu-schema.sql` file is applied automatically during
setup and contains all migrations

## Notes

- **Backwards Compatibility**: Migrations are designed to maintain backwards compatibility with
  existing application code
- **Local Development**: Always test schema changes locally using Supabase CLI before applying to
  staging or production

