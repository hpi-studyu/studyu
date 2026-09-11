# SonarQube

This guide describes the StudyU SonarQube workflow and its GitHub integration.

> **Server verification required.** The actual SonarQube server edition,
> version, and installed plugins have not been verified for this repository. A
> server administrator must confirm that both of the following are installed and
> compatible before relying on these settings:
>
> - The **sonar-flutter** analyzer plugin for Dart/Flutter analysis.
> - A community **branch plugin** (for example,
>   `mc1arke/sonarqube-with-community-branch-plugin`) for branch and pull
>   request support.

## Project

The workflow uses one SonarQube project for both push analysis and same-
repository pull request analysis.

| Setting | Value |
| --- | --- |
| Project key | `hpi-studyu_studyu` |
| Project name | `StudyU` |
| Main branch | `dev` |
| Server host URL | `https://sonar.cloud.studyu.health/` |

The project configuration lives in
[`sonar-project.properties`](../sonar-project.properties):

- Analyzes `app/`, `core/`, `designer_v2/`, and `flutter_common` `lib/` and
  `test/` directories.
- Excludes generated `*.g.dart` files and generated localization files for
  `app` and `designer_v2`.
- Reads the merged coverage report from `coverage/sonar/lcov.info`.
- Reads the Dart analyzer report from `coverage/sonar/dart-analyze.txt`.
- Waits for the SonarQube quality gate.

## Workflow

The workflow is defined in
[`.github/workflows/sonarqube.yml`](../.github/workflows/sonarqube.yml).

It runs on:

- Pushes to `dev`.
- Pull requests targeting `dev` from the same repository.
- Manual dispatches on `dev`.

It explicitly skips analysis for fork pull requests and Dependabot pull
requests. A skipped run is not proof that analysis passed.

The workflow performs these steps:

1. Checks out the repository with full Git history.
2. Verifies that `SONAR_TOKEN` and `SONAR_HOST_URL` are available.
3. Initializes the workspace with FVM, Melos, and dependencies.
4. Runs the coverage normalizer regression check.
5. Runs `flutter test --coverage` for each workspace package with a test
   directory.
6. Validates and merges the package LCOV reports into
   `coverage/sonar/lcov.info`.
7. Runs the Dart analyzer and writes the machine-readable report to
   `coverage/sonar/dart-analyze.txt`. Analyzer errors fail the step.
8. Runs the SonarQube scanner.

For same-repository pull requests, the scanner passes the pull request
properties supported by the branch plugin:

- `sonar.pullrequest.key`
- `sonar.pullrequest.branch`
- `sonar.pullrequest.base`
- `sonar.scm.revision`

`sonar.branch.name` is not used for pull request analysis.

## Coverage scope

Coverage is collected from the four Flutter/Dart workspace packages that have
test directories:

- `app`
- `core`
- `designer_v2`
- `flutter_common`

Coverage does not include:

- Designer browser end-to-end tests.
- Supabase database tests.
- Native platform code (Android, iOS).
- Generated code (`*.g.dart`) and generated localization files.

## Server configuration

Before the workflow runs successfully, confirm that:

- The SonarQube server is reachable from the GitHub-hosted runner.
- The server uses HTTPS with a certificate trusted by public runners.
- The SonarQube project key is `hpi-studyu_studyu`.
- The SonarQube main branch is `dev`.
- The **sonar-flutter** analyzer plugin and a compatible **branch plugin** are
  installed and enabled. The server administrator must verify edition, version,
  and plugin compatibility.

If the server is available only through a private network, GitHub-hosted
runners cannot reach it. Use a suitable network path or an isolated self-hosted
runner. Do not run untrusted fork pull requests on a self-hosted runner that
has access to SonarQube secrets.

## GitHub Actions configuration

Configure these repository-level settings:

| Name | Type | Value |
| --- | --- | --- |
| `SONAR_HOST_URL` | Variable | `https://sonar.cloud.studyu.health/` |
| `SONAR_TOKEN` | Secret | A SonarQube token with Execute Analysis permission |

`SONAR_HOST_URL` and `SONAR_TOKEN` are configured names and values that the
workflow expects; they are not themselves secret values, but the token must be
stored as a GitHub Actions secret. Do not place it in
`sonar-project.properties`, workflow files, `.env` files, or commits.

The workflow requests only:

```yaml
permissions:
  contents: read
```

`SONAR_TOKEN` is available only to the preflight verification and SonarQube
scan steps. Tests and analyzer steps do not receive it.

## GitHub App integration

Use the modern server-side GitHub App integration for ALM credentials and
project binding:

1. Configure the GitHub App credentials globally in SonarQube.
2. Install the GitHub App only for the organization and repositories that
   SonarQube must access.
3. Grant these repository permissions:
   - **Checks** read and write
   - **Pull requests** read and write
   - **Metadata** read
4. Bind the project `hpi-studyu_studyu` to repository `hpi-studyu/studyu` in
   the SonarQube project DevOps platform integration settings.

Do not use the legacy `sonar.pullrequest.github.token.secured` property. Keep
all GitHub App private configuration in SonarQube protected settings.

## Branch protection

After the first successful `dev` baseline run and a same-repository pull
request run, configure branch protection for `dev` to require the SonarQube
and/or plugin checks. The workflow check is named `SonarQube Quality Gate`.
The branch plugin may add a `SonarQube Code Analysis` check. Select the exact
names that appear after the first successful analysis.

## Local validation

Run these commands from the repository root:

```bash
actionlint .github/workflows/sonarqube.yml
fvm dart format --output=none --set-exit-if-changed scripts/normalize_lcov.dart
fvm dart analyze --no-fatal-warnings scripts/normalize_lcov.dart
fvm dart scripts/normalize_lcov.dart --check
```

A full SonarQube scan requires the configured `SONAR_TOKEN` and `SONAR_HOST_URL`
and must run in GitHub Actions.

## Security checklist

- Store `SONAR_TOKEN` as a GitHub Actions secret.
- Store `SONAR_HOST_URL` as a GitHub Actions variable.
- Use a SonarQube token with the smallest required permissions.
- Do not expose `SONAR_TOKEN` to fork pull requests.
- Do not use `pull_request_target` or `workflow_run` to expose secrets to
  untrusted code.
- Keep GitHub App private keys and configuration out of the repository and
  CLI.
- Keep third-party actions pinned to full commit SHAs.
- Rotate credentials when an authorized maintainer leaves or a credential may
  have been exposed.
