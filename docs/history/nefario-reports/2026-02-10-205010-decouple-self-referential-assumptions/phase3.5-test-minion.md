# Architecture Review: test-minion

## Verdict: APPROVE

## Assessment

The delegation plan aligns strongly with the testing strategy I recommended during planning. All critical concerns are addressed.

### What Was Recommended vs What Is Planned

| Planning Recommendation | Synthesis Coverage | Status |
|------------------------|-------------------|--------|
| Write regression tests BEFORE decoupling changes | Task 1 precedes Task 2, explicitly marked as "BEFORE a decoupling refactor begins" | ✓ Covered |
| Hardcoded-path detection test (grep-based, static) | Task 1 creates `test-no-hardcoded-paths.sh` with explicit patterns and allowlist | ✓ Covered |
| Three-context smoke tests (self, external, greenfield) | Task 6 creates `test-skill-portability.sh` testing all three scenarios | ✓ Covered |
| Install portability test | Task 1 creates `test-install-portability.sh` with mocked HOME | ✓ Covered |
| Test execution order: tests first, changes after | Task 1 is Batch 1 (parallel, no gate), Task 2 is Batch 2 (after Task 1, has gate) | ✓ Covered |

### Execution Order Analysis

The plan correctly sequences tests before changes:

1. **Batch 1 (parallel)**: Task 1 (regression tests) + Task 3 (prompter promotion, low-risk)
2. **Gate-free transition**: Regression tests establish baseline
3. **Batch 2**: Task 2 (SKILL.md refactor) - the high-risk change
4. **Approval Gate**: Only gate in the plan, positioned correctly at highest-risk change
5. **Batch 3 (parallel)**: Task 4 (cleanup), Task 5 (docs), Task 6 (portability smoke tests)

This sequence ensures:
- Regression tests exist before any breaking changes
- High-risk change (SKILL.md refactor) is gated
- Portability validation (Task 6) runs after implementation is complete

### Test Coverage Adequacy

**Static analysis (test-no-hardcoded-paths.sh)**:
- Scans `skills/nefario/SKILL.md` and `nefario/AGENT.md`
- Flags: `nefario/scratch/`, `docs/history/nefario-reports/TEMPLATE.md`, `docs/commit-workflow.md`, `the-plan.md`
- Allowlist: project-local skills, `CLAUDE.md`, `docs/`, report files (correct exceptions)
- Includes `--expect-fail` flag for pre-decoupling baseline (excellent)

**Structural validation (test-install-portability.sh)**:
- Mocked HOME directory (avoids touching real ~/.claude/)
- Verifies 27 agent symlinks + nefario skill symlink
- Tests install and uninstall (bidirectional verification)
- Validates symlink targets (not just symlink existence)

**Portability smoke tests (test-skill-portability.sh)**:
- Three scenarios: self-repo, external existing, greenfield
- Detection priority test (both conventions present, verify correct selection)
- Environment variable override test (NEFARIO_REPORTS_DIR)
- Temp directory cleanup in trap (defensive)

**What is NOT tested (acceptable gaps)**:
- LLM interpretation of SKILL.md prose (cannot automate, manual acceptance only)
- Full end-to-end nefario orchestration (expensive, non-deterministic, manual only)
- Git operations from SKILL.md (complex, YAGNI for automated tests)

These gaps are acceptable. The test strategy focuses on concrete filesystem operations and grep-able patterns - exactly what I recommended.

### Risk Mitigation Verification

**Risk 3 (Self-evolution regression) - HIGHEST PRIORITY**:
- Status: MITIGATED
- Task 1 writes regression tests FIRST (not in parallel with changes)
- Task 1 is blocked by: none (runs immediately)
- Task 2 is blocked by: Task 1 (cannot start until tests exist)
- The `--expect-fail` flag in Task 1 allows tests to run against current codebase as baseline
- Verification steps (end of synthesis) include running all tests after completion

**Risk 5 (Over-testing natural language instructions)**:
- Status: MITIGATED
- Task 1 focuses on grep-able path patterns, not prose content
- Task 6 tests concrete filesystem operations (mkdir, file creation), not LLM behavior
- Manual acceptance testing is explicitly deferred (no attempt to automate LLM behavior)

### Task Prompt Quality (Testing-Specific)

**Task 1 prompt** (lines 88-146):
- Clear context: "regression tests BEFORE a decoupling refactor begins"
- Explicit deliverable paths (absolute paths)
- Patterns to flag vs patterns to allow (comprehensive)
- `--expect-fail` flag requirement (enables pre-post comparison)
- References existing test style (`tests/run-tests.sh`, `tests/test-commit-hooks.sh`)
- "What NOT to Do" section prevents scope creep
- Success criteria are testable

**Task 6 prompt** (lines 442-509):
- Five explicit scenarios (three main + detection priority + env override)
- Follows existing test patterns (bash, set -euo pipefail, color output, trap cleanup)
- "What NOT to Do" prevents LLM invocation attempts
- Success criteria cover all scenarios plus cleanup

Both prompts are well-specified. No ambiguity about what to test or how to test it.

### Gap Analysis

No critical gaps identified. The plan covers:
- Static analysis (hardcoded paths)
- Structural validation (install portability)
- Functional smoke tests (three contexts)
- Regression protection (self-evolution path)

The testing strategy is defensive without being excessive. Test scope matches change scope.

## Conclusion

The testing strategy in this delegation plan is sound. Tests are written before changes, execution order is correct, and coverage matches the risk profile. The highest-risk change (SKILL.md refactor) has both pre-tests (Task 1) and post-tests (Task 6) surrounding it.

No blocking issues from testing perspective.
