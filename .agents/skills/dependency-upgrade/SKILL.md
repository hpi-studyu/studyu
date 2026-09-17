---
name: dependency-upgrade
description: Upgrade Flutter, Dart, or package dependencies in the StudyU monorepo with stable-SDK selection, migration review, validation, release, and pull-request gates.
argument-hint: "[target-branch]"
---

# /dependency-upgrade - StudyU dependency upgrades

Use this skill for Flutter SDK, Dart SDK, or Dart and Flutter package upgrades.
Run every command from the repository root.

## 1. Preflight

Do not mutate the repository until every preflight check passes.

1. Require the repository root. Verify it with `git rev-parse --show-toplevel`.
2. Require a dedicated, clean task worktree. Run:

   ```bash
   git status --short --untracked-files=all
   git branch --show-current
   git rev-parse HEAD
   ```

   If the worktree is not clean, create a fresh worktree without changing the
   existing one. Never stash, reset, or remove unrelated work.
3. Treat dependency upgrades as ticketless maintenance. Do not require a Jira
   ticket.
4. Require a branch that matches `^chore/[a-z0-9][a-z0-9-]*$`. Do not rename a
   branch automatically. Stop and request an approved branch if the name does
   not match.
5. Print the target branch and the current commit. Confirm that the target is
   not the task branch.
6. Confirm the intended scope. Allowed changes are dependency manifests,
   lockfiles, generated output, and compatibility fixes caused by the update.
   Do not edit `.github/workflows/*`. Do not add helper scripts or unrelated
   cleanup.

Never run `git clean`, `melos reset`, `supabase link`, `supabase db push`, a
Supabase reset against a non-local target, a deployment, a publish operation, or
a tag push during this workflow. Local Melos versioning is allowed only in
section 9, after all checks pass.

## 2. Prepare the worktree

Use a fresh worktree based on the selected target branch. Preserve the source
worktree and all unrelated changes. In the fresh worktree, run:

```bash
fvm install
./setup.sh
fvm exec melos setup
```

`./setup.sh` bootstraps the workspace. If the repository setup script no longer
bootstraps the workspace, run `fvm exec melos bootstrap` after inspecting its
current definition.

Create the local environment file only when it does not exist:

```bash
if [ ! -e flutter_common/lib/envs/.env.local ] && \
   [ ! -L flutter_common/lib/envs/.env.local ]; then
  cp flutter_common/lib/envs/.env.local.example \
    flutter_common/lib/envs/.env.local
fi
git check-ignore -q flutter_common/lib/envs/.env.local
```

Never overwrite `.env.local`. Never add it to Git. Do not use production
`.env` for routine validation.

## 3. Inventory the workspace

Read the current command catalog and configuration before choosing commands.
The root `pubspec.yaml` is the source of truth for Melos scripts. The current
workflow files are the source of truth for CI and E2E steps. Do not copy script
bodies into this skill or replace them with guessed commands.

Inspect:

- `.fvmrc` and the Flutter and Dart constraints.
- `pubspec.yaml`.
- `core/pubspec.yaml`.
- `flutter_common/pubspec.yaml`.
- `app/pubspec.yaml`.
- `designer_v2/pubspec.yaml`.
- Every workspace `pubspec.lock`.
- Platform lockfiles such as `app/ios/Podfile.lock` and
  `app/android/Gemfile.lock`, when present.

Run and record the full result of:

```bash
fvm exec melos outdated
```

Record current, upgradable, resolvable, and latest versions. Include direct and
dev dependencies, SDK constraints, platform plugins, Git dependencies, and
workspace package versions.

## 4. Select the Flutter SDK

Select the latest stable Flutter release only. Use `fvm releases` and verify the
choice against the official stable release list. Do not select beta, dev, master,
or another prerelease channel. Read the Flutter and Dart migration notes for
every stable release skipped between the pinned version and the selected version.

Show the proposed `.fvmrc` change and ask for approval before changing the
pinned SDK. After approval, use FVM to select and install the exact release, then
verify:

```bash
fvm use <latest-stable-version>
fvm install
fvm flutter --version
fvm dart --version
```

Do not raise a minimum Dart SDK constraint unless the selected stable SDK
requires it. If it does, show the constraint change and its migration reason.
Run this report only after the new SDK is selected:

```bash
fvm dart pub outdated --json
```

Save the JSON output for the upgrade record. Run the workspace report again
with the selected SDK:

```bash
fvm exec melos outdated
```

Use the post-SDK reports for the update table. Do not use the pre-SDK inventory
to make package decisions.

## 5. Review and approve package updates

Consolidate direct and dev dependency entries from all workspace manifests into
one review table. For each proposed update, record the package, owning
manifest, current constraint, selected constraint, resolved version, source,
and risk.

Skip these updates by default:

