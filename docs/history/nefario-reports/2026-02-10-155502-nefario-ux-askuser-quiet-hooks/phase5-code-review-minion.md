# Code Review Findings: nefario-ux-askuser-quiet-hooks

**Reviewer**: code-review-minion
**Date**: 2026-02-10

## VERDICT: APPROVE

All changes are correct, well-structured, and production-ready. Implementation is clean with good test coverage. No blocking or advisory issues found.

## FINDINGS

### Overall Quality

The implementation successfully converts four freeform decision points to structured AskUserQuestion patterns while adding orchestrated-session marker lifecycle management to suppress hook noise during nefario execution.

**Strengths**:
- Clean separation of concerns: hook suppression logic isolated in single guard clause
- Consistent marker lifecycle: creation at Phase 4 start, cleanup at wrap-up
- Good test coverage: new test for marker suppression + teardown cleanup added
- Natural language AskUserQuestion specs avoid tight coupling to tool schemas
- Documentation updated appropriately in commit-workflow.md

**Code Quality Metrics**:
- No complexity issues detected
- No code duplication (DRY principle maintained)
- Clear, readable implementation across all files
- Proper error handling in shell scripts

### File-by-File Assessment

#### 1. `.claude/hooks/commit-point-check.sh`

**Lines 139-143**: Orchestrated-session marker guard

```bash
# --- Orchestrated session? Exit silently ---
local orchestrated_marker="/tmp/claude-commit-orchestrated-${session_id}"
if [[ -f "$orchestrated_marker" ]]; then
    exit 0
fi
```

**NIT**: Pre-existing shellcheck warning at line 78 (SC2053: quote glob pattern in RHS of `==`). Not introduced by this change, but consider addressing in a follow-up cleanup pass.

**Assessment**: Correct implementation. Placement is appropriate (after declined/defer checks, before sensitive patterns check). Variable naming is consistent with existing marker patterns.

#### 2. `skills/nefario/SKILL.md`

**Lines 408-410**: Marker creation instruction

```
After branch resolution (whether creating a new branch or using an existing one),
create the orchestrated-session marker to suppress commit hook noise:
`touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`
```

**Assessment**: Clear instruction placement. Uses correct CLAUDE_SESSION_ID variable (environment variable, not shell substitution). Timing is appropriate (immediately after branch setup, before any execution tasks).

**Lines 457-508**: Approval gate AskUserQuestion conversion

