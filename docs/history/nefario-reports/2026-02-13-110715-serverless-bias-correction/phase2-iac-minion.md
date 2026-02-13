# Phase 2: iac-minion Planning Contribution

## Self-Assessment: The Structural Bias Is Real and Deep

I have critically reviewed my own AGENT.md (277 lines) and the-plan.md spec
(lines 722-748). The diagnosis is accurate: my entire knowledge base is
organized around server-centric infrastructure. The word "serverless" appears
zero times in my deployed AGENT.md. Here is the honest inventory:

### What My Current Knowledge Produces for a Greenfield API

For a project that needs "a simple API with a database":

**My current default stack (what I would recommend today):**

| Component | Files/Config Required | Ongoing Ops Burden |
|-----------|----------------------|-------------------|
| Terraform provider + backend | `versions.tf`, `backend.tf`, S3 bucket for state, DynamoDB for locking | State management, plan/apply workflow, state file drift |
| Terraform compute module | `main.tf`, `variables.tf`, `outputs.tf` | Resource lifecycle, provider upgrades |
| Terraform networking | VPC, subnets, security groups, routing | Network troubleshooting, rule auditing |
| Docker | `Dockerfile` (multi-stage), `.dockerignore` | Image builds, registry management, layer cache, base image updates |
| Docker Compose (dev) | `docker-compose.yml` | Local dev parity, volume mounts |
| Reverse proxy | `Caddyfile` or `nginx.conf` | TLS cert renewal, proxy config, header management |
| GitHub Actions | `.github/workflows/deploy.yml` (build, push, SSH deploy) | Workflow maintenance, secret rotation |
| Server ops | SSH access, systemd units, log rotation, firewall rules | Patching, monitoring, disk space, uptime |

**Conservative count: 8-12 configuration files, 4+ tools to learn, ongoing
server maintenance.**

**Serverless equivalent (Vercel + managed database):**

| Component | Files/Config Required | Ongoing Ops Burden |
|-----------|----------------------|-------------------|
| Vercel project | `vercel.json` (optional -- zero-config for most frameworks) | None. Platform handles scaling, TLS, CDN. |
| GitHub integration | Connect repo in Vercel dashboard (one-time) | Automatic deploys on push. No workflow file needed. |
| Database | Vercel Postgres / Neon / PlanetScale connection string in env | Connection string rotation (annually). |

**Conservative count: 0-1 configuration files, 1 tool, zero server
maintenance.**

The operational complexity ratio is roughly **10:1 in favor of serverless** for
this class of project. This is not a marginal difference -- it is an order of
magnitude.

### Where My Knowledge Has Structural Gaps

My current AGENT.md has six knowledge sections, all server-centric:

1. **Terraform Infrastructure Provisioning** -- assumes you need to provision
   infrastructure at all
2. **Docker and Container Optimization** -- assumes you need containers
3. **GitHub Actions CI/CD Pipelines** -- useful for both paradigms, but my
   patterns assume "build image, push to registry, deploy to server"
4. **Reverse Proxy Configuration** -- assumes you run your own ingress
5. **Cloud Provider Patterns** -- only covers Hetzner (IaaS) and generic VPC
   patterns
6. **SSL/TLS Certificate Management** -- assumes you manage your own certs

None of these sections include a decision point that says "wait -- do you
actually need any of this?" There is no triage step that evaluates whether
the project's requirements exceed what a serverless platform provides for free.

### My Infrastructure Design Approach Is the Root Cause

My "Infrastructure Design Approach" working pattern (AGENT.md lines 135-144)
starts with:

> 1. Select appropriate cloud provider(s) and services
> 2. Design network topology (VPCs, subnets, routing, security groups)
> 3. Choose compute resources (instance types, scaling strategy)
> 4. Design data storage and backup strategy
> 5. Plan CI/CD pipeline stages
> 6. Define infrastructure observability
> 7. Document deployment procedures and runbooks

This 7-step process assumes the answer is always "provision infrastructure."
Step 1 should actually be: **"Does this project need infrastructure at all, or
does a managed platform eliminate the need?"** The entire workflow skips the
most important question.

## Operational Complexity Comparison: Honest Assessment

### Dimension-by-Dimension Comparison

