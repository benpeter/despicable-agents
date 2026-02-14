# Domain Plan Contribution: edge-minion

## Recommendations

### (a) Boundary with iac-minion

The boundary should follow the **strategy vs. implementation** split, with an important nuance: the platform boundary is not clean because Cloudflare (and similar platforms) blur infrastructure and runtime into one.

**iac-minion owns:**
- Deployment strategy selection: "should this project use serverless, containers, or a hybrid?" This is a cost/ops/requirements trade-off decision, not an edge-specific one.
- Platform selection at the infrastructure level: "Cloudflare vs. AWS Lambda vs. Google Cloud Run vs. container on Hetzner?"
- Serverless cost modeling and budgeting (Lambda invocation costs, Workers pricing tiers, bandwidth projections).
- CI/CD pipeline definition for deploying to serverless platforms (GitHub Actions workflow that runs `wrangler deploy` or `serverless deploy`).
- DNS and domain configuration at the registrar/provider level.
- Infrastructure-as-code for serverless resources (Terraform for AWS Lambda + API Gateway, Pulumi for Cloudflare Workers).

**edge-minion owns:**
- Platform-specific runtime patterns: Workers runtime constraints (CPU time limits, memory limits, no Node.js APIs), Pages Functions routing, KV/R2/D1/Durable Objects storage selection and access patterns.
- Edge-specific configuration: caching headers, cache rules, WAF/rate limiting, custom domains within CDN dashboard, routing rules.
- Worker code architecture: request handling patterns, middleware chains, error handling at the edge, cold start optimization.
- Performance tuning within the platform: cache hit ratios, TTFB optimization, compression settings, image optimization.

**The Cloudflare Pages + Workers full-app scenario:** iac-minion decides "we're deploying on Cloudflare Pages with Workers functions" and sets up the CI/CD pipeline (GitHub Actions -> `wrangler pages deploy`). edge-minion then owns the `wrangler.toml` configuration, the Workers function code patterns, the caching strategy, KV/D1 bindings configuration, and runtime performance. If Terraform is used to manage the Cloudflare resources (DNS, Workers routes, KV namespaces), iac-minion writes the Terraform; edge-minion reviews the caching and routing portions.

**Key principle:** iac-minion answers "where does it run and how does it get there." edge-minion answers "how does it run well once it's there." There will be overlap in configuration files (wrangler.toml serves both purposes), so the collaboration note in the delegation table matters.

### (b) Full-stack serverless framing

The current edge-minion spec and AGENT.md already cover Cloudflare Workers/Pages as a compute platform with real depth (Workers KV, R2, D1, Durable Objects, edge rendering, edge databases). The research document also covers these storage backends thoroughly. However, the framing is entirely through the lens of "edge compute" -- an implicit positioning as CDN-adjunct rather than full-stack deployment target.

**What needs to change in edge-minion's spec:** One explicit sentence acknowledging that platforms like Cloudflare Workers/Pages serve as full-stack serverless deployment targets, not only CDN compute layers. Something like:

> Cloudflare Workers/Pages, Vercel, and Netlify function as full-stack serverless platforms. Edge-minion covers edge-layer behavior (caching, routing, edge functions, storage bindings) on these platforms; deployment strategy and CI/CD are iac-minion's domain.

**Regarding Vercel/Netlify:** Edge-minion should NOT expand its remit to cover Vercel or Netlify deployment configuration -- those are deployment platforms first, edge compute platforms second. edge-minion's value is in the edge-layer behavior: cache headers, edge middleware, edge functions, image optimization APIs. The deployment and build configuration (vercel.json project settings, netlify.toml build commands) should be iac-minion territory.

**Recommended spec addition to edge-minion's "Does NOT do":**
> Full-stack serverless deployment configuration (Vercel project settings, Netlify build config, `wrangler.toml` deployment targets) -> iac-minion. Edge-minion covers edge runtime behavior on these platforms.

