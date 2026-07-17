BEGIN;

SELECT plan(12);

SELECT tests.create_supabase_user(
    'recovery_user',
    'recovery_user@fake-studyu-email-domain.com'
);

INSERT INTO public.user_recovery (recovery_id, user_id)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    tests.get_supabase_uid('recovery_user')
);

SELECT ok(
    (
        public.recover_account(
            '00000000-0000-4000-8000-000000000001'
        ) ->> 'success'
    )::boolean,
    'recovery succeeds with the current recovery ID'
);

SELECT is(
    (
        SELECT count(*)
        FROM public.user_recovery
        WHERE recovery_id = '00000000-0000-4000-8000-000000000001'
    ),
    1::bigint,
    'normal recovery keeps the recovery ID current'
);

SELECT ok(
    (
        public.recover_account(
            '00000000-0000-4000-8000-000000000001'
        ) ->> 'success'
    )::boolean,
    'the same recovery ID can be used after a normal reset'
);

SELECT is(
    (
        SELECT count(*)
        FROM information_schema.routine_privileges
        WHERE
            routine_schema = 'public'
            AND routine_name = 'rotate_recovery_id'
            AND grantee = 'PUBLIC'
            AND privilege_type = 'EXECUTE'
    ),
    0::bigint,
    'PUBLIC cannot execute rotate_recovery_id'
);

SELECT ok(
    NOT has_function_privilege(
        'anon', 'public.rotate_recovery_id()', 'EXECUTE'
    ),
    'anon cannot execute rotate_recovery_id'
);

SELECT ok(
    has_function_privilege(
        'authenticated',
        'public.rotate_recovery_id()',
        'EXECUTE'
    ),
    'authenticated can execute rotate_recovery_id'
);

SELECT set_config('role', 'authenticated', true);
SELECT set_config('request.jwt.claims', null, true);
SELECT throws_ok(
    'SELECT public.rotate_recovery_id()',
    '42501',
    'Not authenticated',
    'rotate_recovery_id rejects callers without an authenticated user ID'
);

SELECT tests.authenticate_as('recovery_user');
SELECT set_config(
    'tests.rotated_recovery_id',
    public.rotate_recovery_id()::text,
    true
);

SELECT isnt(
    current_setting('tests.rotated_recovery_id'),
    '00000000-0000-4000-8000-000000000001',
    'rotation returns a replacement recovery ID'
);

SELECT is(
    (
        SELECT count(*)
        FROM public.user_recovery
        WHERE recovery_id = '00000000-0000-4000-8000-000000000001'
    ),
    0::bigint,
    'the old recovery ID is invalid after explicit rotation'
);

SELECT is(
    (
        SELECT count(*)
        FROM public.user_recovery
        WHERE
            recovery_id = current_setting('tests.rotated_recovery_id')::uuid
            AND user_id = tests.get_supabase_uid('recovery_user')
    ),
    1::bigint,
    'the replacement recovery ID is current for the authenticated user'
);

SELECT is(
    (
        public.recover_account(
            '00000000-0000-4000-8000-000000000001'
        ) ->> 'success'
    )::boolean,
    false,
    'the old recovery ID cannot recover the account after explicit rotation'
);

SELECT ok(
    (
        public.recover_account(
            current_setting('tests.rotated_recovery_id')::uuid
        ) ->> 'success'
    )::boolean,
    'the replacement recovery ID can recover the account'
);

SELECT * FROM finish();

ROLLBACK;
