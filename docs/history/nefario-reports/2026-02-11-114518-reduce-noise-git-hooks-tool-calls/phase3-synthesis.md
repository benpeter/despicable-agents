# Delegation Plan: Reduce Noise from Git Commit Hooks and Tool Calls

**Team name**: noise-reduction
**Description**: Suppress verbose git commit hook output and reduce tool call output noise in nefario main orchestration sessions.

Source issue: #26

---

## Architectural Decisions

Before describing the tasks, here are the key design decisions made during synthesis, resolving conflicts and ambiguities from specialist input.

### Decision 1: No PreToolUse hook for Bash commands

The devx-minion proposed a PreToolUse hook on Bash that intercepts git commands and wraps them with `| tail -2`. After reviewing all specialist input, this approach is rejected in favor of the simpler alternative.

**Why rejected:**
- Exit code destruction through pipes is a serious risk, even with `set -o pipefail` (which requires wrapping in `bash -c`, adding complexity)
- Commands with existing pipes, heredocs, or `&&` chains break when another `| tail -2` is appended
- The hook fires on ALL Bash tool calls in all sessions. Scoping via marker file adds yet more complexity
- Git's built-in `--quiet` flag does exactly what we need for commit output with zero risk
- SKILL.md instructions control the orchestrated session behavior, and that is the correct layer

**What instead:** Use `git commit --quiet` in SKILL.md instructions (Task 1) and add CLAUDE.md output discipline instructions (also Task 1). This is the devx-minion's "Option B" approach. It is simpler, risk-free, and addresses the issue scope.

### Decision 2: No PostToolUse hook for Read/Write/Bash output truncation

The test-minion confirmed (Risk R5) that PostToolUse `suppressOutput` only hides the hook's own stdout from verbose mode -- it does NOT suppress or modify the tool's native output that Claude sees in context. There is no hook mechanism to truncate built-in tool output.

**What instead:** CLAUDE.md/SKILL.md instructions tell the orchestrator to minimize tool output verbosity. This is advisory (not mechanical), but the highest-noise source (git commit output) is handled mechanically via `--quiet`. For Read/Write/Bash, the instructions provide guidance that Claude follows in the vast majority of cases.

### Decision 3: Two-tier output model adopted from ux-strategy-minion

The ux-strategy-minion's two-tier model is sound and adopted as the spec:

| Outcome | Lines shown | Rationale |
|---------|-------------|-----------|
| Success (exit 0) | Last 2 lines | Confirms completion. Operator scans, moves on. |
| Error (exit non-zero) | Last 10 lines | Captures actionable error context. |

Git commit hooks specifically: suppress entirely on success (the informational commit line already confirms the action), show full output on failure.

### Decision 4: Scope is SKILL.md + CLAUDE.md instructions only

Given Decisions 1-2, this task reduces to:
1. Adding `--quiet` flags to git commit/push instructions in SKILL.md
2. Adding a "Session Output Discipline" section to CLAUDE.md
3. Updating documentation to reflect the convention
4. Adding tests for the `--quiet` behavior to the existing test suite

No new hook scripts are created. No changes to `.claude/settings.json`. This is the leanest possible approach that satisfies all three success criteria.

### Decision 5: Session scoping is natural (no marker file needed for this approach)

The `--quiet` flag approach is instruction-based, scoped to orchestrated sessions via SKILL.md. SKILL.md only runs during `/nefario` orchestrations. Single-agent sessions and subagents are unaffected because they do not follow SKILL.md instructions. No marker file gating is needed.

The CLAUDE.md output discipline instructions are scoped with the phrase "During nefario-orchestrated sessions" to avoid affecting single-agent sessions.

### Decision 6: Deferred item -- verbosity escape hatch

Per ux-strategy-minion recommendation (YAGNI): no debugging escape hatch in this iteration. If the two-tier model proves insufficient after 5+ orchestration sessions, add a marker-file toggle. Record this as a deferred item in the execution report.

---

## Tasks

