# Phase 3: Synthesis -- despicable-statusline Skill

## Delegation Plan

**Team name**: despicable-statusline
**Description**: Create a `/despicable-statusline` skill that configures the user's Claude Code status line to include nefario orchestration phase status.

### Task 1: Create the SKILL.md for despicable-statusline

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |

    Create the file `~/github/benpeter/claude-skills/despicable-statusline/SKILL.md`.

    This is a Claude Code skill that, when invoked via `/despicable-statusline`,
    instructs Claude Code to modify `~/.claude/settings.json` to append nefario
    orchestration status to the user's status line.

    **Important context**: A skill's SKILL.md is a system prompt that Claude Code
    follows when the user invokes `/despicable-statusline`. The skill does NOT run
    shell scripts directly -- it instructs Claude Code to use its own tools (Read,
    Write, Edit, Bash) to accomplish the task. Study the reference skills for the
    exact pattern.

    **Reference skills** (read these before writing):
    - `~/github/benpeter/claude-skills/session-review/SKILL.md` -- shows the
      vault-detection-then-act pattern
    - `~/github/benpeter/claude-skills/obsidian-tasks/SKILL.md` -- shows YAML
      frontmatter format and workflow structure
    - `/Users/ben/github/benpeter/2despicable/3/skills/despicable-prompter/SKILL.md`
      -- shows the "act immediately on invocation" pattern

    **YAML frontmatter**:
    ```yaml
    ---
    name: despicable-statusline
    description: >
      Configure the Claude Code status line to show nefario orchestration phase.
      Reads existing statusLine config, preserves it, and appends the nefario
      status snippet. Idempotent -- safe to run multiple times.
    ---
    ```

    **The nefario status snippet** (the shell fragment that reads orchestration
    status from a temp file and appends it to the status line output):
    ```sh
    f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"
    ```
    This snippet expects two variables to already exist in the command:
    - `$sid` -- session ID, extracted from the JSON input's `.session_id`
    - `$result` -- the accumulated status line string that gets echoed at the end

    **The default statusLine command** (for users who have no statusLine config at
    all). This provides dir, model, context%, session-id infrastructure, and
    nefario status:
    ```sh
    input=$(cat); dir=$(echo "$input" | jq -r '.workspace.current_dir // "?"'); model=$(echo "$input" | jq -r '.model.display_name // "?"'); used=$(echo "$input" | jq -r '.context_window.used_percentage // ""'); sid=$(echo "$input" | jq -r '.session_id // ""'); [ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id; result="$dir | $model"; if [ -n "$used" ]; then result="$result | Context: $(printf '%.0f' "$used")%"; fi; f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; echo "$result"
    ```

    **Workflow the SKILL.md must instruct Claude Code to follow**:

    1. **Read settings.json**: Use the Read tool to read `~/.claude/settings.json`.
       If the file does not exist, create it with `{}` as content first.

    2. **Idempotency check**: Check if the string `nefario-status-` appears anywhere
       in `.statusLine.command`. If it does, output the no-op message and stop:
       ```
       Status line already includes nefario status. No changes made.
       ```

    3. **Branch on existing config state**:

       **State A -- No statusLine configured** (`.statusLine` is absent or null):
       Use the Edit or Write tool to set `.statusLine` to the default command
       shown above. Use `jq` via Bash to perform the JSON update safely:
       ```sh
       jq --arg cmd '<default command>' '.statusLine = {"type": "command", "command": $cmd}' ~/.claude/settings.json
       ```
       Write via atomic pattern: write to a temp file, then `mv` over the original.

       **State B -- Inline statusLine without nefario snippet**: The existing
       `.statusLine.command` is a shell string that does NOT contain
       `nefario-status-`. The skill must append the nefario snippet before the
       final `echo "$result"` in the command.

       Strategy: Use bash parameter expansion to insert before the last
       `echo "$result"`:
       ```sh
       current=<existing command>
       snippet='f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"; '
       new_command="${current%echo \"\$result\"*}${snippet}echo \"\$result\""
       ```
       If the command does NOT end with `echo "$result"` (non-standard format),
       fall back to State D.

       **State C -- Already has nefario snippet**: Handled by step 2 (no-op).

       **State D -- Non-standard or script-file statusLine**: If the command value
       looks like a script file path (no semicolons, references a .sh file) or
       does not contain `echo "$result"`, do NOT modify it. Instead output manual
       instructions:
       ```
       Your status line uses a custom format that cannot be auto-modified.

       To add nefario status manually, add this before your final output:

         f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"

       This requires $sid (session ID from .session_id) and $result (your output
       string) to be defined earlier in your command.
       ```

    4. **Safety measures**: Before modifying settings.json:
       - Validate the file is valid JSON (use `jq empty` via Bash)
       - Create a backup: copy to `~/.claude/settings.json.backup-statusline`
       - After writing, validate the result is valid JSON
       - If post-write validation fails, restore from backup and report the error

    5. **Success message** (for State A and State B):
       ```
       Status line updated.
         Added: nefario orchestration status
         Config: ~/.claude/settings.json

       The nefario status appears during /nefario orchestration sessions.
       Outside orchestration, it is hidden.
       ```

    **What NOT to do**:
    - Do NOT ask for confirmation before modifying. Invocation is consent.
    - Do NOT show the user the shell command that was written. They need to know
      the job is done, not the implementation.
    - Do NOT modify any settings.json keys other than `statusLine`.
    - Do NOT reorder, rename, or remove existing statusLine elements.
    - Do NOT add elements beyond the nefario snippet (no git branch, no cost
      tracking, no session ID display). The default has dir/model/context% because
      those are baseline useful; the append case adds ONLY the nefario snippet.
    - Do NOT use Claude Code's Edit tool for JSON manipulation of the command
      string -- the shell command contains special characters that make string
      matching unreliable. Use `jq` via Bash for all JSON read/write operations.

    **File to create**: `~/github/benpeter/claude-skills/despicable-statusline/SKILL.md`

    **Style**: Follow the pattern of existing skills in `~/github/benpeter/claude-skills/`.
    YAML frontmatter with name and description, then a markdown document that serves
    as a system prompt for Claude Code. Use numbered workflow steps. Keep it concise
    -- the skill is simple.

