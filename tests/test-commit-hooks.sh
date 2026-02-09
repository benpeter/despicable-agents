#!/usr/bin/env bash
#
# Test suite for commit workflow hooks:
#   - track-file-changes.sh  (PostToolUse hook)
#   - commit-point-check.sh  (Stop hook)
#
# Each test creates a fresh temp directory with a real git repo,
# sets up required state, invokes the hook via stdin JSON, and
# asserts exit code and output content.
#
# Usage:
#   ./tests/test-commit-hooks.sh
#
# Exit codes:
#   0 - All tests pass
#   1 - One or more tests fail

set -euo pipefail

# --- Test framework ---

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRACKER_HOOK="${SCRIPT_DIR}/../.claude/hooks/track-file-changes.sh"
COMMIT_HOOK="${SCRIPT_DIR}/../.claude/hooks/commit-point-check.sh"
SENSITIVE_PATTERNS="${SCRIPT_DIR}/../.claude/hooks/sensitive-patterns.txt"
TESTS_PASSED=0
TESTS_FAILED=0
TEMP_DIR=""
SESSION_ID=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() {
    local test_name="$1"
    echo -e "${GREEN}✓${NC} ${test_name}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    local test_name="$1"
    local reason="$2"
    echo -e "${RED}✗${NC} ${test_name}"
    echo -e "  ${RED}${reason}${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Create a fresh temp dir with a git repo and unique session ID
setup() {
    TEMP_DIR=$(mktemp -d)
    SESSION_ID="test-$$-${RANDOM}"

    # Initialize a real git repo
    git init -b main "$TEMP_DIR/repo" >/dev/null 2>&1
    git -C "$TEMP_DIR/repo" config user.email "test@test.com"
    git -C "$TEMP_DIR/repo" config user.name "Test"

    # Create initial commit so HEAD exists
    touch "$TEMP_DIR/repo/.gitkeep"
    git -C "$TEMP_DIR/repo" add .gitkeep
    git -C "$TEMP_DIR/repo" commit -m "initial" >/dev/null 2>&1

    # Copy sensitive patterns file into the repo at the expected relative path
    mkdir -p "$TEMP_DIR/repo/.claude/hooks"
    cp "$SENSITIVE_PATTERNS" "$TEMP_DIR/repo/.claude/hooks/sensitive-patterns.txt"

    # Clean up any ledger/marker files for this session
    rm -f "/tmp/claude-change-ledger-${SESSION_ID}.txt"
    rm -f "/tmp/claude-commit-defer-${SESSION_ID}.txt"
    rm -f "/tmp/claude-commit-declined-${SESSION_ID}"
}

teardown() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    rm -f "/tmp/claude-change-ledger-${SESSION_ID}.txt"
    rm -f "/tmp/claude-commit-defer-${SESSION_ID}.txt"
    rm -f "/tmp/claude-commit-declined-${SESSION_ID}"
}

# --- JSON helpers ---

# Build PostToolUse JSON for track-file-changes.sh
tracker_input() {
    local file_path="${1:-}"
    local tool_name="${2:-Write}"
    cat <<EOF
{
  "tool_name": "$tool_name",
  "tool_input": { "file_path": "$file_path" },
  "session_id": "$SESSION_ID"
}
EOF
}

# Build Stop hook JSON for commit-point-check.sh
commit_input() {
    local stop_hook_active="${1:-false}"
    cat <<EOF
{
  "stop_hook_active": $stop_hook_active,
  "session_id": "$SESSION_ID",
  "working_directory": "$TEMP_DIR/repo"
}
EOF
}

# Get the ledger path for the current session
ledger_path() {
    echo "/tmp/claude-change-ledger-${SESSION_ID}.txt"
}

# --- File Change Tracker Tests (track-file-changes.sh) ---

