#!/usr/bin/env bash
# tva
#
# Integration tests for lib/load-routing-config.sh
#
# Usage: bash tests/test-routing-config.sh
# Exit:  0 if all tests pass, N if N tests failed

set -euo pipefail

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOADER="$REPO_ROOT/lib/load-routing-config.sh"
FIXTURES="$SCRIPT_DIR/fixtures/routing"

# Real agent dir: repo root, where all AGENT.md files live
REAL_AGENT_DIR="$REPO_ROOT"

TESTS_PASSED=0
TESTS_FAILED=0

# Temp dir roots -- must be inside their respective expected roots:
#   project config: must be under REPO_ROOT
#   user config:    must be under HOME
PROJ_TMP_ROOT="$REPO_ROOT/.test-tmp-routing"
USER_TMP_ROOT="$HOME/.test-tmp-routing"

PROJ_TEMP_DIRS=()
USER_TEMP_DIRS=()
AGENT_TEMP_DIRS=()

cleanup() {
  for d in "${PROJ_TEMP_DIRS[@]:-}"; do
    [[ -d "$d" ]] && rm -rf "$d"
  done
  for d in "${USER_TEMP_DIRS[@]:-}"; do
    [[ -d "$d" ]] && rm -rf "$d"
  done
  for d in "${AGENT_TEMP_DIRS[@]:-}"; do
    [[ -d "$d" ]] && rm -rf "$d"
  done
  [[ -d "$PROJ_TMP_ROOT" ]] && rm -rf "$PROJ_TMP_ROOT"
  [[ -d "$USER_TMP_ROOT" ]] && rm -rf "$USER_TMP_ROOT"
}
trap cleanup EXIT

mkdir -p "$PROJ_TMP_ROOT"
mkdir -p "$USER_TMP_ROOT"

# make_project_temp -- temp dir for project config files (inside REPO_ROOT)
make_project_temp() {
  local d
  d=$(mktemp -d "$PROJ_TMP_ROOT/XXXXXXXX")
  PROJ_TEMP_DIRS+=("$d")
  echo "$d"
}

# make_user_temp -- temp dir for user config files (inside HOME)
make_user_temp() {
  local d
  d=$(mktemp -d "$USER_TMP_ROOT/XXXXXXXX")
  USER_TEMP_DIRS+=("$d")
  echo "$d"
}

