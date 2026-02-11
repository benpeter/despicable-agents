# Domain Plan Contribution: iac-minion

## Recommendations

### (a) Fetching Issue Title and Body

The most robust invocation for fetching structured issue data:

```sh
gh issue view "$issue_number" --json title,body --jq '{title: .title, body: .body}'
```

Key considerations:

- **`--json` with explicit fields**: Only request `title` and `body`. This avoids pulling the entire issue payload (comments, labels, assignees, reactions) which would be wasteful and could hit response size issues on large issues.
- **`--jq` for structured extraction**: Using `--jq` avoids a second `jq` dependency. The `gh` CLI bundles its own jq engine. However, for clarity in the SKILL.md instructions, it is simpler to use two separate calls or extract fields individually:

```sh
issue_title=$(gh issue view "$issue_number" --json title --jq '.title')
issue_body=$(gh issue view "$issue_number" --json body --jq '.body')
```

- **Why separate calls vs. combined**: A combined `--json title,body` with `--jq` outputting both fields requires parsing multi-line JSON output. Since issue bodies can contain arbitrary markdown (including JSON, code fences, backticks, newlines), piping through jq and assigning to a shell variable is fragile. The safer pattern is to write to a temp file:

```sh
body_file=$(mktemp)
gh issue view "$issue_number" --json body --jq '.body' > "$body_file"
```

This avoids shell quoting problems with issue bodies that contain special characters, heredocs, or embedded scripts. The title is safe to capture in a variable since GitHub enforces a 256-character limit on issue titles with no newlines.

- **Non-existent issue handling**: `gh issue view` for a non-existent issue exits with code 1 and prints `Could not resolve to an issue or pull request with the number <N>` to stderr. Check the exit code:

```sh
if ! gh issue view "$issue_number" --json title --jq '.title' >/dev/null 2>&1; then
  echo "Error: Issue #${issue_number} not found in this repository."
  # exit or return error
fi
```

### (b) Updating Issue Body and Title

For the despicable-prompter write-back:

```sh
# Update body from a file (safe for arbitrary markdown content)
gh issue edit "$issue_number" --body-file "$body_file"

# Update title
gh issue edit "$issue_number" --title "$new_title"
```

Key considerations:

- **Use `--body-file` not `--body`**: The `--body` flag passes content as a shell argument, which breaks on issue bodies containing quotes, backticks, dollar signs, or other shell metacharacters. `--body-file` reads from a file, completely sidestepping shell expansion. This is the same pattern the nefario SKILL.md already uses for `gh pr create --body-file` (line 1025).
- **Atomic vs. separate calls**: `gh issue edit` supports both `--title` and `--body-file` in a single invocation. Use a single call for atomicity:

```sh
gh issue edit "$issue_number" --title "$new_title" --body-file "$body_file"
```

This avoids a partial-update race condition where the title updates but the body fails (or vice versa). A single API call is also more rate-limit-friendly.

- **Idempotency**: `gh issue edit` is idempotent. Re-running with the same content produces no observable side effect (the API returns success, the issue remains unchanged). This matters if the skill is interrupted and retried.

### (c) Detecting `gh` Availability and Auth

Three-layer check, run once at the start of the skill invocation before any API calls:

```sh
# Layer 1: Binary exists
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: GitHub CLI (gh) is not installed. Install from https://cli.github.com/"
  # exit or return
fi

# Layer 2: Authenticated
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: GitHub CLI is not authenticated. Run 'gh auth login' first."
  # exit or return
fi

# Layer 3: Has required scopes (optional, more defensive)
# gh auth status prints scopes to stderr; check for 'repo' scope
if ! gh auth status 2>&1 | grep -q 'repo'; then
  echo "Warning: GitHub CLI token may lack 'repo' scope. Issue operations may fail."
fi
```

**Recommendation**: Use layers 1 and 2 only. Layer 3 adds complexity and the scope check is brittle (output format may change across gh versions). If the token lacks permissions, `gh issue view` will fail with a clear 403 error message anyway.

The existing nefario SKILL.md (line 1030) handles `gh` unavailability with a prose instruction ("If `gh` is unavailable, print the manual push command instead"). For issue integration, the check must be stricter and earlier because there is no manual fallback -- the entire feature depends on `gh`. The check should happen at argument parsing time, before any processing.

