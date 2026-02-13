# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Exact YAML Format for the SessionStart Hook in Skill Frontmatter

Based on the [Claude Code hooks reference](https://code.claude.com/docs/en/hooks), hooks in skill frontmatter use this structure. The nefario skill frontmatter should become:

```yaml
---
name: nefario
description: >
  Orchestrate a team of specialist agents for complex, multi-domain tasks.
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
argument-hint: "#<issue> | <task description>"
hooks:
  SessionStart:
    - hooks:
        - type: command
          command: 'jq -r ".session_id" | xargs -I{} sh -c ''[ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_SESSION_ID={}" >> "$CLAUDE_ENV_FILE"'''
          once: true
---
```

Key format details:
- `hooks:` is a top-level frontmatter key at the same level as `name:` and `description:`
- Under `hooks:`, each event type (e.g., `SessionStart:`) is a key whose value is an array of matcher groups
- Each matcher group has an optional `matcher:` field and a required `hooks:` array of hook handlers
- Each handler has `type:`, `command:`, and optional fields like `once:` and `timeout:`
- No `matcher:` field needed when matching all SessionStart events (omitting matcher matches everything)

### 2. Use `once: true` -- Yes, With Caveats

The `once` field is explicitly supported for skill-scoped hooks (documented as "Skills only, not agents"). Since the session ID is immutable for the lifetime of a session, `once: true` is the correct choice. This means:

- The hook fires once on the first qualifying SessionStart event and is then removed for the rest of the skill's lifetime
- This is efficient -- no redundant writes on `/clear` or `/compact`

**However, there is a critical caveat**: we need to verify whether `CLAUDE_ENV_FILE` contents persist across compaction and `/clear`. The documentation says SessionStart fires on `startup`, `resume`, `clear`, and `compact` events, and that `CLAUDE_ENV_FILE` is only available in SessionStart hooks. If the env file is reset on compaction/clear, then `once: true` would cause the env var to disappear after the first compaction.

**My recommendation**: Do NOT use `once: true`. Use no matcher (match all SessionStart events). The command is fast (a single `jq | xargs` pipeline), and redundantly writing the same value is harmless. This eliminates the risk of losing the env var after compaction. The append (`>>`) pattern means duplicate entries are fine -- the last `export` wins.

### 3. Do NOT Use a Matcher -- Match All SessionStart Events

SessionStart matchers are: `startup`, `resume`, `clear`, `compact`.

Since we cannot be certain that `CLAUDE_ENV_FILE` contents persist across `clear` and `compact` events, the hook should fire on ALL SessionStart events. Omitting the `matcher:` field entirely (or using `"*"`) achieves this.

This is the safe, defensive approach. The cost is negligible -- the hook runs a simple `jq` extraction that completes in milliseconds.

### 4. Extract session_id from stdin JSON -- Not from an Env Var

Per the hooks documentation, all hook events receive a JSON payload on stdin with `session_id` as a common field. The `CLAUDE_SESSION_ID` env var does not exist before we create it -- that is the whole point of this change. The hook must read from stdin.

The stdin JSON for SessionStart looks like:
```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../.claude/projects/.../transcript.jsonl",
  "cwd": "/Users/...",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-5-20250929"
}
```

The extraction command: `jq -r ".session_id"` on stdin.

### 5. Inline Command vs. Script File

**Recommendation: Use an inline command.** Reasons:

- The nefario skill is deployed via symlink (`~/.claude/skills/nefario -> <repo>/skills/nefario/`). A script file would need to be referenced relative to the skill directory, but skill hooks do not have access to `CLAUDE_PLUGIN_ROOT` (that is a plugin-only variable) and `CLAUDE_PROJECT_DIR` points to the current project, not the skill's source repo.
- The command is a one-liner -- it extracts one JSON field and writes one export line. This does not warrant a separate file.
- Inline commands avoid path resolution issues when the skill is symlinked across different projects.

**Proposed inline command (refined)**:

```sh
INPUT=$(cat); SID=$(echo "$INPUT" | jq -r '.session_id // empty'); [ -n "$SID" ] && [ -n "$CLAUDE_ENV_FILE" ] && echo "export CLAUDE_SESSION_ID=$SID" >> "$CLAUDE_ENV_FILE"
```

This is defensive:
- Reads all stdin into a variable (prevents broken pipe)
- Uses `// empty` to avoid the string "null" if session_id is missing
- Guards on both `$SID` and `$CLAUDE_ENV_FILE` being non-empty
- Uses append (`>>`) to not clobber other hooks' env vars

### 6. SKILL.md Status File Pattern Change

Currently, every phase transition in SKILL.md uses this two-line pattern:
```sh
SID=$(cat /tmp/claude-session-id 2>/dev/null)
echo "..." > /tmp/nefario-status-$SID
```

This should change to:
```sh
echo "..." > /tmp/nefario-status-$CLAUDE_SESSION_ID
```

The `$CLAUDE_SESSION_ID` env var is available in all Bash tool calls after the SessionStart hook writes it. No `cat` needed.

Cleanup lines change similarly:
```sh
# Before:
SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID
# After:
rm -f /tmp/nefario-status-$CLAUDE_SESSION_ID
```

### 7. Status Line Command -- Remove the `/tmp/claude-session-id` Write

The status line command in `despicable-statusline/SKILL.md` currently includes:
```sh
[ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id;
```

This entire fragment must be removed. The status line command still extracts `$sid` from the stdin JSON (`.session_id`) for its own use in reading `/tmp/nefario-status-$sid`, but it no longer writes the shared file.

### 8. The `commit-point-check.sh` Already Has the Right Fallback

The existing `commit-point-check.sh` at line 38-46 already falls back to `CLAUDE_SESSION_ID`:
```bash
get_session_id() {
    local input="$1"
    local sid
    sid=$(json_field "$input" "session_id")
    if [[ -z "$sid" ]]; then
        sid="${CLAUDE_SESSION_ID:-default}"
    fi
    echo "$sid"
}
```

This is already correct -- it prefers the stdin JSON (which Stop hooks receive) and falls back to the env var. No changes needed here, but it confirms the env var name convention is already established.

## Proposed Tasks

### Task 1: Add SessionStart hook to nefario skill frontmatter
**What**: Add a `hooks:` section to the YAML frontmatter of `skills/nefario/SKILL.md` with a SessionStart hook that writes `CLAUDE_SESSION_ID` to `CLAUDE_ENV_FILE`.
**Deliverables**: Updated `skills/nefario/SKILL.md` frontmatter (lines 1-9 become approximately lines 1-16).
**Dependencies**: None -- this is the foundational change.

### Task 2: Replace all `SID=$(cat /tmp/claude-session-id ...)` with `$CLAUDE_SESSION_ID` in SKILL.md
**What**: Find-and-replace all 9 occurrences in `skills/nefario/SKILL.md` where `SID=$(cat /tmp/claude-session-id 2>/dev/null)` is used, replacing the two-line pattern with a single-line pattern using `$CLAUDE_SESSION_ID` directly.
**Deliverables**: Updated `skills/nefario/SKILL.md` body content.
**Dependencies**: Task 1 (the env var must be defined before it is referenced).

Specific locations (by current line numbers):
- Line 366-369: Phase 1 status write
- Line 569: Phase 1 rejection cleanup
- Line 580-581: Phase 2 status write
- Line 654-655: Phase 3 status write
- Line 730-731: Phase 3.5 status write
- Line 1184-1185: Phase 4 status write
- Line 1312-1313: Phase 4 gate status write
- Line 1329-1330: Phase 4 resume status write
- Line 1758: Post-execution cleanup

### Task 3: Update despicable-statusline skill
**What**: Remove the `echo "$sid" > /tmp/claude-session-id` fragment from all status line command templates in `.claude/skills/despicable-statusline/SKILL.md`. The `$sid` variable is still extracted from stdin JSON for reading the nefario status file -- only the write to the shared file is removed.
**Deliverables**: Updated `.claude/skills/despicable-statusline/SKILL.md` (States A, B, D manual instructions).
**Dependencies**: None (can run in parallel with Task 2).

### Task 4: Update `docs/using-nefario.md`
**What**: Update the "How It Works" section (lines 196-208) that explains the `/tmp/claude-session-id` mechanism. Replace with an explanation of the SessionStart hook and `CLAUDE_SESSION_ID` env var. Update the manual configuration JSON example to remove the `echo "$sid" > /tmp/claude-session-id` fragment.
**Deliverables**: Updated `docs/using-nefario.md`.
**Dependencies**: None (can run in parallel with Tasks 2-3).

### Task 5: Verify no other files reference `/tmp/claude-session-id`
**What**: Run a repo-wide grep for `/tmp/claude-session-id` and confirm all references have been removed. The `commit-point-check.sh` references `/tmp/nefario-status-${session_id}` (which is fine -- that file still exists) and already has `CLAUDE_SESSION_ID` fallback (also fine).
**Deliverables**: Verification that no file reads or writes `/tmp/claude-session-id`.
**Dependencies**: Tasks 2, 3, 4.

## Risks and Concerns

### Risk 1: `CLAUDE_ENV_FILE` may not persist across compaction/clear (MEDIUM)
The documentation is not explicit about whether environment variables set via `CLAUDE_ENV_FILE` survive `clear` and `compact` events. If they do not, the `$CLAUDE_SESSION_ID` env var would be empty after the first compaction, causing all status file writes to fail silently (writing to `/tmp/nefario-status-` with no ID suffix).

**Mitigation**: Do not use `once: true`. Let the SessionStart hook fire on every session start event (startup, resume, clear, compact). This re-exports the env var after every compaction. The cost is negligible.

### Risk 2: SessionStart hook may not fire for skill-scoped hooks in all contexts (LOW-MEDIUM)
GitHub issue [#17688](https://github.com/anthropics/claude-code/issues/17688) reports that skill-scoped hooks defined in SKILL.md frontmatter are not triggered within plugins. While nefario is a skill (not a plugin), this indicates the feature has known edge cases.

**Mitigation**: Test immediately after implementation. If skill-scoped SessionStart hooks do not fire reliably, the fallback is to define the hook in `.claude/settings.json` instead (which violates the constraint "no new entries in settings.json" but would be a documented exception).

### Risk 3: Multiple hooks appending to `CLAUDE_ENV_FILE` concurrently (LOW)
If multiple SessionStart hooks run in parallel (the docs say "all matching hooks run in parallel"), concurrent appends to `CLAUDE_ENV_FILE` could interleave. However, since each `echo "export ..." >>` is a single small write well under the POSIX atomic write size (typically 512 bytes or more), this is practically safe.

**Mitigation**: None needed -- the write is atomic at the OS level for small payloads.

### Risk 4: The `once: true` documentation says "Skills only, not agents" (LOW)
If `once: true` is used and nefario is ever converted from a skill to an agent, the `once` flag would stop working. This is a future-proofing concern only.

**Mitigation**: Recommend not using `once: true` (per Risk 1 reasoning).

### Risk 5: Existing users' status line commands still write to `/tmp/claude-session-id` (MEDIUM)
Users who already ran `/despicable-statusline` have the old command baked into their `~/.claude/settings.json`. Updating the skill template does not retroactively update their settings. The old `echo "$sid" > /tmp/claude-session-id` line is harmless (it writes a file nothing reads anymore), but it is dead code that creates a stale file.

**Mitigation**: Document in the changelog that users should re-run `/despicable-statusline` to get the updated status line command. Alternatively, add idempotent detection: if the old `echo "$sid" > /tmp/claude-session-id` pattern is detected, offer to update it. This could be a follow-up task.

## Additional Agents Needed

None. The current team is sufficient. This is primarily a developer tooling and configuration change that falls squarely within devx-minion scope. The changes touch:
- Skill frontmatter YAML (devx domain: CLI/tool configuration)
- Shell command patterns (devx domain: developer tooling)
- Documentation (devx domain: developer portal content)

No security, API design, or infrastructure concerns are introduced by this change.
