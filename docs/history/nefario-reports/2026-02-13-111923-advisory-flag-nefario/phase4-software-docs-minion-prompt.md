You are updating the nefario report template to support advisory-mode reports.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`
with these changes:

**Change 1: Add `advisory` to mode field** in the Frontmatter Fields table

Change:
```
| `mode` | always | `full` (all phases) or `plan` (planning only) |
```
To:
```
| `mode` | always | `full` (all phases), `plan` (planning only), or `advisory` (recommendation only) |
```

**Change 2: Add Team Recommendation section to skeleton**

In the skeleton (between Agent Contributions closing `</details>` and the Execution section `## Execution`), add:

```markdown
## Team Recommendation

**{One-line recommendation.}**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| {position} | {agents} | {strength assessment} |

### When to Revisit

{Numbered list of concrete trigger conditions under which the recommendation
should be re-evaluated.}

### Strongest Arguments

**For {adopted position}** (adopted):

| Argument | Agent |
|----------|-------|
| {argument} | {agent} |

**For {rejected position}** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| {argument} | {agent} |
```

**Change 3: Add conditional section rules** to the Conditional Section Rules table.

Add these rows to the existing table:

```
| Team Recommendation | `mode` = `advisory` | `mode` != `advisory` |
| Execution | `mode` != `advisory` | `mode` = `advisory` |
| Verification | `mode` != `advisory` | `mode` = `advisory` |
| Agent Contributions: Architecture Review subsection | Phase 3.5 ran | `mode` = `advisory` or Phase 3.5 skipped |
| Agent Contributions: Code Review subsection | Phase 5 ran | `mode` = `advisory` or Phase 5 skipped |
```

Also update the existing Test Plan row to add the advisory condition:
The Test Plan row should say OMIT WHEN includes `mode` = `advisory`.

**Change 4: Add advisory formatting note** to the Formatting Rules section:

Add these bullet points:
```markdown
- **Advisory mode Phases**: Phases 1-3 get full narrative. Phases 3.5-8 each
  get a single line: `Skipped (advisory-only orchestration).`
- **Team Recommendation**: One-line recommendation in bold, followed by
  Consensus table (always required). When to Revisit, Escalation Path, and
  Strongest Arguments subsections are recommended but optional.
- **Agent Contributions summary**: Use `({N} planning)` not
  `({N} planning, {N} review)` when no review phases ran.
```

**Change 5: Add advisory steps to Report Writing Checklist**

After step 10 (Write Agent Contributions), add:
```markdown
10a. If `mode` = `advisory`: Write Team Recommendation (bold one-line recommendation,
     Consensus table, optional subsections: When to Revisit, Escalation Path,
     Strongest Arguments)
10b. If `mode` = `advisory`: Skip steps 11-13, 16 (Execution, Decisions,
     Verification, Test Plan)
```

**Change 6: Add advisory note to Incremental Writing section**

Add:
```markdown
For advisory-mode orchestrations (`mode: advisory`), the report is written once
at Advisory Wrap-up, not incrementally. Phase 3 is the final phase.
```

## What NOT to Do
- Do not create a separate template file for advisory reports
- Do not bump template version (this is a minor extension to v3)
- Do not modify skeleton sections that are shared between modes
- Do not modify `the-plan.md`

## Context
- The exemplar advisory report is at
  `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`
- Existing conditional rules demonstrate the pattern
- Template stays at v3

## Deliverables
- Modified `docs/history/nefario-reports/TEMPLATE.md` with advisory mode support

When you finish your task, report:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
