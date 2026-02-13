You are modifying the nefario agent specification to support advisory-mode synthesis.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` with three changes:

**Change 1: Add Advisory Directive to Invocation Modes section**

After the existing MODE descriptions (after the paragraph about MODE: PLAN, around line 38-40), add a new H2 section:

```markdown
## Advisory Directive

When your prompt includes `ADVISORY: true`, you are producing an advisory
report instead of an execution plan. This directive is orthogonal to MODE --
it modifies the output format of SYNTHESIS and PLAN modes.

- `MODE: SYNTHESIS` + `ADVISORY: true` = produce an advisory report (see below)
- `MODE: META-PLAN` + `ADVISORY: true` = no effect (meta-plan is unchanged)
- `MODE: PLAN` + `ADVISORY: true` = produce an advisory report directly
```

**Change 2: Add advisory output format to MODE: SYNTHESIS working pattern**

Find the MODE: SYNTHESIS section. After the existing delegation plan format documentation and before the "## Architecture Review (Phase 3.5)" section, add:

```markdown
### Advisory Output (when ADVISORY: true)

When the prompt includes `ADVISORY: true`, produce an advisory report instead
of a delegation plan. Do NOT produce task prompts, agent assignments, execution
order, approval gates, architecture review agent lists, or cross-cutting
coverage checklists.

Output format:

## Advisory Report

**Question**: <the original task/question being evaluated>
**Confidence**: HIGH | MEDIUM | LOW
**Recommendation**: <1-2 sentence recommendation>

### Executive Summary

<2-3 paragraphs. Answer the question. State the recommendation. Note the
confidence level and what drives it.>

### Team Consensus

<Areas where all specialists agreed. Numbered list of consensus points.>

### Dissenting Views

<Where specialists disagreed. For each disagreement:>
- **<Topic>**: <Agent A> recommends X because [reason]. <Agent B> recommends Y
  because [reason]. Resolution: <how nefario resolved it, or "unresolved --
  presented for user judgment">.

### Supporting Evidence

<Key findings organized by domain. One H4 per specialist domain.>

#### <Domain 1>
<Findings relevant to the recommendation>

### Risks and Caveats

<What could invalidate the recommendation. Numbered list.>

### Next Steps

<If the recommendation is adopted, what the implementation path looks like.
This section naturally feeds into a follow-up `/nefario` execution if the user
decides to proceed.>

### Conflict Resolutions

<Description of conflicts between specialist recommendations and how they were
resolved. "None." if no conflicts arose.>
```

**Change 3: Add advisory note to MODE: PLAN section**

Find the MODE: PLAN paragraph. Add after the existing text:

```markdown
When `ADVISORY: true` is set, MODE: PLAN produces an advisory report directly
without specialist consultation. The output format is the same advisory report
format as MODE: SYNTHESIS + ADVISORY.
```

## What NOT to Do
- Do not modify any other sections of AGENT.md (delegation table, cross-cutting checklist, approval gates, post-execution phases, etc.)
- Do not add a new MODE: ADVISORY -- advisory is a directive, not a mode
- Do not change the existing delegation plan format
- Do not modify `the-plan.md`

## Context
- The advisory directive is orthogonal to MODE
- ai-modeling-minion designed this approach; devx-minion's insertion points are adopted
- SKILL.md changes depend on AGENT.md defining the format first
- The advisory report format is based on the exemplar at
  `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`

## Deliverables
- Modified `nefario/AGENT.md` with three changes

When you finish your task, report:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
