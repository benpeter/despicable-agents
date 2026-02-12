## Domain Plan Contribution: devx-minion

### Recommendations

#### (a) Reading and Parsing the Existing statusLine Command String

**Do not parse the shell command string.** The existing `statusLine.command` value is a
dense one-liner with semicolons, pipes, variable expansions, and conditionals. Attempting
to parse it as a string (splitting on `;`, finding the "last segment", etc.) is fragile
and will break when the user modifies their status line in any unexpected way.

Instead, treat the command string as an opaque blob. The skill should:

1. Read `~/.claude/settings.json` as JSON using `jq` (available at `/usr/bin/jq`, version 1.6+).
2. Extract `.statusLine.command` as a raw string.
3. Perform idempotency check (see below).
4. If the nefario snippet is absent, append it using string concatenation at the JSON level.

The current value is:

```
input=$(cat); dir=$(echo "$input" | jq -r '...'); ...; echo "$result"
```

The key structural insight: the entire command ends with `echo "$result"`. The nefario
snippet already present in the user's config follows this pattern -- it appends to `$result`
before the final `echo`. This means appending the nefario snippet requires inserting it
*before* the final `echo "$result"`.

However, since the user's config **already has the nefario snippet**, the skill will be
a no-op on the current machine. The skill needs to handle the general case for other users
or after a settings reset.

**Recommended approach**: Rather than surgically inserting into the middle of a shell
one-liner, define the nefario status as a **suffix pattern** that appends to `$result`
before the final echo. The canonical snippet is:

```sh
f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"
```

This snippet expects `$sid` and `$result` to be defined earlier in the command.

#### (b) Idempotency Detection

Use a simple string containment check on the raw command value:

```sh
jq -r '.statusLine.command // ""' ~/.claude/settings.json | grep -qF 'nefario-status-'
```

If `nefario-status-` appears anywhere in the command string, the snippet is already
present. This is the most reliable marker because:

- It is unique to the nefario status mechanism
- It survives reformatting, reordering of other parts
- It does not depend on exact whitespace or quoting

Do NOT check for the entire snippet verbatim -- any minor formatting change would
cause a false negative.

#### (c) Appending Without Breaking Existing Shell Logic

The safest append strategy recognizes that the current command ends with `echo "$result"`.
The nefario snippet must be inserted **before** this final echo.

**Strategy: Sed-based insertion before the final echo**:

```sh
# Extract current command
current=$(jq -r '.statusLine.command // ""' ~/.claude/settings.json)

# The nefario suffix (inserted before the final echo)
nefario_snippet='f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; '

# Insert before the last 'echo "$result"'
# Use parameter expansion: replace the LAST occurrence of 'echo "$result"'
new_command="${current%echo \"\$result\"*}${nefario_snippet}echo \"\$result\""
```

This uses bash parameter expansion (`${var%pattern*}`) to strip everything from the last
`echo "$result"` onward, then appends the snippet + the echo. This is safer than sed
because it does not require escaping regex metacharacters in the shell command.

**Fallback for commands without `echo "$result"`**: If the command does not end with
`echo "$result"` (a custom/unknown format), do NOT modify it. Instead, warn the user:

```
Your statusLine command uses a non-standard format.
To add nefario status, manually append this before your final output:

  f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"

This requires $sid (session ID) and $result to be defined earlier.
```

#### (d) Default statusLine for Users With No Config

If `statusLine` is absent or null in settings.json, create a sensible default that
covers the most useful information: working directory, model, context usage, and
nefario status. The default should closely mirror the current user's config (since it
is already well-designed):

```sh
input=$(cat); dir=$(echo "$input" | jq -r '.workspace.current_dir // "?"'); model=$(echo "$input" | jq -r '.model.display_name // "?"'); used=$(echo "$input" | jq -r '.context_window.used_percentage // ""'); sid=$(echo "$input" | jq -r '.session_id // ""'); [ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id; result="$dir | $model"; if [ -n "$used" ]; then result="$result | Context: $(printf '%.0f' "$used")%"; fi; f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; echo "$result"
```

This default:
- Shows working directory, model name, context window usage
- Writes session ID to `/tmp/claude-session-id` (required by nefario)
- Appends nefario status when present
- Uses `jq` (requires jq on PATH, which is standard on macOS via Homebrew or system)

#### JSON Manipulation: Use jq, Not Manual String Building

`jq` is the right tool. It is already installed (`/usr/bin/jq`), the user's existing
statusLine command already depends on it (the command itself calls `jq -r`), and it
handles JSON escaping correctly -- which is critical because the shell command contains
double quotes, dollar signs, and backslashes that would break naive string interpolation.

The update pattern:

