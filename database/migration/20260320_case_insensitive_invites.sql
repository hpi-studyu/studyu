-- ============================================================================
-- OVERVIEW:
-- This migration updates the get_study_record_from_invite RPC function
-- to perform case-insensitive and space-trimmed matching of invite codes.
-- 
-- WHY:
-- Mobile keyboards frequently auto-capitalize the first letter of manual text
-- inputs, and email clients often modify deep links. A strict binary equality
-- check fails on these user cases. This migration enforces lowercase matching.
-- ============================================================================

CREATE OR REPLACE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS public.study
LANGUAGE sql SECURITY DEFINER
SET search_path = ''
STABLE
AS $$
  SELECT * FROM public.study
  WHERE study.id = (
    SELECT study_invite.study_id
    FROM public.study_invite
    WHERE lower(invite_code) = lower(study_invite.code)
  );
$$;
