#!/usr/bin/env bash
# tva
# load-routing-config.sh -- Nefario routing config loader
# Reads, validates, merges, and emits .nefario/routing.yml as JSON.
#
# Exit codes:
#   0 -- success (JSON emitted to stdout)
#   1 -- validation error
#   2 -- missing dependency (yq or jq)
#
# Usage:
#   load-routing-config.sh [OPTIONS]
#   load-routing-config.sh --resolve AGENT_NAME [--tier sonnet|opus]
#
# Options:
#   --project-config PATH   Override project config path
#   --user-config PATH      Override user config path
#   --agent-dir PATH        Root dir containing agent AGENT.md files
#   --resolve AGENT_NAME    Resolve a single agent's harness+model and print JSON
#   --tier opus|sonnet      Model tier for --resolve (default: sonnet)

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

VALID_HARNESSES="claude-code codex aider"
MAX_FILE_BYTES=65536

# Capability registry per harness (space-separated tool lists)
CAPS_claude_code="Read Write Edit Bash Glob Grep WebSearch WebFetch"
CAPS_codex="Read Write Edit Bash Glob Grep"
CAPS_aider="Read Write Edit"

# Default models per harness+tier (used when no model-mapping configured)
DEFAULT_claude_code_opus="claude-opus-4-6"
DEFAULT_claude_code_sonnet="claude-sonnet-4-5"
DEFAULT_codex_opus="o3"
DEFAULT_codex_sonnet="o4-mini"
DEFAULT_aider_opus="claude-opus-4-6"
DEFAULT_aider_sonnet="claude-sonnet-4-5"

# Group definitions as flat lookup (bash 3.2 compatible)
# Format: get_group_members GROUP_ID returns space-separated member names
get_group_members() {
  case "$1" in
    boss)                 echo "gru" ;;
    governance)           echo "lucy margo" ;;
    protocol-integration) echo "mcp-minion oauth-minion api-design-minion api-spec-minion" ;;
    infrastructure-data)  echo "iac-minion edge-minion data-minion" ;;
    intelligence)         echo "ai-modeling-minion" ;;
    development-quality)  echo "frontend-minion test-minion debugger-minion devx-minion code-review-minion" ;;
    security-observability) echo "security-minion observability-minion" ;;
    design-documentation) echo "ux-strategy-minion ux-design-minion software-docs-minion user-docs-minion product-marketing-minion" ;;
    web-quality)          echo "accessibility-minion seo-minion sitespeed-minion" ;;
    *)                    echo "" ;;
  esac
}

VALID_GROUP_IDS="boss governance protocol-integration infrastructure-data intelligence development-quality security-observability design-documentation web-quality"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

ARG_PROJECT_CONFIG=""
ARG_USER_CONFIG=""
ARG_AGENT_DIR=""
ARG_RESOLVE=""
ARG_TIER="sonnet"

while [ $# -gt 0 ]; do
  case "$1" in
    --project-config)
      ARG_PROJECT_CONFIG="$2"
      shift 2
      ;;
    --user-config)
      ARG_USER_CONFIG="$2"
      shift 2
      ;;
    --agent-dir)
      ARG_AGENT_DIR="$2"
      shift 2
      ;;
    --resolve)
      ARG_RESOLVE="$2"
      shift 2
      ;;
    --tier)
      ARG_TIER="$2"
      shift 2
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      echo "" >&2
      echo "Usage: load-routing-config.sh [--project-config PATH] [--user-config PATH]" >&2
      echo "       load-routing-config.sh --resolve AGENT_NAME [--tier opus|sonnet]" >&2
      exit 2
      ;;
  esac
done

