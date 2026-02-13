# Phase 3: Synthesis -- Replace Session ID File with SessionStart Hook

## Delegation Plan

**Team name**: session-id-hook
**Description**: Replace the `/tmp/claude-session-id` shared file mechanism with a SessionStart hook that writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`, eliminating the last-writer-wins race condition in concurrent sessions.

### Task 1: Add SessionStart hook to nefario skill frontmatter and replace all SID references in SKILL.md body

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: The hook mechanism is the foundational change. If it does not work correctly (env var not available, wrong format, wrong event timing), every downstream reference breaks. Hard to reverse (all other changes assume this works) and high blast radius (all status writes depend on it).
- **Prompt**: |
    You are modifying the nefario orchestration skill to replace the `/tmp/claude-session-id` shared file mechanism with a `SessionStart` hook that writes `CLAUDE_SESSION_ID` into `CLAUDE_ENV_FILE`.

    ## Context

    Currently, nefario's status line integration works by having the status line command write the session ID to `/tmp/claude-session-id`, which the SKILL.md then reads back via `cat /tmp/claude-session-id 2>/dev/null`. This creates a last-writer-wins race condition when multiple Claude Code sessions run concurrently.

    The fix: add a `hooks:` section to the skill's YAML frontmatter that fires on every SessionStart event, extracts `session_id` from the stdin JSON payload, and writes `export CLAUDE_SESSION_ID=<value>` to `$CLAUDE_ENV_FILE`. This makes the session ID available as an env var in all subsequent Bash tool calls.

    ## Part A: Add the SessionStart hook to frontmatter

    Edit `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`.

    The current frontmatter (lines 1-9) is:
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
    ---
    ```

    Replace with:
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
              command: 'INPUT=$(cat); SID=$(echo "$INPUT" | jq -r ''.session_id // empty''); [ -n "$SID" ] && [ -n "$CLAUDE_ENV_FILE" ] && echo "CLAUDE_SESSION_ID=$SID" >> "$CLAUDE_ENV_FILE"'
    ---
    ```

    IMPORTANT format details for the hook command:
    - Do NOT use `once: true` -- the hook must fire on every SessionStart event (startup, resume, clear, compact) to survive compaction
    - Do NOT add a `matcher:` field -- omitting it matches all SessionStart events
    - The command reads all stdin into a variable first (prevents broken pipe), uses `// empty` to avoid the string "null", guards on both SID and CLAUDE_ENV_FILE being non-empty, and appends with `>>` to not clobber other hooks' env vars
    - Use `echo "CLAUDE_SESSION_ID=$SID"` (no `export` prefix) -- CLAUDE_ENV_FILE uses bare `KEY=VALUE` format, not shell export syntax

    ## Part B: Replace all 9 SID references in SKILL.md body

    In the same file, find and replace all occurrences of the two-line pattern:
    ```sh
    SID=$(cat /tmp/claude-session-id 2>/dev/null)
    echo "..." > /tmp/nefario-status-$SID
    ```
    With the single-line pattern:
    ```sh
    echo "..." > /tmp/nefario-status-$CLAUDE_SESSION_ID
    ```

    And for the `chmod` line that immediately follows the first occurrence (line 369):
    ```sh
    chmod 600 /tmp/nefario-status-$SID
    ```
    Change to:
    ```sh
    chmod 600 /tmp/nefario-status-$CLAUDE_SESSION_ID
    ```

    And for cleanup patterns:
    ```sh
    SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID
    ```
    Change to:
    ```sh
    rm -f /tmp/nefario-status-$CLAUDE_SESSION_ID
    ```

    The specific locations (by approximate current line numbers):
    1. Lines 366-369: Phase 1 status write + chmod (two-line pattern -> one-line, plus chmod fix)
    2. Line 569: Phase 1 rejection cleanup (inline pattern)
    3. Lines 580-581: Phase 2 status write (two-line pattern -> one-line)
    4. Lines 654-655: Phase 3 status write (two-line pattern -> one-line)
    5. Lines 730-731: Phase 3.5 status write (two-line pattern -> one-line)
    6. Lines 1184-1185: Phase 4 status write (two-line pattern -> one-line)
    7. Lines 1312-1313: Phase 4 gate status write (two-line pattern -> one-line)
    8. Lines 1329-1330: Phase 4 resume status write (two-line pattern -> one-line)
    9. Line 1758: Post-execution cleanup (inline pattern)

    ## Deliverables
    - Updated `skills/nefario/SKILL.md` with:
      - SessionStart hook in frontmatter
      - All 9 SID references replaced with `$CLAUDE_SESSION_ID`
      - No references to `/tmp/claude-session-id` remaining

    ## What NOT to do
    - Do NOT modify any other files (despicable-statusline, docs, etc.)
    - Do NOT change the status file path pattern (`/tmp/nefario-status-*`) -- only the SID sourcing changes
    - Do NOT add `once: true` to the hook
    - Do NOT use `export` prefix in the CLAUDE_ENV_FILE write
    - Do NOT touch `commit-point-check.sh` -- it already has the right fallback
    - Do NOT modify files under `docs/history/` -- those are immutable execution reports
