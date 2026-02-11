#!/usr/bin/env bash
#
# Static regression test: scan deployable toolkit files for hardcoded
# self-referential paths that couple the nefario skill to the
# despicable-agents repo layout.
#
# This test FAILS against the pre-decoupling codebase (it documents
# what needs to change). After decoupling, it should PASS.
#
# Usage:
#   ./tests/test-no-hardcoded-paths.sh              # expect pass (post-decoupling)
#   ./tests/test-no-hardcoded-paths.sh --expect-fail # invert exit code (pre-decoupling)
#
# Exit codes:
#   0 - All checks pass (or --expect-fail and checks did fail as expected)
#   1 - One or more checks fail (or --expect-fail and checks unexpectedly passed)

set -euo pipefail

# --- Configuration ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}/.."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse flags
EXPECT_FAIL=false
if [[ "${1:-}" == "--expect-fail" ]]; then
  EXPECT_FAIL=true
fi

# Files to scan (deployable toolkit files only)
SCAN_FILES=(
  "${REPO_ROOT}/skills/nefario/SKILL.md"
  "${REPO_ROOT}/nefario/AGENT.md"
)

# --- Test framework ---

TOTAL_CHECKS=0
FAILED_CHECKS=0
FINDINGS=()

pass() {
  local name="$1"
  echo -e "${GREEN}PASS${NC} ${name}"
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

fail() {
  local name="$1"
  local detail="$2"
  echo -e "${RED}FAIL${NC} ${name}"
  echo -e "  ${RED}${detail}${NC}"
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

# Scan a file for a grep pattern. Returns 0 if the pattern is NOT found (clean).
# Records findings when the pattern IS found.
check_pattern() {
  local label="$1"
  local pattern="$2"
  local file="$3"
  local basename
  basename=$(basename "$file")

  if [[ ! -f "$file" ]]; then
    pass "${label} (${basename}): file not found, nothing to scan"
    return
  fi

  local matches
  matches=$(grep -n "$pattern" "$file" 2>/dev/null || true)

  if [[ -z "$matches" ]]; then
    pass "${label} (${basename})"
  else
    local count
    count=$(echo "$matches" | wc -l | tr -d ' ')
    fail "${label} (${basename})" "Found ${count} occurrence(s):"
    echo "$matches" | while IFS= read -r line; do
      echo -e "    ${YELLOW}${basename}:${line}${NC}"
    done
    FINDINGS+=("${label} in ${basename}")
  fi
}

# --- Hardcoded Path Checks ---

echo -e "\n${YELLOW}Scanning deployable toolkit files for hardcoded paths${NC}\n"

for file in "${SCAN_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo -e "${YELLOW}SKIP${NC} $(basename "$file"): file not found"
    continue
  fi

  echo -e "${YELLOW}--- $(basename "$file") ---${NC}\n"

  # Pattern 1: nefario/scratch/ -- hardcoded scratch path (should become $TMPDIR-based)
  check_pattern "Hardcoded scratch path (nefario/scratch/)" \
    'nefario/scratch/' "$file"

  # Pattern 2: docs/history/nefario-reports/TEMPLATE.md -- hardcoded template reference
  check_pattern "Hardcoded template reference (TEMPLATE.md)" \
    'docs/history/nefario-reports/TEMPLATE\.md' "$file"

  # Pattern 3: docs/commit-workflow.md -- hardcoded commit workflow reference
  check_pattern "Hardcoded commit-workflow reference" \
    'docs/commit-workflow\.md' "$file"

  # Pattern 4: the-plan.md references in skill files (internal project artifact)
  check_pattern "Internal artifact reference (the-plan.md)" \
    'the-plan\.md' "$file"

  echo ""
done

# --- Report Directory Detection Priority Test ---

echo -e "${YELLOW}--- Report directory detection priority ---${NC}\n"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

TMPDIR_TEST=$(mktemp -d)
trap "rm -rf '$TMPDIR_TEST'" EXIT

# Create both directory conventions
mkdir -p "${TMPDIR_TEST}/docs/nefario-reports"
mkdir -p "${TMPDIR_TEST}/docs/history/nefario-reports"

# Simulate the detection priority logic that the decoupled code should use:
# 1. docs/nefario-reports/ (newer convention, takes priority)
# 2. docs/history/nefario-reports/ (legacy convention, fallback)
detect_report_dir() {
  local base="$1"
  if [[ -d "${base}/docs/nefario-reports" ]]; then
    echo "${base}/docs/nefario-reports"
  elif [[ -d "${base}/docs/history/nefario-reports" ]]; then
    echo "${base}/docs/history/nefario-reports"
  else
    echo ""
  fi
}

detected=$(detect_report_dir "$TMPDIR_TEST")
expected="${TMPDIR_TEST}/docs/nefario-reports"

if [[ "$detected" == "$expected" ]]; then
  pass "Detection selects docs/nefario-reports/ over docs/history/nefario-reports/"
else
  fail "Detection priority" "Expected: $expected, Got: $detected"
fi

# Test fallback when only legacy exists
rm -rf "${TMPDIR_TEST}/docs/nefario-reports"
detected_fallback=$(detect_report_dir "$TMPDIR_TEST")
expected_fallback="${TMPDIR_TEST}/docs/history/nefario-reports"

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ "$detected_fallback" == "$expected_fallback" ]]; then
  pass "Fallback to docs/history/nefario-reports/ when newer dir absent"
else
  fail "Detection fallback" "Expected: $expected_fallback, Got: $detected_fallback"
fi

# Test no directory found
rm -rf "${TMPDIR_TEST}/docs/history/nefario-reports"
detected_none=$(detect_report_dir "$TMPDIR_TEST")

TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
if [[ -z "$detected_none" ]]; then
  pass "Returns empty when no report directory exists"
else
  fail "Detection empty case" "Expected empty, Got: $detected_none"
fi

# --- Summary ---

echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "  Total checks: ${TOTAL_CHECKS}"
echo -e "  Passed:       ${GREEN}$((TOTAL_CHECKS - FAILED_CHECKS))${NC}"
echo -e "  Failed:       ${RED}${FAILED_CHECKS}${NC}"
echo -e "${YELLOW}===========================================${NC}"

# Determine exit code
if [[ $FAILED_CHECKS -eq 0 ]]; then
  if $EXPECT_FAIL; then
    echo -e "\n${RED}UNEXPECTED: All checks passed but --expect-fail was set.${NC}"
    echo -e "${RED}This means the hardcoded paths have been removed already.${NC}\n"
    exit 1
  else
    echo -e "\n${GREEN}All checks passed! No hardcoded paths found.${NC}\n"
    exit 0
  fi
else
  if $EXPECT_FAIL; then
    echo -e "\n${GREEN}Expected failures confirmed (--expect-fail mode).${NC}"
    echo -e "Found ${FAILED_CHECKS} hardcoded path pattern(s) to decouple.\n"
    exit 0
  else
    echo -e "\n${RED}Hardcoded paths detected. These must be decoupled.${NC}\n"
    exit 1
  fi
fi
