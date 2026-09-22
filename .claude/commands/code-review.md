---
name: code-review
description: Full code review of a branch, PR, or Jira ticket. Accepts a Jira ticket ID (e.g. TICKET-123), branch name, or PR number as optional input. Defaults to current branch. Runs static analysis, PHPCS, PHPStan, and Drupal best-practice checks.
allowed-tools: Bash(git branch --show-current:), Bash(git diff *:), Bash(git log *:), Bash(git fetch *:), Bash(gh pr view *:), Bash(gh pr diff *:), Bash(ddev describe:), Bash(ddev phpcs *:), Bash(ddev phpstan:), Bash(ddev drush cr:), Agent, Read, Glob, Grep
---

# Code Review

Run a full code review against changed files — static analysis, PHPCS, PHPStan, and best-practice checks.

## Purpose

Use this command to review work before a PR or during a PR — whether you have a Jira ticket, a branch name, a PR number, or nothing at all.

---

## Input

Optional. One of:

- Jira ticket ID — e.g. `TICKET-123`
- Branch name — e.g. `my-feature-branch`
- PR number — e.g. `612` or `#612`
- Nothing → defaults to current branch

---

## Step 1 — Resolve input to a branch

### No input

```bash
git branch --show-current
```

Use the result as the branch.

### Jira ticket (e.g. `TICKET-123`)

```bash
gh pr list --search "TICKET-123" --json number,headRefName,title
```

If a PR is found → use its branch.
If no PR → search local/remote branches for the ticket ID:

```bash
git branch -a | grep -i TICKET-123
```

Use the first match. If nothing found → tell the user and stop.

### PR number (e.g. `612`)

```bash
gh pr view 612 --json headRefName,title,files
```

Use the `headRefName` as the branch.

### Branch name

Use it directly. Verify it exists:

```bash
git fetch origin
git log origin/<branch> -1
```

If not found → tell the user and stop.

---

## Step 2 — Get changed files

Get the diff between the resolved branch and the base branch (as defined in `workflow.md` — typically `develop` or `main`):

```bash
git fetch origin
git diff origin/<base-branch>...origin/<branch> --name-only
```

If on current branch (no remote yet):

```bash
git diff origin/<base-branch>...HEAD --name-only
```

Show the list of changed files to the user.

If no changed files → tell the user and stop.

---

## Step 3 — Run PHPCS on changed PHP files

Filter changed files to those in PHPCS scope:
- `docroot/modules/custom/`
- `docroot/themes/custom/`
- `docroot/sites/default/settings.php`

For each matching file, run:

```bash
ddev phpcs <file-path>
```

Collect all output. Store raw results — use them as-is in the report.

If no in-scope PHP files → note "PHPCS: no in-scope files" and skip.

---

## Step 4 — Run PHPStan

```bash
ddev phpstan
```

Collect output. Store raw results.

---

## Step 5 — Static code review (quality-gate)

Use the **quality-gate** agent.

Pass it:
- The list of changed files from Step 2
- The diff content (read changed files directly)
- Instruction to review against project rules: PHP design (`final`, `private`, visibility), DocBlocks, Drupal best practices (DI, naming conventions, module placement)

The quality-gate agent is read-only — it will not modify files.

---

## Step 6 — Clear cache check (done-gate)

```bash
ddev drush cr
```

If this fails → flag it as a blocker in the report.

---

## Report

### Header

```
Code Review: <branch-name>
Files changed: <count>
```

### PHPCS

Use exact output from Step 3.
If clean → `✅ PHPCS: clean`
If issues → list them with file and line.

### PHPStan

Use exact output from Step 4.
If clean → `✅ PHPStan: clean`
If issues → list them.

### PHP Design

From quality-gate results:
- `final` missing on concrete classes
- public properties
- wrong visibility
- non-readonly dependencies

### DocBlocks

From quality-gate results:
- missing docblocks
- missing `@var` where type is non-obvious
- weak `@param` / `@return` descriptions

### Drupal Best Practices

From quality-gate results:
- `\Drupal::` static calls in classes
- naming convention violations (module prefix and constants — as defined by the project's agent guide)
- wrong module placement

### Cache

If `ddev drush cr` passed → `✅ Cache: clear`
If failed → `🚨 Cache: failed — investigate before merging`

### Overall verdict

- `✅ Clean` — no issues
- `⚠️ Minor` — style/docblock issues only, safe to merge with fixes
- `🚨 Needs work` — PHPCS errors, PHPStan errors, or design issues that must be addressed

---

## Rules

- no code changes
- no commits
- no pushes
- analyze only changed files
- PHPCS and PHPStan output must be used as-is — do not guess or infer
- follow `phpcs.xml` as source of truth for standards
