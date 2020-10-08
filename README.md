# N of 1 app built at HPI with ❤

We have 3 different Flutter packages all contained in this monorepo.

- StudyU App
- StudyU Study Designer
- Core: shared code

## Setup

### Install Flutter

1. [Setup Flutter](https://flutter.dev/docs/get-started/install)
2. `flutter channel beta`
3. `flutter upgrade`
4. `flutter config --enable-web` To enable [web support](https://flutter.dev/docs/get-started/web).

#### A word about beta

We only developed on beta, since it is required for web and we did not build a have a running production app. It is stable, but some plugins may not be instantly adapted to beta, causing incompatibilities. This was the case a few times, we managed to find fixes in the GitHub issues of those packages.

### Running the app and designer

Inside the respective folders run:

```
flutter pub get
flutter run -t lib/main.dart
```

## Running everything with docker-compose

There exist 4 different compose files to run locally:

- `docker-compose.yml`: Parse, Parse Dashboard
- `docker-compose-full.yml`: Parse, Parse Dashboard, App, Study Designer
- `docker-compose-app.yml`: App
- `docker-compose-designer.yml`: Study Designer

### Start it up
0. Make sure you have Docker and docker-compose installed and running
1. Inside run `docker-compose up --build`. This starts a nodejs docker container running the Parse Server and Dashboard and a MongoDB container, which is used by Parse.
2. You can login with the credentials specified in the env vars: `admin: nof1`
3. You should now be able to see your parse dashboard under http://localhost:1337/dashboard
4. To stop the local parse server you can press CTRL-C in your terminal

To run the study designer with backend:

```
docker-compose -f docker-compose.yml -f docker-compose-designer.yml up --build
```

To run app with backend:

```
docker-compose -f docker-compose.yml -f docker-compose-app.yml up --build
```

To run both with backend:

```
docker-compose -f docker-compose-full.yml up --build
```

### Environments

Above command starts the app or designer using the `development` environment. This currently points to our hosted Heroku instance (will be shut down on Nov 10th).
Environments (Envs) are defined in the core package under [core/lib/environment.dart](./core/lib/environment.dart). It defines the 3 variables used to connect to the Parse Server. Those are definied in the [parse repo](https://gitlab.hpi.de/nof1/parse):

- keyParseApplicationId
- keyParseMasterKey
- keyParseServerUrl

The forEnv configuration uses ENV vars passed when executing flutter run/build.
Recommended for running under different environments without changing the code.
Pass the vars using:

```
flutter build/run android/web/... --dart-define=ENV_VAR1=VALUE1 --dart-define=ENV_VAR2=VALUE2
```

Additionally we have 4 envs for convenience:

- development: Points to our Heroku instance. What we mainly use.
- production: Same as development currently
- local: Used when connecting to a local running parse server.
- localAndroidEmulator: Same as local, but for connecting from an android emulator.

### Coding

Setup your editor of choice: https://flutter.dev/docs/get-started/editor?tab=androidstudio

We prefer Android Studio, Visual Studio Code is also well supported.

To open and edit the project, the best option is to open the whole repository in Android Studio. This allows you to work on all 3 projects at the same time. It is especially useful when navigating the code from app/designer to core, as it is loaded in the same project and you can directly see and edit the code.

To run the app or study designer, you need to create your own run config in Android Studio.

1. Click on add run configuration
2. Click on the `+` in the `Run/Debug Configurations` screen.
3. Select Flutter
4. Give it a name
5. Add the path to the main file. e.g. `<repo-root>/app/lib/main.dart` or a different main file. We recommend having one for the app and one for the designer.

#### Coding on `core`

When developing models in the `core` package you need to make sure the JSON IO code is generated correctly.
To do this we use `build_runner` together with `json_serializable`.

To generate the IO code once, run `flutter pub run build_runner build`.

To watch the model files and continually generate the files, run `flutter pub run build_runner watch`.

Contrary to most recommendations, we commit those generated files to Git. This is needed, because core is a dependency by app and designer and dependencies need to have all files generated.

### Parse

We are using [parse-server](https://github.com/ParsePlatform/parse-server) and [Parse Dashboard](https://github.com/parse-community/parse-dashboard).

[Read the full Parse Server guide here](https://github.com/ParsePlatform/parse-server/wiki/Parse-Server-Guide)

We use the official [parse-server docker image](https://hub.docker.com/r/parseplatform/parse-server)
and the [bitnami parse-dashboard image](https://hub.docker.com/r/bitnami/parse-dashboard),
which is more actively maintained than the official one