You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Make all nefario advisories self-contained and readable in isolation. Currently, advisories reference invisible context — task numbers, plan step details, internal decisions — that only make sense inside the agent conversation that produced them. After this change, each advisory carries enough context that a user reading the synthesis, execution report, or task list can evaluate it without opening the originating agent session.

**Success criteria**:
- Each advisory names the concrete artifact, file, or concept it concerns (not "step 1" or "the approach")
- CHANGE descriptions state what they propose in domain terms, not by referencing plan-internal numbering or structure
- WHY descriptions explain the risk or rationale using information present in the advisory itself
- A user seeing only the advisory block can answer: "what part of the system does this affect, what is suggested, and why"

**Scope**:
- In: Advisory format and instructions across all phases and agents that produce advisories; verdict format definition in nefario and reviewer agent prompts
- Out: Verdict routing mechanics, phase sequencing, report template layout

## Your Planning Question

Advisories appear on five surfaces: Phase 3.5 verdict output, execution plan ADVISORIES block, inline summary template, execution report, and Phase 5 code review findings. How should the format be unified so every surface presents a self-contained advisory without requiring cross-referencing? What is the minimal field set that achieves self-containment across all surfaces, and where do surface-specific fields (scratch file links) belong?

## Context

The five surfaces and current formats:

**Surface 1 - Phase 3.5 reviewer verdict (nefario/AGENT.md)**:
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  TASK: <task number affected, e.g., "Task 3">
  CHANGE: <what specifically changed in the task prompt or deliverables>
  RECOMMENDATION: <suggested change>
```

**Surface 2 - Execution plan ADVISORIES block (skills/nefario/SKILL.md)**:
```
ADVISORIES:
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>
```

**Surface 3 - Inline summary template (skills/nefario/SKILL.md)**:
```
## Summary: {agent-name}
Phase: {planning | review}
Recommendation: {1-2 sentences}
Tasks: {N} -- {one-line each, semicolons}
Risks: {critical only, 1-2 bullets}
Conflicts: {cross-domain conflicts, or "none"}
Verdict: {APPROVE | ADVISE(details) | BLOCK(details)}
```

**Surface 4 - Execution report (TEMPLATE.md)**:
```
**{agent-name}**: ADVISE. {Concern and recommendation.}
```

**Surface 5 - Phase 5 code review findings (skills/nefario/SKILL.md)**:
```
VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>
```

Files to read for full context:
- nefario/AGENT.md - nefario agent definition with verdict format
- skills/nefario/SKILL.md - orchestration skill with all surface formats
- docs/history/nefario-reports/TEMPLATE.md - report template
- lucy/AGENT.md, margo/AGENT.md - reviewer verdict formats

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-software-docs-minion.md
