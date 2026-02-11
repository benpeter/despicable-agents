#!/usr/bin/env bash
#
# Portability test for install.sh: run install and uninstall with a
# mocked HOME directory (temp dir) and verify all expected symlinks
# are created and removed correctly.
#
# Uses a temporary HOME to avoid touching the real ~/.claude/.
#
# Usage:
#   ./tests/test-install-portability.sh
#
# Exit codes:
#   0 - All tests pass
#   1 - One or more tests fail

set -euo pipefail

# --- Configuration ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
INSTALL_SCRIPT="${REPO_ROOT}/install.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
  local name="$1"
  echo -e "${GREEN}PASS${NC} ${name}"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  local name="$1"
  local detail="$2"
  echo -e "${RED}FAIL${NC} ${name}"
  echo -e "  ${RED}${detail}${NC}"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

# --- Setup ---

FAKE_HOME=$(mktemp -d)
trap "rm -rf '$FAKE_HOME'" EXIT

AGENTS_DIR="${FAKE_HOME}/.claude/agents"
SKILLS_DIR="${FAKE_HOME}/.claude/skills"

# --- Discover expected agents ---

# Core agents (gru, nefario, lucy, margo)
EXPECTED_AGENTS=()
for agent in gru nefario lucy margo; do
  if [[ -f "${REPO_ROOT}/${agent}/AGENT.md" ]]; then
    EXPECTED_AGENTS+=("${agent}.md")
  fi
done

