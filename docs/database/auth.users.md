# auth.users

## Description

Auth: Stores user login data within a secure schema.

## Columns

| Name | Type | Default | Nullable | Children | Parents | Comment |
| ---- | ---- | ------- | -------- | -------- | ------- | ------- |
| instance_id | uuid |  | true |  |  |  |
| id | uuid |  | false | [storage.buckets](storage.buckets.md) [storage.objects](storage.objects.md) |  |  |
| aud | varchar(255) |  | true |  |  |  |
| role | varchar(255) |  | true |  |  |  |
| email | varchar(255) |  | true |  |  |  |
| encrypted_password | varchar(255) |  | true |  |  |  |
| confirmed_at | timestamp with time zone |  | true |  |  |  |
| invited_at | timestamp with time zone |  | true |  |  |  |
| confirmation_token | varchar(255) |  | true |  |  |  |
| confirmation_sent_at | timestamp with time zone |  | true |  |  |  |
| recovery_token | varchar(255) |  | true |  |  |  |
| recovery_sent_at | timestamp with time zone |  | true |  |  |  |
| email_change_token | varchar(255) |  | true |  |  |  |
| email_change | varchar(255) |  | true |  |  |  |
| email_change_sent_at | timestamp with time zone |  | true |  |  |  |
| last_sign_in_at | timestamp with time zone |  | true |  |  |  |
| raw_app_meta_data | jsonb |  | true |  |  |  |
| raw_user_meta_data | jsonb |  | true |  |  |  |
| is_super_admin | boolean |  | true |  |  |  |
| created_at | timestamp with time zone |  | true |  |  |  |
| updated_at | timestamp with time zone |  | true |  |  |  |

## Constraints

| Name | Type | Definition |
| ---- | ---- | ---------- |
| users_pkey | PRIMARY KEY | PRIMARY KEY (id) |
| users_email_key | UNIQUE | UNIQUE (email) |

## Indexes

| Name | Definition |
| ---- | ---------- |
| users_pkey | CREATE UNIQUE INDEX users_pkey ON auth.users USING btree (id) |
| users_email_key | CREATE UNIQUE INDEX users_email_key ON auth.users USING btree (email) |
| users_instance_id_email_idx | CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, email) |
| users_instance_id_idx | CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id) |

## Triggers

| Name | Definition |
| ---- | ---------- |
| on_auth_user_created | CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION handle_new_user() |

## Relations

![er](auth.users.svg)

---

> Generated by [tbls](https://github.com/k1LoW/tbls)