# Validate --tier
if [ "$ARG_TIER" != "opus" ] && [ "$ARG_TIER" != "sonnet" ]; then
  echo "Error: --tier must be 'opus' or 'sonnet', got: $ARG_TIER" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Derive paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Agent directory default: repo root (agents live in gru/, nefario/, lucy/, margo/, minions/*/)
if [ -n "$ARG_AGENT_DIR" ]; then
  AGENT_DIR="$ARG_AGENT_DIR"
else
  AGENT_DIR="$PROJECT_ROOT"
fi

# Raw config paths (before canonicalization)
if [ -n "$ARG_PROJECT_CONFIG" ]; then
  RAW_PROJECT_CONFIG="$ARG_PROJECT_CONFIG"
else
  RAW_PROJECT_CONFIG="$PROJECT_ROOT/.nefario/routing.yml"
fi

if [ -n "$ARG_USER_CONFIG" ]; then
  RAW_USER_CONFIG="$ARG_USER_CONFIG"
else
  RAW_USER_CONFIG="$HOME/.claude/nefario/routing.yml"
fi

# ---------------------------------------------------------------------------
# Dependency checks
# ---------------------------------------------------------------------------

check_deps() {
  local missing=""

  if ! command -v jq >/dev/null 2>&1; then
    missing="$missing jq"
  fi

  if ! command -v yq >/dev/null 2>&1; then
    missing="$missing yq(Mike-Farah-Go-v4+)"
  else
    local yq_version
    yq_version="$(yq --version 2>&1 || true)"
    if ! echo "$yq_version" | grep -qi "mikefarah"; then
      missing="$missing yq(Mike-Farah-Go-v4+-found-different-version)"
    fi
  fi

  if [ -n "$missing" ]; then
    echo "Error: Missing required dependencies" >&2
    echo "" >&2
    for dep in $missing; do
      echo "  Missing: $(echo "$dep" | tr '-' ' ')" >&2
    done
    echo "" >&2
    echo "Install yq (Mike Farah Go version):" >&2
    echo "  macOS:  brew install yq" >&2
    echo "  Linux:  https://github.com/mikefarah/yq/releases (download binary for your arch)" >&2
    echo "  Go:     go install github.com/mikefarah/yq/v4@latest" >&2
    echo "" >&2
    echo "Install jq:" >&2
    echo "  macOS:  brew install jq" >&2
    echo "  Linux:  apt install jq  /  yum install jq" >&2
    exit 2
  fi
}

# ---------------------------------------------------------------------------
# Path canonicalization and escape validation
# ---------------------------------------------------------------------------

# Canonicalize a path and verify it does not escape the expected root.
# Usage: canon_path RAW_PATH EXPECTED_ROOT LABEL
# Returns the canonical path on stdout, or exits 1 with an error message.
canon_path() {
  local raw_path="$1"
  local expected_root="$2"
  local label="$3"

  # Expand ~ manually
  case "$1" in
    "~"*) raw_path="$HOME${1#\~}" ;;
    *)    raw_path="$1" ;;
  esac

  local canon
  if [ -e "$raw_path" ]; then
    canon="$(realpath "$raw_path")"
  elif [ -d "$(dirname "$raw_path")" ]; then
    canon="$(realpath "$(dirname "$raw_path")")/$(basename "$raw_path")"
  else
    # Path does not exist; use as-is for escape check
    canon="$raw_path"
  fi

  # Normalize expected_root
  local root_canon
  root_canon="$(realpath "$expected_root" 2>/dev/null || echo "$expected_root")"

  # Check that canon starts with root_canon
  if [ "$canon" != "$root_canon" ] && [ "${canon#$root_canon/}" = "$canon" ]; then
    echo "Error: $label path escapes expected root" >&2
    echo "" >&2
    echo "  path: $canon" >&2
    echo "  expected root: $root_canon" >&2
    echo "" >&2
    echo "Provide a config path that is inside $root_canon." >&2
    exit 1
  fi

  echo "$canon"
}

# ---------------------------------------------------------------------------
# Filesystem-based agent discovery
# ---------------------------------------------------------------------------

# Build newline-separated list of valid agent names by finding AGENT.md files
# and extracting the name: field from their YAML frontmatter.
discover_agents() {
  local agent_dir="$1"
  find "$agent_dir" -name "AGENT.md" -not -path "*/node_modules/*" 2>/dev/null | while IFS= read -r agent_file; do
    awk '/^---$/{if(in_front){exit}else{in_front=1;next}} in_front && /^name:/{gsub(/^name:[[:space:]]*/,""); print; exit}' "$agent_file" 2>/dev/null || true
  done
}

# ---------------------------------------------------------------------------
# Validation helpers
# ---------------------------------------------------------------------------

is_valid_harness() {
  local h="$1"
  for valid in $VALID_HARNESSES; do
    [ "$h" = "$valid" ] && return 0
  done
  return 1
}

