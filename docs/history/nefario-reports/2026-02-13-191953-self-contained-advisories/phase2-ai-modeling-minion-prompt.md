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

Advisories are produced by LLM agents following prompt instructions, and consumed by both humans (at approval gates, in reports) and LLMs (advisory text is folded into task prompts for execution agents). How should the advisory format be designed so that:
1. Agent prompts (instructions to reviewers) reliably produce self-contained advisories without requiring examples for every edge case?
2. The advisory text works well when injected into execution agent prompts (consumed by an LLM that needs to understand what to change and why)?
3. The format avoids ambiguity that could cause LLMs to revert to generic phrasing?

Consider prompt engineering best practices for structured output generation.

## Context

Current reviewer prompt template (Phase 3.5, from skills/nefario/SKILL.md):
```
You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

## Your Review Focus
<domain-specific: security gaps / test coverage / observability gaps / etc.>

## Instructions
Return exactly one verdict:
- APPROVE: No concerns from your domain.
- ADVISE: <list specific non-blocking warnings>
- BLOCK: <describe the blocking issue and what must change>

Be concise. Only flag issues within your domain expertise.
```

Current ADVISE format (nefario/AGENT.md):
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  TASK: <task number affected, e.g., "Task 3">
  CHANGE: <what specifically changed in the task prompt or deliverables>
  RECOMMENDATION: <suggested change>
```

The advisory is then transformed for the execution plan gate (SKILL.md):
```
ADVISORIES:
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>
```

And advisories are "folded into relevant task prompts" for execution agents -- meaning the text is literally appended to agent prompts.

Files to read:
- nefario/AGENT.md - verdict format definition
- skills/nefario/SKILL.md - reviewer prompt templates, advisory surfaces, folding logic

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-ytuTko/self-contained-advisories/phase2-ai-modeling-minion.md
