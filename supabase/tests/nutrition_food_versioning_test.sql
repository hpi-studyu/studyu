BEGIN;

SELECT plan(35);

SELECT
    tests.create_supabase_user('nutrition_owner', 'nutrition_owner@studyu.health');
SELECT
    tests.create_supabase_user('nutrition_other', 'nutrition_other@studyu.health');

INSERT INTO public.study_subject (
    id, study_id, user_id, selected_intervention_ids
) VALUES
(
    '10000000-0000-0000-0000-000000000001',
    (SELECT id FROM public.study LIMIT 1),
    tests.get_supabase_uid('nutrition_owner'),
    ARRAY[]::text []
),
(
    '10000000-0000-0000-0000-000000000002',
    (SELECT id FROM public.study LIMIT 1),
    tests.get_supabase_uid('nutrition_other'),
    ARRAY[]::text []
);

INSERT INTO public.subject_progress (
    completed_at, subject_id, intervention_id, task_id, result_type, result
) VALUES
(
    '2026-07-15 12:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'historical-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-a","result":{"id":"historical","date":"2026-07-15T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"historical-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"historical-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":2,"unit":"servings","servingSizeGrams":80,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","modifiedAt":"2026-07-15T09:00:00.000Z","originalValues":{},"parentEntryId":"historical-meal"},{"id":"historical-sibling","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Sibling old","amount":4,"unit":"plates","servingSizeGrams":400,"portionEstimationMethod":"householdMeasure","portionState":"asServed","nutrition":{"energyKcal":400,"protein":4,"carbs":4,"fat":4,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T10:00:00.000Z","originalValues":{}},{"id":"other-food-entry","foodId":"20000000-0000-0000-0000-000000000002","foodVersionId":"30000000-0000-0000-0000-000000000099","entryType":"singleIngredient","name":"Other food","amount":1,"unit":"serving","servingSizeGrams":50,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":50,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T11:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":4}}'::jsonb
),
(
    '2026-07-16 08:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'current-task-a',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-b","result":{"id":"current-a","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"current-meal-a","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"current-entry-a","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
),
(
    '2026-07-16 09:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-b',
    'current-task-b',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-c","result":{"id":"current-b","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"current-meal-b","mealType":"lunch","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"current-entry-b","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":3,"unit":"bowls","servingSizeGrams":300,"portionEstimationMethod":"householdMeasure","portionState":"asServed","nutrition":{"energyKcal":300,"protein":3,"carbs":3,"fat":3,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T09:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
),
(
    '2026-07-14 12:00:00+00',
    '10000000-0000-0000-0000-000000000001',
    'intervention-a',
    'locked-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-old","result":{"id":"locked","date":"2026-07-14T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"locked-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"locked-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-14T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":3}}'::jsonb
),
(
    '2026-07-16 08:00:00+00',
    '10000000-0000-0000-0000-000000000002',
    'intervention-a',
    'other-subject-task',
    'DailyRecall',
    '{"type":"DailyRecall","periodId":"period-b","result":{"id":"other","date":"2026-07-16T00:00:00.000","recallMode":"realtimeRecord","meals":[{"id":"other-meal","mealType":"breakfast","mealContext":"home","timezone":"UTC","isSkipped":false,"foods":[{"id":"other-entry","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Other subject old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-16T08:00:00.000Z","originalValues":{}}]}],"studyDaySnapshot":5}}'::jsonb
);

UPDATE public.subject_progress
SET
    result = jsonb_set(
        result,
        '{result,meals,0,foods}',
        (result #> '{result,meals,0,foods}') || jsonb_build_array(
            (result #> '{result,meals,0,foods,0}')
            || '{"id":"current-entry-a-second","amount":2,"nutrition":{"energyKcal":200,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}}}'::jsonb
        )
    )
WHERE
    subject_id = '10000000-0000-0000-0000-000000000001'
    AND task_id = 'current-task-a';

SELECT tests.authenticate_as('nutrition_owner');

CREATE TEMP TABLE nutrition_results (label text PRIMARY KEY, response jsonb);
INSERT INTO nutrition_results VALUES (
    'create',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        NULL,
        '{"id":"definition-snapshot","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"Old","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":100,"protein":1,"carbs":1,"fat":1,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}'::jsonb,
        FALSE,
        NULL,
        NULL,
        TRUE
    )
);

SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    1,
    'creation inserts one immutable version'
);
SELECT is(
    (
        SELECT response FROM nutrition_results
        WHERE label = 'create'
    ),
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000001',
        '20000000-0000-0000-0000-000000000001',
        NULL,
        '{}'::jsonb,
        FALSE,
        NULL,
        NULL,
        NULL
    ),
    'idempotent retry returns the canonical original response'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    1,
    'idempotent retry does not add a version'
);

