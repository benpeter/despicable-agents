# Phase 5: margo Complexity Review

**Verdict: ADVISE**

The changes are broadly proportional to the spec changes and solve a real problem (topology-neutral complexity assessment, iac-minion deployment strategy coverage). Three findings are non-blocking but worth addressing.

---

## Finding 1: iac-minion Deployment Strategy Selection -- 10-dimension checklist is over-specified

**File**: `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md`, lines 170-188 (Step 0: Deployment Strategy Selection)

**What is complex**: The 10-dimension evaluation list (execution duration, state requirements, traffic pattern, latency sensitivity, scale pattern, team expertise, existing infrastructure, cost at projected scale, vendor portability, compliance/data residency) followed by a 4-option topology recommendation matrix.

**Why it appears accidental**: The spec in `the-plan.md` (line 740) says: "Deployment strategy selection (evaluating serverless vs. container vs. self-managed for a given workload)." That is one line. The AGENT.md inflates it into a 20-line structured evaluation framework with numbered dimensions. In practice, an agent given the high-level instruction "evaluate the workload against criteria and recommend the best-fit deployment model" will already consider relevant factors -- it does not need a prescriptive 10-item checklist to do so. The checklist risks becoming a rote procedure the agent walks through mechanically rather than applying judgment.

**Simpler alternative**: Collapse Step 0 into a shorter directive:

```
Before designing infrastructure, evaluate the workload to select the right
deployment topology. Consider execution duration, state, traffic pattern,
latency requirements, team expertise, existing infrastructure, cost, and
compliance constraints. Recommend a topology (serverless, container,
self-managed, or hybrid) with rationale tied to workload characteristics,
not platform preferences.
```

This preserves all the signal dimensions without the numbered-list rigidity. The RESEARCH.md already contains the detailed evaluation table (lines 491-518) for the agent to draw on when needed.

**Severity**: Low. The 10-dimension list is not wrong, just more prescriptive than necessary. The agent will produce reasonable recommendations with or without the rigid structure.

---

## Finding 2: margo two-column budget adds moderate value but could be leaner

**File**: `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md`, lines 53-85 (Complexity Budget section)

**What is complex**: The two-column budget table (self-managed vs. managed/serverless) with accompanying explanation paragraphs, shared vocabulary definitions, and the "Boring Technology Assessment (Topology-Neutral)" section (lines 252-270). Combined, these add approximately 50 lines to the AGENT.md.

**Why it appears partially accidental**: The two-column table itself is a clean, useful addition -- it prevents margo from unfairly penalizing managed services at the same complexity cost as self-managed ones. That is a real problem worth solving. However, the surrounding prose explaining *why* scores differ ("Self-managed column: team operates the infrastructure -- patching, scaling, monitoring, availability. Managed/serverless column: provider absorbs operational burden...") is explaining the obvious. The shared vocabulary section (self-managed / managed / serverless definitions) is definitional content that does not need to live in the agent prompt -- anyone using these terms understands them.

**Simpler alternative**: Keep the table and the "What stays the same" paragraph. Remove the per-column explanation paragraphs and the shared vocabulary section. The table is self-documenting -- "Self-Managed" and "Managed/Serverless" as column headers communicate the distinction. Save roughly 15 lines.

**Severity**: Low. The content is accurate and not harmful, just slightly verbose for what it conveys. The AGENT.md grew from 274 to 391 lines (+43%), but the spec version only bumped from 1.0 to 1.1. The growth is within acceptable range for the scope of the change, though trimming the explanatory prose would improve signal density.

---

## Finding 3: CLAUDE.md template is well-scoped but redundant with agent behavior

**File**: `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md` (new file, 101 lines)

**What is complex**: A new documentation file providing a template and five examples for adding a `## Deployment` section to a target project's CLAUDE.md.

**Why it may be accidental**: The template itself is one sentence: "We deploy on [platform/approach]." The remaining 90+ lines are examples, anti-examples, and meta-explanation ("What this section is not," "When to omit this section," "Discoverability"). The document correctly notes that most projects do not need this section and that agents will infer deployment context from existing files. Given that, the file optimizes for a minority case.

**Assessment**: This is borderline. The file is well-written, clearly scoped, and explicitly tells users when *not* to use it. The examples are genuinely helpful for users who do need the section. It does not introduce code complexity, runtime cost, or dependencies. The concern is documentation bloat -- adding a file that most users are told to ignore. However, documentation for an open-source project has different economics than code. The file is discoverable, low-maintenance, and does not create ongoing burden.

**Recommendation**: Keep as-is. The file's value comes from preventing overspecification in target projects (users who would otherwise write 50-line deployment sections now see that one sentence suffices). That is a net simplicity gain across the ecosystem even if the template file itself costs 101 lines.

**Severity**: Informational only. No action needed.

---

## Finding 4: edge-minion changes are proportional

**File**: `/Users/ben/github/benpeter/2despicable/4/minions/edge-minion/AGENT.md` (+5 lines)

The edge-minion AGENT.md changes add boundary clarification for full-stack serverless platforms (Cloudflare Workers/Pages, Vercel, Netlify) -- specifically which aspects are edge-minion scope vs. iac-minion scope. The spec at `the-plan.md` lines 776-779 mandates this distinction. The AGENT.md growth (+5 lines) is proportional to the spec change (~10 lines). The RESEARCH.md adds 20 lines of platform boundary examples, which directly back the AGENT.md content.

**Assessment**: No concerns. The changes are minimal and well-justified.

---

## Summary

| Finding | File | Severity | Action |
|---------|------|----------|--------|
| 10-dimension deployment checklist | iac-minion/AGENT.md | Low | Consider condensing to prose paragraph |
| Two-column budget explanatory prose | margo/AGENT.md | Low | Consider trimming definitional content |
| CLAUDE.md template | docs/claudemd-template.md | Informational | Keep as-is |
| edge-minion boundary clarification | edge-minion/AGENT.md | None | No action |

**Overall**: The changes solve a real problem (topology-neutral assessment) and the AGENT.md growth is broadly proportional to the spec changes. The iac-minion deployment strategy checklist is the most over-specified element, but it is non-blocking -- the agent will function well with or without the rigid 10-item structure. No blocking issues found.
