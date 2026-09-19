BEGIN;

create extension if not exists pg_trgm with schema extensions;
create schema if not exists private;
revoke all on schema private from public;
revoke usage, create on schema private from anon, authenticated;

create table private.bfarm_data_approval (
  id uuid primary key default gen_random_uuid(),
  is_current boolean not null default false,
  decision text not null check (decision in ('approved','denied','revoked')),
  approved_uses text[] not null default '{}',
  decided_by text,
  decided_at timestamptz not null default now(),
  evidence_reference text,
  valid_until timestamptz,
  created_at timestamptz not null default now()
);
create unique index bfarm_data_approval_one_current_idx
  on private.bfarm_data_approval ((is_current)) where is_current;
comment on table private.bfarm_data_approval is 'Append-only BfArM approval decisions. id is identity; is_current is the single current marker demoted by private.bfarm_add_approval.';

create table private.bfarm_release (
  id uuid primary key default gen_random_uuid(),
  source_date date not null,
  source_message_id text,
  source_sender text not null,
  source_sha256 text not null check (source_sha256 ~ '^[0-9a-f]{64}$'),
  received_at timestamptz not null default now(),
  importer_version text not null,
  expected_counts jsonb not null,
  staged_counts jsonb not null default '{}'::jsonb,
  corrects_release_id uuid references private.bfarm_release(id),
  status text not null default 'staging' check (status in ('staging','active','superseded','failed')),
  failure_code text,
  failure_summary text,
  approval_decision_id uuid references private.bfarm_data_approval(id),
  activated_at timestamptz,
  allow_large_drop boolean not null default false,
  allow_same_date_correction boolean not null default false
);
create unique index bfarm_release_message_id_uniq on private.bfarm_release(source_message_id) where source_message_id is not null;
create unique index bfarm_release_sha256_uniq on private.bfarm_release(source_sha256);
create index bfarm_release_source_date_idx on private.bfarm_release(source_date);

create table private.bfarm_medicinal_product (
  release_id uuid not null references private.bfarm_release(id) on delete cascade,
  rmp_key text not null,
  rmp_pzn text not null check (rmp_pzn ~ '^[0-9]{8}$'),
  rmp_count_substance integer not null check (rmp_count_substance >= 1),
  rmp_multiple_ppt text not null check (rmp_multiple_ppt in ('0','1')),
  rmp_pfm_put_short text not null,
  rmp_pfm_put_long text,
  rmp_pfm_name text not null,
  rmp_pfm_term_id text not null,
  rmp_mpd_name text not null,
  normalized_name text not null,
  primary key (release_id,rmp_key)
);
create unique index bfarm_medicinal_product_pzn_uniq on private.bfarm_medicinal_product(release_id,rmp_pzn);
create index bfarm_medicinal_product_name_trgm_idx on private.bfarm_medicinal_product using gin(normalized_name extensions.gin_trgm_ops);

create table private.bfarm_pharmaceutical_product (
  release_id uuid not null references private.bfarm_release(id) on delete cascade,
  rpp_key text not null,
  rmp_key text not null,
  rpp_number integer not null check (rpp_number >= 1),
  rpp_pfm_put_short text not null,
  rpp_pfm_put_long text,
  rpp_pfm_name text not null,
  rpp_pfm_term_id text not null,
  rpp_description text,
  primary key (release_id,rpp_key),
  foreign key (release_id,rmp_key) references private.bfarm_medicinal_product(release_id,rmp_key) deferrable initially deferred
);

create table private.bfarm_substance (
  release_id uuid not null references private.bfarm_release(id) on delete cascade,
  rse_key text not null,
  rpp_key text not null,
  rse_substance_name text not null,
  rse_substance_strength text,
  rse_substance_id text,
  rse_substance_rank integer not null check (rse_substance_rank >= 1),
  primary key (release_id,rse_key),
  foreign key (release_id,rpp_key) references private.bfarm_pharmaceutical_product(release_id,rpp_key) deferrable initially deferred
);
create unique index bfarm_substance_rank_uniq on private.bfarm_substance(release_id,rpp_key,rse_substance_rank);
comment on column private.bfarm_medicinal_product.rmp_count_substance is 'Preserved source count; not equated to staged component substance rows.';

create table private.bfarm_catalog_state (
  id smallint primary key check (id=1),
  active_release_id uuid references private.bfarm_release(id),
  rollback_release_id uuid references private.bfarm_release(id),
  updated_at timestamptz not null default now()
);
insert into private.bfarm_catalog_state(id) values (1);

create table private.bfarm_catalog_transition (
  id bigserial primary key,
  action text not null check (action in ('activate','rollback','prune')),
  from_release_id uuid,
  to_release_id uuid,
  actor text not null,
  reason text,
  created_at timestamptz not null default now()
);

revoke all on all tables in schema private from public, anon, authenticated;
revoke all on all sequences in schema private from public, anon, authenticated;
alter default privileges in schema private revoke all on tables from public, anon, authenticated;
alter default privileges in schema private revoke all on sequences from public, anon, authenticated;

