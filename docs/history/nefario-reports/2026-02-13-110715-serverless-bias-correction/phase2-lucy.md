# Phase 2: Lucy -- Convention Enforceability Analysis

**Planning question**: Where should "serverless-first for greenfield" live to be most enforceable, least likely to drift, and most discoverable during planning?

---

## 1. Framing the Problem from a Convention Enforcement Perspective

I enforce conventions by verifying that plans and code comply with declared directives. A convention only works if it is (a) written down in a location I can read, (b) unambiguous enough to produce APPROVE/BLOCK verdicts, and (c) in the resolution path that agents consult before making decisions. Anything that does not meet all three criteria will drift.

The question has a critical secondary dimension the task description already flags: this is an Apache 2.0 publishable agent system. Hardcoding opinionated infrastructure defaults into agent AGENT.md files makes the system less generic. That constraint must weigh heavily in the recommendation.

---

## 2. Analysis of Each Option

### (a) Project CLAUDE.md as a technology preference

**Enforceability: HIGH.** CLAUDE.md is loaded into every agent session. I already verify CLAUDE.md compliance as part of my standard review workflow. A directive like "For greenfield infrastructure, prefer serverless/managed services over self-hosted unless the workload has sustained, predictable compute requirements" would be checkable against any plan that proposes infrastructure.

**Drift risk: LOW.** CLAUDE.md is the canonical convention source. It is human-edited, version-controlled, and diff-visible in PRs. Changes require deliberate human action. This is the mechanism already used for the "prefer lightweight, vanilla solutions" directive in the current CLAUDE.md (line 44-47), which is enforced project-wide.

**Discoverability: HIGH.** Every agent in the system receives CLAUDE.md context. It is Priority 2 in the resolution hierarchy (or Priority 1 via CLAUDE.local.md). No agent can miss it.

**Publishability impact: NONE -- but only if placed in CLAUDE.local.md or the target project's CLAUDE.md.** If placed in despicable-agents' own CLAUDE.md, it becomes an opinionated stance in a published tool. The correct pattern is: the despicable-agents project itself does not declare this preference (its agents are generic), but the user's target project CLAUDE.md does. This is identical to how `CLAUDE.local.md` already handles the Adobe-adjacent technology bias without baking it into published agents.

**Verdict**: Best option for per-project enforcement. Not suitable for hardcoding in the despicable-agents repo's own CLAUDE.md.

### (b) Margo's heuristics as a complexity calibration

**Enforceability: MEDIUM.** Margo's complexity budget (AGENT.md lines 55-62) currently scores: new technology (10 pts), new service (5 pts), new abstraction layer (3 pts), new dependency (1 pt). This scoring system does not distinguish between "new technology: self-hosted Kubernetes" and "new technology: AWS Lambda." Both get 10 points. To encode a serverless preference, margo would need a heuristic like "operational burden compounds: self-managed infrastructure incurs ongoing ops cost that should be counted against the complexity budget; serverless/managed services reduce operational complexity even if they add a new technology."

**Drift risk: MEDIUM.** Margo's heuristics are baked into AGENT.md, which is generated from the-plan.md spec. Changes require spec version bumps and rebuilds. This is more rigid than CLAUDE.md (good for stability, bad for per-project customization). However, margo's job is simplicity enforcement, not infrastructure strategy. Adding infrastructure topology preferences to margo's remit is a scope expansion for the agent itself.

**Discoverability: LOW for infrastructure decisions.** Margo participates in Phase 3.5 architecture review (always), but iac-minion makes the initial infrastructure proposal in Phase 2. By the time margo reviews, the infrastructure choice may already be baked into the plan. Margo can flag complexity, but cannot steer the initial proposal.

**Publishability impact: PROBLEMATIC.** Making margo opinionated about serverless vs. self-hosted embeds an infrastructure stance into a generic simplicity enforcer. Not all users want serverless-first. This violates the "generic domain specialists" design principle (the-plan.md line 11).