# make_agent_temp -- temp dir for mock AGENT.md files (no path restriction)
make_agent_temp() {
  local d
  d=$(mktemp -d)
  AGENT_TEMP_DIRS+=("$d")
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
# Runner helpers
# ---------------------------------------------------------------------------

# run_loader ARGS...
# Runs loader, captures stdout, stderr, and exit code.
# Sets: OUT, ERR, RC
run_loader() {
  OUT=""
  ERR=""
  RC=0
  OUT=$(bash "$LOADER" "$@" 2>/tmp/test-routing-stderr-$$ ) || RC=$?
  ERR=$(cat /tmp/test-routing-stderr-$$ 2>/dev/null || true)
  rm -f /tmp/test-routing-stderr-$$
}

# make_mock_agent_dir -- creates a temp dir with minimal AGENT.md mocks.
# Creates three agents:
#   web-agent      -- tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch
#   basic-agent    -- tools: Read, Write, Edit
#   no-tools-agent -- no tools: field (implies ALL)
make_mock_agent_dir() {
  local d
  d=$(make_agent_temp)

  mkdir -p "$d/web-agent"
  cat > "$d/web-agent/AGENT.md" <<'FRONTMATTER'
---
name: web-agent
description: Mock agent requiring web access
tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch
model: sonnet
---

Mock web agent body.
FRONTMATTER

  mkdir -p "$d/basic-agent"
  cat > "$d/basic-agent/AGENT.md" <<'FRONTMATTER'
---
name: basic-agent
description: Mock agent with minimal tools
tools: Read, Write, Edit
model: sonnet
---

Mock basic agent body.
FRONTMATTER

  mkdir -p "$d/no-tools-agent"
  cat > "$d/no-tools-agent/AGENT.md" <<'FRONTMATTER'
---
name: no-tools-agent
description: Mock agent with no tools field (implies ALL)
model: sonnet
---

Mock no-tools agent body.
FRONTMATTER

  echo "$d"
}

# write_project_config LABEL CONTENT -- writes config to a project temp dir, returns path
write_project_config() {
  local label="$1"
  local content="$2"
  local d
  d=$(make_project_temp)
  local f="$d/${label}.yml"
  printf '%s\n' "$content" > "$f"
  echo "$f"
}

# write_user_config LABEL CONTENT -- writes config to a user temp dir, returns path
write_user_config() {
  local label="$1"
  local content="$2"
  local d
  d=$(make_user_temp)
  local f="$d/${label}.yml"
  printf '%s\n' "$content" > "$f"
  echo "$f"
}

# ---------------------------------------------------------------------------
# AC4: Zero-config defaults to claude-code
# ---------------------------------------------------------------------------

# Zero-config only fires when the DEFAULT project config path ($SCRIPT_DIR/../.nefario/routing.yml)
# doesn't exist. We test with a temp copy of the loader in a fresh temp dir so its
# derived PROJECT_ROOT has no .nefario/routing.yml.
t_zc_loader=$(make_agent_temp)
cp "$LOADER" "$t_zc_loader/load-routing-config.sh"
RC=0
OUT=$(bash "$t_zc_loader/load-routing-config.sh" 2>/dev/null) || RC=$?
if [ "$RC" -eq 0 ] && echo "$OUT" | grep -q '"default":"claude-code"'; then
  if echo "$OUT" | grep -q '"groups":{}'; then
    pass "AC4: Zero-config (no routing.yml) emits default JSON and exits 0"
  else
    fail "AC4: Zero-config (no routing.yml) emits default JSON and exits 0" "JSON: $OUT"
  fi
else
  fail "AC4: Zero-config (no routing.yml) emits default JSON and exits 0" "RC=$RC OUT=$OUT"
fi

# Verify zero-config JSON has all four keys
if echo "$OUT" | jq -e 'has("default") and has("groups") and has("agents") and has("model-mapping")' >/dev/null 2>&1; then
  pass "AC4b: Zero-config JSON contains all four top-level keys"
else
  fail "AC4b: Zero-config JSON contains all four top-level keys" "JSON: $OUT"
fi

# ---------------------------------------------------------------------------
# AC1: Minimal config loads without error
# ---------------------------------------------------------------------------

t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/minimal.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 0 ]; then
  pass "AC1: Minimal config (default: claude-code) loads without error"
else
  fail "AC1: Minimal config (default: claude-code) loads without error" "RC=$RC ERR=$ERR"
fi

# Minimal config stdout is valid JSON
if echo "$OUT" | jq -e . >/dev/null 2>&1; then
  pass "AC1b: Minimal config output is valid JSON"
else
  fail "AC1b: Minimal config output is valid JSON" "OUT=$OUT"
fi

# Minimal config default field is claude-code
default_val=$(echo "$OUT" | jq -r '.default' 2>/dev/null || true)
if [ "$default_val" = "claude-code" ]; then
  pass "AC1c: Minimal config default field is claude-code"
else
  fail "AC1c: Minimal config default field is claude-code" "default=$default_val"
fi

# ---------------------------------------------------------------------------
# Valid fixture tests
# ---------------------------------------------------------------------------

# default-codex.yml: default=codex, exits 0
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/default-codex.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 0 ]; then
  dv=$(echo "$OUT" | jq -r '.default' 2>/dev/null || true)
  if [ "$dv" = "codex" ]; then
    pass "default-codex.yml: loads and default=codex"
  else
    fail "default-codex.yml: loads and default=codex" "default=$dv"
  fi
else
  fail "default-codex.yml: loads and default=codex" "RC=$RC ERR=$ERR"
fi

# groups block: governance->codex succeeds (lucy/margo tools are codex-compatible)
# lucy tools: Read, Glob, Grep, Write, Edit -- all supported by codex.
cfg=$(write_project_config "groups-governance-codex" \
"default: codex

groups:
  governance: codex")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 0 ]; then
  grp=$(echo "$OUT" | jq -r '.groups.governance' 2>/dev/null || true)
  if [ "$grp" = "codex" ]; then
    pass "groups block: governance->codex loads, groups.governance=codex in output"
  else
    fail "groups block: governance->codex loads, groups.governance=codex in output" "groups=$OUT"
  fi
else
  fail "groups block: governance->codex loads without capability error" "RC=$RC ERR=$ERR"
fi

# with-groups.yml: governance->aider fails (lucy/margo need Glob+Grep, aider doesn't support them)
run_loader \
  --project-config "$FIXTURES/with-groups.yml" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 1 ]; then
  pass "with-groups.yml: governance->aider fails capability check (Glob+Grep unsupported by aider)"
