# SonarQube

SonarQube analyzes StudyU pull requests that target `dev`, and every push to `dev`. The analysis
reports code issues, coverage on new code, and duplicated lines on new code. The project uses the
built-in **Sonar way** quality gate.

Dashboard: <https://sonar.cloud.studyu.health/dashboard?id=hpi-studyu_studyu>

The gate reports its result on the pull request. It blocks a merge only when the repository
requires the `SonarQube Quality Gate` check for `dev`.

## When analysis runs

| Event | Analysis |
| --- | --- |
| Pull request to `dev` from `studyu-health/studyu` | Pull request analysis |
| Push to `dev` | Branch analysis |
| Manual run of the `SonarQube` workflow on `dev` | Branch analysis |

The workflow skips two cases, because those runs cannot receive the SonarQube token:

- Pull requests from forks.
- Pull requests from Dependabot.

GitHub reports a job that its `if` condition skips as successful. A skipped job is not a pass.

## Where you see the result

A pull request run adds two checks:

- **`SonarQube Quality Gate`** is the workflow check. It runs the tests, the analyzer, and the
  scan. When the quality gate fails, the check shows one error annotation for each failing
  condition, and the run summary shows a table with the value and the threshold of each
  condition.
- **`SonarQube Code Analysis`** is the SonarQube check. It links to the pull request analysis in
  the dashboard and lists the new, fixed, and unresolved issues.

The workflow also writes the condition table to the run summary, and the scan step writes the
full scanner output to the log.

## What the analysis covers

The analysis reads the Dart and Flutter code of four packages:

- Sources: `app/lib`, `core/lib`, `designer_v2/lib`, `flutter_common/lib`.
- Tests: `app/test`, `core/test`, `designer_v2/test`, `flutter_common/test`.

The analysis excludes these files:

- Generated code, for example `*.g.dart`.
- Generated localization files of `app` and `designer_v2`.
- Generated Mockito mocks, for example `*.mocks.dart`.

Coverage comes from the unit and widget tests of the four packages. The workflow merges the
package LCOV reports into one report for the scan.

The analysis does not cover:

- Designer browser end-to-end tests.
- Supabase database tests.
- Native Android and iOS code.
- Generated code and generated localization files.

## New code

The quality gate measures new code, not the complete code base.

- A pull request analysis uses the pull request diff against `dev`.
- A branch analysis uses a window of the last 30 days.

## Quality gate conditions

| Condition | Fails when |
| --- | --- |
| Coverage on new code | below 80.0% |
| Duplicated lines on new code | above 3.0% |
| New issues | one or more |
| Security hotspots reviewed on new code | below 100% |

SonarQube ignores the coverage condition and the duplication condition when a change adds fewer
than 20 new coverable lines. A documentation-only pull request therefore passes the gate.

## When the quality gate fails

1. Open the failing `SonarQube Quality Gate` check. The annotations and the summary table show
   the failing condition, its value, and its threshold. For example:
   `new_coverage is 67.4 on pull request #968, below the 80 threshold`.
2. Open the dashboard link in the same message. The dashboard shows the affected files and
   lines.
3. Fix the failing condition:
   - **Coverage on new code** — add tests that execute the new lines.
   - **New issues** — fix the reported issues, or mark a false positive in the dashboard and
     give a reason.
   - **Duplicated lines on new code** — remove the duplication, or extract the shared code into
     one place.
   - **Security hotspots reviewed on new code** — review each hotspot in the dashboard, then
     mark it safe or fixed.
4. Push the fix. The workflow analyzes the pull request again.

A bypass hides the failing condition from the reviewer and from the next analysis. Fix the
condition, or discuss the exception in the pull request.

## Reproduce the coverage result locally

Run these commands from the repository root:

```bash
fvm exec melos test:coverage
fvm dart scripts/normalize_lcov.dart coverage/sonar/lcov.info
fvm dart scripts/normalize_lcov.dart --check
```

`test:coverage` runs `flutter test --coverage` for each package with a test directory. It writes
the package test reports and the package LCOV reports. The normalizer merges the package reports
into `coverage/sonar/lcov.info`. This file is the only coverage input of the scan.

A local run does not contact SonarQube, and it does not evaluate the quality gate. The scan
requires `SONAR_TOKEN` and `SONAR_HOST_URL`, so it runs in GitHub Actions only.

## Known limits

- Coverage includes unit and widget tests only. Integration tests, browser end-to-end tests, and
  database tests do not change the coverage value.
- A skipped workflow run leaves the pull request without a quality gate result. A manual run
  does not replace it, because a manual run analyzes `dev`.
