Update the PostToolUse hook at `.claude/hooks/track-file-changes.sh` to extract
`agent_type` and `agent_id` from the hook event JSON and write them as
tab-separated columns in the change ledger.

## Current State

Read the current hook at:
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/agent-attribution/.claude/hooks/track-file-changes.sh

The hook currently:
1. Reads JSON from stdin (PostToolUse event)
2. Extracts `.tool_input.file_path` via jq
3. Validates the path (rejects newlines)
4. Appends the bare path to `/tmp/claude-change-ledger-<session_id>.txt`
5. Deduplicates using `grep -qFx "$file_path"`

## What to Change

1. **Extract agent metadata** after file_path extraction:
   ```bash
   local agent_type
   agent_type=$(json_field "$input" '.agent_type')
   local agent_id
   agent_id=$(json_field "$input" '.agent_id')
   ```

2. **Validate agent_type and agent_id** -- apply regex validation:
   ```bash
   if [[ -n "$agent_type" ]] && ! [[ "$agent_type" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
       agent_type=""
   fi
   if [[ -n "$agent_id" ]] && ! [[ "$agent_id" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
       agent_id=""
   fi
   ```

3. **Validate session_id** -- apply same regex guard to session_id (SECURITY ADVISORY):
   ```bash
   if ! [[ "$session_id" =~ ^[a-zA-Z0-9_-]{1,128}$ ]]; then
       session_id="default"
   fi
   ```

4. **Add tab validation for file_path** (TESTING ADVISORY):
   In addition to rejecting newlines, also reject tabs in file paths:
   ```bash
   if [[ "$file_path" == *$'\t'* ]]; then
       exit 0
   fi
   ```

5. **Write TSV lines** -- use `printf` exclusively for tab insertion (never use `\t` in double-quoted strings):
   ```bash
   if [[ -n "$agent_type" ]]; then
       if [[ -n "$agent_id" ]]; then
           printf '%s\t%s\t%s\n' "$file_path" "$agent_type" "$agent_id" >> "$ledger"
       else
           printf '%s\t%s\n' "$file_path" "$agent_type" >> "$ledger"
       fi
   else
       echo "$file_path" >> "$ledger"
   fi
   ```

6. **Update deduplication** -- per-tuple (path, agent_type) dedup when agent present, per-path when absent:
   ```bash
   if [[ -n "$agent_type" ]]; then
       local prefix
       prefix=$(printf '%s\t%s' "$file_path" "$agent_type")
       if grep -qF "$prefix" "$ledger" 2>/dev/null; then
           exit 0
       fi
   else
       if grep -qFx "$file_path" "$ledger" 2>/dev/null; then
           exit 0
       fi
   fi
   ```

7. **Harden ledger file creation** -- replace `touch` with explicit permissions:
   ```bash
   if [[ ! -f "$ledger" ]]; then
       install -m 0600 /dev/null "$ledger"
   fi
   ```

8. **Update the file header comment** to document the new TSV format:
   ```
   # PostToolUse hook: Track file changes for commit workflow
   #
   # This hook runs after Write and Edit tool calls. It appends the modified
   # file's absolute path (with optional agent metadata) to a session-scoped
   # change ledger in TSV format:
   #
   #   <file_path>[\t<agent_type>[\t<agent_id>]]
   #
   # When agent_type/agent_id are absent from the hook input, only the bare
   # file path is written (backward compatible with the pre-attribution format).
   ```

## What NOT to Do

- Do NOT create a separate metadata sidecar file. All data goes in the existing ledger.
- Do NOT add an allowlist of known agent names. The regex validation is sufficient.
- Do NOT use `agent_type` for any authorization or access control decision.
- Do NOT change the exit code behavior. The hook must always exit 0.
- Do NOT use JSON lines format or any format other than TSV.
- Do NOT use `\t` in double-quoted variable assignments. Always use printf for tab insertion.

## Deliverables

Modified `.claude/hooks/track-file-changes.sh`