alter table private.bfarm_data_approval enable row level security;
alter table private.bfarm_release enable row level security;
alter table private.bfarm_medicinal_product enable row level security;
alter table private.bfarm_pharmaceutical_product enable row level security;
alter table private.bfarm_substance enable row level security;
alter table private.bfarm_catalog_state enable row level security;
alter table private.bfarm_catalog_transition enable row level security;

create or replace function private.bfarm_normalize_name(p_value text) returns text
language sql immutable strict set search_path = '' as $$
  select trim(regexp_replace(regexp_replace(replace(replace(replace(replace(lower(p_value),'ä','ae'),'ö','oe'),'ü','ue'),'ß','ss'),'[^[:alnum:] ]','','g'),'[[:space:]]+',' ','g'));
$$;

create or replace function private.bfarm_is_valid_pzn(p_pzn text) returns boolean
language plpgsql immutable set search_path = '' as $$
declare total integer:=0; i integer;
begin
  if p_pzn is null or p_pzn !~ '^[0-9]{8}$' then return false; end if;
  for i in 1..7 loop total:=total + substr(p_pzn,i,1)::integer*i; end loop;
  return total % 11 = substr(p_pzn,8,1)::integer;
end; $$;

create or replace function private.bfarm_core_uses() returns text[] language sql immutable set search_path = '' as $$
  select array['store','transform','serve_authenticated_studyu_users','persist_in_research_answers']::text[];
$$;
create or replace function private.bfarm_share_use() returns text[] language sql immutable set search_path = '' as $$
  select array['share_results_beyond_study_editors']::text[];
$$;
create or replace function private.bfarm_current_approval_ok(p_required_uses text[]) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists(select 1 from private.bfarm_data_approval a where a.is_current and a.decision='approved' and (a.valid_until is null or a.valid_until > now()) and p_required_uses <@ a.approved_uses);
$$;

create or replace function private.bfarm_add_approval(p_decision text,p_approved_uses text[] default '{}',p_decided_by text default null,p_evidence_reference text default null,p_valid_until timestamptz default null) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_id uuid;
begin
  if p_decision not in ('approved','denied','revoked') then raise exception 'bfarm_invalid_decision'; end if;
  update private.bfarm_data_approval set is_current=false where is_current;
  insert into private.bfarm_data_approval(is_current,decision,approved_uses,decided_by,evidence_reference,valid_until) values(true,p_decision,p_approved_uses,p_decided_by,p_evidence_reference,p_valid_until) returning id into v_id;
  return v_id;
end; $$;

create or replace function private.jsonb_contains_medication(p_value jsonb) returns boolean
language sql immutable strict set search_path = '' as $$
  with recursive walk(node) as (
    select p_value
    union all
    select child.value from walk w cross join lateral (
      select e.value from jsonb_each(w.node) e where jsonb_typeof(w.node)='object'
      union all
      select e.value from jsonb_array_elements(w.node) e where jsonb_typeof(w.node)='array'
    ) child
  ) select exists(select 1 from walk where jsonb_typeof(node)='object' and node->>'type'='medication');
$$;

create or replace function private.bfarm_releases_with_state_lock() returns setof uuid
language plpgsql security definer set search_path = '' as $$
declare r record;
begin
  perform 1 from private.bfarm_catalog_state where id=1 for update;
  for r in select id from private.bfarm_release where status in ('staging','active','superseded') order by id for update loop return next r.id; end loop;
end; $$;

