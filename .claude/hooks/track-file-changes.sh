#!/usr/bin/env bash
#
# PostToolUse hook: Track file changes for commit workflow
#
# This hook runs after Write and Edit tool calls. It appends the modified
# file's absolute path to a session-scoped change ledger. The commit
# checkpoint hook reads this ledger to determine which files to stage.
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

    # Determine session ID for the ledger filename.
    # Try session_id from the hook input JSON first, then CLAUDE_SESSION_ID env var.
    local session_id
    session_id=$(json_field "$input" '.session_id')
    if [[ -z "$session_id" ]]; then
        session_id="${CLAUDE_SESSION_ID:-default}"
    fi

    local ledger="/tmp/claude-change-ledger-${session_id}.txt"

    # Create ledger if it does not exist
    touch "$ledger" 2>/dev/null || exit 0

    # Deduplicate: only append if path is not already in the ledger.
    # Use grep with fixed-string, full-line match for exact comparison.
    if ! grep -qFx "$file_path" "$ledger" 2>/dev/null; then
        echo "$file_path" >> "$ledger" 2>/dev/null || true
    fi

    exit 0
}

main