- **Deliverables**: `~/github/benpeter/claude-skills/despicable-statusline/SKILL.md`
- **Success criteria**:
  - File exists and has valid YAML frontmatter
  - Workflow covers all four states (A, B, C, D)
  - Contains the exact nefario snippet and default statusLine command
  - Includes idempotency check, backup/validation, and appropriate output messages
  - Follows the established skill pattern (no interactive prompts, acts immediately)

### Task 2: Create the symlink

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |

    Create a symlink so the `/despicable-statusline` skill is available in Claude Code.

    Run:
    ```bash
    ln -sf ~/github/benpeter/claude-skills/despicable-statusline ~/.claude/skills/despicable-statusline
    ```

    Then verify:
    ```bash
    ls -la ~/.claude/skills/despicable-statusline
    ```

    Confirm the symlink points to `~/github/benpeter/claude-skills/despicable-statusline`
    and that `SKILL.md` is readable at the target.

    **What NOT to do**:
    - Do NOT modify the SKILL.md
    - Do NOT modify any other symlinks or skills

- **Deliverables**: Working symlink at `~/.claude/skills/despicable-statusline`
- **Success criteria**:
  - Symlink exists and points to the correct directory
  - `~/.claude/skills/despicable-statusline/SKILL.md` is readable

### Cross-Cutting Coverage

- **Testing**: Excluded. This is a single prompt file (SKILL.md) with no executable code.
  The skill itself is a set of instructions for Claude Code to follow. Idempotency can
  be verified manually by invoking `/despicable-statusline` twice, which the user will
  naturally do. There is no test harness for Claude Code skill prompts.
- **Security**: Excluded. The skill modifies a local config file (`~/.claude/settings.json`)
  that is user-owned. No network operations, no auth, no user input processing beyond
  the invocation itself. The backup/validation/rollback pattern in the prompt is sufficient
  safety for a local config modification.
- **Usability -- Strategy**: Covered. UX strategy recommendations are fully incorporated:
  no confirmation gate (invocation = consent), two distinct outcome messages (success and
  no-op), post-action confusion prevention (explaining nefario status is only visible
  during orchestration), manual fallback for non-standard configs.
- **Usability -- Design**: Excluded. No UI components. The output is 3-4 lines of terminal
  text. No visual hierarchy, interaction patterns, or components to design.
- **Documentation**: Excluded. The SKILL.md itself is the documentation. The skill's
  description field in the YAML frontmatter describes what it does. No API surface, no
  architectural changes, no user guide needed beyond the invocation itself.
- **Observability**: Excluded. No runtime component, no service, no background process.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no UI, no web-facing output)

### Conflict Resolutions

No conflicts between specialists. Both devx-minion and ux-strategy-minion aligned on:
- Idempotency via `nefario-status-` substring check
- No confirmation prompt (invocation = consent)
- Atomic write with backup and validation
- Manual fallback for non-standard configs
- Same default statusLine elements (dir, model, context%, nefario)

Minor difference resolved: ux-strategy-minion proposed the success message include
"The nefario status appears during /nefario orchestration sessions." while devx-minion's
message included "To revert, remove the nefario snippet..." -- both are incorporated.
The revert instruction is dropped as it adds clutter to a reversible action (the user
can always edit settings.json); the visibility explanation is kept because it prevents
the most common post-action confusion.

### Risks and Mitigations

1. **JSON corruption of settings.json** (HIGH severity, LOW probability):
   Mitigated by atomic write (mktemp + mv), pre/post-write JSON validation,
   and backup to `settings.json.backup-statusline`. Rollback on validation failure.

2. **Non-standard statusLine formats** (MEDIUM severity, MEDIUM probability):
   Mitigated by detecting commands without `echo "$result"` and script-file configs,
   falling back to manual instructions rather than attempting modification.

3. **Session ID dependency in append case** (MEDIUM severity, LOW probability):
   The nefario snippet requires `$sid` to be defined. If a user's existing command
   doesn't extract session_id, the snippet fails safely (all guards short-circuit).
   Acceptable behavior -- it fails silently rather than breaking the status line.

4. **Post-invocation confusion** (LOW severity, HIGH probability):
   The nefario status element is invisible when no orchestration is running.
   Mitigated by explicit message: "The nefario status appears during /nefario
   orchestration sessions. Outside orchestration, it is hidden."

5. **jq availability** (LOW severity, LOW probability):
   The statusLine command itself uses jq, so a user without jq already has a
   non-functional status line. The skill checks for jq and provides a clear error.

### Execution Order

```
Task 1: Create SKILL.md
  |
  v
Task 2: Create symlink (blocked by Task 1)
```

Both tasks are simple and sequential. No parallelism needed. No approval gates
(single-file deliverable, easily reversible, low blast radius).

### Verification Steps

1. Symlink exists: `ls -la ~/.claude/skills/despicable-statusline`
2. SKILL.md is readable: `cat ~/.claude/skills/despicable-statusline/SKILL.md | head -5`
3. Idempotency: Invoke `/despicable-statusline` on current machine (which already
   has the nefario snippet) and confirm no-op output
4. (Optional, on a test setup): Remove `statusLine` from settings.json, invoke the
   skill, confirm default is created correctly