- **Deliverables**: Updated `skills/nefario/SKILL.md` with SessionStart hook in frontmatter and all SID references replaced
- **Success criteria**: `grep -c '/tmp/claude-session-id' skills/nefario/SKILL.md` returns 0; frontmatter contains `hooks:` section with SessionStart handler; all 9 status write locations use `$CLAUDE_SESSION_ID`

### Task 2: Update despicable-statusline skill

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (parallel with Task 1)
- **Approval gate**: no
- **Prompt**: |
    You are updating the despicable-statusline skill to remove the `/tmp/claude-session-id` write that is no longer needed.

    ## Context

    The nefario skill now uses a SessionStart hook to set `CLAUDE_SESSION_ID` as an env var instead of reading from `/tmp/claude-session-id`. The status line command no longer needs to write the session ID to that file. However, the status line command still needs to extract `$sid` from the stdin JSON for its own use (reading `/tmp/nefario-status-$sid`).

    ## File to edit

    `/Users/ben/github/benpeter/despicable-agents/.claude/skills/despicable-statusline/SKILL.md`

    ## Changes

    In **three** locations (States A, B, and D manual instructions), remove the fragment:
    ```sh
    [ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id;
    ```

    The specific locations:

    1. **State A** (line 45): The full default command. Remove `[ -n "$sid" ] && echo "$sid" > /tmp/claude-session-id;` from the command string. The `sid` variable extraction (`sid=$(echo "$input" | jq -r '.session_id // ""')`) MUST remain because it is used later in the nefario status file read (`f="/tmp/nefario-status-$sid"`).

    2. **State B** (line 56-57): The nefario snippet block. This snippet does NOT contain the session-id write -- it only has the nefario status read. Verify it does not need changes. If it does contain the write, remove it.

    3. **State D** (lines 73-78): The manual instructions block. This snippet also only has the nefario status read. Verify it does not need changes. If it does contain the write, remove it.

    So effectively only State A's full command (line 45) needs the removal. States B and D contain only the nefario status reading snippet which does not write to `/tmp/claude-session-id`.

    ## Deliverables
    - Updated `.claude/skills/despicable-statusline/SKILL.md` with the write fragment removed
    - The `$sid` extraction and nefario status file reading logic remains intact

    ## What NOT to do
    - Do NOT remove the `sid=$(echo "$input" | jq -r '.session_id // ""')` extraction -- it is still needed
    - Do NOT remove the nefario status file reading logic (`f="/tmp/nefario-status-$sid"` etc.)
    - Do NOT modify any other files
    - Do NOT change the overall structure of the skill
- **Deliverables**: Updated `.claude/skills/despicable-statusline/SKILL.md` with `/tmp/claude-session-id` write removed
- **Success criteria**: `grep -c 'claude-session-id' .claude/skills/despicable-statusline/SKILL.md` returns 0; the `$sid` variable is still extracted and used for nefario status reading

