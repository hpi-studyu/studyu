-- BfArM catalog contract tests. The Supabase runner requires one TAP plan per file.
do $$ begin raise notice 'BfArM catalog tests: server %, client %, current %', inet_server_addr(), inet_client_addr(), current_user; end $$;

begin;
select plan(63);

-- Privilege denial.
do $$ begin perform set_config('role','anon',true); end $$;
select throws_ok($$select * from private.bfarm_release$$,'42501');
select throws_ok($$select * from private.bfarm_medicinal_product$$,'42501');
select throws_ok($$select * from private.bfarm_catalog_state$$,'42501');
select throws_ok($$select * from private.bfarm_data_approval$$,'42501');
select throws_ok($$select * from private.bfarm_catalog_transition$$,'42501');
select throws_ok($$select public.lookup_bfarm_medication('03752864')$$,'42501');
do $$ begin perform set_config('role','authenticated',true); end $$;
select throws_ok($$select * from private.bfarm_release$$,'42501');
do $$ begin perform set_config('role','postgres',true); end $$;

-- Approval gate.
select ok(not private.bfarm_current_approval_ok(private.bfarm_core_uses()),'approval starts closed');
select throws_ok($$select public.lookup_bfarm_medication('03752864')$$,'P0001','bfarm_approval_missing');
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test')$$,'core approval can be recorded');
select ok(private.bfarm_current_approval_ok(private.bfarm_core_uses()),'core approval opens gate');
select lives_ok($$select private.bfarm_add_approval('denied',private.bfarm_core_uses(),'test','test')$$,'denied decision can be recorded');
select ok(not private.bfarm_current_approval_ok(private.bfarm_core_uses()),'denied approval closes gate');
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test',now()-interval '1 minute')$$,'expired decision can be recorded');
select throws_ok($$select public.lookup_bfarm_medication('03752864')$$,'P0001','bfarm_approval_missing');

-- Normal lifecycle, idempotency, projection, and read grants.
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test')$$,'approval setup');
select lives_ok($$select public.begin_bfarm_import('2026-09-15','message-1','referenzdaten@bfarm.de',repeat('b',64),'{"medicinal_products":1,"pharmaceutical_products":1,"substances":1}'::jsonb,'test')$$,'begin creates release');
select is(public.begin_bfarm_import('2026-09-15','message-1','referenzdaten@bfarm.de',repeat('b',64),'{"medicinal_products":1,"pharmaceutical_products":1,"substances":1}'::jsonb,'test')::text,(select id::text from private.bfarm_release where source_message_id='message-1'),'same identity is idempotent');
select is(public.stage_bfarm_medicinal_products((select id from private.bfarm_release where source_message_id='message-1'),'[{"rmp_key":"rmp-1","rmp_pzn":"03752864","rmp_count_substance":1,"rmp_multiple_ppt":"0","rmp_pfm_put_short":"Tablet","rmp_pfm_put_long":null,"rmp_pfm_name":"Tablette","rmp_pfm_term_id":"T1","rmp_mpd_name":"Ibuprofen Test"}]'::jsonb),1,'medicinal row stages');
select is(public.stage_bfarm_medicinal_products((select id from private.bfarm_release where source_message_id='message-1'),'[{"rmp_key":"rmp-1","rmp_pzn":"03752864","rmp_count_substance":1,"rmp_multiple_ppt":"0","rmp_pfm_put_short":"Tablet","rmp_pfm_put_long":null,"rmp_pfm_name":"Tablette","rmp_pfm_term_id":"T1","rmp_mpd_name":"Ibuprofen Test"}]'::jsonb),0,'identical replay is a no-op');
select throws_ok($$select public.stage_bfarm_medicinal_products((select id from private.bfarm_release where source_message_id='message-1'),'[{"rmp_key":"rmp-1","rmp_pzn":"03752864","rmp_count_substance":1,"rmp_multiple_ppt":"0","rmp_pfm_put_short":"Changed","rmp_pfm_put_long":null,"rmp_pfm_name":"Tablette","rmp_pfm_term_id":"T1","rmp_mpd_name":"Ibuprofen Test"}]'::jsonb)$$,'P0001','bfarm_repeat_key_content_changed');
select is(public.stage_bfarm_pharmaceutical_products((select id from private.bfarm_release where source_message_id='message-1'),'[{"rpp_key":"rpp-1","rmp_key":"rmp-1","rpp_number":1,"rpp_pfm_put_short":"Tablet","rpp_pfm_put_long":null,"rpp_pfm_name":"Tablette","rpp_pfm_term_id":"T1","rpp_description":null}]'::jsonb),1,'pharmaceutical row stages');
select is(public.stage_bfarm_substances((select id from private.bfarm_release where source_message_id='message-1'),'[{"rse_key":"rse-1","rpp_key":"rpp-1","rse_substance_name":"Ibuprofen","rse_substance_strength":"400 mg","rse_substance_id":null,"rse_substance_rank":1}]'::jsonb),1,'substance row stages');
select is((public.get_bfarm_import_status((select id from private.bfarm_release where source_message_id='message-1'))->>'status'),'staging','status reports staging');
select is((public.activate_bfarm_import((select id from private.bfarm_release where source_message_id='message-1'))->>'status'),'active','activation succeeds');
select is((public.activate_bfarm_import((select id from private.bfarm_release where source_message_id='message-1'))->>'status'),'active','active activation is a no-op');
select throws_ok($$select public.mark_bfarm_import_failed((select id from private.bfarm_release where source_message_id='message-1'),'x','cannot fail active')$$,'P0001','bfarm_release_not_staging');
do $$ begin perform set_config('role','authenticated',true); end $$;
select is((public.lookup_bfarm_medication('03752864')->>'pzn'),'03752864','lookup preserves leading zero');
select is((public.lookup_bfarm_medication('03752864')->'source'->>'releaseDate'),'2026-09-15','lookup returns source date');
select ok((select count(*) from public.search_bfarm_medications('ibuprofen'))=1,'search finds active product');
do $$ begin perform set_config('role','postgres',true); end $$;