INSERT INTO nutrition_results VALUES (
    'historical',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000002',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'create'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        '{"id":"edited-snapshot","foodId":"20000000-0000-0000-0000-000000000001","foodVersionId":"30000000-0000-0000-0000-000000000000","entryType":"singleIngredient","name":"New","amount":1,"unit":"serving","servingSizeGrams":100,"portionEstimationMethod":"standardUnit","portionState":"asServed","nutrition":{"energyKcal":150,"protein":2,"carbs":2,"fat":2,"sugars":0,"fiber":0,"saturatedFat":0,"transFat":0,"cholesterol":0,"sodium":0,"waterContent":0,"micros":{}},"source":"manual","confidenceScore":1,"createdAt":"2026-07-15T08:00:00.000Z","originalValues":{}}'::jsonb,
        FALSE,
        '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
        5,
        NULL,
        'historical-entry'
    )
);

SELECT is(
    (
        SELECT (response ->> 'selectedHistoricalUpdateCount')::integer
        FROM nutrition_results
        WHERE label = 'historical'
    ),
    1,
    'mutation reports the selected historical row update count'
);
SELECT is(
    (
        SELECT (response ->> 'todayUpdateCount')::integer
        FROM nutrition_results
        WHERE label = 'historical'
    ),
    3,
    'mutation reports the current study-day occurrence update count'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'New',
    'selected historical target is rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'Sibling old',
    'same-food historical sibling is not rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,id}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'historical-entry',
    'historical logged entry identity is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,unit}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    'serving',
    'historical serving name comes from the new definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,servingSizeGrams}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    '100',
    'historical serving weight comes from the new definition'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,amount}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'historical-task'
    ),
    '2',
    'historical quantity is preserved'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND (result #>> '{result,studyDaySnapshot}')::integer = 5
            AND result #>> '{result,meals,0,foods,0,name}' = 'New'
    ),
    2,
    'all matching current-day task and period rows are rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,1,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-a'
    ),
    'New',
    'multiple same-food occurrences in one current-day row are rewritten'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,amount}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    '3',
    'current-day serving state is preserved'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,unit}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    'serving',
    'current-day serving metadata comes from the new definition'
);
SELECT is(
    (
        SELECT
            (
                result #>> '{result,meals,0,foods,0,nutrition,energyKcal}'
            )::numeric
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'current-task-b'
    ),
    450::numeric,
    'definition nutrition is scaled to the preserved quantity'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE
            subject_id = '10000000-0000-0000-0000-000000000001'
            AND task_id = 'locked-task'
    ),
    'Old',
    'unrelated historical days are isolated'
);
SELECT is(
    (
        SELECT result #>> '{result,meals,0,foods,0,name}'
        FROM public.subject_progress
        WHERE subject_id = '10000000-0000-0000-0000-000000000002'
    ),
    'Other subject old',
    'other subjects are isolated'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000009',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical') - 'source',
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots missing a FoodEntry required field are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000a',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{entryType}', '"invalid"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots with unknown enum values are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000b',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{nutrition,energyKcal}', '"not-a-number"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'snapshots with invalid nested JSON types are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000e',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    jsonb_set(
      (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
      '{createdAt}', '"2026-07-15T08:00:00 UTC"'::jsonb
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'timestamps unsupported by Dart DateTime.parse are rejected'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    2,
    'malformed snapshot mutations roll back without adding versions'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000c',
    '20000000-0000-0000-0000-000000000010',
    NULL,
    jsonb_set(
      jsonb_set(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
        '{foodId}', '"20000000-0000-0000-0000-000000000010"'::jsonb
      ),
      '{entryType}', '"meal"'::jsonb
    ) || jsonb_build_object(
      'componentFoods', jsonb_build_array(jsonb_build_object(
        'id', 'composition-a',
        'parentEntryId', 'edited-snapshot',
        'foodId', '20000000-0000-0000-0000-000000000001',
        'amount', 1,
        'unit', 'serving'
      )),
      'componentSnapshots', jsonb_build_array(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical') - 'source'
      )
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'saved-meal component snapshots are validated recursively'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-00000000000d',
    '20000000-0000-0000-0000-000000000011',
    NULL,
    jsonb_set(
      jsonb_set(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
        '{foodId}', '"20000000-0000-0000-0000-000000000011"'::jsonb
      ),
      '{entryType}', '"meal"'::jsonb
    ) || jsonb_build_object(
      'componentFoods', jsonb_build_array(jsonb_build_object(
        'id', 'composition-a',
        'parentEntryId', 'edited-snapshot',
        'foodId', '20000000-0000-0000-0000-000000000002',
        'amount', 1,
        'unit', 'serving'
      )),
      'componentSnapshots', jsonb_build_array(
        (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical')
      )
    ),
    false, NULL, NULL, NULL
  )$$,
    '22023',
    'invalid nutrition mutation payload',
    'saved-meal components must correspond by ordered food identity'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.nutrition_food_definition
        WHERE id IN (
            '20000000-0000-0000-0000-000000000010',
            '20000000-0000-0000-0000-000000000011'
        )
    ),
    0,
    'malformed saved meals roll back definition creation atomically'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000003',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'create') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false, NULL, NULL, NULL
  )$$,
    '40001',
    'stale nutrition definition version',
    'stale versions are rejected'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000004',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"missing","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
    5,
    NULL,
    'historical-entry'
  )$$,
    'P0002',
    'historical nutrition recall target is missing or ambiguous',
    'nonmatching persistence targets are rejected atomically'
);
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_version),
    2,
    'post-version target failures roll back the entire mutation'
);

SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000008',
    '20000000-0000-0000-0000-000000000001',
    ((SELECT response FROM nutrition_results WHERE label = 'historical') #>> '{definition,currentVersionId}')::uuid,
    (SELECT response #> '{definition,snapshot}' FROM nutrition_results WHERE label = 'historical'),
    false,
    '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
    5,
    NULL,
    'other-food-entry'
  )$$,
    'P0002',
    'historical target entry does not contain food definition',
    'historical entry must belong to the requested stable food definition'
);

INSERT INTO nutrition_results VALUES (
    'delete',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000005',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'historical'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        (
            SELECT response #> '{definition,snapshot}' FROM nutrition_results
            WHERE label = 'historical'
        ),
        TRUE, NULL, NULL, NULL
    )
);
SELECT ok(
    (
        SELECT deleted_at IS NOT NULL FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    'definition is soft deleted'
);

INSERT INTO nutrition_results VALUES (
    'restore',
    public.apply_nutrition_food_mutation(
        '10000000-0000-0000-0000-000000000001',
        '40000000-0000-0000-0000-000000000006',
        '20000000-0000-0000-0000-000000000001',
        (
            (
                SELECT response FROM nutrition_results
                WHERE label = 'historical'
            ) #>> '{definition,currentVersionId}'
        )::uuid,
        (
            SELECT response #> '{definition,snapshot}' FROM nutrition_results
            WHERE label = 'historical'
        ),
        FALSE,
        '{"taskId":"historical-task","periodId":"period-a","interventionId":"intervention-a","completedAt":"2026-07-15T12:00:00Z","studyDaySnapshot":4}'::jsonb,
        5,
        NULL,
        'historical-entry'
    )
);
SELECT ok(
    (
        SELECT deleted_at IS NULL FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    'historical edit restores the same stable definition identity'
);
SELECT is(
    (
        SELECT count(*)::integer FROM public.nutrition_food_definition
        WHERE id = '20000000-0000-0000-0000-000000000001'
    ),
    1,
    'restore does not create a second definition'
);

SELECT tests.authenticate_as('nutrition_other');
SELECT is(
    (SELECT count(*)::integer FROM public.nutrition_food_definition),
    0,
    'definition RLS hides another subject library'
);
SELECT throws_ok(
    $$SELECT public.apply_nutrition_food_mutation(
    '10000000-0000-0000-0000-000000000001',
    '40000000-0000-0000-0000-000000000007',
    '20000000-0000-0000-0000-000000000001',
    NULL, '{}'::jsonb, false, NULL, NULL, NULL
  )$$,
    '42501',
    'nutrition definition subject is not owned by caller',
    'RPC rejects cross-subject mutation'
);

SELECT * FROM finish();
ROLLBACK;
