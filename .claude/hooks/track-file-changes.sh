#!/usr/bin/env bash
#
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
#
# Exit codes:
#   0 - Always (PostToolUse hooks must not block tool execution)

set -euo pipefail

# Trap any error and exit cleanly -- PostToolUse hooks must never fail
trap 'exit 0' ERR

# --- Helpers ---

# Extract field from JSON using jq
json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r "$field // empty" 2>/dev/null || echo ""
}

# --- Main ---

main() {
    # Read JSON input from stdin
    local input
    input=$(cat)

    # Extract the file path from tool_input
    local file_path
    file_path=$(json_field "$input" '.tool_input.file_path')

    # Nothing to track if file_path is empty
    if [[ -z "$file_path" ]]; then
        exit 0
    fi

    # Validate: reject paths with newlines (prevent injection).
    # Null bytes cannot appear in bash variables so no explicit check is needed.
    if [[ "$file_path" == *$'\n'* ]]; then
        exit 0
    fi

    # Validate: reject paths with tabs (would corrupt TSV format).
    if [[ "$file_path" == *$'\t'* ]]; then
        exit 0
    fi

    # Determine session ID for the ledger filename.
    # Try session_id from the hook input JSON first, then CLAUDE_SESSION_ID env var.
    local session_id
    session_id=$(json_field "$input" '.session_id')
    if [[ -z "$session_id" ]]; then
        session_id="${CLAUDE_SESSION_ID:-default}"
    fi

    # Validate session_id to prevent path traversal in ledger filename.
    if ! [[ "$session_id" =~ ^[a-zA-Z0-9_-]{1,128}$ ]]; then
        session_id="default"
    fi

    local ledger="/tmp/claude-change-ledger-${session_id}.txt"

    # Create ledger with restricted permissions if it does not exist
    if [[ ! -f "$ledger" ]]; then
        install -m 0600 /dev/null "$ledger"
    fi

    # Extract agent metadata from hook input
    local agent_type
    agent_type=$(json_field "$input" '.agent_type')
    local agent_id
    agent_id=$(json_field "$input" '.agent_id')

    # Validate agent_type and agent_id (allowable chars only, max 64)
    if [[ -n "$agent_type" ]] && ! [[ "$agent_type" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
        agent_type=""
    fi
    if [[ -n "$agent_id" ]] && ! [[ "$agent_id" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
        agent_id=""
    fi

    # Deduplicate: per-tuple (path, agent_type) when agent present, per-path when absent.
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

    # Append TSV line: path [tab agent_type [tab agent_id]]
    if [[ -n "$agent_type" ]]; then
        if [[ -n "$agent_id" ]]; then
            printf '%s\t%s\t%s\n' "$file_path" "$agent_type" "$agent_id" >> "$ledger" 2>/dev/null || true
        else
            printf '%s\t%s\n' "$file_path" "$agent_type" >> "$ledger" 2>/dev/null || true
        fi
    else
        echo "$file_path" >> "$ledger" 2>/dev/null || true
    fi

    exit 0
}

main
