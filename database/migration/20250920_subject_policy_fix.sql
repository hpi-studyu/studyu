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

REVOKE EXECUTE ON FUNCTION public.has_results_public(uuid) FROM PUBLIC;

-- todo check if without this migration user has all crud operations on these tables
-- todo check if with this migration user has only read access on these tables if results are public
-- todo move this migration to studyu-schema file if everything is ok