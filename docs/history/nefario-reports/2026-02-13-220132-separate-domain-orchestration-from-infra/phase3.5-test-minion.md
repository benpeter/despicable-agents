# Test-Minion Review: Domain Orchestration Separation

## Verdict: ADVISE

## Concerns

### 1. Task 5 Verification Scope is Too Static

Task 5 verifies behavioral equivalence through static file comparison and diff analysis. This is necessary but insufficient for a refactoring that touches the orchestration core. The verification should include:

**Missing verification:**
- **Actual orchestration execution test**: Run `/nefario` with a simple representative task using the assembled AGENT.md and verify it completes successfully. Static equivalence does not guarantee runtime behavior.
- **Assembly idempotence verification**: The success criteria claim "scripts are idempotent" but Task 5 does not actually test this. Run `./assemble.sh` twice and diff the outputs.
- **Disassemble/reassemble round-trip test**: Run `./assemble.sh && ./disassemble.sh && ./assemble.sh` and verify the final output matches the first assembly. This catches extraction boundary errors.

**Recommendation**: Add to Task 5 verification steps:
1. Execute `./assemble.sh && ./assemble.sh` and verify outputs are identical (idempotence)
2. Execute `./assemble.sh && ./disassemble.sh && ./assemble.sh` and verify final assembly matches first (round-trip)
3. Execute `/nefario --advisory "list files in project root"` (or similar trivial task) with assembled AGENT.md and verify it completes without errors

These are mechanical tests that take minutes but provide high confidence.

### 2. Section Marker Verification is Fragile

Task 5 verifies that SKILL.md markers are HTML comments and "should be treated as invisible by the model." This assumes HTML comment invisibility without testing it. LLMs can and do read HTML comments in markdown.

**The risk**: Section markers like `<!-- DOMAIN-SPECIFIC: agent roster selection logic -->` become part of the prompt context and could influence model behavior (e.g., priming it to think about domain-specificity when processing that section).

**Recommendation**: Task 2 should use minimal markers without inline descriptions. Instead of:
```
<!-- DOMAIN-SPECIFIC: describes which agents to select for phases -->
```

Use:
```
<!-- @domain-marker:agent-selection -->
```

And document the marker meanings in `adapter-format.md`, not inline in SKILL.md.

### 3. Missing Regression Test Coverage

The plan states "No executable code is produced that needs unit tests" but `assemble.sh` and `disassemble.sh` ARE executable code that manipulate critical system files. The bash scripts handle text parsing, pattern matching, and file I/O with potential edge cases.

**Edge cases not addressed:**
- DOMAIN.md sections containing the marker delimiter strings (e.g., adapter content includes `<!-- @domain:roster END -->`)
- Missing newlines at section boundaries causing content concatenation
- Special characters in adapter content (backticks, dollar signs) breaking sed/awk patterns
- YAML frontmatter preservation when assembly markers appear near frontmatter boundary

**Recommendation**: Add a test script (`test/test-assembly.sh`) that:
1. Creates a minimal synthetic DOMAIN.md with edge-case content (sections with marker strings, special characters)
2. Creates a minimal template AGENT.md with markers
3. Runs assembly and verifies expected substitutions occurred
4. Verifies error handling for missing sections

This is test-minion's standard recommendation: bash scripts that manipulate critical files need test coverage, even if brief.

### 4. Assembly Failure Mode Verification

Task 3 specifies "The script must fail clearly if a marker in AGENT.md has no corresponding section in DOMAIN.md" but Task 5 does not verify this failure mode. If the error handling is silent or unclear, adapter authors will waste time debugging.

**Recommendation**: Add to Task 5:
1. Temporarily remove one section from DOMAIN.md
2. Run `./assemble.sh` and verify it exits non-zero with a clear error message naming the missing section
3. Restore the section

This takes 30 seconds and confirms error handling works as specified.

## Summary

The delegation plan is sound architecturally, but Task 5's verification approach is insufficient for a change touching orchestration infrastructure. The concerns are all addressable with minor additions to Task 5 (runtime execution test, idempotence test, round-trip test, error handling test) and Task 2 (minimal section markers).

The core insight: **static diff comparison verifies extraction accuracy, but does not verify assembly correctness or runtime behavior.** This refactoring changes how the prompt is constructed. Test the constructed prompt, not just the extraction.

Recommendation: Expand Task 5 verification steps per Section 1 above. Consider adding edge-case assembly testing per Section 3. These additions are low-cost, high-value confidence checks.