### Task 3: Update docs/using-nefario.md

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (parallel with Tasks 1-2)
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario user documentation to reflect the new session ID mechanism.

    ## File to edit

    `/Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md`

    ## Changes

    ### 1. Update the "How It Works" section (around line 195-197)

    Current text (line 197):
    ```
    The status line command extracts `session_id` from the JSON that Claude Code pipes to it, and writes it to `/tmp/claude-session-id` so the nefario skill can discover it. When nefario starts orchestrating, it reads the session ID from that file and writes the current phase and task summary to `/tmp/nefario-status-<session-id>`. The file is updated at each phase transition so the status line always reflects the current phase. The status line command checks for this file and appends its contents. When orchestration finishes, nefario removes the file.
    ```

    Replace with:
    ```
    The nefario skill registers a `SessionStart` hook that captures the session ID and makes it available as the `CLAUDE_SESSION_ID` environment variable. When nefario starts orchestrating, it writes the current phase and task summary to `/tmp/nefario-status-<session-id>`. The file is updated at each phase transition. The status line command extracts `session_id` from the JSON that Claude Code pipes to it, checks for the nefario status file, and appends its contents. When orchestration finishes, nefario removes the file. Each session has its own status file, so concurrent sessions do not interfere.
    ```

    ### 2. Update the manual configuration JSON example (around lines 204-211)

    In the JSON command string, remove the fragment `[ -n \\\"$sid\\\" ] && echo \\\"$sid\\\" > /tmp/claude-session-id; ` (the escaped version within the JSON string). The rest of the command stays the same.

    The current command value contains (among other things):
    ```
    [ -n \"$sid\" ] && echo \"$sid\" > /tmp/claude-session-id;
    ```
    Remove that fragment. Keep the `sid` extraction and the nefario status file reading.

    ### 3. Update the manual configuration note text (around line 202)

    The text currently says "If you already have a `statusLine` entry, merge the nefario-specific part (the `f="/tmp/nefario-status-..."` line) into your existing command."

    This is still accurate and does not need changes.

    ## Deliverables
    - Updated `docs/using-nefario.md` with new mechanism explanation and updated manual config example

    ## What NOT to do
    - Do NOT modify any other documentation files
    - Do NOT change the "What It Shows" section -- it is still accurate
    - Do NOT modify files under `docs/history/` -- those are immutable execution reports
    - Do NOT remove the manual configuration section -- just update it
- **Deliverables**: Updated `docs/using-nefario.md` with corrected "How It Works" text and manual config example
- **Success criteria**: `grep -c 'claude-session-id' docs/using-nefario.md` returns 0; the "How It Works" section explains the SessionStart hook mechanism; manual config example no longer writes to the shared file

### Task 4: Verify no remaining references to `/tmp/claude-session-id`

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1, Task 2, Task 3
- **Approval gate**: no
- **Prompt**: |
    Run a repository-wide search for `/tmp/claude-session-id` in the despicable-agents repo at `/Users/ben/github/benpeter/despicable-agents`.

    ```sh
    grep -r '/tmp/claude-session-id' /Users/ben/github/benpeter/despicable-agents --include='*.md' --include='*.sh' --include='*.json' --include='*.yaml' --include='*.yml' | grep -v 'docs/history/'
    ```

    Files under `docs/history/` are immutable execution reports and should be excluded from the check.

    **Expected result**: Zero matches. If any matches remain, list them with file paths and line numbers.

    Also verify that the `commit-point-check.sh` file does NOT reference `/tmp/claude-session-id` (it should only reference `CLAUDE_SESSION_ID` as a fallback, which is correct).

    Report the verification results. If any unexpected references remain, list them.

    ## Deliverables
    - Verification that no active file (excluding `docs/history/`) reads or writes `/tmp/claude-session-id`

    ## What NOT to do
    - Do NOT modify any files -- this is a read-only verification task
    - Do NOT flag references in `docs/history/` -- those are historical records
- **Deliverables**: Verification report confirming no remaining references
- **Success criteria**: Zero grep matches (excluding `docs/history/`)

### Cross-Cutting Coverage

