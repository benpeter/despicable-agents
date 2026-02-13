# Phase 2: margo -- Complexity Heuristic Recalibration for Serverless

## Summary

The current complexity budget and boring technology heuristics contain a structural
bias that penalizes serverless adoption by measuring novelty instead of operational
burden. This creates a paradox where margo -- the simplicity enforcer -- steers
teams toward objectively more complex deployment stacks (Docker + Terraform +
reverse proxy + OS patching) when a single `vercel deploy` or `wrangler deploy`
would satisfy requirements with less accidental complexity. The heuristics need
recalibration, not replacement.

---

## Diagnosis: Where the Current Heuristics Fail

### Problem 1: The Complexity Budget Counts Technologies, Not Operational Burden

The current budget assigns flat costs:

```
- New technology: 10 points
- New service: 5 points
- New abstraction layer: 3 points
- New dependency: 1 point
```

These costs measure *what you add to the stack*, not *what you have to operate*.
Under this model, deploying a Node.js API to Vercel scores:

- Vercel (new technology): 10 points
- **Total: 10 points**

But deploying the same API to a VPS with Docker and Caddy scores:

- Docker (new technology): 10 points
- Caddy (new technology): 10 points
- VPS provider (new service): 5 points
- **Total: 25 points**

Wait -- the current budget actually penalizes the server-based approach harder?
Not in practice. Here is the failure mode: if a team already uses Docker and
Caddy (they are "existing technology," cost 0), then adding Vercel is a net +10.
The budget measures *marginal novelty*, not *total operational burden*. A team
deep in server infrastructure never pays the complexity cost for its accumulated
toolchain -- it only pays when adding something new.

This means the heuristic structurally favors whatever the team is already doing,
even if what they are already doing is objectively more complex. For greenfield
projects with no existing stack, this creates an implicit bias toward whatever
the reviewing agent considers "default" -- and the boring technology heuristic
nudges that default toward server-based infrastructure.

### Problem 2: "Boring Technology" Conflates Age with Operational Maturity

The current boring technology section states:

> "Boring tech has decades of production hardening, well-understood failure modes,
> staffable talent pools, and community documentation."

And:

> "Using a technology that's existed for a year or less consumes a token."

By these criteria:

| Technology | Launch Year | Age | Production Hardening | Staffable |
|------------|------------|-----|---------------------|-----------|
| AWS Lambda | 2014 | 12 years | Enormous | Yes |
| Cloudflare Workers | 2018 | 8 years | Large | Yes |
| Vercel | 2020 (production) | 6 years | Large | Yes |
| Docker | 2013 | 13 years | Enormous | Yes |
| Terraform | 2014 | 12 years | Enormous | Yes |
| Caddy | 2015 | 11 years | Moderate | Moderate |
| Kubernetes | 2014 | 12 years | Enormous | Yes, but expensive |

Lambda is as old as Terraform. Workers is older than many Docker orchestration
patterns teams use today. Vercel has six years of production use. None of these
are innovation token spends by any reasonable reading of the heuristic.

Yet the boring technology section frames the choice as "Postgres, Redis, Nginx"
versus new and risky. Serverless platforms are conspicuously absent from the
examples, creating an implicit association between "boring = servers you manage"
and "new = anything else."

### Problem 3: Accidental Complexity Lives in the Server Stack, Not in Serverless

The AGENT.md and RESEARCH.md define accidental complexity as "implementation
choices -- poor abstractions, unnecessary indirection, over-engineered frameworks."
Consider what a server-based deployment requires that serverless eliminates:

| Concern | Server-Based | Serverless |
|---------|-------------|-----------|
| OS patching | Your problem (or Dockerfile rebuild) | Platform handles |
| TLS certificates | Caddy automates, but you configure | Platform handles |
| Scaling | Manual or auto-scaling config | Platform handles |
| Process supervision | systemd/supervisord/Docker restart | Platform handles |
| Reverse proxy | Caddy/Nginx config files | Platform handles |
| Port management | Your config | Platform handles |
| Log rotation | Your config | Platform handles |
| State file management | Terraform state locking, remote backends | N/A |
| Container registry | Push/pull/prune/auth | N/A |
| Network configuration | VPC, security groups, firewall rules | Platform handles |

Every row in the "Server-Based" column is accidental complexity -- none of it
comes from the problem domain. It exists purely because of the implementation
choice to run your own servers. By margo's own framework, this should be
flagged and challenged.

---

## Answers to the Three Questions

### (a) Should "serverless deployment" score LOWER than "server + container + orchestration"?

