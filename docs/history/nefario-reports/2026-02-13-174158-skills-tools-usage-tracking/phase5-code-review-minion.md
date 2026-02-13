# Code Review: Session Resources Tracking

**Reviewer**: code-review-minion
**Files reviewed**: `docs/history/nefario-reports/TEMPLATE.md`, `skills/nefario/SKILL.md`
**Commits**: `df77f7e`, `a54cb4c`

## VERDICT: ADVISE

The changes are well-structured, internally consistent within each file, and faithfully implement the synthesis plan. The section replacement is clean, conditional rules are coherent, and the markdown formatting (table alignment, `<details>` blank lines) is correct. Two cross-file reference counts are now stale, and there is one minor specification gap. None are blocking.

## FINDINGS

### ADVISE: Stale frontmatter field count in SKILL.md

- **File**: `skills/nefario/SKILL.md` line 2048
- **Description**: The Report Template summary says "v3 YAML frontmatter schema (10-11 fields)" but the addition of the `skills-used` conditional field in TEMPLATE.md brings the total to 12 fields (10 always + 2 conditional). The range should be "10-12 fields" or simply "12 fields (10 required, 2 conditional)".
- **AGENT**: devx-minion (Task 2)
- **FIX**: Change line 2048 from `v3 YAML frontmatter schema (10-11 fields)` to `v3 YAML frontmatter schema (10-12 fields)`.

### ADVISE: Section count reference says 12 but skeleton has 13 H2 sections

- **File**: `skills/nefario/SKILL.md` line 2049
- **Description**: The comment says "Canonical section order (12 top-level H2 sections)" but the skeleton in TEMPLATE.md contains 13 H2 sections: Summary, Original Prompt, Key Design Decisions, Phases, Agent Contributions, Team Recommendation, Execution, Decisions, Verification, Session Resources, Working Files, Test Plan, Post-Nefario Updates. This was already wrong before this PR (External Skills was also the 10th of 13), but the task spec explicitly asked the agent to verify the count. It was not corrected.
- **AGENT**: devx-minion (Task 2 -- spec asked to verify and correct)
- **FIX**: Change line 2049 from `Canonical section order (12 top-level H2 sections)` to `Canonical section order (13 top-level H2 sections)`.

### NIT: Summary tag placeholder ambiguity when Tool Usage is omitted

- **File**: `docs/history/nefario-reports/TEMPLATE.md` line 209
- **Description**: The `<summary>` tag reads `Session resources ({N} skills, {M} tool types)`. The Formatting Rules specify that in advisory mode the Tool Usage subsection is "omitted entirely" and when counts are unavailable it is replaced with a fallback message. In either case, `{M}` has no meaningful value. The Formatting Rules do not specify how the summary tag should render when Tool Usage is absent (e.g., should it be `(2 skills)` without the tool types count?). This is a minor specification gap -- report authors will have to guess.
- **AGENT**: devx-minion (Task 1)
- **FIX**: Add a sentence to the Formatting Rules: "When Tool Usage is omitted, the summary tag should read `Session resources ({N} skills)` without the tool types count."

### NIT: Conditional Section Rules table slight imprecision for Tool Usage OMIT case

- **File**: `docs/history/nefario-reports/TEMPLATE.md` line 311
- **Description**: The Conditional Section Rules table says Tool Usage subsection OMIT WHEN "`mode` = `advisory` OR counts not available". The Formatting Rules (lines 360-365) differentiate these two OMIT cases: advisory mode fully omits, while non-advisory with unavailable counts replaces with fallback text "Tool counts not available for this session." The conditional table treats both as "OMIT" which technically conflicts with the "replace with fallback" behavior. This is a very minor inconsistency -- the Formatting Rules are more specific and would naturally take precedence. Not worth blocking over, but could confuse a strict reader of the conditional table alone.
- **AGENT**: devx-minion (Task 1)
- **FIX**: Optionally refine the OMIT WHEN column to: "`mode` = `advisory` (omit entirely) OR counts not available (replace with fallback message)". Or leave as-is and accept the Formatting Rules as the authoritative specification for behavior details.

### NIT: Markdown table alignment in Conditional Section Rules

- **File**: `docs/history/nefario-reports/TEMPLATE.md` lines 308-311
- **Description**: The new Session Resources rows are longer than existing rows, causing column width inconsistency within the table. This has no rendering impact (markdown tables render regardless of column alignment in source), but is a readability nit for source editing.
- **AGENT**: devx-minion (Task 1)
- **FIX**: No fix needed. Markdown tables do not require aligned columns. Purely cosmetic.

## Summary of Findings

| Severity | Count |
|----------|-------|
| BLOCK    | 0     |
| ADVISE   | 2     |
| NIT      | 3     |

The two ADVISE findings are both stale numeric references in SKILL.md that should be corrected to match the actual template structure. They are non-blocking because the referenced counts are informational comments, not functional logic, but correcting them prevents future confusion when someone reads these as authoritative references.
