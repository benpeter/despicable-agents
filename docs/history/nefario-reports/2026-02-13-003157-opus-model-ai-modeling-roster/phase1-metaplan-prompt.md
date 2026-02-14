MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
## Problem

The agent system has a structural bias against serverless infrastructure. When starting greenfield projects, it recommends Docker + Terraform + reverse proxy stacks even when `vercel deploy` (1 command, zero config) would suffice. The bias is not an explicit rule -- it emerges from three compounding gaps.

### Gap 1: iac-minion has zero serverless knowledge

The word "serverless" appears zero times in iac-minion's AGENT.md. Its remit lists Terraform, Docker, GitHub Actions, reverse proxies, and server deployment. Its Infrastructure Design Approach starts with "select cloud provider" and "design network topology" without ever asking: **does this project need infrastructure at all?**

When nefario delegates a greenfield deployment task, iac-minion produces a Docker + Terraform + Caddy stack because that's the only thing it knows. The operational complexity ratio is roughly 10:1 (server stack vs serverless).

### Gap 2: margo's complexity budget penalizes novelty, not operational burden

The complexity budget scores "New service: 5 points" -- treating `vercel deploy` the same as Docker + Terraform + Caddy. A team already using Docker pays 0 points for maintaining that stack but 10 points ("New technology") for adopting Vercel, even though Vercel eliminates entire categories of operational work.

The "Boring Technology" section cites Postgres, Redis, Nginx as boring tech. AWS Lambda (2014), Cloudflare Workers (2018), and Vercel (2020) are conspicuously absent despite meeting every stated criterion. Margo -- the agent whose job is to catch over-engineering -- currently cannot detect infrastructure over-engineering.

### Gap 3: Delegation table has no serverless routing

The delegation table routes "Infrastructure provisioning" to iac-minion. There is no row for "deployment strategy selection" or "serverless deployment." When a user asks to deploy a greenfield project, nefario routes it as "infrastructure provisioning" because that's the only matching row -- which presupposes that infrastructure needs provisioning.

### Compounding effect

1. Nefario routes deployment work to iac-minion (delegation table assumes infrastructure)
2. iac-minion proposes servers (only knowledge it has)
3. margo approves the plan (complexity budget doesn't penalize operational burden)
4. Result: server infrastructure for every project, regardless of need

## Solution

Four coordinated changes, no new agent. The build pipeline is: `the-plan.md` (spec) -> `/despicable-lab` (research + build) -> AGENT.md. All content changes flow through the spec; AGENT.md and RESEARCH.md are generated artifacts.

### 1. Expand iac-minion's spec in the-plan.md (1.0 -> 1.1)

Add to **Remit**:
- Deployment strategy selection (serverless vs. container vs. self-managed)
- Serverless deployment patterns (Vercel, Cloudflare Pages, AWS Lambda, Netlify)
- Serverless cost modeling and escalation triggers

Add to **Research focus**:
Serverless deployment patterns (Vercel, Cloudflare Pages/Workers, AWS Lambda + API Gateway), serverless vs. container decision frameworks, serverless cost modeling and crossover analysis, vendor lock-in portability assessment patterns.

Add to **Principles** (or add a Principles section if absent):
Ask "does this project need infrastructure?" before designing infrastructure. Serverless is the default for greenfield; server infrastructure is the escalation path when serverless constraints are hit.

### 2. Recalibrate margo's spec in the-plan.md (1.0 -> 1.1)

Add to **Remit**:
- Infrastructure over-engineering detection
- Deployment complexity assessment (managed/serverless vs self-managed)

Add to **Principles**:
Complexity budget should measure operational burden, not just novelty. Managed/serverless services that eliminate ops work score lower than self-managed services. Serverless platforms (Lambda 2014, Workers 2018, Vercel 2020) are boring technology.

Add to **Research focus**:
Infrastructure over-engineering patterns and detection heuristics, serverless as boring technology (maturity evidence), operational burden vs novelty in complexity scoring, managed vs self-managed service complexity comparison.

### 3. Update the delegation table in the-plan.md

Add rows to the nefario delegation table (Infrastructure & Data section):

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Deployment strategy selection | iac-minion | devx-minion |
| Serverless platform deployment (Vercel, CF Pages, Netlify, Lambda) | iac-minion | edge-minion |

### 4. Provide CLAUDE.md template for target projects

Add guidance to docs with a copy-paste CLAUDE.md template for target projects about infrastructure defaults.

## Boundary clarifications

- **iac-minion** owns deployment strategy selection and platform config
- **edge-minion** owns edge-specific implementation. Also acknowledge in edge-minion's framing that Cloudflare Workers/Pages is a full-stack serverless platform, not only CDN compute.
- **margo** detects when infrastructure complexity is disproportionate to the problem but does NOT prescribe serverless as the answer

## What NOT to do

- Do NOT create a 28th agent (serverless-minion)
- Do NOT hardcode "serverless-first" in AGENT.md -- makes a generic agent opinionated
- Do NOT edit AGENT.md or RESEARCH.md directly -- those are generated by /despicable-lab from the-plan.md spec
- Do NOT make margo block self-hosted proposals -- margo enforces simplicity, not topology
</github-issue>

---
Additional context: use opus for all agents, make ai-modeling part of the roster

## Working Directory
/Users/ben/github/benpeter/2despicable/4

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase1-metaplan.md`
