# Domain Plan Contribution: devx-minion

## Recommendations

### Ledger Format: TSV with Optional Columns

**Recommendation: Tab-separated values (TSV) with positional columns.**

The ledger should remain a plain text file, one entry per line, with tab-separated fields:

```
<file_path>\t<agent_type>\t<agent_id>
```

When `agent_type` and `agent_id` are absent from the hook input (main session, no `--agent`), the fields are omitted entirely -- the line is just the bare file path with no trailing tabs. This makes the new format a strict superset of the old format: every existing ledger file is already a valid TSV ledger with zero metadata columns.

**Example ledger content:**

```
/Users/ben/project/src/auth.ts	security-minion	subagent-abc123
/Users/ben/project/src/header.tsx	frontend-minion	subagent-def456
/Users/ben/project/docs/README.md
/Users/ben/project/src/api.ts	api-minion	subagent-ghi789
```

**Why TSV over the alternatives:**

| Format | Pros | Cons |
|--------|------|------|
| **TSV** | Native bash parsing (`cut -f1`, `IFS=$'\t' read`), grep-compatible for path dedup, backward-compatible (bare paths are valid single-column TSV), no external deps | Tab in file path would break parsing (mitigated: tabs in paths are pathological and already unsupported by git) |
| **JSON Lines** | Structured, extensible, handles special chars | Requires jq for every read operation, existing `grep -qFx` dedup breaks, heavier to parse in bash |
| **Companion metadata file** | Zero change to existing ledger | Two files to keep in sync, race conditions on concurrent writes, more complex cleanup |

TSV is the right choice because the primary consumers are bash scripts that currently use `grep -qFx`, `while IFS= read`, and `cut`. TSV preserves these idioms with minimal modification. The path column stays in position 1, so `cut -f1` extracts it cleanly for any consumer that only needs paths.

### Backward Compatibility Strategy

The critical design constraint is that the **commit-point-check.sh** Stop hook and the **SKILL.md auto-commit flow** must both work correctly during the transition, including the case where an old-format ledger exists from a session that started before the upgrade.

**Rule: readers tolerate both formats; the writer always writes the new format.**

- **`commit-point-check.sh`**: Change `while IFS= read -r filepath` to `while IFS=$'\t' read -r filepath agent_type agent_id`. If `agent_type` is empty, it was a main-session write. The dedup logic (`grep -qFx`) needs adjustment -- see Proposed Tasks.
- **`track-file-changes.sh`**: Always writes TSV. If `agent_type`/`agent_id` are absent from the JSON input, writes just the bare path (no trailing tab).
- **SKILL.md auto-commit instructions**: The instructions reference "the change ledger" generically. The auto-commit reads file paths from the ledger to stage them. It needs to be aware that lines may have tab-separated metadata, so it should extract column 1 only.

### Deduplication Behavior Change

The current dedup in `track-file-changes.sh` uses `grep -qFx "$file_path"` to check if a path already exists. With TSV, the same file path can appear multiple times if written by different agents. This is actually **desirable** -- it captures the full attribution history.

**New dedup rule: deduplicate on the tuple `(file_path, agent_type)`, not just `file_path`.**

If the same agent writes the same file twice, skip it. If a different agent writes the same file, record both entries. The commit consumer resolves this by taking the *last* agent_type for each file_path (latest writer wins), which matches the real attribution -- the last agent to touch the file is the one whose changes are in the working tree.

### Error Handling and Graceful Degradation

The hook must never fail (PostToolUse hooks must exit 0). If jq cannot parse agent_type or agent_id, fall back to writing a bare path line. This ensures the file tracking functionality is never lost, even if the agent metadata extraction fails.

```bash
# Graceful fallback: if agent metadata extraction fails, record path only
local agent_type
agent_type=$(json_field "$input" '.agent_type')
local agent_id
agent_id=$(json_field "$input" '.agent_id')

if [[ -n "$agent_type" ]]; then
    local line="${file_path}\t${agent_type}\t${agent_id}"
else
    local line="$file_path"
fi
```

### Validation of agent_type

The `agent_type` value comes from the Claude Code runtime and should be a simple identifier string (e.g., `"frontend-minion"`, `"Explore"`, `"security-reviewer"`). However, since it flows into commit messages and shell variables, minimal validation is prudent:

1. Reject values containing newlines (same guard already applied to `file_path`).
2. Reject values containing tabs (would break TSV structure).
3. Length cap at 64 characters (no legitimate agent name is longer).
4. No need to validate against a known roster -- new agents should work without hook updates.

This validation is defensive, not security-critical (the value originates from the Claude Code platform, not user input). But it prevents malformed ledger entries from breaking downstream consumers.

## Proposed Tasks

### Task 1: Update `track-file-changes.sh` to capture agent metadata

**Scope:** Modify the PostToolUse hook to extract `agent_type` and `agent_id` from the JSON input and write TSV lines to the ledger.

**Changes:**
1. Add `agent_type` and `agent_id` extraction using `json_field`.
2. Add validation guards (no newlines, no tabs, length cap).
3. Change the write logic to produce TSV when agent metadata is present, bare path otherwise.
4. Update the dedup check from `grep -qFx "$file_path"` to a tuple-based dedup: `grep -qP "^${file_path}\t${agent_type}\t"` (or equivalent).
5. Update the file header comment to document the new format.

**Estimated size:** ~20 lines changed.

