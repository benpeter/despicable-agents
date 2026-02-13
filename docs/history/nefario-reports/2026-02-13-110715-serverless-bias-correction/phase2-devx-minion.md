# Phase 2 Contribution: devx-minion

## Domain Perspective: Developer Experience for Serverless-First Greenfield

### Executive Summary

The current agent system's default deployment path is hostile to the most common
developer journey: "I have code, I want it running on the internet." The iac-minion's
knowledge base assumes the developer has already decided to manage servers, and
then helps them do it well. But the prior question -- "should you manage servers
at all?" -- is never asked. From a DX perspective, this is the most damaging gap
in the system. The default path should be the simplest path. For most greenfield
projects, the simplest path is serverless.

---

### 1. What a Good "Serverless-First Greenfield" Experience Looks Like

**The gold standard is zero-to-deployed in under 5 minutes.** The developer experience
benchmark is:

```
# The entire deployment journey for a greenfield project
npm create next-app my-api
cd my-api
vercel deploy
# Live URL in 47 seconds
```

Compare with the current iac-minion default path:

```
# Step 1: Write the application (same)
# Step 2: Containerize it
#   - Write Dockerfile (multi-stage build, base image selection)
#   - Write .dockerignore
#   - Test build locally
# Step 3: Provision infrastructure
#   - Write Terraform HCL (provider, VPC, security groups, instance)
#   - Configure remote state backend (S3 + DynamoDB for locking)
#   - terraform init && terraform plan && terraform apply
# Step 4: Configure the server
#   - Write Caddyfile or nginx.conf for reverse proxy
#   - Configure SSL/TLS
#   - Set up systemd service or docker-compose
# Step 5: Deploy
#   - Push image to registry
#   - SSH or run deployment script
#   - Verify health checks
# Total: 30-120 minutes for someone experienced, days for a beginner
```

The ratio is roughly **50:1 in time-to-first-deploy.** This is not a minor
difference -- it is a category difference. The iac-minion's default path has the
developer writing infrastructure code before their application code is running
anywhere. That is backwards.

**A good serverless-first greenfield experience has these properties:**

1. **Zero infrastructure configuration for the first deploy.** No Terraform, no
   Docker, no reverse proxy. The platform handles compute, TLS, DNS, scaling.
2. **Git-push-to-deploy as the default CI/CD.** No GitHub Actions workflow files
   needed for basic deployment. Push to main, it deploys.
3. **Local development that matches production.** `dev` command starts a local
   server that behaves like the deployed version. No Docker required locally.
4. **Preview deployments for every PR.** Automatic, no configuration. Every pull
   request gets a unique URL.
5. **Environment variables as the only configuration surface.** No YAML, no TOML,
   no HCL. Just key-value pairs in a dashboard or CLI.
6. **Instant rollback.** Every deployment is immutable. Rolling back is selecting
   a previous deployment, not re-running a pipeline.

### 2. The Default Deployment Path: A Decision Tree

The agent system should guide developers through a decision tree, not start them
on the most complex path. Here is the tree I recommend, ordered by increasing
complexity:

**Level 0: Static site (no server logic)**
- Path: Cloudflare Pages, Vercel, Netlify, GitHub Pages
- Time to deploy: < 2 minutes
- Configuration: zero
- Trigger: project has only HTML/CSS/JS, or uses a static site generator

**Level 1: Static site + API routes / edge functions**
- Path: Vercel (API routes), Cloudflare Workers/Pages Functions, Netlify Functions
- Time to deploy: < 5 minutes
- Configuration: project structure convention (e.g., `/api` directory)
- Trigger: project needs server logic but individual functions, not a long-running server

**Level 2: Full application with serverless backend**
- Path: Vercel (Next.js/SvelteKit/etc.), Cloudflare Workers (full app), AWS Lambda + API Gateway
- Time to deploy: 5-15 minutes
- Configuration: framework config + environment variables
- Trigger: project is a full web application with SSR, API, database

**Level 3: Containerized application (serverless containers)**
- Path: AWS Fargate, Google Cloud Run, Fly.io, Railway
- Time to deploy: 15-30 minutes
- Configuration: Dockerfile + platform config
- Trigger: application needs long-running processes, WebSockets beyond platform limits,
  custom runtimes, binary dependencies not available in serverless runtimes

**Level 4: Self-managed infrastructure**
- Path: Docker + Terraform + reverse proxy (current iac-minion default)
- Time to deploy: 1-4 hours
- Configuration: Dockerfile + Terraform HCL + Caddyfile + CI/CD pipeline
- Trigger: specific compliance requirements (data residency, dedicated tenancy),
  cost optimization at scale (> $5k/month cloud bill), custom networking requirements,
  bare-metal performance needs

**The current system starts developers at Level 4.** It should start them at
Level 0-1 and escalate only when constraints demand it.

