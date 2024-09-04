BEGIN;

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "moddatetime" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."git_provider" AS ENUM (
    'gitlab'
);


ALTER TYPE "public"."git_provider" OWNER TO "postgres";


CREATE TYPE "public"."participation" AS ENUM (
    'open',
    'invite'
);


ALTER TYPE "public"."participation" OWNER TO "postgres";


CREATE TYPE "public"."result_sharing" AS ENUM (
    'public',
    'private',
    'organization'
);


ALTER TYPE "public"."result_sharing" OWNER TO "postgres";


CREATE TYPE "public"."study_status" AS ENUM (
    'draft',
    'running',
    'closed'
);


ALTER TYPE "public"."study_status" OWNER TO "postgres";


CREATE TYPE "public"."study_type" AS ENUM (
    'standalone-trial',
    'sub-trial',
    'template'
);


ALTER TYPE "public"."study_type" OWNER TO "postgres";


CREATE TYPE "public"."upsert_type" AS ENUM (
    'insert',
    'update'
);


ALTER TYPE "public"."upsert_type" OWNER TO "postgres";


COMMENT ON TYPE "public"."upsert_type" IS 'Type of upsert operation used by check_locked_template_fields_func';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."study_base" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "contact" "jsonb" NOT NULL,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "icon_name" "text" NOT NULL,
    "published" boolean DEFAULT false NOT NULL,
    "status" "public"."study_status" DEFAULT 'draft'::"public"."study_status" NOT NULL,
    "registry_published" boolean DEFAULT false NOT NULL,
    "questionnaire" "jsonb" NOT NULL,
    "eligibility_criteria" "jsonb" NOT NULL,
    "observations" "jsonb" NOT NULL,
    "interventions" "jsonb" NOT NULL,
    "consent" "jsonb" NOT NULL,
    "schedule" "jsonb" NOT NULL,
    "report_specification" "jsonb" NOT NULL,
    "results" "jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "participation" "public"."participation" DEFAULT 'invite'::"public"."participation" NOT NULL,
    "result_sharing" "public"."result_sharing" DEFAULT 'private'::"public"."result_sharing" NOT NULL,
    "collaborator_emails" "text"[] DEFAULT '{}'::"text"[] NOT NULL
);


ALTER TABLE "public"."study_base" OWNER TO "postgres";


COMMENT ON COLUMN "public"."study_base"."user_id" IS 'UserId of study creator';



CREATE OR REPLACE FUNCTION "public"."active_subject_count"("study" "public"."study_base") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
    SELECT
            count(1)::int
        FROM (
            SELECT
                is_active_subject (study_subject.id, 3) -- TODO: Let research decide when User is not active anymore
            FROM
                study_subject
            WHERE
                study_id = study.id
                AND study_subject.is_deleted = false
            ) AS s
        WHERE
            s.is_active_subject;

$$;


