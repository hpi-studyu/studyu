# Overview

The following sections describe how to run StudyU manually without the StudyU CLI.
Be aware that this is more complicated and error-prone than using the CLI. If you
want to use the CLI, refer to [StudyU CLI](README.md) instead.

Since the StudyU CLI is the recommended way to run StudyU, the following sections
might be outdated. If you find any errors, please open an issue or a pull request.

All the following commands are meant to be run from the `docker` directory of
this repository, unless otherwise specified.

## Use Case #1: Dockerize the StudyU platform only

Choose this method if you do not want to setup your own Supabase instance, but
only launch StudyU applications with docker. This might be useful if you want to
run StudyU after you made changes to the codebase.

To start both the StudyU App and the StudyU Designer, simply run `docker compose
-f studyu/docker-compose.yml up`.

If you only want to start a single StudyU application run `docker compose -f
studyu/docker-compose-{module} up`. Make sure to replace `{module}` with one of
the following:

- `app`: Start the StudyU App
- `designer`: Start the StudyU Designer

### Further customize the setup

The default ports are 8080 for the [StudyU App](http://localhost:8080) and 8081
for the [StudyU Designer](http://localhost:8081).

By default the main StudyU database will be used. If you want to use a different
database, more steps are necessary. You can start a managed Supabase project at
[supabase.com](https://supabase.com) and link it with your StudyU instance by
replacing the values for `STUDYU_SUPABASE_URL` and
`STUDYU_SUPABASE_PUBLIC_ANON_KEY` in the file `flutter_common/lib/envs/.env.local`.
Alternatively, you can self-host Supabase on your own as explained in
[Use Case #2](#use-case-2-run-a-self-hosted-supabase-instance-together-with-studyu).

In order to run your StudyU instance under a custom domain or a different port,
refer to [Change hostname or ports](#change-hostname-or-ports).

## Use Case #2: Run a self-hosted Supabase instance together with StudyU

Supabase can be
[self-hosted](https://supabase.com/docs/guides/self-hosting/docker) by design,
since they are open source. We provide a modified version of their docker setup,
specifically optimized to work with StudyU. Everything for this is located in
the [supabase directory](supabase).

Supabase consists out of [several
tools](https://supabase.com/docs/guides/getting-started/architecture) with
PostgreSQL database as the core. To make it easy to perform changes to the
Supabase middleware independently to the database, we have decoupled the
database to `supabase/docker-compose-db.yml`. The database will also hold
StudyU's data. All the other Supabase components are located in the
`supabase/docker-compose.yml` file.

### Configure

Before your own Supabase instance can be started, the default Supabase secrets
need to be changed and assigned to Supabase and StudyU.

1. Create a copy of the example Supabase configuration `cp supabase/.env.example
   supabase/.env`
2. Choose a password for the postgres database (`POSTGRES_PASSWORD`) and a
   `JWT_SECRET` for [Supabase
   Auth](https://supabase.com/docs/learn/auth-deep-dive/auth-deep-dive-jwts)
   with at least 32 characters. Then
   [generate](https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys)
   the corresponding `ANON_KEY` and the `SERVICE_ROLE_KEY` for the API.
3. Replace the default secrets with your newly generated ones in the following
   files:
    - `supabase/.env`
    - `flutter_common/lib/envs/.env.local` (needs to be copied from .env.local.example)
4. Configure the other Supabase settings in `supabase/.env` and StudyU settings
   in `flutter_common/lib/envs/.env.local` according to your wishes.

Otherwise, if a custom domain or port should be used, refer to [Change hostname
or ports](#change-hostname-or-ports).

**BE AWARE THAT SUPABASE IS NOT SECURE BY DEFAULT. READ MORE AT [Advanced
Configuration](#advanced-configuration)**

### Run Supabase and StudyU

Make sure that you thoughtfully completed all the previous steps. Then, start
the components in the following order:

- `docker compose -f supabase/docker-compose-db.yml up` (Start PostgreSQL)
- `docker compose -f supabase/docker-compose.yml up` (Start Supabase)
- `docker compose -f studyu/docker-compose-app.yml up` (Start StudyU App)
- `docker compose -f studyu/docker-compose-designer.yml up` (Start StudyU Designer)

How to start:

Open your local Supabase Studio instance on
[http://localhost:8082](http://localhost:8082)
(username: studyu, password: studyu). The StudyU database scheme is
automatically applied. The app_config table needs to be filled with basic information
describing the StudyU instance. Refer to the `app_config` data in the `/database`
directory.

The default ports are as follows:

- 8080 for [StudyU App](http://localhost:8080)
- 8081 for [StudyU Designer](http://localhost:8081).
- 8082 for [Supabase Studio](http://localhost:8082) (**INSECURE** Username:
  studyu, Password: studyu)

## Use Case #3: Run Supabase and StudyU on different machines

Supabase and StudyU can be deployed on different machines, e.g. for
load-balancing reasons. A mix of the previous use cases will be applied for
configuration purposes.

This set up can also be used for local development by following the instructions
in *Supabase Machine* and running StudyU locally with Flutter.

### Supabase Machine

On the machine where Supabase and PostgreSQL should be run, perform all the
Supabase related configuration steps described in [Configure](#configure) of Use
Case #2 (for local development, it is sufficient to copy the `supabase/.env.example`
to `supabase/.env` and leave everything else as is). However, this will not be
sufficient to access Supabase. Additionally, to the Supabase backend, a nginx
reverse proxy, will need to be started. This is further explained in
[Some words about nginx](#access-the-components-with-nginx).

**BE AWARE THAT SUPABASE IS NOT SECURE BY DEFAULT. READ MORE AT [Advanced
Configuration](#advanced-configuration)**

Run the following services:

- `docker compose -f supabase/docker-compose-db.yml up` (Start PostgreSQL)
- `docker compose -f supabase/docker-compose.yml up` (Start Supabase)
- `docker compose -f nginx/docker-compose-proxy.yml up` (Start the nginx reverse
  proxy)

Operation:

The default ports are as follows:

- 8082 for [Supabase Studio](http://localhost:8082) (**INSECURE** username:
  studyu, password: studyu)

### StudyU Machine

On the second machine where StudyU should be run, replace the default Supabase
values with your custom ones in the file
`flutter_common/lib/envs/.env.local`. Make sure to set `STUDYU_SUPABASE_URL`
to the correct URL of the Supabase instace of your first machine.

- `docker compose -f studyu/docker-compose.yml up` (Start StudyU App and StudyU Designer)

Operation:

The default ports are as follows:

- 8080 for [StudyU App](http://localhost:8080)
- 8081 for [StudyU Designer](http://localhost:8081).

## Advanced Configuration

Some more modifications can be done to customize and secure the setup.

### Secure the Supabase backend

By default, the Supabase backend is not secure if you deploy it, since it can be
accessed by anyone. Supabase itself offers basic authentication access control.
However, the defaults credentials need to be changed in the `supabase/.env` file.

Additional security measures can be added by allowing only certain IP ranges to
access the nginx reverse proxy. Have a look at the
`nginx/conf.d/03_supabase.conf` file on how to enable this.

### Access the components with Nginx

To run flutter apps like StudyU in a web browser, a web server is necessary. We
have chosen to use nginx alpine for this task, since it features a very small
file size and can furthermore act as a reverse proxy. The configuration files
in the `nginx/conf.d/` directory are shipped together with each docker compose
file in the `studyu/` directory. The nginx server serves various purposes.

For the StudyU App and Designer (`nginx/conf.d/01_app.conf` and
`nginx/conf.d/02_designer.conf`), nginx makes sure that all requests to these
flutter apps are forwarded to the index.html which is the entrypoint for flutter
on the web.

When running a self-hosted Supabase instance with our setup, all external ports
are closed by default. Thus, a separate nginx container needs to be started
additionally, serving as a reverse proxy for advanced configuration and security
purposes. All external requests to Supabase outside of docker are tunneled
through the proxy at `nginx/conf.d/03_supabase.conf`. This allows to restrict
access as explained in [Secure the Supabase
backend](#secure-the-supabase-backend). Any changes to the hostname or ports in
any Supabase configuration files must therefore also be applied to the nginx
configuration.

### Change hostname or ports

In order to change the hostname from localhost to a custom domain for StudyU,
the configuration file at `supabase/.env` has to be adapted. Changes also need
to be made to the nginx proxy by modifying the respective `nginx/conf.d/` files
(`01_app.conf`, `02_designer.conf`, `03_supabase.conf`) and replacing `localhost`
with the designated hostname.

The default ports can be changed by replacing the old port with the new one in
the same files as above. Additionally, the `docker-compose-*.yml` files have to
be modified.

### SSL

Since all requests to StudyU and Supabase are going through the nginx server,
SSL can be implemented by adding port 443 to the `docker-compose-*.yml` files,
listening on port 443 in the nginx configuration, and enabling the
`nginx/conf.d/ssl.conf.example` file. Moreover, the ports inside the
`nginx/conf.d/` files should be adapted.

As a next step, SSL certificates can be mounted via a docker volume, or obtained
without cost by using [certbot](https://certbot.eff.org/). There are a variety
of methods on how to make certbot work with nginx available on the web.

## Good to know

- Use `-d` to run containers in the background.
- After making changes to nginx configuration scripts, it is necessary to reload
  nginx. For this, get the name of the docker container with `docker ps`, and
  then `sh` into the container with `docker exec -it <container name> sh` and
  run `/usr/sbin/nginx -s reload` inside the container.
- After making changes to `docker-compose*.yml` files in the `studyu/`
  directory, a rebuild of studyu is necessary. Run `docker compose up --build`.
- In order to stop docker containers from running press CTRL+C or run `docker
  compose -p 'studyu' down --remove-orphans` and `docker compose -p 'supabase'
  down --remove-orphans`.
- When experimenting with Docker setups, it might be necessary
  to [remove previous resources](https://docs.docker.com/engine/reference/commandline/system_prune/)
  in order to make changes visible.
- Moreover, it often helps to clear the cache of your web browser when making
  changes to environment files.

## Automatic install and update script

Currently not usable.

~~The following steps describe the manual installation process. However, in
order to install and update StudyU and a self-hosted Supabase instance
automatically, [this gist
script](https://gist.github.com/johannesvedder/29a384f82e761527fc7acce1d06f78b9)
can also be used.~~
