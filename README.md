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

### Environments

Above command starts the app or designer using the `development` environment. This currently points to our hosted Heroku instance.
Environments (Envs) are defined in the core package under [core/lib/environment.dart](./core/lib/environment.dart). It defines the 3 variables used to connect to the Parse Server. Those are definied in the [parse repo](https://gitlab.hpi.de/nof1/parse):

- keyParseApplicationId
- keyParseMasterKey
- keyParseServerUrl

We have 4 envs for convinience:

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