-- Combination product semantics.
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test')$$,'combination approval setup');
select lives_ok($$select public.begin_bfarm_import('2026-09-16','combo','sender',repeat('e',64),'{"medicinal_products":1,"pharmaceutical_products":2,"substances":2}'::jsonb,'test')$$,'combination begin');
select is(public.stage_bfarm_medicinal_products((select id from private.bfarm_release where source_message_id='combo'),'[{"rmp_key":"rmp-c","rmp_pzn":"19100431","rmp_count_substance":1,"rmp_multiple_ppt":"1","rmp_pfm_put_short":"Pack","rmp_pfm_put_long":null,"rmp_pfm_name":"Pack","rmp_pfm_term_id":"P1","rmp_mpd_name":"Combination"}]'::jsonb),1,'combination medicinal row stages');
select is(public.stage_bfarm_pharmaceutical_products((select id from private.bfarm_release where source_message_id='combo'),'[{"rpp_key":"rpp-c1","rmp_key":"rmp-c","rpp_number":1,"rpp_pfm_put_short":"Tablet","rpp_pfm_put_long":null,"rpp_pfm_name":"Tablet","rpp_pfm_term_id":"T1","rpp_description":null},{"rpp_key":"rpp-c2","rmp_key":"rmp-c","rpp_number":2,"rpp_pfm_put_short":"Capsule","rpp_pfm_put_long":null,"rpp_pfm_name":"Capsule","rpp_pfm_term_id":"T2","rpp_description":null}]'::jsonb),2,'two components stage');
select is(public.stage_bfarm_substances((select id from private.bfarm_release where source_message_id='combo'),'[{"rse_key":"rse-c1","rpp_key":"rpp-c1","rse_substance_name":"One","rse_substance_strength":null,"rse_substance_id":null,"rse_substance_rank":1},{"rse_key":"rse-c2","rpp_key":"rpp-c2","rse_substance_name":"Two","rse_substance_strength":null,"rse_substance_id":null,"rse_substance_rank":1}]'::jsonb),2,'two component substances stage');
select is((public.activate_bfarm_import((select id from private.bfarm_release where source_message_id='combo'))->>'status'),'active','combination activation');
do $$ begin perform set_config('role','authenticated',true); end $$;
select is(jsonb_array_length(public.lookup_bfarm_medication('19100431')->'components'),2,'combination pack projects both components');
select is((public.lookup_bfarm_medication('19100431')->'components'->1->'activeIngredients'->0->>'name'),'Two','component ingredient remains distinct');
do $$ begin perform set_config('role','postgres',true); end $$;
-- Rollback pointer and pruning rules.
select lives_ok($$select private.bfarm_rollback_catalog((select id from private.bfarm_release where source_message_id='message-1'),'test rollback')$$,'owner can roll back to the pointer');
select is((select active_release_id::text from private.bfarm_catalog_state),(select id::text from private.bfarm_release where source_message_id='message-1'),'rollback points to prior release');
select is((select rollback_release_id::text from private.bfarm_catalog_state),(select id::text from private.bfarm_release where source_message_id='combo'),'rollback stores former active release');
select throws_ok($$select private.bfarm_rollback_catalog((select id from private.bfarm_release where source_message_id='message-1'),'wrong target')$$,'P0001','bfarm_rollback_target_mismatch');
select lives_ok($$select public.begin_bfarm_import('2026-09-17','prune-me','sender',repeat('f',64),'{"medicinal_products":1,"pharmaceutical_products":1,"substances":1}'::jsonb,'test')$$,'prune candidate begin');
select is(public.stage_bfarm_medicinal_products((select id from private.bfarm_release where source_message_id='prune-me'),'[{"rmp_key":"rmp-p","rmp_pzn":"03752864","rmp_count_substance":1,"rmp_multiple_ppt":"0","rmp_pfm_put_short":"Tablet","rmp_pfm_put_long":null,"rmp_pfm_name":"Tablette","rmp_pfm_term_id":"T1","rmp_mpd_name":"Prune"}]'::jsonb),1,'prune candidate content stages');
select is(public.prune_bfarm_releases(0),1,'prune returns deleted content count');
select is((select count(*)::integer from private.bfarm_medicinal_product where release_id=(select id from private.bfarm_release where source_message_id='prune-me')),0,'prune removes non-pointer content');
-- Study gate across questionnaire, observation, intervention, publication, and plain studies.
select lives_ok($$select private.bfarm_add_approval('denied',private.bfarm_core_uses(),'test','test')$$,'gate denial setup');
select lives_ok($$select tests.create_supabase_user('bfarm_gate_user')$$,'gate user setup');
select lives_ok($$select tests.authenticate_as('bfarm_gate_user')$$,'gate user authentication');
select throws_ok($$insert into public.study(contact,title,description,icon_name,status,registry_published,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results,user_id,participation,result_sharing,collaborator_emails) values('{}','Gate questionnaire','test','accountHeart','draft',false,'[{"id":"m","type":"medication","prompt":"Medication"}]','[]','[]','[]','{}','{}','{}','{}',tests.get_supabase_uid('bfarm_gate_user'),'open','private','{}')$$,'P0001','bfarm_approval_required');
select throws_ok($$insert into public.study(contact,title,description,icon_name,status,registry_published,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results,user_id,participation,result_sharing,collaborator_emails) values('{}','Gate observation','test','accountHeart','draft',false,'[]','[]','[{"tasks":[{"questionnaire":[{"id":"m","type":"medication"}]}]}]','[]','{}','{}','{}','{}',tests.get_supabase_uid('bfarm_gate_user'),'open','private','{}')$$,'P0001','bfarm_approval_required');
select throws_ok($$insert into public.study(contact,title,description,icon_name,status,registry_published,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results,user_id,participation,result_sharing,collaborator_emails) values('{}','Gate intervention','test','accountHeart','draft',false,'[]','[]','[]','[{"tasks":[{"questionnaire":[{"id":"m","type":"medication"}]}]}]','{}','{}','{}','{}',tests.get_supabase_uid('bfarm_gate_user'),'open','private','{}')$$,'P0001','bfarm_approval_required');
select set_config('role','postgres',true);
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test')$$,'gate approval setup');
select set_config('role','authenticated',true);
select lives_ok($$insert into public.study(contact,title,description,icon_name,status,registry_published,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results,user_id,participation,result_sharing,collaborator_emails) values('{}','Gate approved','test','accountHeart','draft',false,'[{"id":"m","type":"medication","prompt":"Medication"}]','[]','[]','[]','{}','{}','{}','{}',tests.get_supabase_uid('bfarm_gate_user'),'open','private','{}')$$,'approved draft medication study');
select set_config('role','postgres',true);
select lives_ok($$select private.bfarm_add_approval('denied',private.bfarm_core_uses(),'test','test')$$,'running denial setup');
select set_config('role','authenticated',true);
select throws_ok($$update public.study set status='running' where title='Gate approved'$$,'P0001','bfarm_approval_required');
select set_config('role','postgres',true);
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses() || private.bfarm_share_use(),'test','test')$$,'private publication approval setup');
select set_config('role','authenticated',true);
select lives_ok($$update public.study set status='running' where title='Gate approved'$$,'approved medication study runs privately');
select set_config('role','postgres',true);
select lives_ok($$select private.bfarm_add_approval('approved',private.bfarm_core_uses(),'test','test',now()-interval '1 minute')$$,'expired publication approval setup');
select set_config('role','authenticated',true);
select throws_ok($$update public.study set result_sharing='public' where title='Gate approved'$$,'P0001','bfarm_result_sharing_restricted');
select lives_ok($$update public.study set status='closed' where title='Gate approved'$$,'closing medication study remains allowed');
select set_config('role','postgres',true);
select lives_ok($$select private.bfarm_add_approval('denied',private.bfarm_core_uses(),'test','test')$$,'plain study denial setup');
select set_config('role','authenticated',true);
select lives_ok($$insert into public.study(contact,title,description,icon_name,status,registry_published,questionnaire,eligibility_criteria,observations,interventions,consent,schedule,report_specification,results,user_id,participation,result_sharing,collaborator_emails) values('{}','Gate plain','test','accountHeart','draft',false,'[]','[]','[]','[]','{}','{}','{}','{}',tests.get_supabase_uid('bfarm_gate_user'),'open','public','{}')$$,'plain study does not consult approval');
select set_config('role','postgres',true);

select * from finish();
rollback;
