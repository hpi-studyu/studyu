# Repository Guidelines

## Project Structure & Module Organization

StudyU is a Melos-managed Dart/Flutter workspace. The root `pubspec.yaml` defines the workspace packages: `app`, `designer_v2`, `core`, and `flutter_common`.

- `app/`: participant-facing Flutter app, including `lib/`, `assets/`, platform folders, and widget tests.
- `designer_v2/`: study designer Flutter app, with feature modules under `lib/features/` and integration tests under `integration_test/`.
- `core/`: shared domain models and utilities; generated serialization files are committed.
- `flutter_common/`: shared Flutter utilities, env files, and common UI/support code.
- `supabase/` and `database/`: backend/local database setup and documentation.

## Build, Test, and Development Commands

Use FVM and Melos from the repository root. Run `fvm install` if the configured SDK is missing.

Prefix `dart`/`flutter` commands with `fvm`, and `melos` commands with `fvm exec`, to use the
FVM-managed SDK version.

- `fvm dart pub get`: installs root dependencies.
- `fvm exec melos bootstrap`: links workspace packages and installs package dependencies.
- `fvm exec melos run app`: runs the StudyU app on Chrome at port `8080`.
- `fvm exec melos run designer_v2`: runs Designer v2 on Chrome at port `8081`.
- `fvm exec melos run dev:app` or `fvm exec melos run dev:designer_v2`: runs against `.env.dev`.
- `fvm exec melos run local:app` or `fvm exec melos run local:designer_v2`: runs against
  `.env.local`.
- `fvm exec melos run generate`: runs `build_runner` for generated Dart files.
- `fvm exec melos run qualitycheck`: formats, regenerates, and analyzes the workspace.
- `fvm exec melos run build:web`: builds both web apps.

## Coding Style & Naming Conventions

Follow Effective Dart and the shared `analysis_options.yaml`, which includes `package:lint/strict.yaml`. Use `melos format` before committing. Keep Dart files `snake_case.dart`, classes and widgets `UpperCamelCase`, and members `lowerCamelCase`. Generated `*.g.dart` files are excluded from analysis but must be regenerated and committed when model annotations change.

## Testing Guidelines

Tests use Flutter/Dart test tooling. Place unit and widget tests under each package's `test/` directory and Designer integration tests under `designer_v2/integration_test/`. Prefer names ending in `_test.dart`, matching the feature or model, for example `filter_evaluator_test.dart`. Run all package tests with `melos run test`; run a focused package test with `cd designer_v2 && flutter test`.

## Commit & Pull Request Guidelines

Use Conventional Commits, as seen in history: `fix: remove redundant fitbit label`, `feat(designer): move fitbit credentials...`, `chore: update deps + ios deps`. Keep commits scoped and include generated files when applicable. Pull requests should describe the change, link related issues, list verification commands, and include screenshots or recordings for UI changes.

## Security & Configuration Tips

Do not commit secrets. Environment templates live in `flutter_common/lib/envs/`; select them with `--dart-define=STUDYU_ENV=.env.dev` or `.env.local`. Use development or local Supabase instances for routine work; see `supabase/README.md` for local backend setup.

## AI Agent Behavioral Constraints & Execution Rules

You must strictly adhere to the following workspace rules for all file modifications, terminal command executions, commit generations, and pull request actions.

### 1. Code Quality & Pre-Commit Checks

Before staging changes, committing, or opening a Pull Request, you MUST run `fvm exec melos run qualitycheck`.

If `fvm exec melos run qualitycheck` prints `[rtk] WARNING: untrusted project filters (.rtk/filters.toml)`, review `.rtk/filters.toml`. If it only contains repository-owned output filters, run `rtk trust`, then rerun `fvm exec melos run qualitycheck`.

### 2. Commit Message Enforcement

You must use the Conventional Commits format for all commits. Never generate a generic commit message.

- **Format**: `<type>(<scope>): <description>`
- **Allowed Types**: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`
- **Allowed Scopes**: `app`, `designer`, `core`, `flutter_common`, `db`
- **Case**: The description must be lowercase. Do not end with a period.

### 3. Pull Request Automation

When using the GitHub CLI (`gh`) to open a Pull Request:

1. Parse `.github/pull_request_template.md` to use as the base schema for the PR body.
2. Complete the `Description` and `Testing Steps` sections with high-density, accurate summaries derived from the git diff.
3. Keep the checklist interactive (`- [ ]`) but check off the formatting and analyzer items if you successfully ran them in Step 1.
4. Output a reminder to the user in the chat interface stating that they must manually attach the required screenshot or video before merging.

### 4. Git Worktrees

All git worktrees MUST be created inside `.worktrees/` relative to the project root (e.g.,
`git worktree add .worktrees/<branch-name> <branch>`). Never create worktrees outside the project
folder.

### 5. Code Reviews (Conventional Comments)

When asked to evaluate code or review a PR, format every single comment exactly to the Conventional Comments specification:

- **Format**: `<label> [decorations]: <subject>\n\n[discussion]`
- **Valid Labels**: `praise:`, `nitpick:`, `suggestion:`, `issue:`, `todo:`, `question:`, `thought:`, `chore:`, `note:`
- **Valid Decorations**: `(blocking)`, `(non-blocking)`, `(if-minor)`
