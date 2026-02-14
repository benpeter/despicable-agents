You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix the structural serverless bias in the agent system. The agent team defaults to Docker+Terraform for every deployment, even when serverless would suffice. Three gaps compound: (1) iac-minion has zero serverless knowledge, (2) margo's complexity budget penalizes novelty not operational burden, (3) delegation table has no serverless routing.

Solution: four coordinated spec changes in the-plan.md: expand iac-minion spec, recalibrate margo spec, update delegation table, provide CLAUDE.md template for target projects.

The issue (GitHub #91) was produced by a nefario advisory orchestration and constitutes the human owner's approved direction.

## Your Planning Question

Lucy brings governance alignment and repo convention enforcement. Five questions covering the territory that both iac-minion's self-assessment and software-docs-minion's documentation review would have covered:

(a) **Intent alignment**: The issue states four specific changes. Do the proposed changes faithfully address the three gaps identified without introducing scope beyond what was requested? Are there any risks of the planning team drifting from the issue's intent (e.g., expanding edge-minion's spec more than the issue calls for, or making the CLAUDE.md template more opinionated than needed)?

(b) **Spec consistency**: When iac-minion's spec is bumped to 1.1 and margo's spec to 1.1, do the changes need to be reflected anywhere else in the-plan.md for internal consistency? Are there cross-references between agent specs, the delegation table, the nefario working patterns, or the build process section that would become stale?

(c) **Boundary coherence**: The expanded iac-minion will overlap with edge-minion on serverless platforms. Does the-plan.md structure have conventions for how "Does NOT do" sections and remit boundaries are expressed that the new spec must follow? Are there existing boundary patterns between other agents that should serve as templates?

(d) **CLAUDE.md compliance**: The project's CLAUDE.md says "Do NOT modify the-plan.md unless the human owner approves." The issue constitutes that approval. Are there other CLAUDE.md rules that constrain how this work should proceed?

(e) **Repo convention review**: If the CLAUDE.md template (issue item #4) is placed in the docs/ directory, does it follow existing documentation patterns? What naming and format conventions should it adhere to?

## Context

Read these files for context:
- the-plan.md (full file, especially: Design Principles lines 1-74, versioning lines 50-64, delegation table lines 293-390, "Does NOT do" sections for iac-minion and edge-minion)
- CLAUDE.md (project instructions)
- docs/ directory listing and sample docs for format conventions
- docs/architecture.md (first 50 lines for structure reference)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: lucy

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-lucy.md`
