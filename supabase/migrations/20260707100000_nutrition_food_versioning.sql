BEGIN;

CREATE TABLE public.nutrition_food_definition (
    id uuid PRIMARY KEY,
    subject_id uuid NOT NULL REFERENCES public.study_subject (
        id
    ) ON DELETE CASCADE,
    kind text NOT NULL CHECK (kind IN ('food', 'meal')),
    current_version_id uuid NOT NULL,
    library_visible boolean NOT NULL DEFAULT false,
    deleted_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE public.nutrition_food_version (
    id uuid PRIMARY KEY,
    food_id uuid NOT NULL REFERENCES public.nutrition_food_definition (
        id
    ) ON DELETE CASCADE,
    version_number integer NOT NULL CHECK (version_number > 0),
    snapshot jsonb NOT NULL,
    mutation_id uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (food_id, version_number),
    UNIQUE (food_id, mutation_id)
);

ALTER TABLE public.nutrition_food_definition
ADD CONSTRAINT nutrition_food_definition_current_version_id_fkey
FOREIGN KEY (current_version_id) REFERENCES public.nutrition_food_version (id)
DEFERRABLE INITIALLY DEFERRED;

CREATE TABLE public.nutrition_food_mutation (
    subject_id uuid NOT NULL REFERENCES public.study_subject (
        id
    ) ON DELETE CASCADE,
    mutation_id uuid NOT NULL,
    response jsonb NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (subject_id, mutation_id)
);

ALTER TABLE public.nutrition_food_definition ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_food_version ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_food_mutation ENABLE ROW LEVEL SECURITY;

CREATE POLICY nutrition_food_definition_select ON public.nutrition_food_definition
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.study_subject AS subject
        WHERE
            subject.id = nutrition_food_definition.subject_id
            AND subject.user_id = auth.uid()
    )
);

CREATE POLICY nutrition_food_version_select ON public.nutrition_food_version
FOR SELECT TO authenticated
USING (
    EXISTS (
        SELECT 1
        FROM public.nutrition_food_definition AS definition
        INNER JOIN
            public.study_subject AS subject
            ON definition.subject_id = subject.id
        WHERE
            definition.id = nutrition_food_version.food_id
            AND subject.user_id = auth.uid()
    )
);

