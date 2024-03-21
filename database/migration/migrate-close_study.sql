ALTER TYPE public.participation ADD VALUE 'closed';

CREATE POLICY "Joining a closed study should not be possible" ON public.study_subject
    AS RESTRICTIVE
    FOR INSERT
    WITH CHECK (NOT EXISTS (
    SELECT 1
    FROM public.study
    WHERE study.id = study_subject.study_id
      AND study.participation = 'closed'
));