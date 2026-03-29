# Domain Plan Contribution: test-minion

## Recommendations

### (a) Yes, follow the `tests/test-routing-config.sh` bash pattern exactly

The existing test script establishes a clear, battle-tested convention: single bash script with `set -euo pipefail`, `pass()`/`fail()` reporting helpers, `run_*` wrappers that capture stdout/stderr/exit code, temp directory lifecycle via `trap cleanup EXIT`, and a summary counter at the end. The translator tests should follow this pattern verbatim -- same reporting functions, same cleanup structure, same fixture organization under `tests/fixtures/translator/`. This keeps the test suite consistent and means contributors need to learn one testing pattern, not two.

The test runner wrapper (`run_translator`) should mirror `run_loader`: capture `OUT`, `ERR`, `RC`, enabling assertions against all three channels. The translator will write to an output file rather than stdout, so the wrapper should also read the output file contents into a variable (e.g., `TRANSLATED`) for assertion.

### (b) Use both synthetic fixtures AND a subset of real AGENT.md files

**Synthetic fixtures** for targeted, isolated testing:
- A minimal AGENT.md with all five sections (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries) and standard frontmatter -- the happy-path canary.
- An AGENT.md with Claude Code-specific content that must be stripped: `TaskUpdate`, `SendMessage`, scratch directory references, `TeamCreate`, `TaskList`. This is the primary stripping test.
- An AGENT.md with CLAUDE.md references and Claude Code tool mentions (e.g., `AskUserQuestion`) to verify those are stripped or left alone depending on the spec.
- Edge cases: empty body (frontmatter only), body with no headings, frontmatter with unusual fields (`x-plan-version`, `x-build-date`, `x-fine-tuned`), YAML frontmatter with multi-line `description:` (the `>` folded scalar pattern used in most agents).

**Real AGENT.md corpus validation** for regression and completeness:
- Run the translator against `nefario/AGENT.md` (the only one with TaskUpdate/SendMessage in the body) and `lucy/AGENT.md` (heavy CLAUDE.md references) as named integration tests with specific assertions.
- Run the translator against ALL 27 AGENT.md files in a loop as a smoke test: every file must translate without error, produce valid Markdown, and produce output with no YAML frontmatter. This catches real-world edge cases that synthetic fixtures miss. Pattern it after the existing "Group membership drift check" loop in test-routing-config.sh (lines 931-958).

The synthetic fixtures go in `tests/fixtures/translator/` and are version-controlled. The real AGENT.md files are referenced via `REAL_AGENT_DIR="$REPO_ROOT"` (same pattern as the routing tests).

### (c) Key assertions, in priority order

1. **No YAML frontmatter in output**: Output must not start with `---`. Grep for `^---$` -- if the first line matches or any `---`-delimited block appears at the top, fail. This is acceptance criterion #1.

2. **No Claude Code-specific references**: Output must not contain `TaskUpdate`, `SendMessage`, `TeamCreate`, `TaskList`, `TaskCreate`, `nefario-scratch`, or `scratch directory` patterns. Grep each pattern against the output. This is acceptance criterion #2.

3. **Valid Markdown**: Output must be non-empty, must not contain bare YAML frontmatter delimiters (`^---$` at line 1), and should preserve heading structure. A lightweight check: verify at least one `#` heading exists in output (since every AGENT.md has an Identity heading). Do not reach for a full Markdown validator -- it adds a dependency for marginal value.

4. **Correct format per target**: For AGENTS.md format, verify the output is clean Markdown body (frontmatter stripped, Claude Code content stripped, sections preserved). For CONVENTIONS.md format, verify same stripping but check whether any structural transformation was applied (per the translation table, Identity becomes "preamble section" -- the test should verify whatever structural contract the implementation chooses).

5. **Exit code semantics**: Zero on success. Non-zero on invalid input (missing file, bad format argument, empty AGENT.md). Error messages on stderr should name the problem (following the existing pattern in test-routing-config.sh where error messages are asserted to contain specific strings).

