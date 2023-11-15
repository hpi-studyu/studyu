ALTER TABLE public.study
    ADD COLUMN parent_template uuid;

ALTER TABLE public.study
    ADD COLUMN template_configuration jsonb;

ALTER TABLE ONLY public.study
    ADD CONSTRAINT "study_parent_template_fkey" FOREIGN KEY (parent_template) REFERENCES public.study(id);