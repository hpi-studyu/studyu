-- todo move to studyu-schema.sql

CREATE TYPE public.study_status AS ENUM (
    'draft',
    'running',
    'closed'
);

ALTER TABLE public.study
ADD COLUMN status public.study_status DEFAULT 'draft'::public.study_status NOT NULL;

-- Migrate existing studies from published to study_status
UPDATE public.study SET status = CASE
    WHEN status != 'draft'::public.study_status THEN status
    WHEN published THEN 'running'::public.study_status
    ELSE status
END;

-- Migrate policy
DROP POLICY "Editors can do everything with their studies" ON public.study;

CREATE POLICY "Editors can view their studies" ON public.study FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Editor can control their draft studies" ON public.study
    --USING (public.can_edit(auth.uid(), study.*) AND status = 'draft'::public.study_status);
    USING (public.can_edit(auth.uid(), study.*));

-- Editors can only update registry_published and resultSharing
--grant update (registry_published, result_sharing) on public.study USING (public.can_edit(auth.uid(), study.*);
--CREATE POLICY "Editors can only update registry_published and resultSharing" ON public.study
--    FOR UPDATE
--    USING (public.can_edit(auth.uid(), study.*))
--    WITH CHECK ((new.*) IS NOT DISTINCT FROM (old.* EXCEPT registry_published, result_sharing));
-- t odo solve with trigger or function
-- or create view with only updatable columns and provide permission on view see https://dba.stackexchange.com/questions/298931/allow-users-to-modify-only-some-but-not-all-fields-in-a-postgresql-table-with

-- https://stackoverflow.com/questions/72756376/supabase-solutions-for-column-level-security

-- https://github.com/orgs/supabase/discussions/656#discussioncomment-5594653

-- todo document this function
CREATE OR REPLACE FUNCTION public.allow_updating_only()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  whitelist TEXT[] := TG_ARGV::TEXT[];
  schema_table TEXT;
  column_name TEXT;
  rec RECORD;
  new_value TEXT;
  old_value TEXT;
BEGIN

  -- If the current user is 'postgres', return NEW without making any changes
  IF CURRENT_USER = 'postgres' THEN
    RETURN NEW;
  END IF;

  -- If the status is draft, return NEW without making any changes
  IF OLD.status = 'draft'::public.study_status THEN
    RETURN NEW;
  END IF;

  -- Don't allow invalid status transitions
  IF OLD.status != NEW.status THEN
    IF NOT (
        (OLD.status = 'draft'::public.study_status AND NEW.status = 'running'::public.study_status)
        OR (OLD.status = 'running'::public.study_status AND NEW.status = 'closed'::public.study_status)
    ) THEN
      RAISE EXCEPTION 'Invalid status transition';
    END IF;
  END IF;

  schema_table := concat(TG_TABLE_SCHEMA, '.', TG_TABLE_NAME);

  -- If RLS is not active on current table for function invoker, early return
  IF NOT row_security_active(schema_table) THEN
    RETURN NEW;
  END IF;

  -- Otherwise, loop on all columns of the table schema
  FOR rec IN (
    SELECT col.column_name
    FROM information_schema.columns as col
    WHERE table_schema = TG_TABLE_SCHEMA
    AND table_name = TG_TABLE_NAME
  ) LOOP
    -- If the current column is whitelisted, early continue
    column_name := rec.column_name;
    IF column_name = ANY(whitelist) THEN
      CONTINUE;
    END IF;

    -- If not whitelisted, execute dynamic SQL to get column value from OLD and NEW records
    EXECUTE format('SELECT ($1).%I, ($2).%I', column_name, column_name)
    INTO new_value, old_value
    USING NEW, OLD;

    -- Raise exception if column value changed
    IF new_value IS DISTINCT FROM old_value THEN
      RAISE EXCEPTION 'Unauthorized change to "%"', column_name;
    END IF;
  END LOOP;

  -- RLS active, but no exception encountered, clear to proceed.
  RETURN NEW;
END;
$function$;

CREATE OR REPLACE TRIGGER study_status_update_permissions
  BEFORE UPDATE
  ON public.study
  FOR EACH ROW
  EXECUTE FUNCTION public.allow_updating_only('updated_at', 'status', 'registry_published', 'result_sharing');
  -- todo also add participation?

-- Owners can update status
--CREATE FUNCTION public.update_study_status(study_param public.study) RETURNS VOID
--    LANGUAGE plpgsql -- SECURITY DEFINER
--    AS $$
--BEGIN
    --IF study_param.user_id != auth.uid() THEN
    --    RAISE EXCEPTION 'Only the owner can update the status';
    --END IF;
    -- Increment the study.status
--    UPDATE public.study
--    SET status = CASE
--        WHEN study_param.status = 'draft'::public.study_status THEN 'running'::public.study_status
--        WHEN study_param.status = 'running'::public.study_status THEN 'closed'::public.study_status
--        ELSE study_param.status
--    END
--    WHERE id = study_param.id;
--END;
--$$;

--ALTER FUNCTION public.update_study_status(public.study) OWNER TO postgres;

CREATE POLICY "Joining a closed study should not be possible" ON public.study_subject
    AS RESTRICTIVE
    FOR INSERT
    WITH CHECK (NOT EXISTS (
    SELECT 1
    FROM public.study
    WHERE study.id = study_subject.study_id
      AND study.status = 'closed'::public.study_status
));
