# Test-Minion Review: despicable-statusline skill

## Verdict: ADVISE

## Analysis

The deliverable is a SKILL.md file (a system prompt for Claude Code, not executable code). The plan correctly excludes automated testing and states: "There is no test harness for Claude Code skill prompts."

However, the verification strategy relies solely on manual invocation and has gaps.

## Recommendations

### 1. Add Structured Manual Verification Plan

The plan includes 4 verification steps but they are minimal. Expand to cover all four workflow states:

**Add to verification steps:**

- **State A test** (no statusLine): Remove `.statusLine` from test settings.json, invoke skill, verify default command was written, parse JSON to confirm structure
- **State B test** (inline without nefario): Set a custom command ending in `echo "$result"`, invoke skill, verify snippet was inserted before final echo
- **State C test** (idempotency): Already covered in step 3
- **State D test** (non-standard): Set command to script path or command without `echo "$result"`, invoke skill, verify manual instructions are shown and no modification occurred

Each test should include validation of backup creation and JSON integrity post-modification.

### 2. Add Error Path Verification

The plan describes error handling (invalid JSON, validation failure, rollback) but verification steps don't test these paths. Add:

- **Invalid JSON recovery**: Corrupt settings.json, invoke skill, verify error message and that backup is not corrupted
- **jq availability check**: If possible, test on system without jq (or temporarily rename jq binary) to verify graceful error message

### 3. Reference Implementation Testing Pattern

Since this follows the pattern of existing skills (`session-review`, `obsidian-tasks`, `despicable-prompter`), verification should confirm behavioral consistency:

- **Pattern check**: After creation, compare SKILL.md structure against reference skills to confirm it follows the established pattern (YAML frontmatter, imperative workflow, no confirmation prompts)

### 4. Document Expected Behavior

The verification steps should document expected output for each test case, not just "confirm it works". For example:

**Step 3 expected output:**
```
Status line already includes nefario status. No changes made.
```

This makes verification mechanical rather than interpretive.

## Non-blocking Concerns

The plan states verification will be done on "current machine (which already has the nefario snippet)" for idempotency testing. This is good but insufficient. The plan should specify testing State A and State B on a clean or test settings.json file to avoid only verifying the no-op path.

The optional verification step (State A test) should be mandatory for complete coverage, not optional.

## Conclusion

The exclusion of automated testing is correct for this artifact type. The manual verification steps exist but need expansion to cover all workflow states, error paths, and expected outputs. This is a non-blocking issue since the deliverable is low-risk (local config modification with backup/rollback) and easily reversible.

Add structured manual verification checklist covering all states and error paths to increase confidence before considering the task complete.
