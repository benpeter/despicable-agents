# Test-Minion Review: advisory-flag

**Verdict**: APPROVE

## Assessment

This delegation plan modifies specification files (AGENT.md, SKILL.md, TEMPLATE.md) that define orchestrator behavior. There is no executable code to unit test.

### Verification Strategy

The plan includes appropriate verification:

1. **Structural verification** (lines 717-724): Confirms all specification changes are in place with correct section names, fields, and references.

2. **Consistency verification** (lines 725-732): Cross-checks that AGENT.md, SKILL.md, and TEMPLATE.md refer to the same concepts with compatible terminology (`ADVISORY: true` directive vs `advisory-mode` session context vs `mode: advisory` frontmatter).

3. **Integration test** (lines 734-738): Manual test path for post-merge validation. This is the appropriate test level for orchestrator behavior changes.

### Test Coverage Analysis

**What can be tested**: Flag parsing logic could theoretically have unit tests, but the parsing is implemented as LLM-interpreted specification ("extract flags from argument string"), not deterministic code. The test is whether the LLM follows the spec.

**What cannot be tested**: Behavioral specification adherence (phase skipping, advisory synthesis output, report format compliance) requires running actual orchestrations.

**Excluded from cross-cutting**: Line 660 correctly excludes testing with clear rationale: "no executable code to test." The verification approach (manual integration test) is appropriate.

### Risk Assessment

The manual integration test is well-scoped (line 733-738):
- Covers the complete advisory flow end-to-end
- Tests flag parsing, phase execution, output format, and termination behavior
- Verifiable through observable artifacts (status lines, report file, absence of branch/PR)

No additional test coverage needed. The verification steps match the risk profile of specification changes to an AI orchestrator.

## Recommendation

Proceed with implementation. Run the integration test described in lines 733-738 after merge to validate behavioral compliance.