This is a subtle but important line. Without it, edge-minion gets pulled into deployment strategy conversations it shouldn't own.

### (c) iac-minion's decision framework for serverless vs. containers

From operational experience with edge/serverless platforms, here are the real decision criteria iac-minion should encode:

**Serverless is the right default when:**
- Request-driven workloads (HTTP APIs, webhooks, scheduled tasks) -- not long-running processes.
- Execution duration under 30 seconds (Lambda) or under 30ms CPU time (Workers). Workers is stricter.
- Traffic is spiky or unpredictable -- serverless scales to zero and scales up instantly. Paying for idle containers is waste.
- Team is small and operational bandwidth is limited -- serverless eliminates OS patching, scaling config, container orchestration.
- The project is a prototype, internal tool, or low-traffic app. Over-provisioning with containers is the serverless bias in reverse.
- Static site + API functions (the Pages/Netlify/Vercel sweet spot).

**Container-based infrastructure is the right choice when:**
- Long-running processes: WebSocket servers with persistent connections, background job processors, stream processors.
- Execution duration regularly exceeds platform limits (Lambda 15min, Workers 30s on paid plan for cron triggers).
- Cold start latency is unacceptable for the use case (sub-10ms p99 requirements). Provisioned concurrency mitigates this on Lambda but adds cost -- at that point, containers may be cheaper.
- The workload needs specific system dependencies (native binaries, GPU, large memory footprint, specific OS libraries).
- High and steady request volume where per-invocation pricing exceeds container pricing. The crossover point is roughly 1-3 million requests/day sustained, but varies by execution time and memory.
- Stateful workloads requiring local disk, persistent connections, or in-memory caches (Redis-like patterns).
- Regulatory requirements mandate specific infrastructure control (data residency, audit trails on the compute layer).

**Real escalation triggers (serverless -> containers):**
1. **Per-invocation cost exceeds container cost** at sustained volume. Run the math: (monthly invocations * avg duration * price per GB-second) vs. (container instances * hourly price * hours).
2. **Cold start latency** causes SLO violations. Measure p95/p99 latency, not averages. If provisioned concurrency cost approaches always-on container cost, switch.
3. **Execution time limits** force architectural contortions. If you're chaining Lambda invocations with Step Functions to work around the 15-minute limit, a container is simpler.
4. **Package size limits** block required dependencies. Lambda has a 250MB limit (unzipped); Workers has a 10MB limit. If your app needs large native dependencies, containers win.
5. **Vendor lock-in** becomes a concrete risk, not a theoretical one. If the team needs to migrate and the serverless code is deeply coupled to platform APIs (D1, Durable Objects, Lambda Layers), the migration cost is real.

**What iac-minion should NOT do:** Default to containers because "it's more flexible" or because the team "might need it later." That's the current bias. The decision framework should start with serverless and require a specific trigger to justify containers.

### (d) Delegation table routing

The proposed task-type names need refinement.

**"Deployment strategy selection"** -- Good name. This is the high-level "serverless vs. containers vs. hybrid" decision. iac-minion primary is correct. Supporting agents should be contextual:
- edge-minion supporting when the candidate platforms include edge/serverless (Cloudflare, Vercel, Netlify).
- devx-minion supporting when developer experience is a factor (local dev story, debugging, deployment friction).

I would name it **"Deployment strategy selection"** and list supporting as `edge-minion, devx-minion` (both conditional, but listing both is fine since nefario can route intelligently).

**"Serverless platform deployment"** -- This name is problematic. It sounds like execution ("deploy this to serverless"), not planning. And the scope is ambiguous: does it mean deploying code to a serverless platform, or deploying the serverless platform infrastructure itself?

Better names:
- **"Serverless platform configuration"** -- for setting up the serverless platform (wrangler.toml, serverless.yml, SAM templates, Lambda function definitions). iac-minion primary, edge-minion supporting.
- **"Serverless function development"** -- for writing the actual function code. This should route to the relevant domain minion (edge-minion for edge workers, api-design-minion for API handlers, frontend-minion for SSR functions).

