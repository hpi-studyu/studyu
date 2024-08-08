-- Seed for CI environment to create a clean test environment

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

COMMIT;
