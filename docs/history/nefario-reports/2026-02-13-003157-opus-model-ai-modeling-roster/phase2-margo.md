## Domain Plan Contribution: margo

### Recommendations

#### (a) Complexity Budget Recalibration: Score What You Actually Own

The current complexity budget is flat-rate per category. The problem is not the
categories themselves but that they conflate two distinct costs: **novelty cost**
(learning curve, unfamiliar failure modes) and **operational burden** (things you
must keep running). A managed service eliminates operational burden but may still
carry novelty cost. The budget should score both dimensions independently.

**Proposed scoring model -- replace the existing four-line budget with:**

```
Complexity Budget (approximate costs):

                        | Self-managed | Managed/Serverless
  New technology        |     10       |      5
  New service           |      5       |      2
  New abstraction layer |      3       |      3
  New dependency        |      1       |      1

Self-managed: you operate the runtime (VMs, containers, orchestration).
Managed/Serverless: vendor operates the runtime; you own config and code only.
```

Rationale for the specific numbers:

- **New technology, managed (5 vs 10):** You still pay learning curve, vendor
  lock-in awareness, and unfamiliar failure modes. But you eliminate deployment
  pipelines, OS patching, scaling configuration, monitoring stack, and container
  orchestration. Half the cost is fair -- the novelty half remains.
- **New service, managed (2 vs 5):** A managed service means no deployment
  artifact, no networking topology you maintain, no monitoring you wire up. The
  cost drops to config complexity (IAM, environment variables, API keys) plus
  vendor coupling. That is real but much smaller than standing up a new
  container.
- **Abstraction layers and dependencies stay unchanged:** These are code-level
  costs. Whether the code runs on Lambda or on a VM, an unnecessary abstraction
  layer still costs 3 points of cognitive load, and a dependency still carries
  supply chain risk.

**Key design choice:** The budget does NOT award zero points to anything. Even a
fully managed service has configuration complexity, vendor failure modes, and
cognitive load from one more thing in the stack. Zero-cost entries would
undermine the budget's purpose of making teams think before adding.

#### (b) Boring Technology Graduation: Apply the Existing Criteria Honestly

The AGENT.md already defines boring technology criteria: "decades of production
hardening, well-understood failure modes, staffable talent pools, community
documentation." The issue is that these criteria were written with an implicit
assumption that "technology" means "something you install and operate." Managed
platforms should be evaluated against the same criteria without topology bias.

**Specific guidance to add to the Boring Technology section:**

> Boring technology assessment applies to platforms, not just software you
> install. A managed platform qualifies as boring when it meets the same
> criteria: production-hardened (5+ years of widespread production use),
> well-understood failure modes (documented incident patterns), staffable
> (engineers with production experience are readily available), and
> well-documented (official docs, community troubleshooting).
>
> Examples as of this writing: AWS Lambda (2014), Vercel (2015 as ZEIT),
> Cloudflare Workers (2018), GitHub Actions (2019), AWS S3 static hosting
> (2006). These are boring. Treat them as established platforms, not novel
> technology, when scoring the complexity budget.
>
> Boring technology assessment is topology-neutral. A Docker+VPS stack can be
> boring. A serverless stack can be boring. Novelty is about unfamiliarity and
> unproven failure modes, not about where the code runs.

**What this does NOT do:** It does not say "serverless is always simpler." It
says "do not automatically penalize a platform as novel when it has a decade of
production history." The budget still charges points for each service. A project
using Lambda + API Gateway + DynamoDB + S3 + CloudFront still accumulates cost
(2+2+2+2+2 = 10 points for five managed services). That is honest complexity
accounting.

#### (c) Infrastructure Over-Engineering Detection: Signals, Not Prescriptions

Margo should detect *disproportionate infrastructure* the same way it detects
disproportionate abstraction: by comparing the infrastructure's complexity to the
problem's actual operational requirements.

**Proposed heuristic -- add as a new subsection "Infrastructure Proportionality"
under KISS Enforcement or as a peer section:**

> **Infrastructure Proportionality**
>
> Infrastructure complexity should be proportional to operational requirements.
> Flag plans where infrastructure outweighs the application:
>
> - **Deploy pipeline exceeds application code**: multi-stage Docker builds,
>   Terraform modules, Nginx configs, and monitoring stack for a project with
>   fewer than 5 routes or endpoints
> - **Scaling machinery without scale evidence**: load balancers, auto-scaling
>   groups, or container orchestration when expected traffic is under 1000
>   requests/minute
> - **Ops surface area exceeds team capacity**: infrastructure requiring
>   on-call rotation, certificate renewal, OS patching, or database backups
>   when the team is 1-3 people
> - **Configuration count**: more than 5 infrastructure configuration files
>   (Dockerfiles, Terraform files, Nginx configs, docker-compose files) for a
>   project that could deploy with 1-2
> - **Deployment ceremony**: deploy process requiring more than 3 manual or
>   scripted steps when a `git push` deploy would suffice
>
> These are signals for investigation, not automatic vetoes. A project with
> genuine operational requirements (compliance, data residency, custom
> networking, performance SLAs) may justify heavy infrastructure. The test is:
> "Does this infrastructure complexity serve actual requirements, or is it
> inherited from a template?"