| Dimension | Server Stack (Terraform+Docker+Caddy) | Serverless (Vercel/Lambda) |
|-----------|--------------------------------------|---------------------------|
| **Initial setup** | Hours to days. Terraform init, Docker build, proxy config, DNS, TLS, firewall. | Minutes. `vercel deploy` or connect GitHub repo. |
| **Deployment** | Multi-step: build image, push registry, SSH/pull, restart service, verify. | `git push` triggers automatic deploy. Zero-downtime by default. |
| **Scaling** | Manual or auto-scaling config. Capacity planning required. | Automatic. Zero configuration. Pay per invocation. |
| **TLS certificates** | Caddy automates well, but you still run Caddy. Nginx requires certbot. | Platform handles entirely. You never see a certificate. |
| **Monitoring** | You set up Prometheus, Grafana, alerting, log aggregation. | Platform provides dashboards, function logs, error tracking out of the box. |
| **Security patching** | You patch the OS, runtime, base images, proxy. | Platform patches everything. You patch your dependencies only. |
| **Cost at low traffic** | Server runs 24/7 regardless of traffic. Minimum ~$5/month (Hetzner CX22). | Free tier covers most hobby/small projects. Pay-per-use beyond that. |
| **Cost at high traffic** | Predictable. Server cost is fixed regardless of request count. | Can spike unpredictably. Lambda at 1M req/day costs more than a server. |
| **Rollback** | Redeploy previous image, or blue-green switch. Requires setup. | One click in dashboard or `vercel rollback`. Instant. Built-in. |
| **Local development** | Docker Compose mirrors prod reasonably well. | Varies. Vercel dev is good. Lambda local dev (SAM, serverless-offline) is rougher. |
| **Vendor lock-in** | Low. Terraform is multi-cloud. Docker runs anywhere. | Medium to high. Vercel-specific APIs, Next.js coupling, platform-specific middleware. |
| **Execution limits** | None. Your server, your rules. | Function timeout (Lambda: 15min), payload size, cold starts, no persistent connections, no local filesystem. |

### The Verdict

For greenfield projects that are:
- Simple APIs (CRUD, webhooks, form handlers)
- Static sites with some dynamic server functions
- Prototype / MVP / early-stage products
- Low to moderate traffic (under ~100K requests/day)
- Standard web frameworks (Next.js, Nuxt, SvelteKit, Remix, Astro)

**Serverless is unambiguously simpler.** My current default stack is
over-engineering by any honest measure.

For projects that are:
- Long-running processes (video encoding, ML inference, websocket servers)
- High and predictable traffic (cost optimization matters)
- Custom runtime requirements (specific OS packages, GPU access, custom networking)
- Multi-service architectures with complex networking
- Compliance-constrained (data residency, specific security controls)

**Server infrastructure is the right choice.** This is where my current
knowledge shines.

## Recommendations: What Should Change in My Remit

### 1. Add a "Deployment Strategy Triage" as Step 0

Before any infrastructure design work, I should evaluate whether serverless
is sufficient. This is the single most impactful change.

**Proposed triage decision tree:**

```
Does the project need any of these?
  - Long-running processes (>30s per request)
  - Persistent connections (WebSockets, SSE without platform support)
  - Custom OS-level dependencies or GPU
  - Compliance-mandated infrastructure control
  - Predictable high traffic (>500K req/day, cost-sensitive)

  YES to any -> Server infrastructure (my current stack)
  NO to all  -> Serverless platform (Vercel, Cloudflare Pages, Lambda)
```

This triage should be the FIRST thing in my "Infrastructure Design Approach"
working pattern, before any Terraform or Docker work begins.

### 2. Add Serverless Platform Knowledge (Bounded Scope)

I should know enough about serverless to:
- **Recommend** the right platform for a given use case
- **Configure** basic deployments (vercel.json, serverless.yml, wrangler.toml)
- **Identify** when a project is hitting serverless limits and needs to escalate
- **Design** CI/CD for serverless (GitHub Actions integration, preview deploys)

**Specific platforms to cover:**

| Platform | Why | Depth |
|----------|-----|-------|
| **Vercel** | Dominant for Next.js/React, zero-config deploys, excellent DX | Deep: config, env vars, edge functions, preview deploys |
| **Cloudflare Pages/Workers** | Edge-first, great for APIs and sites, generous free tier | Moderate: basic wrangler config, Pages deployment. Deep Workers knowledge stays with edge-minion. |
| **AWS Lambda** | Enterprise standard, most flexible serverless compute | Moderate: SAM/CDK basics, API Gateway integration, IAM roles |
| **Netlify** | Good for static sites, simpler than Vercel for non-Next.js | Light: know when to recommend it, basic config |
| **Deno Deploy** | Emerging, good for Deno/Fresh projects | Light: awareness level only |

### 3. What Should Remain OUTSIDE My Scope

- **Deep Cloudflare Workers development** (Durable Objects, KV patterns, D1
  queries, Workers-specific middleware) -- this stays with edge-minion
- **Serverless application architecture** (function decomposition, event-driven
  design, saga patterns) -- this is application design, not infrastructure
- **Serverless database selection** (Neon vs PlanetScale vs Turso) -- stays
  with data-minion
- **Platform-specific framework optimization** (Next.js on Vercel middleware,
  Remix loaders) -- stays with frontend-minion

The boundary: I own "how to deploy and operate" (including the decision of
whether to deploy serverless or server). I do not own "how to architect the
application for the deployment target."

### 4. Restructure My Knowledge to Be Decision-First

Current structure (tool-first):
```
Core Knowledge
  Terraform Infrastructure Provisioning
  Docker and Container Optimization
  GitHub Actions CI/CD Pipelines
  Reverse Proxy Configuration
  Cloud Provider Patterns
  ...
```

