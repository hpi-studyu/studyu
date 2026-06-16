BEGIN;

-- Explicit Data API grants for Supabase projects where public tables are not
-- exposed automatically. RLS policies continue to decide row-level access.

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Normalize legacy/default grants first, then opt each role back in explicitly.
REVOKE ALL PRIVILEGES ON TABLE public.app_config FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.repo FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.study FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.study_fitbit_credentials FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.study_invite FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.study_subject FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.subject_progress FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public."user" FROM anon, authenticated, service_role;
REVOKE ALL PRIVILEGES ON TABLE public.study_progress_export FROM anon, authenticated, service_role;

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

-- Export view is read-only; security_invoker makes underlying table RLS apply.
GRANT SELECT ON TABLE public.study_progress_export TO authenticated, service_role;

-- Service role is used for administrative flows and should keep full access to
-- base tables. Views remain SELECT-only.
GRANT ALL PRIVILEGES ON TABLE public.app_config TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.repo TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.study TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.study_fitbit_credentials TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.study_invite TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.study_subject TO service_role;
GRANT ALL PRIVILEGES ON TABLE public.subject_progress TO service_role;
GRANT ALL PRIVILEGES ON TABLE public."user" TO service_role;

COMMIT;