### Task 1: Add output discipline to SKILL.md and CLAUDE.md
- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are implementing noise reduction for nefario orchestration sessions.
    The goal: suppress verbose git output and reduce tool call noise so the
    operator can follow the session flow without wading through irrelevant output.

    ## What to do

    ### 1. Update SKILL.md auto-commit instructions

    In `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`,
    find the auto-commit instructions (around lines 842-854 and 1088-1089 and 1274).
    Wherever auto-commits are described, add `--quiet` to the git commit command
    description. Specifically:

    - Line ~842-854 (Auto-commit after gate approval): In step 4, change the
      commit instruction to specify `git commit --quiet` with the conventional
      commit message format. Also add `git add` (already quiet by default) and
      note that `git push --quiet` should be used when pushing.
    - Line ~1088-1089 (Auto-commit remaining changes at wrap-up): Same -- note
      that commits use `--quiet`.
    - Line ~1104 (PR creation, git push): Add `--quiet` to the `git push` command.
    - Line ~1274 (Wrap-up commit): Same -- note `--quiet`.

    The key instruction to add/modify: "Use `git commit --quiet` for all
    auto-commits during orchestrated sessions. Use `git push --quiet` when
    pushing. The `--quiet` flag suppresses commit summary output while still
    showing errors on stderr."

    Do NOT add `--no-verify`. Hooks must still run; only their noise is suppressed.

    ### 2. Add "Session Output Discipline" section to CLAUDE.md

    In `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md`, add a new
    section after the "Engineering Philosophy" section and before "Versioning".
    Title: "## Session Output Discipline"

    Content should specify these rules for nefario-orchestrated sessions:

    ```markdown
    ## Session Output Discipline

    During nefario-orchestrated sessions, minimize tool output noise:

    - **Git commands**: Use `--quiet` on `commit` and `push`. Do not use `--no-verify`.
    - **Bash commands** producing expected verbose output: When the output is not
      needed for decision-making, pipe through `| tail -2` on success. Show last
      10 lines on error for debugging context.
    - **Read tool**: Use `offset` and `limit` parameters to read only what is needed.
      Do not read entire large files when a section suffices.
    - **Write/Edit tools**: Output is already concise (success/failure confirmation).
      No additional truncation needed.

    These conventions apply only during orchestrated sessions (invoked via `/nefario`).
    Single-agent sessions and subagents are not affected.
    ```

    ### 3. Add quiet convention to SKILL.md Communication Protocol

    In the Communication Protocol section of SKILL.md (around line 130), in the
    "NEVER SHOW" list, add a bullet:
    - "Verbose git command output (use `--quiet` flags on commit/push)"

    ## What NOT to do

    - Do NOT create any new hook scripts
    - Do NOT modify `.claude/settings.json`
    - Do NOT add PreToolUse or PostToolUse hooks
    - Do NOT use `--no-verify` on any git command
    - Do NOT modify the existing hook scripts (`track-file-changes.sh`,
      `commit-point-check.sh`)
    - Do NOT change any behavior for single-agent sessions or subagents

    ## Deliverables

    - Modified `skills/nefario/SKILL.md` -- `--quiet` flags on auto-commit instructions
    - Modified `CLAUDE.md` -- "Session Output Discipline" section
    - Modified `skills/nefario/SKILL.md` -- Communication Protocol NEVER SHOW addition

    ## Context

    - Current SKILL.md: `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`
    - Current CLAUDE.md: `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md`
    - The auto-commit flow is described in SKILL.md around lines 842-854
      (gate approval commits) and 1088-1089 (wrap-up commits)
    - The Communication Protocol is at lines 130-161 of SKILL.md
    - Git's `--quiet` flag suppresses the commit summary line
      (`[branch abc1234] message`) while still writing errors to stderr
    - The existing orchestrated-session marker
      (`/tmp/claude-commit-orchestrated-<session-id>`) is used elsewhere
      but is NOT needed for this approach

    ## Success criteria

    - All auto-commit instructions in SKILL.md include `--quiet`
    - CLAUDE.md has a "Session Output Discipline" section
    - Communication Protocol NEVER SHOW list includes git verbose output
    - No new files created
    - No hook scripts modified

- **Deliverables**: Modified `skills/nefario/SKILL.md`, modified `CLAUDE.md`
- **Success criteria**: `--quiet` present in all auto-commit instructions; output discipline section in CLAUDE.md; NEVER SHOW list updated

