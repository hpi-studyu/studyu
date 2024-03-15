ALTER TABLE public.app_config
ADD COLUMN app_min_version text;

UPDATE public.app_config
SET app_min_version = '2.6.0'
WHERE id = 'prod';

ALTER TABLE public.app_config
ALTER COLUMN app_min_version SET NOT NULL;
