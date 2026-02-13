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

The calling session needs to track which skills were invoked and which tools were used, then populate the report at wrap-up. Session context already tracks phase data at boundaries. How should skills/tools tracking integrate into Data Accumulation? Specifically: (1) At what phase boundaries should skill invocations be recorded? (2) Can tool usage counts be extracted from conversation context reliably, or is this inherently best-effort? (3) What is the minimal session context overhead? (4) The existing `External Skills` section tracks skills *discovered* during meta-plan. The new section should track skills actually *invoked*. How should data accumulation instructions distinguish "discovered" from "invoked"?

## Context

Read these files for context:
- `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` (full skill instructions -- focus on Data Accumulation, Inline Summary Template, Phase 4 Execution, and Report Generation sections)
- `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/TEMPLATE.md` (report template)

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase2-ai-modeling-minion.md`
