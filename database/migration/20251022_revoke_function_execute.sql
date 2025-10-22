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
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;

-- Remove user_email function entirely as it is not used
DROP FUNCTION IF EXISTS public.user_email(uuid);

-- Remove SECURITY DEFINER from can_edit and inline user_email logic
-- Study owners already have access through RLS policies

CREATE OR REPLACE FUNCTION public.can_edit(user_id uuid, study_param public.study)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
  SELECT study_param.user_id = user_id
    OR (SELECT email FROM "user" WHERE id = user_id) = ANY (study_param.collaborator_emails);
$$;

-- Remove SECURITY DEFINER from active_subject_count
-- Participants already have access through RLS policies

CREATE OR REPLACE FUNCTION public.active_subject_count(study public.study)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
    SELECT count(1)::int
    FROM (
        SELECT is_active_subject(study_subject.id, 3)
        FROM study_subject
        WHERE study_id = study.id
          AND study_subject.is_deleted = false
    ) AS s
    WHERE s.is_active_subject;
$$;

CREATE OR REPLACE FUNCTION public.has_study_ended(psubject_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
    SELECT study_length(study) < (DATE(now()) - DATE(started_at))
    FROM study
    INNER JOIN study_subject ON study.id = study_subject.study_id
    WHERE study_subject.id = psubject_id;
$$;

CREATE OR REPLACE FUNCTION public.study_active_days(study_param public.study)
RETURNS integer[]
LANGUAGE sql
STABLE
AS $$
  SELECT ARRAY_AGG(subject_total_active_days(study_subject))
  FROM study_subject
  WHERE study_subject.study_id = study_param.id;
$$;

CREATE OR REPLACE FUNCTION public.study_ended_count(study public.study)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT count(1)::int
  FROM (
    SELECT has_study_ended(study_subject) AS completed
    FROM study_subject
    WHERE study_id = study.id
      AND study_subject.is_deleted = false
  ) AS s
  WHERE completed;
$$;

CREATE OR REPLACE FUNCTION public.study_length(study_param public.study)
RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
    SELECT
        (schedule -> 'numberOfCycles')::int * (schedule -> 'phaseDuration')::int * 2 + CASE WHEN (schedule -> 'includeBaseline')::boolean THEN
        (schedule -> 'phaseDuration')::int
    ELSE
        0
        END AS length
    FROM
        study
    WHERE
        id = study_param.id
$$;

CREATE OR REPLACE FUNCTION public.study_missed_days(study_param public.study)
RETURNS integer[]
    LANGUAGE sql
    STABLE
    AS $$
  select ARRAY_AGG(subject_current_day(study_subject) - subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;

CREATE OR REPLACE FUNCTION public.study_participant_count(study public.study)
RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
  select count(1)::int
    from study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;

CREATE OR REPLACE FUNCTION public.study_total_tasks(subject public.study_subject)
RETURNS integer
    LANGUAGE sql
    STABLE
    AS $$
  select count(1)::int
    from subject_progress
    where subject_id = subject.id;
$$;

CREATE OR REPLACE FUNCTION public.subject_current_day(subject public.study_subject)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT
    CASE
      WHEN has_study_ended(subject)
      THEN (SELECT study_length(study) FROM study WHERE id = subject.study_id)::int
      ELSE DATE(now()) - DATE(subject.started_at)
    END;
$$;

CREATE OR REPLACE FUNCTION public.subject_total_active_days(subject public.study_subject)
RETURNS integer
LANGUAGE sql
STABLE
AS $$
  SELECT COUNT(DISTINCT DATE(completed_at))::int
  FROM subject_progress
  WHERE subject_id = subject.id
  AND DATE(completed_at) < DATE(now());
$$;

-- Remove the uuid-based has_study_ended function
-- The study_subject-based version is sufficient and more commonly used
DROP FUNCTION IF EXISTS public.has_study_ended(uuid);

CREATE OR REPLACE FUNCTION public.is_active_subject(psubject_id uuid, days_active integer)
RETURNS boolean
	LANGUAGE plpgsql
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
STABLE
AS $$
  SELECT * FROM study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM study_invite
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
    LANGUAGE plpgsql
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;

REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.allow_updating_only_study() FROM authenticated;

-- Drop get_study_from_invite - it's redundant
-- get_study_record_from_invite already returns the study_id and all study fields

DROP FUNCTION IF EXISTS public.get_study_from_invite(text);

-- Migration to fix access policies for public.subject_progress and public.study_subject

DROP POLICY IF EXISTS "Enable read access for all users if results are public" ON public.subject_progress;
DROP POLICY IF EXISTS "Enable read access for all users if results are public" ON public.study_subject;

CREATE POLICY "Enable read access for all users if results are public (subject progress)"
ON public.subject_progress
FOR SELECT
USING (public.has_results_public(subject_id));

CREATE POLICY "Enable read access for all users if results are public (study subject)"
ON public.study_subject
FOR SELECT
USING (public.has_results_public(id));

COMMIT;