### 3. Common Serverless DX Pain Points and Agent Mitigations

#### 3.1 Cold Starts

**The pain:** First invocation after idle period takes 500ms-5s depending on
runtime and bundle size. Developers see this in development, panic, and
over-engineer warm-keeping solutions.

**How the agent system should help:**
- Quantify the impact: "Cold starts affect < 1% of requests for APIs with
  steady traffic. For 99th percentile latency-sensitive APIs, consider
  provisioned concurrency."
- Platform-specific guidance: Cloudflare Workers have near-zero cold starts
  (V8 isolates, not containers). AWS Lambda cold starts vary by runtime
  (Node.js ~200ms, Java ~2-5s). Vercel edge functions use V8 isolates.
- Decision heuristic: "If your p99 latency budget is > 500ms, cold starts
  are not a real problem. If your p99 budget is < 100ms, use edge functions
  (Cloudflare Workers, Vercel Edge) or provisioned concurrency."
- Anti-pattern detection: flag developers who add "keep-warm" cron jobs as
  over-engineering when their traffic is sufficient for natural warm-keeping.

#### 3.2 Local Development

**The pain:** "How do I test my serverless functions locally?" is the #1 question
for serverless beginners. The gap between local development and production is
the single biggest DX failure of first-generation serverless (raw Lambda without
frameworks).

**How the agent system should help:**
- Recommend frameworks with local dev parity:
  - Vercel: `vercel dev` runs locally with the same routing and function execution
  - Cloudflare: `wrangler dev` provides local Workers runtime with KV, D1, R2 bindings
  - Netlify: `netlify dev` proxies functions locally
  - SST (for AWS): `sst dev` provides live Lambda debugging with breakpoints
  - AWS SAM: `sam local start-api` for local API Gateway + Lambda emulation
- Anti-pattern: never recommend "deploy to test." Local development must work.
- Framework selection guidance: "Choose a framework that provides a local dev
  server that matches production behavior. If the framework does not have `dev`
  command parity, it is not ready for production use."

#### 3.3 Debugging in Production

**The pain:** No SSH, no `docker exec`, no attaching a debugger to a running
process. Serverless functions are ephemeral. When something goes wrong in
production, developers feel blind.

**How the agent system should help:**
- Structured logging as the primary debugging tool. Every serverless function
  should emit structured JSON logs with correlation IDs, request context, and
  timing information.
- Platform-native observability:
  - Vercel: built-in logs, serverless function traces, Edge Runtime logs
  - Cloudflare: Workers Logpush, Tail Workers for real-time log streaming
  - AWS: CloudWatch Logs with structured queries, X-Ray for tracing
- Error tracking integration: recommend Sentry, Axiom, or Baselime (now
  part of Cloudflare) for serverless-specific error tracking with source maps.
- The agent system should proactively recommend: "Add structured logging and
  error tracking BEFORE your first production deployment, not after your first
  production incident."

#### 3.4 Vendor Lock-in

**The pain:** "If I build on Vercel, am I stuck on Vercel?" This fear causes
developers to over-abstract their deployment layer, adding complexity to solve
a problem they do not yet have.

**How the agent system should help:**
- Quantify the actual lock-in surface. For most serverless platforms, the
  lock-in is in platform-specific APIs (Vercel KV, Cloudflare KV, AWS DynamoDB),
  not in the compute layer. A Next.js app can move from Vercel to self-hosted
  with moderate effort. An Express API can move from Lambda to any container.
- Recommend standard interfaces: use standard Node.js HTTP (Request/Response),
  standard SQL databases (PostgreSQL via Neon/Supabase), standard object storage
  (S3-compatible APIs). The function code itself is usually portable.
- Decision heuristic: "Vendor lock-in becomes a real concern when your monthly
  bill exceeds $5k or when you need capabilities the platform does not offer.
  Below that threshold, optimize for speed, not portability."
- Anti-pattern detection: flag developers who add Terraform + Docker + Kubernetes
  "just in case we need to move" as premature abstraction. YAGNI applies to
  infrastructure portability too.

#### 3.5 Cost Surprises at Scale

**The pain:** Serverless pricing is per-invocation. At low scale, it is free
or nearly free. At high scale, it can be dramatically more expensive than a
fixed-cost server.

**How the agent system should help:**
- Provide cost comparison heuristics:
  - Rule of thumb: serverless is cheaper below ~1M requests/month for typical
    API workloads. Above that, compare carefully.
  - Vercel: generous free tier, Pro at $20/month covers most small-medium projects
  - Cloudflare Workers: 100k requests/day free, $5/month for 10M requests
  - AWS Lambda: 1M free requests/month, then $0.20 per 1M
  - Break-even point vs. a $5/month Hetzner VPS: roughly 5-10M requests/month
    depending on function duration
