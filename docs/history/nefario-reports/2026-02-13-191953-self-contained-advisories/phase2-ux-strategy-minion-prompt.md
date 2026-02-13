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
- The verdict format (ADVISE, and potentially APPROVE/BLOCK) is updated if needed to support this

**Scope**:
- In: Advisory format and instructions across all phases and agents that produce advisories; verdict format definition in nefario and reviewer agent prompts
- Out: Verdict routing mechanics, phase sequencing, report template layout

## Your Planning Question

The advisory format currently uses `TASK: <task number>` and `CHANGE: <what changed in the task prompt>` -- references meaningful only inside the orchestration session. How should an advisory be structured so that a reader seeing only the advisory text (in a synthesis output, execution report, or task list) can evaluate it without opening the originating session? What replaces task numbers as anchoring context, how much domain context belongs in each advisory, and where is the line between "self-contained" and "bloated"?

## Context

Current ADVISE verdict format from nefario/AGENT.md:
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  TASK: <task number affected, e.g., "Task 3">
  CHANGE: <what specifically changed in the task prompt or deliverables>
  RECOMMENDATION: <suggested change>
```

Current execution plan ADVISORIES block from SKILL.md:
```
ADVISORIES:
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>
```

Phase 5 code review finding format:
```
VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>
```

Lucy/margo verdict formats:
- Lucy: APPROVE / ADVISE / BLOCK with structured verdicts
- Margo: APPROVE / ADVISE / BLOCK - leads with verdict

The advisory format appears on 5 surfaces:
1. Phase 3.5 reviewer verdict output
2. Execution plan ADVISORIES block (user-facing gate)
3. Inline summary template (session context)
4. Execution report
5. Phase 5 code review findings

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-ux-strategy-minion.md
