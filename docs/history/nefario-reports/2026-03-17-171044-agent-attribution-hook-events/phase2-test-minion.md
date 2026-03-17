# Test Strategy for Hook Modifications (agent_id/agent_type)

## Recommendation: Lightweight Bash Test Script (No bats-core)

### Why Not bats-core

bats-core is not installed on this machine, the project has zero existing test infrastructure, and the project philosophy (Helix Manifesto: lean and mean, minimize dependencies) strongly argues against adding a test framework for two shell scripts. The hooks are ~70 and ~360 lines of bash respectively -- well within the range where a self-contained bash test script provides full coverage without framework overhead.

### Why Not Manual Verification Only

Manual verification is insufficient here for three reasons:

1. **The changes touch safety-critical logic.** The hooks gate commit behavior -- mis-extracting `agent_id` could silently produce wrong commit attribution with no visible error (the ERR trap in `track-file-changes.sh` swallows failures). This is the class of bug that manual testing misses because the happy path works fine while edge cases silently degrade.

2. **The input contract is external and unstable.** The `agent_id`/`agent_type` fields come from Claude Code's hook event JSON -- a format the project does not control. When Claude Code changes its schema (and it will -- these fields were just added in 2.1.69), a regression test that pipes known JSON into the hook and checks output catches breakage immediately. Manual testing requires someone to remember to test edge cases after every Claude Code update.

3. **The hooks are pure functions of their input.** Both hooks read JSON from stdin and produce side effects (files on disk). This makes them trivially testable: pipe JSON in, check file output. The effort to write tests is low, the maintenance cost is near zero, and the value is high.

### Proposed Test Approach

A single bash test script at `.claude/hooks/test-hooks.sh` that:

- Creates an isolated temp directory per test run
- Mocks the git environment where needed (for `commit-point-check.sh`)
- Pipes crafted JSON payloads into each hook via stdin
- Asserts on file contents (ledger file), exit codes, and stderr output
- Cleans up completely afterward
- Uses the pass/fail counter pattern (no external dependencies)

This follows the project's existing bash scripting style (see `install.sh`) and the test organization pattern from agent memory.

## Test Cases for agent_id / agent_type Extraction

### Track-file-changes.sh (PostToolUse hook)

The primary change is extracting `agent_id` and `agent_type` from the hook event JSON and recording them in the ledger alongside the file path for downstream commit attribution.

**Core extraction tests:**

