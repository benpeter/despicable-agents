# Phase 1: Meta-Plan

## Task Summary

Replace the shared `/tmp/claude-session-id` file mechanism with a `SessionStart` hook that writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`, making it available as an environment variable. This eliminates a last-writer-wins race condition when multiple Claude Code sessions run concurrently.

## Scope

**In scope:**
- Add `SessionStart` hook to nefario skill frontmatter (both `skills/nefario/SKILL.md` and `skills/nefario/nefario/SKILL.md`)
- Replace all `SID=$(cat /tmp/claude-session-id 2>/dev/null)` with `SID="$CLAUDE_SESSION_ID"` in SKILL.md
- Remove `echo "$sid" > /tmp/claude-session-id` from status line command in despicable-statusline SKILL.md
- Update `docs/using-nefario.md` (references old mechanism in "How It Works" section and manual config example)
- Ensure no new entries in `~/.claude/settings.json`

**Out of scope:**
- Hook logic for commit-point-check (covered by #73)
- Change ledger mechanism, defer/declined markers
- Nefario status file format
- `install.sh` changes

## Planning Consultations

### Consultation 1: DevX -- Skill Frontmatter Hook Design

- **Agent**: devx-minion
- **Planning question**: What is the correct YAML format for defining a `SessionStart` hook in a skill's YAML frontmatter? The hook needs to write `CLAUDE_SESSION_ID` to `CLAUDE_ENV_FILE`. Specifically: (1) Should the hook use a `once: true` flag since the session ID only needs to be set once per session? (2) Should we use a matcher (e.g., `startup`) or match all session start events (`startup`, `resume`, `clear`, `compact`) since `CLAUDE_ENV_FILE` contents may not persist across compaction/clear? (3) The hook script receives session_id in stdin JSON -- should it extract from stdin or is it already available as an env var? (4) What is the exact inline command vs. script file tradeoff given this is deployed via symlink?
- **Context to provide**: The Claude Code hooks reference docs (SessionStart section, CLAUDE_ENV_FILE section), current SKILL.md frontmatter (lines 1-9), the constraint that this must live in skill frontmatter only (not settings.json).
- **Why this agent**: DevX specializes in CLI/SDK design and developer ergonomics. The hook frontmatter format, the inline-vs-script decision, and the session lifecycle edge cases (resume, compact, clear) are DX concerns.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task modifies skill SKILL.md files (which are prompt/instruction documents, not executable code) and a documentation file. There is no testable code output -- the "test" is whether `$CLAUDE_SESSION_ID` is available in Bash tool calls during orchestration, which is a runtime verification, not something that can be unit-tested. The success criteria in the issue cover verification.
- **Security**: EXCLUDE. No new attack surface is created. The session ID was already written to a world-readable file at `/tmp/claude-session-id`; moving it to a per-session env var via `CLAUDE_ENV_FILE` is strictly more secure (process-scoped rather than filesystem-scoped). No auth, secrets, or user input handling changes.
- **Usability -- Strategy**: EXCLUDE. This is an internal infrastructure change with zero user-facing workflow impact. The status line continues to work identically; the only difference is that concurrent sessions no longer interfere. No journey changes, no cognitive load changes, no new user decisions.
- **Usability -- Design**: EXCLUDE. No UI components or visual changes.
- **Documentation**: INCLUDE. `docs/using-nefario.md` has a "How It Works" section and a manual configuration example that both reference the old `/tmp/claude-session-id` mechanism. These must be updated. software-docs-minion should review whether any other docs reference this mechanism.
- **Observability**: EXCLUDE. No runtime components, no services, no APIs. Status file mechanism is unchanged (still `/tmp/nefario-status-$SID`).

## Anticipated Approval Gates

**Zero gates.** This task has no high-blast-radius, hard-to-reverse decisions. All changes are:
- Additive YAML frontmatter (easy to revert)
- String replacements in instruction text (easy to revert)
- Documentation text updates (easy to revert)

No downstream tasks depend on intermediate deliverables. The entire task is a single coherent change set with clear, mechanical success criteria defined in the issue.

## Rationale

This is a tightly scoped infrastructure improvement with a single domain concern: how the nefario skill obtains the session ID. Only one specialist (devx-minion) has planning-relevant expertise -- specifically around the SessionStart hook lifecycle, frontmatter format, and edge cases like session resume/compaction.

The other agents in the delegation table (mcp-minion, iac-minion, etc.) have no relevant expertise for this task. It does not touch APIs, infrastructure, databases, AI/ML, frontend, or security surfaces.

software-docs-minion is included for Phase 3.5 (mandatory reviewer) where it will produce a documentation impact checklist, but does not need to participate in planning -- the documentation changes are straightforward text updates already identified in the issue scope.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | ORCHESTRATION | Agent rebuild pipeline | Not relevant -- no agents need rebuilding for this task |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Relevant as a **modification target** but not as an execution tool. The SKILL.md itself needs editing (remove `echo "$sid" > /tmp/claude-session-id` from the status line command template). It should NOT be invoked during execution. |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with a built-in specialist for this task. The despicable-statusline skill is a file to be edited, not a tool to delegate work to.
