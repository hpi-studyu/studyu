BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'study_invite_study_id_code_unique'
      AND conrelid = 'public.study_invite'::regclass
  ) THEN
    ALTER TABLE public.study_invite
      ADD CONSTRAINT study_invite_study_id_code_unique UNIQUE (study_id, code);
  END IF;
END $$;

ALTER TABLE public.study_subject
  DROP CONSTRAINT IF EXISTS "study_subject_loginCode_fkey";

ALTER TABLE public.study_subject
  DROP CONSTRAINT IF EXISTS study_subject_study_invite_fkey;

ALTER TABLE public.study_subject
  ADD CONSTRAINT study_subject_study_invite_fkey
  FOREIGN KEY (study_id, invite_code)
  REFERENCES public.study_invite(study_id, code)
  ON DELETE CASCADE;

CREATE OR REPLACE FUNCTION public.is_invite_code_for_study(
  study_id uuid,
  invite_code text
)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.study_invite
    WHERE study_invite.study_id = is_invite_code_for_study.study_id
      AND study_invite.code = is_invite_code_for_study.invite_code
  );
$$;

DROP POLICY IF EXISTS "Invite code must match study_id" ON public.study_subject;

CREATE POLICY "Invite code must match study_id"
ON public.study_subject
AS RESTRICTIVE
FOR INSERT
TO authenticated
WITH CHECK (
  invite_code IS NULL
  OR public.is_invite_code_for_study(study_id, invite_code)
);

REVOKE EXECUTE ON FUNCTION public.is_invite_code_for_study(uuid, text)
FROM public, anon;

COMMIT;
