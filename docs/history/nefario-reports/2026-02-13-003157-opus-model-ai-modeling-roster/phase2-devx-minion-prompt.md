You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix the structural serverless bias in the agent system. The agent team defaults to Docker+Terraform for every deployment, even when serverless would suffice. Three gaps compound: (1) iac-minion has zero serverless knowledge, (2) margo's complexity budget penalizes novelty not operational burden, (3) delegation table has no serverless routing.

Solution: four coordinated spec changes in the-plan.md: expand iac-minion spec, recalibrate margo spec, update delegation table, provide CLAUDE.md template for target projects.

Note: Edge-minion's opinions take precedence over yours on deployment strategy boundaries. Your input is about the template design and developer workflow UX, not platform ranking.

## Your Planning Question

devx-minion brings the developer experience perspective -- how the deployment strategy choice affects the humans using the agent system. Three questions, scoped to avoid overlap with edge-minion's platform expertise:

(a) **Developer workflow impact**: When the agent team recommends a deployment strategy, what DX dimensions matter? Time-to-deploy, local development experience, CI/CD simplicity, debugging and logs access, rollback ease? Which of these are systematically better with serverless vs. self-managed, and which are platform-dependent?

(b) **CLAUDE.md template design**: The issue's solution item #4 proposes a CLAUDE.md template for target projects that lets users declare deployment preferences. From a developer experience perspective, what should this template look like? What fields or sections help a user communicate their infrastructure context clearly to the agent team (e.g., "We deploy on Vercel," "We use Docker Compose," "No infra preference -- keep it simple")? What format follows existing CLAUDE.md conventions?

(c) **Sensible defaults**: The template should embody "sensible defaults, progressive complexity" (devx-minion's own principle). What is the right default for a project with NO deployment preference stated -- should the agents assume simplest-viable (serverless) or ask? Note: defer to edge-minion's perspective on which platforms qualify as "simplest" -- devx-minion's input here is about the template design and default-selection UX, not platform ranking.

## Context

Read these files for context:
- Current devx-minion spec: the-plan.md lines 973-1011
- Current devx-minion AGENT.md: minions/devx-minion/AGENT.md
- The project's CLAUDE.md for format conventions
- The user's global CLAUDE.md at ~/.claude/CLAUDE.md for format conventions
- The issue's solution item #4 (CLAUDE.md template for target projects)
- docs/ directory listing for existing documentation patterns

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-devx-minion.md`
