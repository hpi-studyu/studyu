BEGIN;
--------------------------------------------------------------------
-- Revoke EXECUTE privileges on functions from public and anon roles
--------------------------------------------------------------------

-- Functions used in RLS policies
REVOKE EXECUTE ON FUNCTION public.can_edit(uuid, public.study) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.get_study_from_invite(text) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.has_results_public(uuid) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.user_email(uuid) FROM public, anon;

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
REVOKE EXECUTE ON FUNCTION public.has_study_ended(uuid) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.is_active_subject(uuid, integer) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.last_completed_task(uuid) FROM public, anon;

-- RPC/API functions
REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM public, anon;

-- Trigger functions
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM public, anon;

--------------------------------------------------------------------
-- Custom adjustments per function
--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid)
RETURNS boolean
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;

CREATE OR REPLACE FUNCTION public.has_results_public(psubject_id uuid) RETURNS boolean
  LANGUAGE plpgsql SECURITY DEFINER
  set search_path = ''
  AS $$
  BEGIN
    RETURN (
     SELECT EXISTS(
     SELECT 1
      FROM study, study_subject
      WHERE (study_subject.study_id = study.id AND psubject_id = study_subject.id AND study.result_sharing = 'public'::public.result_sharing))
    );
  END;
$$;

-- Remove user_email function entirely as it is not used
DROP FUNCTION public.user_email(uuid);

-- Remove SECURITY DEFINER from can_edit and inline user_email logic
-- Study owners already have access through RLS policies

CREATE OR REPLACE FUNCTION public.can_edit(user_id uuid, study_param public.study)
RETURNS boolean
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT study_param.user_id = user_id
    OR (SELECT email FROM public.user WHERE id = user_id) = ANY (study_param.collaborator_emails);
$$;

-- Remove SECURITY DEFINER from active_subject_count
-- Participants already have access through RLS policies

CREATE OR REPLACE FUNCTION public.active_subject_count(study public.study)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
    SELECT count(1)::int
    FROM (
        SELECT public.is_active_subject(study_subject.id, 3)
        FROM public.study_subject
        WHERE study_id = study.id
          AND study_subject.is_deleted = false
    ) AS s
    WHERE s.is_active_subject;
$$;

CREATE OR REPLACE FUNCTION public.has_study_ended(subject public.study_subject)
RETURNS boolean
LANGUAGE sql
SET search_path = ''
STABLE
AS $$
  SELECT public.study_length(s.*) < (DATE(now()) - DATE(subject.started_at))
  FROM public.study s
  WHERE s.id = subject.study_id;
$$;

-- Remove the uuid-based has_study_ended function
-- The study_subject-based version is sufficient and more commonly used
DROP FUNCTION public.has_study_ended(uuid);

CREATE OR REPLACE FUNCTION public.study_active_days(study_param public.study)
RETURNS integer[]
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT ARRAY_AGG(public.subject_total_active_days(study_subject))
  FROM public.study_subject
  WHERE study_subject.study_id = study_param.id;
$$;

CREATE OR REPLACE FUNCTION public.study_ended_count(study public.study)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT count(1)::int
  FROM (
    SELECT public.has_study_ended(study_subject) AS completed
    FROM public.study_subject
    WHERE study_id = study.id
      AND study_subject.is_deleted = false
  ) AS s
  WHERE completed;
$$;

CREATE OR REPLACE FUNCTION public.study_length(study_param public.study)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
    SELECT
        (schedule -> 'numberOfCycles')::int * (schedule -> 'phaseDuration')::int * 2 + CASE WHEN (schedule -> 'includeBaseline')::boolean THEN
        (schedule -> 'phaseDuration')::int
    ELSE
        0
        END AS length
    FROM
        public.study
    WHERE
        id = study_param.id
$$;

CREATE OR REPLACE FUNCTION public.study_missed_days(study_param public.study)
RETURNS integer[]
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select ARRAY_AGG(public.subject_current_day(study_subject) - public.subject_total_active_days(study_subject)) from public.study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;

CREATE OR REPLACE FUNCTION public.study_participant_count(study public.study)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select count(1)::int
    from public.study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;

