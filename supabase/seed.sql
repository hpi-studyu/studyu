BEGIN;

INSERT INTO public.app_config (id, app_min_version, app_privacy, app_terms, designer_privacy, designer_terms, imprint, contact, analytics)
VALUES (
    'prod',
    '2.6.0',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "email": "email@example.com", "phone": "1235678", "website": "example.com", "organization": "example" }',
    '{ "dsn": "example", "enabled": false, "samplingRate": 0 }'
);

-- Seed data

DO $$
DECLARE
    email text := 'user1@studyu.health';
    password text := 'user1pass';
    user_id UUID;
BEGIN
    user_id := mockup.create_user(email, password);
END $$;

COMMIT;