- **Testing**: Not included. This change modifies skill configuration (YAML frontmatter) and shell command patterns in markdown instruction files. There is no executable code to unit-test -- the SessionStart hook is a one-liner shell command, and the SKILL.md is a prompt document, not runnable code. Verification is handled by Task 4 (grep check) and manual testing after deployment.
- **Security**: Not included. The change replaces one session ID propagation mechanism (shared file) with another (env var via CLAUDE_ENV_FILE). Both are local-only, non-secret identifiers used for status file naming. The new mechanism is strictly more secure (eliminates the world-readable shared file). No new attack surface, auth changes, user input handling, or dependency additions.
- **Usability -- Strategy**: Not included. This is an invisible infrastructure change. The user-visible behavior (status line showing nefario phase) is unchanged. The only user-facing difference is eliminating cross-talk in concurrent sessions, which is a pure improvement requiring no workflow changes.
- **Usability -- Design**: Not applicable. No UI components or visual changes.
- **Documentation**: Included as Task 3 (docs/using-nefario.md update).
- **Observability**: Not applicable. No runtime services, APIs, or production components.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none
  - ux-strategy-minion: No -- invisible infrastructure change, no user workflow changes
  - ux-design-minion: No -- no UI components
  - accessibility-minion: No -- no web-facing HTML/UI
  - sitespeed-minion: No -- no web-facing runtime code
  - observability-minion: No -- no runtime components
  - user-docs-minion: No -- the only user-facing doc (`using-nefario.md`) is already covered by Task 3; the change is minimal (mechanism explanation, not new features)
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

The devx-minion contribution initially suggested `once: true` as viable but ultimately recommended against it. This is the correct call -- the risk of CLAUDE_ENV_FILE not persisting across compaction outweighs the negligible performance gain. The plan follows the "no `once: true`" recommendation.

The devx-minion contribution initially showed `export CLAUDE_SESSION_ID=...` in the CLAUDE_ENV_FILE write. Based on Claude Code hooks documentation, CLAUDE_ENV_FILE uses bare `KEY=VALUE` format without `export`. The plan corrects this to `echo "CLAUDE_SESSION_ID=$SID"`.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| CLAUDE_ENV_FILE contents may not persist across compaction/clear | MEDIUM | Hook fires on ALL SessionStart events (no `once: true`), re-writing the env var after every compaction |
| Skill-scoped SessionStart hooks may have edge cases (GitHub issue #17688) | LOW-MEDIUM | Test immediately after implementation. Fallback: define hook in `.claude/settings.json` as a documented exception |
| Existing users have old status line command baked into settings.json | MEDIUM | Old write is harmless (dead code). Document in changelog that users should re-run `/despicable-statusline` to get the clean command. The old command writes a file nothing reads -- no functional impact |
| Multiple hooks appending to CLAUDE_ENV_FILE concurrently | LOW | Single small write well under POSIX atomic write size. No mitigation needed |

### Execution Order

```
Batch 1 (parallel):
  Task 1: Add hook + replace SID refs in SKILL.md  [APPROVAL GATE]
  Task 2: Update despicable-statusline skill
  Task 3: Update docs/using-nefario.md

  -- Gate: Task 1 approval required before Task 4 --

Batch 2 (after gate + Batch 1 completion):
  Task 4: Verify no remaining references
```

Tasks 1, 2, and 3 can execute in parallel since they modify different files. Task 4 depends on all three completing. However, the approval gate on Task 1 means Task 4 will wait for gate approval + Tasks 2-3 completion before running.

### Verification Steps

1. **Grep verification** (Task 4): Zero matches for `/tmp/claude-session-id` in active files
2. **Frontmatter validation**: `skills/nefario/SKILL.md` starts with valid YAML frontmatter containing `hooks: > SessionStart:` structure
3. **Manual smoke test**: After deployment (`./install.sh`), start a `/nefario` session and verify `echo $CLAUDE_SESSION_ID` in a Bash tool call returns a non-empty value matching the session ID
4. **Concurrent session test**: Open two Claude Code sessions, run `/nefario` in both, verify each writes to a different `/tmp/nefario-status-*` file
5. **Status line test**: Re-run `/despicable-statusline` and verify the status line still shows nefario phase information during orchestration
