---
task: "Reduce noise from git commit hooks and tool calls in main session"
source-issue: 26
date: 2026-02-11
status: completed
agents-consulted: devx-minion, test-minion, ux-strategy-minion, user-docs-minion
agents-reviewed: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
agents-executed: devx-minion, user-docs-minion, test-minion
code-reviewers: code-review-minion, lucy, margo
verdict: approved
---

# Reduce Noise from Git Commit Hooks and Tool Calls

## Original Prompt

**Outcome**: The main orchestration session stays clean and focused by suppressing or summarizing verbose output from git commit hooks and read/write tool calls, so that the operator can follow the session flow without wading through irrelevant tool output.

**Success criteria**:
- Git commit hook output does not appear inline in the main session unless an error occurs
- Read, Write, and Bash tool call output is reduced to the last 2 lines in the main session
- Existing hook and tool functionality is unchanged

**Scope**:
- In: Git commit hook output handling, Read/Write tool call verbosity in the main session
- Out: Hook logic changes, new hooks, tool behavior outside the main session, other tool types

## Executive Summary

Implemented noise reduction for nefario-orchestrated sessions using the simplest viable approach: `--quiet` flags on all git commit/push/pull commands in SKILL.md, plus a "Session Output Discipline" subsection in CLAUDE.md with a two-tier output model (2 lines on success, 10 lines on error). No new hook scripts, no settings changes, no PreToolUse/PostToolUse hooks. The approach mechanically enforces quiet git output while providing advisory guidance for other tool types.

## Architectural Decisions

1. **No PreToolUse hook for Bash commands** — Rejected due to exit code destruction risk, pipe breakage, and scoping complexity. Git's built-in `--quiet` flag handles the primary noise source with zero risk.

2. **No PostToolUse hook for tool output truncation** — Confirmed that `suppressOutput` only hides hook stdout, not tool response in Claude's context. No hook mechanism exists to truncate built-in tool output.

3. **Two-tier output model** (from ux-strategy-minion) — Success: 2 lines. Error: 10 lines. Git hooks: suppress entirely on success, full output on failure.

4. **Pure instructions approach** — SKILL.md `--quiet` flags + CLAUDE.md output discipline section. Lean, risk-free, reversible.

5. **Natural session scoping** — No marker file needed. SKILL.md only runs during `/nefario`. CLAUDE.md section scoped with "During nefario-orchestrated sessions."

## Agent Contributions

### Planning Phase

| Agent | Recommendation | Tasks Proposed |
|-------|---------------|----------------|
| devx-minion | Two-pronged: --quiet flags + PreToolUse hook OR CLAUDE.md instructions | 3 |
| test-minion | Five test groups; flagged PostToolUse cannot truncate tool output | 5 |
| ux-strategy-minion | Two-tier model (2/10 lines); no escape hatch (YAGNI) | 3 |
| user-docs-minion | 4 docs need updates, all under 15 lines each | 4 |

### Architecture Review

| Reviewer | Verdict | Key Finding |
|----------|---------|-------------|
| security-minion | APPROVE | No security concerns; error visibility preserved |
| test-minion | ADVISE | Add git-native error test alongside hook error test |
| ux-strategy-minion | APPROVE | Two-tier model well-applied |
| software-docs-minion | ADVISE | Add using-nefario.md note; cross-reference CLAUDE.md↔SKILL.md |
| lucy | ADVISE | Flag advisory nature of criterion #2; add pipefail caveat |
| margo | APPROVE | Plan is simplest viable approach; strong YAGNI discipline |

### Code Review

| Reviewer | Verdict | Key Finding |
|----------|---------|-------------|
| code-review-minion | APPROVE | All requirements met, comprehensive test coverage |
| lucy | ADVISE | using-nefario.md modified beyond original synthesis scope (accepted: advisory incorporated) |
| margo | ADVISE | CLAUDE.md partially duplicates SKILL.md; tests verify git behavior not project code |

## Execution

### Task 1: Add output discipline to SKILL.md and CLAUDE.md
- **Agent**: devx-minion
- **Status**: Completed
- **Deliverables**:
  - `skills/nefario/SKILL.md`: 7 edits adding `--quiet` to all git commit/push/pull commands + NEVER SHOW update
  - `CLAUDE.md`: Added "Session Output Discipline" subsection under Engineering Philosophy

### Task 2: Update documentation
- **Agent**: user-docs-minion
- **Status**: Completed
- **Deliverables**:
  - `docs/commit-workflow.md`: 2 edits (Section 2 + Section 7)
  - `docs/orchestration.md`: 1 edit (Section 5)
  - `docs/using-nefario.md`: 1 edit (after phase descriptions)
  - `docs/deployment.md`: Verified, no changes needed

### Task 3: Add tests for quiet git output behavior
- **Agent**: test-minion
- **Status**: Completed
- **Deliverables**:
  - `tests/test-commit-hooks.sh`: 4 new tests (quiet commit suppresses output, hook errors preserved, native errors preserved, quiet push suppresses output)
  - All 23 tests pass (19 existing + 4 new)

## Verification

Verification: code review passed (1 APPROVE, 2 ADVISE), all 23 tests pass, docs updated (3 files).

## Success Criteria Assessment

| Criterion | Status | Notes |
|-----------|--------|-------|
| Git commit hook output suppressed unless error | MET | Mechanically enforced via `--quiet` flags |
| Read/Write/Bash output reduced to last 2 lines | PARTIALLY MET | Advisory via CLAUDE.md (no hook mechanism exists to enforce mechanically) |
| Existing functionality unchanged | MET | No hooks modified, no --no-verify, all existing tests pass |

## Deferred Items

- **Verbosity escape hatch**: Marker-file toggle for debugging. Deferred per YAGNI — revisit after 5+ orchestration sessions.
- **Mechanical enforcement for Read/Bash**: PreToolUse hook with proper exit code handling. Deferred pending evidence that advisory instructions are insufficient.

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-114518-reduce-noise-git-hooks-tool-calls/`

Files:
- `prompt.md` — Original prompt
- `phase1-metaplan.md` — Meta-plan
- `phase2-devx-minion.md` — devx-minion planning contribution
- `phase2-test-minion.md` — test-minion planning contribution
- `phase2-ux-strategy-minion.md` — ux-strategy-minion planning contribution
- `phase2-user-docs-minion.md` — user-docs-minion planning contribution
- `phase3-synthesis.md` — Final execution plan
- `phase5-code-review-minion.md` — Code review findings
- `phase5-lucy.md` — Lucy code review findings
- `phase5-margo.md` — Margo code review findings
