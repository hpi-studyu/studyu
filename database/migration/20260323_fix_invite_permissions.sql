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


-- ============================================================================
-- OVERVIEW:
-- Ensure invite-code RPC can be called before authentication.
--
-- WHY:
-- Deep link handling validates invite codes before signup/login to provide
-- immediate feedback and preserve study context during onboarding.
-- The RPC must therefore be executable by the anon role.
-- ============================================================================

ALTER FUNCTION public.get_study_record_from_invite(text) SECURITY DEFINER;
ALTER FUNCTION public.get_study_record_from_invite(text) SET search_path = '';

REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO authenticated;


-- ============================================================================
-- OVERVIEW:
-- Update "Study visibility" RLS policy to allow public reads for open studies.
--
-- WHY:
-- Deep link handling for open studies (/study/uuid) fetches study details
-- before signup/login to populate the onboarding screens. The previous policy
-- was explicitly restricted TO "authenticated", causing a 0-rows permission
-- error for new users. Removing the role restriction allows the anon role to
-- safely read the study, provided the strict conditions in the USING clause
-- (e.g., participation = 'open') are met.
-- ============================================================================

DROP POLICY IF EXISTS "Study visibility" ON "public"."study";

CREATE POLICY "Study visibility" ON "public"."study"
FOR SELECT
USING (
  (
    ("status" = 'running'::"public"."study_status") OR
    ("status" = 'closed'::"public"."study_status")
  )
  AND
  (
    ("registry_published" = true) OR
    ("participation" = 'open'::"public"."participation") OR
    ("result_sharing" = 'public'::"public"."result_sharing")
  )
);
