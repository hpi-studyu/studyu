-- TODO move stuff from migrate_tags to here

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


-- ================== EXTENSIONS ===============================

--
-- Name: moddatetime; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS moddatetime WITH SCHEMA extensions;


--
-- Name: EXTENSION moddatetime; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION moddatetime IS 'functions for tracking last modification time';

-- =================== ENUMS ====================================

--
-- Name: git_provider; Type: TYPE; Schema: public; Owner: supabase_admin
--

CREATE TYPE public.git_provider AS ENUM (
    'gitlab'
);


ALTER TYPE public.git_provider OWNER TO supabase_admin;

--
-- Name: participation; Type: TYPE; Schema: public; Owner: supabase_admin
--

CREATE TYPE public.participation AS ENUM (
    'open',
    'invite'
);


ALTER TYPE public.participation OWNER TO supabase_admin;

--
-- Name: result_sharing; Type: TYPE; Schema: public; Owner: supabase_admin
--

CREATE TYPE public.result_sharing AS ENUM (
    'public',
    'private',
    'organization'
);


ALTER TYPE public.result_sharing OWNER TO supabase_admin;


SET default_tablespace = '';

SET default_table_access_method = heap;

-- ==================== TABLES ========================
--
-- Name: study; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.study (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contact jsonb NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    icon_name text NOT NULL,
    published boolean DEFAULT false NOT NULL,
    registry_published boolean DEFAULT false NOT NULL,
    questionnaire jsonb NOT NULL,
    eligibility_criteria jsonb NOT NULL,
    observations jsonb NOT NULL,
    interventions jsonb NOT NULL,
    consent jsonb NOT NULL,
    schedule jsonb NOT NULL,
    report_specification jsonb NOT NULL,
    results jsonb NOT NULL,
    fhir_questionnaire jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    participation public.participation DEFAULT 'invite'::public.participation NOT NULL,
    result_sharing public.result_sharing DEFAULT 'private'::public.result_sharing NOT NULL,
    collaborator_emails text[] DEFAULT '{}'::text[] NOT NULL
);


ALTER TABLE public.study OWNER TO supabase_admin;

--
-- Name: COLUMN study.user_id; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.study.user_id IS 'UserId of study creator';


