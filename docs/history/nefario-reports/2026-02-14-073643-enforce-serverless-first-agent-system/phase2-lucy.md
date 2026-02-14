# Phase 2: Lucy -- Template Design, Governance Checking, and Cross-Document Consistency

**Planning question**: How should the CLAUDE.md template, governance review mechanics, and related documentation change to encode serverless-first as the strong default?

---

## Analysis

### Context: The Policy Shift

The previous advisory (2026-02-13-110715-serverless-bias-correction) established that serverless-first preferences belong in the target project's CLAUDE.md, not in agent AGENT.md files. That advisory was topology-neutral by design -- agents stay generic, projects declare preferences. The current task goes further: the agent system itself should encode serverless-first as the **default stance**, not just a user-configurable option. This is a meaningful shift. The template moves from "here are equal options, pick one" to "here is the default, deviate with justification."

This shift is grounded in two Helix Manifesto principles:
- **Lean and Mean** -- serverless eliminates infrastructure management overhead
- **Ops reliability wins** -- managed platforms handle scaling, patching, uptime

The shift is also bounded by four documented blocking concerns that are the ONLY legitimate reasons to deviate.

### Publishability Tension

The previous advisory explicitly warned against making agents opinionated (Apache 2.0 publishability). The current approach threads this needle correctly: the **template** (a documentation artifact that projects adopt voluntarily) encodes the default, not the agent AGENT.md files. A template with a strong default is still a recommendation -- projects are not forced to adopt it. This is architecturally sound and preserves agent genericity.

---

## Answers to Specific Questions

### (a) "When to omit this section" guidance

**Current state**: Omission means "agents recommend an approach" -- topology-neutral.

**Proposed change**: Omission means "serverless is the default deployment approach." The guidance should make this explicit:

> Most projects do not need a Deployment section. You should omit it entirely if:
>
> - You are deploying to serverless/managed platforms (the system default).
> - Your project already contains infrastructure artifacts (`wrangler.toml`, `vercel.json`, `netlify.toml`, serverless framework configs, etc.) that confirm the serverless approach.
> - You are early in development and have no blocking reason to deviate from serverless.
>
> When no Deployment section exists, agents default to serverless/managed platforms and select the best fit for your workload (e.g., Cloudflare Workers, Vercel, AWS Lambda). Existing infrastructure files in your repository serve as implicit signals -- agents read them and factor them into recommendations without needing explicit prose.
>
> **Add this section only when you need to deviate from the serverless default** -- because you have blocking concerns (persistent connections, long-running processes, compliance-mandated control, or proven cost optimization at scale) or because you have existing non-serverless infrastructure that agents should respect.

Key changes:
1. The bullet list shifts from "no strong preference" to "deploying serverless (the default)."
2. The infrastructure artifact examples shift from Docker-heavy to serverless-config-heavy (keeping Docker artifacts as signals of deviation, not of alignment).
3. The "only add this section when" framing inverts from "when you have preferences" to "when you need to deviate."

### (b) Example changes -- deviation framing for non-serverless

**Current state**: Three examples (serverless, self-managed, general preference) presented as equals.

**Proposed change**: Restructure examples into two groups: "confirming the default" and "deviating from the default."

**Confirming the default** (minimal or specific serverless):

The "Minimal" and "Specific platform (serverless)" examples stay largely as-is, but gain a framing note:

> These examples confirm the serverless default with additional specificity. They are optional -- omitting the section entirely produces the same behavior.

**Deviating from the default** (self-managed, hybrid):

The self-managed example should explicitly show the "deviation because" framing:

```markdown
## Deployment

We deploy on a Hetzner VPS using Docker Compose. Deviation from serverless
default: the application requires persistent WebSocket connections for
real-time collaboration, and our existing Terraform + GitHub Actions pipeline
is already production-proven.
```

The "Mixed infrastructure" example should show partial deviation:

```markdown
## Deployment

Stateless APIs and frontends deploy to Cloudflare Workers (serverless default).
Stateful services (Postgres, Redis) run on a Hetzner VPS with Docker Compose.
Deviation for stateful tier: persistent connections and data residency
requirements.
```

The "General preference" example should be rewritten to align with the new framing. The current version ("keep deployments simple -- prefer managed platforms") is close to the serverless default already, so it can become a confirming example or be removed to avoid redundancy.

**Important**: The word "deviation" should appear in every non-serverless example. This is not punitive -- it is a signal to the reviewing agent (lucy) that the choice was deliberate, not accidental.

### (c) "What this section is not" paragraph