else
  fail "with-groups.yml: governance->aider fails capability check" "RC=$RC OUT=$OUT ERR=$ERR"
fi

# agents block: basic-agent->aider succeeds (Read,Write,Edit all supported by aider)
t_mock_dir=$(make_mock_agent_dir)
cfg=$(write_project_config "basic-to-aider" \
"default: claude-code

agents:
  basic-agent: aider")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_mock_dir"
if [ "$RC" -eq 0 ]; then
  av=$(echo "$OUT" | jq -r '.agents["basic-agent"]' 2>/dev/null || true)
  if [ "$av" = "aider" ]; then
    pass "agents block: basic-agent->aider loads, agents[basic-agent]=aider in output"
  else
    fail "agents block: basic-agent->aider loads, agents[basic-agent]=aider in output" "agents=$OUT"
  fi
else
  fail "agents block: basic-agent->aider (aider-safe tools) loads without error" "RC=$RC ERR=$ERR"
fi

# with-agents.yml: lucy->aider fails (lucy has Glob+Grep, aider doesn't support them)
run_loader \
  --project-config "$FIXTURES/with-agents.yml" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 1 ]; then
  pass "with-agents.yml: lucy/margo->aider fails capability check (Glob+Grep unsupported by aider)"
else
  fail "with-agents.yml: lucy/margo->aider fails capability check" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# AC2: Power-user config loads without error, resolution order verified
# ---------------------------------------------------------------------------

# All four sections: default=codex, groups.governance=codex, agents.lucy=claude-code, model-mapping
# lucy is in governance (->codex via group), but agents.lucy=claude-code overrides.
cfg=$(write_project_config "full-power-user" \
"default: codex

groups:
  governance: codex

agents:
  lucy: claude-code

model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 0 ]; then
  pass "AC2: Power-user config (all four sections) loads without error"
else
  fail "AC2: Power-user config (all four sections) loads without error" "RC=$RC ERR=$ERR"
fi

# AC2: All four top-level keys present in output
if echo "$OUT" | jq -e 'has("default") and has("groups") and has("agents") and has("model-mapping")' >/dev/null 2>&1; then
  pass "AC2b: Power-user config output contains all four top-level keys"
else
  fail "AC2b: Power-user config output contains all four top-level keys" "JSON: $OUT"
fi

# AC2: Resolution order data in output: agent override > group > default
a_lucy=$(echo "$OUT" | jq -r '.agents.lucy' 2>/dev/null || true)
g_gov=$(echo "$OUT" | jq -r '.groups.governance' 2>/dev/null || true)
d_val=$(echo "$OUT" | jq -r '.default' 2>/dev/null || true)
if [ "$a_lucy" = "claude-code" ] && [ "$g_gov" = "codex" ] && [ "$d_val" = "codex" ]; then
  pass "AC2c: Resolution order data correct -- agents.lucy=claude-code, groups.governance=codex, default=codex"
else
  fail "AC2c: Resolution order data correct" "lucy=$a_lucy governance=$g_gov default=$d_val"
fi

# AC2: Model mapping preserved in output
mm_codex_opus=$(echo "$OUT" | jq -r '."model-mapping".codex.opus' 2>/dev/null || true)
if [ "$mm_codex_opus" = "o3" ]; then
  pass "AC2d: Model mapping preserved in output (codex.opus=o3)"
else
  fail "AC2d: Model mapping preserved in output (codex.opus=o3)" "got=$mm_codex_opus"
fi

# ---------------------------------------------------------------------------
# AC3: Capability gating rejects bad routing
# ---------------------------------------------------------------------------

# AC3: WebSearch agent (test-minion) routed to aider -> fails
run_loader \
  --project-config "$FIXTURES/bad-capability.yml" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 1 ]; then
  pass "AC3: Capability gating rejects test-minion->aider (WebSearch unsupported)"
