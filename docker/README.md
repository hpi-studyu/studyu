# Run StudyU with Docker

The StudyU modules can be run with Docker and `docker compose` allowing StudyU
to be very easy to operate. This makes it possible to quickly deploy code
changes to your own instance or to store data in a self-hosted Supabase instance
data, rather than relying on a public cloud service.

You will need to install Docker to be able to run any of the following scripts.
Make sure you have [Docker](https://docker.com) installed and configured by
running `docker -v`.

For HPI VMs, [this
script](https://gist.github.com/johannesvedder/0fafcbeabe8e069f96085bfedaebd9d0)
can be used to install and setup docker.

## Overview

StudyU can be operated with docker in different ways. The setup is designed to
be flexible and easily adoptable for various purposes. Here we describe the most
common use-cases to get you started quickly.

## Use Case #1: Dockerize the StudyU platform only

Choose this method if you do not want to setup your own Supabase instance, but
only launch StudyU applications with docker. This might be useful if you want to
run StudyU after you made changes to the codebase. Switch to the `.env.local`
[environment
file](https://github.com/hpi-studyu/studyu/blob/dev/flutter_common/lib/envs/.env.local)
to use the StudyU database with local StudyU applications. For this modify the
`docker-compose-*.yml` files you want to run (see below), and replace
`../flutter_common/lib/envs/.env.selfhost` with
`../flutter_common/lib/envs/.env.local` in the section `env_file`.

To start both the StudyU App and the StudyU Designer, simply run `docker compose
up`.

If you only want to start a single StudyU application run `docker compose -f
docker-compose-{module} up`. Make sure to replace `{module}` with one of the
following:

- `app`: Start the StudyU App
- `designer`: Start the StudyU Designer
- `designer_legacy`: Start the outdated Designer v1 (not recommended)

The default ports are 8080 for the [StudyU App](http://localhost:8080) and 8081
for the [StudyU Designer](http://localhost:8081).

If you want to use a different database, more steps are necessary. You can start
a managed Supabase project at [supabase.com](https://supabase.com) and link it
with your StudyU instance by replacing the values for `STUDYU_SUPABASE_URL` and
`STUDYU_SUPABASE_PUBLIC_ANON_KEY` in the file `.env.local`. Alternatively, you
can self-host Supabase on your own as explained in [Use Case # 2](#use-case-2-run-a-self-hosted-supabase-instance-together-with-studyu).

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
Auth](https://supabase.com/docs/learn/auth-deep-dive/auth-deep-dive-jwts) with
at least 32 characters. Then
[generate](https://supabase.com/docs/guides/hosting/overview#api-keys) the
corresponding `ANON_KEY` and the `SERVICE_ROLE_KEY` for the API.
3. Replace the default secrets with your newly generated ones in the following
files:
   - `supabase/.env`
   - `supabase/volumes/api/kong.yml`
   - `flutter_common/lib/envs/.env.selfhost`
4. Configure the other Supabase settings in `supabase/.env` and StudyU settings
in `flutter_common/lib/envs/.env.selfhost` according to your wishes.

Otherwise, if a custom domain or port should be used, refer to [Change hostname
or ports](#change-hostname-or-ports).

**BE AWARE THAT SUPABASE IS NOT SECURE BY DEFAULT. READ MORE AT [Advanced
Configuration](#advanced-configuration)**

### Run Supabase and StudyU

Make sure that you thoughtfully completed all the previous steps and then start
the following services:

In the directory `supabase`:

- `docker compose -f docker-compose-db.yml up` (Start PostgreSQL)
- `docker compose up` (Start Supabase)

In the directory `docker`

- `docker compose up` (Start StudyU App and StudyU Designer)

Open your local Supabase Studio instance on
[http://localhost:8082](http://localhost:8082) (default basic authentication
with username: studyu, password: studyu). The StudyU database scheme is
automatically applied. Navigate to the table editor. Add a row to the table
`app_config` with the id `prod` and insert the links to the terms of services
and privacy policies with respect to their language.

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
Case #2 (for local development, it is sufficient to copy the `.env.example` to
`.env` and leave everything else as is). However, this will not be sufficient to
access Supabase. Additionally, to the Supabase backend, a nginx reverse proxy,
will need to be started. This is further explained in [Some words about
nginx](#some-words-about-nginx).

**BE AWARE THAT SUPABASE IS NOT SECURE BY DEFAULT. READ MORE AT [Advanced
Configuration](#advanced-configuration)**

Run the following services. In the directory `supabase`:

- `docker compose -f docker-compose-db.yml up` (Start PostgreSQL)
- `docker compose up` (Start Supabase)

In the directory `docker`:

- `docker compose -f docker-compose-nginx_only.yml up` (Start the nginx reverse
  proxy)

The default ports are as follows:

- 8082 for [Supabase Studio](http://localhost:8082) (**INSECURE** username:
  studyu, password: studyu)

### StudyU Machine

On the second machine where StudyU should be run, replace the default Supabase
values with your custom ones in the file
`flutter_common/lib/envs/.env.selfhost`. Make sure to set `STUDYU_SUPABASE_URL`
to the correct URL of the Supabase instace of your first machine.

Then run in the directory `docker`:

- `docker compose up` (Start StudyU App and StudyU Designer)

The default ports are as follows:

- 8080 for [StudyU App](http://localhost:8080)
- 8081 for [StudyU Designer](http://localhost:8081).

## Advanced Configuration

Some more modifications can be done to customize and secure the setup.

### Secure the Supabase backend

By default, the Supabase backend is not secure if you deploy it, since it can be
accessed by anyone. Supabase itself does not offer any access control for
Supabase Studio. We have added basic authentication as an easy way to remedy
this potential vulnerability. However, the defaults credentials need to be
changed in the `nginx/.htpasswd` file. Consult your favorite search engine on
how to do this.

Additional security measures can be added by allowing only certain IP ranges to
access the nginx reverse proxy. Have a look at the
`nginx/conf.d/03_supabase.conf` file on how to enable this.

### Some words about nginx

To run flutter apps like StudyU in a web browser, a web server is necessary. We
have chosen to use nginx alpine for this task, since it features a very small
file size and can furthermore act as a reverse proxy. The configuration files
in the `nginx/conf.d/` directory are shipped together with each docker compose
file in the `/docker` directory. The nginx server serves various purposes.

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

In order to change the hostname from localhost to a custom domain for either
StudyU, or the self-hosted Supabase instance, the respective configuration files
at `supabase/.env` and `flutter_common/lib/envs/.env.selfhost` have to be
adapted. Changes also need to be made to the nginx proxy by modifying the
respective `nginx/conf.d/` files (`01_app.conf`, `02_designer.conf`,
`03_supabase.conf`) and replacing `localhost` with the designated hostname.

The default ports can be changed by replacing the old port with the new one in
the same files as above. Additionally, the `docker-compose-*.yml` files have to
be modified.

### SSL

Since all requests to StudyU and Supabase are going through the nginx server,
SSL can be implemented by adding port 443 to the `docker-compose-*.yml` files,
listening on port 443 in the nginx configuration, and enabling the
`nginx/conf.d/ssl.conf.example` file.

As a next step, SSL certificates can be mounted via a docker volume, or obtained
without cost by using [certbot](https://certbot.eff.org/). There are a variety
of methods on how to make certbot work with nginx available on the web.

## Backup the Database

StudyU stores its data with Supabase as a backend that in turn stores its data
in a PostgreSQL database. The data for this database is mapped as a docker
compose volume to `supabase/volumes/db/data` and is persisted between restarts.

For backup purposes you should not create a backup of this directory, but rather
use specific postgres backup tools such as `pg_dump`.

## Update

TODO

## Good to know

- Use `-d` to run containers in the background.
- After making changes to nginx configuration scripts, it is necessary to reload
  nginx. For this, get the name of the docker container with `docker ps`, and
  then `sh` into the container with `docker exec -it <container name> sh` and
  run `/usr/sbin/nginx -s reload` inside the container.
- After making changes to `docker-compose*.yml` files in the `docker/`
  directory, a rebuild of studyu is necessary. Run `docker compose up --build`.
- In order to stop docker containers from running press CTRL+C or run `docker
  compose -p 'studyu' down --remove-orphans` and `docker compose -p 'supabase'
  down --remove-orphans`.
- When experimenting with Docker setups, it might be necessary to [remove
  previous
  resources](https://docs.docker.com/engine/reference/commandline/system_prune/)
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
