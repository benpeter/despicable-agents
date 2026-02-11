# Domain Plan Contribution: user-docs-minion

## Recommendations

After reviewing the documentation set, four documents need updates to reflect the noise reduction behavior. The changes are narrow -- no new documents are needed, no structural reorganization is required, and no user-facing workflows change. The documentation updates document what the hooks now do differently with output, not new functionality.

### 1. `docs/commit-workflow.md` -- Two sections need updates

**Section 2 (Auto-Commit Behavior), "Informational Output" subsection (lines 116-123):**
This section currently describes the auto-commit producing a single informational line (`Committed 3 files: ...`). If git commit hooks (pre-commit, commit-msg, etc.) now have their output suppressed on success and shown only on error, this section needs a sentence clarifying that behavior. The current text says "Stage and commit silently" (line 109), which is close but does not explicitly address git hook output. Add a note stating that git commit hook output is suppressed in the main session unless the hook exits non-zero, in which case the full output is shown for debugging.

**Section 7 (Hook Composition), near the settings configuration (lines 282-310):**
The `.claude/settings.json` configuration will likely gain new hook entries or the existing PostToolUse hooks will gain output handling behavior. If a new PostToolUse hook is added (for Read, Write, Bash output truncation), the settings configuration block in this section must be updated to match. If the existing `track-file-changes.sh` hook is extended to also handle output truncation, the description of that hook's purpose needs updating. Either way, the settings.json example must mirror reality.

### 2. `docs/orchestration.md` -- One section needs a minor update

**Section 5 (Commit Points in Execution Flow), paragraph about "co-located" commits (line 516-517):**
The text says "commit checkpoints immediately follow" gate approval. If git hook output is now suppressed during these auto-commits, a brief note clarifying that commit hook output does not clutter the approval gate flow would reinforce the "silent" promise. This is a one-sentence addition, not a rewrite. Something like: "Git commit hook output is suppressed during auto-commits; only errors are surfaced."

### 3. `docs/deployment.md` -- Hook Deployment section needs updating

**Hook Deployment section (lines 79-104):**
The hook scripts table currently lists two scripts: `track-file-changes.sh` and `commit-point-check.sh`. If a new hook script is added for output noise reduction (e.g., a PostToolUse hook that truncates Read/Write/Bash output to the last 2 lines), it must be added to this table with its event type and purpose. If the noise reduction is implemented as modifications to the existing hooks or as a new hook, the table and description must reflect the change.

Additionally, the sentence "Hooks are registered in `.claude/settings.json` at the project root" should reference the new hook entry if one is added.

### 4. `.claude/settings.json` -- Must match documentation

The actual settings file (line of truth) must match whatever is documented in `docs/commit-workflow.md` Section 7 and `docs/deployment.md`. If new PostToolUse matchers are added (e.g., for `Read|Bash`), both docs must be updated in the same commit to avoid drift.

### 5. `docs/using-nefario.md` -- No changes needed

The user-facing orchestration guide does not describe hook behavior or tool output verbosity. It stays at the user workflow level ("what you experience at each phase"). The noise reduction is invisible to users by design -- sessions become cleaner without the user needing to know why. No updates needed here.

### 6. `docs/commit-workflow-security.md` -- Likely no changes needed

The security assessment covers hook input validation, git command safety, and fail-closed behavior. Output truncation does not change security properties. However, if the implementation suppresses error output from git hooks, the security doc should note that error output is always shown (fail-open for diagnostics) to maintain the fail-closed principle. This is a conditional recommendation: only needed if the implementation could accidentally swallow error output.

## Proposed Tasks

### Task 1: Update commit-workflow.md with hook output suppression behavior

**File:** `docs/commit-workflow.md`

**Changes:**

1. In Section 2 (Auto-Commit Behavior), add a bullet or sentence to the "Flow" list (after step 3, "Stage and commit silently") clarifying that git commit hook stdout/stderr is captured and discarded on success (exit 0). On non-zero exit, the full hook output is shown inline for debugging.

2. In Section 7 (Hook Composition), update the `.claude/settings.json` example to include any new hook entries for output noise reduction. Update the hook scripts description if new scripts are added or existing scripts gain new responsibilities.

**Estimated scope:** 5-15 lines changed.

### Task 2: Update deployment.md hook table

**File:** `docs/deployment.md`

**Changes:**

1. Add any new hook script to the Hook Scripts table (script name, event, purpose).
2. Update the settings configuration description if new matchers or hooks are registered.

**Estimated scope:** 3-8 lines changed.

### Task 3: Add one-sentence note to orchestration.md

**File:** `docs/orchestration.md`

**Changes:**

1. In Section 5 (Commit Points in Execution Flow), add a brief note that git commit hook output is suppressed during auto-commits to keep the approval gate flow clean.

**Estimated scope:** 1-2 lines changed.

### Task 4: Verify settings.json matches documentation

**File:** `.claude/settings.json` (not a doc file, but must stay consistent)

**Changes:**

1. After implementation changes are complete, verify the settings.json examples in commit-workflow.md and deployment.md match the actual file. This is a cross-check, not a writing task -- but documentation drift between the settings file and its documentation is a known risk.

**Estimated scope:** Review only, 0 lines changed in docs if implementation keeps docs in sync.

## Risks and Concerns

### Risk 1: Documentation drift between settings.json and docs

Two documentation files (`docs/commit-workflow.md` Section 7 and `docs/deployment.md` Hook Deployment) contain inline copies of the `.claude/settings.json` structure. If the implementation changes the actual settings file without updating both doc files, they drift. **Mitigation:** Documentation tasks should run after implementation is complete so the doc author can read the final settings file and reproduce it accurately.

### Risk 2: Suppressing error output accidentally

If the noise reduction implementation truncates all hook output (including errors), users lose the ability to diagnose commit hook failures. The documentation should explicitly state that error output (non-zero exit) is always shown in full. This is both a documentation concern and an implementation concern -- the docs should describe the intended behavior clearly enough that the implementation cannot accidentally break it.

### Risk 3: "Last 2 lines" truncation may lose context

The success criteria specify "Read, Write, and Bash tool call output is reduced to the last 2 lines." For Read tool calls that display file contents, the last 2 lines are rarely the most useful summary. For Write tool calls, the last 2 lines might be fine (typically just "Wrote N bytes to path"). The documentation should explain what the user sees after truncation so they know the full output is still available if needed (e.g., in the tool call details or session log). This is a user expectation management concern.

### Risk 4: Scope creep into user-facing guide

The `docs/using-nefario.md` guide currently does not mention hooks or tool output. Adding noise reduction details there would violate the guide's level of abstraction (user workflow, not implementation details). Keep that boundary intact -- noise reduction documentation belongs in the contributor/architecture docs, not the user guide.

## Additional Agents Needed

**software-docs-minion** -- If the implementation introduces new hook scripts or modifies the hook composition pattern, the software-docs-minion should update the architecture-level documentation alongside these user-docs changes. The commit-workflow.md and deployment.md files straddle the boundary between architecture documentation (software-docs-minion) and operational/user-facing documentation (user-docs-minion). Coordination is needed to avoid conflicting edits to the same files.

Otherwise, no additional agents are needed. The documentation changes are small, well-scoped, and do not require UX, security, or testing input beyond what the implementation agents provide.