### Task 2: Update documentation
- **Agent**: user-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating documentation to reflect the noise reduction conventions
    added in Task 1. The implementation uses `git commit --quiet` and
    `git push --quiet` flags plus CLAUDE.md output discipline instructions.
    No new hook scripts were created. No changes to `.claude/settings.json`.

    ## What to do

    ### 1. Update docs/commit-workflow.md

    File: `/Users/ben/github/benpeter/despicable-agents/docs/commit-workflow.md`

    In Section 2 (Auto-Commit Behavior), around lines 109-112:
    - In step 3 of the Flow ("Stage and commit silently"), clarify that
      `git commit --quiet` is used during orchestrated sessions.
    - Add a brief note after the "Informational Output" subsection (line 116-123)
      stating that git commit hook output is captured by the `--quiet` flag;
      errors still surface via stderr.

    In Section 7 (Hook Composition), around line 260-262:
    - The text mentions "auto-commits are driven by SKILL.md instructions."
      Add a sentence noting that the SKILL.md instructions specify `--quiet`
      flags on git commit/push to suppress verbose output.

    ### 2. Update docs/orchestration.md

    File: `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md`

    In Section 5 (Commit Points in Execution Flow), around lines 516-517:
    - Add one sentence noting that auto-commits use `git commit --quiet`
      to keep the approval gate flow clean. Git commit hook output does not
      appear inline; only errors surface.

    ### 3. Update docs/deployment.md

    File: `/Users/ben/github/benpeter/despicable-agents/docs/deployment.md`

    No changes needed to the hook scripts table (no new hooks were created).
    No changes needed to settings configuration (no new hook entries).

    Verify and confirm: the Hook Deployment section (lines 79-104) accurately
    describes the current state. If it already matches reality, do nothing.
    If it mentions output behavior that contradicts the new `--quiet` convention,
    update it.

    ## What NOT to do

    - Do NOT add new sections to docs. Only modify existing paragraphs.
    - Do NOT update `docs/using-nefario.md` -- noise reduction is invisible
      to users by design, per user-docs-minion recommendation.
    - Do NOT update `docs/commit-workflow-security.md` -- the security
      properties are unchanged (error output is still shown).
    - Do NOT modify `.claude/settings.json` examples in the docs (they are
      unchanged).
    - Do NOT add information about PreToolUse hooks, PostToolUse output
      suppression, or any hook-based approach. The implementation is purely
      instruction-based (`--quiet` flags + CLAUDE.md).

    ## Context

    - Read Task 1's deliverables first: check the modified `CLAUDE.md` and
      `skills/nefario/SKILL.md` to see exactly what was changed.
    - The commit-workflow.md mermaid diagram (lines 59-97) shows `git commit`
      without `--quiet` -- this is acceptable; the diagram shows the logical
      flow, not the exact flags. Do not modify the diagram.
    - docs/deployment.md Hook Scripts table lists 2 scripts. This is unchanged.

    ## Deliverables

    - Modified `docs/commit-workflow.md` (5-15 lines changed)
    - Modified `docs/orchestration.md` (1-2 lines changed)
    - Verified `docs/deployment.md` (0 lines changed if already accurate)

    ## Success criteria

    - commit-workflow.md mentions `--quiet` convention in Section 2 and Section 7
    - orchestration.md mentions `--quiet` in Section 5
    - deployment.md accurately reflects hook state (no new hooks)
    - No contradictions between docs and SKILL.md/CLAUDE.md
    - Total changes are under 20 lines across all docs

- **Deliverables**: Modified docs (commit-workflow.md, orchestration.md; verified deployment.md)
- **Success criteria**: Docs reflect the `--quiet` convention; no contradictions; minimal changes

