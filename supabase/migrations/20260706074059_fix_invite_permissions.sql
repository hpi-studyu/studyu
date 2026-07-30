BEGIN;

-- ============================================================================
-- Migration: Fix invite and public study deep-link permissions
-- Date: July 6, 2026
-- ============================================================================
--
-- OVERVIEW:
-- Allow unauthenticated deep-link validation for invite codes and public study
-- links. The app needs to resolve invite links and open-study links before the
-- participant has signed in or completed onboarding.
--
-- Additionally, get_study_record_from_invite now returns only the participant-
-- facing study payload plus the invite's preselected_intervention_ids, so the
-- app can resolve an invite (including its preselected interventions) in a
-- single RPC. Anon deep-link callers cannot SELECT study_invite (RLS blocks
-- non-editors), so the preselected ids must come from this SECURITY DEFINER
-- function rather than a second client query. Draft studies remain resolvable
-- by invite code so researchers can test them before publishing.
-- ============================================================================

-- The return type changes from public.study to jsonb, so CREATE OR REPLACE
-- is rejected (SQLSTATE 42P13: cannot change return type of existing
-- function). Drop the dependent INSERT policy first (it references the
-- function), then DROP the function itself, then recreate with jsonb.
DROP POLICY IF EXISTS "Invite code must match study_id" ON public.study_subject;

DROP FUNCTION IF EXISTS public.get_study_record_from_invite(text);

-- Normalize invite-code lookup so mobile keyboard capitalization and copied
-- whitespace do not make otherwise valid invite links fail. Returns the study
-- fields needed by the participant app plus the matched invite's
-- preselected_intervention_ids as a single jsonb object, or NULL when the code
-- matches no invite.
CREATE FUNCTION public.get_study_record_from_invite(invite_code text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT jsonb_build_object(
    'id', s.id,
    -- Study.fromJson requires user_id, but invite callers do not need the
    -- owner UUID. Return a neutral UUID instead of leaking editor identity.
    'user_id', '00000000-0000-0000-0000-000000000000',
    'title', s.title,
    'description', s.description,
    'participation', s.participation,
    'result_sharing', s.result_sharing,
    'contact', s.contact,
    'icon_name', s.icon_name,
    'published', s.published,
    'status', s.status,
    'questionnaire', s.questionnaire,
    'eligibility_criteria', s.eligibility_criteria,
    'consent', s.consent,
    'interventions', s.interventions,
    'observations', s.observations,
    'schedule', s.schedule,
    'report_specification', s.report_specification,
    'results', s.results,
    -- Editor emails are not participant-facing invite data.
    'collaborator_emails', '[]'::jsonb,
    'registry_published', s.registry_published,
    'preselected_intervention_ids', si.preselected_intervention_ids
  )
  FROM public.study s
  JOIN public.study_invite si ON si.study_id = s.id
  WHERE lower(trim(invite_code)) = lower(trim(si.code));
$$;

-- Deep-link validation calls this RPC before authentication. Keep PUBLIC
-- revoked, then grant only the roles that need the API surface.
REVOKE EXECUTE ON FUNCTION public.get_study_record_from_invite(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO authenticated;

-- The restrictive study_subject INSERT policy validates the invite code by
-- looking up the study it belongs to. With the function now returning jsonb,
-- access the id via the jsonb text operator and cast to uuid.
CREATE POLICY "Invite code must match study_id" ON public.study_subject
AS RESTRICTIVE FOR INSERT TO "authenticated"
WITH CHECK (
  (invite_code IS NULL)
  OR (study_id IN (
    SELECT (public.get_study_record_from_invite(study_subject.invite_code) ->> 'id')::uuid
  ))
);


-- Public /study/<id> deep links need anonymous SELECT access for open studies.
-- RLS still limits rows to running/closed studies with public visibility.
DROP POLICY IF EXISTS "Study visibility" ON public.study;

CREATE POLICY "Study visibility" ON public.study
FOR SELECT
USING (
  (
    status = 'running'::public.study_status
    OR status = 'closed'::public.study_status
  )
  AND (
    registry_published = true
    OR participation = 'open'::public.participation
    OR result_sharing = 'public'::public.result_sharing
  )
);

COMMIT;
