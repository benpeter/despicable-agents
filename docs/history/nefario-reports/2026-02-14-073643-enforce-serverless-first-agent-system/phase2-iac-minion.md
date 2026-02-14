# Domain Plan Contribution: iac-minion

## Recommendations

### (a) Opening Framing Statement

Replace:

> "This decision must be criteria-driven, not preference-driven. No default to any topology."

With:

> "Start with serverless. Evaluate whether any blocking concern prevents serverless deployment. Only deviate when a specific, documented blocking concern demands it. The burden of proof is on the deviation, not on the default."

**Rationale**: The old framing treated all topologies as equally likely starting points, which in practice led to arbitrary selection based on familiarity rather than workload fit. Serverless aligns directly with the Helix Manifesto's "lean and mean" (no idle infrastructure, no capacity planning, minimal ops surface) and "ops reliability wins" (managed platform reliability exceeds what most teams achieve self-managing). Making serverless the default with explicit escape hatches produces better outcomes than false neutrality.

### (b) 10-Dimension Evaluation Checklist: Restructure as Blocking Concern Detector

The current 10-dimension checklist should be **restructured, not removed**. It transforms from "which topology does this dimension favor?" into "does this dimension surface a blocking concern against serverless?"

**Proposed structure**: Split the checklist into two tiers.

**Tier 1 -- Blocking Concern Gate** (the four canonical blockers, checked first):

| Blocking Concern | Trigger Condition | If Triggered |
|------------------|-------------------|--------------|
| Persistent connections | WebSockets, long-lived TCP, gRPC streaming | Container or self-managed |
| Long-running processes | Execution > 30s, batch jobs, ML training | Container or self-managed |
| Compliance-mandated infra control | Regulatory requirement for specific infrastructure ownership | Self-managed or dedicated tenancy |
| Cost optimization at scale | **Measured** (not projected) cost data showing serverless is 3x+ more expensive at sustained load | Container or self-managed |

The word "measured" is critical for the cost blocker. Speculative cost projections ("it might get expensive") do not qualify. You need actual traffic data or a concrete, committed scale commitment.

**Tier 2 -- Validation Dimensions** (the remaining dimensions, used to validate and refine once a topology is selected):

1. Latency sensitivity -- cold start mitigation strategy needed? Edge platform viable?
2. Scale pattern -- scale-to-zero valuable? Burst capacity needed?
3. Team expertise -- does the team have the ops maturity for the selected topology?
4. Existing infrastructure -- does this fragment the stack?
5. Vendor portability -- is lock-in acceptable for this workload?
6. Data residency -- does the serverless platform operate in required regions?

These Tier 2 dimensions do NOT override the serverless default on their own. They inform implementation choices within the selected topology (e.g., which serverless platform, whether to use provisioned concurrency, whether edge deployment addresses latency concerns).

### (c) Topology Recommendation Section: Serverless-Default with Escalation

Replace the current four equal-weight recommendation blocks with a decision cascade:

```
1. DEFAULT: Serverless
   No blocking concerns triggered -> deploy serverless.
   Select platform based on workload profile (edge-minion advises on platform).

2. ESCALATION: Container
   One or more blocking concerns triggered, but workload does not require
   hardware-level control or compliance-mandated infrastructure ownership.
   Document which blocking concern(s) drove the escalation.

3. ESCALATION: Self-Managed
   Compliance-mandated infrastructure control, specialized hardware needs,
   or container orchestration itself becomes the bottleneck.
   Document the specific regulatory or hardware requirement.

4. HYBRID (unchanged)
   Different workloads within the same system have different profiles.
   Evaluate each workload independently through this same cascade.
```

Each escalation step must include a `deviation-reason` field in the infrastructure documentation, citing the specific blocking concern by name. This creates an audit trail and makes it easy to revisit decisions when platform capabilities evolve (e.g., Cloudflare Workers adding WebSocket support might eliminate a persistent-connection blocker).

### (d) Identity Line

Replace:

> "You are topology-neutral: you evaluate workloads against criteria and recommend the best-fit deployment model, whether serverless, containerized, or self-managed."

With:

> "You are serverless-first: you default to serverless and only escalate to containers or self-managed infrastructure when a specific blocking concern -- persistent connections, long-running processes, compliance-mandated infrastructure control, or measured cost optimization at scale -- demands it."

This is a meaningful change in agent behavior. The old identity invited the agent to weigh all options equally. The new identity creates a clear default and makes the agent actively seek reasons to stay serverless rather than reasons to leave it.

### (e) RESEARCH.md Neutrality Statement

Replace (line 493):

> "The decision must be neutral -- no default to any topology."

With:

> "The decision defaults to serverless. Deviation requires a documented blocking concern: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, or measured cost optimization at scale. The burden of proof is on the deviation."

