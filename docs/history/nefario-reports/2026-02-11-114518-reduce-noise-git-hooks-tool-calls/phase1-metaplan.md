# Meta-Plan: Reduce Noise from Git Commit Hooks and Tool Calls in Main Session

Source issue: #26

## Context

The despicable-agents project uses Claude Code hooks (configured in `.claude/settings.json`) for two purposes:
1. **PostToolUse hook** (`track-file-changes.sh`): Tracks file changes after Write/Edit tool calls by appending to a session-scoped ledger.
2. **Stop hook** (`commit-point-check.sh`): Presents a commit checkpoint when the agent finishes, reading from that ledger. In orchestrated sessions, it is suppressed via a marker file.

The issue requests reducing session noise from two sources:
- **Git commit hook output**: Currently, when commits happen, hook output (pre-commit, commit-msg, etc.) appears inline. The orchestrated session marker already suppresses the Stop hook, but git's own commit hooks (pre-commit, commit-msg) still produce output during auto-commits.
- **Read/Write/Bash tool output**: Verbose tool output clutters the session. The request is to reduce this to the last 2 lines.

### Key Technical Findings

From the Claude Code hooks reference:
- **PostToolUse hooks** can return `{ "suppressOutput": true }` to hide stdout from verbose mode output.
- **PostToolUse hooks** can return `{ "decision": "block", "reason": "..." }` to provide feedback to Claude.
- PostToolUse hooks receive `tool_name`, `tool_input`, and `tool_response` on stdin.
- The `suppressOutput` field hides hook stdout from the transcript, but does NOT control the tool's own output.
- There is no documented hook mechanism to truncate or suppress a tool's native output (Read/Write/Bash results).

### What This Means for the Task

1. **Git commit hook output suppression**: This can be addressed by modifying how git commits are executed (e.g., adding `--quiet` flags, redirecting hook output) or by wrapping commit commands. This is a shell scripting / devx problem.
2. **Tool output truncation**: Claude Code does not offer a hook to truncate tool output. The "last 2 lines" requirement may need to be addressed through SKILL.md / CLAUDE.md instructions that tell the agent to use specific patterns (e.g., `command 2>&1 | tail -2`), or through a PreToolUse hook that modifies Bash commands to pipe through tail. This is a devx / Claude Code configuration problem.

### Current Hook Configuration

```json
{
  "hooks": {
    "Stop": [{ "hooks": [{ "type": "command", "command": "commit-point-check.sh", "timeout": 10 }] }],
    "PostToolUse": [{ "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "track-file-changes.sh", "timeout": 5 }] }]
  }
}
```

## Planning Consultations

### Consultation 1: Git Commit Noise Suppression Strategy

- **Agent**: devx-minion
- **Planning question**: How should we suppress git commit hook output (pre-commit, commit-msg, etc.) during auto-commits in the main orchestration session? Consider these approaches: (a) Adding `--quiet` or `--no-verify` flags to git commit commands, (b) Wrapping git commit in a script that captures and filters output, (c) Using environment variables to signal hooks to be silent. The solution must preserve hook functionality (hooks still run, still catch errors) but suppress their normal stdout/stderr unless an error occurs. What is the simplest approach that works with Claude Code's existing Bash tool?
- **Context to provide**: Current commit workflow docs at `docs/commit-workflow.md`, current hook scripts at `.claude/hooks/commit-point-check.sh`, the SKILL.md auto-commit instructions, and the fact that git commit hooks are the standard git hooks in `.git/hooks/` (currently all `.sample` files -- no active custom hooks). The noise is likely from pre-commit hooks installed by tools like husky or from git's own output.
- **Why this agent**: devx-minion specializes in CLI design, configuration files, and developer experience. This is fundamentally about improving the developer experience of the orchestration session by reducing CLI noise.

### Consultation 2: Tool Output Truncation Strategy