### (d) Repo Context Detection

`gh` automatically detects the repository from the git remote in the current working directory. No explicit `--repo` flag is needed when running inside a cloned repo. However, there are edge cases:

```sh
# Verify gh can resolve the repo
if ! gh repo view --json name --jq '.name' >/dev/null 2>&1; then
  echo "Error: Cannot determine GitHub repository. Ensure you are in a git repo with a GitHub remote."
  # exit or return
fi
```

**When this fails**:
- Not in a git repo (no `.git/` directory)
- Git remote does not point to GitHub (GitLab, Bitbucket, self-hosted)
- No remote configured at all (`git init` without `git remote add`)

**Recommendation**: Do NOT add an explicit `--repo` flag or repo detection logic. Let `gh` handle it natively. The error messages from `gh` are already clear ("could not determine base repo"). The pre-check above is optional but useful for providing a more contextual error message.

### Failure Mode Handling

| Failure | `gh` exit code | Detection | Recommended handling |
|---------|----------------|-----------|---------------------|
| Issue not found | 1 | stderr contains "Could not resolve" | Clear error: "Issue #N not found in this repository." |
| Auth expired | 4 (or 1) | stderr contains "auth" or "401" | Clear error: "GitHub auth expired. Run 'gh auth login'." |
| Rate limited | 1 | stderr contains "API rate limit" or HTTP 403 with rate limit header | Clear error: "GitHub API rate limited. Wait and retry." |
| Network error | 1 | stderr contains "connection" or "dial" | Clear error: "Network error connecting to GitHub. Check connectivity." |
| Insufficient perms | 1 | stderr contains "403" or "Resource not accessible" | Clear error: "Insufficient permissions to access issue #N." |
| Private repo, no access | 1 | stderr contains "404" (GitHub returns 404 for private repos you cannot access) | Same as "not found" -- cannot distinguish without elevated access |

**Practical recommendation**: Do not try to parse all these stderr patterns. Instead, use a generic error handler:

```sh
error_output=$(gh issue view "$issue_number" --json title,body 2>&1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "Error: Failed to fetch issue #${issue_number}."
  echo "gh output: $error_output"
  # exit or return
fi
```

This preserves the original `gh` error message (which is already user-friendly) while adding context. Trying to pattern-match every failure mode creates a maintenance burden as `gh` CLI evolves.

### Integration Pattern for SKILL.md Files

Both skills need an **argument parsing preamble** that runs before the existing logic. The pattern should be:

1. Check if the first argument matches `#<digits>`
2. If yes: validate `gh` availability, fetch issue, inject into the skill's normal flow
3. If no: pass through to existing behavior unchanged

For despicable-prompter, the preamble replaces the raw input with the fetched issue body (plus any trailing text), processes it through the existing brief-generation logic, then writes back. The write-back is a new post-processing step after the existing output.

For nefario, the preamble replaces the raw input with the fetched issue body (plus any trailing text), then the existing Phase 1 flow proceeds unchanged.

This keeps the integration surgical: a new "Input Resolution" section at the top of each SKILL.md, with no changes to the core logic of either skill.

## Proposed Tasks

### Task 1: Add Input Resolution section to despicable-prompter SKILL.md

**What**: Add an "Input Resolution" section immediately after the frontmatter and before "Input Classification". This section defines: (1) `#<N>` detection regex, (2) `gh` availability check (command -v + auth status), (3) issue fetch via `gh issue view --json title,body`, (4) concatenation of trailing text, (5) error handling for missing issues and auth failures. After resolution, the issue body becomes the "input" for the existing classification logic. Add a "Write-Back" section after the "Refinement Offer" section that: (1) strips the `/nefario` prefix from the generated brief, (2) writes the brief to the issue body via `gh issue edit --body-file`, (3) updates the issue title to the brief's first line (the one-line task summary).

**Deliverables**: Updated `/Users/ben/github/benpeter/despicable-agents/skills/despicable-prompter/SKILL.md`

**Dependencies**: None

### Task 2: Add Input Resolution section to nefario SKILL.md