ALTER FUNCTION "public"."active_subject_count"("study" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."allow_updating_only_study"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
  whitelist TEXT[] := TG_ARGV::TEXT[];
  schema_table TEXT;
  column_name TEXT;
  rec RECORD;
  new_value TEXT;
  old_value TEXT;
BEGIN

  -- The user 'postgres' should be able to update any record, e.g. when using Supabase Studio
  IF CURRENT_USER = 'postgres' THEN
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
$_$;


ALTER FUNCTION "public"."allow_updating_only_study"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study_base") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select study_param.user_id = user_id OR user_email(user_id) = ANY (study_param.collaborator_emails);
$$;


ALTER FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    _original_contact JSONB;
    _original_participation public.participation;
    _original_schedule JSONB;
    _original_result_sharing public.result_sharing;
    _original_registry_published BOOLEAN;
    _locked_contact BOOLEAN;
    _locked_participation BOOLEAN;
    _locked_schedule BOOLEAN;
    _locked_registry BOOLEAN;
BEGIN

    -- Get lock status from the template table
    SELECT locked_contact, locked_participation, locked_schedule, locked_registry
    INTO _locked_contact, _locked_participation, _locked_schedule, _locked_registry
    FROM template
    WHERE template.id = _parent_id;

    IF _locked_contact IS NULL OR
       _locked_participation IS NULL OR
       _locked_schedule IS NULL OR
       _locked_registry IS NULL THEN
        RAISE EXCEPTION 'One or more locked fields are NULL. Cannot proceed with validation.';
    END IF;

    IF _type = 'update' THEN
        -- Get original field values from the study table
        SELECT contact, participation, schedule, result_sharing, registry_published
        INTO _original_contact, _original_participation, _original_schedule, _original_result_sharing, _original_registry_published
        FROM study
        WHERE study.id = _id;
    ELSIF _type = 'insert' THEN
        -- Get original field values from the template table
        SELECT contact, participation, schedule, result_sharing, registry_published
        INTO _original_contact, _original_participation, _original_schedule, _original_result_sharing, _original_registry_published
        FROM template
        WHERE template.id = _parent_id;
    ELSE
        RAISE EXCEPTION 'Invalid upsert type';
    END IF;

    -- Check if any of the required variables are NULL
    IF _original_contact IS NULL OR
    _original_participation IS NULL OR
    _original_schedule IS NULL OR
    _original_result_sharing IS NULL OR
    _original_registry_published IS NULL THEN
    RAISE EXCEPTION 'One or more required fields are NULL. Cannot proceed with validation.';
    END IF;

    -- Check if the locked fields are being modified
    IF _locked_contact AND _new_contact IS DISTINCT FROM _original_contact THEN
        RAISE EXCEPTION 'Cannot modify contact field as it is locked by the parent template';
    ELSIF _locked_participation AND _new_participation IS DISTINCT FROM _original_participation THEN
        RAISE EXCEPTION 'Cannot modify participation field as it is locked by the parent template';
    ELSIF _locked_schedule AND _new_schedule IS DISTINCT FROM _original_schedule THEN
        RAISE EXCEPTION 'Cannot modify schedule field as it is locked by the parent template';
    ELSIF _locked_registry AND (_new_result_sharing IS DISTINCT FROM _original_result_sharing OR _new_registry_published IS DISTINCT FROM _original_registry_published) THEN
        RAISE EXCEPTION 'Cannot modify result_sharing field and registry_published as they are locked by the parent template';
    END IF;

    -- If no exception has been raised, return true
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) IS 'Restrict modifications to fields locked by the template when inserting a new sub-trial';



CREATE OR REPLACE FUNCTION "public"."get_study_from_invite"("invite_code" "text") RETURNS TABLE("study_id" "uuid", "preselected_intervention_ids" "text"[])
    LANGUAGE "sql" IMMUTABLE SECURITY DEFINER
    AS $$
   select study_invite.study_id, study_invite.preselected_intervention_ids
   from study_invite
   where invite_code = study_invite.code;
$$;


ALTER FUNCTION "public"."get_study_from_invite"("invite_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") RETURNS "public"."study_base"
    LANGUAGE "sql" IMMUTABLE SECURITY DEFINER
    AS $$
    SELECT * FROM study WHERE study.id = (
        SELECT study_invite.study_id
        FROM study_invite
        WHERE invite_code = study_invite.code
   );
$$;