create or replace function private.bfarm_status_payload(p_release_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('release_id',r.id,'status',r.status,'source_date',r.source_date,'source_message_id',r.source_message_id,'source_sha256',r.source_sha256,'received_at',r.received_at,'expected_counts',r.expected_counts,'staged_counts',r.staged_counts,'corrects_release_id',r.corrects_release_id,'active_release_id',s.active_release_id,'rollback_release_id',s.rollback_release_id,'failure_code',r.failure_code,'failure_summary',r.failure_summary)
  from private.bfarm_release r cross join private.bfarm_catalog_state s where r.id=p_release_id and s.id=1;
$$;

create or replace function private.bfarm_row_keys_ok(p_row jsonb,p_string_keys text[],p_nullable_keys text[],p_number_keys text[]) returns boolean
language plpgsql immutable strict set search_path = '' as $$
declare k text; n integer;
begin
  n:=coalesce(array_length(p_string_keys,1),0)+coalesce(array_length(p_nullable_keys,1),0)+coalesce(array_length(p_number_keys,1),0);
  if (select count(*) from jsonb_object_keys(p_row))<>n then return false; end if;
  foreach k in array p_string_keys loop
    if not (p_row ? k) or jsonb_typeof(p_row -> k) is distinct from 'string' then return false; end if;
  end loop;
  foreach k in array p_nullable_keys loop
    if not (p_row ? k) or jsonb_typeof(p_row -> k) not in ('string','null') then return false; end if;
  end loop;
  foreach k in array p_number_keys loop
    if not (p_row ? k) or jsonb_typeof(p_row -> k) is distinct from 'number' then return false; end if;
  end loop;
  return true;
end; $$;

create or replace function private.bfarm_content_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare s text;
begin
  select status into s from private.bfarm_release where id=coalesce(new.release_id,old.release_id);
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if tg_op='DELETE' then
    if coalesce(current_setting('bfarm.prune_scope',true),'')<>'on' then raise exception 'catalog_rows_are_immutable'; end if;
    return old;
  end if;
  if s<>'staging' then raise exception 'catalog_rows_are_immutable'; end if;
  return new;
end; $$;
create or replace function private.bfarm_medicinal_product_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare s text;
begin
  select status into s from private.bfarm_release where id=coalesce(new.release_id,old.release_id);
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if tg_op='DELETE' then
    if coalesce(current_setting('bfarm.prune_scope',true),'')<>'on' then raise exception 'catalog_rows_are_immutable'; end if;
    return old;
  end if;
  if s<>'staging' then raise exception 'catalog_rows_are_immutable'; end if;
  return new;
end; $$;
create or replace function private.bfarm_pharmaceutical_product_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare s text;
begin
  select status into s from private.bfarm_release where id=coalesce(new.release_id,old.release_id);
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if tg_op='DELETE' then
    if coalesce(current_setting('bfarm.prune_scope',true),'')<>'on' then raise exception 'catalog_rows_are_immutable'; end if;
    return old;
  end if;
  if s<>'staging' then raise exception 'catalog_rows_are_immutable'; end if;
  return new;
end; $$;
create or replace function private.bfarm_substance_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare s text;
begin
  select status into s from private.bfarm_release where id=coalesce(new.release_id,old.release_id);
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if tg_op='DELETE' then
    if coalesce(current_setting('bfarm.prune_scope',true),'')<>'on' then raise exception 'catalog_rows_are_immutable'; end if;
    return old;
  end if;
  if s<>'staging' then raise exception 'catalog_rows_are_immutable'; end if;
  return new;
end; $$;

create or replace function private.bfarm_release_guard() returns trigger
language plpgsql security definer set search_path = '' as $$
declare rollback_scope text;
begin
  rollback_scope:=coalesce(current_setting('bfarm.rollback_scope',true),'off');
  if tg_op='DELETE' then raise exception 'bfarm_release_immutable'; end if;
  if old.status in ('active','superseded') then
    if old.status='active' and new.status='superseded' then
      if (to_jsonb(new)-'status') is distinct from (to_jsonb(old)-'status') then raise exception 'bfarm_release_immutable'; end if;
    elsif old.status='superseded' and new.status='active' and rollback_scope='on' then
      if (to_jsonb(new)-'status'-'activated_at') is distinct from (to_jsonb(old)-'status'-'activated_at') then raise exception 'bfarm_release_immutable'; end if;
    else
      raise exception 'bfarm_release_immutable';
    end if;
  end if;
  if new.status is distinct from old.status and not ((old.status='staging' and new.status in ('active','failed')) or (old.status='failed' and new.status='staging') or (old.status='active' and new.status='superseded') or (old.status='superseded' and new.status='active' and rollback_scope='on')) then raise exception 'bfarm_invalid_release_transition'; end if;
  return new;
end; $$;
create or replace function private.bfarm_study_medication_gate() returns trigger
language plpgsql security definer set search_path = '' as $$
declare nh boolean; oh boolean;
begin
  nh:=coalesce(private.jsonb_contains_medication(new.questionnaire),false) or coalesce(private.jsonb_contains_medication(new.observations),false) or coalesce(private.jsonb_contains_medication(new.interventions),false);
  if tg_op='UPDATE' then oh:=coalesce(private.jsonb_contains_medication(old.questionnaire),false) or coalesce(private.jsonb_contains_medication(old.observations),false) or coalesce(private.jsonb_contains_medication(old.interventions),false); else oh:=false; end if;
  if not nh then return new; end if;
  if tg_op='INSERT' or not oh then
    if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_required' using hint='Current approval must cover store, transform, serve_authenticated_studyu_users, and persist_in_research_answers.'; end if;
  end if;
  if tg_op='UPDATE' and old.status is distinct from new.status and new.status='running' then
    if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_required'; end if;
  end if;
  if new.status='running' and new.result_sharing is distinct from 'private' then
    if not private.bfarm_current_approval_ok(private.bfarm_core_uses() || private.bfarm_share_use()) then raise exception 'bfarm_result_sharing_restricted'; end if;
  end if;
  return new;
end; $$;
create trigger bfarm_study_medication_gate_trg before insert or update on public.study for each row execute procedure private.bfarm_study_medication_gate();
-- Import lifecycle RPCs. Every function is SECURITY DEFINER and only service_role receives EXECUTE.
create or replace function public.begin_bfarm_import(
  p_source_date date, p_message_id text, p_sender text, p_attachment_sha256 text,
  p_expected_counts jsonb, p_importer_version text, p_corrects_release_id uuid default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare r private.bfarm_release%rowtype; v_id uuid; k text; v jsonb;
begin
  if p_attachment_sha256 is null or p_attachment_sha256 !~ '^[0-9a-f]{64}$' then raise exception 'bfarm_invalid_sha256'; end if;
  if p_source_date is null or coalesce(p_sender,'')='' or coalesce(p_importer_version,'')='' then raise exception 'bfarm_invalid_import_arguments'; end if;
  if p_expected_counts is null or jsonb_typeof(p_expected_counts)<>'object' or (select count(*) from jsonb_object_keys(p_expected_counts))<>3 then raise exception 'bfarm_invalid_expected_counts'; end if;
  for k,v in select key,value from jsonb_each(p_expected_counts) loop
    if k not in ('medicinal_products','pharmaceutical_products','substances') or jsonb_typeof(v)<>'number' or (v#>>'{}') !~ '^[1-9][0-9]*$' then raise exception 'bfarm_invalid_expected_counts'; end if;
  end loop;
  if p_message_id is not null and exists(select 1 from private.bfarm_release where source_message_id=p_message_id and source_sha256 is distinct from p_attachment_sha256) then raise exception 'bfarm_identity_conflict'; end if;
  if exists(select 1 from private.bfarm_release where source_sha256=p_attachment_sha256 and source_message_id is distinct from p_message_id) then raise exception 'bfarm_identity_conflict'; end if;
  select * into r from private.bfarm_release where source_sha256=p_attachment_sha256 or (p_message_id is not null and source_message_id=p_message_id) limit 1 for update;
  if found then
    if r.source_message_id is distinct from p_message_id or r.source_sha256 is distinct from p_attachment_sha256 or r.source_date is distinct from p_source_date or r.corrects_release_id is distinct from p_corrects_release_id then raise exception 'bfarm_identity_conflict'; end if;
    if r.status='failed' then update private.bfarm_release set status='staging',failure_code=null,failure_summary=null where id=r.id; end if;
    return r.id;
  end if;
  if exists(select 1 from private.bfarm_release where source_date=p_source_date and source_sha256<>p_attachment_sha256) then raise exception 'bfarm_same_date_conflict'; end if;
  insert into private.bfarm_release(source_date,source_message_id,source_sender,source_sha256,importer_version,expected_counts,corrects_release_id) values(p_source_date,p_message_id,p_sender,p_attachment_sha256,p_importer_version,p_expected_counts,p_corrects_release_id) returning id into v_id;
  return v_id;
end; $$;

create or replace function public.stage_bfarm_medicinal_products(p_release_id uuid,p_rows jsonb) returns integer
language plpgsql security definer set search_path = '' as $$
declare s text; row jsonb; n integer:=0; rc integer; k text; old record;
begin
  perform private.bfarm_releases_with_state_lock();
  select status into s from private.bfarm_release where id=p_release_id for update;
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if s<>'staging' then raise exception 'bfarm_release_not_staging'; end if;
  if p_rows is null or jsonb_typeof(p_rows)<>'array' or jsonb_array_length(p_rows)>500 then raise exception 'bfarm_invalid_rows'; end if;
  for row in select value from jsonb_array_elements(p_rows) loop
    if not private.bfarm_row_keys_ok(row,array['rmp_key','rmp_pzn','rmp_multiple_ppt','rmp_pfm_put_short','rmp_pfm_name','rmp_pfm_term_id','rmp_mpd_name'],array['rmp_pfm_put_long'],array['rmp_count_substance']) then raise exception 'bfarm_invalid_row'; end if;
    k:=row->>'rmp_key';
    if k='' or not private.bfarm_is_valid_pzn(row->>'rmp_pzn') then raise exception 'bfarm_invalid_pzn'; end if;
    select * into old from private.bfarm_medicinal_product where release_id=p_release_id and rmp_key=k;
    if found and (old.rmp_pzn,old.rmp_count_substance,old.rmp_multiple_ppt,old.rmp_pfm_put_short,old.rmp_pfm_put_long,old.rmp_pfm_name,old.rmp_pfm_term_id,old.rmp_mpd_name,old.normalized_name) is distinct from (row->>'rmp_pzn',(row->>'rmp_count_substance')::integer,row->>'rmp_multiple_ppt',row->>'rmp_pfm_put_short',row->>'rmp_pfm_put_long',row->>'rmp_pfm_name',row->>'rmp_pfm_term_id',row->>'rmp_mpd_name',private.bfarm_normalize_name(row->>'rmp_mpd_name')) then raise exception 'bfarm_repeat_key_content_changed'; end if;
    insert into private.bfarm_medicinal_product(release_id,rmp_key,rmp_pzn,rmp_count_substance,rmp_multiple_ppt,rmp_pfm_put_short,rmp_pfm_put_long,rmp_pfm_name,rmp_pfm_term_id,rmp_mpd_name,normalized_name) values(p_release_id,k,row->>'rmp_pzn',(row->>'rmp_count_substance')::integer,row->>'rmp_multiple_ppt',row->>'rmp_pfm_put_short',row->>'rmp_pfm_put_long',row->>'rmp_pfm_name',row->>'rmp_pfm_term_id',row->>'rmp_mpd_name',private.bfarm_normalize_name(row->>'rmp_mpd_name')) on conflict(release_id,rmp_key) do update set rmp_pzn=excluded.rmp_pzn where false;
    get diagnostics rc=row_count; n:=n+rc;
  end loop;
  update private.bfarm_release set staged_counts=jsonb_build_object('medicinal_products',(select count(*) from private.bfarm_medicinal_product where release_id=p_release_id),'pharmaceutical_products',(select count(*) from private.bfarm_pharmaceutical_product where release_id=p_release_id),'substances',(select count(*) from private.bfarm_substance where release_id=p_release_id)) where id=p_release_id;
  return n;
end; $$;

create or replace function public.stage_bfarm_pharmaceutical_products(p_release_id uuid,p_rows jsonb) returns integer
language plpgsql security definer set search_path = '' as $$
declare s text; row jsonb; n integer:=0; rc integer; k text; old record;
begin
  perform private.bfarm_releases_with_state_lock(); select status into s from private.bfarm_release where id=p_release_id for update;
  if s is null then raise exception 'bfarm_release_not_found'; end if; if s<>'staging' then raise exception 'bfarm_release_not_staging'; end if;
  if p_rows is null or jsonb_typeof(p_rows)<>'array' or jsonb_array_length(p_rows)>500 then raise exception 'bfarm_invalid_rows'; end if;
  for row in select value from jsonb_array_elements(p_rows) loop
    if not private.bfarm_row_keys_ok(row,array['rpp_key','rmp_key','rpp_pfm_put_short','rpp_pfm_name','rpp_pfm_term_id'],array['rpp_pfm_put_long','rpp_description'],array['rpp_number']) then raise exception 'bfarm_invalid_row'; end if;
    k:=row->>'rpp_key'; if k='' or row->>'rmp_key'='' then raise exception 'bfarm_invalid_row'; end if;
    select * into old from private.bfarm_pharmaceutical_product where release_id=p_release_id and rpp_key=k;
    if found and (old.rmp_key,old.rpp_number,old.rpp_pfm_put_short,old.rpp_pfm_put_long,old.rpp_pfm_name,old.rpp_pfm_term_id,old.rpp_description) is distinct from (row->>'rmp_key',(row->>'rpp_number')::integer,row->>'rpp_pfm_put_short',row->>'rpp_pfm_put_long',row->>'rpp_pfm_name',row->>'rpp_pfm_term_id',row->>'rpp_description') then raise exception 'bfarm_repeat_key_content_changed'; end if;
    insert into private.bfarm_pharmaceutical_product(release_id,rpp_key,rmp_key,rpp_number,rpp_pfm_put_short,rpp_pfm_put_long,rpp_pfm_name,rpp_pfm_term_id,rpp_description) values(p_release_id,k,row->>'rmp_key',(row->>'rpp_number')::integer,row->>'rpp_pfm_put_short',row->>'rpp_pfm_put_long',row->>'rpp_pfm_name',row->>'rpp_pfm_term_id',row->>'rpp_description') on conflict(release_id,rpp_key) do update set rmp_key=excluded.rmp_key where false;
    get diagnostics rc=row_count; n:=n+rc;
  end loop;
  update private.bfarm_release set staged_counts=jsonb_build_object('medicinal_products',(select count(*) from private.bfarm_medicinal_product where release_id=p_release_id),'pharmaceutical_products',(select count(*) from private.bfarm_pharmaceutical_product where release_id=p_release_id),'substances',(select count(*) from private.bfarm_substance where release_id=p_release_id)) where id=p_release_id;
  return n;
end; $$;

create or replace function public.stage_bfarm_substances(p_release_id uuid,p_rows jsonb) returns integer
language plpgsql security definer set search_path = '' as $$
declare s text; row jsonb; n integer:=0; rc integer; k text; old record;
begin
  perform private.bfarm_releases_with_state_lock(); select status into s from private.bfarm_release where id=p_release_id for update;
  if s is null then raise exception 'bfarm_release_not_found'; end if; if s<>'staging' then raise exception 'bfarm_release_not_staging'; end if;
  if p_rows is null or jsonb_typeof(p_rows)<>'array' or jsonb_array_length(p_rows)>500 then raise exception 'bfarm_invalid_rows'; end if;
  for row in select value from jsonb_array_elements(p_rows) loop
    if not private.bfarm_row_keys_ok(row,array['rse_key','rpp_key','rse_substance_name'],array['rse_substance_strength','rse_substance_id'],array['rse_substance_rank']) then raise exception 'bfarm_invalid_row'; end if;
    k:=row->>'rse_key'; if k='' or row->>'rpp_key'='' then raise exception 'bfarm_invalid_row'; end if;
    select * into old from private.bfarm_substance where release_id=p_release_id and rse_key=k;
    if found and (old.rpp_key,old.rse_substance_name,old.rse_substance_strength,old.rse_substance_id,old.rse_substance_rank) is distinct from (row->>'rpp_key',row->>'rse_substance_name',row->>'rse_substance_strength',row->>'rse_substance_id',(row->>'rse_substance_rank')::integer) then raise exception 'bfarm_repeat_key_content_changed'; end if;
    insert into private.bfarm_substance(release_id,rse_key,rpp_key,rse_substance_name,rse_substance_strength,rse_substance_id,rse_substance_rank) values(p_release_id,k,row->>'rpp_key',row->>'rse_substance_name',row->>'rse_substance_strength',row->>'rse_substance_id',(row->>'rse_substance_rank')::integer) on conflict(release_id,rse_key) do update set rpp_key=excluded.rpp_key where false;
    get diagnostics rc=row_count; n:=n+rc;
  end loop;
  update private.bfarm_release set staged_counts=jsonb_build_object('medicinal_products',(select count(*) from private.bfarm_medicinal_product where release_id=p_release_id),'pharmaceutical_products',(select count(*) from private.bfarm_pharmaceutical_product where release_id=p_release_id),'substances',(select count(*) from private.bfarm_substance where release_id=p_release_id)) where id=p_release_id;
  return n;
end; $$;
create or replace function public.get_bfarm_import_status(p_release_id uuid) returns jsonb
language sql stable security definer set search_path = '' as $$ select private.bfarm_status_payload(p_release_id); $$;
create or replace function public.get_bfarm_active_release() returns jsonb
language sql stable security definer set search_path = '' as $$ select private.bfarm_status_payload(active_release_id) from private.bfarm_catalog_state where id=1; $$;

create or replace function public.mark_bfarm_import_failed(p_release_id uuid,p_code text,p_summary text) returns void
language plpgsql security definer set search_path = '' as $$
declare s text;
begin
  if p_code is null or p_code='' or length(p_code)>64 or p_code ~ '[[:cntrl:]]' or (p_summary is not null and (length(p_summary)>512 or p_summary ~ '[[:cntrl:]]')) then raise exception 'bfarm_invalid_failure_report'; end if;
  select status into s from private.bfarm_release where id=p_release_id for update;
  if s is null then raise exception 'bfarm_release_not_found'; end if;
  if s in ('active','superseded') then raise exception 'bfarm_release_not_staging'; end if;
  if s='failed' then return; end if;
  update private.bfarm_release set status='failed',failure_code=p_code,failure_summary=p_summary where id=p_release_id;
end; $$;

create or replace function public.activate_bfarm_import(p_release_id uuid,p_allow_large_drop boolean default false,p_allow_same_date_correction boolean default false) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare r private.bfarm_release%rowtype; a private.bfarm_release%rowtype; st private.bfarm_catalog_state%rowtype; previous uuid;
begin
  perform private.bfarm_releases_with_state_lock();
  select * into st from private.bfarm_catalog_state where id=1;
  select * into r from private.bfarm_release where id=p_release_id;
  if not found then raise exception 'bfarm_release_not_found'; end if;
  if r.status='active' and st.active_release_id=r.id then return private.bfarm_status_payload(r.id)||jsonb_build_object('previous_release_id',st.rollback_release_id); end if;
  if r.status<>'staging' then raise exception 'bfarm_release_not_staging'; end if;
  if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_missing'; end if;
  if coalesce((r.staged_counts->>'medicinal_products')::integer,0)=0 or coalesce((r.staged_counts->>'pharmaceutical_products')::integer,0)=0 or coalesce((r.staged_counts->>'substances')::integer,0)=0 then raise exception 'bfarm_empty_release'; end if;
  if (r.staged_counts->>'medicinal_products')::integer is distinct from (r.expected_counts->>'medicinal_products')::integer or (r.staged_counts->>'pharmaceutical_products')::integer is distinct from (r.expected_counts->>'pharmaceutical_products')::integer or (r.staged_counts->>'substances')::integer is distinct from (r.expected_counts->>'substances')::integer then raise exception 'bfarm_count_mismatch'; end if;
  if exists(select 1 from private.bfarm_medicinal_product where release_id=r.id and not private.bfarm_is_valid_pzn(rmp_pzn)) or exists(select 1 from private.bfarm_medicinal_product where release_id=r.id and rmp_multiple_ppt not in ('0','1')) or exists(select 1 from private.bfarm_pharmaceutical_product where release_id=r.id and rpp_number<1) or exists(select 1 from private.bfarm_substance where release_id=r.id and rse_substance_rank<1) then raise exception 'bfarm_invalid_staged_data'; end if;
  if exists(select 1 from private.bfarm_medicinal_product m where m.release_id=r.id and not exists(select 1 from private.bfarm_pharmaceutical_product p where p.release_id=m.release_id and p.rmp_key=m.rmp_key)) or exists(select 1 from private.bfarm_pharmaceutical_product p where p.release_id=r.id and not exists(select 1 from private.bfarm_substance s where s.release_id=p.release_id and s.rpp_key=p.rpp_key)) or exists(select 1 from private.bfarm_pharmaceutical_product p where p.release_id=r.id and not exists(select 1 from private.bfarm_medicinal_product m where m.release_id=p.release_id and m.rmp_key=p.rmp_key)) or exists(select 1 from private.bfarm_substance s where s.release_id=r.id and not exists(select 1 from private.bfarm_pharmaceutical_product p where p.release_id=s.release_id and p.rpp_key=s.rpp_key)) then raise exception 'bfarm_reference_integrity'; end if;
  if exists(select 1 from private.bfarm_medicinal_product m where m.release_id=r.id and (m.rmp_multiple_ppt='1') is distinct from ((select count(*) from private.bfarm_pharmaceutical_product p where p.release_id=m.release_id and p.rmp_key=m.rmp_key)>1)) then raise exception 'bfarm_multiple_ppt_semantics'; end if;
  if exists(select 1 from private.bfarm_medicinal_product where release_id=r.id and (coalesce(rmp_pfm_name,'')='' or coalesce(rmp_mpd_name,'')='' or coalesce(rmp_pfm_put_short,'')='' or coalesce(rmp_pfm_term_id,'')='')) then raise exception 'bfarm_missing_required_fields'; end if;
  if st.active_release_id is not null then
    select * into a from private.bfarm_release where id=st.active_release_id;
    if r.source_date<=a.source_date then
      if r.corrects_release_id is null then raise exception 'bfarm_date_not_newer'; end if;
      if r.corrects_release_id<>a.id then raise exception 'bfarm_correction_stale'; end if;
      if not p_allow_same_date_correction or r.source_sha256=a.source_sha256 then raise exception 'bfarm_date_not_newer'; end if;
    end if;
    if not p_allow_large_drop and ((r.staged_counts->>'medicinal_products')::numeric < (a.staged_counts->>'medicinal_products')::numeric*0.9 or (r.staged_counts->>'pharmaceutical_products')::numeric < (a.staged_counts->>'pharmaceutical_products')::numeric*0.9 or (r.staged_counts->>'substances')::numeric < (a.staged_counts->>'substances')::numeric*0.9) then raise exception 'bfarm_large_drop'; end if;
    previous:=a.id;
  end if;
  update private.bfarm_release set status='active',activated_at=now(),approval_decision_id=(select id from private.bfarm_data_approval where is_current),allow_large_drop=p_allow_large_drop,allow_same_date_correction=p_allow_same_date_correction where id=r.id;
  if previous is not null then update private.bfarm_release set status='superseded' where id=previous; end if;
  update private.bfarm_catalog_state set active_release_id=r.id,rollback_release_id=previous,updated_at=now() where id=1;
  insert into private.bfarm_catalog_transition(action,from_release_id,to_release_id,actor,reason) values('activate',previous,r.id,session_user,format('allow_large_drop=%s;allow_same_date_correction=%s',p_allow_large_drop,p_allow_same_date_correction));
  return private.bfarm_status_payload(r.id)||jsonb_build_object('previous_release_id',previous);
end; $$;

create or replace function public.prune_bfarm_releases(p_keep integer default 2) returns integer
language plpgsql security definer set search_path = '' as $$
declare st private.bfarm_catalog_state%rowtype; ids uuid[]; n integer; m integer; p integer; s integer;
begin
  if p_keep is null or p_keep<0 then raise exception 'bfarm_invalid_prune_keep'; end if;
  perform private.bfarm_releases_with_state_lock(); select * into st from private.bfarm_catalog_state where id=1;
  select coalesce(array_agg(id),'{}') into ids from (select id from private.bfarm_release where id is distinct from st.active_release_id and id is distinct from st.rollback_release_id order by activated_at desc nulls last,id desc offset p_keep) q;
  select count(*) into m from private.bfarm_medicinal_product where release_id=any(ids); select count(*) into p from private.bfarm_pharmaceutical_product where release_id=any(ids); select count(*) into s from private.bfarm_substance where release_id=any(ids); n:=m+p+s;
  perform set_config('bfarm.prune_scope','on',true);
  delete from private.bfarm_medicinal_product where release_id=any(ids);
  perform set_config('bfarm.prune_scope','off',true);
  insert into private.bfarm_catalog_transition(action,actor,reason) values('prune',session_user,'keep='||p_keep);
  return n;
end; $$;

create or replace function private.bfarm_project_product(p_product private.bfarm_medicinal_product,p_release_date date) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('pzn',p_product.rmp_pzn,'officialName',p_product.rmp_mpd_name,'activeIngredientCount',p_product.rmp_count_substance,'dosageForm',jsonb_build_object('patientFriendlyShort',p_product.rmp_pfm_put_short,'patientFriendlyLong',p_product.rmp_pfm_put_long,'bfarmName',p_product.rmp_pfm_name,'bfarmTermId',p_product.rmp_pfm_term_id),'components',coalesce((select jsonb_agg(jsonb_build_object('key',p.rpp_key,'number',p.rpp_number,'dosageForm',jsonb_build_object('patientFriendlyShort',p.rpp_pfm_put_short,'patientFriendlyLong',p.rpp_pfm_put_long,'bfarmName',p.rpp_pfm_name,'bfarmTermId',p.rpp_pfm_term_id),'description',p.rpp_description,'activeIngredients',coalesce((select jsonb_agg(jsonb_build_object('key',s.rse_key,'name',s.rse_substance_name,'strength',s.rse_substance_strength,'bfarmSubstanceId',s.rse_substance_id,'rank',s.rse_substance_rank) order by s.rse_substance_rank,s.rse_key) from private.bfarm_substance s where s.release_id=p.release_id and s.rpp_key=p.rpp_key),'[]'::jsonb)) order by p.rpp_number,p.rpp_key) from private.bfarm_pharmaceutical_product p where p.release_id=p_product.release_id and p.rmp_key=p_product.rmp_key),'[]'::jsonb),'source',jsonb_build_object('name','BfArM Referenzdatenbank gemäß § 31b SGB V','releaseDate',to_char(p_release_date,'YYYY-MM-DD')));
$$;

create or replace function public.lookup_bfarm_medication(p_pzn text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare rid uuid; d date; result jsonb;
begin
  if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_missing'; end if;
  if not private.bfarm_is_valid_pzn(p_pzn) then raise exception 'bfarm_invalid_pzn'; end if;
  select s.active_release_id,r.source_date into rid,d from private.bfarm_catalog_state s left join private.bfarm_release r on r.id=s.active_release_id where s.id=1;
  if rid is null then return null; end if;
  select private.bfarm_project_product(m,d) into result from private.bfarm_medicinal_product m where m.release_id=rid and m.rmp_pzn=p_pzn;
  return result;
end; $$;

create or replace function public.search_bfarm_medications(p_query text,p_limit integer default 20,p_offset integer default 0) returns setof jsonb
language plpgsql stable security definer set search_path = '' as $$
declare q text; lim integer; off integer; rid uuid; d date;
begin
  if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_missing'; end if;
  q:=coalesce(private.bfarm_normalize_name(p_query),''); if char_length(q)<2 then raise exception 'bfarm_query_too_short'; end if;
  lim:=greatest(1,least(50,coalesce(p_limit,20))); off:=greatest(0,coalesce(p_offset,0));
  select s.active_release_id,r.source_date into rid,d from private.bfarm_catalog_state s left join private.bfarm_release r on r.id=s.active_release_id where s.id=1;
  if rid is null then return; end if;
  return query select private.bfarm_project_product(m,d) from private.bfarm_medicinal_product m where m.release_id=rid and (strpos(m.normalized_name,q)>0 or m.normalized_name operator(extensions.%) q) order by (m.normalized_name=q) desc,(strpos(m.normalized_name,q)=1) desc,extensions.similarity(m.normalized_name,q) desc,m.rmp_mpd_name,m.rmp_pzn limit lim offset off;
end; $$;

create or replace function private.bfarm_rollback_catalog(p_target_release_id uuid,p_reason text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare st private.bfarm_catalog_state%rowtype; cur private.bfarm_release%rowtype; target private.bfarm_release%rowtype;
begin
  perform private.bfarm_releases_with_state_lock(); select * into st from private.bfarm_catalog_state where id=1;
  if st.rollback_release_id is null or st.rollback_release_id<>p_target_release_id then raise exception 'bfarm_rollback_target_mismatch'; end if;
  if not private.bfarm_current_approval_ok(private.bfarm_core_uses()) then raise exception 'bfarm_approval_missing'; end if;
  select * into target from private.bfarm_release where id=p_target_release_id;
  select * into cur from private.bfarm_release where id=st.active_release_id;
  if not found or coalesce((target.staged_counts->>'medicinal_products')::integer,0)=0 or coalesce((target.staged_counts->>'pharmaceutical_products')::integer,0)=0 or coalesce((target.staged_counts->>'substances')::integer,0)=0 then raise exception 'bfarm_rollback_invalid_target'; end if;
  perform set_config('bfarm.rollback_scope','on',true);
  update private.bfarm_release set status='superseded' where id=cur.id;
  update private.bfarm_release set status='active',activated_at=now() where id=target.id;
  perform set_config('bfarm.rollback_scope','off',true);
  update private.bfarm_catalog_state set active_release_id=target.id,rollback_release_id=cur.id,updated_at=now() where id=1;
  insert into private.bfarm_catalog_transition(action,from_release_id,to_release_id,actor,reason) values('rollback',cur.id,target.id,session_user,p_reason);
  return private.bfarm_status_payload(target.id);
end; $$;


revoke execute on all functions in schema private from public, anon, authenticated, service_role;
alter default privileges in schema private revoke execute on functions from public, anon, authenticated, service_role;

do $$ declare f text; begin
  foreach f in array array['begin_bfarm_import','stage_bfarm_medicinal_products','stage_bfarm_pharmaceutical_products','stage_bfarm_substances','get_bfarm_import_status','get_bfarm_active_release','mark_bfarm_import_failed','activate_bfarm_import','prune_bfarm_releases'] loop execute format('revoke execute on function public.%I from public, anon, authenticated',f); end loop;
end $$;
grant execute on function public.begin_bfarm_import(date,text,text,text,jsonb,text,uuid) to service_role;
grant execute on function public.stage_bfarm_medicinal_products(uuid,jsonb) to service_role;
grant execute on function public.stage_bfarm_pharmaceutical_products(uuid,jsonb) to service_role;
grant execute on function public.stage_bfarm_substances(uuid,jsonb) to service_role;
grant execute on function public.get_bfarm_import_status(uuid) to service_role;
grant execute on function public.get_bfarm_active_release() to service_role;
grant execute on function public.mark_bfarm_import_failed(uuid,text,text) to service_role;
grant execute on function public.activate_bfarm_import(uuid,boolean,boolean) to service_role;
grant execute on function public.prune_bfarm_releases(integer) to service_role;
revoke execute on function public.lookup_bfarm_medication(text) from public, anon;
revoke execute on function public.search_bfarm_medications(text,integer,integer) from public, anon;
grant execute on function public.lookup_bfarm_medication(text) to authenticated;
grant execute on function public.search_bfarm_medications(text,integer,integer) to authenticated;

COMMIT;
