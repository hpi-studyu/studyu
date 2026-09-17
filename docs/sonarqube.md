# SonarQube

This guide describes the StudyU SonarQube workflow and its GitHub integration.

The server runs SonarQube Community Build `26.5.0.122743`. Successful CI scans
log the Flutter analyzer sensors, the Flutter coverage sensor, the Flutter unit
test sensor, and the mc1arke community branch plugin pull request scanner
sensor. These logs are the evidence for the plugin capability this guide relies
on.

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
- Reads the merged LCOV coverage report from `coverage/sonar/lcov.info`. This
  file is the only coverage input.
- Reads four Flutter test execution reports through
  `sonar.flutter.tests.reportPath`. These reports provide unit test count and
  duration. They do not calculate coverage.
- Excludes generated Mockito mocks from test analysis through
  `sonar.test.exclusions=**/*.mocks.dart`. The `sonar.exclusions` property
  applies to source code only, so it cannot remove these files.
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
   directory. Each run also writes a JSON test report to
   `coverage/tests.output`.
6. Validates the four Flutter test reports. The step stops the workflow when a
   report is missing, empty, invalid, or unsuccessful.
7. Validates and merges the package LCOV reports into
   `coverage/sonar/lcov.info`.
8. Runs the Dart analyzer and writes the machine-readable report to
   `coverage/sonar/dart-analyze.txt`. Analyzer errors fail the step.
9. Runs the SonarQube scanner.

The `test:coverage` Melos script runs one command per package:

```bash
mkdir -p coverage && flutter test --coverage --file-reporter=json:coverage/tests.output
```

`--file-reporter` adds the JSON report. Standard output keeps the normal
reporter, so GitHub Actions still receives the test output.

The validation step in step 6 requires four report paths:

- `app/coverage/tests.output`
- `core/coverage/tests.output`
- `designer_v2/coverage/tests.output`
- `flutter_common/coverage/tests.output`

Each report must be non-empty, contain at least one `suite` event, and end with
a successful `done` event.

For same-repository pull requests, the scanner passes the pull request
properties supported by the branch plugin:

- `sonar.pullrequest.key`
- `sonar.pullrequest.branch`
- `sonar.pullrequest.base`
- `sonar.scm.revision`

`sonar.branch.name` is not used for pull request analysis.

## Coverage scope

Coverage comes from the merged LCOV report only. The Flutter test execution
reports add unit test count and duration. They do not calculate coverage.

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

Some SonarQube views can hide test-execution metrics on pull request analyses.
The `dev` branch analysis is the authoritative source for unit test count and
duration.

## Quality gate and new code

The project uses the built-in, read-only **Sonar way** gate. The other Sonar way
new-code conditions stay in place.

| Setting | Value |
| --- | --- |
| New code definition | Project-specific **Number of days**, value `30` |
| Coverage condition | Coverage on New Code is less than 80.0% |
| Overall coverage condition | None |
| Small changes | **Ignore duplication and coverage on small changes** stays enabled |

**Ignore duplication and coverage on small changes** keeps the Sonar way
allowance. The coverage condition applies only after a change has at least 20
new coverable lines.

Pull request analysis uses the pull request diff against `dev` as new code. The
30-day setting governs branch analysis. It does not replace the pull request
diff.

The scanner sends the complete `coverage/sonar/lcov.info` report. Do not trim
the report to changed files or changed lines. SonarQube calculates
`new_coverage` from SCM data and the new code definition.

These settings need **Administer** permission on the project:

```bash
curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/new_code_periods/show?project=hpi-studyu_studyu"
curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/qualitygates/get_by_project?project=hpi-studyu_studyu"
```

## Server configuration

Confirm that:

- The SonarQube server is reachable from the GitHub-hosted runner.
- The server uses HTTPS with a certificate trusted by public runners.
- The SonarQube project key is `hpi-studyu_studyu`.
- The SonarQube main branch is `dev`.
- The **sonar-flutter** analyzer plugin and a compatible **branch plugin** are
  installed and enabled. The scanner log of a successful run is the check.

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