ALTER FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_results_public"("psubject_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."has_results_public"("psubject_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_study_ended"("psubject_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (
        SELECT
            study_length(study) < (DATE(now()) - DATE(started_at)) AS completed
        FROM study, study_subject
        WHERE study.id = study_subject.study_id
        AND study_subject.id = psubject_id);
END;
$$;


ALTER FUNCTION "public"."has_study_ended"("psubject_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."study_subject" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "study_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "selected_intervention_ids" "text"[] NOT NULL,
    "invite_code" "text",
    "is_deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."study_subject" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN (
        SELECT
            study_length(study) < (DATE(now()) - DATE(started_at)) AS completed
        FROM study, study_subject
        WHERE study.id = study_subject.study_id
        AND study_subject.id = subject.id);
END;
$$;


ALTER FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN (
    SELECT
      (DATE(now()) - last_completed_task (psubject_id)) <= days_active);
END;
$$;


ALTER FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;


ALTER FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."last_completed_task"("psubject_id" "uuid") RETURNS "date"
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."last_completed_task"("psubject_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF _parent_id IS DISTINCT FROM OLD.parent_id THEN
        RAISE EXCEPTION 'Cannot move a sub-trial to another template';
    END IF;
    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") IS 'Prevent changing the template of a sub-trial';



CREATE OR REPLACE FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    _status TEXT;
BEGIN
    -- Get the status of the parent template
    SELECT status
    INTO _status
    FROM template
    WHERE id = _parent_id;

    -- If the template is closed, prevent creating a new sub-trial
    IF _status = 'closed' THEN
        RAISE EXCEPTION 'Cannot create a new sub-trial for a closed template';
    END IF;

    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") IS 'Prevent creating a new sub-trial for a closed template';



CREATE OR REPLACE FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    sub_trial_count INT;
BEGIN
    -- Count the number of sub-trials referencing this template
    SELECT COUNT(*)
    INTO sub_trial_count
    FROM study
    WHERE parent_id = _id;

    -- If there are sub-trials, prevent deletion
    IF sub_trial_count > 0 THEN
        RAISE EXCEPTION 'Cannot delete template with existing sub-trials';
    END IF;

    RETURN TRUE;
END;
$$;


ALTER FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") IS 'Prevent deletion of a template with existing sub-trials';



CREATE OR REPLACE FUNCTION "public"."study_active_days"("study_param" "public"."study_base") RETURNS integer[]
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select ARRAY_AGG(subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id;
$$;


ALTER FUNCTION "public"."study_active_days"("study_param" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_ended_count"("study" "public"."study_base") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
    SELECT
        count(1)::int
    FROM (
        SELECT
            has_study_ended (study_subject.id) AS completed
        FROM
            study_subject
        WHERE
            study_id = study.id
            AND study_subject.is_deleted = false
        ) AS s
WHERE
    completed;

$$;


ALTER FUNCTION "public"."study_ended_count"("study" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_length"("study_param" "public"."study_base") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
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


ALTER FUNCTION "public"."study_length"("study_param" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_missed_days"("study_param" "public"."study_base") RETURNS integer[]
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select ARRAY_AGG(subject_current_day(study_subject) - subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;


ALTER FUNCTION "public"."study_missed_days"("study_param" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_participant_count"("study" "public"."study_base") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select count(1)::int
    from study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;


ALTER FUNCTION "public"."study_participant_count"("study" "public"."study_base") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  select count(1)::int
    from subject_progress
    where subject_id = subject.id;
$$;


ALTER FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT
    CASE WHEN has_study_ended(subject) THEN (Select study_length(study) from study where id = subject.study_id)::int
    ELSE
        DATE(now()) - DATE(subject.started_at)
    END;
$$;


ALTER FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") RETURNS integer
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT
    COUNT(DISTINCT DATE(completed_at))::int
FROM
    subject_progress
WHERE subject_id = subject.id
AND DATE(completed_at) < DATE(now());
$$;


ALTER FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_sub_trial_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    -- Only update the sub-trials if the new status is 'closed' and the sub-trial's current status is 'running'
    IF NEW.status = 'closed'::public.study_status THEN
        UPDATE study
        SET status = NEW.status
        WHERE parent_id = OLD.id AND status = 'running'::public.study_status;
    END IF;
    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."update_sub_trial_status"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_sub_trial_status"() IS 'If the status of a template is updated to "closed", update the status of all sub-trials currently "running" to "closed". Otherwise, do not change the status of the sub-trials.';



CREATE OR REPLACE FUNCTION "public"."user_email"("user_id" "uuid") RETURNS "text"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT email from "user" where id = user_id
$$;


ALTER FUNCTION "public"."user_email"("user_id" "uuid") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."app_config" (
    "id" "text" NOT NULL,
    "app_min_version" "text" NOT NULL,
    "app_privacy" "jsonb" NOT NULL,
    "app_terms" "jsonb" NOT NULL,
    "designer_privacy" "jsonb" NOT NULL,
    "designer_terms" "jsonb" NOT NULL,
    "imprint" "jsonb" NOT NULL,
    "contact" "jsonb" DEFAULT '{"email": "hpi-info@hpi.de", "phone": "+49-(0)331 5509-0", "website": "https://hpi.de/", "organization": "Hasso Plattner Institute"}'::"jsonb" NOT NULL,
    "analytics" "jsonb"
);


ALTER TABLE "public"."app_config" OWNER TO "postgres";


COMMENT ON TABLE "public"."app_config" IS 'Stores app config for different envs';



CREATE TABLE IF NOT EXISTS "public"."repo" (
    "project_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "study_id" "uuid" NOT NULL,
    "provider" "public"."git_provider" NOT NULL
);


ALTER TABLE "public"."repo" OWNER TO "postgres";


COMMENT ON TABLE "public"."repo" IS 'Git repo where the generated project is stored';



CREATE TABLE IF NOT EXISTS "public"."study" (
    "parent_id" "uuid"
)
INHERITS ("public"."study_base");


ALTER TABLE "public"."study" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."template" (
    "locked_contact" boolean DEFAULT false NOT NULL,
    "locked_participation" boolean DEFAULT false NOT NULL,
    "locked_schedule" boolean DEFAULT false NOT NULL,
    "locked_registry" boolean DEFAULT false NOT NULL
)
INHERITS ("public"."study_base");


ALTER TABLE "public"."template" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."study_display_view" AS
 SELECT "id",
    "contact",
    "title",
    "description",
    "icon_name",
    "published",
    "status",
    "registry_published",
    "questionnaire",
    "eligibility_criteria",
    "observations",
    "interventions",
    "consent",
    "schedule",
    "report_specification",
    "results",
    "created_at",
    "updated_at",
    "user_id",
    "participation",
    "result_sharing",
    "collaborator_emails",
    "source",
    "study"."parent_id",
    "template"."locked_contact",
    "template"."locked_participation",
    "template"."locked_schedule",
    "template"."locked_registry",
        CASE
            WHEN ("template"."locked_contact" IS NOT NULL) THEN 'template'::"public"."study_type"
            WHEN ("study"."parent_id" IS NOT NULL) THEN 'sub-trial'::"public"."study_type"
            ELSE 'standalone-trial'::"public"."study_type"
        END AS "study_type"
   FROM (( SELECT "study_1"."id",
            "study_1"."contact",
            "study_1"."title",
            "study_1"."description",
            "study_1"."icon_name",
            "study_1"."published",
            "study_1"."status",
            "study_1"."registry_published",
            "study_1"."questionnaire",
            "study_1"."eligibility_criteria",
            "study_1"."observations",
            "study_1"."interventions",
            "study_1"."consent",
            "study_1"."schedule",
            "study_1"."report_specification",
            "study_1"."results",
            "study_1"."created_at",
            "study_1"."updated_at",
            "study_1"."user_id",
            "study_1"."participation",
            "study_1"."result_sharing",
            "study_1"."collaborator_emails",
            "study_1"."parent_id",
            'study'::"text" AS "source"
           FROM "public"."study" "study_1") "study"
     FULL JOIN ( SELECT "template_1"."id",
            "template_1"."contact",
            "template_1"."title",
            "template_1"."description",
            "template_1"."icon_name",
            "template_1"."published",
            "template_1"."status",
            "template_1"."registry_published",
            "template_1"."questionnaire",
            "template_1"."eligibility_criteria",
            "template_1"."observations",
            "template_1"."interventions",
            "template_1"."consent",
            "template_1"."schedule",
            "template_1"."report_specification",
            "template_1"."results",
            "template_1"."created_at",
            "template_1"."updated_at",
            "template_1"."user_id",
            "template_1"."participation",
            "template_1"."result_sharing",
            "template_1"."collaborator_emails",
            "template_1"."locked_contact",
            "template_1"."locked_participation",
            "template_1"."locked_schedule",
            "template_1"."locked_registry",
            'template'::"text" AS "source"
           FROM "public"."template" "template_1") "template" USING ("id", "contact", "title", "description", "icon_name", "published", "status", "registry_published", "questionnaire", "eligibility_criteria", "observations", "interventions", "consent", "schedule", "report_specification", "results", "created_at", "updated_at", "user_id", "participation", "result_sharing", "collaborator_emails", "source"));


ALTER TABLE "public"."study_display_view" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."study_invite" (
    "code" "text" NOT NULL,
    "study_id" "uuid" NOT NULL,
    "preselected_intervention_ids" "text"[]
);


ALTER TABLE "public"."study_invite" OWNER TO "postgres";


COMMENT ON TABLE "public"."study_invite" IS 'Study invite codes';



COMMENT ON COLUMN "public"."study_invite"."preselected_intervention_ids" IS 'Intervention Ids (and order) preselected by study creator';



CREATE TABLE IF NOT EXISTS "public"."subject_progress" (
    "completed_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "subject_id" "uuid" NOT NULL,
    "intervention_id" "text" NOT NULL,
    "task_id" "text" NOT NULL,
    "result_type" "text" NOT NULL,
    "result" "jsonb" NOT NULL
);


ALTER TABLE "public"."subject_progress" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."study_progress_export" WITH ("security_invoker"='on') AS
 SELECT "subject_progress"."completed_at",
    "subject_progress"."intervention_id",
    "subject_progress"."task_id",
    "subject_progress"."result_type",
    "subject_progress"."result",
    "subject_progress"."subject_id",
    "study_subject"."user_id",
    "study_subject"."study_id",
    "study_subject"."started_at",
    "study_subject"."selected_intervention_ids"
   FROM "public"."study_subject",
    "public"."subject_progress"
  WHERE ("study_subject"."id" = "subject_progress"."subject_id");


ALTER TABLE "public"."study_progress_export" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user" (
    "id" "uuid" NOT NULL,
    "email" "text",
    "preferences" "jsonb"
);


ALTER TABLE "public"."user" OWNER TO "postgres";


COMMENT ON TABLE "public"."user" IS 'Users get automatically added, when a new user is created in auth.users';



ALTER TABLE ONLY "public"."study" ALTER COLUMN "id" SET DEFAULT "gen_random_uuid"();



ALTER TABLE ONLY "public"."study" ALTER COLUMN "published" SET DEFAULT false;



ALTER TABLE ONLY "public"."study" ALTER COLUMN "status" SET DEFAULT 'draft'::"public"."study_status";



ALTER TABLE ONLY "public"."study" ALTER COLUMN "registry_published" SET DEFAULT false;



ALTER TABLE ONLY "public"."study" ALTER COLUMN "created_at" SET DEFAULT "now"();



ALTER TABLE ONLY "public"."study" ALTER COLUMN "updated_at" SET DEFAULT "now"();



ALTER TABLE ONLY "public"."study" ALTER COLUMN "participation" SET DEFAULT 'invite'::"public"."participation";



ALTER TABLE ONLY "public"."study" ALTER COLUMN "result_sharing" SET DEFAULT 'private'::"public"."result_sharing";



ALTER TABLE ONLY "public"."study" ALTER COLUMN "collaborator_emails" SET DEFAULT '{}'::"text"[];



ALTER TABLE ONLY "public"."template" ALTER COLUMN "id" SET DEFAULT "gen_random_uuid"();



ALTER TABLE ONLY "public"."template" ALTER COLUMN "published" SET DEFAULT false;



ALTER TABLE ONLY "public"."template" ALTER COLUMN "status" SET DEFAULT 'draft'::"public"."study_status";



ALTER TABLE ONLY "public"."template" ALTER COLUMN "registry_published" SET DEFAULT false;



ALTER TABLE ONLY "public"."template" ALTER COLUMN "created_at" SET DEFAULT "now"();



ALTER TABLE ONLY "public"."template" ALTER COLUMN "updated_at" SET DEFAULT "now"();



ALTER TABLE ONLY "public"."template" ALTER COLUMN "participation" SET DEFAULT 'invite'::"public"."participation";



ALTER TABLE ONLY "public"."template" ALTER COLUMN "result_sharing" SET DEFAULT 'private'::"public"."result_sharing";



ALTER TABLE ONLY "public"."template" ALTER COLUMN "collaborator_emails" SET DEFAULT '{}'::"text"[];



ALTER TABLE ONLY "public"."app_config"
    ADD CONSTRAINT "AppConfig_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."subject_progress"
    ADD CONSTRAINT "participant_progress_pkey" PRIMARY KEY ("completed_at", "subject_id");



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_pkey" PRIMARY KEY ("project_id");



ALTER TABLE ONLY "public"."study_base"
    ADD CONSTRAINT "study_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."study_invite"
    ADD CONSTRAINT "study_invite_code_unique" UNIQUE ("code");



ALTER TABLE ONLY "public"."study_invite"
    ADD CONSTRAINT "study_invite_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."study_base"
    ADD CONSTRAINT "study_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."study"
    ADD CONSTRAINT "study_pkey1" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."template"
    ADD CONSTRAINT "template_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."template"
    ADD CONSTRAINT "template_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");



CREATE OR REPLACE TRIGGER "align_subtrial_status_to_template" AFTER UPDATE OF "status" ON "public"."template" FOR EACH ROW WHEN (("old"."status" IS DISTINCT FROM "new"."status")) EXECUTE FUNCTION "public"."update_sub_trial_status"();



COMMENT ON TRIGGER "align_subtrial_status_to_template" ON "public"."template" IS 'Update the status of sub-trials to match the status of the template';



CREATE OR REPLACE TRIGGER "handle_updated_at" BEFORE UPDATE ON "public"."study" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');



CREATE OR REPLACE TRIGGER "handle_updated_at_template" BEFORE UPDATE ON "public"."template" FOR EACH ROW EXECUTE FUNCTION "extensions"."moddatetime"('updated_at');



CREATE OR REPLACE TRIGGER "status_update_permissions_study" BEFORE UPDATE ON "public"."study" FOR EACH ROW EXECUTE FUNCTION "public"."allow_updating_only_study"('updated_at', 'status', 'registry_published', 'result_sharing');



CREATE OR REPLACE TRIGGER "status_update_permissions_template" BEFORE UPDATE ON "public"."template" FOR EACH ROW EXECUTE FUNCTION "public"."allow_updating_only_study"('updated_at', 'status');



CREATE OR REPLACE TRIGGER "on_auth_user_created" AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION "public"."handle_new_user"();



ALTER TABLE ONLY "public"."subject_progress"
    ADD CONSTRAINT "participant_progress_subjectId_fkey" FOREIGN KEY ("subject_id") REFERENCES "public"."study_subject"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study_base"("id");



ALTER TABLE ONLY "public"."repo"
    ADD CONSTRAINT "repo_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_invite"
    ADD CONSTRAINT "study_invite_studyId_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study_base"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study"
    ADD CONSTRAINT "study_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."template"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_loginCode_fkey" FOREIGN KEY ("invite_code") REFERENCES "public"."study_invite"("code") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_study_id_fkey" FOREIGN KEY ("study_id") REFERENCES "public"."study"("id");



ALTER TABLE ONLY "public"."study_subject"
    ADD CONSTRAINT "study_subject_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");



ALTER TABLE ONLY "public"."study_base"
    ADD CONSTRAINT "study_userId_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id");



ALTER TABLE ONLY "public"."study"
    ADD CONSTRAINT "study_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."template"
    ADD CONSTRAINT "template_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Allow users to manage their own user" ON "public"."user" USING (("auth"."uid"() = "id"));



CREATE POLICY "Config is viewable by everyone" ON "public"."app_config" FOR SELECT USING (true);



CREATE POLICY "Editors can delete their own open-study_base invite codes" ON "public"."study_invite" FOR DELETE USING (( SELECT "public"."can_edit"("auth"."uid"(), "study_base".*) AS "can_edit"
   FROM "public"."study_base"
  WHERE (("study_base"."id" = "study_invite"."study_id") AND ("study_base"."participation" = 'open'::"public"."participation"))));



CREATE POLICY "Editors can do everything with their studies" ON "public"."study" USING ("public"."can_edit"("auth"."uid"(), ("study".*)::"public"."study_base"));



CREATE POLICY "Editors can do everything with their study subjects" ON "public"."study_subject" USING (( SELECT "public"."can_edit"("auth"."uid"(), ("study".*)::"public"."study_base") AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_subject"."study_id")));



CREATE POLICY "Editors can manage their own invite-only study_base invite code" ON "public"."study_invite" USING (( SELECT "public"."can_edit"("auth"."uid"(), "study_base".*) AS "can_edit"
   FROM "public"."study_base"
  WHERE (("study_base"."id" = "study_invite"."study_id") AND ("study_base"."participation" = 'invite'::"public"."participation"))));



CREATE POLICY "Editors can read their own open-study_base invite codes" ON "public"."study_invite" FOR SELECT USING (( SELECT "public"."can_edit"("auth"."uid"(), "study_base".*) AS "can_edit"
   FROM "public"."study_base"
  WHERE (("study_base"."id" = "study_invite"."study_id") AND ("study_base"."participation" = 'open'::"public"."participation"))));



CREATE POLICY "Editors can see subjects from their studies" ON "public"."study_subject" FOR SELECT USING (( SELECT "public"."can_edit"("auth"."uid"(), ("study".*)::"public"."study_base") AS "can_edit"
   FROM "public"."study"
  WHERE ("study"."id" = "study_subject"."study_id")));



CREATE POLICY "Editors can see their study subjects progress" ON "public"."subject_progress" FOR SELECT USING (( SELECT "public"."can_edit"("auth"."uid"(), ("study".*)::"public"."study_base") AS "can_edit"
   FROM "public"."study",
    "public"."study_subject"
  WHERE (("study"."id" = "study_subject"."study_id") AND ("study_subject"."id" = "subject_progress"."subject_id"))));



CREATE POLICY "Editors can view their studies" ON "public"."study" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Enable read access for all users if results are public" ON "public"."study_subject" USING ("public"."has_results_public"("id"));



CREATE POLICY "Enable read access for all users if results are public" ON "public"."subject_progress" USING ("public"."has_results_public"("subject_id"));



CREATE POLICY "Invite code needs to be valid (not possible in the app)" ON "public"."study_subject" AS RESTRICTIVE FOR INSERT WITH CHECK ((("invite_code" IS NULL) OR ("study_id" IN ( SELECT "code_fun"."study_id"
   FROM "public"."get_study_from_invite"("study_subject"."invite_code") "code_fun"("study_id", "preselected_intervention_ids")))));



CREATE POLICY "Joining a closed study should not be possible" ON "public"."study_subject" AS RESTRICTIVE FOR INSERT WITH CHECK ((NOT (EXISTS ( SELECT 1
   FROM "public"."study"
  WHERE (("study"."id" = "study_subject"."study_id") AND ("study"."status" = 'closed'::"public"."study_status"))))));



CREATE POLICY "Repo is viewable by everyone" ON "public"."repo" FOR SELECT USING (true);



CREATE POLICY "Study creators can do everything with repos from their study_ba" ON "public"."repo" USING (("auth"."uid"() = ( SELECT "study_base"."user_id"
   FROM "public"."study_base"
  WHERE ("repo"."study_id" = "study_base"."id"))));



CREATE POLICY "Study subjects can view their joined study" ON "public"."study" FOR SELECT USING ("public"."is_study_subject_of"("auth"."uid"(), "id"));



CREATE POLICY "Study visibility" ON "public"."study" FOR SELECT USING (((("status" = 'running'::"public"."study_status") OR ("status" = 'closed'::"public"."study_status")) AND (("registry_published" = true) OR ("participation" = 'open'::"public"."participation") OR ("result_sharing" = 'public'::"public"."result_sharing"))));



CREATE POLICY "Users can do everything with their progress" ON "public"."subject_progress" USING (("auth"."uid"() = ( SELECT "study_subject"."user_id"
   FROM "public"."study_subject"
  WHERE ("study_subject"."id" = "subject_progress"."subject_id"))));



CREATE POLICY "Users can do everything with their subjects" ON "public"."study_subject" USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."app_config" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "check_locked_template_fields_policy_insert" ON "public"."study" AS RESTRICTIVE FOR INSERT WITH CHECK ("public"."check_locked_template_fields_func"('insert'::"public"."upsert_type", "id", "parent_id", "contact", "participation", "schedule", "result_sharing", "registry_published"));



CREATE POLICY "check_locked_template_fields_policy_update" ON "public"."study" AS RESTRICTIVE FOR UPDATE USING (("parent_id" IS NOT NULL)) WITH CHECK ("public"."check_locked_template_fields_func"('update'::"public"."upsert_type", "id", "parent_id", "contact", "participation", "schedule", "result_sharing", "registry_published"));



CREATE POLICY "editor_view_own_template" ON "public"."template" USING (("auth"."uid"() = "user_id"));



COMMENT ON POLICY "editor_view_own_template" ON "public"."template" IS 'Editors can do everything with their own templates';



CREATE POLICY "prevent_changing_parent_id" ON "public"."study" AS RESTRICTIVE FOR UPDATE USING (("parent_id" IS NOT NULL)) WITH CHECK ("public"."prevent_changing_parent_id_func"("id", "parent_id"));



CREATE POLICY "prevent_creating_sub_trial_check" ON "public"."study" AS RESTRICTIVE FOR INSERT WITH CHECK ("public"."prevent_creating_sub_trial_check_func"("parent_id"));



COMMENT ON POLICY "prevent_creating_sub_trial_check" ON "public"."study" IS 'Prevent creating a new sub-trial for a closed template';



CREATE POLICY "prevent_template_deletion_with_sub_trials" ON "public"."template" AS RESTRICTIVE FOR DELETE USING ("public"."prevent_template_deletion_if_sub_trials_exist"("id"));



COMMENT ON POLICY "prevent_template_deletion_with_sub_trials" ON "public"."template" IS 'Prevent deletion of a template with existing sub-trials';



ALTER TABLE "public"."repo" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_base" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_invite" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."study_subject" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "study_subject_view_template" ON "public"."template" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."study"
  WHERE (("study"."parent_id" = "template"."id") AND "public"."is_study_subject_of"("auth"."uid"(), "study"."id")))));



COMMENT ON POLICY "study_subject_view_template" ON "public"."template" IS 'Study subjects can view the template of the study they are participating in';



ALTER TABLE "public"."subject_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."template" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "template_visibility" ON "public"."template" FOR SELECT USING ((("status" = ANY (ARRAY['running'::"public"."study_status", 'closed'::"public"."study_status"])) AND ("registry_published" OR ("participation" = 'open'::"public"."participation") OR ("result_sharing" = 'public'::"public"."result_sharing"))));



COMMENT ON POLICY "template_visibility" ON "public"."template" IS 'Allow visibility of templates to those that are running or closed and are published to the registry, have open participation, or have public result sharing';



ALTER TABLE "public"."user" ENABLE ROW LEVEL SECURITY;


--CREATE PUBLICATION "logflare_pub" WITH (publish = 'insert, update, delete, truncate');


--ALTER PUBLICATION "logflare_pub" OWNER TO "supabase_admin";




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";





























































































































































































GRANT ALL ON TABLE "public"."study_base" TO "anon";
GRANT ALL ON TABLE "public"."study_base" TO "authenticated";
GRANT ALL ON TABLE "public"."study_base" TO "service_role";



GRANT ALL ON FUNCTION "public"."active_subject_count"("study" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."active_subject_count"("study" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."active_subject_count"("study" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."allow_updating_only_study"() TO "anon";
GRANT ALL ON FUNCTION "public"."allow_updating_only_study"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."allow_updating_only_study"() TO "service_role";



GRANT ALL ON FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."can_edit"("user_id" "uuid", "study_param" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_locked_template_fields_func"("_type" "public"."upsert_type", "_id" "uuid", "_parent_id" "uuid", "_new_contact" "jsonb", "_new_participation" "public"."participation", "_new_schedule" "jsonb", "_new_result_sharing" "public"."result_sharing", "_new_registry_published" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_study_from_invite"("invite_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_study_from_invite"("invite_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_study_from_invite"("invite_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_study_record_from_invite"("invite_code" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_results_public"("psubject_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_results_public"("psubject_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_results_public"("psubject_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."has_study_ended"("psubject_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."has_study_ended"("psubject_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_study_ended"("psubject_id" "uuid") TO "service_role";



GRANT ALL ON TABLE "public"."study_subject" TO "anon";
GRANT ALL ON TABLE "public"."study_subject" TO "authenticated";
GRANT ALL ON TABLE "public"."study_subject" TO "service_role";



GRANT ALL ON FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") TO "anon";
GRANT ALL ON FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_study_ended"("subject" "public"."study_subject") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_active_subject"("psubject_id" "uuid", "days_active" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_study_subject_of"("_user_id" "uuid", "_study_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."last_completed_task"("psubject_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."last_completed_task"("psubject_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."last_completed_task"("psubject_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_changing_parent_id_func"("_id" "uuid", "_parent_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_creating_sub_trial_check_func"("_parent_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_template_deletion_if_sub_trials_exist"("_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_active_days"("study_param" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."study_active_days"("study_param" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_active_days"("study_param" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_ended_count"("study" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."study_ended_count"("study" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_ended_count"("study" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_length"("study_param" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."study_length"("study_param" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_length"("study_param" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_missed_days"("study_param" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."study_missed_days"("study_param" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_missed_days"("study_param" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_participant_count"("study" "public"."study_base") TO "anon";
GRANT ALL ON FUNCTION "public"."study_participant_count"("study" "public"."study_base") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_participant_count"("study" "public"."study_base") TO "service_role";



GRANT ALL ON FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") TO "anon";
GRANT ALL ON FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") TO "authenticated";
GRANT ALL ON FUNCTION "public"."study_total_tasks"("subject" "public"."study_subject") TO "service_role";



GRANT ALL ON FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") TO "anon";
GRANT ALL ON FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") TO "authenticated";
GRANT ALL ON FUNCTION "public"."subject_current_day"("subject" "public"."study_subject") TO "service_role";



GRANT ALL ON FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") TO "anon";
GRANT ALL ON FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") TO "authenticated";
GRANT ALL ON FUNCTION "public"."subject_total_active_days"("subject" "public"."study_subject") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_sub_trial_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_sub_trial_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_sub_trial_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."user_email"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."user_email"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."user_email"("user_id" "uuid") TO "service_role";


















GRANT ALL ON TABLE "public"."app_config" TO "anon";
GRANT ALL ON TABLE "public"."app_config" TO "authenticated";
GRANT ALL ON TABLE "public"."app_config" TO "service_role";



GRANT ALL ON TABLE "public"."repo" TO "anon";
GRANT ALL ON TABLE "public"."repo" TO "authenticated";
GRANT ALL ON TABLE "public"."repo" TO "service_role";



GRANT ALL ON TABLE "public"."study" TO "anon";
GRANT ALL ON TABLE "public"."study" TO "authenticated";
GRANT ALL ON TABLE "public"."study" TO "service_role";



GRANT ALL ON TABLE "public"."template" TO "anon";
GRANT ALL ON TABLE "public"."template" TO "authenticated";
GRANT ALL ON TABLE "public"."template" TO "service_role";



GRANT ALL ON TABLE "public"."study_display_view" TO "anon";
GRANT ALL ON TABLE "public"."study_display_view" TO "authenticated";
GRANT ALL ON TABLE "public"."study_display_view" TO "service_role";



GRANT ALL ON TABLE "public"."study_invite" TO "anon";
GRANT ALL ON TABLE "public"."study_invite" TO "authenticated";
GRANT ALL ON TABLE "public"."study_invite" TO "service_role";



GRANT ALL ON TABLE "public"."subject_progress" TO "anon";
GRANT ALL ON TABLE "public"."subject_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."subject_progress" TO "service_role";



GRANT ALL ON TABLE "public"."study_progress_export" TO "anon";
GRANT ALL ON TABLE "public"."study_progress_export" TO "authenticated";
GRANT ALL ON TABLE "public"."study_progress_export" TO "service_role";



GRANT ALL ON TABLE "public"."user" TO "anon";
GRANT ALL ON TABLE "public"."user" TO "authenticated";
GRANT ALL ON TABLE "public"."user" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;

COMMIT;
