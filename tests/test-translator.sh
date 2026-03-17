#!/usr/bin/env bash
# tva
#
# Integration tests for lib/translate-agent-md.sh
#
# Usage: bash tests/test-translator.sh
# Exit:  0 if all tests pass, N if N tests failed

set -euo pipefail

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TRANSLATOR="$REPO_ROOT/lib/translate-agent-md.sh"
FIXTURES="$SCRIPT_DIR/fixtures/translator"

TESTS_PASSED=0
TESTS_FAILED=0

# Temp dir root -- all test temp dirs live under this path so cleanup is a single rm -rf.
TMP_ROOT="$REPO_ROOT/.test-tmp-translator"
TEMP_DIRS=()

cleanup() {
  for d in "${TEMP_DIRS[@]:-}"; do
    [[ -d "$d" ]] && rm -rf "$d"
  done
  [[ -d "$TMP_ROOT" ]] && rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$TMP_ROOT"

make_temp() {
  local d
  d=$(mktemp -d "$TMP_ROOT/XXXXXXXX")
  TEMP_DIRS+=("$d")
  echo "$d"
}

# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

pass() {
  echo "PASS: $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo "FAIL: $1 -- $2"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# ---------------------------------------------------------------------------
# Runner helper
# ---------------------------------------------------------------------------

# run_translator ARGS...
# Runs translator, captures stdout (OUT), stderr (ERR), exit code (RC),
# and output file content (TRANSLATED) from the --output path.
# Sets: OUT, ERR, RC, TRANSLATED
run_translator() {
  OUT=""
  ERR=""
  RC=0
  TRANSLATED=""

  # Extract --output value so we can read the file afterwards
  local _args=("$@")
  local _output_path=""
  local i=0
  while [ $i -lt ${#_args[@]} ]; do
    if [ "${_args[$i]}" = "--output" ]; then
      i=$((i + 1))
      _output_path="${_args[$i]}"
    fi
    i=$((i + 1))
  done

  local stderr_file
  stderr_file="$(mktemp "${TMPDIR:-/tmp}/test-translator-stderr-XXXXXX")"

  OUT=$(bash "$TRANSLATOR" "$@" 2>"$stderr_file") || RC=$?
  ERR=$(cat "$stderr_file" 2>/dev/null || true)
  rm -f "$stderr_file"

  if [ -n "$_output_path" ] && [ -f "$_output_path" ]; then
    TRANSLATED=$(cat "$_output_path")
  fi
}

# ---------------------------------------------------------------------------
# 1. Happy-path: minimal.md to both formats
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/minimal.AGENTS.md"
if [ "$RC" -eq 0 ]; then
  pass "Happy-path: minimal.md -> agents-md exits 0"
else
  fail "Happy-path: minimal.md -> agents-md exits 0" "RC=$RC ERR=$ERR"
fi

if [ -n "$TRANSLATED" ]; then
  pass "Happy-path: minimal.md -> agents-md produces non-empty output file"
else
  fail "Happy-path: minimal.md -> agents-md produces non-empty output file" "TRANSLATED empty"
fi

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format conventions-md \
  --output "$t/minimal.CONVENTIONS.md"
if [ "$RC" -eq 0 ]; then
  pass "Happy-path: minimal.md -> conventions-md exits 0"
else
  fail "Happy-path: minimal.md -> conventions-md exits 0" "RC=$RC ERR=$ERR"
fi

if [ -n "$TRANSLATED" ]; then
  pass "Happy-path: minimal.md -> conventions-md produces non-empty output file"
else
  fail "Happy-path: minimal.md -> conventions-md produces non-empty output file" "TRANSLATED empty"
fi

# ---------------------------------------------------------------------------
# 2. Frontmatter stripping: no --- lines, no YAML fields, body headings kept
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/out.md"

if ! printf '%s\n' "$TRANSLATED" | grep -q '^---'; then
  pass "Frontmatter stripping: output contains no '---' lines"
else
  fail "Frontmatter stripping: output contains no '---' lines" "found --- in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q '^name:'; then
  pass "Frontmatter stripping: output contains no 'name:' YAML field"
else
  fail "Frontmatter stripping: output contains no 'name:' YAML field" "found name: in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q '^tools:'; then
  pass "Frontmatter stripping: output contains no 'tools:' YAML field"
else
  fail "Frontmatter stripping: output contains no 'tools:' YAML field" "found tools: in output"
fi

if printf '%s\n' "$TRANSLATED" | grep -q '^# Identity'; then
  pass "Frontmatter stripping: body heading '# Identity' preserved in output"
else
  fail "Frontmatter stripping: body heading '# Identity' preserved in output" "not found in: $TRANSLATED"
fi

# ---------------------------------------------------------------------------
# 3. Frontmatter JSON extraction: correct name, model, tools, description
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/out.md"

fm_name=$(printf '%s' "$OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('name',''))" 2>/dev/null || true)
if [ "$fm_name" = "test-agent" ]; then
  pass "Frontmatter JSON: name field is 'test-agent'"
else
  fail "Frontmatter JSON: name field is 'test-agent'" "got: $fm_name (OUT=$OUT)"
fi

fm_model=$(printf '%s' "$OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('model',''))" 2>/dev/null || true)
if [ "$fm_model" = "sonnet" ]; then
  pass "Frontmatter JSON: model field is 'sonnet'"
else
  fail "Frontmatter JSON: model field is 'sonnet'" "got: $fm_model"
fi

fm_tools=$(printf '%s' "$OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tools',''))" 2>/dev/null || true)
if [ "$fm_tools" = "Read, Write, Edit" ]; then
  pass "Frontmatter JSON: tools field is 'Read, Write, Edit'"
else
  fail "Frontmatter JSON: tools field is 'Read, Write, Edit'" "got: $fm_tools"
fi

# Multiline folded scalar description is flattened to a single string
t=$(make_temp)
run_translator \
  --agent-md "$FIXTURES/multiline-description.md" \
  --format agents-md \
  --output "$t/out.md"
fm_desc=$(printf '%s' "$OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('description',''))" 2>/dev/null || true)
if printf '%s' "$fm_desc" | grep -q "multiline folded scalar"; then
  pass "Frontmatter JSON: multiline description folded scalar flattened to single string"
else
  fail "Frontmatter JSON: multiline description folded scalar flattened to single string" "got: $fm_desc"
fi

# ---------------------------------------------------------------------------
# 4. Claude Code stripping: with-claude-refs.md
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/with-claude-refs.md" \
  --format agents-md \
  --output "$t/out.md"

if ! printf '%s\n' "$TRANSLATED" | grep -q 'TaskUpdate'; then
  pass "Claude Code stripping: TaskUpdate removed from output"
else
  fail "Claude Code stripping: TaskUpdate removed from output" "found TaskUpdate in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q 'SendMessage'; then
  pass "Claude Code stripping: SendMessage removed from output"
else
  fail "Claude Code stripping: SendMessage removed from output" "found SendMessage in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q 'TeamCreate'; then
  pass "Claude Code stripping: TeamCreate removed from output"
else
  fail "Claude Code stripping: TeamCreate removed from output" "found TeamCreate in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q 'nefario-scratch-'; then
  pass "Claude Code stripping: nefario-scratch-* reference removed from output"
else
  fail "Claude Code stripping: nefario-scratch-* reference removed from output" "found nefario-scratch- in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q '@domain:'; then
  pass "Claude Code stripping: @domain: markers removed from output"
else
  fail "Claude Code stripping: @domain: markers removed from output" "found @domain: in output"
fi

if ! printf '%s\n' "$TRANSLATED" | grep -q '^## Main Agent Mode'; then
  pass "Claude Code stripping: ## Main Agent Mode section removed from output"
else
  fail "Claude Code stripping: ## Main Agent Mode section removed from output" "found ## Main Agent Mode in output"
fi

# Legitimate content that must NOT be stripped
if printf '%s\n' "$TRANSLATED" | grep -q 'CLAUDE.md'; then
  pass "Claude Code stripping: CLAUDE.md reference preserved in output"
else
  fail "Claude Code stripping: CLAUDE.md reference preserved in output" "CLAUDE.md missing from output"
fi

if printf '%s\n' "$TRANSLATED" | grep -q 'building from scratch'; then
  pass "Claude Code stripping: 'building from scratch' phrase preserved in output"
else
  fail "Claude Code stripping: 'building from scratch' phrase preserved in output" "phrase missing from output"
fi

if printf '%s\n' "$TRANSLATED" | grep -q 'standalone Task description'; then
  pass "Claude Code stripping: standalone 'Task' word preserved in output"
else
  fail "Claude Code stripping: standalone 'Task' word preserved in output" "standalone Task missing from output"
fi

# ---------------------------------------------------------------------------
# 5. Golden-file regression
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/minimal-agents.md"
if diff -q "$FIXTURES/golden-minimal.agents-md.md" "$t/minimal-agents.md" >/dev/null 2>&1; then
  pass "Golden regression: minimal.md -> agents-md matches golden file"
else
  fail "Golden regression: minimal.md -> agents-md matches golden file" "$(diff "$FIXTURES/golden-minimal.agents-md.md" "$t/minimal-agents.md" | head -10)"
fi

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format conventions-md \
  --output "$t/minimal-conv.md"
if diff -q "$FIXTURES/golden-minimal.conventions-md.md" "$t/minimal-conv.md" >/dev/null 2>&1; then
  pass "Golden regression: minimal.md -> conventions-md matches golden file"
else
  fail "Golden regression: minimal.md -> conventions-md matches golden file" "$(diff "$FIXTURES/golden-minimal.conventions-md.md" "$t/minimal-conv.md" | head -10)"
fi

run_translator \
  --agent-md "$FIXTURES/with-claude-refs.md" \
  --format agents-md \
  --output "$t/refs-agents.md"
if diff -q "$FIXTURES/golden-with-claude-refs.agents-md.md" "$t/refs-agents.md" >/dev/null 2>&1; then
  pass "Golden regression: with-claude-refs.md -> agents-md matches golden file"
else
  fail "Golden regression: with-claude-refs.md -> agents-md matches golden file" "$(diff "$FIXTURES/golden-with-claude-refs.agents-md.md" "$t/refs-agents.md" | head -10)"
fi

# ---------------------------------------------------------------------------
# 6. Edge cases
# ---------------------------------------------------------------------------

# frontmatter-only.md: empty body -> exit 1
t=$(make_temp)
run_translator \
  --agent-md "$FIXTURES/frontmatter-only.md" \
  --format agents-md \
  --output "$t/out.md"
if [ "$RC" -eq 1 ]; then
  pass "Edge case: frontmatter-only.md (empty body) exits 1"
else
  fail "Edge case: frontmatter-only.md (empty body) exits 1" "RC=$RC"
fi

# no-frontmatter.md: body passes through, stdout is {}
t=$(make_temp)
run_translator \
  --agent-md "$FIXTURES/no-frontmatter.md" \
  --format agents-md \
  --output "$t/out.md"
if [ "$RC" -eq 0 ]; then
  pass "Edge case: no-frontmatter.md exits 0"
else
  fail "Edge case: no-frontmatter.md exits 0" "RC=$RC ERR=$ERR"
fi
if [ "$OUT" = "{}" ]; then
  pass "Edge case: no-frontmatter.md emits '{}' on stdout"
else
  fail "Edge case: no-frontmatter.md emits '{}' on stdout" "OUT=$OUT"
fi
if printf '%s\n' "$TRANSLATED" | grep -q '# Plain Instructions'; then
  pass "Edge case: no-frontmatter.md body passed through to output"
else
  fail "Edge case: no-frontmatter.md body passed through to output" "TRANSLATED=$TRANSLATED"
fi

# Output file permissions are 0600
t=$(make_temp)
run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/out.md"
perms=$(stat -f "%Lp" "$t/out.md" 2>/dev/null || stat --format="%a" "$t/out.md" 2>/dev/null || true)
if [ "$perms" = "600" ]; then
  pass "Edge case: output file has restricted permissions (0600)"
else
  fail "Edge case: output file has restricted permissions (0600)" "perms=$perms"
fi

# ---------------------------------------------------------------------------
# 7. Error / usage
# ---------------------------------------------------------------------------

# Missing --agent-md exits 2
t=$(make_temp)
run_translator --format agents-md --output "$t/out.md"
if [ "$RC" -eq 2 ]; then
  pass "Error/usage: missing --agent-md exits 2"
else
  fail "Error/usage: missing --agent-md exits 2" "RC=$RC"
fi

# Missing --format exits 2
t=$(make_temp)
run_translator --agent-md "$FIXTURES/minimal.md" --output "$t/out.md"
if [ "$RC" -eq 2 ]; then
  pass "Error/usage: missing --format exits 2"
else
  fail "Error/usage: missing --format exits 2" "RC=$RC"
fi

# Invalid --format exits 2
t=$(make_temp)
run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format bad-format \
  --output "$t/out.md"
if [ "$RC" -eq 2 ]; then
  pass "Error/usage: invalid --format value exits 2"
else
  fail "Error/usage: invalid --format value exits 2" "RC=$RC"
fi

# Nonexistent --agent-md exits 1
t=$(make_temp)
run_translator \
  --agent-md "$t/does-not-exist.md" \
  --format agents-md \
  --output "$t/out.md"
if [ "$RC" -eq 1 ]; then
  pass "Error/usage: nonexistent --agent-md exits 1"
else
  fail "Error/usage: nonexistent --agent-md exits 1" "RC=$RC"
fi

# ---------------------------------------------------------------------------
# 8. Idempotency: running twice produces identical output
# ---------------------------------------------------------------------------

t=$(make_temp)

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/run1.md"
sum1=$(md5 -q "$t/run1.md" 2>/dev/null || md5sum "$t/run1.md" 2>/dev/null | awk '{print $1}')

run_translator \
  --agent-md "$FIXTURES/minimal.md" \
  --format agents-md \
  --output "$t/run2.md"
sum2=$(md5 -q "$t/run2.md" 2>/dev/null || md5sum "$t/run2.md" 2>/dev/null | awk '{print $1}')

if [ "$sum1" = "$sum2" ]; then
  pass "Idempotency: translating minimal.md twice produces identical output checksums"
else
  fail "Idempotency: translating minimal.md twice produces identical output checksums" "sum1=$sum1 sum2=$sum2"
fi

# ---------------------------------------------------------------------------
# 9. Corpus smoke: translate all real AGENT.md files
# ---------------------------------------------------------------------------

echo ""
echo "--- Corpus smoke test ---"

t=$(make_temp)
corpus_ok=0
corpus_fail=0

while IFS= read -r agent_md; do
  out="$t/$(basename "$(dirname "$agent_md")").md"
  RC_corp=0
  stderr_corp="$(mktemp "${TMPDIR:-/tmp}/test-translator-corpus-XXXXXX")"
  bash "$TRANSLATOR" \
    --agent-md "$agent_md" \
    --format agents-md \
    --output "$out" \
    >"$t/stdout-corp" 2>"$stderr_corp" || RC_corp=$?
  err_corp="$(cat "$stderr_corp")"
  rm -f "$stderr_corp"

  if [ "$RC_corp" -eq 0 ]; then
    corpus_ok=$((corpus_ok + 1))
    agent_name="$(basename "$(dirname "$agent_md")")"

    # No residual frontmatter: first three lines must not be '---'
    # (body may contain '---' as Markdown horizontal rules, which is legitimate)
    line1="$(sed -n '1p' "$out" 2>/dev/null || true)"
    line2="$(sed -n '2p' "$out" 2>/dev/null || true)"
    line3="$(sed -n '3p' "$out" 2>/dev/null || true)"
    if [ "$line1" = "---" ] || [ "$line2" = "---" ] || [ "$line3" = "---" ]; then
      fail "Corpus smoke: $agent_name output starts with residual frontmatter" "first lines: '$line1' '$line2' '$line3'"
      corpus_fail=$((corpus_fail + 1))
    fi

    # No residual Claude Code tool tokens (narrow patterns only -- not bare "Task" or "scratch")
    for tok in TaskUpdate SendMessage TeamCreate TaskList TaskCreate TeamUpdate AskUserQuestion; do
      if grep -q "$tok" "$out" 2>/dev/null; then
        fail "Corpus smoke: $agent_name output contains residual token '$tok'" "in $out"
        corpus_fail=$((corpus_fail + 1))
      fi
    done

    # No residual @domain markers
    if grep -q '@domain:' "$out" 2>/dev/null; then
      fail "Corpus smoke: $agent_name output contains residual @domain marker" "in $out"
      corpus_fail=$((corpus_fail + 1))
    fi

    # No nefario-scratch-XXXXX patterns
    if grep -q 'nefario-scratch-[A-Za-z0-9]' "$out" 2>/dev/null; then
      fail "Corpus smoke: $agent_name output contains residual nefario-scratch- pattern" "in $out"
      corpus_fail=$((corpus_fail + 1))
    fi

  else
    fail "Corpus smoke: $(basename "$(dirname "$agent_md")") failed translation unexpectedly" "RC=$RC_corp ERR=$err_corp"
    corpus_fail=$((corpus_fail + 1))
  fi
done < <(find "$REPO_ROOT" -name "AGENT.md" -not -path "*/node_modules/*" | sort)

pass "Corpus smoke: $corpus_ok agents translated cleanly"

if [ "$corpus_fail" -gt 0 ]; then
  fail "Corpus smoke: $corpus_fail unexpected failures (see individual FAIL lines above)" ""
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Results: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
exit "$TESTS_FAILED"
