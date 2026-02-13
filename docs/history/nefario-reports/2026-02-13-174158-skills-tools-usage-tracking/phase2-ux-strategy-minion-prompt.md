You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

<github-issue>
**Outcome**: Nefario execution reports capture which skills and tools were used during the orchestration session, providing visibility into resource utilization and enabling retrospective analysis of agent behavior patterns.

**Success criteria**:
- Report template includes a section for skills invoked during the session
- Report template includes a section for tools used (with counts if feasible)
- Skills tracking is populated by the calling session from conversation context (no hooks or shell scripting required)
- Tool counts are best-effort — included if extractable from conversation context, omitted gracefully if not
- Existing reports remain valid (new section is additive)

**Scope**:
- In: Report template (`TEMPLATE.md`), skill instructions (`SKILL.md`), report generation guidance
- Out: Runtime hooks, shell-based instrumentation, modifying Claude Code internals, backfilling existing reports
</github-issue>

---
Additional context: use opus for all agents

## Your Planning Question

The nefario execution report is already detailed (12 sections in the template). Adding skills/tools tracking adds more content. From a UX strategy perspective: (1) Is this section worth the cognitive cost? Who reads it and when? (2) Where should it appear in the report's information hierarchy? Early (high-value) or late (reference-only)? (3) Should it be always-visible or collapsible? (4) How does it interact with the existing External Skills section and Agent Contributions section? (5) Is there a simpler alternative that achieves the same outcome (e.g., adding to frontmatter instead of a full section)?

## Context

Read these files for context:
- `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/TEMPLATE.md` (report template -- see full section list and collapsibility rules)
- A recent report to see what users actually read: `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-13-134802-gates-include-orchestration-title.md`

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-ux-strategy-minion.md`
