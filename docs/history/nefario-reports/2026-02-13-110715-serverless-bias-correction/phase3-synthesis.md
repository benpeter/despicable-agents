# Phase 3: Synthesis -- Serverless Bias Advisory Report

## Executive Summary

Five specialists independently confirmed the same diagnosis: the despicable-agents system has a structural anti-serverless bias. It is not in one place -- it is distributed across three compounding gaps: (1) iac-minion has zero serverless knowledge and defaults to servers, (2) margo's complexity heuristics penalize novelty instead of operational burden, and (3) the delegation table has no routing for serverless tasks. The bias is real, measurable, and fixable without adding a new agent.

All five specialists converge on the same corrective architecture:
- **No 28th agent.** Expand iac-minion and adjust edge-minion's framing.
- **CLAUDE.md of target projects** is the right place for "serverless-first" preferences (not baked into published agents).
- **iac-minion, margo, and the delegation table** need capability and calibration fixes.
- **Vendor lock-in** is the highest-severity risk to monitor.

---

## 1. Root Cause Analysis: Where the Bias Lives

The bias is not a single misconfiguration. It is three independent gaps that compound.

### Gap 1: iac-minion Has No Serverless Knowledge (Primary Vector)

**Location**: `the-plan.md` lines 722-748 (iac-minion spec), `minions/iac-minion/AGENT.md` (deployed agent)

The iac-minion spec lists eight remit items: Terraform, Docker, Docker Compose, GitHub Actions, reverse proxies, cloud provider patterns, cost optimization, server deployment and operations. The word "serverless" appears zero times. The agent's "Infrastructure Design Approach" working pattern (AGENT.md lines 135-144) begins with "Select appropriate cloud provider(s) and services" and proceeds through VPC design, compute selection, and deployment procedures -- all assuming infrastructure exists. There is no Step 0 that asks "does this project need infrastructure at all?"

**Impact**: When nefario delegates a greenfield deployment task to iac-minion, the agent's knowledge produces a Docker + Terraform + Caddy stack regardless of whether the project needs it. The 10:1 operational complexity ratio (iac-minion's own assessment) means the default recommendation carries an order of magnitude more ops burden than the serverless alternative for qualifying projects.

### Gap 2: margo's Complexity Budget Penalizes Novelty, Not Operational Burden

**Location**: `margo/AGENT.md` lines 55-59 (Complexity Budget), lines 171-179 (Boring Technology)

The complexity budget scores: new technology (10 pts), new service (5 pts), new abstraction layer (3 pts), new dependency (1 pt). These costs measure what you *add*, not what you *operate*. A team already using Docker + Terraform + Caddy pays zero complexity points for maintaining those tools, but pays 10 points for adopting Vercel -- even though Vercel eliminates entire categories of operational work. The budget structurally favors incumbency over simplicity.

The "Boring Technology" section frames boring tech as "decades of production hardening" with implicit examples of self-hosted infrastructure. Serverless platforms (Lambda: 2014, Workers: 2018, Vercel: 2020) are conspicuously absent from the boring tech examples, despite meeting every stated criterion.

**Impact**: margo -- the agent whose job is to catch over-engineering -- currently cannot detect infrastructure over-engineering. A plan proposing Docker + Terraform + Caddy for a three-endpoint API passes margo's review unchallenged.

### Gap 3: Delegation Table Has No Serverless Routing