test_tracker_write_adds_to_ledger() {
    local test_name="Tracker: Write tool call adds file to ledger"

    local input
    input=$(tracker_input "$TEMP_DIR/repo/src/main.js")
    local exit_code=0
    echo "$input" | "$TRACKER_HOOK" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        fail "$test_name" "Expected exit 0, got $exit_code"
        return
    fi

    local ledger
    ledger=$(ledger_path)
    if [[ ! -f "$ledger" ]]; then
        fail "$test_name" "Ledger file not created"
        return
    fi

    if grep -qFx "$TEMP_DIR/repo/src/main.js" "$ledger"; then
        pass "$test_name"
    else
        fail "$test_name" "File path not found in ledger"
    fi
}

test_tracker_edit_adds_to_ledger() {
    local test_name="Tracker: Edit tool call adds file to ledger"

    local input
    input=$(tracker_input "$TEMP_DIR/repo/src/utils.js" "Edit")
    local exit_code=0
    echo "$input" | "$TRACKER_HOOK" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        fail "$test_name" "Expected exit 0, got $exit_code"
        return
    fi

    if grep -qFx "$TEMP_DIR/repo/src/utils.js" "$(ledger_path)"; then
        pass "$test_name"
    else
        fail "$test_name" "File path not found in ledger"
    fi
}

