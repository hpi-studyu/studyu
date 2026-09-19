-- Local development medication catalog. This file is never used for production.
BEGIN;

SELECT private.bfarm_add_approval(
  'approved',
  private.bfarm_core_uses() || private.bfarm_share_use(),
  'local-development-seed',
  'local development only'
);

DO $$
DECLARE
  release_id uuid;
BEGIN
  release_id := public.begin_bfarm_import(
    '2026-09-15',
    'local-development-medication',
    'local-development',
    repeat('a', 64),
    '{"medicinal_products":1,"pharmaceutical_products":1,"substances":1}'::jsonb,
    'local-development-seed'
  );

  PERFORM public.stage_bfarm_medicinal_products(
    release_id,
    '[{"rmp_key":"rmp-dev-1","rmp_pzn":"03752864","rmp_count_substance":1,"rmp_multiple_ppt":"0","rmp_pfm_put_short":"Tablet","rmp_pfm_put_long":null,"rmp_pfm_name":"Tablette","rmp_pfm_term_id":"T1","rmp_mpd_name":"Ibuprofen Test"}]'::jsonb
  );
  PERFORM public.stage_bfarm_pharmaceutical_products(
    release_id,
    '[{"rpp_key":"rpp-dev-1","rmp_key":"rmp-dev-1","rpp_number":1,"rpp_pfm_put_short":"Tablet","rpp_pfm_put_long":null,"rpp_pfm_name":"Tablette","rpp_pfm_term_id":"T1","rpp_description":null}]'::jsonb
  );
  PERFORM public.stage_bfarm_substances(
    release_id,
    '[{"rse_key":"rse-dev-1","rpp_key":"rpp-dev-1","rse_substance_name":"Ibuprofen","rse_substance_strength":"400 mg","rse_substance_id":null,"rse_substance_rank":1}]'::jsonb
  );
  PERFORM public.activate_bfarm_import(release_id);
END;
$$;

COMMIT;
