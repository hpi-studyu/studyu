INSERT INTO public.app_config (id, app_privacy, app_terms, designer_privacy, designer_terms, imprint, contact, analytics)
VALUES (
    'prod',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "de": "example.com", "en": "example.com" }',
    '{ "email": "email@example.com", "phone": "1235678", "website": "example.com", "organization": "example" }',
    '{ "dsn": "example", "enabled": false, "samplingRate": 0 }'
);