**Yes.** The complexity budget should measure operational burden, not just
technology count. I recommend a two-dimensional scoring model:

**Adoption cost** (one-time): learning curve, migration effort, new failure modes
to understand.

**Operational cost** (ongoing): what you must maintain, monitor, patch, scale,
and debug in production over the lifetime of the project.

For greenfield projects, the adoption cost comparison is:

| Approach | Config Files | Concepts to Learn | Failure Modes to Understand |
|----------|-------------|-------------------|---------------------------|
| `vercel deploy` | 0-1 (vercel.json optional) | 1 (the platform) | Cold starts, function limits |
| Docker + Terraform + Caddy | 3+ (Dockerfile, *.tf, Caddyfile) | 3+ (containers, IaC, reverse proxy) | Container networking, state drift, cert renewal, OOM, disk space |

For operational cost:

| Approach | Ongoing Maintenance |
|----------|-------------------|
| Serverless | Monitor function errors, manage environment variables |
| Server-based | OS updates, Docker image rebuilds, Terraform state, cert monitoring, disk/memory monitoring, backup strategy, security patching |

The budget should reflect this. Proposed revision:

```
Complexity Budget (approximate costs):
- New technology (unfamiliar to team): 10 points
- New self-managed service: 8 points (deployment, networking, monitoring, patching, scaling)
- New managed/serverless service: 3 points (vendor API, limits, failure modes)
- New abstraction layer: 3 points (indirection, cognitive load)
- New dependency: 1 point (supply chain risk, maintenance)
```

The key change: splitting "new service" into self-managed (8 points, raised from
5 because the original underweighted operational burden) and managed/serverless
(3 points, because the platform absorbs most operational complexity).

### (b) Should the "boring technology" heuristic include serverless platforms as boring?

**Yes.** AWS Lambda (2014), Cloudflare Workers (2018), and Vercel (2020) meet
every criterion the heuristic defines for boring technology:

- **Production hardening**: Lambda runs a significant fraction of the internet's
  backend compute. Workers handles trillions of requests. Vercel hosts millions
  of deployments.
- **Well-understood failure modes**: Cold starts, execution limits, vendor
  lock-in, egress costs -- all documented extensively.
- **Staffable talent pools**: Any Node.js developer can write a Vercel function
  or a Lambda handler. The deployment model is simpler to learn than Docker +
  Terraform.
- **Community documentation**: Massive ecosystems, Stack Overflow coverage,
  official docs, tutorials.

The boring technology section should explicitly name serverless platforms
alongside Postgres, Redis, and Nginx as examples of boring, proven technology.
Not doing so creates a false impression that only self-hosted infrastructure
qualifies as boring.

Proposed addition to the Boring Technology section:

> **Serverless platforms are boring technology.** AWS Lambda (2014), Cloudflare
> Workers (2018), and Vercel (2020) have years of production hardening, well-
> understood failure modes (cold starts, execution limits, vendor lock-in),
> staffable talent pools, and extensive documentation. Deploying to a serverless
> platform is not an innovation token spend -- it is the operationally simpler
> default for most greenfield web services and APIs.

### (c) What signals should trigger margo to flag server infrastructure as over-engineering?

I propose a new detection pattern: **Infrastructure Over-Engineering**. This
mirrors the existing "Premature Microservices" case study but targets deployment
complexity.

**Trigger signals -- flag server infrastructure when:**

1. **No scaling requirement exists**: The project has no evidence of needing
   custom scaling behavior. Default serverless auto-scaling suffices.

2. **No long-running process requirement**: The workload fits within serverless
   execution limits (typically 10-30 seconds for API responses, up to 15 minutes
   for background jobs on Lambda). If every request completes in under 30 seconds,
   you do not need a persistent server.

3. **No stateful process requirement**: The application does not need persistent
   in-memory state, WebSocket connections held for hours, or local filesystem
   storage between requests. (Note: short-lived WebSockets and server-sent events
   are supported on Workers and some serverless platforms.)