The evaluation criteria table in RESEARCH.md (lines 497-508) should also be restructured. Instead of three "Favors X" columns, use a two-column format:

| Dimension | Blocking Concern? |
|-----------|-------------------|
| Execution duration > 30s | Yes -- long-running process |
| Persistent connections needed | Yes -- persistent connections |
| Compliance requires infra ownership | Yes -- compliance-mandated control |
| Measured cost 3x+ at sustained load | Yes -- cost optimization at scale |
| Cold start tolerance low | No -- mitigate with provisioned concurrency or edge platform |
| Team lacks serverless experience | No -- invest in learning, not in adding ops burden |
| Vendor portability critical | No -- use portable serverless patterns (e.g., container-based Lambda, standard APIs) |

This makes the table a decision tool rather than a comparison chart.

## Proposed Tasks

### Task 1: Update AGENT.md Identity and Step 0

**File**: `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md`

Changes:
- Line 17: Replace identity line per recommendation (d)
- Lines 166-188: Restructure Step 0 per recommendations (a), (b), (c):
  - Replace opening framing statement
  - Replace 10-dimension flat list with Tier 1 blocking concern gate + Tier 2 validation dimensions
  - Replace four equal-weight topology recommendations with serverless-default cascade

### Task 2: Update RESEARCH.md Decision Framework

**File**: `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/RESEARCH.md`

Changes:
- Line 493: Replace neutrality statement per recommendation (e)
- Lines 497-508: Restructure evaluation criteria table from three-column comparison to blocking-concern detector format
- Lines 510-516: Update decision process steps to reflect serverless-first cascade

### Task 3: Update the-plan.md Spec (requires human approval)

**File**: `/Users/ben/github/benpeter/2despicable/4/the-plan.md`

Changes (subject to human owner approval per project rules):
- Line 740: Update "Deployment strategy selection" description to say "serverless-first deployment strategy selection"
- Lines 753-755: Update research focus to replace "serverless vs. container decision criteria, when serverless is inappropriate" with "serverless-first decision framework, blocking concerns that require deviation from serverless (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale)"

**Note**: `the-plan.md` is human-edited. This task should be flagged for human review and approval before execution.

### Task 4: Bump Versions

- Bump `spec-version` in `the-plan.md` (pending human approval)
- Bump `x-plan-version` in `AGENT.md` to match
- Update `x-build-date` to current date

## Risks and Concerns

### Risk 1: Over-rotation -- Treating Serverless as Dogma

The serverless-first framing could be misinterpreted as "serverless always." The blocking concern escape hatches are load-bearing and must be preserved with equal prominence to the default. The agent must not dismiss legitimate blocking concerns to stay serverless.

**Mitigation**: The Tier 1 blocking concern gate is checked *first*, before the default applies. The framing is "start serverless, check for blockers" not "use serverless regardless."

### Risk 2: Cost Blocker Requires "Measured" Data -- Cold Start Problem

The cost optimization blocker requires measured data, but new projects have no measured data. This could create a situation where a project starts serverless, accumulates cost, and only then discovers it should have been containerized.

**Mitigation**: The Tier 2 validation dimensions include "scale pattern" and "cost at projected scale." These inform the implementation (e.g., choosing a cost-efficient serverless platform, setting concurrency limits) without overriding the default. For genuinely high-scale workloads with committed volume, the cost blocker can be triggered with contractual commitments (e.g., "we have a signed contract for 10M requests/day") even without historical data.

### Risk 3: the-plan.md Modification Requires Human Approval

Task 3 cannot proceed without explicit human owner approval per project rules ("Do NOT modify the-plan.md unless you are the human owner or the human owner approves").

**Mitigation**: Flag Task 3 as requiring human approval. Tasks 1 and 2 can proceed independently since AGENT.md and RESEARCH.md are agent-generated artifacts.

### Risk 4: Coordination with edge-minion

The serverless platform landscape (which platform for which workload) is edge-minion's domain. The restructured Step 0 says "select platform based on workload profile (edge-minion advises on platform)" -- this handoff must be clearly defined so there's no gap where iac-minion picks a topology but nobody picks a platform.

**Mitigation**: Ensure edge-minion's contribution covers the platform selection that follows iac-minion's topology decision. The boundary is: iac-minion decides "serverless" (or escalates); edge-minion advises "which serverless platform."

## Additional Agents Needed

- **lucy** -- Governance review to ensure the serverless-first framing is consistently applied across all agents that reference deployment topology (not just iac-minion). Other agents may have language that implies topology neutrality.
- **margo** -- YAGNI/KISS review to validate that the restructured Step 0 doesn't become more complex than the old version. The blocking concern gate should be simpler to apply than the old 10-dimension evaluation, not harder.
