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

What is the minimum change needed for self-containment without over-engineering the format? There's a risk of advisories becoming too verbose or structured, defeating their purpose as quick-scan items. What constraints prevent advisory bloat while meeting the self-containment criteria?

## Context

Current advisory is compact (2-3 lines):
```
ADVISORIES:
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>
```

The 3-line maximum per advisory rule exists in SKILL.md. Adding more fields risks violating this constraint.

Current ADVISE verdict format (4 lines):
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  TASK: <task number affected, e.g., "Task 3">
  CHANGE: <what specifically changed in the task prompt or deliverables>
  RECOMMENDATION: <suggested change>
```

The success criteria require:
- Name the concrete artifact, file, or concept (not "step 1")
- CHANGE in domain terms, not plan-internal numbering
- WHY with self-contained rationale

Key question: Can these requirements be met by changing WHAT goes in the existing fields (instructions to agents), or do the fields themselves need restructuring?

Files to read:
- margo/AGENT.md - your full agent definition
- nefario/AGENT.md - nefario agent with verdict format
- skills/nefario/SKILL.md - orchestration skill (search for "ADVISORIES" and "3-line maximum")

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: margo

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-margo.md
