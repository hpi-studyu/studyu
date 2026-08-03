BEGIN;

SELECT plan(9);

SELECT tests.create_supabase_user('fitbit_owner', 'fitbit_owner@test.local');
SELECT tests.create_supabase_user('fitbit_other', 'fitbit_other@test.local');

INSERT INTO public.study (
  contact,
  user_id,
  title,
  description,
  icon_name,
  status,
  registry_published,
  questionnaire,
  eligibility_criteria,
  observations,
  interventions,
  consent,
  schedule,
  report_specification,
  results,
  participation,
  result_sharing,
  collaborator_emails
)
VALUES (
  '{"email":"fitbit@example.com","phone":"0123456789","website":"https://studyu.health","researchers":"StudyU Researcher","organization":"StudyU","institutionalReviewBoard":"N/A","institutionalReviewBoardNumber":"N/A"}',
  tests.get_supabase_uid('fitbit_owner'),
  'Study: participant fitbit credentials',
  'Verifies participant Fitbit token isolation.',
  'accountHeart',
  'running',
  false,
  '[]',
  '[]',
  '[]',
  '[]',
  '[]',
  '{"sequence":"alternating","phaseDuration":1,"numberOfCycles":1,"sequenceCustom":"AB","includeBaseline":false}',
  '{"primary":{"id":"average","type":"average","title":"Average","aggregate":"day","description":"Average","resultProperty":{"task":"task","property":"value"}},"secondary":[]}',
  '[]',
  'open',
  'private',
  '{}'
);

SELECT tests.authenticate_as('fitbit_owner');

SELECT lives_ok(
  $$
    INSERT INTO public.participant_fitbit_credentials (user_id, study_id, fitbit_credentials)
    VALUES (
      tests.get_supabase_uid('fitbit_owner'),
      (SELECT id FROM public.study WHERE title = 'Study: participant fitbit credentials'),
      '{"userID":"owner","fitbitAccessToken":"access-owner","fitbitRefreshToken":"refresh-owner"}'
    )
  $$,
  'owner can insert own participant fitbit credentials'
);

SELECT is(
  (
    SELECT fitbit_credentials ->> 'fitbitAccessToken'
    FROM public.participant_fitbit_credentials
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  ),
  'access-owner',
  'owner can read own participant fitbit credentials'
);

SELECT lives_ok(
  $$
    UPDATE public.participant_fitbit_credentials
    SET fitbit_credentials = '{"userID":"owner","fitbitAccessToken":"access-owner-updated","fitbitRefreshToken":"refresh-owner"}'
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  $$,
  'owner can update own participant fitbit credentials'
);

SELECT is(
  (
    SELECT fitbit_credentials ->> 'fitbitAccessToken'
    FROM public.participant_fitbit_credentials
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  ),
  'access-owner-updated',
  'updated participant fitbit credentials are visible to owner'
);

SELECT tests.authenticate_as('fitbit_other');

SELECT is(
  (SELECT count(*) FROM public.participant_fitbit_credentials),
  0::bigint,
  'other user cannot read another participant fitbit credential row'
);

SELECT lives_ok(
  $$
    UPDATE public.participant_fitbit_credentials
    SET fitbit_credentials = '{"userID":"other","fitbitAccessToken":"should-not-apply","fitbitRefreshToken":"refresh-other"}'
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  $$,
  'other user update is filtered by RLS'
);

SELECT tests.authenticate_as('fitbit_owner');

SELECT is(
  (
    SELECT fitbit_credentials ->> 'fitbitAccessToken'
    FROM public.participant_fitbit_credentials
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  ),
  'access-owner-updated',
  'other user update did not change owner credentials'
);

SELECT lives_ok(
  $$
    DELETE FROM public.participant_fitbit_credentials
    WHERE user_id = tests.get_supabase_uid('fitbit_owner')
  $$,
  'owner can delete own participant fitbit credentials'
);

INSERT INTO public.participant_fitbit_credentials (user_id, study_id, fitbit_credentials)
VALUES (
  tests.get_supabase_uid('fitbit_owner'),
  (SELECT id FROM public.study WHERE title = 'Study: participant fitbit credentials'),
  '{"userID":"owner","fitbitAccessToken":"access-owner","fitbitRefreshToken":"refresh-owner"}'
);

DELETE FROM public.study
WHERE title = 'Study: participant fitbit credentials';

SELECT is(
  (SELECT count(*) FROM public.participant_fitbit_credentials),
  0::bigint,
  'deleting study cascades to participant fitbit credentials'
);

SELECT * FROM finish();

ROLLBACK;
