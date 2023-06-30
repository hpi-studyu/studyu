ALTER TABLE public."user" ADD COLUMN preferences jsonb;


--
-- Name: Allow users to select their own user row; Type: POLICY; Schema: public; Owner: supabase_admin
--

CREATE POLICY "Allow users to read their own user row"
ON public."user"
FOR SELECT USING (
  auth.uid() = id
);
