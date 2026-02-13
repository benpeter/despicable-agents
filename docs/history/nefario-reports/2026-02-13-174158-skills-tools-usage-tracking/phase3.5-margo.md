# Margo -- Architectural Simplicity Review

## Verdict: ADVISE

The plan is well-scoped (2 tasks, 2 files, documentation-only) and the core decision
to evolve the never-used External Skills section rather than adding a parallel section
is the right call. No blocking concerns. Three non-blocking observations:

### 1. Three-subsection structure has one subsection too many (LOW)

The `### External Skills` subsection inside `## Session Resources` preserves a table
that has appeared in zero of 50+ reports. The plan correctly notes this. Keeping it
as a subsection means the new section inherits dead weight from the old one. If
External Skills is ever discovered, a simple bullet in Skills Invoked ("discovered
but not invoked" / "discovered and invoked") would suffice without a separate
subsection and its four-column table.

**Simpler alternative**: Drop the External Skills subsection entirely. If external
skill discovery becomes real in the future, add the subsection then (YAGNI). This
reduces the Session Resources section from three subsections to two, simplifies the
Conditional Section Rules (one fewer conditional subsection), and removes the
"discovered vs. invoked" confusion risk (Risk #3 in the plan) at the source.

**Non-blocking because**: The plan already makes External Skills conditional and
collapsed, so the dead weight cost is minimal. If preserving it is important for
schema continuity, that is a reasonable judgment call.

### 2. Tool Usage table is best-effort data in a structured format (LOW)

Presenting approximate, post-compaction-degraded counts in a precise-looking markdown
table creates a false-precision signal. The plan acknowledges this with disclaimers,
which is the right mitigation. No change needed, but consider whether a prose line
("Orchestrator used ~45 Task calls, ~30 Read calls, ...") would be more honest about
the data quality than a table with exact-looking numbers.

**Non-blocking**: The disclaimer is adequate.

### 3. Frontmatter field conditional logic adds cognitive load (LOW)

The `skills-used` field appears only when skills beyond `/nefario` were used, while
the body section always lists `/nefario`. Two different inclusion rules for
the same data creates a small inconsistency readers must internalize. Consider: always
include the field (even if only listing `/nefario`) or always omit `/nefario` from
both. Consistency reduces cognitive load.

**Non-blocking**: The conditional rule is documented clearly enough. This is a
style preference.

### Complexity Budget Assessment

- New abstraction layers: 0
- New dependencies: 0
- New technologies: 0
- Task count: 2 (proportional to the change)
- Files changed: 2 (TEMPLATE.md, SKILL.md)
- Scope alignment: Tight. No scope creep detected. The plan does exactly what was
  requested (track skills and tools in reports) without expanding into adjacent areas.

The plan is lean for what it delivers. Proceed.
