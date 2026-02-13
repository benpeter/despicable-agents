You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly).

The fix introduces a classification boundary: "logic-bearing markdown" vs "documentation-only markdown." This distinction needs to be documented so future contributors (both human and AI agents) understand it.

## Your Planning Question

1. Where should the canonical definition of this boundary live -- in SKILL.md (where the phase conditionals reference it), in AGENT.md (where the delegation table lives), in both, or in a separate document? Consider that the primary consumers of these files are AI agents reading them as system prompts, and duplication risks divergence.

2. Should the classification include worked examples (e.g., "AGENT.md in an agent directory = logic-bearing; README.md = documentation-only")? If so, how many examples strike the balance between clarity and clutter in a file that is already a long system prompt?

3. Is there existing project documentation (docs/architecture.md, the-plan.md) that should reference or be updated to reflect this distinction? Note: the-plan.md must not be modified (per project CLAUDE.md). If you believe the-plan.md needs updating, flag it as a recommendation for the human owner rather than a planned change.

4. The issue's success criteria include "the distinction is clear and documented so future contributors understand the boundary." What documentation format best achieves this for a project where the primary consumers are AI agents reading these files as system prompts?

Note: ai-modeling-minion defines what the boundary IS (domain expertise). Your role is ensuring the boundary is CAPTURED where it will be found and maintained (documentation expertise). lucy ensures the boundary ALIGNS with project intent. Avoid overlapping into classification criteria -- focus on placement, format, and maintainability.

## Context

Read these files:
- docs/architecture.md
- the-plan.md -- for reference (do NOT recommend modifications)
- CLAUDE.md -- project conventions
- nefario/AGENT.md -- one of the target files for the documentation
- skills/nefario/SKILL.md -- one of the target files for the documentation (lines 1638-1710 for the phase conditionals)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-software-docs-minion.md
