You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix the structural serverless bias in the agent system. The agent team defaults to Docker+Terraform for every deployment, even when serverless would suffice. Three gaps compound: (1) iac-minion has zero serverless knowledge, (2) margo's complexity budget penalizes novelty not operational burden, (3) delegation table has no serverless routing.

Solution: four coordinated spec changes in the-plan.md: expand iac-minion spec, recalibrate margo spec, update delegation table, provide CLAUDE.md template for target projects.

Key note: Your opinions take precedence over devx-minion on deployment strategy boundaries (per user directive).

## Your Planning Question

Edge-minion has the deepest operational knowledge of serverless deployment platforms on this team, which makes your input critical for shaping the iac-minion spec expansion (even though iac-minion is not being consulted). Four questions:

(a) **Boundary with iac-minion**: When iac-minion gains serverless knowledge, where should the line be between iac-minion's responsibility (deployment strategy selection, platform choice, serverless cost modeling) and edge-minion's responsibility (platform-specific implementation patterns, Workers runtime, Pages config, edge storage)? If a user deploys a full app on Cloudflare Pages with Workers functions, which agent owns what?

(b) **Full-stack serverless framing**: The issue notes edge-minion should acknowledge Cloudflare Workers/Pages as a full-stack serverless platform, not only CDN compute. Does edge-minion's current spec and research already cover this sufficiently, or does the spec need explicit acknowledgment? What about Vercel (Next.js deployment), Netlify, and similar platforms -- should edge-minion's "Does NOT do" or "Remit" mention these to clarify boundaries?

(c) **iac-minion's decision framework**: From edge-minion's operational experience, what criteria actually determine when serverless is the right deployment choice vs. container-based infrastructure? What are the real escalation triggers -- request volume, execution duration, cold start sensitivity, data locality, stateful workloads -- that would signal a project has outgrown serverless?

(d) **Delegation table routing**: The issue proposes new rows for "Deployment strategy selection" and "Serverless platform deployment." From edge-minion's perspective, are these the right task-type names, and is the primary/supporting split correct (iac-minion primary, edge-minion + devx-minion supporting)?

## Context

Read these files for context:
- Current edge-minion spec: the-plan.md lines 751-784
- Current iac-minion spec: the-plan.md lines 722-749
- Current delegation table: the-plan.md lines 293-390
- Current edge-minion AGENT.md: minions/edge-minion/AGENT.md
- Current iac-minion AGENT.md: minions/iac-minion/AGENT.md

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: edge-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-edge-minion.md`
