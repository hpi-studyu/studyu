BEGIN;

SELECT plan(5);

SELECT tests.create_supabase_user(
  'recovery_user',
  'recovery_user@fake-studyu-email-domain.com'
);

INSERT INTO public.user_recovery (recovery_id, user_id)
VALUES (
  '00000000-0000-4000-8000-000000000001',
  tests.get_supabase_uid('recovery_user')
);

CREATE TEMP TABLE recovery_result AS
SELECT public.recover_account(
  '00000000-0000-4000-8000-000000000001'
) AS result;

SELECT ok(
  (SELECT (result ->> 'success')::boolean FROM recovery_result),
  'recovery succeeds with the current recovery ID'
);

SELECT isnt(
  (SELECT result ->> 'recovery_id' FROM recovery_result),
  '00000000-0000-4000-8000-000000000001',
  'successful recovery returns a replacement recovery ID'
);

SELECT is(
  (
    SELECT count(*)
    FROM public.user_recovery
    WHERE recovery_id = '00000000-0000-4000-8000-000000000001'
  ),
  0::bigint,
  'the used recovery ID is removed'
);

SELECT is(
  (
    public.recover_account(
      '00000000-0000-4000-8000-000000000001'
    ) ->> 'success'
  )::boolean,
  false,
  'the used recovery ID cannot recover the account again'
);

SELECT ok(
  (
    public.recover_account(
      (SELECT (result ->> 'recovery_id')::uuid FROM recovery_result)
    ) ->> 'success'
  )::boolean,
  'the replacement recovery ID can recover the account'
);

SELECT * FROM finish();

ROLLBACK;