- **Agent**: devx-minion
- **Planning question**: How should we reduce Read, Write, and Bash tool output to the last 2 lines in the main orchestration session? The Claude Code hooks system offers PreToolUse hooks that can modify tool input (via `updatedInput`) and PostToolUse hooks that can provide feedback. Consider: (a) A PreToolUse hook on Bash that wraps commands to pipe through `tail -2`, (b) A PostToolUse hook on Read/Write/Bash that uses `suppressOutput` plus a `systemMessage` with truncated output, (c) CLAUDE.md instructions telling the agent to use concise commands, (d) A combination of approaches. The solution must not break existing tool functionality and must still surface errors. What is the most reliable and least invasive approach?
- **Context to provide**: The Claude Code hooks reference (especially PreToolUse `updatedInput` field, PostToolUse `suppressOutput` and `systemMessage` fields), current `.claude/settings.json` hook configuration, and the fact that this applies specifically to the "main session" (the orchestration session, not subagent sessions).
- **Why this agent**: Same reasoning -- this is a developer experience and configuration problem. devx-minion understands CLI tool behavior, output formatting, and how to create good defaults without breaking power-user workflows.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning. The hooks need to be tested to ensure they do not break existing commit workflow or tool functionality. Question: What test scenarios should we define to verify that (a) git commit hooks are suppressed in normal flow but errors still surface, (b) tool output truncation works correctly for Read/Write/Bash, and (c) subagent sessions are unaffected?
- **Security**: Exclude security-minion from planning. The task does not create new attack surface, handle auth, process user input, or introduce dependencies. It modifies output verbosity of existing tools. Security review in Phase 3.5 is sufficient.
- **Usability -- Strategy**: ALWAYS include. Question for ux-strategy-minion: From a user journey perspective, what is the right balance between noise reduction and visibility? The issue requests "last 2 lines" -- is this the right truncation level, or should it be context-dependent (e.g., more lines for errors, fewer for success)? Should there be a way for the operator to temporarily increase verbosity when debugging?
- **Usability -- Design**: Exclude. No user-facing interfaces are produced.
- **Documentation**: ALWAYS include. Question for user-docs-minion: The commit workflow documentation (`docs/commit-workflow.md`) and potentially the orchestration docs (`docs/orchestration.md`) need to be updated to reflect the noise reduction behavior. What sections need updates?
- **Observability**: Exclude. No production services, APIs, or background processes are created. The task is about CLI output formatting.

## Anticipated Approval Gates

**None anticipated.** All changes are additive configuration (hook scripts, settings.json updates) with low blast radius and high reversibility. No downstream tasks depend on architectural decisions here. The gate classification matrix places this firmly in the "NO GATE" quadrant (easy to reverse, low blast radius).

## Rationale

The task spans two domains that are both in devx-minion's wheelhouse: CLI output management and hook configuration. Rather than splitting between two specialists who would largely cover the same ground, a single devx-minion consultation covers both aspects. The cross-cutting agents (test-minion for test strategy, ux-strategy-minion for UX, user-docs-minion for docs) add genuine planning value because:

- test-minion needs to define verification scenarios for hook behavior (hooks are notoriously hard to test)
- ux-strategy-minion should validate the truncation strategy (2 lines might be too aggressive or not enough)
- user-docs-minion needs to identify which docs need updating

Security-minion, observability-minion, ux-design-minion, accessibility-minion, and sitespeed-minion are excluded from planning because this task is purely about CLI output formatting with no runtime, UI, web, or security implications. They will still review in Phase 3.5 as mandated.

## Scope

**In scope:**
- Suppressing git commit hook output in the main orchestration session (errors still surface)
- Reducing Read, Write, and Bash tool output verbosity in the main session
- Updating `.claude/settings.json` hook configuration
- Creating new hook scripts as needed in `.claude/hooks/`
- Updating documentation to reflect the new behavior

**Out of scope:**
- Modifying git hook logic (pre-commit, commit-msg hook scripts themselves)
- Adding new git hooks
- Changing tool behavior outside the main session (subagent sessions unaffected)
- Changing behavior of tool types other than Read, Write, and Bash
- Modifying the commit-point-check.sh or track-file-changes.sh behavior (only output handling)
