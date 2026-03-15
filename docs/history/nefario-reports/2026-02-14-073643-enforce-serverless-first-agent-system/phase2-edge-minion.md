# Domain Plan Contribution: edge-minion

## Recommendations

### (a) Completeness of the Blocking Concerns List

The four blocking concerns (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale) cover the most common reasons to reject serverless. However, from direct experience with edge serverless platforms, three additional blocking concerns are legitimate and should be added:

**1. Execution environment constraints (native binaries, CPU/memory limits)**

Edge serverless platforms impose hard runtime constraints that cannot be worked around:

- **Cloudflare Workers**: 10ms CPU time (free), 30s CPU time (paid), 128MB memory. No native binary execution -- only JavaScript, WebAssembly, and supported WASM-compiled languages. No filesystem access. No raw TCP/UDP sockets (only HTTP fetch, WebSocket, and Cloudflare-specific bindings).
- **Vercel Edge Functions**: 25ms CPU time (Hobby), limited to Web APIs and V8 runtime. No Node.js-specific APIs (no `fs`, `child_process`, `net`). Vercel Serverless Functions (Node.js runtime) have higher limits but run in a single region, not at the edge.
- **Fastly Compute**: WASM-only. 60s execution time, 150MB memory. Must compile to WASM, which excludes many languages and libraries with native dependencies.
- **AWS Lambda@Edge**: 5s execution limit (viewer triggers), 30s (origin triggers), 128-10240MB memory. More generous but still hard-capped.

Workloads requiring native binary execution (FFmpeg, ImageMagick, ML inference with native models, PDF generation with headless browsers), large memory footprints, or CPU-intensive computation beyond platform limits are legitimately blocked from serverless. This is not a preference -- it is a hard constraint.

**Recommendation**: Add "Execution environment constraints" to the blocking list. Phrasing: "Execution environment constraints (native binaries, CPU/memory limits beyond platform maximums)."

**2. Storage access patterns that don't fit edge primitives**

Edge storage (KV, D1, R2, Durable Objects) has specific access pattern constraints:

- **Workers KV**: 1 write RPS per key, eventually consistent reads. Not suitable for high-write workloads or workloads requiring strong read-after-write consistency.
- **D1**: Serialized writes via Durable Objects. Not suitable for write-heavy transactional workloads with high concurrency.
- **Edge databases generally**: Best for datasets under 1GB, read-heavy access patterns, and eventual consistency tolerance. Workloads requiring complex multi-table joins, large datasets, or strict global consistency are blocked.

However, I would classify this as a sub-case of execution environment constraints rather than a separate top-level blocking concern. The storage limitations are part of the serverless platform's overall constraint envelope. If the workload needs a traditional RDBMS with 100GB+ of data and complex transactions, the storage constraint is what blocks serverless, but the solution is typically to use serverless compute with a managed database (RDS, Cloud SQL) -- which is still serverless for the compute layer. Only when the storage access pattern demands co-located compute (e.g., data-intensive batch processing reading terabytes from local disk) does it truly block the serverless topology.

**Recommendation**: Fold storage constraints into the execution environment constraints item rather than creating a separate entry. The existing list item can read: "Execution environment constraints (native binaries, CPU/memory limits, storage access patterns incompatible with platform primitives)."

**3. Cold start latency sensitivity for specific P99 requirements**

This is partially covered by the existing list but deserves explicit mention. Edge serverless platforms largely eliminate cold starts (Workers: 0ms cold start due to V8 isolates; Vercel Edge Functions: similar). But full-cloud serverless (Lambda, Cloud Functions) has meaningful cold starts:

- **AWS Lambda**: 100ms-2s cold start depending on runtime, package size, VPC configuration.
- **Cloud Functions**: Similar range.

For workloads with strict P99 latency SLOs (e.g., <50ms for API responses), Lambda cold starts are a blocking concern unless provisioned concurrency is used -- which partially defeats the scale-to-zero benefit of serverless. Edge serverless handles this better, but not all workloads can run at the edge (see constraints above).

**Recommendation**: This is NOT a new blocking concern but rather a nuance that strengthens the case for an edge-first sub-preference within serverless (see part b). The existing blocking list is sufficient if the "edge-first within serverless" sub-preference is adopted, because edge platforms largely eliminate the cold start problem.

**What does NOT belong on the blocking list:**