This is how margo already works for code (challenge every layer, demand
justification). The change is extending that same principle to infrastructure
layers.

#### (d) Framing: Disproportionality Detection, Not Topology Prescription

The recalibration must be carefully framed so margo never says "use serverless
instead" but can say "this infrastructure seems disproportionate to the
requirements."

**Concrete framing rules to embed in the spec:**

1. **Margo flags disproportion, not topology.** "This plan has 8 infrastructure
   config files for a 3-endpoint API" is a valid margo observation. "Use Vercel
   instead of Docker" is NOT -- that is a technology decision (gru's domain).

2. **Margo scores complexity honestly regardless of topology.** If a serverless
   plan has 6 managed services, 3 abstraction layers, and a custom deployment
   framework, margo scores it at 12+ 9 + framework cost. Serverless is not a
   complexity exemption.

3. **Margo asks the proportionality question, not the topology question.** The
   canonical margo question is: "Is this complexity justified by actual
   requirements?" NOT "Is this the right platform?" The former is margo's lane.
   The latter is gru's.

4. **Handoff trigger:** When margo identifies disproportionate infrastructure and
   the team needs to evaluate alternative platforms, margo hands off to gru for
   the technology decision. Margo says "this is more infrastructure than the
   problem seems to require -- gru should evaluate whether a simpler deployment
   target exists." Margo does not name the alternative.

### Proposed Tasks

**Task 1: Recalibrate complexity budget in the-plan.md margo spec (lines 537-570)**

Update the spec-version and add language directing the AGENT.md to include:
- Two-column complexity budget (self-managed vs managed/serverless)
- Topology-neutral boring technology assessment
- Infrastructure proportionality detection heuristic
- Explicit framing: margo detects disproportion, does not prescribe topology

This is a spec-level change to `the-plan.md` only. The AGENT.md rebuild follows
from the spec change via the standard `/despicable-lab` process.

**Task 2: Rebuild margo/AGENT.md from updated spec**

After the spec change, regenerate `margo/AGENT.md` to incorporate:
- Revised Complexity Budget section with the two-column scoring model
- Expanded Boring Technology section with platform-neutral criteria
- New Infrastructure Proportionality subsection
- Updated handoff triggers (disproportionate infrastructure -> gru)
- Bump `x-plan-version` to match new `spec-version`

**Task 3: Update margo/RESEARCH.md with supporting evidence**

Add research backing for:
- Operational burden as a complexity dimension (cite DevOps research on MTTR,
  deployment frequency correlation with team size)
- Production track records for established managed platforms
- Infrastructure-proportionality as a review heuristic (tie to existing
  simplicity literature already in RESEARCH.md)

### Risks and Concerns

1. **Over-correction risk: serverless gets a free pass.** If the managed column
   scores too low, margo will stop flagging genuinely complex serverless
   architectures (Lambda + Step Functions + API Gateway + DynamoDB + SQS +
   EventBridge is six services and real complexity). The two-column model
   mitigates this because each managed service still costs 2 points, so
   sprawling architectures still accumulate significant budgets. Monitor this
   in practice.

2. **Boundary blurriness with gru.** The line between "this infrastructure is
   disproportionate" (margo) and "consider this alternative platform" (gru) is
   inherently fuzzy. The framing rules help, but in practice margo will
   sometimes identify disproportion in a way that implies a specific alternative.
   The safeguard is the explicit handoff trigger: margo names the problem, gru
   names the solution.

3. **"Managed" is not binary.** A self-managed Kubernetes cluster running on
   Hetzner is fully self-managed. AWS ECS is partially managed. Vercel is fully
   managed. The two-column model is a simplification. For the purposes of a
   heuristic budget this is acceptable -- the budget was always approximate. But
   the AGENT.md should note that teams should use judgment for hybrid cases.

4. **Spec-version coordination.** This change touches margo's spec-version in
   the-plan.md. If other changes are in flight for margo (unlikely but
   possible), version coordination is needed.

### Additional Agents Needed

None beyond what the issue already identifies. The margo changes are
self-contained within margo's spec and AGENT.md. The coordination with iac-minion
spec expansion and delegation table updates is handled at the plan level by
nefario, not by margo.

One note: if the iac-minion spec expansion introduces new serverless platforms
that margo should recognize as "boring technology," the boring technology
examples list in margo's AGENT.md should be updated in the same pass to stay
consistent. This is a sequencing dependency, not an additional agent need.
