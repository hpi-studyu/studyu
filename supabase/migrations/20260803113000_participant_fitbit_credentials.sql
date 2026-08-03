BEGIN;

CREATE TABLE IF NOT EXISTS public.participant_fitbit_credentials (
    user_id uuid NOT NULL REFERENCES public."user" (id) ON DELETE CASCADE,
    study_id uuid NOT NULL REFERENCES public.study (id) ON DELETE CASCADE,
    fitbit_credentials jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, study_id)
);

ALTER TABLE public.participant_fitbit_credentials OWNER TO postgres;

COMMENT ON TABLE public.participant_fitbit_credentials IS
'Participant Fitbit OAuth credentials, scoped to authenticated user and study.';

ALTER TABLE public.participant_fitbit_credentials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Participants can manage their own Fitbit credentials"
ON public.participant_fitbit_credentials
TO authenticated
USING ((SELECT auth.uid() AS uid) = user_id)
WITH CHECK ((SELECT auth.uid() AS uid) = user_id);

GRANT SELECT, INSERT, UPDATE, DELETE
ON TABLE public.participant_fitbit_credentials
TO authenticated, service_role;

COMMIT;
