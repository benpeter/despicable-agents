You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Add `--advisory` flag to `/nefario` for advisory-only orchestrations.

When `--advisory` is present:
- Phases 1-2 run identically (meta-plan, specialist planning)
- Phase 3 produces a recommendation synthesis instead of an execution plan
- Phases 3.5-8 are skipped (no architecture review, no execution, no code review, no tests, no deployment, no docs)
- A report is generated with `mode: advisory` frontmatter
- No branch is created, no PR is opened
- Reports go to `docs/history/nefario-reports/` with the same naming convention

Prior analysis: `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`

## Your Planning Question

Design advisory synthesis behavior:
(a) What MODE does nefario receive for advisory synthesis?
(b) Exact output format for advisory synthesis?
(c) What AGENT.md changes are needed?
(d) How does Phase 1 meta-plan prompt differ for advisory?
Produce implementation-ready specifications.

## Context

Key files to read:
- `nefario/AGENT.md` -- current agent definition with MODE descriptions
- `skills/nefario/SKILL.md` -- Phase 3 synthesis section
- `docs/history/nefario-reports/TEMPLATE.md` -- current report template
- `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-ai-modeling-minion.md` -- your prior analysis
- `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase3-synthesis.md` -- prior synthesis

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ai-modeling-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ITMTbi/advisory-flag-nefario/phase2-ai-modeling-minion.md`