**Assessment**: Well-structured decision flow. Key improvements:
- Two-step presentation (text brief first, then structured choice) provides context before decision
- Follow-up question for post-execution phases reduces gate cognitive load
- Secondary confirmation for "Reject" prevents accidental dependency drops
- Natural language specs (e.g., `` `header`: "Gate" ``) are schema-agnostic and maintainable
- Recommended defaults marked on all questions (follows Hick's Law guidance from ux-strategy-minion)

**Lines 533-538**: Calibration check conversion

**Assessment**: Clean conversion. Question presents context naturally ("5 consecutive approvals..."). Two-option structure is appropriate for yes/no decision.

**Lines 602-617**: Verification issue escalation conversion

**Assessment**: Good structure. Three options cover the decision space (accept/manual-fix/skip). "Accept as-is" as recommended default is appropriate for post-2-round escalation (indicates the issue is non-trivial or subjective).

**Lines 709-715**: PR creation conversion

**Assessment**: Simple, clean conversion. Two options clearly distinguish "create now" vs "defer".

**Lines 732-734**: Marker cleanup instruction

```
Remove the orchestrated-session marker:
`rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`
Then: `git checkout main && git pull --rebase`.
```

**Assessment**: Correct placement (after all orchestration work, before returning to main). Using `rm -f` is appropriate (silent if file doesn't exist). Sequencing is correct (cleanup before checkout).

#### 3. `docs/commit-workflow.md`

**Lines 262-263**: Hook composition explanation

```
During nefario-orchestrated sessions, the Stop hook is suppressed via a session-scoped
marker file (`/tmp/claude-commit-orchestrated-<session-id>`). The marker is created at
the start of Phase 4 (execution) and removed at wrap-up. When the marker exists, the
hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint
from conflicting with the SKILL.md-driven auto-commit flow.
```

**Assessment**: Clear, accurate documentation. Explains the what, when, and why. Placement in "Hook Composition" section is appropriate.

#### 4. `tests/test-commit-hooks.sh`

**Lines 80**: Teardown cleanup addition

```bash
rm -f "/tmp/claude-commit-orchestrated-${SESSION_ID}"
```

**Assessment**: Correct. Ensures test isolation (marker won't leak across test runs).

**Lines 317-342**: New test `test_commit_orchestrated_marker_suppresses`

```bash
test_commit_orchestrated_marker_suppresses() {
    local test_name="Commit: orchestrated-session marker suppresses prompt (exit 0)"

    # Create uncommitted changes
    echo "content" > "$TEMP_DIR/repo/orchestrated.js"
    git -C "$TEMP_DIR/repo" add orchestrated.js
    git -C "$TEMP_DIR/repo" commit -m "add orchestrated" >/dev/null 2>&1
    echo "modified" > "$TEMP_DIR/repo/orchestrated.js"

    # Populate ledger
    echo "$TEMP_DIR/repo/orchestrated.js" > "$(ledger_path)"

    # Create orchestrated marker
    touch "/tmp/claude-commit-orchestrated-${SESSION_ID}"

    local input
    input=$(commit_input)
    local exit_code=0
    echo "$input" | bash -c "cd '$TEMP_DIR/repo' && exec '$COMMIT_HOOK'" >/dev/null 2>&1 || exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        pass "$test_name"
    else
        fail "$test_name" "Expected exit 0, got $exit_code"
    fi
}
```

**Assessment**: Correct test implementation. Follows existing test patterns. Properly:
1. Sets up uncommitted changes (creates condition that would normally trigger hook prompt)
2. Populates ledger (simulates normal hook preconditions)
3. Creates orchestrated marker (the feature under test)
4. Verifies exit 0 (hook suppression successful)

No shellcheck issues detected for this test.

#### 5. `minions/ux-strategy-minion/AGENT.md`

**Lines 55-57**: Structured Choice Presentation subsection

```
When designing interactive decision points in CLI or conversational interfaces, prefer
structured choice presentation (e.g., Claude Code's `AskUserQuestion` tool) over freeform
text prompts. Structured choices reduce cognitive load, prevent input parsing errors, and
make decision points scannable. Reserve freeform input for open-ended questions where
predefined options cannot cover the space. Apply Hick's Law: keep options to 2-4 per
question; mark the recommended default.
```

**Assessment**: Well-written guidance. Appropriately generic (Claude Code mentioned as example, not requirement). Ties to existing UX principles (Hick's Law, cognitive load). Token budget (~100 tokens) is reasonable for this addition.

#### 6. `minions/ai-modeling-minion/AGENT.md`

**Lines 204-206**: Interactive Patterns in Skills subsection

```
When designing Claude Code skills or orchestration workflows that present choices to users,
prefer structured choice tools (Claude Code's `AskUserQuestion`) over freeform text prompts.
In SKILL.md instructions, reference AskUserQuestion using natural language with parameter-name
anchors (e.g., `header:`, `options:`, `multiSelect:`) rather than literal JSON tool call specs.
This is more resilient to schema changes. Structured choices prevent input parsing ambiguity
and reduce cognitive load at decision points.
```

**Assessment**: Clear, actionable guidance. Correctly emphasizes natural-language spec pattern (matches SKILL.md implementation). Resilience rationale (schema changes) is well-articulated. Token budget (~100 tokens) is appropriate.

## Security Assessment

**NIT**: No security issues introduced. All changes are low-risk:
- Marker file uses session ID (collision-free, scoped to single session)
- Cleanup occurs at wrap-up (no marker leakage across sessions)
- Hook suppression is intentional and documented (not a bypass of security controls)
- Test cleanup ensures no state leakage in test suite

## Testing Assessment

**PASS**: Test coverage is adequate:
- New test for marker suppression behavior
- Teardown cleanup ensures test isolation
- Test follows existing patterns (consistent with test suite style)

**NIT**: Consider adding a test for marker cleanup at wrap-up (verify `rm -f` succeeds when marker exists and when it doesn't). Current test only validates suppression behavior, not lifecycle completion. However, this is low-priority since `rm -f` is idempotent.

## Complexity Assessment

**PASS**: No complexity issues:
- Hook guard is a simple conditional (cyclomatic complexity: 1)
- SKILL.md instructions are linear (no complex branching in natural language specs)
- Test is straightforward setup-execute-assert pattern

## Maintainability Assessment

**PASS**: Changes improve maintainability:
- Natural language AskUserQuestion specs reduce coupling to tool schema
- Documentation explains marker behavior clearly
- Test suite expanded appropriately
- DRY principle maintained (no duplication introduced)

## Cross-File Integration

**PASS**: Files integrate correctly:
- SKILL.md marker creation → hook guard → SKILL.md marker cleanup (correct lifecycle)
- Documentation in commit-workflow.md accurately describes hook behavior
- Test validates hook implementation matches SKILL.md instructions
- Minion guidance (ux-strategy, ai-modeling) aligns with SKILL.md patterns

## Recommendations

None. All changes are production-ready.

## Summary

This is a clean, well-executed implementation. The conversion from freeform text to structured AskUserQuestion patterns improves user experience (reduced cognitive load, scannable options, clear defaults) while the marker-based hook suppression eliminates noise during orchestrated execution. Code quality is high, test coverage is appropriate, and documentation is clear.