6. **Frontmatter fields extractable**: If the translator exposes frontmatter fields to the caller (e.g., via stdout JSON or separate output), verify `name`, `model`, `tools` are correctly extracted. This tests that frontmatter is stripped from the output but still available to the adapter.

### (d) Yes, use golden-file regression tests for two representative agents

Create golden files for:
- `tests/fixtures/translator/golden-minimal.agents.md` -- expected AGENTS.md output from the synthetic minimal fixture.
- `tests/fixtures/translator/golden-minimal.conventions.md` -- expected CONVENTIONS.md output from the same fixture.
- `tests/fixtures/translator/golden-nefario.agents.md` -- expected AGENTS.md output from `nefario/AGENT.md` (the most complex agent with stripping targets).

Compare using `diff -u "$GOLDEN" "$ACTUAL"`. On mismatch, the diff itself is the error message -- directly useful for debugging. This pattern catches regressions when the translator logic changes and also serves as documentation of expected behavior.

Keep golden files small and focused. The minimal fixture should be ~30 lines so the golden file is easily reviewable. The nefario golden file will be large, but it is the critical regression anchor because nefario is the only agent with all stripping targets.

**Important**: Golden files must be regenerated explicitly (a helper script or make target), never auto-updated. Blind updates defeat the purpose.

### (e) Parametric testing for two output formats

Use a simple loop pattern, not separate test functions per format. For each test case that applies to both formats, iterate:

```bash
for fmt in agents.md conventions.md; do
  run_translator --format "$fmt" --input "$FIXTURE" --output "$OUTFILE"
  # assertions here, using $fmt in the test name
done
```

This halves the test code and ensures both formats get identical coverage. Format-specific assertions (e.g., CONVENTIONS.md preamble structure vs AGENTS.md section structure) run inside conditional blocks within the loop.

Tests that are format-specific (e.g., verifying AGENTS.md has no preamble transformation, or CONVENTIONS.md has specific preamble handling) should be standalone, not parametric.

## Proposed Tasks

### Task 1: Create test fixtures (`tests/fixtures/translator/`)

Create synthetic AGENT.md fixtures:
- `minimal.md` -- clean five-section agent with standard frontmatter (name, description, tools, model, memory).
- `with-claude-refs.md` -- agent body containing TaskUpdate, SendMessage, TeamCreate, scratch directory references, CLAUDE.md mentions. Used to verify stripping.
- `frontmatter-only.md` -- YAML frontmatter with empty body. Edge case.
- `no-frontmatter.md` -- Markdown body with no YAML frontmatter. Edge case (should pass through or error cleanly).
- `multiline-description.md` -- Frontmatter using `>` folded scalar for description (common in real agents).

Create golden output files:
- `golden-minimal.agents.md` -- Expected AGENTS.md output from `minimal.md`.
- `golden-minimal.conventions.md` -- Expected CONVENTIONS.md output from `minimal.md`.
- `golden-with-claude-refs.agents.md` -- Expected AGENTS.md output from `with-claude-refs.md` (stripping verified).

**Estimated size**: ~10 fixture files, each under 50 lines.

### Task 2: Write `tests/test-translator.sh`

Structure (following test-routing-config.sh exactly):

1. **Setup block**: `SCRIPT_DIR`, `REPO_ROOT`, `TRANSLATOR="$REPO_ROOT/lib/translate-agent-md.sh"`, `FIXTURES="$SCRIPT_DIR/fixtures/translator"`, pass/fail counters, temp dir management, cleanup trap.

2. **Runner helper**: `run_translator()` that invokes the translator, captures stdout (frontmatter JSON or other metadata), stderr, exit code, and reads the output file content.

3. **Happy-path tests** (~6 tests): Translate `minimal.md` to AGENTS.md format (exits 0, output non-empty, no frontmatter, at least one heading). Same for CONVENTIONS.md format. Parametric loop for both formats on core assertions.

4. **Stripping tests** (~8 tests): Translate `with-claude-refs.md` and assert no TaskUpdate, no SendMessage, no TeamCreate, no TaskList, no scratch directory references in output. Separately assert that non-stripping content is preserved (section headings, domain knowledge). Test nefario/AGENT.md specifically (the real file) and verify stripping.