harness_caps() {
  case "$1" in
    claude-code) echo "$CAPS_claude_code" ;;
    codex)       echo "$CAPS_codex" ;;
    aider)       echo "$CAPS_aider" ;;
    *)           echo "" ;;
  esac
}

harness_supports_tool() {
  local harness="$1"
  local tool="$2"
  local caps
  caps="$(harness_caps "$harness")"
  for cap in $caps; do
    [ "$cap" = "$tool" ] && return 0
  done
  return 1
}

# Return newline-separated list of harnesses supporting all tools in $1 (space-separated)
harnesses_supporting_tools() {
  local required_tools="$1"
  for h in $VALID_HARNESSES; do
    local all_ok=1
    for tool in $required_tools; do
      if ! harness_supports_tool "$h" "$tool"; then
        all_ok=0
        break
      fi
    done
    [ "$all_ok" -eq 1 ] && echo "$h"
  done
}

# Get tools: field from an agent's AGENT.md (space-separated, or "ALL" if absent)
agent_required_tools() {
  local agent_name="$1"
  local agent_dir="$2"

  local agent_file=""
  while IFS= read -r f; do
    local name
    name="$(awk '/^---$/{if(in_front){exit}else{in_front=1;next}} in_front && /^name:/{gsub(/^name:[[:space:]]*/,""); print; exit}' "$f" 2>/dev/null || true)"
    if [ "$name" = "$agent_name" ]; then
      agent_file="$f"
      break
    fi
  done < <(find "$agent_dir" -name "AGENT.md" -not -path "*/node_modules/*" 2>/dev/null)

  if [ -z "$agent_file" ]; then
    echo "ALL"
    return
  fi

  local tools_line
  tools_line="$(awk '/^---$/{if(in_front){exit}else{in_front=1;next}} in_front && /^tools:/{gsub(/^tools:[[:space:]]*/,""); print; exit}' "$agent_file" 2>/dev/null || true)"

  if [ -z "$tools_line" ]; then
    echo "ALL"
  else
    echo "$tools_line" | tr ',' ' ' | tr -s ' '
  fi
}

# ---------------------------------------------------------------------------
# YAML anchor detection
# ---------------------------------------------------------------------------

detect_yaml_anchors() {
  local file="$1"
  # Anchor definitions: value starts with &word
  if grep -qE '^[^#]*:[[:space:]]+&[a-zA-Z_][a-zA-Z0-9_-]*' "$file" 2>/dev/null; then
    return 0
  fi
  # Alias references: value is *word (alone on line after key)
  if grep -qE '^[^#]*:[[:space:]]+\*[a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*$' "$file" 2>/dev/null; then
    return 0
  fi
  # Block anchors/aliases on their own line
  if grep -qE '^[[:space:]]*[&*][a-zA-Z_][a-zA-Z0-9_-]*[[:space:]]*$' "$file" 2>/dev/null; then
    return 0
  fi
  return 1
}

# ---------------------------------------------------------------------------
# Error emission
# ---------------------------------------------------------------------------