- "Vendor lock-in" -- this is a risk to manage, not a blocking concern. All serverless platforms have some lock-in; the question is whether the lock-in cost exceeds the operational benefit. The current list item "cost optimization at scale" implicitly covers the scenario where lock-in drives costs up.
- "Debugging difficulty" -- legitimate operational concern but not a reason to reject the topology. Better tooling and observability practices address this.
- "Multi-platform coordination" -- orchestrating across multiple edge providers is complex (cache invalidation timing, config consistency, failover logic), but this is a multi-CDN architecture concern, not a serverless-vs-not concern. It exists regardless of compute topology.

### (b) Edge-First Sub-Preference Within Serverless

**Yes, adopt an edge-first sub-preference within serverless, with a clear escape hatch.**

The Helix Manifesto's latency principle ("<300ms fast. Always.") directly supports this. Here is the reasoning:

**Why edge-first is the right default:**

1. **Latency**: Edge serverless platforms (Workers, Vercel Edge Functions, Fastly Compute) run code in 200+ global locations. P50 latency is typically 5-20ms for compute + edge storage reads. Full-cloud serverless (Lambda) runs in 1-3 regions; cross-region latency adds 50-200ms for users far from the deployment region. The "<300ms fast" principle is easier to meet at the edge.

2. **Cold starts**: V8 isolate-based edge platforms (Workers, Vercel Edge) have near-zero cold starts. Lambda and Cloud Functions have 100ms-2s cold starts. Edge-first eliminates cold start as a concern for most workloads.

3. **Operational simplicity**: Edge platforms are inherently simpler -- no VPC configuration, no subnet planning, no NAT gateways, no security groups. This aligns with "lean and mean" and "ops reliability wins."

4. **Scale-to-zero is native**: All edge platforms scale to zero by default with no configuration. Lambda also does this, but edge does it with less operational overhead (no concurrency tuning, no provisioned capacity decisions).

**When to escape from edge to full-cloud serverless:**

The escape hatch should be crisp and criteria-driven:

- **Node.js/Python ecosystem dependencies**: The workload requires Node.js APIs (`fs`, `net`, `child_process`, `crypto` beyond Web Crypto) or Python packages with C extensions that don't compile to WASM. Use Lambda/Cloud Functions.
- **Execution duration > 30s**: Edge platforms cap at 30s (Workers paid) or less. Lambda allows up to 15 minutes. Use Lambda for longer-running serverless workloads.
- **Memory > 128MB**: Edge platforms are memory-constrained. Lambda allows up to 10GB. Use Lambda for memory-intensive workloads.
- **VPC/private network access required**: Edge platforms cannot reach resources inside a VPC (RDS in private subnet, internal APIs). Lambda with VPC configuration can. Use Lambda when the workload must access private infrastructure.
- **Regulatory data residency**: Edge platforms execute in the nearest POP, which may be in a non-compliant jurisdiction. Lambda runs in a specific, controllable region. Use Lambda when data must not leave a specific geography. (Note: Cloudflare offers jurisdiction restrictions, but the feature set is more limited than region-locked Lambda.)

**How to express this in iac-minion's Step 0:**

The decision flow becomes:

```
1. Start with serverless (unless blocked by the four+one concerns)
2. Within serverless, start with edge (Workers, Vercel Edge, Fastly Compute)
3. Escape to full-cloud serverless (Lambda, Cloud Functions) only when:
   - Workload requires Node.js/Python ecosystem APIs unavailable at edge
   - Execution duration exceeds edge platform limits
   - Memory requirements exceed edge platform limits
   - Must access VPC-internal resources
   - Data residency requires region-locked execution
4. If full-cloud serverless is also blocked, evaluate containers
5. If containers are also blocked, evaluate self-managed
```

This is NOT over-prescriptive because:
- The escape criteria are concrete and measurable (not subjective)
- The decision tree is sequential and fast to evaluate (no matrix of 10 dimensions)
- It aligns with three Helix Manifesto principles simultaneously (latency, lean, ops reliability)
- It reduces decision fatigue -- developers don't need to evaluate all topologies for every workload

**This IS over-prescriptive if** the agent system needs to serve teams that primarily deploy to AWS/GCP with existing Lambda/Cloud Functions infrastructure. In that case, forcing an edge-first evaluation step adds friction without value. But the Helix Manifesto's latency principle suggests the system should push teams toward edge when possible, and the escape hatch keeps it pragmatic.