5. **Golden-file regression tests** (~3 tests): `diff -u` golden vs actual for minimal (both formats) and with-claude-refs (AGENTS.md). Fail with diff output on mismatch.

6. **Edge-case tests** (~4 tests): Frontmatter-only input (exits 0, output is empty or minimal). No-frontmatter input (defined behavior -- error or passthrough). Multiline description frontmatter parsed correctly. Invalid format argument (exits non-zero, stderr names the problem).

7. **Validation/error tests** (~3 tests): Non-existent input file (exits 1). Missing required arguments (exits 1, stderr shows usage). Invalid --format value (exits 1, stderr names valid formats).

8. **Corpus smoke test** (~1 test with 27 iterations): Loop over all `**/AGENT.md` files under `$REPO_ROOT`. For each, translate to AGENTS.md and CONVENTIONS.md. Assert: exits 0, output non-empty, output does not start with `---`, output contains at least one `#` heading. This catches real-world edge cases.

9. **Summary**: Print pass/fail counts, exit with failure count.

**Estimated test count**: ~25 assertions organized in ~8 test groups.

### Task 3: Verify test script runs and integrates with existing test suite

- Run `bash tests/test-translator.sh` and verify all tests pass (or fail predictably on not-yet-implemented translator functions).
- Ensure the script can run independently and also alongside `test-routing-config.sh`.
- Verify cleanup: no temp files left after test run.

## Risks and Concerns

1. **Stripping granularity is underspecified**: The acceptance criteria say "no TaskUpdate, SendMessage, or scratch file references" but the exact stripping boundaries are unclear. Does the translator remove entire lines? Entire paragraphs? Entire sections? The test fixtures for `with-claude-refs.md` need to encode the expected granularity, which depends on the implementation design from devx-minion/ai-modeling-minion consultations. **Mitigation**: Design the test fixture with Claude Code references at multiple granularities (standalone line, inline in a paragraph, entire section) so tests exercise all three cases. Defer golden-file creation until the stripping spec is finalized.

2. **CONVENTIONS.md structural transformation**: The translation table shows Identity becomes "preamble section" for CONVENTIONS.md, but it is unclear whether this requires structural transformation or just passes through the existing Markdown. If the two formats differ structurally, tests must diverge. **Mitigation**: The golden files for the two formats will capture the difference. Parametric tests cover shared assertions; format-specific tests cover divergent structure.

3. **Golden file maintenance cost**: Golden files become a maintenance burden if the translator output format changes frequently during initial development. **Mitigation**: Use golden files only for the stable minimal fixture and the critical nefario stripping case. Do not create golden files for all 27 agents -- that would be brittle. The corpus smoke test (loop over all agents, assert basic invariants) provides broad coverage without golden-file maintenance.

4. **Lucy AGENT.md has extensive CLAUDE.md references**: Lucy's AGENT.md mentions `CLAUDE.md` 20+ times as part of its core knowledge (it is the compliance checker for CLAUDE.md). These are domain knowledge, not Claude Code-specific instructions. The stripping logic must NOT remove these -- they are content, not tool references. **Mitigation**: Add a specific test that translates lucy/AGENT.md and verifies `CLAUDE.md` mentions are preserved in the output (they are part of Lucy's domain expertise, not Claude Code platform references). This is a nuanced distinction the translator must get right.

5. **False positives in the "scratch" stripping pattern**: The word "scratch" appears in `security-minion/AGENT.md` ("scratch for Go" in container context) and `frontend-minion/AGENT.md` ("building from scratch"). The stripping pattern must target `nefario-scratch` or `scratch directory` specifically, not bare `scratch`. **Mitigation**: Add a test with `security-minion/AGENT.md` or a synthetic fixture containing legitimate uses of "scratch" and verify they are preserved.

## Additional Agents Needed

None beyond what the meta-plan already includes. The test strategy depends on the CLI interface design (devx-minion) and stripping spec (ai-modeling-minion + security-minion) being finalized first, but no additional specialist consultation is needed for the test design itself.
