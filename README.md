# StudyU built at HPI with ❤

We have 6 different Flutter/Dart packages all contained in this monorepo.

- StudyU App (flutter)
- StudyU Study Designer (flutter)
- Repository Generator (dart web server)
- Analysis Generator (dart CLI script)
- Core: shared code for all 4 applications
- Flutter Common: shared code for all Flutter apps (App, Designer)

## Try it yourself

- [StudyU App](https://app.studyu.health)
- [StudyU Designer](https://designer.studyu.health)

## App Stores

- [Google Play Store](https://play.google.com/store/apps/details?id=health.studyu.app)
- [Apple App Store](https://apps.apple.com/us/app/studyu-health/id1571991198)

## Publications

More information on the scientific background and a detailed description of the StudyU platform is available at:

Konigorski S, Wernicke S, Slosarek T, Zenner AM, Strelow N, Ruether FD, Henschel F, Manaswini M, Pottbäcker F, Edelman JA, Owoyele B, Danieletto M, Golden E, Zweig M, Nadkarni G, Böttinger E (2020). StudyU: a platform for designing and conducting innovative digital N-of-1 trials. arXiv:2012.1420. [https://arxiv.org/abs/2012.14201](https://arxiv.org/abs/2012.14201).

## Setup

### Getting started

1. [Setup Flutter](https://flutter.dev/docs/get-started/install)
2. Make sure both flutter and dart are in your PATH. Run `dart --version` and `flutter --version` to check.
3. Install [Melos](https://melos.invertase.dev/) by running: `dart pub global activate melos`. Melos is used to manage the Monorepo structure and links all packages.
4. Run `melos bootstrap` to generate Android Studio/VS Code IDE files to make sure your IDE is setup properly. This also takes care of downloading all other dependencies (usually `flutter pub get` is used).
5. Open the root folder of the studyu Git repository in Android Studio or VS Code. You should have new run-configurations/tasks added for running the Flutter apps or executing Melos scripts. More information at the [Melos Documentation](https://melos.invertase.dev/).

### Running Flutter apps

Select the run-configuration/task in your IDE to run the Flutter apps.

#### A word about Flutter beta

We used to keep the channel on beta to get the newest changes (web support) and react quickly to breaking changes.
Beta was mostly stable, but sometimes packages were not being updated quickly to address beta changes.
Sometimes we had to include packages from Github PRs, which required some effort to maintain.

Flutter has come a long way since then and now with version 2.8, we switched our code to use stable.
This will make it easier to maintain in the future and reduce the occurrence of breaking changes and workarounds.

### Environments

We use .env (environment) files, to specify the enviroment variables such as Supabase instance and other servers.
We have multiple configurations stored under `flutter_common/lib/envs/`.
By default `.env` (see below) is used, which is our production environment.
We can specify the other files by using e.g. `--dart-define=ENV=.env.local`.
This can also be added to the run configuration in Android Studio or VS Code.

```shell
flutter build/run android/web/... --dart-define=ENV=.env.dev/.env.prod/.env.local/...
```

#### flutter_common/lib/envs/.env file example

```shell
STUDYU_SUPABASE_URL=https://efeapuvwaxtxnlkzlajv.supabase.co
STUDYU_SUPABASE_PUBLIC_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYyNTUwODMyOCwiZXhwIjoxOTQxMDg0MzI4fQ.PUirsx5Zzhj3akaStc5Djid0aAVza3ELoZ5XUTqM91A
STUDYU_PROJECT_GENERATOR_URL=https://studyu-project-generator-2zro3rzera-ew.a.run.app
STUDYU_APP_URL="https://studyu-app.web.app/#/"
```

The great advantage of this new approach
(compared to the previous approach which different entrypoint `main.dart` files)
is that we can set the configuration of already compiled web apps. Previously, once built,
a Flutter web app and its container would be hardcoded to whatever variable was given at the build time.
In the docker-compose setup, we leverage this by copying the config (`.env`)
to the right place in the container, without needing to rebuild.
Now we can publish a docker image and the same image can be used in multiple environments.

Additionally we have 4 envs for convenience. Replace or create for more convenience:

- `.env`: Production database used by default
- `.env.staging`: Staging database, currently not used
- `.env.local`: Used when connecting to a locally running supabase instance.
- `.env.selfhost`: Used when connecting to a self-hosted supabase instance.

Ideally we should only use staging for all our development work or run an instance locally.
This needs to be setup using the new [supabase cli](https://github.com/supabase/cli).

Also see melos commands `app:web:local` and `designer:web:local`.

### Coding on `core`

When developing models in the `core` package you need to make sure the JSON IO code is generated correctly.
To do this we use `build_runner` together with `json_serializable`.

To generate the IO code once, run `melos run generate`.

Contrary to most recommendations, we commit those generated files to Git. This is needed, because core is a dependency by app and designer and dependencies need to have all files generated, when being imported.

### Supabase

We are using [Supabase](https://supabase.com/) as a Backend-as-a-Service provider.
Supabase provides different backend services such as a database, API, authentication, storage service all based around PostgreSQL and other FOSS.

### Local setup

StudyU and Supabase can also be hosted locally via Docker. More information on this [can be found here](docker).