You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Fix the structural serverless bias in the agent system. The agent team defaults to Docker+Terraform for every deployment, even when serverless would suffice. Three gaps compound: (1) iac-minion has zero serverless knowledge, (2) margo's complexity budget penalizes novelty not operational burden, (3) delegation table has no serverless routing.

Solution: four coordinated spec changes in the-plan.md: expand iac-minion spec, recalibrate margo spec, update delegation table, provide CLAUDE.md template for target projects.

Key constraint: Do NOT make margo block self-hosted proposals. Margo enforces simplicity, not topology.

## Your Planning Question

How should margo's complexity budget and boring technology framework be recalibrated to account for operational burden? Specifically:

(a) The current complexity budget scores "New technology: 10 points" and "New service: 5 points" -- but a managed/serverless platform eliminates the ops burden that justifies those costs. How should managed services that eliminate deployment, monitoring, and scaling work score relative to self-managed infrastructure? What scoring model preserves the spirit of the budget (penalizing genuine complexity) while recognizing that operational simplicity IS simplicity?

(b) Which serverless platforms qualify as "boring technology" by margo's own stated criteria (production hardened, known failure modes, staffable talent, community docs)? Vercel, Cloudflare Pages, and AWS Lambda have 5-10+ years of production track records -- should they graduate from "new technology" (10 points) to effectively zero marginal cost?

(c) How should "infrastructure over-engineering detection" work as a review heuristic -- what signals indicate a project has more infrastructure than it needs, without making margo prescriptive about topology?

(d) The issue explicitly says "do NOT make margo block self-hosted proposals." How do you frame the recalibration so margo can flag disproportionate complexity without vetoing legitimate infrastructure choices?

## Context

Read these files for context:
- Current margo spec: the-plan.md lines 537-570
- Current margo AGENT.md: margo/AGENT.md (especially Complexity Budget section and Boring Technology section)
- The boundary clarification: margo detects disproportionate complexity but does NOT prescribe serverless

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase2-margo.md`