else
  fail "AC3: Capability gating rejects test-minion->aider (WebSearch unsupported)" "RC=$RC ERR=$ERR"
fi

# AC3: Error message names the agent
if echo "$ERR" | grep -q "test-minion"; then
  pass "AC3b: Capability error message names the offending agent (test-minion)"
else
  fail "AC3b: Capability error message names the offending agent (test-minion)" "ERR=$ERR"
fi

# AC3: Error message names an unsupported tool
if echo "$ERR" | grep -q "WebSearch" || echo "$ERR" | grep -q "WebFetch"; then
  pass "AC3c: Capability error message names unsupported tools"
else
  fail "AC3c: Capability error message names unsupported tools" "ERR=$ERR"
fi

# AC3: Error message names the target harness
if echo "$ERR" | grep -q "aider"; then
  pass "AC3d: Capability error message names the target harness (aider)"
else
  fail "AC3d: Capability error message names the target harness (aider)" "ERR=$ERR"
fi

# Capability: web-agent->codex fails (WebSearch not in codex caps)
t_cap_dir=$(make_mock_agent_dir)
cfg=$(write_project_config "web-to-codex" \
"default: claude-code

agents:
  web-agent: codex")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_cap_dir"
if [ "$RC" -eq 1 ]; then
  pass "Capability gating: web-agent->codex fails (WebSearch unsupported by codex)"
else
  fail "Capability gating: web-agent->codex fails (WebSearch unsupported by codex)" "RC=$RC ERR=$ERR"
fi

# Capability: no-tools-agent->aider fails (ALL tools implied, aider lacks most)
cfg=$(write_project_config "notools-to-aider" \
"default: claude-code

agents:
  no-tools-agent: aider")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_cap_dir"
if [ "$RC" -eq 1 ]; then
  pass "Capability gating: no-tools-agent (ALL tools implied)->aider fails"
else
  fail "Capability gating: no-tools-agent (ALL tools implied)->aider fails" "RC=$RC ERR=$ERR"
fi

# Capability: basic-agent (Read,Write,Edit)->codex succeeds
cfg=$(write_project_config "basic-to-codex" \
"default: claude-code

agents:
  basic-agent: codex")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_cap_dir"
if [ "$RC" -eq 0 ]; then
  pass "Capability gating: basic-agent (Read,Write,Edit)->codex succeeds"
else
  fail "Capability gating: basic-agent (Read,Write,Edit)->codex succeeds" "RC=$RC ERR=$ERR"
fi

# Capability: no-tools-agent->claude-code bypasses capability check (claude-code skipped per loader logic)
cfg=$(write_project_config "notools-to-claude-code" \
"default: claude-code

agents:
  no-tools-agent: claude-code")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_cap_dir"
if [ "$RC" -eq 0 ]; then
  pass "Capability gating: no-tools-agent->claude-code bypasses capability check"
else
  fail "Capability gating: no-tools-agent->claude-code bypasses capability check" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# Validation error tests
# ---------------------------------------------------------------------------

# malformed.yml: YAML syntax error -> exit 1, stderr mentions parse failure
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/malformed.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "malformed.yml: YAML syntax error exits 1"
else
  fail "malformed.yml: YAML syntax error exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -qi "syntax\|parse\|error"; then
  pass "malformed.yml: Error message mentions parse failure"
else
  fail "malformed.yml: Error message mentions parse failure" "ERR=$ERR"
fi

# missing-default.yml: no default field -> exit 1, mentions 'default'
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/missing-default.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "missing-default.yml: Missing default field exits 1"
else
  fail "missing-default.yml: Missing default field exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -q "default"; then
  pass "missing-default.yml: Error mentions 'default' field"
else
  fail "missing-default.yml: Error mentions 'default' field" "ERR=$ERR"
fi

# empty-file.yml: empty config -> treated as missing default -> exit 1
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/empty-file.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "empty-file.yml: Empty config file exits 1"
else
  fail "empty-file.yml: Empty config file exits 1" "RC=$RC ERR=$ERR"
fi

# unknown-harness.yml: default: does-not-exist -> exit 1, names bad harness, lists valid
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/unknown-harness.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "unknown-harness.yml: Unknown harness in default exits 1"
else
  fail "unknown-harness.yml: Unknown harness in default exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -q "does-not-exist"; then
  pass "unknown-harness.yml: Error names the bad harness value"
else
  fail "unknown-harness.yml: Error names the bad harness value" "ERR=$ERR"
fi

if echo "$ERR" | grep -q "claude-code"; then
  pass "unknown-harness.yml: Error lists valid harnesses"
else
  fail "unknown-harness.yml: Error lists valid harnesses" "ERR=$ERR"
fi

# unknown-harness-agent.yml: valid default, agent with bad harness -> exit 1, names bad harness
run_loader \
  --project-config "$FIXTURES/unknown-harness-agent.yml" \
  --agent-dir "$REAL_AGENT_DIR"
if [ "$RC" -eq 1 ]; then
  pass "unknown-harness-agent.yml: Unknown harness in agents block exits 1"
else
  fail "unknown-harness-agent.yml: Unknown harness in agents block exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -q "bad-harness"; then
  pass "unknown-harness-agent.yml: Error names the bad harness value"
else
  fail "unknown-harness-agent.yml: Error names the bad harness value" "ERR=$ERR"
fi

# unknown-group.yml: groups.code-writers -> exit 1, names bad group, lists valid IDs
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/unknown-group.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "unknown-group.yml: Unknown group name exits 1"
else
  fail "unknown-group.yml: Unknown group name exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -q "code-writers"; then
  pass "unknown-group.yml: Error names the bad group"
else
  fail "unknown-group.yml: Error names the bad group" "ERR=$ERR"
fi

if echo "$ERR" | grep -q "governance\|boss\|web-quality"; then
  pass "unknown-group.yml: Error lists valid group IDs"
else
  fail "unknown-group.yml: Error lists valid group IDs" "ERR=$ERR"
fi

# bad-model-id.yml: model ID with shell metacharacters -> exit 1
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/bad-model-id.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "bad-model-id.yml: Invalid model ID with shell chars exits 1"
else
  fail "bad-model-id.yml: Invalid model ID with shell chars exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -qi "model\|invalid\|character"; then
  pass "bad-model-id.yml: Error mentions invalid model ID"
else
  fail "bad-model-id.yml: Error mentions invalid model ID" "ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# --resolve subcommand tests
# ---------------------------------------------------------------------------

t_res_dir=$(make_mock_agent_dir)

# --resolve: default path -- web-agent has no override, resolves to default (codex)
cfg=$(write_project_config "resolve-default" \
"default: codex

agents:
  basic-agent: aider")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve web-agent
if [ "$RC" -eq 0 ]; then
  h=$(echo "$OUT" | jq -r '.harness' 2>/dev/null || true)
  if [ "$h" = "codex" ]; then
    pass "--resolve: web-agent with no override resolves to default (codex)"
  else
    fail "--resolve: web-agent with no override resolves to default (codex)" "harness=$h"
  fi
else
  fail "--resolve: web-agent with no override resolves to default (codex)" "RC=$RC ERR=$ERR"
fi

# --resolve: agent override wins over default
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve basic-agent
if [ "$RC" -eq 0 ]; then
  h=$(echo "$OUT" | jq -r '.harness' 2>/dev/null || true)
  if [ "$h" = "aider" ]; then
    pass "--resolve: basic-agent with agent override resolves to aider (agent > default)"
  else
    fail "--resolve: basic-agent with agent override resolves to aider (agent > default)" "harness=$h"
  fi
else
  fail "--resolve: basic-agent with agent override resolves to aider (agent > default)" "RC=$RC ERR=$ERR"
fi

# --resolve: --tier opus vs --tier sonnet return different model IDs
cfg=$(write_project_config "tier-test" "default: claude-code")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve web-agent \
  --tier opus
opus_model=$(echo "$OUT" | jq -r '.model' 2>/dev/null || true)

run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve web-agent \
  --tier sonnet
sonnet_model=$(echo "$OUT" | jq -r '.model' 2>/dev/null || true)

if [ "$opus_model" != "$sonnet_model" ] && [ -n "$opus_model" ] && [ -n "$sonnet_model" ]; then
  pass "--resolve --tier: opus and sonnet return different model IDs ($opus_model vs $sonnet_model)"
else
  fail "--resolve --tier: opus and sonnet return different model IDs" "opus=$opus_model sonnet=$sonnet_model"
fi

# --resolve: model-mapping overrides default model IDs
cfg=$(write_project_config "model-mapping-resolve" \
"default: codex

model-mapping:
  codex:
    opus: custom-opus-model
    sonnet: custom-sonnet-model")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve web-agent \
  --tier opus
if [ "$RC" -eq 0 ]; then
  m=$(echo "$OUT" | jq -r '.model' 2>/dev/null || true)
  if [ "$m" = "custom-opus-model" ]; then
    pass "--resolve: model-mapping.codex.opus overrides default model ID"
  else
    fail "--resolve: model-mapping.codex.opus overrides default model ID" "model=$m"
  fi
else
  fail "--resolve: model-mapping.codex.opus overrides default model ID" "RC=$RC ERR=$ERR"
fi

# --resolve: unknown agent exits 1
cfg=$(write_project_config "unknown-agent-resolve" "default: claude-code")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve does-not-exist-agent
if [ "$RC" -eq 1 ]; then
  pass "--resolve: unknown agent name exits 1"
else
  fail "--resolve: unknown agent name exits 1" "RC=$RC ERR=$ERR"
fi

if echo "$ERR" | grep -q "does-not-exist-agent\|Unknown agent"; then
  pass "--resolve: unknown agent error message names the agent"
else
  fail "--resolve: unknown agent error message names the agent" "ERR=$ERR"
fi

# --resolve: output JSON contains harness and model fields
cfg=$(write_project_config "struct-test" "default: claude-code")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve basic-agent
if [ "$RC" -eq 0 ]; then
  if echo "$OUT" | jq -e 'has("harness") and has("model")' >/dev/null 2>&1; then
    pass "--resolve: output JSON contains harness and model fields"
  else
    fail "--resolve: output JSON contains harness and model fields" "OUT=$OUT"
  fi
else
  fail "--resolve: exits 0 for known agent" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# Resolution order tests
# ---------------------------------------------------------------------------

# Group > default: lucy is in governance group. governance=codex -> lucy resolves to codex (not default claude-code)
cfg=$(write_project_config "group-order" \
"default: claude-code

groups:
  governance: codex")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$REAL_AGENT_DIR" \
  --resolve lucy
if [ "$RC" -eq 0 ]; then
  h=$(echo "$OUT" | jq -r '.harness' 2>/dev/null || true)
  if [ "$h" = "codex" ]; then
    pass "Resolution order: group override > default (lucy via governance->codex)"
  else
    fail "Resolution order: group override > default (lucy via governance->codex)" "harness=$h"
  fi
else
  fail "Resolution order: group override > default (lucy via governance->codex)" "RC=$RC ERR=$ERR"
fi

# Agent > group: lucy in governance->codex but agents.lucy=claude-code -> claude-code wins
cfg=$(write_project_config "agent-wins" \
"default: codex

groups:
  governance: codex

agents:
  lucy: claude-code")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$REAL_AGENT_DIR" \
  --resolve lucy
if [ "$RC" -eq 0 ]; then
  h=$(echo "$OUT" | jq -r '.harness' 2>/dev/null || true)
  if [ "$h" = "claude-code" ]; then
    pass "Resolution order: agent override > group (agents.lucy=claude-code wins over governance->codex)"
  else
    fail "Resolution order: agent override > group (agents.lucy=claude-code wins over governance->codex)" "harness=$h"
  fi
else
  fail "Resolution order: agent override > group resolves correctly" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# Edge cases
# ---------------------------------------------------------------------------

# empty-groups.yml: empty groups block loads without error
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/empty-groups.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 0 ]; then
  pass "empty-groups.yml: Empty groups block loads without error"
else
  fail "empty-groups.yml: Empty groups block loads without error" "RC=$RC ERR=$ERR"
fi

# partial-model-mapping.yml: only codex mapped, others use defaults -> exits 0
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/partial-model-mapping.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 0 ]; then
  pass "partial-model-mapping.yml: Partial model-mapping (codex only) loads without error"
else
  fail "partial-model-mapping.yml: Partial model-mapping (codex only) loads without error" "RC=$RC ERR=$ERR"
fi

# --resolve with partial model-mapping: unmapped harness uses hardcoded default
cfg=$(write_project_config "partial-mm-resolve" \
"default: claude-code

model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini")
run_loader \
  --project-config "$cfg" \
  --agent-dir "$t_res_dir" \
  --resolve basic-agent \
  --tier sonnet
if [ "$RC" -eq 0 ]; then
  m=$(echo "$OUT" | jq -r '.model' 2>/dev/null || true)
  # claude-code (default harness) has no model-mapping -> uses hardcoded default claude-sonnet-4-5
  if [ -n "$m" ]; then
    pass "partial-model-mapping: unmapped harness (claude-code) returns hardcoded default model ($m)"
  else
    fail "partial-model-mapping: unmapped harness returns hardcoded default model" "model=$m"
  fi
else
  fail "partial-model-mapping: --resolve with unmapped harness exits 0" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# User-level override (merge) tests
# ---------------------------------------------------------------------------

# --user-config overrides default from project config
proj_cfg=$(write_project_config "merge-proj" "default: claude-code")
user_cfg=$(write_user_config "merge-user" "default: codex")
t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$proj_cfg" \
  --user-config "$user_cfg" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 0 ]; then
  dv=$(echo "$OUT" | jq -r '.default' 2>/dev/null || true)
  if [ "$dv" = "codex" ]; then
    pass "User-level override: --user-config default overrides project config default"
  else
    fail "User-level override: --user-config default overrides project config default" "default=$dv"
  fi
else
  fail "User-level override: --user-config overrides project config" "RC=$RC ERR=$ERR"
fi

# Merge: user default overrides project default, project-only agent preserved
t_merge_agents=$(make_mock_agent_dir)
proj_cfg=$(write_project_config "merge-preserve-proj" \
"default: claude-code

agents:
  basic-agent: aider")
user_cfg=$(write_user_config "merge-preserve-user" "default: codex")
run_loader \
  --project-config "$proj_cfg" \
  --user-config "$user_cfg" \
  --agent-dir "$t_merge_agents"
if [ "$RC" -eq 0 ]; then
  dv=$(echo "$OUT" | jq -r '.default' 2>/dev/null || true)
  av=$(echo "$OUT" | jq -r '.agents["basic-agent"]' 2>/dev/null || true)
  if [ "$dv" = "codex" ] && [ "$av" = "aider" ]; then
    pass "Merge: user default overrides project default, project-only agent preserved"
  else
    fail "Merge: user default overrides project default, project-only agent preserved" "default=$dv agents.basic-agent=$av"
  fi
else
  fail "Merge: user and project configs merge correctly" "RC=$RC ERR=$ERR"
fi

# Merge: user group override applies, project-only group preserved.
# Use an agent dir with mock gru, lucy, margo that only declare codex-safe tools
# so capability gating passes when those groups are routed to codex.
# Project: governance=codex, boss=codex. User: boss=claude-code.
# After merge: governance=codex (project only, preserved), boss=claude-code (user override).
t_merge_groups_agents=$(make_agent_temp)
for mock_name in gru lucy margo; do
  mkdir -p "$t_merge_groups_agents/$mock_name"
  printf -- '---\nname: %s\ndescription: mock\ntools: Read, Write, Edit, Bash, Glob, Grep\nmodel: sonnet\n---\nmock\n' \
    "$mock_name" > "$t_merge_groups_agents/$mock_name/AGENT.md"
done
proj_cfg=$(write_project_config "merge-groups-proj" \
"default: claude-code

groups:
  governance: codex
  boss: codex")
user_cfg=$(write_user_config "merge-groups-user" \
"default: claude-code

groups:
  boss: claude-code")
run_loader \
  --project-config "$proj_cfg" \
  --user-config "$user_cfg" \
  --agent-dir "$t_merge_groups_agents"
if [ "$RC" -eq 0 ]; then
  gov=$(echo "$OUT" | jq -r '.groups.governance' 2>/dev/null || true)
  boss=$(echo "$OUT" | jq -r '.groups.boss' 2>/dev/null || true)
  if [ "$gov" = "codex" ] && [ "$boss" = "claude-code" ]; then
    pass "Merge: user group override applies, project-only group preserved (governance=codex, boss=claude-code after user override)"
  else
    fail "Merge: user group override applies, project-only group preserved" "governance=$gov boss=$boss"
  fi
else
  fail "Merge: user+project groups merge correctly" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# --resolve zero-config: known agent resolves to claude-code
# ---------------------------------------------------------------------------

t_zc2_loader=$(make_agent_temp)
cp "$LOADER" "$t_zc2_loader/load-routing-config.sh"
RC=0
OUT=$(bash "$t_zc2_loader/load-routing-config.sh" \
  --resolve nefario \
  --agent-dir "$REAL_AGENT_DIR" 2>/dev/null) || RC=$?
if [ "$RC" -eq 0 ]; then
  h=$(echo "$OUT" | jq -r '.harness' 2>/dev/null || true)
  if [ "$h" = "claude-code" ]; then
    pass "--resolve zero-config: nefario resolves to claude-code (default)"
  else
    fail "--resolve zero-config: nefario resolves to claude-code (default)" "harness=$h"
  fi
else
  fail "--resolve zero-config: exits 0 for known agent" "RC=$RC OUT=$OUT"
fi

# ---------------------------------------------------------------------------
# Group membership drift test
# ---------------------------------------------------------------------------
# Cross-check the hardcoded group registry against discovered AGENT.md files.
# Every agent listed in every group must have a corresponding AGENT.md with
# a matching name: field under the real repo root.

echo ""
echo "--- Group membership drift check ---"

all_group_members="gru lucy margo mcp-minion oauth-minion api-design-minion api-spec-minion iac-minion edge-minion data-minion ai-modeling-minion frontend-minion test-minion debugger-minion devx-minion code-review-minion security-minion observability-minion ux-strategy-minion ux-design-minion software-docs-minion user-docs-minion product-marketing-minion accessibility-minion seo-minion sitespeed-minion"

drift_failures=0
for member in $all_group_members; do
  found=0
  while IFS= read -r agent_file; do
    name=$(awk '/^---$/{if(in_front){exit}else{in_front=1;next}} in_front && /^name:/{gsub(/^name:[[:space:]]*/,""); print; exit}' "$agent_file" 2>/dev/null || true)
    if [ "$name" = "$member" ]; then
      found=1
      break
    fi
  done < <(find "$REAL_AGENT_DIR" -name "AGENT.md" -not -path "*/node_modules/*" 2>/dev/null)

  if [ "$found" -eq 1 ]; then
    pass "Group drift: $member has a valid AGENT.md"
  else
    fail "Group drift: $member has a valid AGENT.md" "No AGENT.md with name: $member under $REAL_AGENT_DIR"
    drift_failures=$((drift_failures + 1))
  fi
done

if [ "$drift_failures" -eq 0 ]; then
  pass "Group drift: all 26 group members have AGENT.md files"
else
  fail "Group drift: $drift_failures group members lack AGENT.md files" "see individual failures above"
fi

# ---------------------------------------------------------------------------
# Explicit --project-config with nonexistent file exits 1
# ---------------------------------------------------------------------------

t_empty_agent=$(make_agent_temp)
t_no_file_dir=$(make_project_temp)
run_loader \
  --project-config "$t_no_file_dir/does-not-exist.yml" \
  --agent-dir "$t_empty_agent"
if [ "$RC" -eq 1 ]; then
  pass "Explicit --project-config with nonexistent file exits 1"
else
  fail "Explicit --project-config with nonexistent file exits 1" "RC=$RC ERR=$ERR"
fi

# ---------------------------------------------------------------------------
# Output format: loader emits exactly one JSON line on stdout
# ---------------------------------------------------------------------------

t_empty_agent=$(make_agent_temp)
run_loader \
  --project-config "$FIXTURES/minimal.yml" \
  --agent-dir "$t_empty_agent"
line_count=$(echo "$OUT" | wc -l | tr -d ' ')
if [ "$line_count" -eq 1 ]; then
  pass "Output: loader emits exactly one JSON line to stdout"
else
  fail "Output: loader emits exactly one JSON line to stdout" "lines=$line_count OUT=$OUT"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Results: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed"
exit "$TESTS_FAILED"