CREATE FUNCTION public.nutrition_scale_json_numbers(
    p_value jsonb,
    p_factor numeric
) RETURNS jsonb
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
BEGIN
  RETURN CASE jsonb_typeof(p_value)
    WHEN 'number' THEN to_jsonb((p_value #>> '{}')::numeric * p_factor)
    WHEN 'object' THEN (
      SELECT COALESCE(
        jsonb_object_agg(key, public.nutrition_scale_json_numbers(value, p_factor)),
        '{}'::jsonb
      )
      FROM jsonb_each(p_value)
    )
    WHEN 'array' THEN (
      SELECT COALESCE(
        jsonb_agg(public.nutrition_scale_json_numbers(value, p_factor)),
        '[]'::jsonb
      )
      FROM jsonb_array_elements(p_value)
    )
    ELSE p_value
  END;
END;
$$;

-- Direct definition matches only. Saved-meal component snapshots remain immutable.
CREATE FUNCTION public.nutrition_replace_food_snapshots(
    p_result jsonb,
    p_food_id uuid,
    p_snapshot jsonb
) RETURNS jsonb
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT jsonb_set(
    p_result,
    '{result,meals}',
    COALESCE((
      SELECT jsonb_agg(
        jsonb_set(
          meal,
          '{foods}',
          COALESCE((
            SELECT jsonb_agg(
              CASE WHEN food->>'foodId' = p_food_id::text THEN
                jsonb_set(
                  p_snapshot,
                  '{nutrition}',
                  public.nutrition_scale_json_numbers(
                    p_snapshot->'nutrition',
                    CASE
                      WHEN (p_snapshot->>'amount')::numeric > 0
                        THEN (food->>'amount')::numeric / (p_snapshot->>'amount')::numeric
                      ELSE 1
                    END
                  ),
                  true
                ) || jsonb_build_object(
                  'id', food->'id',
                  'amount', food->'amount',
                  'unit', food->'unit',
                  'servingSizeGrams', food->'servingSizeGrams',
                  'portionReference', food->'portionReference',
                  'portionEstimationMethod', food->'portionEstimationMethod',
                  'portionState', food->'portionState',
                  'yieldFactor', food->'yieldFactor',
                  'ediblePortion', food->'ediblePortion',
                  'templateId', food->'templateId',
                  'createdAt', food->'createdAt',
                  'modifiedAt', food->'modifiedAt',
                  'parentEntryId', food->'parentEntryId'
                )
              ELSE food END
              ORDER BY ordinality
            )
            FROM jsonb_array_elements(COALESCE(meal->'foods', '[]'::jsonb))
              WITH ORDINALITY AS foods(food, ordinality)
          ), '[]'::jsonb),
          true
        )
        ORDER BY meal_ordinality
      )
      FROM jsonb_array_elements(COALESCE(p_result #> '{result,meals}', '[]'::jsonb))
        WITH ORDINALITY AS meals(meal, meal_ordinality)
    ), '[]'::jsonb),
    true
  );
$$;

CREATE FUNCTION public.nutrition_result_has_food(p_result jsonb, p_food_id uuid)
RETURNS boolean
LANGUAGE sql
IMMUTABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM jsonb_array_elements(COALESCE(p_result #> '{result,meals}', '[]'::jsonb)) AS meal,
         jsonb_array_elements(COALESCE(meal->'foods', '[]'::jsonb)) AS food
    WHERE food->>'foodId' = p_food_id::text
  );
$$;

CREATE FUNCTION public.apply_nutrition_food_mutation(
    p_subject_id uuid,
    p_mutation_id uuid,
    p_food_id uuid,
    p_expected_version_id uuid,
    p_snapshot jsonb,
    p_deleted boolean DEFAULT false,
    p_historical_target jsonb DEFAULT null,
    p_propagate_study_day integer DEFAULT null,
    p_library_visible boolean DEFAULT null
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_definition public.nutrition_food_definition%ROWTYPE;
  v_version_id uuid := gen_random_uuid();
  v_version_number integer;
  v_snapshot jsonb;
  v_target public.subject_progress%ROWTYPE;
  v_target_count integer;
  v_progress jsonb := '[]'::jsonb;
  v_progress_row jsonb;
  v_response jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.study_subject
    WHERE id = p_subject_id AND user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'nutrition definition subject is not owned by caller'
      USING ERRCODE = '42501';
  END IF;
  IF p_mutation_id IS NULL THEN
    RAISE EXCEPTION 'invalid nutrition mutation payload' USING ERRCODE = '22023';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended(p_subject_id::text || p_mutation_id::text, 0));
  SELECT response INTO v_response
  FROM public.nutrition_food_mutation
  WHERE subject_id = p_subject_id AND mutation_id = p_mutation_id;
  IF FOUND THEN RETURN v_response; END IF;

  IF p_food_id IS NULL OR p_snapshot IS NULL OR
      p_snapshot->>'foodId' IS DISTINCT FROM p_food_id::text OR
      NULLIF(p_snapshot->>'id', '') IS NULL OR
      NULLIF(p_snapshot->>'foodVersionId', '') IS NULL OR
      NULLIF(p_snapshot->>'name', '') IS NULL OR
      p_snapshot->'nutrition' IS NULL THEN
    RAISE EXCEPTION 'invalid nutrition mutation payload' USING ERRCODE = '22023';
  END IF;
  IF p_snapshot->>'entryType' = 'meal' AND (
      jsonb_typeof(p_snapshot->'componentFoods') IS DISTINCT FROM 'array' OR
      jsonb_typeof(p_snapshot->'componentSnapshots') IS DISTINCT FROM 'array' OR
      jsonb_array_length(p_snapshot->'componentFoods') <>
        jsonb_array_length(p_snapshot->'componentSnapshots') OR
      EXISTS (
        SELECT 1
        FROM jsonb_array_elements(p_snapshot->'componentSnapshots') AS component
        WHERE NULLIF(component->>'id', '') IS NULL
           OR NULLIF(component->>'foodId', '') IS NULL
           OR NULLIF(component->>'foodVersionId', '') IS NULL
           OR NULLIF(component->>'name', '') IS NULL
           OR component->'nutrition' IS NULL
      )
  ) THEN
    RAISE EXCEPTION 'saved meal versions require complete component snapshots'
      USING ERRCODE = '22023';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(p_food_id::text, 1));
  SELECT * INTO v_definition
  FROM public.nutrition_food_definition
  WHERE id = p_food_id AND subject_id = p_subject_id
  FOR UPDATE;

  IF FOUND THEN
    IF p_expected_version_id IS NULL OR (
      v_definition.current_version_id <> p_expected_version_id AND NOT (
        v_definition.deleted_at IS NOT NULL AND
        p_historical_target IS NOT NULL AND
        EXISTS (
          SELECT 1 FROM public.nutrition_food_version
          WHERE id = p_expected_version_id AND food_id = p_food_id
        )
      )
    ) THEN
      RAISE EXCEPTION 'stale nutrition definition version' USING ERRCODE = '40001';
    END IF;
    v_version_number := (
      SELECT COALESCE(MAX(version_number), 0) + 1
      FROM public.nutrition_food_version WHERE food_id = p_food_id
    );
  ELSE
    IF p_expected_version_id IS NOT NULL THEN
      RAISE EXCEPTION 'nutrition definition does not exist' USING ERRCODE = 'P0002';
    END IF;
    v_version_number := 1;
    INSERT INTO public.nutrition_food_definition (
      id, subject_id, kind, current_version_id, library_visible
    ) VALUES (
      p_food_id,
      p_subject_id,
      CASE WHEN p_snapshot->>'entryType' = 'meal' THEN 'meal' ELSE 'food' END,
      v_version_id,
      COALESCE(p_library_visible, false)
    );
  END IF;

  v_snapshot := jsonb_set(
    p_snapshot,
    '{foodVersionId}',
    to_jsonb(v_version_id::text),
    true
  );
  INSERT INTO public.nutrition_food_version (
    id, food_id, version_number, snapshot, mutation_id
  ) VALUES (
    v_version_id, p_food_id, v_version_number, v_snapshot, p_mutation_id
  );
  UPDATE public.nutrition_food_definition
  SET current_version_id = v_version_id,
      deleted_at = CASE WHEN p_deleted THEN now() ELSE NULL END,
      library_visible = COALESCE(p_library_visible, library_visible),
      updated_at = now()
  WHERE id = p_food_id;

  IF p_historical_target IS NOT NULL THEN
    IF p_deleted OR p_propagate_study_day IS NULL OR
       (p_historical_target->>'studyDaySnapshot')::integer <> p_propagate_study_day - 1 THEN
      RAISE EXCEPTION 'historical nutrition recall is no longer editable'
        USING ERRCODE = '22023';
    END IF;
    SELECT count(*) INTO v_target_count
    FROM public.subject_progress
    WHERE subject_id = p_subject_id
      AND task_id = p_historical_target->>'taskId'
      AND intervention_id = p_historical_target->>'interventionId'
      AND completed_at = (p_historical_target->>'completedAt')::timestamptz
      AND result_type = 'DailyRecall'
      AND result->>'periodId' = p_historical_target->>'periodId'
      AND (result #>> '{result,studyDaySnapshot}')::integer =
          (p_historical_target->>'studyDaySnapshot')::integer;
    IF v_target_count <> 1 THEN
      RAISE EXCEPTION 'historical nutrition recall target is missing or ambiguous'
        USING ERRCODE = 'P0002';
    END IF;

    SELECT * INTO v_target
    FROM public.subject_progress
    WHERE subject_id = p_subject_id
      AND task_id = p_historical_target->>'taskId'
      AND intervention_id = p_historical_target->>'interventionId'
      AND completed_at = (p_historical_target->>'completedAt')::timestamptz
      AND result_type = 'DailyRecall'
      AND result->>'periodId' = p_historical_target->>'periodId'
      AND (result #>> '{result,studyDaySnapshot}')::integer =
          (p_historical_target->>'studyDaySnapshot')::integer
    FOR UPDATE;
    IF NOT public.nutrition_result_has_food(v_target.result, p_food_id) THEN
      RAISE EXCEPTION 'historical target does not contain food definition'
        USING ERRCODE = 'P0002';
    END IF;
    UPDATE public.subject_progress
    SET result = public.nutrition_replace_food_snapshots(result, p_food_id, v_snapshot)
    WHERE completed_at = v_target.completed_at AND subject_id = v_target.subject_id
    RETURNING to_jsonb(public.subject_progress.*) INTO v_progress_row;
    v_progress := v_progress || jsonb_build_array(v_progress_row);
  END IF;

  IF p_propagate_study_day IS NOT NULL THEN
    WITH updated AS (
      UPDATE public.subject_progress
      SET result = public.nutrition_replace_food_snapshots(result, p_food_id, v_snapshot)
      WHERE subject_id = p_subject_id
        AND result_type = 'DailyRecall'
        AND (result #>> '{result,studyDaySnapshot}')::integer = p_propagate_study_day
        AND public.nutrition_result_has_food(result, p_food_id)
      RETURNING to_jsonb(public.subject_progress.*) AS row
    )
    SELECT v_progress || COALESCE(jsonb_agg(row), '[]'::jsonb)
    INTO v_progress
    FROM updated;
  END IF;

  SELECT jsonb_build_object(
    'definition', jsonb_build_object(
      'id', definition.id,
      'subjectId', definition.subject_id,
      'kind', definition.kind,
      'currentVersionId', definition.current_version_id,
      'deletedAt', definition.deleted_at,
      'snapshot', v_snapshot,
      'createdAt', definition.created_at,
      'updatedAt', definition.updated_at
    ),
    'progress', v_progress
  ) INTO v_response
  FROM public.nutrition_food_definition AS definition
  WHERE definition.id = p_food_id;

  INSERT INTO public.nutrition_food_mutation (subject_id, mutation_id, response)
  VALUES (p_subject_id, p_mutation_id, v_response);
  RETURN v_response;
END;
$$;

REVOKE ALL ON FUNCTION public.nutrition_scale_json_numbers(jsonb, numeric)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_replace_food_snapshots(
    jsonb, uuid, jsonb
)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.nutrition_result_has_food(jsonb, uuid)
FROM public, anon, authenticated;
REVOKE ALL ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean
) FROM public, anon;
GRANT EXECUTE ON FUNCTION public.apply_nutrition_food_mutation(
    uuid, uuid, uuid, uuid, jsonb, boolean, jsonb, integer, boolean
) TO authenticated;
GRANT SELECT ON TABLE public.nutrition_food_definition,
public.nutrition_food_version TO authenticated, service_role;
GRANT ALL ON TABLE public.nutrition_food_definition,
public.nutrition_food_version,
public.nutrition_food_mutation TO service_role;

COMMIT;