### Task 3: Add tests for quiet git output behavior
- **Agent**: test-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are extending the existing test suite to verify the noise reduction
    behavior. The implementation uses `git commit --quiet` and `git push --quiet`
    flags -- no new hook scripts were created.

    ## What to do

    Extend the existing test file at:
    `/Users/ben/github/benpeter/despicable-agents/tests/test-commit-hooks.sh`

    Add a new test section "--- Noise Reduction Tests ---" after the
    Integration Tests section (before the main function's report section).

    ### Tests to add

    **Test 1: git commit --quiet suppresses output on success**

    Create a git repo with a file, modify it, run `git commit --quiet -m "test"`.
    Assert that the commit succeeded (exit 0) AND that stdout is empty (no
    commit summary line like `[branch abc1234] message`). Verify the commit
    exists with `git log --oneline -1`.

    **Test 2: git commit --quiet still shows errors on failure**

    Create a git repo, add a pre-commit hook that exits 1 with an error
    message to stderr. Run `git commit --quiet -m "test"`. Assert that
    the commit failed (exit non-zero) AND that stderr contains the error
    message from the hook. This verifies that `--quiet` does not swallow
    errors.

    **Test 3: git push --quiet suppresses output on success**

    Create a git repo with a bare remote (use `git init --bare` for a local
    bare repo, then clone it). Make a commit, run `git push --quiet`. Assert
    exit 0 and that stdout is empty (no "To <remote>..." output). If setting
    up a bare remote is too complex for the test framework, skip this test
    with a comment explaining why.

    **Test 4: Existing 18 tests still pass (regression)**

    This is not a new test function -- it is verified by running the full
    suite. Ensure your new tests do not break existing setup/teardown or
    test infrastructure.

    ### Test infrastructure

    Follow the exact patterns from the existing test suite:
    - Use `setup` and `teardown` functions for each test
    - Use `pass` and `fail` helper functions
    - Create fresh temp directories with real git repos
    - Register new tests in the `main` function

    Add the new test functions before `main()` and register them in `main()`
    in a new section block:

    ```bash
    echo ""
    echo -e "${YELLOW}--- Noise Reduction Tests ---${NC}\n"

    setup; test_quiet_commit_suppresses_output; teardown
    setup; test_quiet_commit_shows_errors; teardown
    setup; test_quiet_push_suppresses_output; teardown  # if feasible
    ```

    ## What NOT to do

    - Do NOT create a new test file. Extend the existing one.
    - Do NOT test PostToolUse hook behavior (no PostToolUse changes were made).
    - Do NOT test PreToolUse hook behavior (no PreToolUse hooks exist).
    - Do NOT test Claude's session behavior end-to-end (untestable in automated tests).
    - Do NOT modify any existing test functions.
    - Do NOT change the test framework (pass/fail/setup/teardown helpers).

    ## Context

    - Existing test suite: `/Users/ben/github/benpeter/despicable-agents/tests/test-commit-hooks.sh`
    - The suite has 18 existing tests across 3 sections: File Change Tracker,
      Commit Checkpoint, and Integration Tests
    - Tests use real git repos in temp directories
    - The `setup` function creates a fresh temp dir, git repo, and unique session ID
    - The `teardown` function cleans up all temp files
    - The `pass`/`fail` functions track test counts for the final report

    ## Deliverables

    - Modified `tests/test-commit-hooks.sh` with 2-3 new test functions

    ## Success criteria

    - New tests verify that `--quiet` suppresses output on success
    - New tests verify that errors are NOT suppressed by `--quiet`
    - All 18 existing tests still pass
    - New tests follow the same patterns as existing tests
    - Total new code: approximately 60-90 lines

- **Deliverables**: Modified `tests/test-commit-hooks.sh` with noise reduction tests
- **Success criteria**: New tests pass; existing 18 tests still pass; error preservation verified

---

## Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| **Testing** | Task 3 (test-minion) | Tests verify `--quiet` behavior and error preservation |
| **Security** | Not needed | No new attack surface. No auth, input processing, secrets, or dependencies changed. `--quiet` does not affect hook execution -- only output. Error output is preserved. |
| **Usability -- Strategy** | Incorporated | ux-strategy-minion's two-tier model (2 lines success / 10 lines error) adopted as the spec in CLAUDE.md output discipline section. Git hooks: suppress on success, full on failure. |
| **Usability -- Design** | Not needed | No user-facing interfaces produced. This is configuration and documentation only. |
| **Documentation** | Task 2 (user-docs-minion) | Three docs updated to reflect the convention. |
| **Observability** | Not needed | No runtime components, services, or APIs created. This is prompt engineering and documentation. |

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing interfaces, no web-facing UI)

## Conflict Resolutions

### devx-minion PreToolUse hook vs. CLAUDE.md instructions

devx-minion proposed both a PreToolUse hook (Option A) and a CLAUDE.md-only approach (Option B). The specialist recommended Option A.