test_tracker_deduplicates() {
    local test_name="Tracker: Duplicate file paths are deduplicated"

    local filepath="$TEMP_DIR/repo/src/app.js"
    local input
    input=$(tracker_input "$filepath")

    # Write same path three times
    echo "$input" | "$TRACKER_HOOK" >/dev/null 2>&1 || true
    echo "$input" | "$TRACKER_HOOK" >/dev/null 2>&1 || true
    echo "$input" | "$TRACKER_HOOK" >/dev/null 2>&1 || true

    local count
    count=$(grep -cFx "$filepath" "$(ledger_path)" 2>/dev/null || echo "0")

    if [[ "$count" -eq 1 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected 1 occurrence, got $count"
    fi
}

test_tracker_malformed_json() {
    local test_name="Tracker: Malformed JSON input does not crash (exit 0)"

    local exit_code=0
    echo "this is not json {{{" | "$TRACKER_HOOK" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}

test_tracker_missing_file_path() {
    local test_name="Tracker: Missing file_path in input handled gracefully"

    local exit_code=0
    echo '{"tool_name": "Write", "tool_input": {}, "session_id": "'"$SESSION_ID"'"}' \
        | "$TRACKER_HOOK" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi

    # Ledger should not exist or be empty
    local ledger
    ledger=$(ledger_path)
    if [[ ! -f "$ledger" ]] || [[ ! -s "$ledger" ]]; then
        pass "$test_name (ledger correctly empty)"
    else
        fail "$test_name (ledger not empty)" "Ledger should be empty but has content"
    fi
}

test_tracker_empty_file_path() {
    local test_name="Tracker: Empty string file_path handled gracefully"

    local exit_code=0
    echo '{"tool_name": "Write", "tool_input": {"file_path": ""}, "session_id": "'"$SESSION_ID"'"}' \
        | "$TRACKER_HOOK" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}

# --- Commit Checkpoint Tests (commit-point-check.sh) ---

test_commit_no_uncommitted_changes() {
    local test_name="Commit: No uncommitted changes exits 0"

    # No ledger file means no changes tracked
    local input
    input=$(commit_input)
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}

test_commit_uncommitted_changes_block() {
    local test_name="Commit: Uncommitted changes exit 2 with checkpoint"

    # Switch to a feature branch to avoid protected-branch blocking path
    git -C "$TEMP_DIR/repo" checkout -b feature/test-changes >/dev/null 2>&1

    # Create a tracked file with uncommitted changes
    echo "content" > "$TEMP_DIR/repo/feature.js"
    git -C "$TEMP_DIR/repo" add feature.js
    git -C "$TEMP_DIR/repo" commit -m "add feature" >/dev/null 2>&1
    echo "modified content" > "$TEMP_DIR/repo/feature.js"

    # Populate ledger with the changed file
    echo "$TEMP_DIR/repo/feature.js" > "$(ledger_path)"

    local input
    input=$(commit_input)
    local exit_code=0
    local stderr
    stderr=$(echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" 2>&1 >/dev/null) || exit_code=$?

    if [[ $exit_code -ne 2 ]]; then
        fail "$test_name" "Expected exit 2, got $exit_code"
        return
    fi

    if echo "$stderr" | grep -q "Uncommitted changes detected"; then
        pass "$test_name"
    else
        fail "$test_name" "stderr missing checkpoint message"
    fi
}

test_commit_defer_all_suppresses() {
    local test_name="Commit: defer-all marker file suppresses prompt (exit 0)"

    # Create uncommitted changes
    echo "content" > "$TEMP_DIR/repo/app.js"
    git -C "$TEMP_DIR/repo" add app.js
    git -C "$TEMP_DIR/repo" commit -m "add app" >/dev/null 2>&1
    echo "modified" > "$TEMP_DIR/repo/app.js"

    # Populate ledger
    echo "$TEMP_DIR/repo/app.js" > "$(ledger_path)"

    # Create defer marker
    echo "deferred" > "/tmp/claude-commit-defer-${SESSION_ID}.txt"

    local input
    input=$(commit_input)
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}

test_commit_auto_defer_trivial_md() {
    local test_name="Commit: Auto-defer for only .md files with < 5 lines diff"

    # Create a markdown file with a small change (< 5 diff lines)
    echo "# Title" > "$TEMP_DIR/repo/notes.md"
    git -C "$TEMP_DIR/repo" add notes.md
    git -C "$TEMP_DIR/repo" commit -m "add notes" >/dev/null 2>&1
    echo "# Title
One small edit" > "$TEMP_DIR/repo/notes.md"

    # Populate ledger
    echo "$TEMP_DIR/repo/notes.md" > "$(ledger_path)"

    local input
    input=$(commit_input)
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0 (auto-deferred), got $exit_code"
    fi
}

test_commit_auto_defer_not_for_non_md() {
    local test_name="Commit: Auto-defer does NOT trigger when non-.md files changed"

    # Create a .js file with a small change (< 5 diff lines)
    echo "// code" > "$TEMP_DIR/repo/index.js"
    git -C "$TEMP_DIR/repo" add index.js
    git -C "$TEMP_DIR/repo" commit -m "add index" >/dev/null 2>&1
    echo "// code
// one line change" > "$TEMP_DIR/repo/index.js"

    # Populate ledger
    echo "$TEMP_DIR/repo/index.js" > "$(ledger_path)"

    local input
    input=$(commit_input)
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 2 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 2 (not auto-deferred), got $exit_code"
    fi
}

test_commit_branch_safety_main() {
    local test_name="Commit: On main branch, warning included in stderr"

    # Create uncommitted changes (we are already on main)
    echo "code" > "$TEMP_DIR/repo/server.js"
    git -C "$TEMP_DIR/repo" add server.js
    git -C "$TEMP_DIR/repo" commit -m "add server" >/dev/null 2>&1
    echo "modified code" > "$TEMP_DIR/repo/server.js"

    # Populate ledger
    echo "$TEMP_DIR/repo/server.js" > "$(ledger_path)"

    local input
    input=$(commit_input)
    local exit_code=0
    local stderr
    stderr=$(echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" 2>&1 >/dev/null) || exit_code=$?

    if [[ $exit_code -ne 2 ]]; then
        fail "$test_name" "Expected exit 2, got $exit_code"
        return
    fi

    if echo "$stderr" | grep -q "main"; then
        pass "$test_name"
    else
        fail "$test_name" "stderr missing branch warning about main"
    fi
}

test_commit_stop_hook_active() {
    local test_name="Commit: stop_hook_active=true exits 0 (loop protection)"

    # Create uncommitted changes
    echo "content" > "$TEMP_DIR/repo/loop.js"
    git -C "$TEMP_DIR/repo" add loop.js
    git -C "$TEMP_DIR/repo" commit -m "add loop" >/dev/null 2>&1
    echo "modified" > "$TEMP_DIR/repo/loop.js"
    echo "$TEMP_DIR/repo/loop.js" > "$(ledger_path)"

    local input
    input=$(commit_input "true")
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}

test_commit_sensitive_file_filtered() {
    local test_name="Commit: Sensitive file patterns filtered from staging list"

    # Create a .env file (sensitive) with changes
    echo "SECRET=abc" > "$TEMP_DIR/repo/.env"
    git -C "$TEMP_DIR/repo" add .env
    git -C "$TEMP_DIR/repo" commit -m "add env" >/dev/null 2>&1
    echo "SECRET=xyz" > "$TEMP_DIR/repo/.env"

    # Also create a normal file with changes
    echo "code" > "$TEMP_DIR/repo/app.js"
    git -C "$TEMP_DIR/repo" add app.js
    git -C "$TEMP_DIR/repo" commit -m "add app" >/dev/null 2>&1
    echo "new code" > "$TEMP_DIR/repo/app.js"

    # Populate ledger with both files
    printf '%s\n' "$TEMP_DIR/repo/.env" "$TEMP_DIR/repo/app.js" > "$(ledger_path)"

    # Create a feature branch so we don't hit main-branch blocking
    git -C "$TEMP_DIR/repo" checkout -b feature/test >/dev/null 2>&1

    local input
    input=$(commit_input)
    local exit_code=0
    local stderr
    stderr=$(echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" 2>&1 >/dev/null) || exit_code=$?

    if [[ $exit_code -ne 2 ]]; then
        fail "$test_name" "Expected exit 2, got $exit_code"
        return
    fi

    # stderr should warn about .env being sensitive
    if echo "$stderr" | grep -qi "sensitive\|skipped"; then
        # stderr should NOT include .env in the staging commands
        if echo "$stderr" | grep "git add" | grep -q "\.env"; then
            fail "$test_name" ".env should not appear in staging commands"
        else
            pass "$test_name"
        fi
    else
        fail "$test_name" "stderr missing sensitive file warning"
    fi
}

test_commit_standalone_stop_hook() {
    local test_name="Commit: Works correctly as standalone Stop hook"

    # This test verifies that commit-point-check.sh works as a standalone Stop hook.
    # The hook only reads its own stdin JSON and ledger files.

    # Create uncommitted changes on a feature branch
    git -C "$TEMP_DIR/repo" checkout -b feature/ordering-test >/dev/null 2>&1
    echo "content" > "$TEMP_DIR/repo/handler.js"
    git -C "$TEMP_DIR/repo" add handler.js
    git -C "$TEMP_DIR/repo" commit -m "add handler" >/dev/null 2>&1
    echo "modified" > "$TEMP_DIR/repo/handler.js"

    echo "$TEMP_DIR/repo/handler.js" > "$(ledger_path)"

    local input
    input=$(commit_input)
    local exit_code=0
    local stderr
    stderr=$(echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" 2>&1 >/dev/null) || exit_code=$?

    if [[ $exit_code -eq 2 ]] && echo "$stderr" | grep -q "Uncommitted changes detected"; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 2 with checkpoint, got exit $exit_code"
    fi
}

# --- Integration Tests ---

test_integration_full_flow() {
    local test_name="Integration: Write -> tracker records -> commit checkpoint detects"

    # Create a feature branch to avoid main-branch blocking
    git -C "$TEMP_DIR/repo" checkout -b feature/integration >/dev/null 2>&1

    # Step 1: Create a file in the repo and commit it
    echo "original" > "$TEMP_DIR/repo/component.js"
    git -C "$TEMP_DIR/repo" add component.js
    git -C "$TEMP_DIR/repo" commit -m "add component" >/dev/null 2>&1

    # Step 2: Modify the file (simulating a Write tool call result)
    echo "modified" > "$TEMP_DIR/repo/component.js"

    # Step 3: Invoke tracker hook (simulating PostToolUse)
    local tracker_json
    tracker_json=$(tracker_input "$TEMP_DIR/repo/component.js")
    echo "$tracker_json" | "$TRACKER_HOOK" >/dev/null 2>&1 || true

    # Verify tracker recorded the file
    if ! grep -qFx "$TEMP_DIR/repo/component.js" "$(ledger_path)" 2>/dev/null; then
        fail "$test_name" "Tracker did not record file to ledger"
        return
    fi

    # Step 4: Invoke commit checkpoint hook
    local commit_json
    commit_json=$(commit_input)
    local exit_code=0
    local stderr
    stderr=$(echo "$commit_json" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" 2>&1 >/dev/null) || exit_code=$?

    if [[ $exit_code -eq 2 ]] && echo "$stderr" | grep -q "Uncommitted changes detected"; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 2 with checkpoint, got exit $exit_code"
    fi
}

test_integration_full_flow_with_defer() {
    local test_name="Integration: Write -> tracker records -> defer -> checkpoint suppressed"

    # Create a feature branch
    git -C "$TEMP_DIR/repo" checkout -b feature/defer-test >/dev/null 2>&1

    # Step 1: Create and modify a file
    echo "original" > "$TEMP_DIR/repo/service.js"
    git -C "$TEMP_DIR/repo" add service.js
    git -C "$TEMP_DIR/repo" commit -m "add service" >/dev/null 2>&1
    echo "modified" > "$TEMP_DIR/repo/service.js"

    # Step 2: Invoke tracker hook
    local tracker_json
    tracker_json=$(tracker_input "$TEMP_DIR/repo/service.js")
    echo "$tracker_json" | "$TRACKER_HOOK" >/dev/null 2>&1 || true

    # Step 3: Set the defer-all marker (simulating user choosing "defer-all")
    echo "deferred" > "/tmp/claude-commit-defer-${SESSION_ID}.txt"

    # Step 4: Invoke commit checkpoint hook
    local commit_json
    commit_json=$(commit_input)
    local exit_code=0
    echo "$commit_json" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0 (deferred), got $exit_code"
    fi
}

# --- Main ---

main() {
    echo -e "\n${YELLOW}Running commit workflow hook tests${NC}\n"

    # Check hook scripts exist
    if [[ ! -f "$TRACKER_HOOK" ]]; then
        echo -e "${RED}ERROR: track-file-changes.sh not found at $TRACKER_HOOK${NC}"
        exit 1
    fi
    if [[ ! -f "$COMMIT_HOOK" ]]; then
        echo -e "${RED}ERROR: commit-point-check.sh not found at $COMMIT_HOOK${NC}"
        exit 1
    fi

    echo -e "${YELLOW}--- File Change Tracker Tests ---${NC}\n"

    setup; test_tracker_write_adds_to_ledger; teardown
    setup; test_tracker_edit_adds_to_ledger; teardown
    setup; test_tracker_deduplicates; teardown
    setup; test_tracker_malformed_json; teardown
    setup; test_tracker_missing_file_path; teardown
    setup; test_tracker_empty_file_path; teardown

    echo ""
    echo -e "${YELLOW}--- Commit Checkpoint Tests ---${NC}\n"

    setup; test_commit_no_uncommitted_changes; teardown
    setup; test_commit_uncommitted_changes_block; teardown
    setup; test_commit_defer_all_suppresses; teardown
    setup; test_commit_auto_defer_trivial_md; teardown
    setup; test_commit_auto_defer_not_for_non_md; teardown
    setup; test_commit_branch_safety_main; teardown
    setup; test_commit_stop_hook_active; teardown
    setup; test_commit_sensitive_file_filtered; teardown
    setup; test_commit_standalone_stop_hook; teardown

    echo ""
    echo -e "${YELLOW}--- Integration Tests ---${NC}\n"

    setup; test_integration_full_flow; teardown
    setup; test_integration_full_flow_with_defer; teardown

    # Report results
    echo ""
    echo -e "${YELLOW}===========================================${NC}"
    echo -e "  Passed: ${GREEN}${TESTS_PASSED}${NC}"
    echo -e "  Failed: ${RED}${TESTS_FAILED}${NC}"
    echo -e "${YELLOW}===========================================${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}All tests passed!${NC}\n"
        exit 0
    else
        echo -e "\n${RED}Some tests failed${NC}\n"
        exit 1
    fi
}

main