# emit_errors FILE ERR1 ERR2 ...
# Prints a count header when multiple errors, then each error.
emit_errors() {
  local file="$1"
  shift
  local count=$#

  if [ "$count" -gt 1 ]; then
    echo "${file}: ${count} errors found" >&2
    echo "" >&2
    while [ $# -gt 0 ]; do
      echo "  $1" >&2
      echo "" >&2
      shift
    done
  else
    echo "$1" >&2
  fi
}

# ---------------------------------------------------------------------------
# Capability gating
# ---------------------------------------------------------------------------

# Check capability gating for one agent/harness pair.
# Prints error string on mismatch, nothing on success.
check_capability() {
  local agent_name="$1"
  local target_harness="$2"
  local required_tools="$3"
  local file="$4"

  local harness_caps_str
  harness_caps_str="$(harness_caps "$target_harness")"

  local tools_to_check="$required_tools"
  if [ "$required_tools" = "ALL" ]; then
    # No tools: field means agent requires full set (treat as claude-code capabilities)
    tools_to_check="$CAPS_claude_code"
  fi

  local unsupported=""
  for tool in $tools_to_check; do
    if ! harness_supports_tool "$target_harness" "$tool"; then
      unsupported="$unsupported $tool"
    fi
  done
  unsupported="${unsupported# }"

  if [ -z "$unsupported" ]; then
    return
  fi

  local supporting
  supporting="$(harnesses_supporting_tools "$tools_to_check" | tr '\n' ' ' | sed 's/ $//')"

  local req_display="$tools_to_check"
  if [ "$required_tools" = "ALL" ]; then
    req_display="ALL (no tools: field in AGENT.md -- treated as full tool set)"
  fi

  printf 'Error: Capability mismatch for %s routed to %s\n\n  in: %s\n\n  %s requires: %s\n  %s supports: %s\n  unsupported:        %s\n\n  Harnesses supporting these tools: %s\n\nRoute %s to a harness that supports these tools,\nor remove the agent-level override to use the default harness.' \
    "$agent_name" "$target_harness" \
    "$file" \
    "$agent_name" "$req_display" \
    "$target_harness" "$harness_caps_str" \
    "$unsupported" \
    "${supporting:-none}" \
    "$agent_name"
}

# ---------------------------------------------------------------------------
# File loading and validation
# ---------------------------------------------------------------------------

# validate_routing_file FILE AGENT_DIR
# Emits validated JSON to stdout on success.
# Exits 1 with error message to stderr on failure.
validate_routing_file() {
  local file="$1"
  local agent_dir="$2"

  # (b) File size check
  local file_size
  file_size="$(wc -c < "$file" | tr -d ' ')"
  if [ "$file_size" -gt "$MAX_FILE_BYTES" ]; then
    echo "Error: Config file exceeds 64KB size limit" >&2
    echo "" >&2
    echo "  in: $file" >&2
    echo "" >&2
    echo "File size: ${file_size} bytes (limit: ${MAX_FILE_BYTES} bytes)." >&2
    echo "Split large configs or remove unused entries." >&2
    exit 1
  fi

  # Security: YAML anchor detection
  if detect_yaml_anchors "$file"; then
    echo "Error: YAML anchors and aliases are not allowed" >&2
    echo "" >&2
    echo "  in: $file" >&2
    echo "" >&2
    echo "Remove anchor definitions (&name) and alias references (*name)." >&2
    echo "Repeat the values explicitly instead." >&2
    exit 1
  fi

  # (a) Syntax check via yq
  local parsed_json
  if ! parsed_json="$(yq -o=json '.' "$file" 2>/tmp/yq-parse-error-$$)"; then
    local parse_err
    parse_err="$(cat /tmp/yq-parse-error-$$ 2>/dev/null || echo "parse error")"
    rm -f /tmp/yq-parse-error-$$
    echo "Error: YAML syntax error" >&2
    echo "" >&2
    echo "  in: $file" >&2
    echo "" >&2
    echo "$parse_err" >&2
    exit 1
  fi
  rm -f /tmp/yq-parse-error-$$

  # (c) Required field: default
  local default_val
  default_val="$(echo "$parsed_json" | jq -r '.default // empty')"

  local c_errors=""
  if [ -z "$default_val" ]; then
    c_errors="Error: Missing required field 'default'

  in: $file

Add a 'default' field specifying the harness for unmatched agents:

  default: claude-code

Valid harnesses: claude-code, codex, aider"
  fi

  if [ -n "$c_errors" ]; then
    echo "$c_errors" >&2
    exit 1
  fi

  # (d) Harness name allowlist
  # Collect all harness errors before failing
  local d_errors=""
  local d_count=0

  # Check default
  if ! is_valid_harness "$default_val"; then
    d_errors="${d_errors}Error: Unknown harness '${default_val}' in 'default'

  in: $file

Valid harnesses: claude-code, codex, aider
"
    d_count=$((d_count + 1))
  fi

  # Check groups.*
  local groups_json
  groups_json="$(echo "$parsed_json" | jq -c '.groups // {}')"
  local group_keys
  group_keys="$(echo "$groups_json" | jq -r 'keys[]')"
  for key in $group_keys; do
    local val
    val="$(echo "$groups_json" | jq -r --arg k "$key" '.[$k]')"
    if ! is_valid_harness "$val"; then
      d_errors="${d_errors}Error: Unknown harness '${val}' in groups.${key}

  in: $file

Valid harnesses: claude-code, codex, aider
"
      d_count=$((d_count + 1))
    fi
  done

  # Check agents.*
  local agents_json
  agents_json="$(echo "$parsed_json" | jq -c '.agents // {}')"
  local agent_keys
  agent_keys="$(echo "$agents_json" | jq -r 'keys[]')"
  for key in $agent_keys; do
    local val
    val="$(echo "$agents_json" | jq -r --arg k "$key" '.[$k]')"
    if ! is_valid_harness "$val"; then
      d_errors="${d_errors}Error: Unknown harness '${val}' in agents.${key}

  in: $file

Valid harnesses: claude-code, codex, aider
"
      d_count=$((d_count + 1))
    fi
  done

  # Check model-mapping top-level keys
  local model_mapping_json
  model_mapping_json="$(echo "$parsed_json" | jq -c '."model-mapping" // {}')"
  local mm_keys
  mm_keys="$(echo "$model_mapping_json" | jq -r 'keys[]')"
  for key in $mm_keys; do
    if ! is_valid_harness "$key"; then
      d_errors="${d_errors}Error: Unknown harness '${key}' in model-mapping

  in: $file

Valid harnesses: claude-code, codex, aider
"
      d_count=$((d_count + 1))
    fi
  done

  if [ "$d_count" -gt 0 ]; then
    if [ "$d_count" -gt 1 ]; then
      echo "${file}: ${d_count} errors found" >&2
      echo "" >&2
      echo "$d_errors" >&2
    else
      echo "$d_errors" >&2
    fi
    exit 1
  fi

  # (e) Group name validation
  local e_errors=""
  local e_count=0
  for key in $group_keys; do
    local found=0
    for valid_gid in $VALID_GROUP_IDS; do
      if [ "$key" = "$valid_gid" ]; then
        found=1
        break
      fi
    done
    if [ "$found" -eq 0 ]; then
      e_errors="${e_errors}Error: Unknown group name '${key}' in groups

  in: $file

Valid group IDs: $(echo "$VALID_GROUP_IDS" | tr ' ' '\n' | sort | tr '\n' ' ')
"
      e_count=$((e_count + 1))
    fi
  done

  if [ "$e_count" -gt 0 ]; then
    if [ "$e_count" -gt 1 ]; then
      echo "${file}: ${e_count} errors found" >&2
      echo "" >&2
      echo "$e_errors" >&2
    else
      echo "$e_errors" >&2
    fi
    exit 1
  fi

  # (f) Agent name validation (filesystem discovery)
  local valid_agents
  valid_agents="$(discover_agents "$agent_dir")"
  local f_errors=""
  local f_count=0
  for key in $agent_keys; do
    if ! echo "$valid_agents" | grep -qx "$key"; then
      f_errors="${f_errors}Error: Unknown agent name '${key}' in agents

  in: $file

Valid agents are discovered from AGENT.md files under: $agent_dir
Run: find $agent_dir -name 'AGENT.md' | xargs grep '^name:' to see current list.
"
      f_count=$((f_count + 1))
    fi
  done

  if [ "$f_count" -gt 0 ]; then
    if [ "$f_count" -gt 1 ]; then
      echo "${file}: ${f_count} errors found" >&2
      echo "" >&2
      echo "$f_errors" >&2
    else
      echo "$f_errors" >&2
    fi
    exit 1
  fi

  # (g) Model-mapping validation
  local g_errors=""
  local g_count=0
  for harness in $mm_keys; do
    local harness_mapping
    harness_mapping="$(echo "$model_mapping_json" | jq -c --arg h "$harness" '.[$h]')"
    local tier_keys
    tier_keys="$(echo "$harness_mapping" | jq -r 'keys[]')"
    for tier in $tier_keys; do
      if [ "$tier" != "opus" ] && [ "$tier" != "sonnet" ]; then
        g_errors="${g_errors}Error: Invalid tier key '${tier}' in model-mapping.${harness}

  in: $file

Tier keys must be 'opus' or 'sonnet'.
"
        g_count=$((g_count + 1))
        continue
      fi
      local model_id
      model_id="$(echo "$harness_mapping" | jq -r --arg t "$tier" '.[$t]')"
      local id_len
      id_len="${#model_id}"
      if [ "$id_len" -gt 256 ]; then
        g_errors="${g_errors}Error: Model ID exceeds 256 characters in model-mapping.${harness}.${tier}

  in: $file

Shorten the model ID to 256 characters or fewer.
"
        g_count=$((g_count + 1))
      elif ! echo "$model_id" | grep -qE '^[a-zA-Z0-9._-]+$'; then
        g_errors="${g_errors}Error: Invalid model ID '${model_id}' in model-mapping.${harness}.${tier}

  in: $file

Model IDs must match [a-zA-Z0-9._-]+ (no spaces, shell metacharacters, or control characters).
Example: claude-opus-4-6, o3, o4-mini
"
        g_count=$((g_count + 1))
      fi
    done
  done

  if [ "$g_count" -gt 0 ]; then
    if [ "$g_count" -gt 1 ]; then
      echo "${file}: ${g_count} errors found" >&2
      echo "" >&2
      echo "$g_errors" >&2
    else
      echo "$g_errors" >&2
    fi
    exit 1
  fi

  # (h) Capability gating
  local h_errors=""
  local h_count=0

  # Check explicit agent -> harness mappings
  for agent_name in $agent_keys; do
    local target_harness
    target_harness="$(echo "$agents_json" | jq -r --arg a "$agent_name" '.[$a]')"
    [ "$target_harness" = "claude-code" ] && continue

    local required_tools
    required_tools="$(agent_required_tools "$agent_name" "$agent_dir")"

    local cap_error
    cap_error="$(check_capability "$agent_name" "$target_harness" "$required_tools" "$file")"
    if [ -n "$cap_error" ]; then
      h_errors="${h_errors}${cap_error}
"
      h_count=$((h_count + 1))
    fi
  done

  # Check group -> harness mappings (for agents not already checked)
  for group_name in $group_keys; do
    local target_harness
    target_harness="$(echo "$groups_json" | jq -r --arg g "$group_name" '.[$g]')"
    [ "$target_harness" = "claude-code" ] && continue

    local members
    members="$(get_group_members "$group_name")"
    for agent_name in $members; do
      # Skip if agent has an explicit override
      local explicit
      explicit="$(echo "$agents_json" | jq -r --arg a "$agent_name" '.[$a] // empty')"
      [ -n "$explicit" ] && continue

      local required_tools
      required_tools="$(agent_required_tools "$agent_name" "$agent_dir")"

      local cap_error
      cap_error="$(check_capability "$agent_name" "$target_harness" "$required_tools" "$file")"
      if [ -n "$cap_error" ]; then
        h_errors="${h_errors}${cap_error}
"
        h_count=$((h_count + 1))
      fi
    done
  done

  if [ "$h_count" -gt 0 ]; then
    if [ "$h_count" -gt 1 ]; then
      echo "${file}: ${h_count} errors found" >&2
      echo "" >&2
      echo "$h_errors" >&2
    else
      echo "$h_errors" >&2
    fi
    exit 1
  fi

  # Normalize output to always include all four top-level keys
  jq -c '{
    "default": (.default // "claude-code"),
    "groups": (.groups // {}),
    "agents": (.agents // {}),
    "model-mapping": (."model-mapping" // {})
  }' <<< "$parsed_json"
}

# ---------------------------------------------------------------------------
# Merge logic
# ---------------------------------------------------------------------------

# Temp file for merge change log (avoids subshell variable scoping issues)
MERGE_LOG_FILE=""

# Merge user-level config over project-level config.
# Writes change log entries to MERGE_LOG_FILE (one entry per line).
merge_configs() {
  local project_json="$1"
  local user_json="$2"

  # Merge default
  local proj_default user_default merged_default
  proj_default="$(echo "$project_json" | jq -r '.default // "claude-code"')"
  user_default="$(echo "$user_json" | jq -r '.default // empty')"
  if [ -n "$user_default" ]; then
    merged_default="$user_default"
    if [ "$proj_default" != "$user_default" ] && [ -n "$MERGE_LOG_FILE" ]; then
      printf 'default: %s -> %s\n' "$proj_default" "$user_default" >> "$MERGE_LOG_FILE"
    fi
  else
    merged_default="$proj_default"
  fi

  # Merge groups (per-key: user overrides matching keys, project-only keys preserved)
  local proj_groups user_groups
  proj_groups="$(echo "$project_json" | jq -c '.groups // {}')"
  user_groups="$(echo "$user_json" | jq -c '.groups // {}')"

  # Log group changes
  while IFS= read -r key; do
    [ -z "$key" ] && continue
    local proj_val user_val
    proj_val="$(echo "$proj_groups" | jq -r --arg k "$key" '.[$k] // empty')"
    user_val="$(echo "$user_groups" | jq -r --arg k "$key" '.[$k] // empty')"
    if [ -n "$user_val" ] && [ -n "$proj_val" ] && [ "$proj_val" != "$user_val" ] && [ -n "$MERGE_LOG_FILE" ]; then
      printf 'groups.%s: %s -> %s\n' "$key" "$proj_val" "$user_val" >> "$MERGE_LOG_FILE"
    fi
  done < <(echo "$user_groups" | jq -r 'keys[]')

  local merged_groups
  merged_groups="$(jq -cn --argjson a "$proj_groups" --argjson b "$user_groups" '$a * $b')"

  # Merge agents (same pattern)
  local proj_agents user_agents
  proj_agents="$(echo "$project_json" | jq -c '.agents // {}')"
  user_agents="$(echo "$user_json" | jq -c '.agents // {}')"

  while IFS= read -r key; do
    [ -z "$key" ] && continue
    local proj_val user_val
    proj_val="$(echo "$proj_agents" | jq -r --arg k "$key" '.[$k] // empty')"
    user_val="$(echo "$user_agents" | jq -r --arg k "$key" '.[$k] // empty')"
    if [ -n "$user_val" ] && [ -n "$proj_val" ] && [ "$proj_val" != "$user_val" ] && [ -n "$MERGE_LOG_FILE" ]; then
      printf 'agents.%s: %s -> %s\n' "$key" "$proj_val" "$user_val" >> "$MERGE_LOG_FILE"
    fi
  done < <(echo "$user_agents" | jq -r 'keys[]')

  local merged_agents
  merged_agents="$(jq -cn --argjson a "$proj_agents" --argjson b "$user_agents" '$a * $b')"

  # Merge model-mapping: user replaces entire harness block
  local proj_mapping user_mapping
  proj_mapping="$(echo "$project_json" | jq -c '."model-mapping" // {}')"
  user_mapping="$(echo "$user_json" | jq -c '."model-mapping" // {}')"
  local merged_mapping
  merged_mapping="$(jq -cn --argjson a "$proj_mapping" --argjson b "$user_mapping" '$a * $b')"

  jq -cn \
    --arg default "$merged_default" \
    --argjson groups "$merged_groups" \
    --argjson agents "$merged_agents" \
    --argjson mapping "$merged_mapping" \
    '{"default": $default, "groups": $groups, "agents": $agents, "model-mapping": $mapping}'
}

# ---------------------------------------------------------------------------
# Resolution logic
# ---------------------------------------------------------------------------

resolve_harness() {
  local agent_name="$1"
  local config_json="$2"

  # Agent-level override
  local agent_harness
  agent_harness="$(echo "$config_json" | jq -r --arg a "$agent_name" '.agents[$a] // empty')"
  if [ -n "$agent_harness" ]; then
    echo "$agent_harness"
    return
  fi

  # Group-level override: find which group this agent belongs to
  for group_id in $VALID_GROUP_IDS; do
    local members
    members="$(get_group_members "$group_id")"
    for member in $members; do
      if [ "$member" = "$agent_name" ]; then
        local group_harness
        group_harness="$(echo "$config_json" | jq -r --arg g "$group_id" '.groups[$g] // empty')"
        if [ -n "$group_harness" ]; then
          echo "$group_harness"
          return
        fi
        break
      fi
    done
  done

  # Default
  local default_harness
  default_harness="$(echo "$config_json" | jq -r '.default // "claude-code"')"
  echo "$default_harness"
}

resolve_model() {
  local harness="$1"
  local tier="$2"
  local config_json="$3"

  local mapped
  mapped="$(echo "$config_json" | jq -r --arg h "$harness" --arg t "$tier" '."model-mapping"[$h][$t] // empty')"
  if [ -n "$mapped" ]; then
    echo "$mapped"
    return
  fi

  # Hardcoded defaults
  case "${harness}__${tier}" in
    claude-code__opus)   echo "$DEFAULT_claude_code_opus" ;;
    claude-code__sonnet) echo "$DEFAULT_claude_code_sonnet" ;;
    codex__opus)         echo "$DEFAULT_codex_opus" ;;
    codex__sonnet)       echo "$DEFAULT_codex_sonnet" ;;
    aider__opus)         echo "$DEFAULT_aider_opus" ;;
    aider__sonnet)       echo "$DEFAULT_aider_sonnet" ;;
    *)                   echo "" ;;
  esac
}