## Proposed Tasks

### Task 1: Add "execution environment constraints" to the blocking concerns list

**Owner**: iac-minion (with edge-minion consultation)
**Action**: Add a fifth blocking concern to the serverless-first default: "Execution environment constraints (native binaries, CPU/memory limits, storage access patterns incompatible with platform primitives)."
**Files affected**: `the-plan.md` (iac-minion spec), `minions/iac-minion/AGENT.md`
**Dependency**: None

### Task 2: Restructure iac-minion Step 0 as serverless-first with edge sub-preference

**Owner**: iac-minion
**Action**: Replace the current 10-dimension neutral evaluation with a serverless-first decision tree. Step 0 becomes: "Start with serverless. Within serverless, start with edge. Escape to full-cloud serverless when edge constraints block. Escape to containers when serverless constraints block. Escape to self-managed when container constraints block." Each escape has explicit, measurable criteria.
**Files affected**: `the-plan.md` (iac-minion spec, Step 0 section), `minions/iac-minion/AGENT.md`
**Dependency**: Task 1 (the blocking list must be finalized first)

### Task 3: Add edge platform constraint reference table to edge-minion

**Owner**: edge-minion
**Action**: Add a concise reference table to the edge-minion AGENT.md documenting current platform limits (CPU time, memory, execution duration, supported runtimes, storage options) for Workers, Vercel Edge, Fastly Compute, and Lambda@Edge. This table serves as the source of truth for iac-minion's "escape from edge" criteria. Keep it factual and updatable.
**Files affected**: `the-plan.md` (edge-minion spec, if constraint reference is spec-level), `minions/edge-minion/AGENT.md`
**Dependency**: None (can run in parallel with Tasks 1 and 2)

### Task 4: Document the edge-to-cloud-serverless escape criteria in iac-minion

**Owner**: iac-minion (with edge-minion review)
**Action**: Add the five escape criteria (Node.js/Python ecosystem deps, execution duration, memory, VPC access, data residency) as an explicit checklist in the iac-minion Step 0 section. Reference edge-minion's constraint table for current platform limits.
**Files affected**: `minions/iac-minion/AGENT.md`
**Dependency**: Task 2 and Task 3

## Risks and Concerns

1. **Platform limits change frequently**: Edge platform constraints (CPU time, memory, execution duration) are updated by providers regularly. Cloudflare has increased Worker limits multiple times. The constraint reference table (Task 3) must be treated as a living document, not a permanent fixture. Risk: stale limits cause incorrect topology decisions. Mitigation: include "last verified" dates and instruct agents to verify limits via WebSearch for critical decisions.

2. **Edge-first bias could frustrate AWS/GCP-heavy teams**: Teams with existing Lambda infrastructure and AWS expertise may find the "evaluate edge first" step unnecessary friction. The escape criteria will quickly route them to Lambda, but the evaluation step itself may feel prescriptive. Mitigation: the escape criteria are fast to evaluate (5 yes/no questions), so the overhead is minimal. The decision tree should explicitly state "if existing infrastructure is Lambda/Cloud Functions and workload fits, use it" to avoid unnecessary re-evaluation.

3. **Vercel/Netlify platform abstraction blurs the edge vs. cloud boundary**: Vercel automatically decides whether to run a function at the edge or in a regional serverless environment based on the runtime used. A developer writing a Vercel function may not control whether it runs at the edge or in Lambda. The decision tree assumes the team can choose, but platform abstraction may make the choice implicit. Mitigation: document that on abstracted platforms (Vercel, Netlify), the "edge vs. cloud serverless" decision is made by choosing the function runtime (Edge Runtime vs. Node.js Runtime), not by explicit deployment configuration.

4. **The "cost optimization at scale" escape is too vague without a threshold**: The blocking concern "cost optimization at scale (proven, measured, not speculative)" is good in principle but provides no guidance on what "at scale" means. A team processing 1M requests/month may claim cost optimization. Mitigation: iac-minion should define a threshold or require a cost comparison document before accepting this as a blocking concern.

## Additional Agents Needed

None. The task set involves iac-minion (primary owner of Step 0 and deployment strategy) and edge-minion (providing platform constraint data). Lucy and margo should review the final wording for consistency and simplicity, but they are already part of the governance review process and don't need special involvement.
