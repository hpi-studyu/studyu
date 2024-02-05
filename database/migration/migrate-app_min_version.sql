ALTER TABLE public.app_config
ADD COLUMN app_min_version text NOT NULL DEFAULT '0.0.0';

ALTER TABLE public.app_config
ADD COLUMN app_playstore_url text NOT NULL DEFAULT 'https://play.google.com/store/apps/details?id=health.studyu.app';

ALTER TABLE public.app_config
ADD COLUMN app_appstore_url text NOT NULL DEFAULT 'https://itunes.apple.com/app/id1571991198';