# Minions
for agent_file in "${REPO_ROOT}"/minions/*/AGENT.md; do
  if [[ -f "$agent_file" ]]; then
    local_name=$(basename "$(dirname "$agent_file")")
    EXPECTED_AGENTS+=("${local_name}.md")
  fi
done

EXPECTED_AGENT_COUNT=${#EXPECTED_AGENTS[@]}

echo -e "\n${YELLOW}Running install.sh portability tests${NC}"
echo -e "Discovered ${EXPECTED_AGENT_COUNT} agent AGENT.md files in repo\n"

# --- Sanity checks ---

echo -e "${YELLOW}--- Sanity Checks ---${NC}\n"

if [[ ! -f "$INSTALL_SCRIPT" ]]; then
  echo -e "${RED}ERROR: install.sh not found at ${INSTALL_SCRIPT}${NC}"
  exit 1
fi

if [[ ! -x "$INSTALL_SCRIPT" ]]; then
  echo -e "${RED}ERROR: install.sh is not executable${NC}"
  exit 1
fi

pass "install.sh exists and is executable"

# --- Test: Install ---

echo -e "\n${YELLOW}--- Install Test ---${NC}\n"

# Run install with mocked HOME
HOME="$FAKE_HOME" "$INSTALL_SCRIPT" install >/dev/null 2>&1

# Check agents directory was created
if [[ -d "$AGENTS_DIR" ]]; then
  pass "Agents directory created at \$HOME/.claude/agents/"
else
  fail "Agents directory creation" "Directory not found: ${AGENTS_DIR}"
fi

# Check skills directory was created
if [[ -d "$SKILLS_DIR" ]]; then
  pass "Skills directory created at \$HOME/.claude/skills/"
else
  fail "Skills directory creation" "Directory not found: ${SKILLS_DIR}"
fi

# Count installed agent symlinks
installed_count=0
missing_agents=()
for agent_link in "${EXPECTED_AGENTS[@]}"; do
  if [[ -L "${AGENTS_DIR}/${agent_link}" ]]; then
    installed_count=$((installed_count + 1))
  else
    missing_agents+=("$agent_link")
  fi
done

if [[ $installed_count -eq $EXPECTED_AGENT_COUNT ]]; then
  pass "All ${EXPECTED_AGENT_COUNT} agent symlinks created"
else
  fail "Agent symlink count" "Expected ${EXPECTED_AGENT_COUNT}, got ${installed_count}. Missing: ${missing_agents[*]}"
fi

# Verify the total matches the expected 27 (4 core + 23 minions)
# This is a soft check -- the count is discovered dynamically, but we
# record if it matches the documented 27-agent roster.
if [[ $EXPECTED_AGENT_COUNT -eq 27 ]]; then
  pass "Agent count matches documented roster (27)"
else
  fail "Agent roster count" "Expected 27 (4 core + 23 minions), discovered ${EXPECTED_AGENT_COUNT}"
fi

# Check nefario skill symlink
if [[ -L "${SKILLS_DIR}/nefario" ]]; then
  pass "Nefario skill symlink created"
else
  fail "Nefario skill symlink" "Not found at ${SKILLS_DIR}/nefario"
fi

# Check despicable-prompter skill symlink (may not exist yet if task #3 is pending)
if [[ -L "${SKILLS_DIR}/despicable-prompter" ]]; then
  pass "Despicable-prompter skill symlink created"
else
  # Check if the install script even has prompter support
  if grep -q "despicable-prompter" "$INSTALL_SCRIPT" 2>/dev/null; then
    fail "Despicable-prompter skill symlink" "install.sh supports it but symlink not created"
  else
    echo -e "${YELLOW}SKIP${NC} Despicable-prompter skill symlink (not yet in install.sh)"
  fi
fi

# --- Test: All symlinks point to valid files ---

echo -e "\n${YELLOW}--- Symlink Validity ---${NC}\n"

broken_links=()
for link in "${AGENTS_DIR}"/*.md; do
  if [[ -L "$link" ]]; then
    target=$(readlink "$link")
    if [[ ! -f "$target" ]]; then
      broken_links+=("$(basename "$link") -> $target")
    fi
  fi
done

# Check skill symlinks too
if [[ -L "${SKILLS_DIR}/nefario" ]]; then
  target=$(readlink "${SKILLS_DIR}/nefario")
  if [[ ! -d "$target" ]]; then
    broken_links+=("nefario skill -> $target")
  fi
fi

if [[ ${#broken_links[@]} -eq 0 ]]; then
  pass "All symlinks point to valid targets"
else
  fail "Broken symlinks found" "${broken_links[*]}"
fi

# --- Test: Symlinks point back to this repo ---

echo -e "\n${YELLOW}--- Symlink Ownership ---${NC}\n"

foreign_links=()
for link in "${AGENTS_DIR}"/*.md; do
  if [[ -L "$link" ]]; then
    target=$(readlink "$link")
    if [[ "$target" != "${REPO_ROOT}/"* ]]; then
      foreign_links+=("$(basename "$link") -> $target")
    fi
  fi
done

if [[ ${#foreign_links[@]} -eq 0 ]]; then
  pass "All agent symlinks point into this repo"
else
  fail "Foreign symlink targets" "${foreign_links[*]}"
fi

# --- Test: Uninstall ---

echo -e "\n${YELLOW}--- Uninstall Test ---${NC}\n"

HOME="$FAKE_HOME" "$INSTALL_SCRIPT" uninstall >/dev/null 2>&1

# Check that no agent symlinks remain
remaining_agents=()
for agent_link in "${EXPECTED_AGENTS[@]}"; do
  if [[ -L "${AGENTS_DIR}/${agent_link}" ]]; then
    remaining_agents+=("$agent_link")
  fi
done

if [[ ${#remaining_agents[@]} -eq 0 ]]; then
  pass "All agent symlinks removed after uninstall"
else
  fail "Agent symlinks remain" "${remaining_agents[*]}"
fi

# Check that nefario skill symlink is removed
if [[ -L "${SKILLS_DIR}/nefario" ]]; then
  fail "Nefario skill symlink remains" "Still present after uninstall"
else
  pass "Nefario skill symlink removed after uninstall"
fi

# Check that no symlinks at all remain in agents dir
remaining_any=0
if [[ -d "$AGENTS_DIR" ]]; then
  for link in "${AGENTS_DIR}"/*; do
    if [[ -L "$link" ]]; then
      remaining_any=$((remaining_any + 1))
    fi
  done
fi

if [[ $remaining_any -eq 0 ]]; then
  pass "No symlinks remain in agents directory after uninstall"
else
  fail "Leftover symlinks" "${remaining_any} symlink(s) remain in ${AGENTS_DIR}"
fi

# --- Test: Idempotent reinstall ---

echo -e "\n${YELLOW}--- Idempotent Reinstall ---${NC}\n"

# Install, then install again -- should not error
HOME="$FAKE_HOME" "$INSTALL_SCRIPT" install >/dev/null 2>&1
HOME="$FAKE_HOME" "$INSTALL_SCRIPT" install >/dev/null 2>&1

reinstall_count=0
for agent_link in "${EXPECTED_AGENTS[@]}"; do
  if [[ -L "${AGENTS_DIR}/${agent_link}" ]]; then
    reinstall_count=$((reinstall_count + 1))
  fi
done

if [[ $reinstall_count -eq $EXPECTED_AGENT_COUNT ]]; then
  pass "Idempotent reinstall: all ${EXPECTED_AGENT_COUNT} agent symlinks present"
else
  fail "Idempotent reinstall" "Expected ${EXPECTED_AGENT_COUNT}, got ${reinstall_count}"
fi

# Clean up for final state
HOME="$FAKE_HOME" "$INSTALL_SCRIPT" uninstall >/dev/null 2>&1

# --- Summary ---

echo ""
echo -e "${YELLOW}===========================================${NC}"
echo -e "  Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "  Failed: ${RED}${TESTS_FAILED}${NC}"
echo -e "${YELLOW}===========================================${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
  echo -e "\n${GREEN}All tests passed!${NC}\n"
  exit 0
else
  echo -e "\n${RED}Some tests failed.${NC}\n"
  exit 1
fi