CREATE OR REPLACE FUNCTION public.study_total_tasks(subject public.study_subject)
RETURNS integer
    LANGUAGE sql
    set search_path = ''
    STABLE
    AS $$
  select count(1)::int
    from public.subject_progress
    where subject_id = subject.id;
$$;

CREATE OR REPLACE FUNCTION public.subject_current_day(subject public.study_subject)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT
    CASE
      WHEN public.has_study_ended(subject)
      THEN (SELECT public.study_length(study) FROM public.study WHERE id = subject.study_id)::int
      ELSE DATE(now()) - DATE(subject.started_at)
    END;
$$;

CREATE OR REPLACE FUNCTION public.subject_total_active_days(subject public.study_subject)
RETURNS integer
LANGUAGE sql
set search_path = ''
STABLE
AS $$
  SELECT COUNT(DISTINCT DATE(completed_at))::int
  FROM public.subject_progress
  WHERE subject_id = subject.id
  AND DATE(completed_at) < DATE(now());
$$;

CREATE OR REPLACE FUNCTION public.is_active_subject(psubject_id uuid, days_active integer)
RETURNS boolean
	LANGUAGE plpgsql
	set search_path = ''
	STABLE
	AS $$
BEGIN
  RETURN (
    SELECT
      (DATE(now()) - last_completed_task (psubject_id)) <= days_active);
END;
$$;

CREATE OR REPLACE FUNCTION public.last_completed_task(psubject_id uuid)
RETURNS date
	LANGUAGE plpgsql
	set search_path = ''
	STABLE
	AS $$
BEGIN
    RETURN (
        SELECT
            DATE(completed_at)
        FROM
            subject_progress
        WHERE
            subject_id = psubject_id
        ORDER BY
            completed_at DESC
        LIMIT 1);
END;
$$;

-- Keep get_study_record_from_invite as SECURITY DEFINER
-- This function allows unauthenticated users to see study details via invite code
-- which participants cannot access through RLS policies

CREATE OR REPLACE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS public.study
LANGUAGE sql SECURITY DEFINER
set search_path = ''
STABLE
AS $$
  SELECT * FROM public.study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM public.study_invite
    WHERE invite_code = study_invite.code
  );
$$;

-- Update the policy to use the full study record function

DROP POLICY IF EXISTS "Invite code needs to be valid (not possible in the app)" ON public.study_subject;

CREATE POLICY "Invite code must match study_id"
ON public.study_subject
AS RESTRICTIVE
FOR INSERT
WITH CHECK (
  invite_code IS NULL
  OR study_id IN (
    SELECT (public.get_study_record_from_invite(study_subject.invite_code)).id
  )
);

-- handle_new_user does not need SECURITY DEFINER privileges
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    set search_path = ''
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;

CREATE OR REPLACE FUNCTION public.allow_updating_only_study()
 RETURNS trigger
 LANGUAGE plpgsql
 set search_path = ''
AS $function$
DECLARE
  whitelist TEXT[] := TG_ARGV::TEXT[];
  schema_table TEXT;
  column_name TEXT;
  rec RECORD;
  new_value TEXT;
  old_value TEXT;
BEGIN

  -- The user 'supabase_admin' should be able to update any record, e.g. when using Supabase Studio
  IF CURRENT_USER = 'supabase_admin' THEN
    RETURN NEW;
  END IF;

  -- In draft status allow update of all columns
  IF OLD.status = 'draft'::public.study_status THEN
    RETURN NEW;
  END IF;

  -- Only allow status to be updated from draft to running and from running to closed
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

REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM authenticated;

-- Drop get_study_from_invite - it's redundant
-- get_study_record_from_invite already returns the study_id and all study fields

DROP FUNCTION public.get_study_from_invite(text);

-- Migration to fix access policies for public.subject_progress and public.study_subject

DROP POLICY "Enable read access for all users if results are public" ON public.subject_progress;
DROP POLICY "Enable read access for all users if results are public" ON public.study_subject;

CREATE POLICY "Enable read access for all users if results are public (subject progress)"
ON public.subject_progress
FOR SELECT
USING (public.has_results_public(subject_id));

CREATE POLICY "Enable read access for all users if results are public (study subject)"
ON public.study_subject
FOR SELECT
USING (public.has_results_public(id));

COMMIT;