## Verdict: ADVISE

The 23 test cases are well-structured and cover the core scenarios correctly. Execution order is sound (Task 3 blocked by Tasks 1 and 2, so tests run against final code). The self-contained bash approach is appropriate for this project. Three gaps worth flagging.

---

### ADVISE 1

**SCOPE**: Test 10-12 (deduplication), and the test script implementation itself.

**CHANGE**: Add a test that verifies a file path containing a tab character is rejected or handled safely. Also, the dedup logic in Task 1 uses `grep -qF "$prefix"` where `prefix=$(printf '%s\t%s' "$file_path" "$agent_type")`. The tab is a literal character inside a `$()` subshell -- this works correctly in bash. But there is no test that a file_path containing a tab would corrupt the TSV format. The current `track-file-changes.sh` only rejects newlines in file_path, not tabs. A path like `/tmp/foo\tbar` would produce a malformed 4-column TSV line.

**WHY**: The task spec says "validate: reject paths with newlines" but is silent on tab characters in file_path. Tab is the delimiter. A tab in file_path would silently corrupt the entire ledger format, and the dedup logic using `grep -qF "$prefix"` would not detect the collision.

**TASK**: In the Task 3 prompt, add test case: file_path containing a literal tab character -- expect no entry written (or bare path fallback), exit 0. In Task 1, add a tab-rejection check alongside the newline check:
```bash
if [[ "$file_path" == *$'\t'* ]]; then
    exit 0
fi
```

---

### ADVISE 2

**SCOPE**: Tests 17-23 (commit-point-check.sh tests).

**CHANGE**: The current commit-point-check.sh reads the ledger at line 171 with `while IFS= read -r filepath` (not TSV-aware). Task 2 changes this to `IFS=$'\t' read -r filepath agent_type agent_id`. The test script for tests 17-23 must create a temp git repo with at least one file that has actual git-tracked changes, or the hook will exit 0 at the "no git changes" filter (lines 196-204). The synthesis plan says "create a temp git repo with git init + initial commit + test-branch" but does not specify that the test files in the ledger must also be tracked and modified in that repo. If the ledger contains `/tmp/test-repo/somefile.txt` but that file has no git diff, the hook silently exits 0 and tests 17-23 will see no output to assert against.

**WHY**: The commit-point-check.sh has multiple early-exit paths before reaching the scope/trailer output: nefario status file check, sensitive-patterns file check, existence check, git-diff check, auto-defer (all .md, <5 lines). Tests that do not control for all of these will produce false passes when the hook exits 0 for the wrong reason.

**TASK**: In the Task 3 prompt, add explicit setup instructions for commit-point-check.sh tests: the temp git repo must contain a non-.md file that is written, staged (or unstaged), and tracked. The sensitive-patterns file must exist and be readable from the repo root. The nefario status file must not exist. Recommend the test runner `cd` into the temp git repo before invoking the hook so `git` commands resolve correctly.

---

### ADVISE 3

**SCOPE**: Tests 21 (majority-wins), test script counter pattern.

**CHANGE**: There is no test for a tie in majority-wins (equal files from two agents). The commit-point-check.sh Task 2 prompt's majority-wins loop iterates `${!agent_counts[@]}` -- bash associative array iteration order is undefined. A tie produces a non-deterministic scope. This is an edge case the feature description does not address, and no test will catch it because only "clear majority" is tested. Additionally, the test script will use pass/fail counters. Per the project memory, `((TESTS_PASSED++))` triggers `set -e` exit when the value is 0 (the increment evaluates to 0, which bash treats as false). Use `TESTS_PASSED=$((TESTS_PASSED + 1))` throughout the test script.

**WHY**: Tie-breaking non-determinism is a silent correctness bug -- commits from balanced two-agent sessions will have unpredictably different scopes. The counter pattern issue would cause the test script to exit after the first passing test, producing misleading output.

**TASK**: (1) In the Task 3 prompt, add test case 24: two agents with equal file counts -- expect scope to be one of the valid agent domain names (not empty, not an error). Document in the test that tie-breaking is undefined but the output must be a valid scope. (2) In the Task 3 prompt, add an explicit note: "Use `TESTS_PASSED=$((TESTS_PASSED + 1))` not `((TESTS_PASSED++))` to avoid `set -e` exit on zero."
