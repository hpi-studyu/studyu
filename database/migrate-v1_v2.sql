-- ==================== TABLES ========================

--
-- Name: study_progress_export; Type: VIEW; Schema: public; Owner: supabase_admin
--

DROP VIEW IF EXISTS public.study_progress;
DROP VIEW IF EXISTS public.study_progress_export;

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


--
-- Name: study; Type: VIEW; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study
  ADD IF NOT EXISTS registry_published boolean DEFAULT false NOT NULL;

UPDATE public.study
    SET registry_published = true
    WHERE result_sharing = 'public';

-- ============================ ROW LEVEL SECURITY POLICIES ======================================

--
-- Name: study_subject Editors can do everything with their study subjects; Type: POLICY; Schema: public; Owner: supabase_admin
--

DROP POLICY IF EXISTS "Editors can do everything with their study subjects" ON public.study_subject;

CREATE POLICY "Editors can do everything with their study subjects"
ON public.study_subject
AS PERMISSIVE FOR ALL
TO public
USING (( SELECT can_edit(uid(), study.*) AS can_edit FROM study WHERE (study.id = study_subject.study_id)));


-- ======================== FOREIGN KEY CONTRAINTS ======================================================

--
-- Name: subject_progress participant_progress_subjectId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.subject_progress
DROP CONSTRAINT IF EXISTS "participant_progress_subjectId_fkey",
ADD CONSTRAINT "participant_progress_subjectId_fkey"
FOREIGN KEY (subject_id)
REFERENCES public.study_subject(id)
ON DELETE CASCADE;
