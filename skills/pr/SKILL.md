---
name: pr
description: Iterate on a PR until CI passes. Use when you need to fix CI failures, address review feedback, or continuously push fixes until all checks are green. Automates the feedback-fix-push-wait cycle.
---

# Iterate on PR Until CI Passes

Continuously iterate on the current branch until all CI checks pass and review feedback is addressed.

**Requires**: GitHub CLI (`gh`) authenticated.

## Workflow

### 1. Identify PR

```bash
gh pr view --json number,url,headRefName
```

Stop if no PR exists for the current branch.

Store the PR number for subsequent commands.

### 2. Gather Review Feedback

Use `gh` CLI to fetch PR review comments and reviews. You need multiple sources to get complete feedback:

```bash
# Get repo info (owner and repo name)
gh repo view --json owner,name

# Get PR info
gh pr view {number} --json number,url,headRefName,author,reviews,reviewDecision

# Get review threads (inline comments with resolved status - requires GraphQL)
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            isOutdated
            path
            line
            comments(first: 10) {
              nodes {
                id
                body
                author { login }
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -F owner={owner} -F repo={repo} -F pr={number}

# Get review comments (inline code comments)
gh api repos/{owner}/{repo}/pulls/{number}/comments

# Get issue comments (PR conversation comments)
gh api repos/{owner}/{repo}/issues/{number}/comments
```

#### Categorizing Feedback

Categorize feedback using the [LOGAF scale](https://develop.sentry.dev/engineering-practices/code-review/#logaf-scale):

**Detect LOGAF markers in comment body:**
- `h:` or `[h]` or `high:` → **high** priority
- `m:` or `[m]` or `medium:` → **medium** priority
- `l:` or `[l]` or `low:` → **low** priority

**If no explicit marker, categorize by keywords:**

*High priority:*
- "must fix", "must change", "security", "critical", "blocker", "will break", "wrong", "incorrect"

*Low priority:*
- "nit", "nitpick", "suggestion", "consider", "could also", "optional", "minor", "style", "prefer", "what do you think"

**Default:** `medium` for regular comments without clear markers.

#### Bot Classification

Distinguish between bots that provide actionable feedback vs. informational bots:

*Review bots (actionable - categorize by content):*
- Sentry, Warden, Cursor, Bugbot, Seer, CodeQL, Copilot, Claude

*Info bots (skip silently):*
- Codecov, Dependabot, Renovate, GitHub Actions, Mergify, Snyk

Review bot feedback goes into high/medium/low buckets with a `review_bot: true` flag. Info bots go into the `bot` bucket (skip).

#### Categories:
- `high` - Must address before merge (explicit `h:`, blockers, changes requested, security issues)
- `medium` - Should address (explicit `m:`, standard feedback without clear priority)
- `low` - Optional (explicit `l:`, nits, suggestions)
- `bot` - Informational automated comments (Codecov, Dependabot, etc.) - skip silently
- `resolved` - Already resolved threads

### 3. Handle Feedback by LOGAF Priority

**Auto-fix (no prompt):**
- `high` - must address (blockers, security, changes requested)
- `medium` - should address (standard feedback)

This includes review bot feedback. Treat it the same as human feedback:
- Real issue found → fix it
- False positive → skip, but explain why in a brief comment
- Never silently ignore review bot feedback — always verify the finding

**Prompt user for selection:**
- `low` - present numbered list and ask which to address:

```
Found 3 low-priority suggestions:
1. [l] "Consider renaming this variable" - @reviewer in api.py:42
2. [nit] "Could use a list comprehension" - @reviewer in utils.py:18
3. [style] "Add a docstring" - @reviewer in models.py:55

Which would you like to address? (e.g., "1,3" or "all" or "none")
```

**Skip silently:**
- `resolved` threads
- `bot` comments (informational only — Codecov, Dependabot, etc.)

### 4. Check CI Status

Get check status with:

```bash
# Basic check status
gh pr checks {number}

# JSON output for parsing (includes run IDs)
gh pr checks {number} --json name,state,bucket,link,workflow
```

For failed checks, get detailed logs:

```bash
# Get run IDs from the JSON output, then view failed logs
gh run view {run-id} --log-failed
```

#### Extracting Failure Context

When reading logs, look for common failure patterns to find the relevant error:
- `error:`, `failed:`, `failure:`, `traceback`, `exception`
- `FAILED`, `panic:`, `fatal:`
- `ModuleNotFoundError`, `ImportError`, `SyntaxError`, `TypeError`
- `=== FAILURES ===`, `___ ___` (pytest separators)
- `npm ERR!`, `yarn error`

Extract context around these markers (5 lines before, up to 50 lines after).

**Wait if pending:** If review bot checks (sentry, warden, cursor, bugbot, seer, codeql) are still running, wait before proceeding—they post actionable feedback that must be evaluated. Informational bots (codecov) are not worth waiting for.

### 5. Fix CI Failures

For each failed check:
1. Read the failure logs via `gh run view {run-id} --log-failed`
2. Read the relevant code before making changes
3. Fix the issue with minimal, targeted changes

Do NOT assume what failed based on check name alone—always read the logs.

### 6. Commit and Push

```bash
git add <files>
git commit -m "fix: <descriptive message>"
git push
```

### 7. Wait for CI

```bash
gh pr checks --watch --interval 30
```

### 8. Re-check Feedback After CI

Review bots often post feedback seconds after CI checks complete. Wait briefly, then check again:

```bash
sleep 10
# Re-fetch review comments using gh api commands from step 2
```

Address any new high/medium feedback the same way as step 3. If new feedback requires code changes, return to step 6 to commit and push.

### 9. Repeat

Return to step 2 if CI failed or new feedback appeared in step 8.

## Exit Conditions

**Success:** All checks pass, post-CI feedback re-check is clean (no new unaddressed high/medium feedback including review bot findings), user has decided on low-priority items.

**Ask for help:** Same failure after 3 attempts, feedback needs clarification, infrastructure issues.

**Stop:** No PR exists, branch needs rebase.