| # | Test Case | Input | Expected Behavior |
|---|-----------|-------|-------------------|
| 1 | Both fields present | `{"agent_id":"frontend-minion","agent_type":"agent","tool_input":{"file_path":"/tmp/test.txt"}}` | Ledger entry includes agent_id and agent_type |
| 2 | agent_type present, agent_id absent | `{"agent_type":"agent","tool_input":{"file_path":"/tmp/test.txt"}}` | Ledger entry records agent_type; agent_id falls back to default/empty |
| 3 | agent_id present, agent_type absent | `{"agent_id":"frontend-minion","tool_input":{"file_path":"/tmp/test.txt"}}` | Ledger entry records agent_id; agent_type falls back to default/empty |
| 4 | Neither field present | `{"tool_input":{"file_path":"/tmp/test.txt"}}` | Ledger entry written (backward compatible), attribution fields empty/default |
| 5 | Fields are null | `{"agent_id":null,"agent_type":null,"tool_input":{"file_path":"/tmp/test.txt"}}` | Same as absent -- treated as empty |
| 6 | Fields are empty strings | `{"agent_id":"","agent_type":"","tool_input":{"file_path":"/tmp/test.txt"}}` | Same as absent -- treated as empty |
| 7 | agent_id with special characters | `{"agent_id":"my/agent name","agent_type":"agent","tool_input":{"file_path":"/tmp/test.txt"}}` | Handles slashes, spaces without breaking ledger format |
| 8 | Unexpected agent_type value | `{"agent_id":"x","agent_type":"something_new","tool_input":{"file_path":"/tmp/test.txt"}}` | Records the value as-is (don't whitelist, just pass through) |

**Existing behavior preservation tests (regression):**

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 9 | file_path extraction still works | Path appears in ledger |
| 10 | Empty file_path exits 0 | No ledger entry, clean exit |
| 11 | Path with newlines exits 0 | Injection prevented, no ledger entry |
| 12 | Deduplication still works | Same path written twice, appears once in ledger |
| 13 | Session ID from JSON | Ledger filename uses session_id from input |
| 14 | Session ID from env var | Falls back to CLAUDE_SESSION_ID when not in JSON |
| 15 | Hook always exits 0 | Even on jq parse failure, exit code is 0 |

### Commit-point-check.sh (Stop hook)

The change here is reading the enriched ledger (which now may include agent attribution metadata) and using it to construct per-agent commit messages or attribution in the commit checkpoint output.

**Attribution in commit output tests:**

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 16 | Ledger with agent_id metadata | Commit checkpoint message includes agent attribution |
| 17 | Ledger with mixed attribution (some entries have agent_id, some don't) | Handles mixed entries gracefully |
| 18 | Ledger in legacy format (no attribution columns) | Backward compatible -- works as before |

**Existing behavior preservation tests (regression):**

| # | Test Case | Expected Behavior |
|---|-----------|-------------------|
| 19 | Protected branch blocks commit | Exit 2 with branch warning on main/master |
| 20 | Sensitive file filtering still works | Matching files excluded from staging instructions |
| 21 | Empty ledger exits 0 | No checkpoint presented |
| 22 | Nefario status file suppresses hook | Exit 0 when nefario status file exists |
| 23 | Infinite loop protection | stop_hook_active=true causes exit 0 |

## Ledger Format Decision (Affects Test Design)

The test design depends on how agent attribution is encoded in the ledger. Two options:

**Option A -- Structured ledger lines (tab-separated):**
```
/path/to/file\tagent_id\tagent_type
```
Pro: All data in one place. Con: Breaks backward compatibility with `grep -qFx` deduplication (existing code searches for exact full-line match).

**Option B -- Separate attribution sidecar file:**
```
# Ledger: /tmp/claude-change-ledger-<session>.txt (unchanged)
/path/to/file

# Attribution: /tmp/claude-change-attribution-<session>.json
{"agent_id":"frontend-minion","agent_type":"agent","file_path":"/path/to/file","timestamp":"..."}
```
Pro: Ledger format unchanged, zero backward-compatibility risk. Con: Two files to manage.

**Option C -- JSON ledger (one JSON object per line, JSONL):**
```
{"file_path":"/path/to/file","agent_id":"frontend-minion","agent_type":"agent"}
```
Pro: Extensible, structured. Con: Requires rewriting all ledger reads/writes, grep dedup needs rewrite.

**Recommendation:** Option A (tab-separated) is the simplest change if backward compatibility with an empty ledger is handled. But Option B (sidecar) is the safest if the executing implementer wants zero risk to existing ledger logic. The test script should validate whichever format is chosen.

## Risks and Dependencies

1. **jq dependency.** Both hooks already depend on `jq` for JSON parsing. The new fields add no new dependency, but the test script should verify `jq` is available and skip with a clear message if not.

2. **Claude Code schema stability.** The `agent_id`/`agent_type` fields were added in 2.1.69. If Claude Code changes the field names or nesting in a future version, the extraction will silently produce empty values (due to `// empty` fallback). Tests should assert on current schema and make schema assumptions explicit so they serve as canary tests.

3. **Ledger format migration.** If the ledger format changes (per the options above), the `commit-point-check.sh` must handle both old-format and new-format ledger files during the transition (a session that started before the upgrade may have old-format entries). Test this explicitly.

4. **ERR trap masking failures.** The `track-file-changes.sh` hook has `trap 'exit 0' ERR`. Any bug in `agent_id` extraction will be silently swallowed. The test script is the only safety net for catching extraction bugs -- this makes the tests load-bearing, not optional.

## Effort Estimate

- Test script creation: ~1 hour
- 15-23 test cases (depending on which ledger format is chosen)
- No external dependencies required
- Runs in <5 seconds
- One-time cost, near-zero maintenance

## What I Am NOT Recommending

- **No CI integration.** This project has no CI pipeline and adding one for two hook scripts violates YAGNI.
- **No bats-core or shunit2.** Adding a bash test framework for this scope is overhead without payoff.
- **No mocking of the full Claude Code runtime.** The hooks are designed to be testable via stdin pipe -- use that interface directly.
- **No load/performance testing.** The hooks run on single file operations with a 5-10 second timeout. Performance is not a concern.
