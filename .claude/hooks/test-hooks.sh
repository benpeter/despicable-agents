#!/usr/bin/env bash
# tva
#
# Self-contained test suite for track-file-changes.sh and commit-point-check.sh
#
# Usage: bash .claude/hooks/test-hooks.sh
# Exit:  0 if all tests pass, N if N tests failed

set -euo pipefail

# --- Setup ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACK_HOOK="${SCRIPT_DIR}/track-file-changes.sh"
COMMIT_HOOK="${SCRIPT_DIR}/commit-point-check.sh"
SENSITIVE_PATTERNS="${SCRIPT_DIR}/sensitive-patterns.txt"

TESTS_PASSED=0
TESTS_FAILED=0
TEMP_DIRS=()

# Cleanup all temp dirs on exit
cleanup() {
    for d in "${TEMP_DIRS[@]:-}"; do
        [[ -d "$d" ]] && rm -rf "$d"
    done
    # Remove test ledger files
    rm -f /tmp/claude-change-ledger-test-session-*.txt
    rm -f /tmp/claude-commit-defer-test-session-*.txt
    rm -f /tmp/claude-commit-declined-test-session-*
    rm -f /tmp/nefario-status-test-session-*
}
trap cleanup EXIT

make_temp() {
    local d
    d=$(mktemp -d)
    TEMP_DIRS+=("$d")
    echo "$d"
}

# --- Reporting ---