- Flutter and Dart SDK constraints.
- Git dependencies, including `fitbitter`.
- Transitive-only dependencies.
- Prerelease versions.

Review the pub.dev changelog and migration notes before any of these updates:

- Major updates.
- Minor updates for a `0.x` package.
- Persistent-data, authentication, storage, or routing packages.
- Camera, notification, permission, scanner, recording, or other native
  platform plugins.
- Updates with platform-minimum changes.
- Updates with staged migrations.
- Updates with missing or unclear migration documentation.

Review Git dependency history separately. Pub.dev release notes do not cover
`fitbitter`.

Ask concrete decision questions only when the review finds an actual risk. A
question must name the package, change, affected boundary, and requested
approval. Do not silently apply a breaking migration.

### Required secure-storage gate

Treat `flutter_secure_storage` as a production-data migration. If production
users may have data from v9 and the proposed path reaches v11 through v10, stop
before mutation. Read the v9, v10, and v11 migration notes. Ask for explicit
approval for the staged v9-to-v10-to-v11 release plan.

The approval question must cover:

- How v10 reads and preserves v9 data.
- How v10 data migrates to v11.
- Storage options and key compatibility.
- The minimum app version for each release.
- Rollback and recovery behavior if a read fails.

Do not jump directly from v9 to v11. Do not assume that a new storage format
migrates existing participant data. Inspect the shared implementation in
`flutter_common` and validate both frontends after approval.

## 6. Mutate approved inputs

Obtain approval for the final update table before mutation. Update each approved
direct constraint consistently across every manifest that declares it. Keep
internal workspace constraints aligned. Do not change SDK constraints unless the
SDK gate approved the change.

Edit manifests, not lockfiles. Let the repository command resolve lockfiles:

```bash
fvm exec melos upgrade
```

This uses the root script. Do not use `dart pub upgrade --major-versions` or
`fvm dart pub upgrade --major-versions` as the mutation step. Do not add a
`dependency_overrides` entry without explicit approval.

Review all resulting lockfiles and manifests. Stop if the solver reports a
conflict, a downgrade, an unexpected source change, an unapproved override, or
unrelated dependency churn. Do not repair a lockfile by hand.

## 7. Validate the update

Run the narrowest checks for the affected packages and platforms. Use the
existing root Melos scripts and inspect their current definitions before use.
Record every command, result, and skipped check.

Run code generation when generator versions or generated inputs changed:

```bash
fvm exec melos generate
```

Inspect generated diffs. Keep tracked generated files only when the update
caused them.

Run analysis and fixes only for failures caused by this update. Use the root
scripts. Run `fvm exec melos fix` only after identifying such a failure. Then
rerun the affected analysis.

Run unit tests for workspace packages with tests:

```bash
fvm exec melos test
```

Run `fvm exec melos qualitycheck` when the pre-commit hook has not already run
an equivalent check, or when a full workspace check is required. This script
formats, generates, and analyzes. Review any formatting changes and keep only
changes caused by the upgrade.

Build every affected platform. Use a current environment-specific build
script from the root `pubspec.yaml`. Every app or Designer build must provide
`--dart-define=STUDYU_ENV=.env.dev` or `--dart-define=STUDYU_ENV=.env.local`.
Do not invoke an unqualified `build:android`, `build:ios`, or `build:web` script.
If the catalog has no safe environment-specific build script, run a root-level
targeted command instead:

```bash
fvm exec melos exec --scope <package-scope> -- \
  "flutter build <platform> --dart-define=STUDYU_ENV=.env.dev"
```

Use `.env.local` when local services are required. Stop when no safe command
exists for an affected platform. Do not run an unqualified production
application or Designer command for routine validation.

### Local E2E gate

Run local E2E checks when the affected boundary requires them. Before any
reset, read `supabase/README.md` and `.github/workflows/e2e_tests.yml`.
Follow the current workflow at run time. Do not copy its script body here.

Start the local Supabase services from the current workflow:

```bash
supabase start -x studio,imgproxy
```

Verify that the Supabase database target is local. Confirm that
`SUPABASE_DB_URL` resolves to `localhost` or `127.0.0.1`, and inspect
`supabase status`. Stop for any remote or unknown target.

Immediately before the reset, show the verified local target and state that the
reset deletes local database data. Ask the user for explicit authorization to
run `./scripts/reset-test-db.sh --yes`. Do not infer authorization from an
earlier approval. After that immediate authorization, run:

```bash
./scripts/reset-test-db.sh --yes
```

Ensure the ignored `.env.local` exists without overwriting it. Populate local
values by following the workflow. Run the current Designer and app browser E2E
commands from `.github/workflows/e2e_tests.yml`. Never substitute production
credentials or a remote Supabase project.

Do not silently skip a required check. Stop when a required tool, platform,
local database, browser, or validation environment is unavailable. Mark an
optional check as skipped only with a reason in the upgrade record.

## 8. Stop conditions