--
-- Name: study_subject; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.study_subject (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    study_id uuid NOT NULL,
    user_id uuid NOT NULL,
    started_at timestamp with time zone DEFAULT now(),
    selected_intervention_ids text[] NOT NULL,
    invite_code text,
    is_deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.study_subject OWNER TO supabase_admin;

--
-- Name: study_tags; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE study_tag (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    color integer,
    parent_id uuid,
);


ALTER TABLE public.study_tag OWNER TO supabase_admin;

--
-- Name: app_config; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.app_config (
    id text NOT NULL,
    app_privacy jsonb NOT NULL,
    app_terms jsonb NOT NULL,
    designer_privacy jsonb NOT NULL,
    designer_terms jsonb NOT NULL,
    imprint jsonb NOT NULL,
    contact jsonb DEFAULT '{"email": "hpi-info@hpi.de", "phone": "+49-(0)331 5509-0", "website": "https://hpi.de/", "organization": "Hasso Plattner Institute"}'::jsonb NOT NULL,
    analytics jsonb
);


ALTER TABLE public.app_config OWNER TO supabase_admin;

--
-- Name: TABLE app_config; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.app_config IS 'Stores app config for different envs';


--
-- Name: repo; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.repo (
    project_id text NOT NULL,
    user_id uuid NOT NULL,
    study_id uuid NOT NULL,
    provider public.git_provider NOT NULL
);


ALTER TABLE public.repo OWNER TO supabase_admin;

--
-- Name: TABLE repo; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.repo IS 'Git repo where the generated project is stored';


--
-- Name: study_invite; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.study_invite (
    code text NOT NULL,
    study_id uuid NOT NULL,
    preselected_intervention_ids text[]
);


ALTER TABLE public.study_invite OWNER TO supabase_admin;

--
-- Name: TABLE study_invite; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public.study_invite IS 'Study invite codes';


--
-- Name: COLUMN study_invite.preselected_intervention_ids; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON COLUMN public.study_invite.preselected_intervention_ids IS 'Intervention Ids (and order) preselected by study creator';


--
-- Name: subject_progress; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.subject_progress (
    completed_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    subject_id uuid NOT NULL,
    intervention_id text NOT NULL,
    task_id text NOT NULL,
    result_type text NOT NULL,
    result jsonb NOT NULL
);


ALTER TABLE public.subject_progress OWNER TO supabase_admin;

--
-- Name: study_progress_export; Type: VIEW; Schema: public; Owner: supabase_admin
--

CREATE VIEW public.study_progress_export AS
 SELECT subject_progress.completed_at,
    subject_progress.intervention_id,
    subject_progress.task_id,
    subject_progress.result_type,
    subject_progress.result,
    subject_progress.subject_id,
    study_subject.user_id,
    study_subject.study_id,
    study_subject.started_at,
    study_subject.selected_intervention_ids
   FROM public.study_subject,
    public.subject_progress
  WHERE (study_subject.id = subject_progress.subject_id);


ALTER TABLE public.study_progress_export OWNER TO supabase_admin;

--
-- Name: user; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."user" (
    id uuid NOT NULL,
    email text,
    preferences jsonb,
);


ALTER TABLE public."user" OWNER TO supabase_admin;

--
-- Name: TABLE "user"; Type: COMMENT; Schema: public; Owner: supabase_admin
--

COMMENT ON TABLE public."user" IS 'Users get automatically added, when a new user is created in auth.users';


-- ======================== PRIMARY KEY CONSTRAINT ================================
--
-- Name: app_config AppConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.app_config
    ADD CONSTRAINT "AppConfig_pkey" PRIMARY KEY (id);


--
-- Name: subject_progress participant_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.subject_progress
    ADD CONSTRAINT participant_progress_pkey PRIMARY KEY (completed_at, subject_id);


--
-- Name: repo repo_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.repo
    ADD CONSTRAINT repo_pkey PRIMARY KEY (project_id);


--
-- Name: study_invite study_invite_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_invite
    ADD CONSTRAINT study_invite_pkey PRIMARY KEY (code);


--
-- Name: study study_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study
    ADD CONSTRAINT study_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: study_subject study_subject_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_subject
    ADD CONSTRAINT study_subject_pkey PRIMARY KEY (id);


--
-- Name: study_tag study_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT study_tag_pkey PRIMARY KEY (id);

-- ======================== FOREIGN KEY CONTRAINTS ======================================================

--
-- Name: subject_progress participant_progress_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.subject_progress
    ADD CONSTRAINT "participant_progress_subjectId_fkey" FOREIGN KEY (subject_id) REFERENCES public.study_subject(id) ON DELETE CASCADE;


--
-- Name: repo repo_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.repo
    ADD CONSTRAINT "repo_studyId_fkey" FOREIGN KEY (study_id) REFERENCES public.study(id);


--
-- Name: repo repo_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.repo
    ADD CONSTRAINT "repo_userId_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: study_invite study_invite_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_invite
    ADD CONSTRAINT "study_invite_studyId_fkey" FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;


--
-- Name: study_subject study_subject_loginCode_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_subject
    ADD CONSTRAINT "study_subject_loginCode_fkey" FOREIGN KEY (invite_code) REFERENCES public.study_invite(code) ON DELETE CASCADE;


--
-- Name: study_subject study_subject_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_subject
    ADD CONSTRAINT "study_subject_studyId_fkey" FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;


--
-- Name: study_tag study_tag_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT "study_tag_parentId_fkey" FOREIGN KEY (parent_id) REFERENCES public.study_tag(id) ON DELETE CASCADE;


--
-- Name: study_subject study_subject_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_subject
    ADD CONSTRAINT "study_subject_userId_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: study study_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study
    ADD CONSTRAINT "study_userId_fkey" FOREIGN KEY (user_id) REFERENCES public."user"(id);


-- ======================== STUDY FUNCTIONS =====================================

--
-- Name: is_active_subject(uuid, integer); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_active_subject(psubject_id uuid, days_active integer) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN (
    SELECT
      (DATE(now()) - last_completed_task (psubject_id)) <= days_active);
END;
$$;


ALTER FUNCTION public.is_active_subject(psubject_id uuid, days_active integer) OWNER TO supabase_admin;

--
-- Name: active_subject_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.active_subject_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
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


ALTER FUNCTION public.active_subject_count(study public.study) OWNER TO supabase_admin;

--
-- Name: user_email(uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.user_email(user_id uuid) RETURNS text
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT email from "user" where id = user_id
$$;

ALTER FUNCTION public.user_email(user_id uuid) OWNER TO supabase_admin;

--
-- Name: can_edit(uuid, public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.can_edit(user_id uuid, study_param public.study) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select study_param.user_id = user_id OR user_email(user_id) = ANY (study_param.collaborator_emails);
$$;


ALTER FUNCTION public.can_edit(user_id uuid, study_param public.study) OWNER TO supabase_admin;

--
-- Name: is_subject_of(uuid, public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid) RETURNS boolean
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM study_subject
    WHERE study_subject.user_id = _user_id AND study_subject.study_id = _study_id
  )
$$;


ALTER FUNCTION public.is_study_subject_of(_user_id uuid, _study_id uuid) OWNER TO supabase_admin;

--
-- Name: get_study_from_invite(text); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_study_from_invite(invite_code text) RETURNS TABLE(study_id uuid, preselected_intervention_ids text[])
    LANGUAGE sql IMMUTABLE SECURITY DEFINER
    AS $$
   select study_invite.study_id, study_invite.preselected_intervention_ids
   from study_invite
   where invite_code = study_invite.code;
$$;


ALTER FUNCTION public.get_study_from_invite(invite_code text) OWNER TO supabase_admin;

--
-- Name: get_study_record_from_invite(text); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.get_study_record_from_invite(invite_code text) RETURNS public.study
    LANGUAGE sql IMMUTABLE SECURITY DEFINER AS $$
    SELECT * FROM study WHERE study.id = (
        SELECT study_invite.study_id
        FROM study_invite
        WHERE invite_code = study_invite.code
   );
$$;


ALTER FUNCTION public.get_study_record_from_invite(invite_code text) OWNER TO supabase_admin;

--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into public.user (id, email)
  values (new.id, new.email);
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO supabase_admin;

--
-- Name: has_study_ended(uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_study_ended(psubject_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.has_study_ended(psubject_id uuid) OWNER TO supabase_admin;

--
-- Name: has_study_ended(public.study_subject); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.has_study_ended(subject public.study_subject) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.has_study_ended(subject public.study_subject) OWNER TO supabase_admin;

--
-- Name: last_completed_task(uuid); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.last_completed_task(psubject_id uuid) RETURNS date
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.last_completed_task(psubject_id uuid) OWNER TO supabase_admin;

--
-- Name: subject_total_active_days(public.study_subject); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.subject_total_active_days(subject public.study_subject) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT
    COUNT(DISTINCT DATE(completed_at))::int
FROM
    subject_progress
WHERE subject_id = subject.id
AND DATE(completed_at) < DATE(now());
$$;


ALTER FUNCTION public.subject_total_active_days(subject public.study_subject) OWNER TO supabase_admin;

--
-- Name: study_active_days(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_active_days(study_param public.study) RETURNS integer[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select ARRAY_AGG(subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id;
$$;


ALTER FUNCTION public.study_active_days(study_param public.study) OWNER TO supabase_admin;

--
-- Name: study_ended_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_ended_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
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


ALTER FUNCTION public.study_ended_count(study public.study) OWNER TO supabase_admin;

--
-- Name: study_length(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_length(study_param public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
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


ALTER FUNCTION public.study_length(study_param public.study) OWNER TO supabase_admin;

--
-- Name: subject_current_day(public.study_subject); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.subject_current_day(subject public.study_subject) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT
    CASE WHEN has_study_ended(subject) THEN (Select study_length(study) from study where id = subject.study_id)::int
    ELSE
        DATE(now()) - DATE(subject.started_at)
    END;
$$;


ALTER FUNCTION public.subject_current_day(subject public.study_subject) OWNER TO supabase_admin;

--
-- Name: study_missed_days(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_missed_days(study_param public.study) RETURNS integer[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select ARRAY_AGG(subject_current_day(study_subject) - subject_total_active_days(study_subject)) from study_subject
where study_subject.study_id = study_param.id and study_subject.is_deleted = false;
$$;


ALTER FUNCTION public.study_missed_days(study_param public.study) OWNER TO supabase_admin;

--
-- Name: study_participant_count(public.study); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_participant_count(study public.study) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select count(1)::int
    from study_subject
    where study_id = study.id
      and study_subject.is_deleted = false;
$$;


ALTER FUNCTION public.study_participant_count(study public.study) OWNER TO supabase_admin;

--
-- Name: study_total_tasks(public.study_subject); Type: FUNCTION; Schema: public; Owner: supabase_admin
--

CREATE FUNCTION public.study_total_tasks(subject public.study_subject) RETURNS integer
    LANGUAGE sql SECURITY DEFINER
    AS $$
  select count(1)::int
    from subject_progress
    where subject_id = subject.id;
$$;


ALTER FUNCTION public.study_total_tasks(subject public.study_subject) OWNER TO supabase_admin;

-- ========================= TRIGGERS ==========================================

--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: postgres
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- Name: study handle_updated_at; Type: TRIGGER; Schema: public; Owner: supabase_admin
--

CREATE TRIGGER handle_updated_at BEFORE UPDATE ON public.study FOR EACH ROW EXECUTE FUNCTION extensions.moddatetime('updated_at');


-- ============================ ROW LEVEL SECURITY POLICIES ======================================

--
-- Name: app_config Config is viewable by everyone; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Config is viewable by everyone" ON public.app_config FOR SELECT USING (true);


--
-- Name: study_invite Editors can do everything with study invite codes; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Editors can do everything with study invite codes" ON public.study_invite USING (( SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study
  WHERE (study.id = study_invite.study_id)));


--
-- Name: study Editors can do everything with their studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Editors can do everything with their studies" ON public.study USING (public.can_edit(auth.uid(), study.*));


--
-- Name: study_subject Editors can do everything with their study subjects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Editors can do everything with their study subjects" ON public.study_subject AS PERMISSIVE FOR ALL
TO public USING (( SELECT public.can_edit(auth.uid(), study) AS can_edit FROM public.study WHERE (study.id = study_subject.study_id)));


--
-- Name: study_subject Editors can see subjects from their studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Editors can see subjects from their studies" ON public.study_subject FOR SELECT USING (( SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study
  WHERE (study.id = study_subject.study_id)));


--
-- Name: subject_progress Editors can see their study subjects progress; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Editors can see their study subjects progress" ON public.subject_progress FOR SELECT USING (( SELECT public.can_edit(auth.uid(), study.*) AS can_edit
   FROM public.study,
    public.study_subject
  WHERE ((study.id = study_subject.study_id) AND (study_subject.id = subject_progress.subject_id))));


--
-- Name: study Everybody can view (published and open) studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Everybody can view (published and open) studies" ON public.study FOR SELECT USING ((published = true) AND (participation = 'open'::public.participation));


--
-- Name: study Study subjects can view their joined study; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Study subjects can view their joined study" ON public.study FOR SELECT USING (public.is_study_subject_of(auth.uid(), id));

--
-- Name: study_subject Invite code needs to be valid (not possible in the app); Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Invite code needs to be valid (not possible in the app)" ON public.study_subject AS RESTRICTIVE FOR INSERT WITH CHECK (((invite_code IS NULL) OR (study_id IN ( SELECT code_fun.study_id
   FROM public.get_study_from_invite(study_subject.invite_code) code_fun(study_id, preselected_intervention_ids)))));


--
-- Name: repo Repo is viewable by everyone; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Repo is viewable by everyone" ON public.repo FOR SELECT USING (true);


--
-- Name: repo Study creators can do everything with repos from their studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Study creators can do everything with repos from their studies" ON public.repo USING ((auth.uid() = ( SELECT study.user_id
   FROM public.study
  WHERE (repo.study_id = study.id))));