**Resolution**: Option B (CLAUDE.md instructions only) is adopted. Rationale:
- The PreToolUse hook introduces three risks: exit code destruction, pipe-in-pipe breakage, and session scoping complexity
- Git's built-in `--quiet` flag handles the primary noise source mechanically
- The remaining noise (Bash/Read output) is lower volume and adequately addressed by advisory instructions
- The project's engineering philosophy (KISS, lean and mean) favors the simpler approach
- The test-minion's Risk R5 confirmed that PostToolUse cannot truncate tool output, which eliminates the alternative mechanical approach for Read/Write

### ux-strategy-minion Read tool suppression

ux-strategy-minion recommended "1-line path summary" for Read tool output. This would require a mechanism to intercept Read output, which does not exist in the hooks API.

**Resolution**: Use CLAUDE.md instructions to encourage `offset`/`limit` parameters on Read calls instead of attempting output truncation. This reduces the amount of content read (and thus displayed) rather than truncating after the fact.

### user-docs-minion settings.json cross-check

user-docs-minion proposed a Task 4 to verify `.claude/settings.json` matches documentation. Since our approach makes NO changes to settings.json, this task is unnecessary.

**Resolution**: Dropped. The settings.json is unchanged. Documentation examples of settings.json in commit-workflow.md and deployment.md remain accurate.

## Risks and Mitigations

### Risk 1: CLAUDE.md instructions are advisory, not enforced (LOW)

Claude may not always follow CLAUDE.md output discipline instructions perfectly.

**Mitigation**: Acceptable risk. The highest-noise source (git commits) is mechanically enforced via `--quiet`. The remaining CLAUDE.md instructions cover lower-noise tools as a best-effort improvement. If compliance is poor after 5+ sessions, a PreToolUse hook can be reconsidered.

### Risk 2: Error output accidentally suppressed (LOW)

If an orchestrator adds `| tail -2` too aggressively based on CLAUDE.md instructions, error output could be truncated to 2 lines, missing root cause.

**Mitigation**: The CLAUDE.md instructions explicitly specify "last 10 lines on error." The ux-strategy-minion's two-tier model is the spec. Additionally, `git commit --quiet` preserves stderr output natively -- no piping is involved for git commands.

### Risk 3: Future SKILL.md changes forget `--quiet` (LOW)

As SKILL.md evolves, new auto-commit instructions might be added without `--quiet`.

**Mitigation**: The "Session Output Discipline" section in CLAUDE.md serves as the canonical rule. The SKILL.md Communication Protocol NEVER SHOW list reinforces it. Code review (Phase 5) would catch omissions in future plans.

## Execution Order

```
Batch 1: Task 1 (devx-minion: SKILL.md + CLAUDE.md changes)
          |
          v
Batch 2: Task 2 (user-docs-minion: documentation) -- parallel with Task 3
         Task 3 (test-minion: tests)
```

No approval gates. All three tasks are easy to reverse (additive documentation and instruction changes), low blast radius, and follow clear best practices. Gate budget: 0.

## Verification Steps

After all tasks complete:

1. Run `./tests/test-commit-hooks.sh` -- all tests pass (existing 18 + new 2-3)
2. Grep SKILL.md for `--quiet` -- should appear in all auto-commit sections
3. Grep CLAUDE.md for "Session Output Discipline" -- section exists
4. Grep SKILL.md Communication Protocol NEVER SHOW for "git" -- bullet exists
5. Grep docs/commit-workflow.md for `--quiet` -- mentioned in Sections 2 and 7
6. Grep docs/orchestration.md for `--quiet` -- mentioned in Section 5
7. Manual verification: run a `/nefario` session and observe reduced git output noise

## Deferred Items

- **Verbosity escape hatch**: If the two-tier model (2/10 lines) proves insufficient after 5+ orchestration sessions, add a marker-file toggle (`touch /tmp/claude-verbose-<session-id>`) that disables output discipline for debugging. (Per ux-strategy-minion, YAGNI for now.)
- **Mechanical enforcement for Read/Bash**: If CLAUDE.md compliance is poor, add a PreToolUse hook with proper exit code handling. (Per devx-minion, deferred pending evidence of need.)
