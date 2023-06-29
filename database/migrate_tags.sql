--
-- Name: study_tags; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE study_tag (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    color integer,
    parent_id uuid
);

ALTER TABLE public.study_tag OWNER TO supabase_admin;


--
-- Name: study_tag study_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT study_tag_pkey PRIMARY KEY (id);


--
-- Name: study_tag study_tag_parentId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public.study_tag
    ADD CONSTRAINT "study_tag_parentId_fkey" FOREIGN KEY (parent_id) REFERENCES public.study_tag(id) ON DELETE CASCADE;


--
-- Add 'tags' field to 'study' table
--

ALTER TABLE public.study
ADD COLUMN tags jsonb;


--
-- Name: study_tag Allow read access but deny write access for tags; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY allow_read_deny_write_tag ON study_tag FOR ALL
USING (true) WITH CHECK (false);


--
-- Name: study_tag; Type: ROW SECURITY; Schema: public; Owner: supabase_admin
--

ALTER TABLE public.study_tag ENABLE ROW LEVEL SECURITY;
