ADVISE

## Non-blocking concerns

1. **Template subsection numbering ambiguity** (Task 1, lines 98-111): The prompt lists "10. Conflict Resolutions" and "13. Files Changed" but then correctly identifies these as subsections, not top-level sections. However, the numbering continues through 16 items when only ~12 are actually top-level. This may confuse the executing agent. Recommend clarifying that the numbered list shows ALL elements (subsections included) but only certain items are H2 sections. The corrected list at lines 107-111 is clear, but appears after the confusing numbered list.

2. **Conditional section detection logic** (Task 1, lines 150-154): "External Skills" condition is "when meta-plan discovered 1+ external skills" but the agent executing Task 1 (me) won't have access to runtime data to know what meta-plan discovered. The template needs placeholder guidance like `<!-- INCLUDE WHEN: external skills were discovered during meta-plan (check session data for external-skills array length > 0) -->`. Same issue for "Test Plan" - executing agents need deterministic detection rules, not descriptive prose.

3. **Post-Nefario Updates H3 timestamp format** (Task 2, line 303): The format `### {YYYY-MM-DD} {HH:MM:SS} -- {one-line task summary}` will render as a very long heading. Consider using bold text instead of H3 for timestamp entries, or moving timestamp to metadata below the heading. Current format is technically valid but poor heading hygiene.

4. **PR body append idempotency** (Task 2, lines 320-323): Detection is "check for `## Post-Nefario Updates` in existing body" but what if the section exists with different casing, trailing whitespace, or markdown variations? Recommend exact string match `\n## Post-Nefario Updates\n` to avoid false negatives. Minor risk but worth specifying.

5. **Cross-reference search scope** (Task 3, lines 418-429): The search is described as "entire project" but then lists specific files to check. Recommend using `Grep pattern="TEMPLATE\.md" path="/Users/ben/github/benpeter/2despicable/3" glob="*.md"` first to ensure completeness before manual verification. Listed files are likely exhaustive but automation guarantees it.

6. **Template maintainability as SKILL.md grows**: The conflict resolution correctly accepts the ~80-120 line template inline (line 488), acknowledging SKILL.md will grow. Long-term, if SKILL.md exceeds ~2000 lines, discoverability degrades. No action needed now, but worth noting that future refactoring (splitting SKILL.md into multiple topic files) may reintroduce the external reference pattern. This is a multi-year horizon concern, not blocking.

## Recommendations

- Task 1: Add explicit placeholder guidance for conditional section detection that executing agents can use (refer to session data structures by name)
- Task 2: Specify exact string match for Post-Nefario Updates section detection to ensure idempotency
- Task 3: Use Grep tool first to exhaustively find all TEMPLATE.md references before manual file review

These are minor polish issues. The architecture is sound: single source of truth, explicit over implicit, deterministic conditions over "optional" vibes. Proceed with tasks as specified.
