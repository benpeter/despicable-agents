# Security Review: Agent Attribution via Hook Events

## Verdict: ADVISE

The plan is sound and my prior recommendations (regex validation, file permission hardening, sidecar rejection) are correctly incorporated. Two residual issues need attention before execution.

---

### ADVISE 1: session_id injection into ledger filename is unvalidated

- **SCOPE**: Task 1 (`track-file-changes.sh`) -- session_id extraction
- **CHANGE**: Add regex validation for `session_id` matching `^[a-zA-Z0-9_-]{1,128}$` before using it in the ledger path, parallel to the agent_type/agent_id validation the plan already specifies. Currently the script uses `session_id` raw in `/tmp/claude-change-ledger-${session_id}.txt` with no sanitization. A malformed `session_id` (e.g. containing `..`, `/`, or shell metacharacters) could produce a path outside `/tmp` or enable symlink traversal. The Task 1 prompt does not include this validation step.
- **WHY**: The plan correctly requires regex validation for `agent_type` and `agent_id` but omits the same treatment for `session_id`, which flows into a filesystem path construction. Path traversal via session_id is a lower-probability vector given that the value comes from Claude Code itself, but the existing code already documents this concern ("Validate: reject paths with newlines") and the new code should be consistent.
- **TASK**: In the Task 1 prompt (or as a devx-minion implementation note), add: after extracting `session_id`, validate it with `^[a-zA-Z0-9_-]{1,128}$`; if invalid, fall back to `"default"`. The ledger path must remain under `/tmp`.

---

### ADVISE 2: grep -F dedup check uses literal tab in prefix -- shell quoting brittle

- **SCOPE**: Task 1 (`track-file-changes.sh`) -- deduplication logic
- **CHANGE**: The synthesis plan recommends constructing the dedup prefix with `printf '%s\t%s' "$file_path" "$agent_type"` and passing it to `grep -qF`. This is correct, but the Task 1 prompt also includes an earlier `\t`-in-double-quotes example (`local line="${file_path}\t${agent_type}"`) that would produce a literal backslash-t, not a tab. Devx-minion may produce a mixed implementation where the `printf` path is right but a naive reading of the surrounding prose produces broken dedup. The prompt is internally inconsistent on this point.
- **WHY**: If dedup produces false negatives (prefix not matched because it contains `\t` instead of a real tab), the same file-agent pair gets written multiple times to the ledger. This is a correctness issue, not a security issue per se, but corrupted ledger state could allow a crafted agent_type to produce grep -F anchor mismatches, weakening the dedup guarantee.
- **TASK**: Clarify the Task 1 prompt to explicitly state: use `printf '%s\t%s' ...` exclusively for constructing both written lines and dedup prefixes; never construct TSV with double-quoted `\t` in a variable assignment. Add a test case to Task 3 (test-hooks.sh) verifying that dedup correctly matches tab-separated lines (not backslash-t).

---

### Already Addressed (no action needed)

- Regex validation on `agent_type` / `agent_id`: adopted, correctly specified in Task 1.
- File permission hardening (`install -m 0600`): adopted, correctly specified in Task 1.
- `agent_type` must not be used for authorization: explicitly called out in Task 1 ("Do NOT use `agent_type` for any authorization or access control decision") and documented in Task 5 security doc update.
- git trailer injection: the regex `^[a-zA-Z0-9_-]{1,64}$` allows no colon, space, or newline, which are the three characters that would allow trailer injection or trailer-format bypass. Safe.
- Temp file race on ledger creation: `install -m 0600 /dev/null "$ledger"` is atomic enough for this threat model (single-user local session). Acceptable.
- ERR trap masking bugs: acknowledged in plan's Risk 3, mitigated by test script. Acceptable.