- Proactive cost monitoring: "Set up cost alerts at 50%, 80%, and 100% of
  your expected monthly budget. Serverless costs are linear with traffic --
  viral posts or bot attacks can cause bill shock."
- Escalation trigger: "When your serverless bill consistently exceeds $500/month
  for a single service, evaluate whether a container (Fly.io, Cloud Run) or
  dedicated server would be more cost-effective. This is the Level 2 -> Level 3
  transition."

### 4. The Complexity Escalation Path

Yes, the system absolutely should have a complexity escalation path. The metaphor
is: **start on the elevator, take the stairs only when you outgrow the building.**

#### Escalation Triggers (When to Move Up a Level)

| Signal | Current Level | Escalation To | Rationale |
|--------|--------------|---------------|-----------|
| Need WebSocket connections beyond platform limits | Level 1-2 | Level 3 (containers) | Most serverless platforms limit WebSocket duration |
| Function execution > 30s consistently | Level 1-2 | Level 3 (containers) | Serverless timeout limits (Vercel 30s/300s, Lambda 15min) |
| Monthly bill > $500/service | Level 2 | Level 3 (containers) | Cost optimization threshold |
| Need custom binary dependencies or OS-level packages | Level 2 | Level 3 (containers) | Serverless runtimes have limited system access |
| Data residency / compliance requirements | Level 2-3 | Level 4 (self-managed) | Need to control physical infrastructure location |
| Monthly bill > $5k/service | Level 3 | Level 4 (self-managed) | Significant cost savings from dedicated infrastructure |
| Need bare-metal performance (GPU, specific CPU) | Any | Level 4 | Serverless cannot provide hardware-specific compute |
| Multi-region active-active with custom routing | Level 2-3 | Level 3-4 | Complex routing beyond platform capabilities |

#### De-escalation Triggers (When to Move Down)

This is equally important and almost never discussed. The agent system should
also recognize when infrastructure is over-provisioned:

| Signal | Current Level | De-escalation To | Rationale |
|--------|--------------|------------------|-----------|
| Server utilization consistently < 10% | Level 4 | Level 3 or 2 | Paying for idle capacity |
| Ops burden dominates development time | Level 4 | Level 3 | Infrastructure maintenance is not value-add |
| Scaling events cause incidents | Level 4 | Level 2-3 | Serverless auto-scales; your manual scaling does not |
| Team < 3 developers managing infrastructure | Level 4 | Level 2-3 | Small teams should not carry infra overhead |
| Docker/Terraform config larger than application code | Level 4 | Level 2-3 | Infrastructure complexity exceeds application complexity |

### 5. CLI/SDK Design for Serverless Deployment

A good serverless CLI experience follows these principles:

**5.1 Single-command deploy:**
```
myapp deploy           # Deploy current directory to production
myapp deploy --preview # Deploy a preview environment
myapp deploy --env staging
```

Not:
```
docker build -t myapp .
docker push registry/myapp:latest
terraform -chdir=infra plan
terraform -chdir=infra apply -auto-approve
ssh server 'docker pull registry/myapp:latest && docker-compose up -d'
```

**5.2 Progressive disclosure in the CLI:**
- `deploy` is the only command a beginner needs
- `config`, `env`, `logs`, `domains` are discovered when needed
- `rollback` is available but not required
- Infrastructure details (regions, scaling, runtime) are flags on `deploy`,
  not separate commands

**5.3 Error messages that guide escalation:**
```
Error: Function execution timed out after 30 seconds.

Your function exceeded the serverless execution limit. Options:
  1. Optimize the function to complete faster (most common fix)
  2. Increase timeout: vercel.json -> { "functions": { "maxDuration": 300 } }
  3. If this function inherently needs long execution, consider moving to a
     container runtime: https://docs.example.com/guides/migrate-to-containers

Run `myapp logs --function api/process` to see execution traces.
```

This error message does three things: explains the constraint, offers a
quick fix, and provides the escalation path. It does not just say "timeout."

**5.4 What the agent system should produce for serverless projects:**
- `vercel.json` or `wrangler.toml` instead of `Dockerfile + docker-compose.yml + Caddyfile + terraform/*.tf`
- GitHub Actions for CI (lint, test) but NOT for CD (the platform handles deploy)
- Environment variable configuration guidance instead of secrets management infrastructure
- A single deployment command in the README instead of a multi-step deployment guide

### 6. Recommendations for the Agent System

#### 6.1 iac-minion Must Add a "Deployment Strategy Selection" Step

Before recommending any specific infrastructure, iac-minion should ask:
"What is the simplest deployment path for this workload?" The answer should
be determined by the decision tree in Section 2, not by defaulting to the
most capable (and most complex) option.

Specifically, iac-minion's Working Patterns should start with:

