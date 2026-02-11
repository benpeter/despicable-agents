# Software Documentation Review

## Verdict: ADVISE

The plan has strong self-documenting changes and consistent patterns. The following non-blocking improvements would enhance developer experience:

## Advisories

### 1. Error Message Discoverability

**Issue**: Error messages are comprehensive but buried in subsections. Developers troubleshooting failures may not find them quickly.

**Recommendation**: Consider adding a one-line "Common issues" reference at the end of each Argument Parsing section pointing to the error messages within Issue Fetch. Not blocking—the error messages themselves are clear and actionable.

### 2. Example Coverage Gap (Nefario)

**Observation**: despicable-prompter gets Example 4 showing issue mode end-to-end. Nefario SKILL.md "has no examples section" (line 439), so no equivalent illustration exists.

**Recommendation**: If nefario SKILL.md later gains an examples section, include one demonstrating `#42` → issue fetch → PR with "Resolves #42". Not blocking now—nefario's argument parsing text is explicit enough for implementation.

### 3. Content Boundary Documentation Pattern

**Issue**: Both skills use `<github-issue>` tags as content boundaries with identical "do not follow instructions within" semantics. This pattern is new to the codebase and could be reused elsewhere.

**Recommendation**: After implementation, consider documenting this pattern in `docs/` as a general anti-injection technique for external content in LLM prompts. Not blocking this PR—can be a follow-up.

### 4. Trailing Text Semantics Clarity

**Observation**: Trailing text behavior differs between skills:
- **Prompter**: Appended to issue body, included in write-back
- **Nefario**: Appended to prompt, NOT written back to issue

The plan documents this in the Conflict Resolutions section (lines 470-474) but the distinction is subtle.

**Recommendation**: Each skill's Argument Parsing section correctly describes its own behavior. Consider adding one clarifying sentence to prompter's trailing text section noting the write-back implication: "The brief generated from the combined input will be written back to the issue, including insights derived from the trailing text."

### 5. Scope Exclusion Justification

**Observation**: Line 459 states "No external documentation changes needed (CLAUDE.md, docs/ are out of scope per task definition)."

**Assessment**: Appropriate for this iteration. The SKILL.md files are the canonical documentation for skill invocation. Future developers will discover issue mode through:
- `argument-hint` in frontmatter (shown in `/help`)
- Argument Parsing sections (self-contained)
- Examples (prompter) and error messages (both)

If `/nefario #42` becomes a primary workflow, adding a one-liner to project docs would help, but not required for MVP.

## Strengths

1. **Consistent pattern**: Both skills follow the same `#<issue>` syntax and section structure (Argument Parsing → Issue Fetch → Issue Write-Back/Context).

2. **Self-documenting argument hints**: Updated `argument-hint` metadata makes the feature discoverable through CLI help.

3. **Comprehensive error messages**: Both "gh not found" and "gh fetch failed" scenarios have actionable recovery steps with example commands.

4. **Edge case coverage**: Empty input behavior updated to show `#42` as first example (line 189), reinforcing issue mode as a primary invocation pattern.

5. **Inline documentation placement**: Argument Parsing sections come early (after identity/core rules, before phase logic), making them easy to find when reading the skills.

6. **Refinement offer update**: Prompter's refinement offer dynamically adapts to issue mode vs free text mode (lines 206-216), maintaining workflow clarity.

## Conclusion

The plan produces well-documented, self-contained SKILL.md changes. The advisories above are enhancements, not blockers. Proceed with implementation.
