# Issue #91: Fix structural serverless bias in agent system

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
```
Serverless deployment patterns (Vercel, Cloudflare Pages/Workers, AWS Lambda + API Gateway),
serverless vs. container decision frameworks, serverless cost modeling and crossover analysis,
vendor lock-in portability assessment patterns.
```

Add to **Principles** (or add a Principles section if absent):
> Ask "does this project need infrastructure?" before designing infrastructure. Serverless is the default for greenfield; server infrastructure is the escalation path when serverless constraints are hit.

The research focus instructs `/despicable-lab` what to research. The remit additions tell it what knowledge to encode. The rebuilt RESEARCH.md and AGENT.md will naturally include:
- A deployment strategy triage decision tree (does the project need long-running processes, persistent connections, custom OS deps, compliance control, cost-optimized high traffic? NO to all -> serverless)
- Serverless platform knowledge (Vercel deep, CF Pages moderate, Lambda moderate, Netlify light)
- Repositioned Terraform/Docker sections as escalation-path knowledge
- Vendor lock-in portability assessment as standard output

### 2. Recalibrate margo's spec in the-plan.md (1.0 -> 1.1)

Add to **Remit** (or equivalent guidance for the research/build):
- Infrastructure over-engineering detection
- Deployment complexity assessment (managed/serverless vs self-managed)

Add to **Principles**:
> Complexity budget should measure operational burden, not just novelty. Managed/serverless services that eliminate ops work score lower than self-managed services. Serverless platforms (Lambda 2014, Workers 2018, Vercel 2020) are boring technology.

Add to **Research focus**:
```
Infrastructure over-engineering patterns and detection heuristics, serverless as boring
technology (maturity evidence), operational burden vs novelty in complexity scoring,
managed vs self-managed service complexity comparison.
```

This instructs `/despicable-lab` to research and encode:
- Split complexity budget: self-managed service (8 pts) vs managed/serverless (3 pts)
- Serverless in the boring technology examples
- An "Infrastructure Over-Engineering" detection pattern with trigger signals (no scaling/state/long-running requirement, config rivaling app code, small team, greenfield) and counter-signals (persistent connections, GPU, compliance, cost at scale)
- YAGNI pattern: server infrastructure for stateless APIs within serverless limits

### 3. Update the delegation table in the-plan.md

Add rows to the nefario delegation table (Infrastructure & Data section):

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Deployment strategy selection | iac-minion | devx-minion |
| Serverless platform deployment (Vercel, CF Pages, Netlify, Lambda) | iac-minion | edge-minion |

Nefario's AGENT.md mirrors this table, so it will be updated on the next nefario rebuild.

### 4. Provide CLAUDE.md template for target projects

Add guidance to docs (e.g., `docs/orchestration.md` or a new section) with a copy-paste CLAUDE.md template for target projects:

```markdown
## Infrastructure Defaults

- For greenfield projects, prefer serverless/managed services (Vercel, Cloudflare Pages,
  Lambda, managed databases) over self-hosted infrastructure unless the workload has
  specific requirements that serverless cannot meet (persistent connections, long-running
  processes, compliance-mandated infrastructure control, cost optimization at scale).
- Justify self-hosted infrastructure against the serverless alternative in the plan.
```

This keeps agents generic (publishable, Apache 2.0) while giving target projects an enforceable preference that lucy can check.

## Execution sequence

1. **Update the-plan.md** (human-approved): bump iac-minion spec 1.0->1.1, margo spec 1.0->1.1, add delegation table rows, note edge-minion framing (Workers as full-stack serverless, not only CDN compute)
2. **Run `/despicable-lab`**: detects spec version divergence, re-runs research for iac-minion and margo, rebuilds their AGENT.md files from updated research + spec
3. **Nefario rebuild**: picks up mirrored delegation table changes on next rebuild
4. **Documentation**: add CLAUDE.md template to docs

## Boundary clarifications

- **iac-minion** owns deployment strategy selection and platform config (vercel.json, wrangler.toml basics, SAM templates)
- **edge-minion** owns edge-specific implementation (Workers code, Durable Objects, edge-side logic). Also acknowledge in edge-minion's framing that Cloudflare Workers/Pages is a full-stack serverless platform, not only CDN compute.
- **margo** detects when infrastructure complexity is disproportionate to the problem (simplicity question, in scope) but does NOT prescribe serverless as the answer (infrastructure preference, out of scope)

## Escalation mental model

The recommended greenfield default escalation path (to be encoded via iac-minion's research):

| Level | Path | Time to Deploy | Escalate when |
|-------|------|---------------|---------------|
| 0 | Static hosting (CF Pages, GitHub Pages) | < 2 min | Need server logic |
| 1 | Static + API routes (Vercel, CF Workers) | < 5 min | Need full app with SSR/DB |
| 2 | Full serverless app (Vercel + DB, Workers + D1) | 5-15 min | Need long-running processes or WebSockets |
| 3 | Serverless containers (Fargate, Cloud Run, Fly.io) | 15-30 min | Need compliance control or cost optimization at scale |
| 4 | Self-managed (Docker + Terraform + proxy) | 1-4 hours | -- |

Principle: complexity is opt-in, not opt-out. Start at Level 0. Escalate only when a specific constraint demands it.

## Technology maturity reference

| Platform | Status | Lock-in Risk |
|----------|--------|-------------|
| AWS Lambda | Adopt (12 years, production-proven) | High (AWS ecosystem) |
| Cloudflare Workers | Adopt (8 years, open-source runtime) | Medium |
| Vercel | Trial (strong DX, cost unpredictable at scale) | High (Next.js coupling) |
| Netlify | Trial (declining velocity) | Medium |
| Deno Deploy | Assess (sound, insufficient production signals) | Low |

## Risks to watch

1. **Over-correction** (medium): The triage decision tree must include counter-signals (persistent connections, long-running processes, compliance, cost at scale) equally prominently. Don't swing from "always servers" to "always serverless."
2. **Vendor lock-in** (high): Every serverless recommendation should include a portability assessment. Keep business logic in portable libraries; use serverless as a thin invocation layer.
3. **Knowledge breadth** (medium): Keep iac-minion's serverless knowledge at deployment/operations level. Deep Workers development stays with edge-minion. Database selection stays with data-minion.

## What NOT to do

- Do NOT create a 28th agent (serverless-minion) -- boundary conflicts with 4 agents
- Do NOT hardcode "serverless-first" in iac-minion's AGENT.md -- makes a generic agent opinionated
- Do NOT edit AGENT.md or RESEARCH.md directly -- those are generated by `/despicable-lab` from the-plan.md spec
- Do NOT add the preference to despicable-agents' own CLAUDE.md -- wrong scope
- Do NOT make margo block self-hosted proposals -- margo enforces simplicity, not topology

## Advisory source

Produced by nefario advisory orchestration (2026-02-13) with 9 agents at opus: nefario, iac-minion, margo, gru, lucy, devx-minion, security-minion, test-minion, ux-strategy-minion. All 5 planning specialists reached unanimous conclusions independently. Architecture review: 2 APPROVE, 3 ADVISE, 0 BLOCK.

---
Additional context: use opus for all agents, make ai-modeling part of the roster
