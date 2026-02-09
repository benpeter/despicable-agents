#!/usr/bin/env bash
#
# Test harness for validate-overlays.sh
#
# Runs validate-overlays.sh against synthetic test fixtures and verifies
# output matches expected results. Each fixture is a mock agent directory
# representing a specific validation scenario.
#
# Usage:
#   ./tests/run-tests.sh
#
# Exit codes:
#   0 - All tests pass
#   1 - One or more tests fail

set -euo pipefail

# Script directory (absolute path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures"
REPO_ROOT="${SCRIPT_DIR}/.."
VALIDATE_SCRIPT="${REPO_ROOT}/validate-overlays.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Print section header
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

# Print test result
print_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"

    if [[ "$result" == "PASS" ]]; then
        echo -e "${GREEN}✓ PASS${NC} ${test_name}"
        if [[ -n "$message" ]]; then
            echo -e "  ${message}"
        fi
    else
        echo -e "${RED}✗ FAIL${NC} ${test_name}"
        if [[ -n "$message" ]]; then
            echo -e "  ${RED}${message}${NC}"
        fi
    fi
}

# Parse expected.txt file
parse_expected() {
    local expected_file="$1"

    if [[ ! -f "$expected_file" ]]; then
        echo "ERROR: expected.txt not found in fixture" >&2
        return 1
    fi

    # Extract exit code
    EXPECTED_EXIT_CODE=$(grep "^exit_code:" "$expected_file" | cut -d: -f2 | xargs)

    # Extract patterns (lines starting with "  - ")
    EXPECTED_PATTERNS=()
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*-[[:space:]]\"(.*)\"$ ]]; then
            EXPECTED_PATTERNS+=("${BASH_REMATCH[1]}")
        fi
    done < "$expected_file"
}

# Clean up test agent directory (used by run_test and exit trap)
TEST_AGENT_DIR="${REPO_ROOT}/test-agent"
cleanup_test_agent() {
    rm -rf "${TEST_AGENT_DIR}"
}

# Ensure cleanup on unexpected exit
trap cleanup_test_agent EXIT

# Run test on a single fixture
run_test() {
    local fixture_name="$1"
    local fixture_dir="${FIXTURES_DIR}/${fixture_name}"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo ""
    echo -e "${YELLOW}Testing: ${fixture_name}${NC}"
    echo "---"

    # Parse expected results
    parse_expected "${fixture_dir}/expected.txt"

    # Clean up any leftover test-agent dir from a previous run
    cleanup_test_agent

    # Copy fixture into repo root where validate-overlays.sh resolves agent dirs
    # (validate-overlays.sh uses SCRIPT_DIR, its own location, to find agents)
    mkdir -p "${TEST_AGENT_DIR}"
    cp -r "${fixture_dir}"/* "${TEST_AGENT_DIR}/"

    # Run validate-overlays.sh against the test-agent
    local actual_exit_code=0
    local detail_output
    detail_output=$("${VALIDATE_SCRIPT}" test-agent 2>&1) || actual_exit_code=$?

    # Derive status from exit code (single-agent mode doesn't print CLEAN/DRIFT)
    local status_word
    if [[ "$actual_exit_code" -eq 0 ]]; then
        status_word="CLEAN"
    else
        status_word="DRIFT"
    fi

    # Clean up test agent directory
    cleanup_test_agent

    # Combine status line with detail output so all expected patterns are matchable
    local output="test-agent ${status_word}"$'\n'"${detail_output}"

    # Check exit code
    local exit_code_match=false
    if [[ "$actual_exit_code" -eq "$EXPECTED_EXIT_CODE" ]]; then
        exit_code_match=true
    fi

    # Check patterns
    local patterns_match=true
    local missing_patterns=()
    for pattern in "${EXPECTED_PATTERNS[@]}"; do
        if ! echo "$output" | grep -q "$pattern"; then
            patterns_match=false
            missing_patterns+=("$pattern")
        fi
    done

    # Determine overall result
    if $exit_code_match && $patterns_match; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        print_result "$fixture_name" "PASS" ""
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        local error_msg=""

        if ! $exit_code_match; then
            error_msg="Exit code mismatch: expected ${EXPECTED_EXIT_CODE}, got ${actual_exit_code}"
        fi

        if ! $patterns_match; then
            if [[ -n "$error_msg" ]]; then
                error_msg="${error_msg}\n  "
            fi
            error_msg="${error_msg}Missing patterns: ${missing_patterns[*]}"
        fi

        print_result "$fixture_name" "FAIL" "$error_msg"

        # Show output for failed tests
        echo ""
        echo "  Actual output:"
        echo "  ---"
        echo "$output" | sed 's/^/  /'
        echo "  ---"
    fi
}

# Main test execution
main() {
    print_header "validate-overlays.sh Test Suite"

    # Check that validate-overlays.sh exists
    if [[ ! -f "$VALIDATE_SCRIPT" ]]; then
        echo -e "${RED}ERROR: validate-overlays.sh not found at ${VALIDATE_SCRIPT}${NC}"
        echo "This script must be run after Task #2 (implementation) is complete."
        exit 2
    fi

    # Check that fixtures directory exists
    if [[ ! -d "$FIXTURES_DIR" ]]; then
        echo -e "${RED}ERROR: Fixtures directory not found at ${FIXTURES_DIR}${NC}"
        exit 2
    fi

    # List all fixtures
    local fixtures=()
    for dir in "${FIXTURES_DIR}"/*; do
        if [[ -d "$dir" ]]; then
            fixtures+=("$(basename "$dir")")
        fi
    done

    if [[ ${#fixtures[@]} -eq 0 ]]; then
        echo -e "${RED}ERROR: No fixtures found in ${FIXTURES_DIR}${NC}"
        exit 2
    fi

    echo "Found ${#fixtures[@]} test fixtures"
    echo ""

    # Run each test
    for fixture in "${fixtures[@]}"; do
        run_test "$fixture"
    done

    # Print summary
    print_header "Test Summary"

    echo "Total tests:  $TOTAL_TESTS"
    echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
    echo ""

    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

main
