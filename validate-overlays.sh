#!/usr/bin/env bash

# validate-overlays.sh — Detect drift in despicable-agents overlay system
#
# Usage:
#   validate-overlays.sh              # check all agents, show summary + details
#   validate-overlays.sh <agent-name> # check one agent, show details
#   validate-overlays.sh --summary    # check all agents, show summary only (for /lab)

set -euo pipefail

# Determine script directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Exit codes
EXIT_CLEAN=0
EXIT_DRIFT=1
EXIT_ERROR=2

# Parse command line arguments
SUMMARY_ONLY=false
SINGLE_AGENT=""

if [[ $# -eq 1 ]]; then
  if [[ "$1" == "--summary" ]]; then
    SUMMARY_ONLY=true
  elif [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    echo "Usage: $0 [<agent-name>] [--summary]"
    echo ""
    echo "Check overlay system drift in despicable-agents."
    echo ""
    echo "Options:"
    echo "  <agent-name>  Check a single agent directory"
    echo "  --summary     Show summary output only (for /lab integration)"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Exit codes:"
    echo "  0  No drift detected"
    echo "  1  Drift detected"
    echo "  2  Script error"
    exit 0
  else
    SINGLE_AGENT="$1"
  fi
elif [[ $# -gt 1 ]]; then
  echo "Error: Too many arguments" >&2
  echo "Usage: $0 [<agent-name>] [--summary]" >&2
  exit $EXIT_ERROR
fi

# Temporary directory for intermediate files
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Results tracking (using files instead of associative arrays for bash 3.2 compatibility)
RESULTS_DIR="${WORK_DIR}/results"
mkdir -p "$RESULTS_DIR"

# Extract YAML frontmatter from a markdown file
# Usage: extract_frontmatter <file> > output
extract_frontmatter() {
  local file="$1"
  awk '
    BEGIN { in_fm = 0; line_count = 0 }
    /^---$/ {
      line_count++
      if (line_count == 1) { in_fm = 1; next }
      if (line_count == 2) { in_fm = 0; exit }
    }
    in_fm { print }
  ' "$file"
}

# Parse YAML frontmatter into key=value pairs (simple, shallow only)
# Usage: parse_yaml_frontmatter <file> > key=value pairs
parse_yaml_frontmatter() {
  local file="$1"
  extract_frontmatter "$file" | \
    grep -E '^\s*[a-zA-Z0-9_-]+:' | \
    sed -E 's/^\s*([a-zA-Z0-9_-]+):\s*(.*)$/\1=\2/' | \
    sed 's/^/FM_/'
}

# Extract markdown body (content after frontmatter)
# Usage: extract_body <file> > output
extract_body() {
  local file="$1"
  awk '
    BEGIN { in_fm = 0; line_count = 0; past_fm = 0 }
    /^---$/ {
      line_count++
      if (line_count == 1) { in_fm = 1; next }
      if (line_count == 2) { past_fm = 1; next }
    }
    past_fm { print }
  ' "$file"
}

# Extract H2 section headings (not inside fenced code blocks)
# Usage: extract_h2_headings <file> > headings
extract_h2_headings() {
  local file="$1"
  awk '
    BEGIN { in_fence = 0 }
    /^```/ {
      if (in_fence == 0) { in_fence = 1 }
      else { in_fence = 0 }
      next
    }
    in_fence { next }
    /^## / {
      heading = substr($0, 4)
      # Normalize whitespace
      gsub(/  +/, " ", heading)
      gsub(/^ | $/, "", heading)
      print heading
    }
  ' "$file"
}

# Extract section claims from AGENT.overrides.md (## Section: <name>)
# Usage: extract_section_claims <file> > section names
extract_section_claims() {
  local file="$1"
  awk '
    BEGIN { in_fence = 0 }
    /^```/ {
      if (in_fence == 0) { in_fence = 1 }
      else { in_fence = 0 }
      next
    }
    in_fence { next }
    /^## Section: / {
      section = substr($0, 13)
      # Normalize whitespace
      gsub(/  +/, " ", section)
      gsub(/^ | $/, "", section)
      print section
    }
  ' "$file"
}

# Extract a single section by heading (H2) from markdown body
# Returns the section content including the heading
# Usage: extract_section <file> <heading> > section content
extract_section() {
  local file="$1"
  local heading="$2"

  # Escape special regex characters in heading for matching
  local escaped_heading
  escaped_heading=$(printf '%s\n' "$heading" | sed 's/[]\/$*.^[]/\\&/g')

  awk -v heading="$escaped_heading" '
    BEGIN {
      in_fence = 0
      in_section = 0
      found = 0
    }
    /^```/ {
      if (in_fence == 0) { in_fence = 1 }
      else { in_fence = 0 }
      if (in_section) print
      next
    }
    in_fence {
      if (in_section) print
      next
    }
    /^## / && !in_fence {
      current_heading = substr($0, 4)
      # Normalize whitespace
      gsub(/  +/, " ", current_heading)
      gsub(/^ | $/, "", current_heading)

      if (in_section) {
        # End of our section
        exit
      }
      if (current_heading == heading) {
        in_section = 1
        found = 1
        print
        next
      }
    }
    in_section { print }
  ' "$file"
}

# Normalize markdown content (strip trailing whitespace, collapse blank lines, ensure single trailing newline)
# Usage: normalize_content <file> > normalized
normalize_content() {
  local file="$1"
  # Strip trailing whitespace from lines
  sed 's/[[:space:]]*$//' "$file" | \
  # Collapse consecutive blank lines to single blank line
  awk 'NF { blank=0; print } !NF { if (!blank) print; blank=1 }'
}

# Merge frontmatter (shallow merge with x-fine-tuned injection)
# Usage: merge_frontmatter <generated-file> <overrides-file> > merged
merge_frontmatter() {
  local gen_file="$1"
  local ovr_file="$2"

  local gen_fm="${WORK_DIR}/gen_fm_tmp"
  local ovr_fm="${WORK_DIR}/ovr_fm_tmp"

  parse_yaml_frontmatter "$gen_file" > "$gen_fm"

  if [[ -f "$ovr_file" ]] && [[ -s "$ovr_file" ]]; then
    parse_yaml_frontmatter "$ovr_file" > "$ovr_fm"
  else
    : > "$ovr_fm"
  fi

  # Build merged frontmatter: start with generated, apply overrides, add x-fine-tuned
  local merged="${WORK_DIR}/merged_fm_tmp"
  : > "$merged"

  # Add all generated keys
  while IFS='=' read -r key value; do
    echo "${key}=${value}" >> "$merged"
  done < "$gen_fm"

  # Apply overrides (remove existing key if present, add override)
  if [[ -s "$ovr_fm" ]]; then
    while IFS='=' read -r key value; do
      # Extract actual key name (without FM_ prefix)
      local key_name="${key#FM_}"
      # Remove any existing entry for this key
      grep -v "^FM_${key_name}=" "$merged" > "${merged}.tmp" || true
      mv "${merged}.tmp" "$merged"
      # Add override value
      echo "${key}=${value}" >> "$merged"
    done < "$ovr_fm"
  fi

  # Add x-fine-tuned if not present
  if ! grep -q "^FM_x-fine-tuned=" "$merged"; then
    echo "FM_x-fine-tuned=true" >> "$merged"
  fi

  # Output as YAML
  while IFS='=' read -r key value; do
    local key_name="${key#FM_}"
    echo "${key_name}: ${value}"
  done < "$merged"

  rm -f "$gen_fm" "$ovr_fm" "$merged"
}

# Merge sections (section-level replacement by H2 heading match)
# Usage: merge_sections <generated-body> <overrides-body> > merged-body
merge_sections() {
  local gen_body="$1"
  local ovr_body="$2"

  # Get list of all H2 headings in generated
  local headings="${WORK_DIR}/headings_tmp"
  extract_h2_headings "$gen_body" > "$headings"

  # For each section in generated, check if override exists
  while IFS= read -r heading; do
    # Check if this section exists in overrides
    local override_section
    override_section=$(extract_section "$ovr_body" "$heading")

    if [[ -n "$override_section" ]]; then
      # Use override section
      echo "$override_section"
    else
      # Use generated section
      extract_section "$gen_body" "$heading"
    fi
    echo ""
  done < "$headings"

  rm -f "$headings"
}

# Perform merge of generated + overrides to compute expected AGENT.md
# Usage: compute_merge <agent-dir> > merged-content
compute_merge() {
  local agent_dir="$1"
  local generated="${agent_dir}/AGENT.generated.md"
  local overrides="${agent_dir}/AGENT.overrides.md"

  # Merge frontmatter
  echo "---"
  merge_frontmatter "$generated" "$overrides"
  echo "---"
  echo ""

  # Extract bodies
  local gen_body="${WORK_DIR}/gen_body"
  local ovr_body="${WORK_DIR}/ovr_body"

  extract_body "$generated" > "$gen_body"
  if [[ -f "$overrides" ]] && [[ -s "$overrides" ]]; then
    extract_body "$overrides" > "$ovr_body"
  else
    : > "$ovr_body"
  fi

  # Merge sections
  if [[ -s "$ovr_body" ]]; then
    merge_sections "$gen_body" "$ovr_body"
  else
    cat "$gen_body"
  fi

  rm -f "$gen_body" "$ovr_body"
}

# Record issue for an agent
# Usage: record_issue <agent-name> <issue-string>
record_issue() {
  local agent_name="$1"
  local issue="$2"
  local agent_file="${RESULTS_DIR}/${agent_name}.issues"
  echo "$issue" >> "$agent_file"
}

# Get issue count for an agent
# Usage: get_issue_count <agent-name>
get_issue_count() {
  local agent_name="$1"
  local agent_file="${RESULTS_DIR}/${agent_name}.issues"
  if [[ -f "$agent_file" ]]; then
    wc -l < "$agent_file" | tr -d ' '
  else
    echo "0"
  fi
}

# Get status for an agent
# Usage: get_status <agent-name>
get_status() {
  local agent_name="$1"
  local count
  count=$(get_issue_count "$agent_name")
  if [[ "$count" -gt 0 ]]; then
    echo "DRIFT"
  else
    echo "CLEAN"
  fi
}

# Check a single agent for drift
# Returns: number of issues found
check_agent() {
  local agent_dir="$1"
  local agent_name
  agent_name=$(basename "$agent_dir")

  local agent_md="${agent_dir}/AGENT.md"
  local generated="${agent_dir}/AGENT.generated.md"
  local overrides="${agent_dir}/AGENT.overrides.md"

  # Skip if no AGENT.md
  if [[ ! -f "$agent_md" ]]; then
    return 0
  fi

  local issue_count=0

  # Check 3: Missing overrides file (x-fine-tuned but no overrides)
  if grep -q "^x-fine-tuned: true" "$agent_md" 2>/dev/null; then
    if [[ ! -f "$overrides" ]]; then
      record_issue "$agent_name" "MISSING_OVERRIDES_FILE: Agent has x-fine-tuned: true but no AGENT.overrides.md|File: ${agent_md}|Action: Remove x-fine-tuned flag from AGENT.md frontmatter or create AGENT.overrides.md if overrides are intended."
      issue_count=$((issue_count + 1))
    fi
  fi

  # Check 4: Inconsistent flag (overrides exist but no x-fine-tuned)
  if [[ -f "$overrides" ]] && [[ -s "$overrides" ]]; then
    if ! grep -q "^x-fine-tuned: true" "$agent_md" 2>/dev/null; then
      record_issue "$agent_name" "INCONSISTENT_FLAG: Agent has AGENT.overrides.md but no x-fine-tuned: true in AGENT.md|File: ${agent_md}|Action: Run /lab ${agent_name} to regenerate and re-merge (merge process auto-injects x-fine-tuned flag)."
      issue_count=$((issue_count + 1))
    fi
  fi

  # Check 2: Orphan override (section claimed but doesn't exist in generated)
  if [[ -f "$overrides" ]] && [[ -f "$generated" ]]; then
    local claimed_sections="${WORK_DIR}/claimed_sections_${agent_name}"
    local generated_headings="${WORK_DIR}/generated_headings_${agent_name}"

    extract_section_claims "$overrides" > "$claimed_sections"
    extract_h2_headings "$generated" > "$generated_headings"

    while IFS= read -r claimed; do
      if ! grep -Fxq "$claimed" "$generated_headings"; then
        record_issue "$agent_name" "ORPHAN_OVERRIDE: Section claimed in overrides does not exist in generated|File: ${overrides}|Section: ## ${claimed}|AGENT.generated.md does not contain a section with this heading.|Action: Review AGENT.overrides.md and remove or rename the orphaned section claim. Check if the section was removed from the-plan.md or if the heading changed."
        issue_count=$((issue_count + 1))
      fi
    done < "$claimed_sections"

    rm -f "$claimed_sections" "$generated_headings"
  fi

  # Check 1: Merge staleness (AGENT.md differs from computed merge)
  if [[ -f "$generated" ]]; then
    if [[ -f "$overrides" ]] && [[ -s "$overrides" ]]; then
      # Compute expected merge
      local computed="${WORK_DIR}/computed_merge_${agent_name}"
      local actual="${WORK_DIR}/actual_${agent_name}"

      compute_merge "$agent_dir" > "$computed"
      cat "$agent_md" > "$actual"

      # Normalize both
      local computed_norm="${WORK_DIR}/computed_norm_${agent_name}"
      local actual_norm="${WORK_DIR}/actual_norm_${agent_name}"

      normalize_content "$computed" > "$computed_norm"
      normalize_content "$actual" > "$actual_norm"

      if ! diff -q "$computed_norm" "$actual_norm" >/dev/null 2>&1; then
        record_issue "$agent_name" "MERGE_STALENESS: AGENT.md does not reflect current merge of AGENT.generated.md + AGENT.overrides.md|File: ${agent_md}|The file differs from the expected merge result. This indicates a manual edit or stale merge.|Action: Run /lab ${agent_name} to regenerate AGENT.generated.md and re-merge. If sections were intentionally hand-edited, move the edits to AGENT.overrides.md."
        issue_count=$((issue_count + 1))
      fi

      rm -f "$computed" "$actual" "$computed_norm" "$actual_norm"
    else
      # No overrides: check if AGENT.md matches AGENT.generated.md
      local gen_norm="${WORK_DIR}/gen_norm_${agent_name}"
      local actual_norm="${WORK_DIR}/actual_norm_${agent_name}"

      normalize_content "$generated" > "$gen_norm"
      normalize_content "$agent_md" > "$actual_norm"

      if ! diff -q "$gen_norm" "$actual_norm" >/dev/null 2>&1; then
        record_issue "$agent_name" "NON_OVERLAY_MISMATCH: AGENT.md differs from AGENT.generated.md but no overrides exist|File: ${agent_md}|Action: Delete AGENT.generated.md or sync AGENT.md to match (copy AGENT.generated.md to AGENT.md)."
        issue_count=$((issue_count + 1))
      fi

      rm -f "$gen_norm" "$actual_norm"
    fi
  fi

  # Check 5: Frontmatter consistency (for agents with overrides)
  if [[ -f "$overrides" ]] && [[ -s "$overrides" ]] && [[ -f "$generated" ]]; then
    local gen_fm="${WORK_DIR}/gen_fm_check_${agent_name}"
    local ovr_fm="${WORK_DIR}/ovr_fm_check_${agent_name}"
    local actual_fm="${WORK_DIR}/actual_fm_check_${agent_name}"
    local merged_fm="${WORK_DIR}/merged_fm_check_${agent_name}"

    parse_yaml_frontmatter "$generated" | sort > "$gen_fm"
    parse_yaml_frontmatter "$overrides" | sort > "$ovr_fm"
    parse_yaml_frontmatter "$agent_md" | sort > "$actual_fm"

    # Compute expected merged frontmatter
    {
      cat "$gen_fm"
      cat "$ovr_fm"
      echo "FM_x-fine-tuned=true"
    } | sort -u -t= -k1,1 > "$merged_fm"

    if ! diff -q "$merged_fm" "$actual_fm" >/dev/null 2>&1; then
      local diff_output
      diff_output=$(diff -u "$merged_fm" "$actual_fm" 2>/dev/null | tail -n +4 || echo "(diff failed)")
      record_issue "$agent_name" "FRONTMATTER_INCONSISTENCY: AGENT.md frontmatter differs from expected merge result|File: ${agent_md}|Diff:|${diff_output}|Action: Run /lab ${agent_name} to regenerate and re-merge."
      issue_count=$((issue_count + 1))
    fi

    rm -f "$gen_fm" "$ovr_fm" "$actual_fm" "$merged_fm"
  fi

  return "$issue_count"
}

# Discover all agent directories
discover_agents() {
  local agents=()

  # gru
  if [[ -d "${SCRIPT_DIR}/gru" ]]; then
    agents+=("${SCRIPT_DIR}/gru")
  fi

  # nefario
  if [[ -d "${SCRIPT_DIR}/nefario" ]]; then
    agents+=("${SCRIPT_DIR}/nefario")
  fi

  # minions
  for minion_dir in "${SCRIPT_DIR}"/minions/*; do
    if [[ -d "$minion_dir" ]]; then
      agents+=("$minion_dir")
    fi
  done

  printf '%s\n' "${agents[@]}"
}

# Print detailed issues for an agent
print_agent_issues() {
  local agent_name="$1"
  local issues_file="${RESULTS_DIR}/${agent_name}.issues"

  if [[ ! -f "$issues_file" ]]; then
    return
  fi

  echo "=== ${agent_name} ==="
  echo ""

  while IFS= read -r issue; do
    # Parse issue format: TYPE: description|Field: value|...
    echo "$issue" | tr '|' '\n'
    echo ""
  done < "$issues_file"

  echo "---"
  echo ""
}

# Main validation logic
main() {
  local agents=()
  local has_drift=false
  local agent_list=()

  if [[ -n "$SINGLE_AGENT" ]]; then
    # Check single agent
    local agent_dir="${SCRIPT_DIR}/${SINGLE_AGENT}"
    if [[ ! -d "$agent_dir" ]]; then
      # Try minions subdirectory
      agent_dir="${SCRIPT_DIR}/minions/${SINGLE_AGENT}"
      if [[ ! -d "$agent_dir" ]]; then
        echo "Error: Agent directory not found: ${SINGLE_AGENT}" >&2
        exit $EXIT_ERROR
      fi
    fi

    agents=("$agent_dir")
  else
    # Discover all agents
    while IFS= read -r agent; do
      agents+=("$agent")
    done < <(discover_agents)
  fi

  # Check each agent
  for agent_dir in "${agents[@]}"; do
    local agent_name
    agent_name=$(basename "$agent_dir")
    agent_list+=("$agent_name")

    if check_agent "$agent_dir"; then
      : # Clean
    else
      has_drift=true
    fi
  done

  # Output results
  if [[ "$SUMMARY_ONLY" == true ]]; then
    # Summary-only output (for /lab integration)
    for agent_name in "${agent_list[@]}"; do
      local status
      local issue_count
      status=$(get_status "$agent_name")
      issue_count=$(get_issue_count "$agent_name")
      echo "${agent_name} ${status} ${issue_count}"
    done
  else
    # Full output with summary table and details
    if [[ -z "$SINGLE_AGENT" ]]; then
      # Print summary table
      printf "%-20s %-10s %s\n" "AGENT" "STATUS" "ISSUES"
      echo "-----------------------------------------"

      local drift_count=0
      for agent_name in "${agent_list[@]}"; do
        local status
        local issue_count
        status=$(get_status "$agent_name")
        issue_count=$(get_issue_count "$agent_name")

        printf "%-20s %-10s %s\n" "$agent_name" "$status" "$issue_count"

        if [[ "$status" == "DRIFT" ]]; then
          drift_count=$((drift_count + 1))
        fi
      done

      echo "-----------------------------------------"
      echo "TOTAL: ${#agent_list[@]} agents, ${drift_count} with drift"
      echo ""
    fi

    # Print detailed issues for agents with drift
    for agent_name in "${agent_list[@]}"; do
      local status
      status=$(get_status "$agent_name")
      if [[ "$status" == "DRIFT" ]]; then
        print_agent_issues "$agent_name"
      fi
    done
  fi

  # Exit with appropriate code
  if [[ "$has_drift" == true ]]; then
    exit $EXIT_DRIFT
  else
    exit $EXIT_CLEAN
  fi
}

main