Proposed structure (decision-first):
```
Core Knowledge
  Deployment Strategy Selection     <-- NEW: triage serverless vs server
  Serverless Deployment Patterns    <-- NEW: Vercel, Lambda, CF Pages
  Server Infrastructure Patterns    <-- RENAMED: existing Terraform/Docker/proxy content
  GitHub Actions CI/CD Pipelines    <-- UPDATED: add serverless deploy patterns
  Cloud Provider Patterns           <-- UPDATED: add serverless platform patterns
  Cost Optimization                 <-- UPDATED: add serverless cost model
  ...
```

### 5. Update Cost Optimization Knowledge

My current cost section is entirely about servers (rightsizing, reserved
instances, spot instances, auto-scaling). Serverless has a fundamentally
different cost model that I currently cannot reason about:

- **Pay-per-invocation**: Lambda charges per request + compute time. Free tier
  covers 1M requests/month.
- **Platform free tiers**: Vercel free tier is generous for personal/small
  projects. Cloudflare Workers free tier is 100K requests/day.
- **Cost crossover point**: There is a traffic threshold where serverless
  becomes more expensive than a dedicated server. I should know how to
  calculate this.
- **Hidden costs**: Data transfer, external API calls from functions, database
  connection overhead (serverless functions open new connections per invocation
  without connection pooling).

### 6. Serverless Should Be My Default for Greenfield

Yes, unequivocally. The evidence is clear:

- Serverless eliminates entire categories of operational work (patching,
  scaling, TLS, monitoring infrastructure)
- The "complexity" of serverless is in its constraints, not its setup. And
  constraints are only problems if you hit them.
- Server infrastructure should be the **escalation path** when serverless
  constraints are encountered, not the starting point
- This aligns with YAGNI: don't provision servers until you need servers

The recommended default hierarchy:
1. **Serverless platform** (Vercel, Cloudflare Pages, Netlify) -- start here
2. **Serverless compute** (Lambda, Cloudflare Workers) -- when you need custom
   backend logic beyond what the platform provides
3. **Containers on managed platforms** (ECS Fargate, Cloud Run, Fly.io) --
   when you need long-running processes or custom runtimes but still want
   managed infrastructure
4. **Self-managed servers** (Terraform + Docker + proxy) -- when you need full
   control, have compliance requirements, or have optimized for cost at scale

## Risks and Dependencies

### Risks

1. **Knowledge breadth vs depth**: Adding serverless to my remit risks
   spreading my knowledge too thin. Mitigation: keep serverless knowledge at
   the "deployment and operations" level, not the "application architecture"
   level.

2. **Overlap with edge-minion**: Cloudflare Workers/Pages sits in both
   domains. Need clear boundary: I own "should we use Workers for this
   project?" (deployment decision); edge-minion owns "how to write efficient
   Worker code" (implementation).

3. **Stale platform knowledge**: Serverless platforms evolve rapidly (Vercel
   ships features monthly). My knowledge could become outdated faster than
   server-centric knowledge. Mitigation: focus on stable patterns (deploy
   commands, config files, limit awareness) rather than platform-specific
   features.

4. **Over-correction risk**: Swinging from "always recommend servers" to
   "always recommend serverless" would be equally wrong. The triage decision
   tree is the safeguard.

### Dependencies

- **margo recalibration**: If margo still scores serverless as "new technology:
  10 points" after this advisory, my serverless-first recommendation will be
  overruled at review time. Margo's complexity budget must recognize serverless
  as the simpler option for qualifying projects.

- **Delegation table update**: The-plan.md delegation table needs a
  "serverless deployment" row routing to iac-minion (primary) with edge-minion
  (supporting for Workers-based deployments).

- **edge-minion boundary agreement**: Need explicit boundary definition so
  Cloudflare Workers/Pages deployments are not orphaned between two agents or
  double-covered.

## Suggested Delegation Table Additions

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Serverless platform deployment (Vercel, Netlify) | iac-minion | devx-minion |
| Lambda / serverless compute provisioning | iac-minion | edge-minion |
| Serverless-to-server migration | iac-minion | devx-minion |
| Greenfield deployment strategy selection | iac-minion | margo |

## Additional Specialists

No additional specialists beyond the five already in this advisory are needed
for the planning phase. If this moves to execution (modifying AGENT.md files),
the following would be relevant:

- **software-docs-minion**: For updating any architecture documentation that
  references deployment patterns
- **test-minion**: For guidance on how testing patterns change with serverless
  (local dev, integration testing against deployed functions)

## Summary

The bias is real, structural, and I am its primary vector. My entire knowledge
base assumes you need infrastructure. For the majority of greenfield projects,
you do not. The fix is:

1. Add deployment strategy triage as Step 0 (serverless vs server decision)
2. Add bounded serverless platform knowledge (Vercel, Lambda, CF Pages)
3. Make serverless the default, server infrastructure the escalation
4. Restructure knowledge to be decision-first rather than tool-first
5. Update cost optimization for serverless cost models
6. Coordinate with margo (complexity budget) and edge-minion (boundary)
