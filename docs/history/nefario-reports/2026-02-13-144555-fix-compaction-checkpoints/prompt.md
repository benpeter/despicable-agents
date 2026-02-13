# Issue #87: Fix compaction checkpoints: add AskUserQuestion pause + clipboard copy

## Bug

Compaction checkpoints (after Phase 3 and Phase 3.5) print a blockquote advisory suggesting the user run `/compact`, but the orchestration proceeds immediately without pausing. The user sees the suggestion flash by and has no opportunity to act on it.

## Root cause

The checkpoint template (SKILL.md lines ~716-728 and ~1051-1061) prints a `>` blockquote with the `/compact` command, then says "if the user runs /compact, wait for continue." But there's no mechanism that actually **pauses execution**. Unlike approval gates which use `AskUserQuestion`, the compaction checkpoint is just output text.

## Why not just invoke /compact programmatically?

Claude Code's `/compact` is a built-in user-only command. Agents cannot invoke it — not via the Skill tool, not via prose output, not via hooks. This is a known limitation tracked as [anthropics/claude-code#19877](https://github.com/anthropics/claude-code/issues/19877). See #88 for a follow-up that will simplify this once that's resolved.

## Proposed fix

Replace the blockquote advisory with an `AskUserQuestion` gate:

- `header`: "Compact"
- `question`: "Phase N complete. Compact context before continuing?"
- `options`:
  1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt later phases." (recommended)
  2. label: "Compact", description: "Compact now. The /compact command will be copied to your clipboard."

**If user selects "Compact":**
1. Copy the full `/compact focus="Preserve: ..."` command to the system clipboard (via `pbcopy` on macOS, with fallback note for other platforms)
2. Print a short note: "Paste and run the command from your clipboard. You can type `continue` and hit Return while compaction is running — it will be queued and executed once compaction completes."
3. Wait for user to say "continue" before proceeding

**If user selects "Skip":**
Proceed immediately with a one-line note: "Continuing without compaction."

## Affected locations

- `skills/nefario/SKILL.md` line ~714 (post-Phase 3 checkpoint)
- `skills/nefario/SKILL.md` line ~1049 (post-Phase 3.5 checkpoint)

## References

- [anthropics/claude-code#19877](https://github.com/anthropics/claude-code/issues/19877) — feature request for Claude-invocable /compact
- [anthropics/claude-code#24606](https://github.com/anthropics/claude-code/issues/24606) — feature request for SDK compact() method
- #88 — follow-up: simplify once programmatic compaction is available

---
Additional context: use opus for all agents