Stop and request a decision or remediation when any of these conditions occurs:

- The repository root, clean worktree, or valid maintenance branch is missing.
- The SDK proposal is not the latest stable release, or migration notes are
  unavailable.
- The solver conflicts, downgrades, changes a source, or requires an override.
- A changelog or migration note is missing for a flagged update.
- A package raises a platform minimum without explicit approval.
- A breaking persistent-data, auth, storage, routing, camera, notification,
  permission, or other native migration lacks an approved plan.
- A required validation command fails or is unavailable.
- The diff contains unrelated changes, workflow edits, or a tracked `.env.local`.
- A generated, lockfile, platform, or compatibility change has no update cause.

Keep the failure output and the exact command. Do not hide or work around the
failure with an override, downgrade, skipped check, or unrelated refactor.

## 9. Version and release handoff

Version only after all required checks pass and the final diff is reviewed.
Commit the validated dependency changes first. Stage only approved files and
use a compliant Conventional Commit subject:

```bash
git add <approved-files>
git commit -m "fix(deps): update approved dependencies"
```

Melos versions from committed Conventional Commits. First preview the
proposals without creating a commit or tags:

```bash
printf 'n\n' | fvm exec melos version --all --no-git-tag-version
```

Review package versions, internal constraints, and changelogs. Then let Melos
create its standard version commit without pre-merge tags:

```bash
fvm exec melos version --all --no-git-tag-version --yes
```

Do not create a manual version commit. Do not create package tags before the
pull request merges. Capture the exact Melos version commit:

```bash
git log --oneline --decorate -n 5
```

Use that actual Melos version commit to derive the released package list. Check
only package pubspec files whose versions changed in that commit:

```bash
git diff-tree --no-commit-id --name-only --diff-filter=M -r \
  <melos-version-commit> -- \
  core/pubspec.yaml flutter_common/pubspec.yaml app/pubspec.yaml \
  designer_v2/pubspec.yaml
```

For each listed manifest, compare its parent `version:` with its new
`version:` from `<melos-version-commit>`. Record a package only when that
version changed. Read and record its `name:` and new `version:` from the actual
commit. Ignore manifests that changed for constraints only. Exclude any package
whose manifest did not change in the actual Melos version commit. Stop if the
list is empty or a package name or version is unclear. Do not use the workspace
package list as a substitute. Melos `--all` includes private packages, but it
does not require every package to receive a version change.

Never push tags before the pull request merges. Never run `git push --tags` or
`git push origin --tags`.

## 10. Pull request and post-merge handoff

After the version step, follow `.agents/skills/pull-request/SKILL.md`. Complete
its ticketless maintenance branch, Conventional Commit, diff, template,
testing, confirmation, and author-attestation gates. Use
`chore(deps): <description>` for the PR title and
`Not applicable — maintenance PR.` for the Jira section.

Push the branch only. Do not include tags:

```bash
git push -u origin HEAD
```

Create the pull request only after the pull-request skill receives the required
confirmation. Do not deploy, publish, or push tags in this workflow. Allow
squash or rebase merges because tags use the merged commit on `main`.

After the pull request merges, handle tags only on `main` or under an explicitly
approved production release plan. An ordinary merge to `dev` must never create
or push package tags. Fetch the merged target and identify the commit on `main`
that contains the merged version files:

```bash
git fetch origin main
git log origin/main --oneline --decorate -- core/pubspec.yaml \
  flutter_common/pubspec.yaml app/pubspec.yaml designer_v2/pubspec.yaml
```

Verify the selected `<main-release-commit>` contains the approved package
versions. Use only the recorded released-package list from the actual Melos
version commit. Do not add packages from the workspace list. If `app/pubspec.yaml`
did not change in that commit, do not create a `studyu_app-v*` tag.

For each recorded `<released-package>` and `<version>`, construct one exact tag.
Before creating any tag, verify that the exact name is absent locally and on
origin:

```bash
git tag --list '<exact-tag>'
git ls-remote --exit-code --refs origin 'refs/tags/<exact-tag>'
```

Stop if either command finds the tag. Never move or overwrite an existing tag.
Replace every placeholder with the recorded package, version, tag, and main
commit. Show the conditional commands, but do not run them until explicit
production release authorization is given:

```bash
# Repeat only for each recorded released-package entry.
git tag --annotate --message="Release <released-package> v<version>" \
  <released-package>-v<version> <main-release-commit>
git push origin <exact-tag-1> <exact-tag-2> ...
```

Pushing `studyu_app-v*` tags triggers `.github/workflows/release_app.yml`.
Tag creation and tag pushes require explicit release authorization. Never create
or push tags for an ordinary `dev` merge. Record the main commit, released
package subset, exact tags, authorization, and commands.

Record the changed files, approvals, commands, results, skipped checks with
reasons, release commit, exact tags, branch push, and residual risks.