> **When Designing Deployment Infrastructure:**
> 1. Start with the simplest deployment path (Level 0-2: platform-managed serverless)
> 2. Only escalate to containers (Level 3) or self-managed (Level 4) when a
>    specific constraint demands it
> 3. Document which constraint triggered the escalation
> 4. If no constraint is identified, the answer is serverless

#### 6.2 The Delegation Table Needs a "Deployment strategy" Row

The current delegation table routes "Infrastructure provisioning" to iac-minion.
But "infrastructure provisioning" implies there IS infrastructure to provision.
For serverless deployments, there is no infrastructure -- just platform configuration.

Proposed addition to the delegation table:

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Deployment strategy selection | iac-minion | devx-minion, edge-minion |
| Serverless deployment config | edge-minion | iac-minion |
| Container deployment | iac-minion | edge-minion |
| Self-managed infrastructure | iac-minion | security-minion |

This separates "deciding HOW to deploy" from "provisioning infrastructure,"
and routes serverless deployment config to edge-minion (who already knows
Cloudflare Workers, Vercel edge, etc.) with iac-minion as supporting.

#### 6.3 devx-minion Should Own "Time-to-First-Deploy" as a Metric

The devx-minion currently tracks "time to first deployment" as a metric but
does not have guidance on what that metric should look like for different
deployment paths. I recommend adding to the devx-minion knowledge base:

- **Deployment DX benchmarks**: Level 0-1 should be < 5 min, Level 2 < 15 min,
  Level 3 < 30 min, Level 4 < 4 hours
- **Deployment complexity scoring**: count of configuration files, count of
  CLI commands, count of external service accounts needed
- **Serverless local dev parity checklist**: does the local `dev` command
  match production routing, function execution, environment variable injection,
  and database access?

#### 6.4 margo's Complexity Budget Should Score Deployment Paths

Margo should have a deployment complexity score that counts actual operational
burden, not perceived novelty:

| Deployment Path | Config Files | External Services | Ongoing Ops | Score |
|----------------|-------------|------------------|-------------|-------|
| Vercel / CF Pages | 0-1 | 1 (platform) | None | 1 |
| Serverless + DB | 1-2 | 2 (platform + DB) | None | 3 |
| Container (Fly/CR) | 2-3 | 2-3 | Minimal | 5 |
| Docker + Terraform | 5-10 | 3-5 | Significant | 12 |
| Kubernetes | 10-20 | 5-10 | Major | 25 |

Under this scoring, recommending Docker + Terraform for a project that could
run on Vercel is a **complexity escalation of 12x** -- which is exactly the
kind of over-engineering margo is designed to catch.

### 7. Risks and Dependencies

**Risks:**
1. **Platform-specific knowledge fragmentation.** If serverless knowledge is
   distributed across iac-minion and edge-minion, neither may have sufficient
   depth. The agent consulted depends on how the user phrases their request --
   "deploy my app" goes to iac-minion (who knows Docker), not edge-minion
   (who knows Cloudflare Workers).
2. **Stale platform knowledge.** Serverless platforms evolve rapidly. Vercel's
   capabilities in 2026 are different from 2024. The agent knowledge base needs
   a refresh mechanism for platform-specific guidance.
3. **Over-correction risk.** The fix for "always recommends servers" should not
   be "always recommends serverless." The decision tree must genuinely evaluate
   constraints, not just flip the default. Some workloads genuinely need Level 3-4.
4. **Local development tooling variance.** The quality of local dev experience
   varies dramatically between platforms. `wrangler dev` is excellent.
   `sam local` is mediocre. This affects which platforms the system should
   recommend.

**Dependencies:**
1. iac-minion's remit update (Section 6.1) depends on margo accepting the
   complexity recalibration (Section 6.4), otherwise margo will flag serverless
   recommendations as "new technology" penalty.
2. Delegation table changes (Section 6.2) require coordination with the
   the-plan.md spec and all agents that reference "infrastructure provisioning."
3. edge-minion may need expanded scope if it becomes the primary agent for
   serverless deployment (currently scoped to CDN/edge, not general deployment).

### 8. Additional Agents Recommended

No additional agents needed for this advisory beyond those already in the
meta-plan. However, if the recommendations lead to execution:
- **edge-minion** should be consulted on its willingness/readiness to take on
  "serverless deployment config" as a primary responsibility.
- **test-minion** should be consulted on serverless testing patterns (local
  emulation, integration testing against deployed previews).

### 9. Key Insight

The fundamental DX principle at stake: **complexity should be opt-in, not
opt-out.** The current system requires developers to opt out of server management
(by knowing enough to ask for serverless). It should require developers to opt
in to server management (by hitting a constraint that demands it). This is the
same principle as "sensible defaults, progressive complexity" that already
governs the devx-minion's approach to SDK and CLI design. It just needs to be
extended to deployment strategy.