```sh
# Read, modify, write back atomically
tmp=$(mktemp)
jq --arg cmd "$new_command" '.statusLine = {"type": "command", "command": $cmd}' \
  ~/.claude/settings.json > "$tmp" && mv "$tmp" ~/.claude/settings.json
```

The `--arg` flag handles all JSON escaping automatically. The `mktemp` + `mv` pattern
ensures atomic writes (no partial writes on crash).

#### Error Handling: Backup and Validation

1. **Backup before modification**: Copy `~/.claude/settings.json` to
   `~/.claude/settings.json.backup-statusline` before any write. Only one backup
   (not timestamped) -- keeps it simple, easy to restore manually.

2. **Pre-flight validation**:
   - Verify `~/.claude/settings.json` exists and is valid JSON (`jq empty`)
   - Verify jq is available (`command -v jq`)
   - Verify the file is writable

3. **Post-write validation**:
   - Verify the written file is valid JSON (`jq empty`)
   - Verify `.statusLine.command` is present and non-empty
   - Verify the nefario snippet is present (containment check)

4. **Rollback on failure**: If post-write validation fails, restore from backup and
   report the error. The user's config is never left in a broken state.

5. **No rollback for the "no statusLine" case**: When creating a default from scratch,
   the backup will be the original file without `statusLine`. Restoring on failure is
   safe -- the user simply has no status line, same as before.

### Proposed Tasks

#### Task 1: Create the SKILL.md for despicable-statusline

**What to do**: Write `~/github/benpeter/claude-skills/despicable-statusline/SKILL.md`
following the established skill pattern (YAML frontmatter with name, description,
argument-hint; markdown body with workflow steps).

**Deliverables**:
- `SKILL.md` with:
  - YAML frontmatter (name: `despicable-statusline`, description, no argument-hint needed)
  - Workflow: preflight checks, read settings, idempotency check, backup, modify/create, validate, report
  - The canonical nefario snippet defined as a constant
  - The default statusLine template for new users
  - Error messages that tell the user what to do, not just what failed
  - Clear "manual fallback" instructions for non-standard statusLine formats

**Dependencies**: None

#### Task 2: Create the symlink

**What to do**: Symlink `~/github/benpeter/claude-skills/despicable-statusline` to
`~/.claude/skills/despicable-statusline`.

**Deliverables**:
- Working symlink
- Skill appears in Claude Code's skill list

**Dependencies**: Task 1

#### Task 3: Verify idempotency on the current machine

**What to do**: Run `/despicable-statusline` on the current machine where the nefario
snippet is already present. Confirm it detects the existing snippet and reports "no-op"
without modifying the file.

**Deliverables**:
- Confirmation that the skill is a no-op when the snippet exists
- No changes to `~/.claude/settings.json`

**Dependencies**: Task 2

### Risks and Concerns

1. **JSON corruption risk**: `~/.claude/settings.json` is the single most critical
   user config file. A malformed write breaks all of Claude Code. Mitigation: atomic
   write via `mktemp` + `mv`, backup before modification, post-write validation.

2. **Shell escaping in jq --arg**: The statusLine command contains `$`, `"`, and
   semicolons. The `jq --arg` approach handles this correctly because it treats the
   value as a raw string and JSON-encodes it. However, if the skill constructs the
   command via bash string interpolation before passing to jq, escaping errors are
   likely. Mitigation: build the command string in a bash variable using single-quoted
   segments, then pass to `jq --arg`.

3. **The `echo "$result"` anchor may not be universal**: Other users may have
   customized their statusLine to use a different output pattern (e.g., `printf`,
   different variable name). The skill must handle this gracefully -- warn and provide
   manual instructions rather than silently corrupting the command.

4. **Session ID dependency**: The nefario snippet requires `$sid` to be defined earlier
   in the command (extracted from the JSON input's `.session_id`). If a user has a
   minimal custom statusLine that does not extract session_id, the snippet will silently
   fail (all the `[ -n "$sid" ]` guards will short-circuit). This is acceptable
   behavior -- it fails safe.

5. **jq availability**: While jq is present on this machine, other users may not have
   it. The statusLine command itself uses jq, so a user without jq already has a broken
   statusLine. But the skill should still check and provide a useful error message.

6. **Claude Code settings.json schema changes**: If Claude Code changes the statusLine
   schema in a future version (e.g., adding a different type, structured config instead
   of a command string), the skill will need updating. This is low risk in the near term
   but should be documented.

7. **Race condition with Claude Code**: If Claude Code is actively writing to
   settings.json while the skill runs, the atomic write could overwrite Claude Code's
   changes. This is extremely unlikely (settings changes are rare and user-initiated)
   but worth noting. The backup mitigates data loss.

### Additional Agents Needed

None. This is a straightforward skill creation task within the devx domain. The shell
scripting and JSON manipulation are standard. No security-sensitive operations beyond
file backup/restore. No user-facing UI. No API design.