### Task 2: Update `commit-point-check.sh` to read TSV ledger

**Scope:** Modify the Stop hook to parse TSV lines and handle agent metadata.

**Changes:**
1. Change the ledger read loop from `IFS= read -r filepath` to `IFS=$'\t' read -r filepath agent_type agent_id`.
2. The dedup logic using `seen_paths` associative array already works on the path alone -- this is correct because for staging purposes, each file should appear once regardless of how many agents touched it.
3. Optionally: collect agent_type per file into a second associative array for use in the commit message hint. The Stop hook already generates a commit message suggestion (`<type>: <summary>`) -- it could include the agent scope if available.
4. If all changed files share the same `agent_type`, include it as the scope in the suggested commit message: `<type>(<agent-scope>): <summary>`.
5. If files span multiple agent types, omit the scope (current behavior) or use a generic scope like `multi`.

**Estimated size:** ~15 lines changed.

### Task 3: Update `docs/commit-workflow.md` Section 6

**Scope:** Update the Ledger Interface documentation to reflect the new TSV format.

**Changes:**
1. Update the format description from "one absolute file path per line" to "tab-separated values: file_path, agent_type (optional), agent_id (optional)".
2. Add an example showing mixed lines (with and without metadata).
3. Update the code example in the PostToolUse Hook subsection.
4. Note the backward compatibility: bare path lines (no tabs) remain valid.

**Estimated size:** ~20 lines of documentation.

### Task 4: Update SKILL.md auto-commit instructions

**Scope:** Update the nefario orchestration skill to use agent metadata from the ledger when generating commit messages.

**Changes:**
1. In the auto-commit instructions, note that ledger lines may contain tab-separated metadata.
2. When reading file paths for staging, extract column 1 only (`cut -f1` or equivalent).
3. When generating the commit message scope, prefer the agent_type from the ledger over heuristic inference. If all files in the commit share one agent_type, use its short form as the scope (strip `-minion` suffix for readability: `frontend-minion` becomes `frontend`).
4. Document the scope derivation precedence: ledger agent_type > task context > heuristic.

**Estimated size:** ~10 lines of SKILL.md changes.

## Risks and Concerns

### Risk 1: Active session ledger format mismatch (Medium)

If a user upgrades the hooks mid-session, the ledger may contain a mix of old-format (bare path) and new-format (TSV) lines. The readers must handle both.

**Mitigation:** The TSV design is inherently backward-compatible. A bare path is a valid single-column TSV line. The `IFS=$'\t' read -r filepath agent_type agent_id` pattern assigns empty strings to `agent_type` and `agent_id` when tabs are absent. No special migration logic needed.

### Risk 2: Dedup behavior change may increase ledger size (Low)

Changing dedup from per-path to per-tuple means the same file could appear multiple times if touched by different agents. In typical sessions, a file is written by one agent, so this is a marginal increase.

**Mitigation:** The ledger is session-scoped and cleaned up at session end. Even with duplicates, a ledger with hundreds of entries is negligible in size. The commit-point-check.sh already deduplicates by path when staging, so no downstream impact.

### Risk 3: grep pattern matching with special characters in agent_type (Low)

The dedup check uses grep with the agent_type value. If agent_type contains regex-special characters (`.`, `*`, `[`, etc.), the grep could match incorrectly.

**Mitigation:** Use `grep -F` (fixed string) for dedup, or use the associative array pattern already used in `commit-point-check.sh`. The `track-file-changes.sh` dedup could switch to an associative array approach if the grep becomes fragile. Alternatively, since agent names are controlled identifiers (alphanumeric + hyphens), regex-special characters are not expected.

### Risk 4: SKILL.md instructions are natural language, not code (Low)

The SKILL.md auto-commit flow is described in prose, not a script. Changes to the instructions must be carefully worded so Claude interprets them correctly. Ambiguous instructions could cause the LLM to misparse TSV lines or construct malformed commit messages.

**Mitigation:** Provide explicit examples in the updated instructions showing how to extract column 1 from a TSV line and how to derive the scope from agent_type. Examples are more reliable than abstract descriptions for LLM instruction-following.

### Risk 5: Scope proliferation in commit messages (Medium)

With 23 minion agents, the scope field in commit messages could have 23+ distinct values. This may reduce the usefulness of `git log --oneline` scanning if readers do not know the agent taxonomy.

**Mitigation:** This is primarily a UX concern (defer to ux-strategy-minion's input). From a DX perspective, the scope values should be short, memorable, and map to domains developers already think about. Stripping the `-minion` suffix helps: `frontend`, `security`, `api` are self-explanatory. The meta-plan's optional gate on commit message format is the right place to finalize this.

## Additional Agents Needed

No additional agents beyond those already identified in the meta-plan. The consultations cover all relevant domains:

- **security-minion**: Validates that agent_type/agent_id extraction does not introduce injection vectors in the TSV ledger or commit messages.
- **ux-strategy-minion**: Reviews whether per-agent scopes in commit messages help or hinder git log readability.
- **test-minion**: Plans minimal test strategy for the modified hooks.
- **software-docs-minion**: Identifies all documentation that needs updating.
- **ai-modeling-minion**: Plans the commit attribution semantics (scope naming, Co-Authored-By format).

The devx-minion's role here is the ledger format and hook implementation -- the interface design. The other agents handle the content that flows through that interface (security validation, naming semantics, documentation, testing).
