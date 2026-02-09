#!/usr/bin/env bash
#
# Stop hook: Detect nefario orchestration and prompt report generation
#
# This hook runs when Claude finishes responding. If it detects that the session
# performed nefario orchestration but didn't generate a report, it blocks Claude's
# exit and instructs it to generate the report.
#
# Exit codes:
#   0 - Allow Claude to stop normally
#   1 - Script error (stop Claude with error)
#   2 - Block Claude's stop; stderr instructions will be fed to Claude

set -euo pipefail

# Constants
readonly VALID_TRANSCRIPT_DIR="${HOME}/.claude/projects"
readonly NEFARIO_REPORTS_DIR="nefario/reports"
readonly REPORT_TEMPLATE="${NEFARIO_REPORTS_DIR}/TEMPLATE.md"

# Error handling
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Read JSON input from stdin
read_input() {
    local input
    input=$(cat)
    echo "$input"
}

# Extract field from JSON
json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r ".$field // empty" 2>/dev/null || echo ""
}

# Validate transcript path is within expected directory
validate_transcript_path() {
    local transcript_path="$1"

    # Canonicalize both paths
    local canon_transcript
    local canon_valid_dir
    canon_transcript=$(cd "$(dirname "$transcript_path")" 2>/dev/null && pwd -P)/$(basename "$transcript_path") || error_exit "Cannot resolve transcript path: $transcript_path"
    canon_valid_dir=$(cd "$VALID_TRANSCRIPT_DIR" 2>/dev/null && pwd -P) || error_exit "Cannot resolve valid transcript directory: $VALID_TRANSCRIPT_DIR"

    # Check if transcript is within valid directory
    if [[ "$canon_transcript" != "$canon_valid_dir"* ]]; then
        error_exit "Transcript path outside valid directory: $transcript_path"
    fi

    # Check file exists
    [[ -f "$transcript_path" ]] || error_exit "Transcript file does not exist: $transcript_path"

    echo "$transcript_path"
}

# Fast grep scan for MODE markers
detect_orchestration() {
    local transcript_path="$1"

    # Search for MODE: META-PLAN or MODE: SYNTHESIS in the transcript
    # These strings appear in nefario Task tool prompts and are unique to orchestration
    if grep -q 'MODE: META-PLAN\|MODE: SYNTHESIS' "$transcript_path" 2>/dev/null; then
        return 0  # Orchestration detected
    fi
    return 1  # No orchestration
}

# Check if report was already written
check_report_written() {
    local transcript_path="$1"

    # Use timeout to prevent hanging on large files
    # macOS-compatible: use perl for timeout if 'timeout' command not available
    local timeout_cmd
    if command -v timeout >/dev/null 2>&1; then
        timeout_cmd="timeout 5s"
    elif command -v gtimeout >/dev/null 2>&1; then
        timeout_cmd="gtimeout 5s"
    else
        # Fallback: use perl to implement timeout
        timeout_cmd="perl -e 'alarm 5; exec @ARGV' --"
    fi

    # Look for Write tool calls to nefario/reports/*.md
    if $timeout_cmd jq -e '
        select(.type == "assistant") |
        .message.content[]? |
        select(.type == "tool_use" and .name == "Write") |
        select(.input.file_path | test("nefario/reports/.*\\.md$"))
    ' "$transcript_path" >/dev/null 2>&1; then
        return 0  # Report was written
    fi
    return 1  # No report written
}

# Main execution
main() {
    # Read input JSON
    local input
    input=$(read_input)

    # Extract fields
    local stop_hook_active
    local transcript_path
    stop_hook_active=$(json_field "$input" "stop_hook_active")
    transcript_path=$(json_field "$input" "transcript_path")

    # Check if we're already continuing from a prior Stop hook block
    if [[ "$stop_hook_active" == "true" ]]; then
        exit 0  # Allow Claude to stop; prevent infinite loop
    fi

    # Validate transcript path
    transcript_path=$(validate_transcript_path "$transcript_path")

    # Fast orchestration detection
    if ! detect_orchestration "$transcript_path"; then
        exit 0  # Not an orchestration session; allow normal stop
    fi

    # Check if report already written
    if check_report_written "$transcript_path"; then
        exit 0  # Report exists; allow normal stop
    fi

    # Orchestration detected but no report written - block and instruct
    cat >&2 <<EOF
**Generating orchestration report...**

A nefario orchestration session was detected but no execution report was generated.

Please generate the report now following the template at ${REPORT_TEMPLATE}.

Review the transcript to extract:
- Task description and outcome
- Agents involved (from Task tool calls)
- Phase breakdown (meta-plan, specialists, synthesis, review, execution)
- Decisions made and conflicts resolved
- Files created/modified
- Approval gates presented
- Outstanding items

Follow the file naming convention in the template and update the index.
EOF

    exit 2  # Block Claude's stop; stderr will be fed as instructions
}

# Run main function
main