**Verdict**: Margo could benefit from an operational complexity dimension in the budget, but should not become the primary vehicle for serverless preferences. That would be scope creep on margo's remit.

### (c) iac-minion's working patterns as a "start here" default

**Enforceability: LOW-MEDIUM.** iac-minion's knowledge shapes what it proposes, but iac-minion only participates when infrastructure work is in scope. The current iac-minion spec (the-plan.md lines 722-748) and AGENT.md show a clear server-centric orientation: Terraform, Docker, Docker Compose, Caddy, Nginx, Hetzner Cloud, server deployment strategies (canary, blue-green, rolling). Serverless appears exactly once in the RESEARCH.md (line 247, as a cost optimization afterthought). The agent has no serverless working patterns, no Lambda/Cloud Functions knowledge, no serverless-first decision framework.

**Drift risk: LOW (for the agent itself).** Agent knowledge is versioned and rebuilt from the-plan.md. However, "start here" defaults in an agent's working patterns are soft guidance, not hard conventions. Without external enforcement (CLAUDE.md or a review checkpoint), iac-minion could still default to its deeper knowledge (server-based) when a user prompt is ambiguous.

**Discoverability: MEDIUM.** Discoverable by nefario when delegating infrastructure tasks, and by iac-minion itself during execution. Not discoverable by other agents who might make infrastructure-adjacent decisions (e.g., data-minion choosing between self-hosted Postgres and Neon, edge-minion choosing between self-hosted Nginx and Cloudflare Workers).

**Publishability impact: PROBLEMATIC.** Same issue as (b). Making iac-minion default to serverless makes it opinionated in the published artifact. A user running these agents for an on-prem enterprise deployment would find the default unhelpful.

**Verdict**: iac-minion's knowledge gap is a real problem regardless of where the convention lives. The agent needs serverless knowledge to execute on serverless plans. But "start here" defaults in agent knowledge are not the right enforcement mechanism for a project preference.

### (d) Delegation table in the-plan.md as a new routing row

**Enforceability: LOW.** The delegation table routes task types to agents. It answers "who does this work?" not "how should they do it?" Adding a row like "Serverless infrastructure | iac-minion | edge-minion" tells nefario who to assign, but does not tell iac-minion to prefer serverless. Routing is not policy.

**Drift risk: LOW (stable location).** The delegation table changes infrequently. But a routing row cannot express "prefer X over Y for greenfield."

**Discoverability: HIGH for nefario.** Nefario consults the delegation table during META-PLAN. However, the table cannot encode decision heuristics, only assignments.

**Publishability impact: NEUTRAL.** A routing row for serverless tasks is reasonable -- it says "these tasks exist" not "prefer these tasks."

**Verdict**: A serverless routing row in the delegation table is useful as a gap fix (so nefario knows serverless tasks exist and who handles them), but it cannot encode a preference or default. Wrong tool for the stated goal.

### (e) A combination

This is the correct answer, but a specific combination, not all of the above.

---

## 3. Recommendation: Layered Approach

### Layer 1 -- Target project CLAUDE.md (primary enforcement point)

The "serverless-first for greenfield" preference belongs in the CLAUDE.md of each target project that wants it, not in the despicable-agents system itself. This is the same pattern already used for "prefer lightweight, vanilla solutions" at the user level.

Example directive for a target project's CLAUDE.md:
```
## Infrastructure Defaults
- For greenfield projects, prefer serverless/managed services (Lambda, Cloud Functions,
  managed databases) over self-hosted infrastructure unless the workload has sustained
  predictable compute that makes reserved instances cheaper.
- Justify self-hosted infrastructure against the serverless alternative in the plan.
```

This is:
- Enforceable by lucy (I check CLAUDE.md compliance on every plan)
- Discoverable by every agent (CLAUDE.md is loaded into all sessions)
- Per-project customizable (different projects can have different defaults)
- Not baked into published agents (preserves generic/publishable constraint)

### Layer 2 -- iac-minion knowledge gap (prerequisite fix)

