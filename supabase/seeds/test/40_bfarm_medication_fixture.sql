-- Test-only approval helper. This file is loaded only by scripts/reset-test-db.sh.
create schema if not exists tests;
create or replace function tests.install_bfarm_test_approval(
  p_approved_uses text[] default null,
  p_valid_until timestamptz default null,
  p_decision text default 'approved'
) returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_addr inet;
  v_uses text[];
  v_id uuid;
begin
  v_addr := inet_server_addr();
  -- Local Supabase test seeds run through a Unix socket inside the database
  -- container, where inet_server_addr() is NULL. A Unix socket is loopback-
  -- local. TCP connections must still report an explicit loopback address.
  if (v_addr is not null and v_addr not in ('127.0.0.1'::inet, '::1'::inet))
     or current_user not in ('postgres', 'supabase_admin') then
    raise exception 'bfarm_loopback_guard';
  end if;
  v_uses := coalesce(p_approved_uses, private.bfarm_core_uses());
  v_id := private.bfarm_add_approval(
    p_decision,
    v_uses,
    'test-fixture',
    'local test fixture only',
    p_valid_until
  );
  return v_id;
end;
$$;
