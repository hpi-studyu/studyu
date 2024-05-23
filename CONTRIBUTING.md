# Contributing

## Getting Started

1. [Setup Flutter](https://flutter.dev/docs/get-started/install)
2. Make sure both flutter and dart are in your PATH. Run `dart --version` and
   `flutter --version` to check.
3. Clone this repository and `cd` into it.
4. Install [Melos](https://melos.invertase.dev/) by running: `dart pub global
   activate melos`. Melos is used to manage the Monorepo structure and links all
   packages.
5. Run `melos bootstrap` download all other dependencies (usually `flutter pub
   get` is used). If you use Android Studio or VS Code, the files for your IDE
   are also set up.
6. Run `dart pub get` to initialize the StudyU root project. This will apply a
   consistent lint style to all packages.

If you use Android Studio or VS Code, open the root folder of the project. You
should have new run-configurations/tasks added for running the Flutter apps or
executing Melos scripts. Use `melos <script>` to run scripts from the
[`melos.yaml` file](melos.yaml). You can find more information about Melos in
the [Melos documentation](https://melos.invertase.dev/)

## Repository Overview

We have different Flutter/Dart packages all contained in this monorepo. The
StudyU platform consists out of the following packages:

- [StudyU App](./app): Participate in N-of-1 trials
- [StudyU Designer v2](./designer_v2): Design and conduct your own N-of-1 trial

Dependency packages:

- [Core](./core): shared code for all applications
- [Flutter Common](./flutter_common): shared code for all Flutter apps (App, Designer)

## Environments

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
STUDYU_DESIGNER_URL="https://designer.studyu.health/"
```

The great advantage of this new approach (compared to the previous approach
with different entrypoint `main.dart` files) is that we can set the
configuration of already compiled web apps. Previously, once built, a Flutter
web app and its container would be hardcoded to whatever variable was given at
the build time. In the docker-compose setup, we leverage this by copying the
config (`.env`) to the right place in the container, without needing to rebuild.
Now we can publish a docker image and the same image can be used in multiple
environments.

Additionally, we have the following environment files:

- `.env`: Production database used by default
- `.env.dev`: Development database used by dev branch
- `.env.local`: Local database for a custom Supabase instance (used by the
StudyU CLI)

Ideally we should only use the development database or a local one for all our
development work.

## Coding on `core`

When developing models in the `core` package you need to make sure the JSON IO
code is generated correctly. To do this we use `build_runner` together with
`json_serializable`.

To generate the IO code once, run `melos run generate`.

Contrary to most recommendations, we commit those generated files to Git. This
is needed, because core is a dependency by app and designer and dependencies
need to have all files generated, when being imported.

## Code Style

We use the [Effective Dart](https://dart.dev/guides/language/effective-dart)
guidelines for Dart and Flutter. Run `melos format` to format your code and
`melos analyze` to check for any issues. For commit messages, we use the
[Conventional Commits](https://www.conventionalcommits.org) format. For any new
features or bug fixes, create a new branch and open a pull request.

Please make sure to follow these guidelines when contributing to the project.

## Database and Backend

We are using a self-hosted instance of [Supabase](https://supabase.com/) as a
Backend-as-a-Service provider. Supabase provides different backend services
such as a database, API, authentication, storage service all based around
PostgreSQL and other FOSS. Since Supabase is open-source, we are hosting our
own instance to ensure data privacy and security.