pass() {
    echo "PASS: $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo "FAIL: $1 -- $2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# --- track-file-changes.sh helpers ---

# Run track hook with JSON input and a specific session ID
# Sets CLAUDE_PROJECT_DIR so hook can resolve paths
run_track() {
    local json="$1"
    local session_id="$2"
    CLAUDE_PROJECT_DIR="${3:-/tmp}" \
    CLAUDE_SESSION_ID="$session_id" \
        bash "$TRACK_HOOK" <<< "$json"
}

ledger_path() {
    echo "/tmp/claude-change-ledger-${1}.txt"
}

reset_ledger() {
    rm -f "$(ledger_path "$1")"
}

# ============================================================
# track-file-changes.sh tests
# ============================================================

# --- Test 1: Both agent_type and agent_id present -> 3 TSV columns ---
t1_session="test-session-t1-$$"
reset_ledger "$t1_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"frontend-minion","agent_id":"sub-abc123","session_id":"'"$t1_session"'"}' "$t1_session"
ledger=$(ledger_path "$t1_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 3 ]]; then
    pass "Test 1: Both agent_type and agent_id -> 3 TSV columns"
else
    fail "Test 1: Both agent_type and agent_id -> 3 TSV columns" "Got $col_count columns: '$line'"
fi

# --- Test 2: agent_type present, agent_id absent -> 2 TSV columns ---
t2_session="test-session-t2-$$"
reset_ledger "$t2_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"nefario","session_id":"'"$t2_session"'"}' "$t2_session"
ledger=$(ledger_path "$t2_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 2 ]]; then
    pass "Test 2: agent_type only -> 2 TSV columns"
else
    fail "Test 2: agent_type only -> 2 TSV columns" "Got $col_count columns: '$line'"
fi

# --- Test 3: Neither field present -> bare path (no tabs) ---
t3_session="test-session-t3-$$"
reset_ledger "$t3_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"session_id":"'"$t3_session"'"}' "$t3_session"
ledger=$(ledger_path "$t3_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]] && [[ "$line" == "/tmp/foo.js" ]]; then
    pass "Test 3: No agent fields -> bare path, no tabs"
else
    fail "Test 3: No agent fields -> bare path, no tabs" "Got $col_count columns: '$line'"
fi

# --- Test 4: Fields are null -> treated as absent -> bare path ---
t4_session="test-session-t4-$$"
reset_ledger "$t4_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":null,"agent_id":null,"session_id":"'"$t4_session"'"}' "$t4_session"
ledger=$(ledger_path "$t4_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 4: null fields -> bare path"
else
    fail "Test 4: null fields -> bare path" "Got $col_count columns: '$line'"
fi

# --- Test 5: Fields are empty strings -> treated as absent -> bare path ---
t5_session="test-session-t5-$$"
reset_ledger "$t5_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"","agent_id":"","session_id":"'"$t5_session"'"}' "$t5_session"
ledger=$(ledger_path "$t5_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 5: empty string fields -> bare path"
else
    fail "Test 5: empty string fields -> bare path" "Got $col_count columns: '$line'"
fi

# --- Test 6: agent_type with shell metacharacters -> cleared -> bare path ---
t6_session="test-session-t6-$$"
reset_ledger "$t6_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"; rm -rf /","session_id":"'"$t6_session"'"}' "$t6_session"
ledger=$(ledger_path "$t6_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 6: shell metacharacters in agent_type -> cleared, bare path"
else
    fail "Test 6: shell metacharacters in agent_type -> cleared, bare path" "Got $col_count columns: '$line'"
fi

# --- Test 7: agent_type with newline -> cleared -> bare path ---
t7_session="test-session-t7-$$"
reset_ledger "$t7_session"
# Use printf to embed literal newline in JSON (jq will parse it as multiline string which is invalid JSON,
# but the hook sees it as a raw jq extraction returning "foo\nbar" literal -- use \n escape in JSON value)
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"foo\nbar","session_id":"'"$t7_session"'"}' "$t7_session"
ledger=$(ledger_path "$t7_session")
line=$(head -1 "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 7: newline in agent_type -> cleared, bare path"
else
    fail "Test 7: newline in agent_type -> cleared, bare path" "Got $col_count columns: '$line'"
fi

# --- Test 8: agent_type exceeding 64 chars -> cleared -> bare path ---
t8_session="test-session-t8-$$"
reset_ledger "$t8_session"
long_type=$(printf 'a%.0s' {1..65})  # 65 'a' characters
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"'"$long_type"'","session_id":"'"$t8_session"'"}' "$t8_session"
ledger=$(ledger_path "$t8_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 8: agent_type >64 chars -> cleared, bare path"
else
    fail "Test 8: agent_type >64 chars -> cleared, bare path" "Got $col_count columns: '$line'"
fi

# --- Test 9: agent_type with spaces -> cleared -> bare path ---
t9_session="test-session-t9-$$"
reset_ledger "$t9_session"
run_track '{"tool_input":{"file_path":"/tmp/foo.js"},"agent_type":"my agent","session_id":"'"$t9_session"'"}' "$t9_session"
ledger=$(ledger_path "$t9_session")
line=$(cat "$ledger")
col_count=$(echo "$line" | awk -F'\t' '{print NF}')
if [[ "$col_count" -eq 1 ]]; then
    pass "Test 9: spaces in agent_type -> cleared, bare path"
else
    fail "Test 9: spaces in agent_type -> cleared, bare path" "Got $col_count columns: '$line'"
fi

# --- Test 10: file_path with tab character -> no entry, exit 0 ---
t10_session="test-session-t10-$$"
reset_ledger "$t10_session"
# Embed a literal tab in the file_path via JSON unicode escape \t is not standard JSON but jq handles \u0009
run_track '{"tool_input":{"file_path":"/tmp/foo\u0009bar.js"},"session_id":"'"$t10_session"'"}' "$t10_session"
ledger=$(ledger_path "$t10_session")
if [[ ! -f "$ledger" ]] || [[ ! -s "$ledger" ]]; then
    pass "Test 10: tab in file_path -> no entry written"
else
    fail "Test 10: tab in file_path -> no entry written" "Ledger contains: '$(cat "$ledger")'"
fi

# --- Test 11: Same path, same agent written twice -> deduplicated to one entry ---
t11_session="test-session-t11-$$"
reset_ledger "$t11_session"
run_track '{"tool_input":{"file_path":"/tmp/dedup.js"},"agent_type":"test-minion","session_id":"'"$t11_session"'"}' "$t11_session"
run_track '{"tool_input":{"file_path":"/tmp/dedup.js"},"agent_type":"test-minion","session_id":"'"$t11_session"'"}' "$t11_session"
ledger=$(ledger_path "$t11_session")
entry_count=$(wc -l < "$ledger")
if [[ "$entry_count" -eq 1 ]]; then
    pass "Test 11: Same path + same agent twice -> deduplicated to 1 entry"
else
    fail "Test 11: Same path + same agent twice -> deduplicated to 1 entry" "Got $entry_count entries"
fi

# --- Test 12: Same path, different agents -> two entries ---
t12_session="test-session-t12-$$"
reset_ledger "$t12_session"
run_track '{"tool_input":{"file_path":"/tmp/multi.js"},"agent_type":"frontend-minion","session_id":"'"$t12_session"'"}' "$t12_session"
run_track '{"tool_input":{"file_path":"/tmp/multi.js"},"agent_type":"backend-minion","session_id":"'"$t12_session"'"}' "$t12_session"
ledger=$(ledger_path "$t12_session")
entry_count=$(wc -l < "$ledger")
if [[ "$entry_count" -eq 2 ]]; then
    pass "Test 12: Same path, different agents -> 2 entries"
else
    fail "Test 12: Same path, different agents -> 2 entries" "Got $entry_count entries"
fi

# --- Test 13: Same path, one with agent, one without -> two entries ---
t13_session="test-session-t13-$$"
reset_ledger "$t13_session"
run_track '{"tool_input":{"file_path":"/tmp/mixed.js"},"agent_type":"nefario","session_id":"'"$t13_session"'"}' "$t13_session"
run_track '{"tool_input":{"file_path":"/tmp/mixed.js"},"session_id":"'"$t13_session"'"}' "$t13_session"
ledger=$(ledger_path "$t13_session")
entry_count=$(wc -l < "$ledger")
if [[ "$entry_count" -eq 2 ]]; then
    pass "Test 13: Same path, one with agent + one bare -> 2 entries"
else
    fail "Test 13: Same path, one with agent + one bare -> 2 entries" "Got $entry_count entries"
fi

# --- Test 14: file_path extraction works ---
t14_session="test-session-t14-$$"
reset_ledger "$t14_session"
run_track '{"tool_input":{"file_path":"/tmp/extract-test.py"},"session_id":"'"$t14_session"'"}' "$t14_session"
ledger=$(ledger_path "$t14_session")
if grep -qF "/tmp/extract-test.py" "$ledger" 2>/dev/null; then
    pass "Test 14: file_path correctly extracted and written to ledger"
else
    fail "Test 14: file_path correctly extracted and written to ledger" "Ledger: '$(cat "$ledger" 2>/dev/null)'"
fi

# --- Test 15: Empty file_path -> no entry, exit 0 ---
t15_session="test-session-t15-$$"
reset_ledger "$t15_session"
run_track '{"tool_input":{"file_path":""},"session_id":"'"$t15_session"'"}' "$t15_session"
ledger=$(ledger_path "$t15_session")
if [[ ! -f "$ledger" ]] || [[ ! -s "$ledger" ]]; then
    pass "Test 15: Empty file_path -> no entry"
else
    fail "Test 15: Empty file_path -> no entry" "Ledger: '$(cat "$ledger")'"
fi

# --- Test 16: file_path with newline -> no entry, exit 0 ---
t16_session="test-session-t16-$$"
reset_ledger "$t16_session"
# JSON \n in a string value becomes a literal newline when jq -r outputs it
run_track '{"tool_input":{"file_path":"/tmp/foo\nbar.js"},"session_id":"'"$t16_session"'"}' "$t16_session"
ledger=$(ledger_path "$t16_session")
if [[ ! -f "$ledger" ]] || [[ ! -s "$ledger" ]]; then
    pass "Test 16: Newline in file_path -> no entry"
else
    fail "Test 16: Newline in file_path -> no entry" "Ledger: '$(head -1 "$ledger")'"
fi

# --- Test 17: Hook exits 0 even on jq parse failure ---
t17_session="test-session-t17-$$"
reset_ledger "$t17_session"
exit_code=0
bash "$TRACK_HOOK" <<< "this is not json" || exit_code=$?
if [[ "$exit_code" -eq 0 ]]; then
    pass "Test 17: Hook exits 0 on jq parse failure"
else
    fail "Test 17: Hook exits 0 on jq parse failure" "Exit code was $exit_code"
fi

# ============================================================
# commit-point-check.sh tests
# ============================================================

# --- Git repo setup helper ---
# Creates a temp git repo, initial commit, non-protected branch, tracked non-.md file with changes,
# and a copy of sensitive-patterns.txt. Returns the repo path.
make_git_repo() {
    local repo
    repo=$(make_temp)

    git -C "$repo" init -q
    git -C "$repo" config user.email "test@test.com"
    git -C "$repo" config user.name "Test"
    git -C "$repo" commit --allow-empty -q -m "initial"
    git -C "$repo" checkout -q -b test-branch

    # Create .claude/hooks directory and copy sensitive-patterns.txt
    mkdir -p "${repo}/.claude/hooks"
    cp "$SENSITIVE_PATTERNS" "${repo}/.claude/hooks/sensitive-patterns.txt"

    # Create a tracked non-.md file and commit it
    echo "console.log('hello');" > "${repo}/app.js"
    git -C "$repo" add app.js
    git -C "$repo" commit -q -m "add app.js"

    # Modify the file so git diff shows changes (unstaged)
    echo "console.log('modified');" > "${repo}/app.js"

    echo "$repo"
}

# Run commit hook in a given repo dir, piping JSON via stdin
# Returns exit code via assignment (caller must use || true)
run_commit() {
    local json="$1"
    local repo="$2"
    local session_id="$3"
    (
        cd "$repo"
        CLAUDE_PROJECT_DIR="$repo" \
        CLAUDE_SESSION_ID="$session_id" \
            bash "$COMMIT_HOOK" <<< "$json"
    )
}

# --- Test 18: TSV ledger with agent metadata -> scope in checkpoint message ---
t18_session="test-session-t18-$$"
repo18=$(make_git_repo)
ledger18=$(ledger_path "$t18_session")
# Write TSV ledger entry referencing the file in the repo
printf '%s\t%s\t%s\n' "${repo18}/app.js" "frontend-minion" "sub-abc123" > "$ledger18"

stderr18=$(run_commit '{"session_id":"'"$t18_session"'"}' "$repo18" "$t18_session" 2>&1) || true
if echo "$stderr18" | grep -q "frontend"; then
    pass "Test 18: TSV ledger with agent metadata -> scope in checkpoint"
else
    fail "Test 18: TSV ledger with agent metadata -> scope in checkpoint" "stderr: '$stderr18'"
fi

# --- Test 19: Mixed format (old bare paths + new TSV) -> handles both ---
t19_session="test-session-t19-$$"
repo19=$(make_git_repo)
ledger19=$(ledger_path "$t19_session")
# Mix: one bare path, one TSV entry
echo "${repo19}/app.js" > "$ledger19"
printf '%s\t%s\n' "${repo19}/app.js" "backend-minion" >> "$ledger19"

stderr19=$(run_commit '{"session_id":"'"$t19_session"'"}' "$repo19" "$t19_session" 2>&1) || true
# Should not crash; should produce a checkpoint (exit 2 means block)
exit19=0
run_commit '{"session_id":"'"$t19_session"'"}' "$repo19" "$t19_session" >/dev/null 2>&1 || exit19=$?
if [[ "$exit19" -eq 2 ]]; then
    pass "Test 19: Mixed format (bare + TSV) -> handled gracefully"
else
    fail "Test 19: Mixed format (bare + TSV) -> handled gracefully" "Exit code: $exit19, stderr: '$stderr19'"
fi

# --- Test 20: Legacy format only (no tabs) -> works, no scope ---
t20_session="test-session-t20-$$"
repo20=$(make_git_repo)
ledger20=$(ledger_path "$t20_session")
echo "${repo20}/app.js" > "$ledger20"

exit20=0
stderr20=$(run_commit '{"session_id":"'"$t20_session"'"}' "$repo20" "$t20_session" 2>&1) || exit20=$?
# Scope appears in subject template as: "<type>(scope): <summary>"
# Without scope it should be: "<type>: <summary>" -- match the template line specifically
if [[ "$exit20" -eq 2 ]] && ! echo "$stderr20" | grep -qE '"<type>\([^)]+\): <summary>"'; then
    pass "Test 20: Legacy bare-path ledger -> checkpoint without scope"
else
    fail "Test 20: Legacy bare-path ledger -> checkpoint without scope" "Exit: $exit20, subject line: $(echo "$stderr20" | grep '<type>' || echo 'none')"
fi

# --- Test 21: Single agent_type "frontend-minion" -> scope = "frontend" ---
t21_session="test-session-t21-$$"
repo21=$(make_git_repo)
ledger21=$(ledger_path "$t21_session")
printf '%s\t%s\n' "${repo21}/app.js" "frontend-minion" > "$ledger21"

stderr21=$(run_commit '{"session_id":"'"$t21_session"'"}' "$repo21" "$t21_session" 2>&1) || true
if echo "$stderr21" | grep -q "(frontend)"; then
    pass "Test 21: agent_type=frontend-minion -> scope=(frontend)"
else
    fail "Test 21: agent_type=frontend-minion -> scope=(frontend)" "stderr: '$stderr21'"
fi

# --- Test 22: Multiple agent_types, clear majority -> scope = majority agent stripped ---
t22_session="test-session-t22-$$"
repo22=$(make_git_repo)
# Create a second tracked file for the second agent entry
echo "body {}" > "${repo22}/style.css"
git -C "$repo22" add style.css
git -C "$repo22" commit -q -m "add style.css"
echo "body { color: red; }" > "${repo22}/style.css"

ledger22=$(ledger_path "$t22_session")
# backend-minion appears twice, frontend-minion once -> majority = backend-minion -> scope = backend
printf '%s\t%s\n' "${repo22}/app.js" "backend-minion" > "$ledger22"
printf '%s\t%s\n' "${repo22}/style.css" "backend-minion" >> "$ledger22"
printf '%s\t%s\n' "${repo22}/app.js" "frontend-minion" >> "$ledger22"

stderr22=$(run_commit '{"session_id":"'"$t22_session"'"}' "$repo22" "$t22_session" 2>&1) || true
if echo "$stderr22" | grep -q "(backend)"; then
    pass "Test 22: Majority agent_type=backend-minion -> scope=(backend)"
else
    fail "Test 22: Majority agent_type=backend-minion -> scope=(backend)" "stderr: '$stderr22'"
fi

# --- Test 23: Tie between agents -> deterministic (alphabetical first wins) ---
t23_session="test-session-t23-$$"
repo23=$(make_git_repo)
echo "body {}" > "${repo23}/style.css"
git -C "$repo23" add style.css
git -C "$repo23" commit -q -m "add style.css"
echo "body { color: blue; }" > "${repo23}/style.css"

ledger23=$(ledger_path "$t23_session")
# alpha-minion and zeta-minion, one each -> alphabetical: alpha wins -> scope = alpha
printf '%s\t%s\n' "${repo23}/app.js" "alpha-minion" > "$ledger23"
printf '%s\t%s\n' "${repo23}/style.css" "zeta-minion" >> "$ledger23"

stderr23=$(run_commit '{"session_id":"'"$t23_session"'"}' "$repo23" "$t23_session" 2>&1) || true
if echo "$stderr23" | grep -q "(alpha)"; then
    pass "Test 23: Tie between agents -> alphabetical first (alpha) wins"
else
    fail "Test 23: Tie between agents -> alphabetical first (alpha) wins" "stderr: '$stderr23'"
fi

# --- Test 24: Agent metadata present -> Agent: trailer in checkpoint ---
t24_session="test-session-t24-$$"
repo24=$(make_git_repo)
ledger24=$(ledger_path "$t24_session")
printf '%s\t%s\t%s\n' "${repo24}/app.js" "test-minion" "sub-xyz" > "$ledger24"

stderr24=$(run_commit '{"session_id":"'"$t24_session"'"}' "$repo24" "$t24_session" 2>&1) || true
if echo "$stderr24" | grep -q "Agent: test-minion"; then
    pass "Test 24: Agent metadata present -> Agent: trailer in checkpoint"
else
    fail "Test 24: Agent metadata present -> Agent: trailer in checkpoint" "stderr: '$stderr24'"
fi

# --- Test 25: Multiple agents -> multiple Agent: trailers in checkpoint ---
t25_session="test-session-t25-$$"
repo25=$(make_git_repo)
echo "body {}" > "${repo25}/style.css"
git -C "$repo25" add style.css
git -C "$repo25" commit -q -m "add style.css"
echo "body { margin: 0; }" > "${repo25}/style.css"

ledger25=$(ledger_path "$t25_session")
printf '%s\t%s\n' "${repo25}/app.js" "alpha-minion" > "$ledger25"
printf '%s\t%s\n' "${repo25}/style.css" "beta-minion" >> "$ledger25"

stderr25=$(run_commit '{"session_id":"'"$t25_session"'"}' "$repo25" "$t25_session" 2>&1) || true
if echo "$stderr25" | grep -q "Agent: alpha-minion" && echo "$stderr25" | grep -q "Agent: beta-minion"; then
    pass "Test 25: Multiple agents -> multiple Agent: trailers"
else
    fail "Test 25: Multiple agents -> multiple Agent: trailers" "stderr: '$stderr25'"
fi

# --- Summary ---
echo ""
echo "Results: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
exit "$TESTS_FAILED"
