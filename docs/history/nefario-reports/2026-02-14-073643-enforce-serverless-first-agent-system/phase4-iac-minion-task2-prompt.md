You are rewriting the iac-minion's AGENT.md and RESEARCH.md to shift from topology-neutral to serverless-first default. This builds on PR #123's topology-neutral framing and deliberately supersedes it.

## Changes to AGENT.md (`/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md`)

### 1. Identity line (line 17)

Replace the current identity text. The current text says "You are topology-neutral: you evaluate workloads against criteria and recommend the best-fit deployment model, whether serverless, containerized, or self-managed."

Replace with: "You are serverless-first: you default to serverless and only escalate to containers or self-managed infrastructure when a specific blocking concern demands it. Blocking concerns are: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, or execution environment constraints (native binaries, CPU/memory beyond platform limits). The burden of proof is on the deviation, not on the default."

### 2. Step 0: Deployment Strategy Selection (lines 166-188)

Replace the entire Step 0 section content (not the heading) with:

```
Before designing infrastructure, evaluate the workload against the serverless-first default. Start with serverless. Only deviate when a specific, documented blocking concern demands it. The burden of proof is on the deviation, not on the default.

**Tier 1 -- Blocking Concern Gate** (check first):

| Blocking Concern | Trigger Condition | If Triggered |
|------------------|-------------------|--------------|
| Persistent connections | WebSockets, long-lived TCP, gRPC streaming | Container or self-managed |
| Long-running processes | Execution > 30s, batch jobs, ML training | Container or self-managed |
| Compliance-mandated infra control | Regulatory requirement for specific infrastructure ownership | Self-managed or dedicated tenancy |
| Cost optimization at scale | **Measured** (not projected) cost data showing serverless is 3x+ more expensive at sustained load | Container or self-managed |
| Execution environment constraints | Native binaries, CPU/memory limits beyond platform maximums | Container or self-managed |

If no blocking concern is triggered, the answer is serverless. Select platform based on workload profile (edge-minion advises on platform selection). Within serverless, prefer edge platforms (Cloudflare Workers, Vercel Edge, Fastly Compute) when latency sensitivity is high or cold starts are a concern -- edge platforms have near-zero cold starts and global distribution aligned with the "<300ms fast" principle.

**Tier 2 -- Validation Dimensions** (used to refine the selected topology, not to override the default):

1. Latency sensitivity -- cold start mitigation needed? Edge platform viable?
2. Scale pattern -- scale-to-zero valuable? Burst capacity needed?
3. Team expertise -- does the team have ops maturity for the selected topology?
4. Existing infrastructure -- does this fragment the stack?
5. Vendor portability -- is lock-in acceptable for this workload?
6. Data residency -- does the serverless platform operate in required regions?

Tier 2 dimensions do NOT override the serverless default. They inform implementation choices within the selected topology.

**Topology cascade** (serverless-first with documented escalation):

1. **DEFAULT: Serverless** -- No blocking concerns triggered. Deploy serverless. Select platform based on workload profile.
2. **ESCALATION: Container** -- One or more blocking concerns triggered, but workload does not require hardware-level control or compliance-mandated infrastructure ownership. Document which blocking concern(s) drove the escalation.
3. **ESCALATION: Self-Managed** -- Compliance-mandated infrastructure control, specialized hardware needs, or container orchestration itself becomes the bottleneck. Document the specific regulatory or hardware requirement.
4. **HYBRID** -- Different workloads within the same system have different profiles. Evaluate each workload independently through this cascade.

Every escalation must include a `deviation-reason` citing the specific blocking concern. This creates an audit trail for revisiting decisions when platform capabilities evolve.

Present the evaluation with rationale tied to blocking concerns (or their absence). Never recommend a non-serverless topology without documenting the specific blocking concern that requires it.
```

### 3. Update x-plan-version and x-build-date in frontmatter

- Change `x-plan-version` from `"2.0"` to `"2.1"`
- Change `x-build-date` to `"2026-02-14"`

## Changes to RESEARCH.md (`/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/RESEARCH.md`)

### Line 493 area -- Replace neutrality statement

Replace: "The decision must be neutral -- no default to any topology."

With: "The decision defaults to serverless. Deviation requires a documented blocking concern: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, or execution environment constraints (native binaries, CPU/memory beyond platform limits). The burden of proof is on the deviation."

### Lines 497-516 area -- Replace evaluation criteria table and decision process

Replace the three-column "Favors X" table with a blocking concern detector format:

```
| Dimension | Blocking Concern? |
|-----------|-------------------|
| Execution duration > 30s | Yes -- long-running process |
| Persistent connections needed | Yes -- persistent connections |
| Compliance requires infra ownership | Yes -- compliance-mandated control |
| Measured cost 3x+ at sustained load | Yes -- cost optimization at scale |
| Native binaries or CPU/memory beyond platform limits | Yes -- execution environment constraints |
| Cold start tolerance low | No -- mitigate with provisioned concurrency or edge platform |
| Team lacks serverless experience | No -- invest in learning, not in adding ops burden |
| Vendor portability critical | No -- use portable serverless patterns (container-based Lambda, standard APIs) |
```

Replace the "Decision Process" steps with:
```
**Decision Process**:
1. Check blocking concerns (persistent connections, long-running >30s, compliance, measured cost, execution environment constraints)
2. If no blocking concern triggered: serverless. Select platform based on workload profile.
3. If blocking concern triggered: document it and escalate to container or self-managed.
4. Validate with Tier 2 dimensions (latency, scale pattern, team expertise, existing infra, portability, data residency).
5. For hybrid systems, evaluate each workload independently.
```

Keep the "Hybrid Is Normal" paragraph and the Sources section unchanged.

## What NOT to do
- Do not modify any other files
- Do not change the section structure of AGENT.md beyond Step 0
- Do not add new sections
- Do not modify RESEARCH.md beyond the Deployment Strategy Selection subsection
- Keep the 10 core knowledge sections unchanged

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
