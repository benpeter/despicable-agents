# Meta-Plan: Compaction Gate Enhancements (#110 + #112)

## Scope

**In scope**: Two enhancements to the compaction checkpoint gates in `skills/nefario/SKILL.md`:

1. **#112 -- Context usage embedding**: Parse `<system_warning>` token usage attachment before firing compaction gates, compute context percentage, and embed it in the AskUserQuestion `question` text so users can make informed compact/skip decisions.
2. **#110 -- pbcopy clipboard support**: Pipe the `/compact` command to `pbcopy` before presenting the gate, so it is already on the clipboard. Keep the printed code block as visible fallback. Mac-only is acceptable.

**Locations**: Two compaction checkpoints in `skills/nefario/SKILL.md`:
- Post-Phase 3 checkpoint (lines ~796-828)
- Post-Phase 3.5 checkpoint (lines ~1208-1240)

**Out of scope**: No changes to other AskUserQuestion gates. No cross-platform clipboard support. No changes to the status line itself. No programmatic `/compact` invocation (#88).

## Planning Consultations

### Consultation 1: DevX -- AskUserQuestion UX and clipboard interaction

- **Agent**: devx-minion
- **Planning question**: The compaction gates need two additions: (a) a context usage line like `[Context: 72% used -- 56k tokens remaining]` embedded in the AskUserQuestion question text, and (b) a `pbcopy` call that pre-loads the `/compact` command onto the clipboard before the gate fires. Given that AskUserQuestion occludes the status line and the user needs context info to decide, what is the best placement and formatting of the context percentage within the question text? Should it go before the existing question, after it, or replace part of it? Should the pbcopy be a silent Bash call before the AskUserQuestion, or should its success/failure be surfaced? Consider that the printed code block remains as fallback.
- **Context to provide**: The two compaction checkpoint sections from SKILL.md (lines 796-828 and 1208-1240), the AskUserQuestion conventions (lines 502-513 -- header max 12 chars, question must end with `\n\nRun: $summary_full`), and both GitHub issues (#110, #112).
- **Why this agent**: DevX expertise covers CLI interaction patterns, user-facing output formatting, and clipboard ergonomics. The core challenge is making the AskUserQuestion informative without cluttering the compact gate UI.

### Consultation 2: Observability -- system_warning parsing reliability

- **Agent**: observability-minion
- **Planning question**: Issue #112 requires parsing the `<system_warning>` token usage attachment (format: `Token usage: {used}/{total}; {remaining} remaining`) to extract context percentage. This attachment is injected by Claude Code after tool calls. What is the most robust way to instruct an agent (in a SKILL.md spec) to parse this data? The agent cannot access it programmatically -- it appears as text in the conversation context. Should the spec instruct the agent to: (a) look backward in its own context for the most recent `<system_warning>`, (b) make a lightweight tool call first to trigger a fresh warning, then parse? What graceful degradation should apply if the warning format changes or is absent?
- **Context to provide**: Issue #112 body (which documents the research into alternatives), the `<system_warning>` format, the two checkpoint locations in SKILL.md.
- **Why this agent**: Observability expertise covers log/signal parsing patterns, format reliability, and graceful degradation. The `<system_warning>` is essentially a runtime signal that needs robust extraction.

## Cross-Cutting Checklist

- **Testing** (test-minion): EXCLUDE from planning. The changes are to a SKILL.md specification file (natural language instructions), not executable code. There is nothing to unit-test or integration-test. The verification path is manual: run a nefario orchestration and observe the compaction gates.
- **Security** (security-minion): EXCLUDE from planning. No auth, no user input processing, no secrets, no new attack surface. The pbcopy call pipes a deterministic string (the `/compact` command) -- no injection risk. The `<system_warning>` parsing reads a system-injected attachment, not user input.
- **Usability -- Strategy** (ux-strategy-minion): INCLUDE -- covered by devx-minion consultation above. The core UX question (how to present context info within an AskUserQuestion that occludes the status line) is the primary planning challenge. DevX is the better fit here because this is CLI/terminal UX, not product journey mapping. If the synthesis reveals broader journey concerns, ux-strategy-minion can be added at execution time.
- **Usability -- Design** (ux-design-minion / accessibility-minion): EXCLUDE from planning. No UI components or visual design -- this is terminal text output within an existing AskUserQuestion pattern.
- **Documentation** (software-docs-minion / user-docs-minion): EXCLUDE from planning. The changes are self-documenting within SKILL.md. No separate documentation artifact is needed. SKILL.md IS the documentation.
- **Observability** (observability-minion / sitespeed-minion): INCLUDE -- covered by Consultation 2 above. The `<system_warning>` parsing is a signal-extraction problem that benefits from observability expertise.

## Anticipated Approval Gates

**None anticipated.** Both changes are:
- Additive (existing printed code block preserved as fallback)
- Easy to reverse (revert the SKILL.md lines)
- Low blast radius (no downstream tasks depend on these changes)
- Clear requirements with minimal ambiguity (both issues specify exactly what to do)

Per the gate classification matrix: easy to reverse + low blast radius = NO GATE.

The single execution task will modify one file (`skills/nefario/SKILL.md`) in two parallel locations with nearly identical changes. Standard post-execution review (Phase 5) will catch any issues.

## Rationale

This is a focused SKILL.md specification change. Two consultations are sufficient:

1. **devx-minion** is primary because the core challenge is CLI UX: formatting context info within the AskUserQuestion constraints (12-char header, trailing `\n\nRun:` line), and clipboard ergonomics (silent pbcopy before the gate).

2. **observability-minion** is secondary because parsing `<system_warning>` is a signal-extraction problem. The format could change, the warning could be absent, and the spec needs graceful degradation instructions. This is exactly what observability expertise covers.

No other specialists are needed for planning. The task is well-scoped (one file, two locations, clear requirements from both issues), the changes are additive and reversible, and the domain is CLI interaction design + signal parsing.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding | Not relevant -- task edits SKILL.md, not AGENT.md files |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- task does not change status line configuration |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain.
