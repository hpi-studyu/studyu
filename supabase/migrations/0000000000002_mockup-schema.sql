BEGIN;

-- We want to store all of this in the mockup schema to keep it
-- separate from any application data
CREATE SCHEMA IF NOT EXISTS mockup;

-- anon and authenticated should have access to mockup schema
GRANT USAGE ON SCHEMA mockup TO anon, authenticated;
-- Don't allow public to execute any functions in the mockup schema
ALTER DEFAULT PRIVILEGES IN SCHEMA mockup REVOKE EXECUTE ON FUNCTIONS FROM public;
-- Grant execute to anon and authenticated for mockup
ALTER DEFAULT PRIVILEGES IN SCHEMA mockup GRANT EXECUTE ON FUNCTIONS TO anon, authenticated;

/*
    * This function is used to create a user in the `auth.users` table.
    *
    * @param email - The email address of the user
    * @param password - The password of the user
    *
    * @returns user_id - The UUID of the user in the `auth.users` table
*/
CREATE OR REPLACE FUNCTION mockup.create_user(
    email text,
    password text
) RETURNS uuid AS $$
  declare
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := extensions.crypt(password, extensions.gen_salt('bf', 12));

  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    ('00000000-0000-0000-0000-000000000000', user_id, 'authenticated', 'authenticated', email, encrypted_pw, now() at time zone 'utc', now() at time zone 'utc', now() at time zone 'utc', '{"provider":"email","providers":["email"]}', '{}', now() at time zone 'utc', now() at time zone 'utc', '', '', '', '');

  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', now() at time zone 'utc', now() at time zone 'utc', now() at time zone 'utc');

  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

/*
    * This function is used to get a user by their email address.
    *
    * @param email_needle - The email of the user to get
    *
    * @returns user - The user object
*/
CREATE OR REPLACE FUNCTION mockup.get_user(
    email_needle text
) RETURNS json AS $$
     DECLARE
         supabase_user json;
     BEGIN
         SELECT json_build_object('id', id, 'email', email, 'phone', phone, 'raw_user_meta_data', raw_user_meta_data) into supabase_user FROM auth.users WHERE email = email_needle LIMIT 1;
         if supabase_user is null OR supabase_user -> 'id' IS NULL then
             RAISE EXCEPTION 'User with email % not found', identifier;
         end if;
         RETURN supabase_user;
     END;
 $$ LANGUAGE plpgsql;

COMMIT;