**What**: Add an "Input Resolution" section in the nefario SKILL.md, after the "Core Rules" section and before "Overview". This section defines the same `#<N>` detection and fetch logic as Task 1 (shared pattern). After resolution, the issue body (plus any trailing text) becomes the task description for Phase 1. Update the `argument-hint` in the frontmatter to indicate both formats: `"<task description or #issue-number [extra context]>"`. No write-back for nefario -- it is read-only.

**Deliverables**: Updated `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

**Dependencies**: None (can run in parallel with Task 1; patterns should be consistent)

### Task 3: Update despicable-prompter argument-hint and examples

**What**: Update the `argument-hint` in the frontmatter to: `"<rough idea or #issue-number [extra context]>"`. Add a new example in the Examples section showing the `#42` flow. Update the Edge Cases section to cover: (1) `gh` not installed, (2) `gh` not authenticated, (3) issue not found, (4) `#0` or negative numbers, (5) `#` without a number.

**Deliverables**: Updated examples and edge cases in `/Users/ben/github/benpeter/despicable-agents/skills/despicable-prompter/SKILL.md`

**Dependencies**: Task 1 (the Input Resolution section must exist before examples reference it)

## Risks and Concerns

### Risk 1: Shell quoting with issue body content (HIGH)

Issue bodies can contain absolutely anything: shell metacharacters, backticks, dollar signs, heredocs, code fences, emoji, null-like sequences. The biggest risk is a body that breaks shell quoting when assigned to a variable or passed as an argument.

**Mitigation**: Always use `--body-file` for writes and temp files for reads. Never pass issue body content through shell variable expansion in command arguments. The `gh issue view --json body --jq '.body' > "$tmpfile"` pattern avoids this entirely.

### Risk 2: Large issue bodies (MEDIUM)

GitHub allows issue bodies up to 65536 characters. An extremely long issue body could overwhelm the skill's context window, especially for nefario where it becomes the task description fed to Phase 1.

**Mitigation**: Document a soft limit (e.g., warn if body exceeds 10,000 characters) but do not truncate. The user wrote the issue; they control its length. Claude's context window is large enough to handle any GitHub issue body.

### Risk 3: Issue body containing prompt injection (MEDIUM)

An issue body could contain `SYSTEM:`, `IGNORE PREVIOUS`, or other injection attempts. The despicable-prompter already has a "Prompt injection defense" rule (line 37 of SKILL.md). Nefario does not have an explicit equivalent.

**Mitigation**: The despicable-prompter's existing defense (treat injection-like patterns as literal content) covers this for that skill. For nefario, the issue body becomes the task description which flows through the structured Phase 1-3 pipeline. The pipeline's structured prompts already frame the task description as user input, not as system instructions. No additional defense needed beyond what exists.

### Risk 4: gh CLI version differences (LOW)

The `--json` and `--jq` flags have been stable since gh 2.0 (released 2021). The `gh issue edit --body-file` flag was added in gh 2.4.0. Any reasonably recent installation will have these.

**Mitigation**: The `command -v gh` check ensures `gh` exists. If someone has a very old version, the error message from `gh` itself will indicate the unknown flag. Not worth adding version detection logic.

### Risk 5: Write-back data loss (MEDIUM)

The despicable-prompter writes the generated brief back to the issue body, replacing whatever was there. If the original issue body had important content beyond the task description (labels, context, links), it would be overwritten.

**Mitigation**: This is by design per the success criteria ("updates the issue body with the brief"). However, the SKILL.md instructions should note that the original body is replaced, not appended to. If the user invoked with trailing text (`#42 also consider caching`), the trailing text was already appended to the body before processing, so it is incorporated into the brief.

### Risk 6: Rate limiting on rapid successive calls (LOW)

The integration makes 1-3 `gh` API calls per invocation (view + edit title + edit body, or view + single edit). GitHub's rate limit is 5000 requests/hour for authenticated users. This is not a practical concern for manual skill invocations.

**Mitigation**: None needed. If the user hits rate limits, the generic error handler will surface `gh`'s rate limit message.

## Additional Agents Needed

None. The current team is sufficient. This is a CLI integration pattern within SKILL.md files -- it falls squarely in the infrastructure/automation domain. The devx-minion may have useful input on the user experience of the `#<N>` argument pattern (discoverability, error message clarity), but this is a minor concern that does not require a separate specialist.