Regardless of where the preference lives, iac-minion cannot execute serverless plans with its current knowledge. The spec (the-plan.md lines 722-748) and the AGENT.md are purely server-centric. This is a knowledge gap, not a convention question. Fix it by:

1. Expanding iac-minion's remit in the-plan.md to include serverless patterns (Lambda, Cloud Functions, API Gateway, serverless frameworks like SST/Serverless Framework)
2. Adding serverless working patterns to RESEARCH.md and AGENT.md
3. Adding a "greenfield decision framework" working pattern: "When starting from scratch, evaluate serverless vs. self-hosted based on: traffic pattern (bursty vs. steady), latency requirements, cold start tolerance, cost at expected scale"

This makes iac-minion capable of proposing serverless when appropriate, without making it the default. The default comes from CLAUDE.md.

### Layer 3 -- Delegation table gap (routing fix)

Add serverless-relevant rows to the delegation table so nefario knows to involve iac-minion for serverless tasks:

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Serverless function design | iac-minion | api-design-minion |
| Serverless deployment & packaging | iac-minion | test-minion |

This ensures nefario routes serverless work correctly rather than dropping it or misassigning it.

### Layer 3.5 -- Margo operational complexity awareness (optional enhancement)

Margo's complexity budget could benefit from an "operational complexity" dimension that recognizes ongoing ops burden as a complexity cost. This is not serverless-specific -- it is a general improvement to complexity assessment. Currently the budget scores one-time adoption costs but not ongoing operational costs (patching, scaling, monitoring self-hosted infra). A note like:

> "Operational burden is recurring complexity: self-managed infrastructure incurs ongoing patching, scaling, and incident response costs that should factor into the complexity budget."

This naturally favors managed/serverless services in margo's reviews without making margo opinionated about a specific infrastructure topology. It is a calibration improvement, not a policy addition.

---

## 4. What NOT to Do

| Anti-pattern | Why |
|-------------|-----|
| Hardcode "serverless-first" in iac-minion's AGENT.md | Makes a generic published agent opinionated. Users with on-prem requirements would fight the default. |
| Add it to despicable-agents' own CLAUDE.md | This repo's CLAUDE.md governs the agent development project, not target projects. Wrong scope. |
| Make margo block self-hosted proposals | Margo enforces simplicity, not infrastructure topology. This would be scope creep on margo's role. |
| Create a new agent (e.g., "serverless-minion") | The task explicitly says "advisory-only consultation." Creating a new agent is a solution far beyond the stated scope. iac-minion should have this knowledge. |

---

## 5. Risks and Dependencies

| Risk | Mitigation |
|------|-----------|
| Users forget to add the directive to their project CLAUDE.md | Provide a documented template/example in despicable-agents docs or a "project setup" checklist. |
| iac-minion knowledge expansion takes the agent off its core competency | Keep serverless knowledge focused on IaC aspects (provisioning, deployment, packaging) not application architecture. |
| Margo operational complexity calibration is subjective | Frame it as a heuristic ("consider"), not a hard rule ("always penalize"). |
| Delegation table rows may not fully cover serverless task routing | Review after iac-minion knowledge expansion to see if additional rows are needed. |

---

## 6. Summary Verdict

**ADVISE**: The convention is most enforceable, least drift-prone, and most discoverable in the target project's CLAUDE.md, not in the agent system itself. The agent system needs capability fixes (iac-minion knowledge gap, delegation table gap) but should not encode the preference as a hardcoded default. This preserves the publishable/generic design principle while giving lucy a concrete, checkable directive to enforce during plan reviews.

The combination is:
1. **CLAUDE.md of target project** -- the preference (primary, enforceable, per-project)
2. **iac-minion spec expansion** -- the capability (prerequisite, without it the preference is unexecutable)
3. **Delegation table rows** -- the routing (so nefario knows serverless tasks exist)
4. **Margo operational complexity note** -- the calibration (optional, general improvement)
