# Architecture Review: software-docs-minion

**Verdict: ADVISE**

## Non-blocking warnings

### 1. Conditional inclusion rule contradiction: "Session Resources always present" vs. advisory mode semantics

The plan says Session Resources is "Always (section is structurally present in all reports)" and "Never omitted entirely." However, it also says the Tool Usage subsection is omitted in advisory mode AND the External Skills subsection is omitted when none discovered. This means in advisory mode with no external skills discovered, the entire Session Resources section would contain only a Skills Invoked list showing `/nefario` -- wrapped in a collapsed `<details>` block. This is coherent but marginal: a collapsed section that contains a single bullet item adds structural noise for negligible informational value.

**Recommendation**: The plan already acknowledges this edge case in the formatting rules ("If the entire section would contain only `/nefario` in Skills Invoked and no other data, the section still appears (collapsed) for structural consistency"). This is acceptable but worth monitoring. If most reports end up showing only `/nefario`, the "always present" rule may need revisiting.

### 2. Conditional Section Rules table: parent vs. subsection rows need clear visual hierarchy

The plan specifies three rows in the Conditional Section Rules table:
- `Session Resources` (always present)
- `Session Resources: External Skills subsection` (conditional)
- `Session Resources: Tool Usage subsection` (conditional)

There is no row for `Session Resources: Skills Invoked subsection` because it is always included. This is logically correct (only conditional items need rules), but the absence is asymmetric with the other two subsections. A developer scanning the table might wonder whether Skills Invoked was forgotten.

**Recommendation**: Consider adding a brief note in the table or a footnote: "Skills Invoked subsection: always included (no conditional rule needed)." Alternatively, add a row with INCLUDE WHEN = "Always" to make the three subsections visually complete.

### 3. `skills-used` frontmatter vs. `skills-invoked` accumulation field naming mismatch

The frontmatter field is named `skills-used` while the Data Accumulation item in SKILL.md is named `skills-invoked`. Both are valid names, but the divergence could confuse a developer reading the SKILL.md instructions alongside the TEMPLATE.md frontmatter spec. The plan does explain the naming rationale (`skills-used` matches `agents-involved` verb pattern), but the two names appear in different documents without cross-referencing.

**Recommendation**: Task 2's prompt should explicitly note the mapping: "The `skills-invoked` accumulation data maps to the `skills-used` frontmatter field (different names, same data)." This prevents a future editor from treating them as distinct concepts.

### 4. Collapsibility: `<details>` summary text could be more informative

The plan shows `<summary>Session resources</summary>` (lowercase "resources"). Other collapsed sections use count-bearing summaries: `Agent Contributions ({N} planning, {N} review)`, `Working files ({N} files)`. The Session Resources summary could follow the same pattern with a count hint.

**Recommendation**: Consider `<summary>Session resources ({N} skills, {N} tools)</summary>` or similar to match the existing convention of informative summary lines. This is a minor formatting suggestion, not structural.

### 5. Skeleton ordering: Session Resources placement relative to Working Files

In the current template, External Skills (line 205) immediately precedes Working Files (line 212). The plan replaces External Skills with Session Resources in the same position. This is clean -- the replacement is positional and Working Files remains next. No orphaned references.

**Status**: No issue. Confirming clean replacement with no orphaned references to "External Skills" in surrounding sections.

## Summary

The plan is well-structured. The conditional inclusion rules are internally coherent, the collapsibility pattern is correctly applied, and the External Skills replacement is clean. The five items above are all advisory -- the most actionable ones are #3 (naming mismatch clarification in Task 2 prompt) and #2 (missing Skills Invoked row in conditional rules table).
