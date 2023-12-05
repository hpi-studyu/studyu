# Contributing

## Repository Overview

We have different Flutter/Dart packages all contained in this monorepo. The
StudyU platform consists out of the following packages:

- [StudyU App](./app): Participate in N-of-1 trials
- [StudyU Designer v2](./designer_v2): Design and conduct your own N-of-1 trial

Dependency packages:

- [Core](./core): shared code for all applications
- [Flutter Common](./flutter_common): shared code for all Flutter apps (App, Designer)

Outdated and deprecated packages:

- [StudyU Designer v1](./designer): Legacy Designer
- [Repository Generator](./repo_generator): Dart web server
- [Analysis Generator](./notebook_uploader): Dart CLI script)

### Test Instance of deprecated Packages

- [StudyU App v1](https://app-v1.studyu.health)
- [StudyU Designer v1](https://designer-v1.studyu.health)

## Project Setup

### Environments

We use .env (environment) files, to specify the environment variables such as
Supabase instance and other servers. We have multiple configurations stored
under `flutter_common/lib/envs/`. By default `.env` (see below) is used, which
is our production environment. We can specify the other files by using e.g.
`--dart-define=STUDYU_ENV=.env.local`. This can also be added to the run
configuration in Android Studio or VS Code.

```shell
flutter build/run android/web/... --dart-define=STUDYU_ENV=.env.dev/.env.prod/.env.local/...
```

Below is an example for an environment file such as
`flutter_common/lib/envs/.env`.

```shell
STUDYU_SUPABASE_URL=https://efeapuvwaxtxnlkzlajv.supabase.co
STUDYU_SUPABASE_PUBLIC_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyNTUwODMyOCwiZXhwIjoxOTQxMDg0MzI4fQ.PUirsx5Zzhj3akaStc5Djid0aAVza3ELoZ5XUTqM91A
STUDYU_PROJECT_GENERATOR_URL=https://studyu-project-generator-2zro3rzera-ew.a.run.app
STUDYU_APP_URL="https://app.studyu.health/"
```

The great advantage of this new approach (compared to the previous approach
with different entrypoint `main.dart` files) is that we can set the
configuration of already compiled web apps. Previously, once built, a Flutter
web app and its container would be hardcoded to whatever variable was given at
the build time. In the docker-compose setup, we leverage this by copying the
config (`.env`) to the right place in the container, without needing to rebuild.
Now we can publish a docker image and the same image can be used in multiple
environments.

Additionally, we have 4 environment files. Replace or create for more
convenience:

- `.env`: Production database used by default
- `.env.dev`: Development database used by dev branch
- `.env.local`: Used to run StudyU locally with Docker

Ideally we should only use the staging database or a local one for all our
development work.

### Coding on `core`

When developing models in the `core` package you need to make sure the JSON IO
code is generated correctly. To do this we use `build_runner` together with
`json_serializable`.

To generate the IO code once, run `melos run generate`.

Contrary to most recommendations, we commit those generated files to Git. This
is needed, because core is a dependency by app and designer and dependencies
need to have all files generated, when being imported.

### Database and Backend

We are using [Supabase](https://supabase.com/) as a Backend-as-a-Service
provider. Supabase provides different backend services such as a database, API,
authentication, storage service all based around PostgreSQL and other FOSS.

## Local Development

Follow these instructions to set up and use your local development environment.

### Supabase

The following are instructions for how to quickly set up and run a local
Supabase instance for development. More detailed instructions and additional use
cases can be found [here](docker).

#### Containers

1. Copy the [`docker/supabase/.env.example`](docker/supabase/.env.example) to
   create `docker/supabase/.env`. You can leave all values as they are.
2. Create a new docker network `docker network create --driver bridge studyu_network`
3. In [`docker/supabase/`](docker/supabase), run `docker compose -f
   docker-compose-db.yml up` to launch the Postgres database.
4. In [`docker/supabase/`](docker/supabase), run `docker compose up` to launch
   Supabase.
5. In [`docker/nginx/`](docker/nginx), run `docker compose -f docker-compose-proxy.yml
   up` to launch the nginx reverse proxy.

If you use [`kitty terminal`](https://sw.kovidgoyal.net/kitty/), with remote
control enabled and the splits layout, you can omit steps 2-4 and instead run
`.kitty/dev` from the project's root to launch all containers in split windows.

#### Seeding

Both the app as well as the designer require some configuration data to be
present. To add this data, make sure your containers are running (steps 2-4
above), open your local Supabase instance on
[http://localhost:8082](http://localhost:8082), and log in with `studyu` as both
the username as well as the password. Go to *production*, then to the *Table
Editor*, and insert a new row into the `app_config` table. Fill in the following
data.

```plain
id                    prod
app_privacy           { "de": "example.com", "en": "example.com" }
app_terms             { "de": "example.com", "en": "example.com" }
designer_privacy      { "de": "example.com", "en": "example.com" }
designer_terms        { "de": "example.com", "en": "example.com" }
imprint               { "de": "example.com", "en": "example.com" }
contact               { "email": "email@example.com",
                        "phone": "1235678",
                        "website": "example.com",
                        "organization": "example" }
analytics             { "dsn": "example",
                        "enabled": false,
                        "samplingRate": 0 }
```

### Flutter

1. [Setup Flutter](https://flutter.dev/docs/get-started/install)
2. Make sure both flutter and dart are in your PATH. Run `dart --version` and
   `flutter --version` to check.
3. Install [Melos](https://melos.invertase.dev/) by running: `dart pub global
   activate melos`. Melos is used to manage the Monorepo structure and links all
   packages.
4. Run `melos bootstrap` download all other dependencies (usually `flutter pub
   get` is used). If you use Android Studio or VS Code, the files for your IDE
   are also set up.
5. Run `dart pub get` to initialize the StudyU root project. This will apply a
   consistent lint style to all packages.

If you use Android Studio or VS Code, open the root folder of the project. You
should have new run-configurations/tasks added for running the Flutter apps or
executing Melos scripts.

If you prefer working with the CLI, use `melos <script>` to run scripts from the
[`melos.yaml` file](melos.yaml).

To start developing locally, make sure your Supabase containers are running,
your database is seeded, and then execute the melos scripts `dev:designer` or
`dev:app`. You can find more information about Melos in its
[documentation](https://melos.invertase.dev/).