Actually, "Serverless function development" might not need its own row -- existing rows like "Edge worker development" already cover the edge case, and API development routes through api-design-minion. What's genuinely missing is the infrastructure setup row.

**My recommended delegation table additions:**

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Deployment strategy selection | iac-minion | edge-minion, devx-minion |
| Serverless platform configuration | iac-minion | edge-minion |

The existing "Edge worker development" row (edge-minion primary, frontend-minion supporting) already covers Workers/edge function code. No change needed there.

One more consideration: the existing "Infrastructure provisioning" row has iac-minion primary with security-minion supporting. Serverless provisioning is a subset of this, so the new "Serverless platform configuration" row might overlap. If the team prefers fewer rows, "Infrastructure provisioning" could simply gain edge-minion as an additional supporting agent with a parenthetical "(for serverless/edge platforms)." But explicit rows are clearer for nefario's routing.

## Proposed Tasks

1. **Add one sentence to edge-minion's spec** acknowledging full-stack serverless platforms (Cloudflare Workers/Pages, Vercel, Netlify) and clarifying that edge-minion covers edge-layer runtime behavior, not deployment configuration. (~5 words added to Remit, ~15 words added to "Does NOT do".)

2. **Review iac-minion's expanded serverless section** (once drafted) to validate the decision framework criteria and escalation triggers against operational reality. Edge-minion should review, not author, this section.

3. **Add two rows to delegation table**: "Deployment strategy selection" and "Serverless platform configuration" with the primary/supporting split described above.

4. **No changes needed to edge-minion's RESEARCH.md** -- the Cloudflare Workers/Pages coverage is already thorough for edge-layer concerns. The gap is in iac-minion's research, not edge-minion's.

## Risks and Concerns

1. **Boundary ambiguity on wrangler.toml / serverless.yml**: These files serve both infrastructure (deployment targets, bindings, routes) and runtime (compatibility flags, limits, environment variables) purposes. Splitting ownership of a single file between two agents will cause confusion. Recommendation: iac-minion owns the file structurally, edge-minion reviews/advises on edge-specific settings. Document this in both specs' collaboration notes.

2. **Margo's complexity budget and serverless**: The planning question mentions margo penalizes novelty but not operational burden. From edge-minion's perspective, the operational burden of maintaining Docker + Terraform + reverse proxy + SSL for a simple API that could be a single Workers script is enormous compared to `wrangler deploy`. Margo's complexity metric should account for ongoing operational complexity (patching, scaling, monitoring, certificate renewal), not just initial setup novelty. A Docker+Terraform stack for a low-traffic API is more complex in total cost of ownership than a serverless function, even if Docker feels "simpler" because it's familiar.

3. **Over-correction risk**: The fix should not create a serverless bias to replace the container bias. The goal is a neutral decision framework. iac-minion should be equally comfortable recommending either approach based on the criteria, not defaulting to serverless the way it currently defaults to containers.

4. **Platform-specific knowledge depth in iac-minion**: iac-minion needs enough serverless knowledge to set up CI/CD and infrastructure, but should not try to become an expert in Workers runtime constraints, Lambda cold start optimization, or edge storage patterns. That depth stays with edge-minion (for edge platforms) and with future agents or the relevant domain minions (for Lambda/Cloud Functions). The risk is iac-minion's serverless section becoming a shallow duplicate of edge-minion's knowledge.

## Additional Agents Needed

**No additional agents needed beyond those already in the planning group.** The four-agent scope (iac-minion spec, margo spec, delegation table, CLAUDE.md template) is correct.

One note: **devx-minion** input would be valuable for the CLAUDE.md template specifically, since that template defines how projects signal their deployment preferences to the agent team. devx-minion understands developer-facing configuration patterns. If devx-minion is already consulted on the template, this is covered. If not, their input on template ergonomics would help.
