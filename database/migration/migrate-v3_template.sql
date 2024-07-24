ALTER TABLE public.study
    ADD COLUMN parent_template_id uuid;

ALTER TABLE public.study
    ADD COLUMN template_configuration jsonb;

ALTER TABLE ONLY public.study
    ADD CONSTRAINT "study_parent_template_id_fkey" FOREIGN KEY (parent_template_id) REFERENCES public.study(id);

CREATE POLICY "Joining a Template Trial should not be possible" ON public.study_subject
    AS RESTRICTIVE
    FOR INSERT
    WITH CHECK (NOT EXISTS (
    SELECT 1
    FROM public.study
    WHERE study.id = study_subject.study_id
      AND study.template_configuration IS NOT NULL
      AND study.parent_template_id IS NULL
));