**Current state**: "The Deployment section is not an infrastructure blueprint or a binding contract."

**Proposed change**: Add one sentence acknowledging the default relationship:

> The Deployment section is not an infrastructure blueprint or a binding contract. When present, it overrides or refines the system's serverless default -- it tells agents where you are starting from so they can meet you there. When absent, agents default to serverless/managed platforms appropriate for your workload.

This reinforces the mental model: absence = serverless default; presence = override.

### (d) Governance-level enforcement -- lucy's review checklist

**Yes, I should check that non-serverless choices have documented blocking concerns.** This adds a new item to my plan review checklist:

**New COMPLIANCE check**: When a plan proposes non-serverless infrastructure and the project's CLAUDE.md does not contain a Deployment section with documented deviation rationale, flag it as a COMPLIANCE finding:

- If the project has no Deployment section: the plan should use serverless unless the workload has a documented blocking concern (persistent connections, long-running processes >30s, compliance-mandated control, proven cost optimization at scale).
- If the project has a Deployment section with non-serverless choice but no deviation rationale: flag as ADVISE (non-blocking) requesting the rationale be documented.
- If the project has a Deployment section with documented deviation rationale tied to a legitimate blocking concern: APPROVE.

This check applies only when infrastructure decisions are part of the plan. Pure frontend, documentation, or non-deployment tasks are unaffected.

**Severity**: ADVISE, not BLOCK. A missing rationale is a documentation gap, not a security or correctness issue. The plan can proceed, but the rationale should be added. Only a plan that proposes self-hosted infrastructure in direct contradiction to a CLAUDE.md "serverless-first" directive would warrant BLOCK.

### (e) Cross-document consistency audit

I checked the following documents for topology-neutral or criteria-driven framing that would become inconsistent:

#### `docs/claudemd-template.md` (PRIMARY TARGET)
- Lines 9-15: "no strong preference" / "agents recommend an approach" -- must change per (a) above.
- Lines 26-28: HTML comment says "agents will recommend an approach" -- must change to "agents default to serverless."
- Lines 40-92: Examples section -- must restructure per (b) above.
- Lines 94-96: "What this section is not" -- must update per (c) above.

#### `docs/agent-catalog.md`
- No topology-neutral or criteria-driven references. The iac-minion description (line 117-123) says "serverless platforms, and deployment automation" and "deployment strategy selection" which is compatible with serverless-first. **No changes needed.**

#### `docs/architecture.md`
- No topology-neutral references. The cross-cutting concerns section (lines 111-121) does not mention deployment topology. **No changes needed.**

#### `docs/decisions.md`
- No topology-neutral deployment references. Decision 29 (CLAUDE.md section convention) is compatible -- it describes the configuration mechanism, not the default content. **No changes needed.**

#### `minions/iac-minion/AGENT.md` (line 17)
- "You are topology-neutral: you evaluate workloads against criteria and recommend the best-fit deployment model" -- this is the iac-minion's identity statement. **This MUST change** to reflect serverless-first default. Something like: "Your default recommendation is serverless/managed platforms. You evaluate workloads against criteria and deviate to containerized or self-managed only when blocking concerns exist (persistent connections, long-running processes, compliance-mandated control, proven cost at scale)."

#### `minions/iac-minion/AGENT.md` (lines 166-188)
- "Step 0: Deployment Strategy Selection" -- "This decision must be criteria-driven, not preference-driven. No default to any topology." This directly contradicts the new requirement. **Must change** to establish serverless as default with criteria-driven deviation.
- The "Topology recommendation" section (lines 182-186) lists serverless/containers/self-managed/hybrid as equal options. **Must restructure** to present serverless as default with the others as justified deviations.

#### `margo/AGENT.md` (lines 252-270)
- "Boring Technology Assessment (Topology-Neutral)" heading and content. The boring technology criteria themselves are fine -- they remain topology-neutral. But the heading and framing should not contradict the serverless-first default. The assessment is about whether a technology is "boring" (mature, documented, staffable), not about which topology to prefer. **Heading can stay** -- "topology-neutral" in this context means "the boring test applies equally to all topologies," which is still true. The boring test does not favor or disfavor serverless; the serverless-first default is a separate concern. **No change needed** -- these are orthogonal. A serverless platform can be boring (Lambda, 2014) or not (a new FaaS platform). The assessment criteria apply regardless.

#### `margo/RESEARCH.md` (lines 553-555)
- "boring technology criteria must be applied topology-neutrally" -- same analysis as above. This is about the boring test, not about deployment preference. **No change needed.**

