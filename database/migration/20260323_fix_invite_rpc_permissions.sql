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
