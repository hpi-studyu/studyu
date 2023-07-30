--
-- Name: tag; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.tag (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    color text,
    parent_id uuid
    -- rename result_sharing to visibility
    --visibility public.result_sharing NOT NULL DEFAULT 'private'::public.result_sharing,
);

ALTER TABLE public.tag OWNER TO supabase_admin;


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: study_tag; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public.study_tag (
    study_id uuid NOT NULL,
    tag_id uuid NOT NULL
);

ALTER TABLE public.study_tag OWNER TO supabase_admin;


--
-- Name: study_tag study_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT "study_tag_pkey" PRIMARY KEY (study_id, tag_id);


--
-- Name: tag tag_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT "tag_parentId_fkey" FOREIGN KEY (parent_id) REFERENCES public.tag(id) ON DELETE CASCADE;


--
-- Name: tag study_tag_studyId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT "study_tag_studyId_fkey" FOREIGN KEY (study_id) REFERENCES public.study(id) ON DELETE CASCADE;


--
-- Name: tag study_tag_tagId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT "study_tag_tagId_fkey" FOREIGN KEY (tag_id) REFERENCES public.tag(id) ON DELETE CASCADE;


-- TODO VERIFY all policies regarding anonymous select, update, insert, delete and authenticated behavior regarding auth.uid()

--
-- Name: study_tag Allow read access but deny write access for tags; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow read access, deny write access"
  ON public.tag
  FOR SELECT
  USING (true);


--
-- Name: Allow study creators to manage tags; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow study creators to manage tags"
  ON public.study_tag
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM study
      WHERE study.id = study_tag.study_id
        AND study.user_id = auth.uid()
    )
  );


--
-- Name: Allow subscribed users to select study tags; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow subscribed users to select study tags"
  ON public.study_tag
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM public.study_subject
      WHERE study_subject.study_id = study_tag.study_id
        AND study_subject.user_id = auth.uid()
    )
  );


-- todo deny insert, delete, update for everyone else
-- todo deny select for everyone except study creators and users subscribed to the study


--
-- Name: tag; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.tag ENABLE ROW LEVEL SECURITY;

--
-- Name: study_tag; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_tag ENABLE ROW LEVEL SECURITY;
