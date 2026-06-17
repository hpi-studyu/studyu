---
name: pull-request
description: Standardize pull request creation. Validates branch name and commits against Conventional Commits spec, audits diff size (flag if >500 lines excluding generated files), proposes split if too large, then creates a PR with structured description (problem, changes, testing checklist). Triggers when user says "create PR", "open a pull request", "make a PR", "/pull-request", or asks to submit work for review.
argument-hint: "[target-branch]"
---

# /pull-request - Standardized PR Creation

## Defaults

- Default target branch: `dev`, unless the user specifies a target branch or repository context clearly indicates a different default.
- Do not force-push, rebase, amend, or rename branches unless the user explicitly asks.
- Never create a PR until branch name, commit compliance, and diff size audit have been presented and the user confirms continuing.

## Step 1: Validate Branch Name

Run:

```bash
git rev-parse --abbrev-ref HEAD
```

Branch names must match:

```text
<type>/<short-description>
```

Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`.

Examples: `fix/delete-study-fk`, `feat/date-question`, `refactor/fitbit-tab`.

If the current branch does not match, stop and propose:

```text
Branch name "<current>" doesn't follow conventions.
Suggested: <type>/<kebab-description>
Rename with: git branch -m <new-name>
```

Wait for the user to rename or explicitly confirm continuing.

## Step 2: Audit Commits

Run:

```bash
git log <target-branch>..HEAD --oneline
```

Each commit subject must match:

```text
<type>[optional scope]: <description>
```

Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`, `revert`.

Rules:

- Subject line is 72 characters or fewer.
- Description uses imperative mood, for example `add`, not `added`.
- No trailing period.
- Breaking change uses `!` after type/scope or a `BREAKING CHANGE:` footer.

For every non-compliant commit, present all proposed rewrites at once:

```text
Commit: "some bad message"
Proposed: "fix(auth): handle expired token on login"
Reword with: git rebase -i <target-branch>
```

Wait for the user to fix or explicitly confirm continuing.

## Step 3: Audit Diff Size

Run:

```bash
git diff <target-branch>...HEAD --stat
```

Count changed lines excluding generated and translation files:

- `*.g.dart`
- `*.freezed.dart`
- `*/l10n/*.dart`
- `*/generated/*`
- `*.g.ts`
- `*.lock`
- `pubspec.lock`

If total non-excluded changed lines exceed 500, analyze the diff and propose an independently mergeable split by feature area, layer, or dependency order:

```text
PR is too large: ~<N> lines (excluding generated files).

Proposed split:
  PR 1 - <type>/<scope-1>: <what it does> (~<N> lines)
    Files: <list key files>
  PR 2 - <type>/<scope-2>: <what it does> (~<N> lines)
    Files: <list key files>

Proceed with single PR anyway? Or split?
```

Wait for the user decision.

## Step 4: Collect PR Info

Run in parallel when possible:

```bash
git diff <target-branch>...HEAD --stat
git log <target-branch>..HEAD --format="%s%n%b"
```

Derive:

- Problem: what was broken or missing, using commits and diff context.
- Changes: grouped bullet list by area.
- Testing: checklist of verification steps, including commands already run.

## Step 5: Create the PR

Push the branch:

```bash
git push -u origin HEAD
```

Create the PR with GitHub CLI:

```bash
gh pr create \
  --title "<type>[scope]: <imperative description>" \
  --base <target-branch> \
  --body "$(cat <<'EOF'
## Problem
<what was broken or missing>

## Changes
- <change 1>
- <change 2>

## Testing
- [ ] <manual test step 1>
- [ ] <manual test step 2>
- [ ] No regressions in <related area>
EOF
)"
```

PR title rules:

- Format: `<type>[optional scope]: <description>`.
- Maximum 72 characters.
- Imperative mood.
- No trailing period.

If `gh` is not authenticated, stop and tell the user to run:

```bash
gh auth login
```