# ---------------------------------------------------------------------------
# resolve_agent subcommand
# ---------------------------------------------------------------------------

resolve_agent() {
  local agent_name="$1"
  local tier="$2"
  local config_json="$3"

  local valid_agents
  valid_agents="$(discover_agents "$AGENT_DIR")"
  if ! echo "$valid_agents" | grep -qx "$agent_name"; then
    echo "Error: Unknown agent '$agent_name'" >&2
    echo "" >&2
    echo "Valid agents are discovered from AGENT.md files under: $AGENT_DIR" >&2
    echo "Run: find $AGENT_DIR -name 'AGENT.md' | xargs grep '^name:' to see current list." >&2
    exit 1
  fi

  local harness
  harness="$(resolve_harness "$agent_name" "$config_json")"

  local model
  model="$(resolve_model "$harness" "$tier" "$config_json")"

  jq -cn --arg harness "$harness" --arg model "$model" \
    '{"harness": $harness, "model": $model}'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
  # Zero-config path: only applies when the DEFAULT project config path is used
  # and that file doesn't exist. Explicit --project-config paths must exist.
  if [ -z "$ARG_PROJECT_CONFIG" ]; then
    # Using default path: check existence without canonicalization (no yq needed)
    if [ ! -f "$RAW_PROJECT_CONFIG" ]; then
      local zero_config='{"default":"claude-code","groups":{},"agents":{},"model-mapping":{}}'
      if [ -n "$ARG_RESOLVE" ]; then
        resolve_agent "$ARG_RESOLVE" "$ARG_TIER" "$zero_config"
        return
      fi
      printf '%s\n' "$zero_config"
      return
    fi
  fi

  # Config file exists (or was explicitly specified) -- need yq and jq
  check_deps

  # Canonicalize and validate project config path (validates escape for both
  # default and CLI-provided paths)
  local canon_project
  canon_project="$(canon_path "$RAW_PROJECT_CONFIG" "$PROJECT_ROOT" "Project config")"

  # When using CLI-provided path, verify the file exists after canonicalization
  if [ -n "$ARG_PROJECT_CONFIG" ] && [ ! -f "$canon_project" ]; then
    echo "Error: Project config file not found" >&2
    echo "" >&2
    echo "  path: $canon_project" >&2
    echo "" >&2
    echo "Check the path and try again." >&2
    exit 1
  fi

  # Load and validate project config
  local project_json
  project_json="$(validate_routing_file "$canon_project" "$AGENT_DIR")"
  echo "routing: loaded ${canon_project/$HOME/~}" >&2

  # Load user config if it exists
  local user_config_path
  case "$RAW_USER_CONFIG" in
    "~"*) user_config_path="$HOME${RAW_USER_CONFIG#\~}" ;;
    *)    user_config_path="$RAW_USER_CONFIG" ;;
  esac

  local merged_json="$project_json"

  if [ -f "$user_config_path" ]; then
    local canon_user
    canon_user="$(canon_path "$RAW_USER_CONFIG" "$HOME" "User config")"

    local user_json
    user_json="$(validate_routing_file "$canon_user" "$AGENT_DIR")"
    echo "routing: loaded ${canon_user/$HOME/~} (user override)" >&2

    # Set up temp file for merge change log, then call merge_configs in subshell
    MERGE_LOG_FILE="$(mktemp /tmp/nefario-merge-log-$$-XXXXXX)"
    merged_json="$(merge_configs "$project_json" "$user_json")"

    # Log changes (read from temp file written by merge_configs)
    if [ -s "$MERGE_LOG_FILE" ]; then
      while IFS= read -r change; do
        [ -z "$change" ] && continue
        echo "routing: user override changed $change" >&2
      done < "$MERGE_LOG_FILE"
    fi
    rm -f "$MERGE_LOG_FILE"
  fi

  if [ -n "$ARG_RESOLVE" ]; then
    resolve_agent "$ARG_RESOLVE" "$ARG_TIER" "$merged_json"
  else
    echo "$merged_json"
  fi
}

main
