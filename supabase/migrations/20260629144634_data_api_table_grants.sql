BEGIN;

-- Explicit Data API grants for Supabase projects where public tables are not
-- exposed automatically. RLS policies continue to decide row-level access.

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Public app configuration is intentionally readable before sign-in.
GRANT SELECT ON TABLE public.app_config TO anon, authenticated, service_role;

-- Authenticated users access application tables through existing RLS policies.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.repo TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_fitbit_credentials TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_invite TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.study_subject TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.subject_progress TO authenticated, service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public."user" TO authenticated, service_role;

-- Anonymous users need table-level SELECT for RLS to return zero rows instead
-- of failing before policy evaluation.
GRANT SELECT ON TABLE public.study TO anon;
GRANT SELECT ON TABLE public."user" TO anon;

-- Export view is read-only; security_invoker makes underlying table RLS apply.
GRANT SELECT ON TABLE public.study_progress_export TO authenticated, service_role;

-- RLS helper functions are callable by authenticated users through policies.
GRANT EXECUTE ON FUNCTION public.can_edit(uuid, public.study) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_study_subject_of(uuid, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_results_public(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_study_record_from_invite(text) TO authenticated;

COMMIT;
