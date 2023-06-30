--
-- Name: tag; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE tag (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    color integer,
    parent_id uuid,
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

CREATE TABLE study_tag (
    study_id uuid REFERENCES study (id) ON DELETE CASCADE,
    tag_id uuid REFERENCES tag (id) ON DELETE CASCADE,

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
-- Name: tag Allow read access but deny write access for tag; Type: POLICY; Schema: public; Owner: supabase_admin
--
-- TODO VERIFY all policies regarding anonymous select, update, insert, delete and authenticated behavior regarding auth.uid()

create policy "Allow read access, deny write access"
  on tag
  for select
  using (true);
  -- with check (false);


--
-- Name: study_tag Allow only study creators to add tags to studies; Type: POLICY; Schema: public; Owner: supabase_admin
--

create policy "Allow study creators to add delete tags"
  on study_tag
  for insert, delete
   USING (
      TRUE
    )
  with check (exists (
    select *
    from study
    where study.id = id
      and study.user_id = auth.uid()
  ));

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