**Location**: `the-plan.md` delegation table (nefario's AGENT.md mirrors it)

The delegation table routes "Infrastructure provisioning" to iac-minion. There is no row for "deployment strategy selection," "serverless deployment," or any task type that distinguishes between server-based and serverless infrastructure. When a user asks nefario to deploy a greenfield project, nefario routes it as "infrastructure provisioning" because that is the only matching row -- which presupposes that infrastructure needs provisioning.

**Impact**: Nefario cannot route serverless work correctly. The routing itself encodes the assumption that deployment requires infrastructure.

### Compounding Effect

The three gaps reinforce each other:
1. Nefario routes deployment work to iac-minion (delegation table assumes infrastructure)
2. iac-minion proposes servers (only knowledge it has)
3. margo approves the plan (complexity budget does not penalize operational burden)
4. Result: server infrastructure for every project, regardless of whether it is needed

Breaking any one of these three links would improve outcomes. Fixing all three eliminates the bias.

---

## 2. Recommended Changes (Prioritized)

### Priority 1: Expand iac-minion's Remit and Knowledge

**Unanimity**: All five specialists agree this is the prerequisite fix. Without serverless knowledge in iac-minion, no convention or heuristic change can produce serverless recommendations.

**What to change in `the-plan.md` (iac-minion spec, lines 722-748)**:

Add to the Remit list:
```
- Deployment strategy selection (serverless vs. container vs. self-managed)
- Serverless deployment patterns (Vercel, Cloudflare Pages, AWS Lambda, Netlify)
- Serverless cost modeling and escalation triggers
```

Add to Research focus:
```
Serverless deployment patterns (Vercel, Cloudflare Pages/Workers, AWS Lambda + API Gateway),
serverless vs. container decision frameworks, serverless cost modeling and crossover analysis.
```

**What to change in iac-minion's AGENT.md knowledge structure** (requires spec version bump + rebuild):

1. Add a new first section: **Deployment Strategy Selection** -- a triage decision tree that evaluates whether a project needs infrastructure before any Terraform or Docker work begins. The tree from iac-minion's contribution (does the project need long-running processes, persistent connections, custom OS dependencies, compliance-mandated control, or high-traffic cost optimization? NO to all = serverless) is the right starting point.

2. Add a new section: **Serverless Deployment Patterns** -- covering Vercel (deep: config, env vars, edge functions, preview deploys), Cloudflare Pages (moderate: basic wrangler config, deployment), AWS Lambda (moderate: SAM/CDK basics, API Gateway integration), Netlify (light: when to recommend it).

3. Rename existing server-centric sections to make the decision-first structure explicit:
   - "Terraform Infrastructure Provisioning" becomes part of "Server Infrastructure Patterns"
   - "Docker and Container Optimization" stays but is positioned as Level 3-4 (containers when serverless is insufficient)

4. Update the "Infrastructure Design Approach" working pattern to begin with deployment strategy triage before any infrastructure design.

**Boundary with edge-minion**: iac-minion owns "should we use serverless and which platform?" (deployment decision). edge-minion owns "how to write efficient Worker/edge code" (implementation). For Cloudflare Workers/Pages: iac-minion recommends the platform; edge-minion implements the Workers code. This boundary is already implicit in edge-minion's "Does NOT do: Origin server infrastructure (-> iac-minion)" -- extend it symmetrically.

**Spec version**: Bump iac-minion from 1.0 to 1.1.

### Priority 2: Recalibrate margo's Complexity Heuristics

**Unanimity**: All five specialists identify margo's complexity budget as a compounding factor. margo and lucy agree the change should be a calibration improvement, not an opinionated stance.

**What to change in `the-plan.md` (margo spec)** and **`margo/AGENT.md`**:

1. **Split the "New service" cost** in the Complexity Budget (AGENT.md lines 55-59):

   Current:
   ```
   - New service: 5 points (deployment, networking, monitoring)
   ```

   Proposed:
   ```
   - New self-managed service: 8 points (deployment, networking, monitoring, patching, scaling)
   - New managed/serverless service: 3 points (vendor API surface, platform limits)
   ```

   Rationale: Self-managed services carry ongoing operational burden (patching, scaling, incident response) that the original flat score underweighted. Managed/serverless services eliminate most operational burden and should score lower. The budget should measure operational burden, not just technology count.

2. **Add serverless platforms to the Boring Technology examples** (AGENT.md lines 171-179):

   After the existing paragraph, add:
   ```
   Serverless platforms are boring technology. AWS Lambda (2014), Cloudflare
   Workers (2018), and Vercel (2020) have years of production hardening,
   well-understood failure modes (cold starts, execution limits, vendor coupling),
   and large talent pools. Deploying to serverless is not an innovation token
   spend for most web services and APIs.
   ```

3. **Add an "Infrastructure Over-Engineering" detection pattern** (new subsection after Premature Optimization):

   Trigger signals: no scaling/long-running/persistent-state requirement, config files rivaling application code in complexity, small team (1-5), greenfield with no existing infra investment.

   Counter-signals: persistent connections, GPU/custom OS needs, cost analysis at actual scale favoring servers, regulatory requirements, existing server infra where serverless would increase total complexity.

4. **Add to YAGNI detection patterns** (AGENT.md lines 70-76):
   ```
   - Server infrastructure (Docker, Terraform, reverse proxy) for stateless APIs
     that fit within serverless execution limits
   ```

**Spec version**: Bump margo from 1.0 to 1.1.

### Priority 3: Update the Delegation Table

**What to change in `the-plan.md`** (delegation table) and **nefario's AGENT.md** (mirrored table):

Add these rows to the Infrastructure & Data section:

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Deployment strategy selection | iac-minion | devx-minion |
| Serverless platform deployment (Vercel, Cloudflare Pages, Netlify) | iac-minion | edge-minion |
| Serverless compute provisioning (Lambda, Cloud Functions) | iac-minion | edge-minion |
| Serverless-to-server migration | iac-minion | devx-minion |

These rows ensure nefario can distinguish "decide how to deploy" (strategy selection) from "provision infrastructure" (server-specific), and routes serverless work to agents who have the knowledge to handle it.

### Priority 4: Provide a CLAUDE.md Template for Projects

**What lucy recommends (and all specialists agree)**: The "serverless-first for greenfield" preference belongs in each target project's CLAUDE.md, not in the published agent system. This is the same pattern already used for "prefer lightweight, vanilla solutions."

**Deliverable**: A documented example in the despicable-agents docs (e.g., `docs/guides/greenfield-defaults.md` or a section in `docs/orchestration.md`) showing how to add infrastructure preferences to a project's CLAUDE.md:

```markdown
## Infrastructure Defaults

- For greenfield projects, prefer serverless/managed services (Vercel, Cloudflare Pages,
  Lambda, managed databases) over self-hosted infrastructure unless the workload has
  specific requirements that serverless cannot meet (persistent connections, long-running
  processes, compliance-mandated infrastructure control, cost optimization at scale).
- Justify self-hosted infrastructure against the serverless alternative in the plan.
```

This gives users a copy-paste directive that:
- lucy can enforce (CLAUDE.md compliance check)
- Every agent receives (CLAUDE.md is loaded into all sessions)
- Is per-project customizable (different projects, different defaults)
- Does not make published agents opinionated

---

## 3. Agent Roster Recommendation: No New Agent

**Unanimous**: All five specialists recommend against a dedicated serverless-minion (28th agent).

**Rationale** (gru's assessment is definitive here):
- 27 agents is already at the upper bound of manageable complexity
- Serverless is a deployment model that crosses infrastructure (iac-minion), edge compute (edge-minion), frontend deployment (frontend-minion), and API design (api-design-minion). A dedicated agent would have boundary conflicts with four existing agents.
- The gap is in iac-minion's knowledge, not in the roster. Filling the knowledge gap is cheaper and less disruptive than adding a new agent.

**Distribution of serverless knowledge after the fix**:

| Agent | Serverless Responsibility | Depth |
|-------|--------------------------|-------|
| iac-minion | Deployment strategy selection, platform recommendation, basic deployment config (vercel.json, basic wrangler.toml, SAM templates), cost modeling, escalation triggers | Deep: decision framework and deployment patterns |
| edge-minion | Cloudflare Workers/Pages as a full-stack serverless platform (not just CDN compute), Fastly Compute, edge function development | Deep: implementation and edge-native patterns |
| margo | Flagging infrastructure over-engineering, complexity budget scoring that recognizes managed vs. self-managed | Heuristic: detection patterns, not platform knowledge |
| devx-minion | Time-to-first-deploy benchmarks, deployment complexity scoring, local dev parity assessment | Metric: DX quality measurement |
| frontend-minion | Framework-specific deployment (Next.js on Vercel, SvelteKit on Cloudflare, Astro anywhere) | Existing: framework deployment already in scope |

**Condition for re-evaluation** (gru): Only if serverless becomes a dominant paradigm requiring specialized knowledge that neither iac-minion nor edge-minion can absorb (e.g., serverless-specific observability, serverless security hardening as a discipline). Not expected within 12 months.

---

## 4. Greenfield Defaults Recommendation

### The Escalation Ladder

devx-minion's 5-level deployment escalation path is the recommended default mental model. The current system starts at Level 4 (self-managed). It should start at Level 0.

| Level | Path | Time to Deploy | When |
|-------|------|---------------|------|
| 0 | Static hosting (Cloudflare Pages, GitHub Pages) | < 2 min | HTML/CSS/JS only, static generators |
| 1 | Static + API routes (Vercel, CF Workers/Pages Functions) | < 5 min | Server logic needed but individual functions |
| 2 | Full serverless app (Vercel + DB, Workers + D1, Lambda + API GW) | 5-15 min | Full web app with SSR, API, database |
| 3 | Serverless containers (Fargate, Cloud Run, Fly.io) | 15-30 min | Long-running processes, WebSockets, custom runtimes |
| 4 | Self-managed (Docker + Terraform + proxy) | 1-4 hours | Compliance, cost optimization at scale, bare-metal needs |

**The principle**: Complexity is opt-in, not opt-out. Start at the simplest level. Escalate only when a specific constraint demands it. Document which constraint triggered the escalation.

### Escalation Triggers

| Signal | From | To | Rationale |
|--------|------|-----|-----------|
| Need persistent WebSocket connections | Level 1-2 | Level 3 | Serverless platforms limit connection duration |
| Function execution consistently > 30s | Level 1-2 | Level 3 | Serverless timeout limits |
| Monthly bill > $500/service | Level 2 | Level 3 | Cost optimization threshold |
| Custom binary deps or OS packages | Level 2 | Level 3 | Serverless runtimes have limited system access |
| Data residency / compliance mandates | Level 2-3 | Level 4 | Need infrastructure control |
| Monthly bill > $5k/service | Level 3 | Level 4 | Significant savings from dedicated infra |
| GPU, specific CPU, bare-metal perf | Any | Level 4 | Serverless cannot provide hardware-specific compute |

### Technology Maturity (gru's Assessment)

| Platform | Ring | Lock-in Risk | Best For |
|----------|------|-------------|----------|
| AWS Lambda | ADOPT | High (AWS ecosystem) | Event-driven, API backends, microservices |
| Cloudflare Workers | ADOPT | Medium (compute portable, data less so) | Edge-native, full-stack with D1/R2/KV |
| Vercel | TRIAL | High (Next.js coupling) | Frontend-first, Next.js projects |
| Netlify | TRIAL* | Medium (Lambda underneath) | Static sites with light serverless |
| Deno Deploy | ASSESS | Low (open standards) | Small projects, portability-first |

*Netlify: re-evaluate in 6 months. If community velocity continues declining, downgrade to Hold.

---

## 5. Conflict Resolution

### Conflict: Who Owns Serverless Deployment Config?

devx-minion proposes routing "serverless deployment config" to edge-minion as primary. iac-minion and gru propose iac-minion as primary for all deployment decisions.

**Resolution**: iac-minion is primary for deployment strategy selection and platform-level config (vercel.json, basic wrangler.toml, serverless.yml). edge-minion is primary for edge-specific implementation (Workers code, Durable Objects, edge-side logic). This preserves the existing boundary: iac-minion owns "how to deploy," edge-minion owns "how to compute at the edge."

The delegation table additions reflect this: "Serverless platform deployment" routes to iac-minion (primary) with edge-minion (supporting), not the reverse.

### Conflict: How Opinionated Should margo Become?

margo proposes specific trigger signals and counter-signals for infrastructure over-engineering. lucy cautions that making margo opinionated about infrastructure topology is scope creep.

**Resolution**: lucy is correct that the preference belongs in CLAUDE.md, not in margo. But margo's contribution is not about preference -- it is about detection. margo should detect when infrastructure complexity is disproportionate to the problem (a simplicity question, squarely in margo's remit), without prescribing a specific alternative. The "Infrastructure Over-Engineering" detection pattern asks "does this workload have a specific requirement that serverless cannot meet?" -- this is a simplicity test, not an infrastructure topology preference. Include it.

### Conflict: Complexity Budget Scoring

margo proposes self-managed service at 8 points (up from 5). devx-minion proposes a deployment complexity score with Kubernetes at 25 points. The two scales are incompatible.

**Resolution**: Use margo's two-tier budget split (self-managed: 8, managed/serverless: 3) as the change to the Complexity Budget. devx-minion's deployment complexity scoring is a useful DX metric but is a different measurement -- it can live in devx-minion's knowledge as a DX benchmark, not in margo's complexity budget.

---

## 6. Risks and Mitigations

### Risk 1: Over-Correction (MEDIUM)

Swinging from "always recommend servers" to "always recommend serverless" would be equally wrong.

**Mitigation**: The triage decision tree includes explicit counter-signals (persistent connections, long-running processes, compliance, cost at scale). margo's Infrastructure Over-Engineering detection pattern includes equally prominent "server infrastructure IS justified when" signals. The escalation ladder is bidirectional -- devx-minion's de-escalation triggers catch over-provisioned infrastructure, and counter-signals catch under-provisioned infrastructure.

### Risk 2: Vendor Lock-in Accumulation (HIGH -- gru's highest severity)

Serverless platforms have real lock-in costs. Lambda uses proprietary event models and IAM. Vercel couples to Next.js. Cloudflare's data layer (D1, KV, R2) is proprietary.

**Mitigation**: iac-minion's serverless knowledge should include portability assessment as standard output. Keep business logic in portable libraries; use serverless as a thin invocation layer. Recommend standard interfaces (Web Standard APIs, standard SQL, S3-compatible storage). The escalation ladder's Level 3 (serverless containers) provides an exit path when platform constraints are hit. gru's recommendation: "Vendor lock-in becomes a real concern when monthly bill exceeds $5k or when you need capabilities the platform does not offer. Below that threshold, optimize for speed, not portability."

### Risk 3: Knowledge Breadth vs. Depth for iac-minion (MEDIUM)

Adding serverless to iac-minion's remit risks spreading its knowledge too thin.

**Mitigation**: Keep serverless knowledge at the "deployment and operations" level, not the "application architecture" level. Deep Workers development stays with edge-minion. Database selection stays with data-minion. Framework optimization stays with frontend-minion. iac-minion owns the deployment decision and platform config, not the application code running on the platform.

### Risk 4: Publishability Constraint (LOW)

Changes to AGENT.md files must keep agents generic and vendor-neutral (Apache 2.0).

**Mitigation**: lucy's layered approach preserves this. Agents gain *capability* (iac-minion can reason about serverless), not *opinion* (agents do not default to serverless). The "serverless-first" preference lives in each target project's CLAUDE.md, not in the published agents. margo's changes are framed as simplicity detection (generic) not infrastructure preference (opinionated).

### Risk 5: Stale Platform Knowledge (MEDIUM)

Serverless platforms evolve rapidly. Vercel ships features monthly. Pricing changes regularly.

**Mitigation**: Focus agent knowledge on stable patterns (deployment commands, config file formats, limit awareness, cost models) rather than platform-specific features. gru's technology radar provides a re-evaluation cadence: Netlify in 6 months, Deno Deploy in 12 months, Lambda cost model ongoing.

---

## 7. Implementation Roadmap

If the user decides to act on this advisory, the recommended execution sequence is:

### Phase A: Spec Changes (the-plan.md)

Prerequisite for all other phases. Requires human approval since the-plan.md is human-edited.

1. Bump iac-minion spec from 1.0 to 1.1: add serverless remit items, update research focus
2. Bump margo spec from 1.0 to 1.1: add complexity budget split, boring tech update, infrastructure over-engineering detection
3. Add delegation table rows for serverless routing
4. Review edge-minion spec: add acknowledgment that Cloudflare Workers/Pages is also a full-stack serverless platform, not only CDN compute

### Phase B: Agent Rebuilds

After spec changes are approved. Use `/despicable-lab` to regenerate.

1. Rebuild iac-minion AGENT.md from updated spec (decision-first knowledge structure, triage working pattern, serverless deployment patterns)
2. Rebuild margo AGENT.md from updated spec (two-tier budget, boring tech examples, infrastructure over-engineering detection)
3. Update iac-minion RESEARCH.md with serverless deployment research
4. Update margo RESEARCH.md with infrastructure over-engineering case study

### Phase C: Nefario Updates

After agent rebuilds.

1. Mirror new delegation table rows into nefario's AGENT.md
2. No other nefario changes needed -- nefario follows the delegation table, not infrastructure opinions

### Phase D: Documentation

After all agent changes.

1. Add greenfield defaults guidance to docs (CLAUDE.md template for projects)
2. Update `docs/orchestration.md` if delegation table changes affect routing examples

### Phase E: Verification

1. Dry-run test: present nefario with "deploy a simple API with a database" for a greenfield project that has the serverless-first CLAUDE.md directive. Verify iac-minion proposes serverless. Verify margo does not flag it as complexity. Verify the delegation routes correctly.
2. Counter-test: present the same task for a project that needs persistent WebSocket connections. Verify iac-minion proposes Level 3 or 4. Verify the escalation is documented.

---

## 8. What NOT to Do

| Anti-pattern | Why | Who flagged it |
|-------------|-----|----------------|
| Create a 28th agent (serverless-minion) | Boundary conflicts with 4 existing agents. The gap is knowledge, not roster. | gru, lucy, devx-minion |
| Hardcode "serverless-first" in iac-minion AGENT.md | Makes a generic published agent opinionated. Users with on-prem requirements would fight the default. | lucy |
| Add the preference to despicable-agents' own CLAUDE.md | Wrong scope. That CLAUDE.md governs agent development, not target projects. | lucy |
| Make margo block self-hosted proposals | Margo enforces simplicity, not infrastructure topology. Blocking is scope creep. | lucy, margo |
| Swing to "always recommend serverless" | Equally wrong as the current bias. The triage tree must genuinely evaluate constraints. | iac-minion, margo, devx-minion |
| Ignore vendor lock-in | Real cost. Include portability assessment as standard iac-minion output. | gru (highest severity) |

---

## 9. Summary of Specialist Convergence

| Question | Consensus | Dissent |
|----------|-----------|---------|
| Is the bias real? | Yes, unanimous, structural, measurable | None |
| Where does it live? | Three gaps: iac-minion knowledge, margo heuristics, delegation table | None (all five identified the same gaps) |
| New agent needed? | No. Expand iac-minion, adjust edge-minion framing. | None |
| Where should the preference live? | Target project CLAUDE.md (primary), with agent capability fixes as prerequisites | None |
| What should greenfield defaults look like? | Start at Level 0-1 (serverless), escalate only on specific constraints | None |
| Highest risk? | Vendor lock-in (gru), over-correction (margo, iac-minion, devx-minion) | Severity ranking varies |

The five specialists reached remarkably similar conclusions independently. There are no unresolved disagreements. The three minor conflicts (routing ownership, margo scope, budget scoring) are resolved above with rationale.
