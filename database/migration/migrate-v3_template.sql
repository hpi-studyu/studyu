ALTER TABLE public.study
    ADD COLUMN parent_template_id uuid;

ALTER TABLE public.study
    ADD COLUMN template_configuration jsonb;

ALTER TABLE ONLY public.study
    ADD CONSTRAINT "study_parent_template_id_fkey" FOREIGN KEY (parent_template_id) REFERENCES public.study(id);