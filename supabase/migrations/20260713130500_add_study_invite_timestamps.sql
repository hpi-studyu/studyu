BEGIN;

-- ============================================================================
-- Migration: Add timestamps to study_invite
-- Date: July 13, 2026
-- ============================================================================
--
-- OVERVIEW:
-- Add created_at and updated_at to invite codes so the Designer can show
-- timestamp metadata and all new/updated invite rows keep these values
-- automatically.
--
-- ============================================================================ 

ALTER TABLE public.study_invite
ADD COLUMN IF NOT EXISTS created_at timestamp with time zone;

ALTER TABLE public.study_invite
ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone;

UPDATE public.study_invite
SET
  created_at = COALESCE(created_at, NOW()),
  updated_at = COALESCE(updated_at, NOW())
WHERE created_at IS NULL OR updated_at IS NULL;

ALTER TABLE public.study_invite
ALTER COLUMN created_at SET DEFAULT NOW(),
ALTER COLUMN updated_at SET DEFAULT NOW(),
ALTER COLUMN created_at SET NOT NULL,
ALTER COLUMN updated_at SET NOT NULL;

DROP TRIGGER IF EXISTS handle_updated_at ON public.study_invite;

CREATE TRIGGER handle_updated_at
BEFORE UPDATE ON public.study_invite
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

COMMIT;