4. **Config file count exceeds code file count**: When the deployment
   configuration (Dockerfile, docker-compose.yml, Caddyfile, terraform/*.tf,
   nginx.conf, systemd units) approaches or exceeds the application code in
   complexity, the infrastructure is disproportionate to the problem.

5. **Team size is small (1-5 developers)**: Small teams cannot afford the
   operational overhead of maintaining servers, containers, and IaC. The
   cognitive load of infrastructure competes directly with feature development.

6. **Greenfield project with no existing infrastructure**: No sunk cost in
   server tooling. The marginal complexity of serverless is near zero.

**Counter-signals -- server infrastructure IS justified when:**

- Workloads require persistent connections (long-lived WebSockets, streaming for
  minutes/hours)
- Execution time regularly exceeds serverless limits
- The application needs GPU access, custom system libraries, or specific OS
  configurations
- Cost analysis shows serverless pricing is significantly more expensive at the
  project's actual scale (not hypothetical future scale)
- Regulatory or compliance requirements mandate specific infrastructure control
- The team already operates server infrastructure and adding serverless would
  genuinely increase total complexity

---

## Proposed Changes to margo AGENT.md

### 1. Revise the Complexity Budget section

Replace the flat service cost with the two-tier model (self-managed vs.
managed/serverless). Add a note that the budget measures operational burden,
not just novelty.

### 2. Expand the Boring Technology section

Add serverless platforms explicitly as boring technology with examples. Reframe
the innovation token test: it is about *unknown failure modes and operational
risk*, not about *calendar age* alone.

### 3. Add an "Infrastructure Over-Engineering" detection pattern

Add to either YAGNI Enforcement or create a new subsection under Scope Creep /
Premature Optimization. Include the trigger signals and counter-signals above.

### 4. Add an "Infrastructure Over-Engineering" case study to RESEARCH.md

Parallel to the existing "Premature Microservices" case study:

> **Case Study: Infrastructure Over-Engineering**
>
> **Problem**: Team deploys a three-endpoint API using Docker + Terraform +
> Caddy + GitHub Actions CI/CD pipeline targeting a VPS.
>
> **Consequences**:
> - Dockerfile, docker-compose.yml, Caddyfile, 4 Terraform files, 2 GitHub
>   Actions workflows -- before a single line of application code
> - Team spends 40% of first sprint on infrastructure instead of features
> - OS security patch requires Dockerfile rebuild, image push, Terraform apply
> - Debugging requires SSH access, Docker logs, Caddy logs, system journals
>
> **Simpler alternative**: `vercel deploy` or `wrangler deploy`. Zero
> infrastructure config files. Deployment is a single command. Monitoring and
> logs provided by platform. Team ships features from day one.
>
> **Lesson**: For greenfield web services and APIs without specific
> infrastructure requirements (GPU, long-running processes, persistent state),
> serverless is the simpler default. Add server infrastructure when you have
> evidence you need it, not before.

### 5. Update YAGNI detection patterns

Add to the existing detection patterns list:

> - Server infrastructure (Docker, Terraform, reverse proxy) for a stateless
>   web API that fits within serverless limits

### 6. Revise the "Premature Optimization" red flags

Add:

> - Provisioning dedicated servers "for performance" without evidence that
>   serverless cold starts or execution limits are a bottleneck

---

## Risks and Dependencies

### Risks

1. **Over-correction risk**: Margo could start reflexively flagging all server
   infrastructure, even when justified. The counter-signals list above must be
   equally prominent to prevent this. Serverless is not always simpler -- the
   heuristic must remain context-dependent.

2. **Vendor lock-in blind spot**: Serverless platforms have real lock-in costs
   (proprietary APIs, migration difficulty). The recalibrated heuristic should
   acknowledge this as a known trade-off, not ignore it. Lock-in is a real cost
   but a *future* cost that must be weighed against the *present* cost of
   operational complexity.

3. **Edge cases**: Some workloads genuinely straddle the boundary (occasional
   long-running jobs, some WebSocket usage, moderate state requirements). The
   heuristic should guide teams to evaluate rather than prescribe.

### Dependencies

- **iac-minion coordination**: The iac-minion (`/Users/ben/github/benpeter/despicable-agents/minions/iac-minion/AGENT.md`)
  currently leads with Terraform, Docker, and reverse proxy knowledge. If margo
  starts flagging these as over-engineering for simple projects, the iac-minion
  should be updated to also recommend serverless-first for greenfield projects
  that fit the profile. Otherwise the two agents will give contradictory advice.

- **edge-minion overlap**: The edge-minion (`/Users/ben/github/benpeter/despicable-agents/minions/edge-minion/AGENT.md`)
  already covers Cloudflare Workers deeply. There should be clear delegation:
  margo flags when serverless is simpler (governance), edge-minion advises on
  which serverless platform to use (domain expertise).

- **the-plan.md spec version**: If margo's AGENT.md changes, the spec-version
  in `the-plan.md` should be bumped from 1.0 to 1.1 to trigger regeneration.

---

## Specific Text Changes (Draft)

### Complexity Budget (AGENT.md, lines 55-59)

**Current:**
```
Every project has a finite complexity budget. Approximate costs:
- New technology: 10 points (failure modes, learning curve, ops burden)
- New service: 5 points (deployment, networking, monitoring)
- New abstraction layer: 3 points (indirection, cognitive load)
- New dependency: 1 point (supply chain risk, maintenance)
```

**Proposed:**
```
Every project has a finite complexity budget. Approximate costs:
- New technology (unfamiliar to team): 10 points (failure modes, learning curve)
- New self-managed service: 8 points (deployment, networking, monitoring, patching, scaling)
- New managed/serverless service: 3 points (vendor API surface, platform limits)
- New abstraction layer: 3 points (indirection, cognitive load)
- New dependency: 1 point (supply chain risk, maintenance)

Budget measures operational burden, not novelty. A single serverless deployment
command carries less ongoing cost than a stack of Dockerfiles, Terraform configs,
and reverse proxy rules -- even when the server tools are familiar.
```

### Boring Technology (AGENT.md, lines 171-179)

**Current:**
```
Choose boring technology. Every organization gets roughly three innovation
tokens. Boring tech has decades of production hardening, well-understood failure
modes, staffable talent pools, and community documentation. The long-term cost
of keeping a system running vastly exceeds build-time inconvenience.

AI coding tools make this more critical, not less -- resist the temptation to
adopt multiple new technologies simultaneously just because AI can scaffold them.
```

**Proposed:**
```
Choose boring technology. Every organization gets roughly three innovation
tokens. Boring tech has years of production hardening, well-understood failure
modes, staffable talent pools, and community documentation. The long-term cost
of keeping a system running vastly exceeds build-time inconvenience.

Serverless platforms are boring technology. AWS Lambda (2014), Cloudflare
Workers (2018), and Vercel (2020) have years of production hardening,
well-understood failure modes (cold starts, execution limits, vendor coupling),
and large talent pools. Deploying to serverless is not an innovation token
spend for most web services and APIs.

AI coding tools make this more critical, not less -- resist the temptation to
adopt multiple new technologies simultaneously just because AI can scaffold them.
```

### New YAGNI Detection Pattern (AGENT.md, add to lines 70-76)

Add to the existing detection patterns list:
```
- Server infrastructure (Docker, Terraform, reverse proxy) for stateless APIs
  that fit within serverless execution limits
```

### New Section: Infrastructure Over-Engineering (AGENT.md, after Premature Optimization)

```
## Infrastructure Over-Engineering Detection

Server infrastructure is essential complexity when workloads demand it. For
stateless web services and APIs, it is often accidental complexity -- operational
burden chosen by habit rather than requirement.

**Flag server infrastructure when**:
- No scaling, long-running process, or persistent state requirement exists
- Deployment config files (Dockerfile, *.tf, Caddyfile) rival application code
  in complexity
- Team is small (1-5 developers) and infrastructure competes with feature work
- Greenfield project with no existing server infrastructure investment

**Server infrastructure IS justified when**:
- Workloads need persistent connections, GPU, custom OS, or exceed serverless
  execution limits
- Cost analysis at actual (not hypothetical) scale favors servers
- Regulatory requirements mandate specific infrastructure control
- Team already operates server infrastructure and serverless would increase
  total complexity

**The test**: "Does this workload have a specific requirement that serverless
cannot meet?" If no, serverless is the simpler default.
```

---

## RESEARCH.md Updates Required

The RESEARCH.md currently has no content about deployment complexity comparison,
serverless as boring technology, or infrastructure over-engineering as an
anti-pattern. The following sections should be added:

1. **Infrastructure Over-Engineering Case Study** (parallel to existing case studies)
2. **Serverless as Boring Technology** subsection under the Boring Technology section
3. **Deployment Complexity Comparison** -- concrete comparison of config file
   counts and operational burden between serverless and server-based approaches
4. **Serverless Limitations** -- honest accounting of cold starts, execution
   limits, vendor lock-in, debugging difficulty, and cost at scale

---

## Verdict on the Bias

The bias is real and structural. It stems from three compounding factors:

1. The complexity budget penalizes adding new things but not maintaining existing
   complex things
2. The boring technology examples implicitly equate "boring" with "self-hosted"
3. There is no detection pattern for infrastructure over-engineering, even though
   patterns exist for premature microservices, premature optimization, and SOLID
   over-application

The fix is straightforward: recalibrate the budget to measure operational burden,
update the boring technology examples, and add an infrastructure over-engineering
detection pattern. These changes are consistent with margo's core mission --
challenging accidental complexity wherever it appears, including in deployment
choices.
