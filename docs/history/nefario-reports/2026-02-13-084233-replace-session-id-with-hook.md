---
type: nefario-report
version: 3
date: "2026-02-13"
time: "08:42:33"
task: "Replace /tmp/claude-session-id with SessionStart hook in nefario skill frontmatter"
source-issue: 74
mode: full
agents-involved: [devx-minion, security-minion, test-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 4
gate-count: 1
outcome: completed
---

# Replace /tmp/claude-session-id with SessionStart hook in nefario skill frontmatter

## Summary

Replaced the global `/tmp/claude-session-id` shared file mechanism with a `SessionStart` hook in the nefario skill frontmatter. The hook writes `CLAUDE_SESSION_ID` to `CLAUDE_ENV_FILE`, making it available as an environment variable in all subsequent Bash tool calls. This eliminates the last-writer-wins race condition when multiple Claude Code sessions run concurrently.

## Original Prompt

> **Outcome**: Nefario and the status line no longer rely on the shared `/tmp/claude-session-id` file to communicate the session ID. Instead, a `SessionStart` hook defined in the nefario skill frontmatter writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`, making it available as an environment variable in all subsequent Bash tool calls during the orchestration. This eliminates the last-writer-wins race condition when multiple Claude Code sessions run concurrently.
>
> **Success criteria**: `CLAUDE_SESSION_ID` env var available in Bash tool calls; `/tmp/claude-session-id` no longer written or read; SKILL.md uses `$CLAUDE_SESSION_ID`; status line command no longer writes session-id file; despicable-statusline skill updated; concurrent sessions isolated; docs updated; no new settings.json entries.

## Key Design Decisions

#### No `once: true` on SessionStart hook

**Rationale**:
- `CLAUDE_ENV_FILE` contents may not persist across compaction and `/clear` events
- Re-running the hook on every SessionStart event is cheap (milliseconds) and eliminates the risk

**Alternatives Rejected**:
- `once: true`: Would be more efficient but risks losing the env var after compaction, breaking all status writes

#### Bare `KEY=VALUE` format in CLAUDE_ENV_FILE

**Rationale**:
- Claude Code's `CLAUDE_ENV_FILE` uses bare `KEY=VALUE` format, not shell `export` syntax

**Alternatives Rejected**:
- `export CLAUDE_SESSION_ID=...`: Wrong format for CLAUDE_ENV_FILE

#### Inline command, not script file

**Rationale**:
- Skill is deployed via symlink; script file path resolution is fragile across projects
- The command is a one-liner that doesn't warrant a separate file

**Alternatives Rejected**:
- External script file: Path resolution issues with symlink deployment

### Conflict Resolutions

The devx-minion initially showed `export` prefix in the CLAUDE_ENV_FILE write. Corrected to bare `KEY=VALUE` based on Claude Code hooks documentation. No inter-agent conflicts arose.

## Phases

### Phase 1: Meta-Plan

Nefario identified this as a tightly scoped infrastructure change spanning 4 files. Only devx-minion was selected for planning consultation -- the task's domain concern (SessionStart hook lifecycle, frontmatter format, session event edge cases) falls squarely within developer tooling expertise. All cross-cutting dimensions except documentation were excluded.

### Phase 2: Specialist Planning

devx-minion researched the Claude Code hooks system and confirmed the exact YAML format for skill frontmatter hooks. Key findings: no `once: true` (compaction risk), no matcher (match all events), extract `session_id` from stdin JSON via `jq`, use inline command (not script file). Identified 9 replacement locations in SKILL.md and confirmed `commit-point-check.sh` already has the right `CLAUDE_SESSION_ID` fallback.

### Phase 3: Synthesis

The plan consolidated into 4 tasks: (1) add hook + replace 9 SID references in SKILL.md (gated), (2) update despicable-statusline skill, (3) update docs/using-nefario.md, (4) verify no remaining references. Tasks 1-3 run in parallel; Task 4 depends on all three.

### Phase 3.5: Architecture Review

Five mandatory reviewers participated. Security-minion ADVISED adding `tr` sanitization to the hook command (defense-in-depth). Test-minion ADVISED considering a bash test script but acknowledged manual verification is adequate for this scope. Software-docs-minion produced a 5-item documentation checklist. Lucy confirmed alignment with CLAUDE.md conventions and noted an untracked duplicate SKILL.md. Margo APPROVED with no concerns about complexity.

### Phase 4: Execution

Tasks 1-3 executed in parallel. All completed successfully. Task 1's approval gate was presented with HIGH confidence and approved. Task 4 (verification) confirmed zero remaining references to `/tmp/claude-session-id` in active files.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all APPROVED. No blocking findings. NITs noted the `tr` sanitization is defensive against a non-existent attack vector but harmless to keep.

### Phase 6: Test Execution

Skipped (no test infrastructure in repository).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Added upgrade note to `docs/using-nefario.md` for existing users whose status line command still contains the old `echo "$sid" > /tmp/claude-session-id` fragment. Verified `docs/architecture.md` and `docs/orchestration.md` have no references to the old mechanism.

<details>
<summary>Agent Contributions (1 planning, 5 review, 3 code review)</summary>

### Planning

**devx-minion**: Researched Claude Code hooks system and designed the SessionStart hook. Provided exact YAML format, recommended against `once: true` and matchers, identified 9 replacement locations.
- Adopted: All recommendations (hook format, no once:true, inline command, 9-location replacement)
- Risks flagged: CLAUDE_ENV_FILE persistence across compaction, skill-scoped hook edge cases, existing users' stale settings

### Architecture Review

**security-minion**: ADVISE. Recommended `tr -dc '[:alnum:]-_'` sanitization on session_id extraction. Confirmed change is a net security improvement.

**test-minion**: ADVISE. Suggested bash test script for hook command validation. Acknowledged manual verification adequate for this scope.

**software-docs-minion**: ADVISE. Produced 5-item documentation checklist. Identified migration note need for existing users.

**lucy**: ADVISE. Confirmed CLAUDE.md compliance and scope alignment. Noted untracked duplicate SKILL.md and meta-plan/synthesis gate count divergence.

**margo**: APPROVE. No concerns. Change reduces complexity (removes shared-file coordination, replaces with platform-native mechanism).

### Code Review

**code-review-minion**: APPROVE. Confirmed secure implementation with proper sanitization and defensive guards.

**lucy**: APPROVE. All conventions met, no scope creep, no intent drift.

**margo**: APPROVE. Proportional, minimal, no over-engineering.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Add SessionStart hook + replace all SID references | devx-minion | completed |
| 2 | Update despicable-statusline skill | devx-minion | completed |
| 3 | Update docs/using-nefario.md | devx-minion | completed |
| 4 | Verify no remaining references | devx-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [skills/nefario/SKILL.md](../../../skills/nefario/SKILL.md) | modified | Added SessionStart hook to frontmatter; replaced 9 SID sourcing patterns with $CLAUDE_SESSION_ID |
| [.claude/skills/despicable-statusline/SKILL.md](../../../.claude/skills/despicable-statusline/SKILL.md) | modified | Removed `echo "$sid" > /tmp/claude-session-id` from State A command |
| [docs/using-nefario.md](../../using-nefario.md) | modified | Updated "How It Works" explanation, manual config example, added upgrade note |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Add SessionStart hook + replace all SID references | devx-minion | HIGH | approved | 1 |

## Decisions

#### Add SessionStart hook + replace all SID references

**Decision**: Accept the SessionStart hook in frontmatter and all 9 SID replacements with `$CLAUDE_SESSION_ID`.
**Rationale**: The hook format matches Claude Code's hooks spec. All replacements are consistent two-line-to-one-line mechanical changes. Zero references to the old mechanism remain.
**Rejected**: `once: true` (compaction risk), `export` prefix (wrong format), script file (symlink path issues).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 APPROVE (code-review-minion, lucy, margo) |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Migration note added to docs/using-nefario.md |

## External Skills

| Skill | Classification | Recommendation | Tasks Used |
|-------|---------------|----------------|------------|
| despicable-statusline | LEAF | Modification target (SKILL.md edited), not invoked | Task 2 |
| despicable-lab | ORCHESTRATION | Not relevant | None |

## Working Files

<details>
<summary>Working files (21 files)</summary>

Companion directory: [2026-02-13-084233-replace-session-id-with-hook/](./2026-02-13-084233-replace-session-id-with-hook/)

- [Original Prompt](./2026-02-13-084233-replace-session-id-with-hook/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-084233-replace-session-id-with-hook/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-084233-replace-session-id-with-hook/phase2-devx-minion.md)
- [Phase 3: Synthesis](./2026-02-13-084233-replace-session-id-with-hook/phase3-synthesis.md)
- [Phase 3.5: docs-checklist](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-docs-checklist.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-software-docs-minion.md)
- [Phase 5: code-review-minion](./2026-02-13-084233-replace-session-id-with-hook/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-084233-replace-session-id-with-hook/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-084233-replace-session-id-with-hook/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-084233-replace-session-id-with-hook/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-084233-replace-session-id-with-hook/phase2-devx-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-084233-replace-session-id-with-hook/phase3.5-margo-prompt.md)
- [Phase 4: devx-task1 prompt](./2026-02-13-084233-replace-session-id-with-hook/phase4-devx-task1-prompt.md)
- [Phase 4: devx-task2 prompt](./2026-02-13-084233-replace-session-id-with-hook/phase4-devx-task2-prompt.md)
- [Phase 4: devx-task3 prompt](./2026-02-13-084233-replace-session-id-with-hook/phase4-devx-task3-prompt.md)
- [Phase 4: devx-task4 prompt](./2026-02-13-084233-replace-session-id-with-hook/phase4-devx-task4-prompt.md)

</details>