--
-- Name: subject_progress Users can do everything with their progress; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can do everything with their progress" ON public.subject_progress USING ((auth.uid() = ( SELECT study_subject.user_id
   FROM public.study_subject
  WHERE (study_subject.id = subject_progress.subject_id))));


--
-- Name: study_subject Users can do everything with their subjects; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can do everything with their subjects" ON public.study_subject USING ((auth.uid() = user_id));


--
-- Name: study_tag Allow read access but deny write access for tags; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY allow_read_deny_write_tag ON study_tag FOR ALL
USING (true) WITH CHECK (false);


--
-- Name: user Users can do everything with their user data; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Users can read and write their user data" ON public."user" USING ((auth.uid() = id));

--
-- Name: app_config; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

--
-- Name: repo; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.repo ENABLE ROW LEVEL SECURITY;

--
-- Name: study; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study ENABLE ROW LEVEL SECURITY;

--
-- Name: study_invite; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_invite ENABLE ROW LEVEL SECURITY;

--
-- Name: study_subject; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_subject ENABLE ROW LEVEL SECURITY;

--
-- Name: study_tag; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_tag ENABLE ROW LEVEL SECURITY;


--
-- Name: subject_progress; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.subject_progress ENABLE ROW LEVEL SECURITY;

--
-- Name: user; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public."user" ENABLE ROW LEVEL SECURITY;
