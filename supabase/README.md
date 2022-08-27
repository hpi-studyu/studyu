# Run StudyU with Docker

## Notice

The files in this directory are adapted from the [Supabase Github repository](https://github.com/supabase/supabase/tree/master/docker)

In case of upgrading this setup from the official repository, custom changes to the docker-compose.yml file have to be considered.

## Description

The StudyU modules can be run with Docker and `docker-compose` which makes it easy to operate.
This allows to store data in a self-hosted Supabase instance data, rather than relying on a public cloud service.
Especially when processing sensitive data, this is a very convenient solution.

## Automatic install and update script

The following steps describe the manual installation process. However, in order to install and update StudyU and a self-hosted Supabase instance automatically, [this gist script](https://gist.github.com/johannesvedder/29a384f82e761527fc7acce1d06f78b9) can also be used.

## Configure

1. Make sure you have Docker and `docker-compose` installed and running
2. Choose a password for the postgres database (`POSTGRES_PASSWORD`) and a `JWT_SECRET` with at least 32 characters.
   Then [generate](https://supabase.com/docs/guides/hosting/overview#api-keys) the corresponding `ANON_KEY` and the `SERVICE_ROLE_KEY` for the API.
3. Insert the secrets and keys into the following files:
    - `supabase/.env`
    - `supabase/volumes/api/kong.yml`
    - `flutter_common/lib/envs/.env` or `flutter_common/lib/envs/.env.selfhost` (see below)
4. Configure `supabase/.env` and your chosen StudyU environment file according to your wishes. Do not forget to replace `localhost` with the correct hostname.

StudyU modules can be run with a managed (`.env`) or a self-hosted (`.env.selfhost`) instance of Supabase.
Depending on your choice, the respective environment file has to be customized.
For more information on how to do this have a look at [Environments](#user-content-environments).

All next steps require that StudyU and Supabase have been configured correctly!

### Run with a managed Supabase instance

1. Run `docker-compose -f docker-compose-<module> up --build`

Make sure to replace `<module>` with one of the following:
- `app`: Start only the StudyU App
- `designer`: Start the StudyU Designer
- `full`: Start the StudyU App and the StudyU Designer

2. The StudyU modules should be available at the URLs you specified in the `.env` file.

### Run with a self-hosted Supabase instance

1. Run Supabase: `cd supabase` and `docker-compose up`

2. Run StudyU: `cd ..` and `docker-compose -f docker-compose-<module>-selfhost.yml up --build` (replace `<module>` as described above)

3. Open your local Supabase Studio instance (default: `http://<YourHostname>:3000`) and navigate to the table editor.
   Add a row to the table `app_config` with the id `prod`. The other fields need to be valid json.

4. The StudyU modules should be available at the URLs you specified in the `.env.selfhost` file.

## Good to know

Use `-d` to run containers in the background.
In order to stop docker containers from running press CTRL+C or run `docker-compose -p 'studyu' down --remove-orphans` and `docker-compose -p 'supabase' down --remove-orphans`.
When experimenting with Docker setups, it might be necessary to [remove previous resources](https://docs.docker.com/engine/reference/commandline/system_prune/) before seeing changes.
Moreover, it often helps to clear the cache of your webbrowser when making changes to environment files.
