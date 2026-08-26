# Contributing

## Getting Started

1. Install [FVM](https://fvm.app/documentation/getting-started/installation).
2. Clone this repository and open its root directory.
3. Run `fvm install` to install the Flutter SDK version defined in `.fvmrc`.
4. Run `./setup.sh` to install Melos, dependencies, and workspace links.
5. Run `fvm exec melos setup` to configure the tracked Git hooks.

The root [`pubspec.yaml`](pubspec.yaml) is the command catalog. Run its Melos
scripts as `fvm exec melos <script>`.

## Flutter SDK Setup

FVM manages the Flutter SDK for this repository. Refer to the [official FVM
installation guide](https://fvm.app/documentation/getting-started/installation) for
installation requirements and the [FVM workflow documentation](https://fvm.app/documentation/guides/workflows)
for general FVM usage.

The committed [`.fvmrc`](.fvmrc) pins this repository to Flutter `3.44.6`. The
project version takes precedence over a global Flutter version. All commands below
must be run from the repository root.

### Set up the repository

After installing FVM, run:

```bash
fvm install
fvm flutter --version
fvm dart --version
./setup.sh
fvm exec melos setup
```

`fvm install` reads `.fvmrc` and creates the ignored `.fvm/flutter_sdk` link to the
cached project SDK. The root `pubspec.yaml` points Melos to the same SDK through
`melos.sdkPath`; no manual `MELOS_SDK_PATH` export is required.

Use the project SDK for development commands:

```bash
fvm flutter test
fvm dart analyze
fvm exec melos test
fvm exec melos dev:app
fvm exec melos local:designer_v2
```

Global FVM configuration is optional for Flutter work outside this repository. It
does not change the StudyU SDK. See FVM’s [global version documentation](https://fvm.app/documentation/guides/global-configuration)
if you need to configure it.

### Change the project Flutter version

Do not edit `.fvmrc` by hand. From the repository root, use FVM to select the new
version:

```bash
fvm use <flutter-version>
fvm flutter --version
```

Review the `.fvmrc` change and run the relevant generation, analysis, and test
checks before sharing it. Keep `.fvm/` ignored and commit `.fvmrc`.

### IDE configuration

Open the repository root, not an individual package. Configure the IDE to use the
project SDK link at `.fvm/flutter_sdk`.

For VS Code or VSCodium, set `dart.flutterSdkPath` to `.fvm/flutter_sdk`. Refer to
the [FVM VS Code documentation](https://fvm.app/documentation/guides/vscode) for
FVM-specific editor integration.

For Android Studio or IntelliJ:

1. Open **Settings/Preferences > Languages & Frameworks > Flutter**.
2. Set **Flutter SDK path** to `<repository-root>/.fvm/flutter_sdk`.
3. If required, set the Dart SDK path to
   `<repository-root>/.fvm/flutter_sdk/bin/cache/dart-sdk`.
4. Re-select the project SDK path after changing versions with `fvm use` if the IDE
   has resolved the previous symlink target.

For project-specific diagnostics, run `fvm doctor` from the repository root.

## Environments

Environment files live in `flutter_common/lib/envs/`. Use the `dev:*` Melos
scripts for the development environment and `local:*` for a local Supabase
instance. The default `.env` targets production and must not be used for routine
development. See [`supabase/README.md`](supabase/README.md) for local backend setup.

## Coding on `core`

Changes to the models in the `core` package requires to perform a re-generation
of the JSON IO code. The toolchain we use for this consists of [build_runner](https://pub.dev/packages/build_runner)
and [json_serializable](https://pub.dev/packages/json_serializable).

After changing models, run `fvm exec melos generate`.

Contrary to most recommendations, we commit those generated files (`*.g.dart`) to Git. This
is needed, because `core` is a dependency of the StudyU App and the StudyU Designer
and dependencies need to have all files generated, when being imported.

## Code Style

The shared Dart and Flutter lint rules are defined in [`analysis_options.yaml`](analysis_options.yaml).
The tracked pre-commit hook runs [`scripts/pre-commit-check`](scripts/pre-commit-check), which
formats, generates affected output, and analyzes the workspace. Run
`fvm exec melos qualitycheck` only for a full CI-style workspace check or when explicitly requested.

## Frontend

We use Flutter's Material Design with a custom light theme defined in `app/lib/theme.dart`.
Prefer `Theme.of(context).colorScheme` over hardcoded colors. For responsive layouts, use
`LayoutBuilder` and `MediaQuery`. Localization is handled via `flutter_localizations` with
ARB files in `app/lib/l10n/`.

## Commits

We use [Conventional Commits](https://www.conventionalcommits.org) for all
commit messages. The format is:

```
<type>[(<scope>)]: <description>
```

Allowed types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`,
`perf`, `ci`, `build`, `revert`.

Allowed scopes: `app`, `designer`, `core`, `flutter_common`, `db`. The scope is
optional. Write the description in lowercase and do not end it with a period.

Examples from this repo:

- `fix: remove redundant fitbit label`
- `feat(designer): move fitbit credentials to study-level`
- `chore: update deps + ios deps`

## Pull Requests

For any new feature or bug fix, create a branch and open a pull request. Follow the
pull request template and these conventions:

- Branch: `<type>/studyu-<ticket-number>-<short-description>`
- PR title: `STUDYU-<ticket-number>: <type>[optional scope]: <description>`
- PR description: include a direct link to the matching Jira ticket.

## Code Reviews — Conventional Comments

We use [Conventional Comments](https://conventionalcomments.org/) for all review
feedback. This standard makes the intent behind each comment clear and
actionable.

### Format

```
<label> [decorations]: <subject>

[discussion]
```

### Labels

| Label | Purpose |
| --- | --- |
| **praise:** | Highlight something sincerely positive when warranted. |
| **nitpick:** | Trivial preference-based request. Non-blocking by nature. |
| **suggestion:** | Propose an improvement. Be explicit about *what* and *why*. |
| **issue:** | Highlight a specific problem. Pair with a suggestion when possible. |
| **todo:** | Small, necessary change that must be done before merging. |
| **question:** | Ask for clarification when you're unsure if something is a problem. |
| **thought:** | Share an idea that came up during review. Non-blocking. |
| **chore:** | A process-related task needed before acceptance (e.g., run CI job). |
| **note:** | Non-blocking observation the reader should be aware of. |

### Decorations

Add decorations in parentheses for extra context:

- **(non-blocking)** — should not prevent merging
- **(blocking)** — must be resolved before merging
- **(if-minor)** — resolve only if the fix is trivial

### Examples

```
suggestion (non-blocking): Consider extracting this into a helper method.

It appears in three places and the logic is identical.
```

```
issue (blocking): This query fetches all rows without pagination.

On tables with 10k+ rows this will timeout. Can we add a LIMIT clause?
```

```
praise: Great use of the builder pattern here — very readable.
```

## Database and Backend

See [`supabase/README.md`](supabase/README.md) for local setup, migrations,
seeds, and database tests. `database/migration-legacy/` is historical only.