## GitHub integration

Four separate configurations exist. Do not confuse them.

| Configuration | Purpose | Location |
| --- | --- | --- |
| Login authentication | Sign in users through GitHub | **Administration > Authentication** |
| Analysis configuration | Let SonarQube call the GitHub API | **Administration > Configuration > General Settings > DevOps Platform Integrations > GitHub** |
| Project binding | Link the project to a repository | Project **DevOps Platform Integration** settings |
| Summary comments | Post one comment per pull request | Part of the project binding |

The analysis configuration uses an existing GitHub App. Its installation needs
these repository permissions:

- **Checks** read and write, for check runs on pull requests.
- **Contents** read, for source access.
- **Metadata** read, which GitHub always requires.
- **Pull requests** read. Keep write access if it is already granted. Write
  access is not necessary while summary comments are disabled.

The project `hpi-studyu_studyu` binds to repository `studyu-health/studyu` with
these settings:

| Setting | Value |
| --- | --- |
| `monorepo` | `false`, because one SonarQube project represents the repository |
| `summaryCommentEnabled` | `false`, because the check run carries the result |

The equivalent API calls are:

```bash
curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/alm_settings/get_binding?project=hpi-studyu_studyu"
curl -s -u "$SONAR_TOKEN:" -X POST "$SONAR_HOST_URL/api/alm_settings/set_github_binding" \
  -d project=hpi-studyu_studyu -d almSetting=<key> \
  -d repository=studyu-health/studyu -d monorepo=false -d summaryCommentEnabled=false
curl -s -u "$SONAR_TOKEN:" "$SONAR_HOST_URL/api/alm_settings/validate_binding?project=hpi-studyu_studyu"
```

`validate_binding` reports missing App credentials, a missing repository or
installation, or a missing check permission. Fix the reported item and repeat
the validation.

Do not use the legacy `sonar.pullrequest.github.token.secured` property. Keep
all GitHub App private configuration in SonarQube protected settings.

A successful pull request scan creates a check named `SonarQube Code Analysis`.
The check links to
`https://sonar.cloud.studyu.health/dashboard?id=hpi-studyu_studyu&pullRequest=<number>`.

## Branch protection

The repository ruleset `SonarQube quality gate` protects `dev` only. It requires
the `SonarQube Quality Gate` check from GitHub Actions.

| Field | Value |
| --- | --- |
| Target | Branch |
| Ref include | `refs/heads/dev` |
| Required check | `SonarQube Quality Gate` |
| Check source | GitHub Actions, integration `15368` |
| Strict policy | Enabled, so the check must pass on the current head SHA |
| Enforcement on create | Enabled |
| Bypass actors | None |

Ruleset `Ready to merge` stays unchanged because it also protects `main`. Do not
add `sonarqube.yml` to `.github/workflows/ready_to_merge.yml`. That aggregator
looks up the latest run by branch, accepts skipped and cancelled runs, and does
not bind results to the current head SHA. The required check evaluates the
latest pull request SHA directly.

Do not require the `SonarQube Code Analysis` decoration check. Require only the
scanner check that waits for the server quality gate.

Fork pull requests and Dependabot pull requests stay unscanned, because they
cannot receive the Sonar token safely. GitHub reports a job skipped by its `if`
condition as successful. These skipped jobs are explicit security-policy
exceptions to the merge gate, not evidence of analysis.

Creating or changing the ruleset needs repository administrator permission.

## Local validation

Run these commands from the repository root:

```bash
actionlint .github/workflows/sonarqube.yml
fvm dart format --output=none --set-exit-if-changed scripts/normalize_lcov.dart
fvm dart analyze --no-fatal-warnings scripts/normalize_lcov.dart
fvm dart scripts/normalize_lcov.dart --check
```

Validate a Flutter test report after `fvm exec melos test:coverage`:

```bash
jq -s -e 'length > 0 and any(.[]; .type == "suite") and (.[-1].type == "done" and .[-1].success == true)' \
  app/coverage/tests.output
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