#### `docs/history/nefario-reports/` (various)
- Historical reports documenting the topology-neutral framing from the serverless-bias-correction advisory. These are historical records and **must not be modified**. They accurately capture what was decided at that time. The current task represents a deliberate policy evolution from that decision.

---

## Recommendations

1. **Rewrite `docs/claudemd-template.md`** per the detailed answers in (a), (b), (c) above. This is the primary deliverable.

2. **Update `minions/iac-minion/AGENT.md`** lines 17 and 166-188 to replace topology-neutral framing with serverless-first default. The criteria evaluation framework stays, but the starting position changes from "no default" to "default serverless, deviate with justification."

3. **Add serverless-first compliance check to lucy's review behavior.** This does not require AGENT.md changes if the check is encoded in the target project's CLAUDE.md (which I already enforce). If the check should apply even without explicit CLAUDE.md directive, then lucy's AGENT.md needs a new item in the "Common CLAUDE.md Directives to Check" or "Working Patterns" section.

4. **Do NOT modify margo's boring technology assessment.** The topology-neutral framing there is about boring-test criteria, not deployment preference. Making margo's boring test serverless-biased would be analytically wrong.

5. **Do NOT modify historical reports.** They are accurate records of prior decisions.

6. **Add a Decision 31 entry to `docs/decisions.md`** documenting this policy shift from topology-neutral to serverless-first-default, what it supersedes, and why.

---

## Proposed Tasks

1. **Rewrite CLAUDE.md template** (`docs/claudemd-template.md`) -- rewrite "When to omit," examples, "What this section is not," and HTML comment in the template block. ~30-40 lines changed.

2. **Update iac-minion AGENT.md** -- change identity statement (line 17) and Step 0 (lines 166-188) from topology-neutral to serverless-first-default. Keep the 10-dimension criteria evaluation but reframe as deviation criteria.

3. **Update iac-minion the-plan.md spec** -- the spec should reflect the serverless-first default so that future rebuilds produce the correct AGENT.md. (Check with nefario whether the-plan.md is in scope per CLAUDE.md rules.)

4. **Add Decision 31 to `docs/decisions.md`** -- document the shift from topology-neutral (Decisions implicit in the 2026-02-13 advisory) to serverless-first-default.

5. **Update lucy AGENT.md** (if governance check should apply system-wide, not just per-project CLAUDE.md) -- add serverless-first compliance check to review checklist.

---

## Risks and Concerns

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Publishability regression**: Encoding serverless-first in iac-minion's AGENT.md makes a published agent opinionated. Users with on-prem or self-managed needs may find the default unhelpful. | MEDIUM | The previous advisory explicitly warned against this. The mitigation is that the default is a starting position, not a hard constraint. The 10-dimension criteria evaluation and documented blocking concerns provide escape hatches. Frame as "start here, deviate when justified" not "always do this." |
| **Contradiction with previous advisory**: The 2026-02-13 serverless-bias-correction advisory explicitly chose topology-neutral framing. This task reverses that decision. Without a clear Decision record, future reviewers will find contradictory guidance. | HIGH | Decision 31 in decisions.md must explicitly state that this supersedes the topology-neutral stance from the advisory, with rationale for the change. Historical reports remain unmodified. |
| **Over-enforcement by lucy**: If lucy's serverless-first check is too aggressive (BLOCK instead of ADVISE), it could slow down legitimate self-hosted proposals. | LOW | Severity is ADVISE for missing rationale, BLOCK only for direct contradiction of CLAUDE.md. This is consistent with existing enforcement patterns. |
| **iac-minion Step 0 becomes biased assessment**: If the 10-dimension criteria evaluation is reframed with a serverless default, the evaluation may skip genuine analysis and rubber-stamp serverless. | MEDIUM | Keep the full 10-dimension evaluation. The default changes the starting recommendation, not the evaluation process. If criteria point to self-managed (e.g., dimension 1 shows >30s execution), the evaluation overrides the default. |
| **Template framing feels heavy-handed**: Requiring "deviation" language in non-serverless examples may feel bureaucratic to users who simply prefer Docker. | LOW | The word "deviation" is an internal signal, not a mandate. Users can write their Deployment section however they want -- the examples are suggestions, not syntax requirements. |

---

## Additional Agents Needed

None beyond what is already planned. The template rewrite is a documentation task (software-docs-minion or devx-minion). The iac-minion AGENT.md changes require understanding the spec-to-build pipeline (use /despicable-lab or manual edit). Lucy AGENT.md changes are self-referential and should be reviewed by margo for scope appropriateness.
