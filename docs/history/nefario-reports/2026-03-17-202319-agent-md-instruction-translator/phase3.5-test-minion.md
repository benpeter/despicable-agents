# Test Minion Review -- Phase 3.5 Architecture Review

**Verdict**: APPROVE

**Confidence**: high

## Assessment

The test plan in Task 2 is thorough and well-structured. The ~25 assertions across 8 test groups cover the testing pyramid correctly for a CLI tool: happy-path, edge cases, error handling, golden-file regression, and a corpus smoke test across all 27 real agents. The fixture design is sound -- synthetic fixtures for controlled assertions, golden files for regression detection, and real agents for catching what synthetic tests miss.

## Strengths

- **Corpus smoke test** is the highest-value test in this suite. Claude Code-specific content is concentrated in `nefario/AGENT.md` (only file with TaskUpdate/SendMessage/Main Agent Mode/`@domain:` markers). The corpus test ensures the translator does not damage the 26 agents that have no stripping targets -- i.e., it validates the "first, do no harm" property.
- **False-positive preservation checks** are well-specified: `CLAUDE.md` in lucy (24 occurrences), `scratch` in legitimate contexts, standalone `Task`. These are the riskiest failure modes for a sed-based stripper.
- **Golden-file approach** for `with-claude-refs.md` will catch context cleanup regressions (dangling commas, empty parens) that assertion-based tests would miss.
- **Permission test** (0600) validates the security requirement.

## Advisory Items (non-blocking)

1. **`no-frontmatter.md` behavior is underspecified.** Task 1 prompt says "first line must be `---`" for frontmatter to exist, and frontmatter extraction emits JSON to stdout. But the test plan says the behavior for no-frontmatter files is "defined behavior (pass through or error with message)" -- the test author will have to read the implementation to know which assertion to write. This is fine since Task 2 is blocked by Task 1, but it means the test for this case may end up as a loose "exits 0 or exits 1" check. Consider: should the Task 1 prompt explicitly state that a file with no frontmatter is valid (body passes through, empty JSON `{}` on stdout)? This would let the test be precise.

2. **Idempotency is specified in Task 1 but not tested in Task 2.** The plan says "running the translator twice with identical inputs must produce identical output." A simple test -- translate, capture checksum, translate again, compare checksums -- would take 3 lines and catch timestamp leaks or non-deterministic sed behavior. Worth adding to the happy-path group.

3. **`memory` and `x-plan-version` frontmatter fields.** The real `nefario/AGENT.md` contains `memory: user`, `x-plan-version`, and `x-build-date` which are not in the extraction list (`name`, `model`, `tools`, `description`). The test should verify these do NOT appear in the JSON output and do NOT leak into the Markdown body. The corpus smoke test partly covers this but an explicit assertion on `nefario/AGENT.md` would catch it cleanly.

4. **Multi-line description golden file.** The `multiline-description.md` fixture tests JSON extraction, but there is no golden file for it. Since flattening a `>` folded scalar is tricky with awk, a golden-file comparison of the expected JSON string would be more robust than a substring grep.

5. **Empty stderr on success.** The test plan checks stderr for error cases but does not assert stderr is empty (or contains only the size-sanity warning) on success. A stray warning or debug print on stderr could break callers that parse stdout JSON.

None of these items warrant BLOCK. Items 1-2 are the most impactful and could be addressed with a one-line addition to each task prompt. Items 3-5 are refinements the test author can incorporate at implementation time.
