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

## Run with Docker

The StudyU modules can be run with Docker and `docker-compose` which makes it easy to operate.
This allows to store data in a self-hosted Supabase instance data, rather than relying on a public cloud service.
Especially, when it comes to sensitive data, this is a very convenient solution.

### Automatic install and update script

The following steps describe the manual installation process. However, in order to install and update StudyU and a self-hosted Supabase instance automatically, [this gist script](https://gist.github.com/johannesvedder/29a384f82e761527fc7acce1d06f78b9) can also be used.

### Configure

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

### Automatic deployment script

### Good to know

Use `-d` to run containers in the background.
In order to stop docker containers from running press CTRL+C or run `docker-compose -p 'studyu' down --remove-orphans` and `docker-compose -p 'supabase' down --remove-orphans`.
When experimenting with Docker setups, it might be necessary to [remove previous resources](https://docs.docker.com/engine/reference/commandline/system_prune/) before seeing changes.
Moreover, it often helps to clear the cache of your webbrowser when making changes to environment files.