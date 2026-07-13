BEGIN;

CREATE OR REPLACE FUNCTION public.get_study_invites_filtered(
  p_study_id uuid,
  p_query text DEFAULT NULL,
  p_enrolled_status text DEFAULT NULL,
  p_enrolled_min integer DEFAULT NULL,
  p_enrolled_max integer DEFAULT NULL,
  p_intervention_filter text DEFAULT NULL,
  p_created_from date DEFAULT NULL,
  p_created_to date DEFAULT NULL,
  p_updated_from date DEFAULT NULL,
  p_updated_to date DEFAULT NULL
)
RETURNS TABLE (
  code text,
  study_id uuid,
  preselected_intervention_ids text[],
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  study_invite_participant_count integer
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  WITH invites AS (
    SELECT
      si.code,
      si.study_id,
      si.preselected_intervention_ids,
      si.created_at,
      si.updated_at,
      public.study_invite_participant_count(si) AS study_invite_participant_count
    FROM public.study_invite AS si
    WHERE si.study_id = p_study_id
  )
  SELECT *
  FROM invites
  WHERE
    (p_query IS NULL OR invites.code ILIKE '%' || p_query || '%')
    AND (
      p_enrolled_status IS NULL
      OR (p_enrolled_status = 'unused' AND invites.study_invite_participant_count = 0)
      OR (p_enrolled_status = 'used' AND invites.study_invite_participant_count > 0)
    )
    AND (
      p_enrolled_min IS NULL
      OR invites.study_invite_participant_count >= p_enrolled_min
    )
    AND (
      p_enrolled_max IS NULL
      OR invites.study_invite_participant_count <= p_enrolled_max
    )
    AND (
      p_intervention_filter IS NULL
      OR (
        p_intervention_filter = 'default'
        AND COALESCE(array_length(invites.preselected_intervention_ids, 1), 0) = 0
      )
      OR (
        p_intervention_filter = 'intervention_a'
        AND COALESCE(array_length(invites.preselected_intervention_ids, 1), 0) >= 1
      )
      OR (
        p_intervention_filter = 'intervention_b'
        AND COALESCE(array_length(invites.preselected_intervention_ids, 1), 0) >= 2
      )
    )
    AND (p_created_from IS NULL OR invites.created_at::date >= p_created_from)
    AND (p_created_to IS NULL OR invites.created_at::date <= p_created_to)
    AND (p_updated_from IS NULL OR invites.updated_at::date >= p_updated_from)
    AND (p_updated_to IS NULL OR invites.updated_at::date <= p_updated_to);
$$;

CREATE OR REPLACE FUNCTION public.fetch_study_invites_filtered(
  p_study_id uuid,
  p_offset integer,
  p_limit integer,
  p_query text DEFAULT NULL,
  p_sort_by text DEFAULT 'created_at',
  p_ascending boolean DEFAULT false,
  p_enrolled_status text DEFAULT NULL,
  p_enrolled_min integer DEFAULT NULL,
  p_enrolled_max integer DEFAULT NULL,
  p_intervention_filter text DEFAULT NULL,
  p_created_from date DEFAULT NULL,
  p_created_to date DEFAULT NULL,
  p_updated_from date DEFAULT NULL,
  p_updated_to date DEFAULT NULL
)
RETURNS TABLE (
  code text,
  study_id uuid,
  preselected_intervention_ids text[],
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  study_invite_participant_count integer
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT *
  FROM public.get_study_invites_filtered(
    p_study_id,
    p_query,
    p_enrolled_status,
    p_enrolled_min,
    p_enrolled_max,
    p_intervention_filter,
    p_created_from,
    p_created_to,
    p_updated_from,
    p_updated_to
  )
  ORDER BY
    CASE WHEN p_sort_by = 'code' AND p_ascending THEN code END ASC,
    CASE WHEN p_sort_by = 'code' AND NOT p_ascending THEN code END DESC,
    CASE
      WHEN p_sort_by = 'enrolled' AND p_ascending
      THEN study_invite_participant_count
    END ASC,
    CASE
      WHEN p_sort_by = 'enrolled' AND NOT p_ascending
      THEN study_invite_participant_count
    END DESC,
    CASE WHEN p_sort_by = 'created_at' AND p_ascending THEN created_at END ASC,
    CASE WHEN p_sort_by = 'created_at' AND NOT p_ascending THEN created_at END DESC,
    CASE WHEN p_sort_by = 'updated_at' AND p_ascending THEN updated_at END ASC,
    CASE WHEN p_sort_by = 'updated_at' AND NOT p_ascending THEN updated_at END DESC,
    code ASC
  OFFSET p_offset
  LIMIT p_limit;
$$;

CREATE OR REPLACE FUNCTION public.count_study_invites_filtered(
  p_study_id uuid,
  p_query text DEFAULT NULL,
  p_enrolled_status text DEFAULT NULL,
  p_enrolled_min integer DEFAULT NULL,
  p_enrolled_max integer DEFAULT NULL,
  p_intervention_filter text DEFAULT NULL,
  p_created_from date DEFAULT NULL,
  p_created_to date DEFAULT NULL,
  p_updated_from date DEFAULT NULL,
  p_updated_to date DEFAULT NULL
)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT count(1)::int
  FROM public.get_study_invites_filtered(
    p_study_id,
    p_query,
    p_enrolled_status,
    p_enrolled_min,
    p_enrolled_max,
    p_intervention_filter,
    p_created_from,
    p_created_to,
    p_updated_from,
    p_updated_to
  );
$$;

REVOKE EXECUTE ON FUNCTION public.get_study_invites_filtered(
  uuid, text, text, integer, integer, text, date, date, date, date
) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.fetch_study_invites_filtered(
  uuid, integer, integer, text, text, boolean, text, integer, integer, text, date, date, date, date
) FROM public, anon;
REVOKE EXECUTE ON FUNCTION public.count_study_invites_filtered(
  uuid, text, text, integer, integer, text, date, date, date, date
) FROM public, anon;

GRANT EXECUTE ON FUNCTION public.get_study_invites_filtered(
  uuid, text, text, integer, integer, text, date, date, date, date
) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fetch_study_invites_filtered(
  uuid, integer, integer, text, text, boolean, text, integer, integer, text, date, date, date, date
) TO authenticated;
GRANT EXECUTE ON FUNCTION public.count_study_invites_filtered(
  uuid, text, text, integer, integer, text, date, date, date, date
) TO authenticated;

COMMIT;
