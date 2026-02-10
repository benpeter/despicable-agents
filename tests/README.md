# Overlay Validation Test Suite

Test fixtures and harness for `validate-overlays.sh`, the overlay drift detection script.

## Structure

```
tests/
  run-tests.sh           # Test harness (bash script)
  README.md              # This file
  fixtures/              # Synthetic test fixtures
    clean-no-overlay/    # Agent with no overrides (PASS)
    clean-with-overlay/  # Agent with clean merge (PASS)
    stale-merge/         # AGENT.md doesn't reflect current merge (FAIL)
    orphan-override/     # Override section not in generated (FAIL)
    missing-overrides-file/    # x-fine-tuned but no overrides file (FAIL)
    inconsistent-flag/   # Overrides file but no x-fine-tuned flag (FAIL)
    non-overlay-mismatch/      # No overrides, files differ (FAIL)
    fenced-code-h2/      # H2 in code block shouldn't cause issues (PASS)
    frontmatter-mismatch/      # Merged frontmatter incorrect (FAIL)
    pre-overlay-agent/   # Legacy agent without AGENT.generated.md (PASS)
```

## Running Tests

```bash
# Run all tests
./tests/run-tests.sh

# Script must be run after validate-overlays.sh is implemented (Task #2)
```

## Test Fixtures

Each fixture is a minimal synthetic agent directory containing:

- `AGENT.generated.md` (optional) - Generated baseline
- `AGENT.overrides.md` (optional) - Hand-tuned customizations
- `AGENT.md` - Deployed agent file
- `expected.txt` - Expected validation results

### Fixture Format

Each `expected.txt` file defines:

```yaml
exit_code: 0|1|2
patterns:
  - "STRING_TO_MATCH_IN_OUTPUT"
  - "ANOTHER_PATTERN"
```

The test harness verifies:
1. Exit code matches expected
2. All patterns appear in script output

## Exit Codes

- `0` - All tests pass
- `1` - One or more tests fail
- `2` - Test harness error (script not found, etc.)

## Validation Scenarios Tested

| Fixture | Scenario | Expected |
|---------|----------|----------|
| `clean-no-overlay` | No overrides, files match | PASS |
| `clean-with-overlay` | Overrides present, merge clean | PASS |
| `stale-merge` | AGENT.md doesn't match computed merge | FAIL (MERGE_STALENESS) |
| `orphan-override` | Override section not in generated | FAIL (ORPHAN_OVERRIDE) |
| `missing-overrides-file` | x-fine-tuned flag but no file | FAIL (MISSING_OVERRIDES_FILE) |
| `inconsistent-flag` | Overrides file but no flag | FAIL (INCONSISTENT_FLAG) |
| `non-overlay-mismatch` | No overrides but files differ | FAIL (NON_OVERLAY_MISMATCH) |
| `fenced-code-h2` | H2 heading inside code block | PASS (no false positive) |
| `frontmatter-mismatch` | Merged frontmatter incorrect | FAIL (FRONTMATTER_INCONSISTENCY) |
| `pre-overlay-agent` | Legacy agent (no .generated) | PASS |

## Adding New Fixtures

1. Create directory under `tests/fixtures/<name>/`
2. Add minimal AGENT files representing the scenario
3. Create `expected.txt` with expected exit code and output patterns
4. Run `./tests/run-tests.sh` to verify

Keep fixtures minimal - just enough to trigger the validation scenario. Use synthetic content, not real agent data.

## Integration

This test suite is standalone. Once `validate-overlays.sh` is implemented and passes all tests, it will be integrated into the `/despicable-lab` skill for continuous validation.

See `/Users/ben/github/benpeter/despicable-agents/docs/validate-overlays-spec.md` for full validation specification.
