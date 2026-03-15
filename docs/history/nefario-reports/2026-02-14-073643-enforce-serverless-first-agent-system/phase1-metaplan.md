# Meta-Plan: Enforce Serverless-First Stance Across Agent System

## Context

PR #123 on branch `nefario/fix-serverless-bias-correction` (6 commits ahead of main) completed the first phase: it added serverless knowledge to iac-minion, introduced a two-column complexity budget to margo, added delegation table rows, and created a CLAUDE.md template. That work was explicitly **topology-neutral** -- it corrected a structural anti-serverless bias by making the system evaluate all topologies on equal criteria.

The task now is to go further: enforce a **serverless-first stance** where serverless is the strong default and deviation requires justification. This is a framing shift, not a knowledge gap fix. The current language says "criteria-driven, not preference-driven. No default to any topology." The target language says "serverless unless blocked."

### Key Files Requiring Changes

1. **`the-plan.md`** (iac-minion spec, lines 726-757): Identity line says "topology-neutral"; Step 0 says "criteria-driven, not preference-driven. No default to any topology"; topology recommendation presents four options as equals.
2. **`the-plan.md`** (margo spec, lines 539-574): Complexity budget scores managed/serverless lower but does not actively penalize self-managed when serverless is viable.
3. **`minions/iac-minion/AGENT.md`** (built agent, line 17): Identity says "topology-neutral"; Step 0 (line 168) repeats the neutral framing.
4. **`margo/AGENT.md`** (built agent): Two-column budget exists but no active penalty for unnecessary self-managed infra.
5. **`docs/claudemd-template.md`**: Currently topology-neutral with equal examples. Needs to encode serverless-first as the strong default.
6. **`minions/iac-minion/RESEARCH.md`** (line 493): Says "The decision must be neutral -- no default to any topology."

### The Publishability Tension

The prior advisory (phase 2, lucy) explicitly warned: "Making a generic published agent opinionated about serverless-first violates the 'generic domain specialists' design principle." The task description addresses this directly: agents must remain **usable** for non-serverless work, but the **preference is strong**. The framing is "why NOT serverless?" (justify deviation), not "serverless or die." This is a legitimate design choice the owner is making for their published system -- the Helix Manifesto's "lean and mean" and "ops reliability wins" principles provide the philosophical anchor.

## Planning Consultations

### Consultation 1: iac-minion Step 0 Redesign

- **Agent**: iac-minion
- **Model**: opus
- **Planning question**: Your Step 0 currently says "criteria-driven, not preference-driven. No default to any topology." The new framing is: "Start with serverless. The first question is 'can this be done serverless without blocking concerns?' If yes, serverless. If no, document which blocking concern (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale) drives the deviation." How should Step 0 be restructured to encode this? Specifically: (a) What should the opening framing statement replace "criteria-driven, not preference-driven" with? (b) Should the 10-dimension evaluation checklist stay as-is (used to validate blocking concerns) or be restructured as a "blocking concern detector"? (c) How should the topology recommendation section change from four equal options to serverless-default with escalation? (d) Your identity line says "topology-neutral" -- what should it say instead?
- **Context to provide**: Current iac-minion spec (the-plan.md lines 726-757), current AGENT.md Step 0 (lines 164-188), the Helix Manifesto principles ("lean and mean", "ops reliability wins"), the blocking concerns list (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale).
- **Why this agent**: iac-minion is the primary agent being changed. Its self-assessment is critical for getting the framing right without making the agent dysfunctional for legitimate non-serverless work.

### Consultation 2: Margo Complexity Budget Enforcement

- **Agent**: margo
- **Model**: opus
- **Planning question**: Your two-column complexity budget already scores self-managed higher than managed/serverless. The new requirement is that you **actively penalize** self-managed infrastructure when a serverless alternative exists without blocking concerns. This means: when reviewing a plan that proposes containers or VMs, you should ask "why not serverless?" and require a documented blocking concern (not just "the team prefers Docker" or "we already know Terraform"). How should this be encoded? Specifically: (a) Should this be a new detection pattern (like "Unnecessary Infrastructure Detection") or a modification to the existing budget? (b) What language makes this a strong preference without making margo unable to approve legitimate non-serverless plans? (c) How does this interact with your "Flag disproportion, not topology" framing rule? That rule was designed for neutrality -- does it need to change?
- **Context to provide**: Current margo spec (the-plan.md lines 539-574), current AGENT.md complexity budget (lines 53-84) and framing rules (lines 306-316), the blocking concerns list, the Helix Manifesto anchor.
- **Why this agent**: Margo is the enforcement mechanism. If margo's heuristics don't actively penalize unnecessary self-managed infrastructure, the serverless-first stance has no teeth during architecture review.

### Consultation 3: CLAUDE.md Template Redesign

- **Agent**: lucy
- **Model**: opus
- **Planning question**: The CLAUDE.md template (`docs/claudemd-template.md`) is currently topology-neutral -- it says "agents recommend an approach" when no section exists, and presents serverless, self-managed, and general preference examples as equals. The new requirement is that the template encodes serverless-first as the strong default. When a project has no Deployment section, the system should default to serverless (not "recommend an approach"). When a project has a Deployment section, it should be framed as "we deploy on X (deviation from serverless default because: Y)." How should the template change? Specifically: (a) What should the "When to omit this section" guidance say now that omission means "use serverless default"? (b) How should the examples change? (c) Does the "What this section is not" paragraph need updating? (d) How do you enforce this at governance level -- when reviewing a plan, do you check that non-serverless choices have documented blocking concerns?
- **Context to provide**: Current template (`docs/claudemd-template.md`), lucy's prior advisory analysis (publishability, enforceability), the blocking concerns list, the Helix Manifesto anchor.
- **Why this agent**: Lucy governs CLAUDE.md compliance and intent alignment. The template change is a convention design question -- lucy's domain. Lucy also needs to know how to enforce the new default during architecture review.

## Cross-Cutting Checklist

- **Testing** (test-minion): **Include for planning.** The changes are to spec files and markdown, not code, but test-minion should define verification criteria: how do we confirm the framing shift actually works? What does a "before/after" test scenario look like for iac-minion's Step 0? test-minion contributed useful calibration criteria in the prior round that were adopted.
  - **Planning question**: Given that we are shifting iac-minion from "topology-neutral" to "serverless unless blocked" and margo from "score honestly" to "actively penalize unnecessary self-managed", what verification scenarios should we define? Design 2-3 dry-run scenarios with expected outcomes that confirm the framing shift works without breaking legitimate non-serverless cases.

- **Security** (security-minion): **Exclude from planning.** No new attack surface, no auth changes, no user input handling. The prior round's security advisory (add serverless security patterns) was already incorporated. The framing shift does not change security posture.

- **Usability -- Strategy** (ux-strategy-minion): **Include for planning (ALWAYS).** The framing shift changes the developer journey: "evaluate options" becomes "use serverless, justify deviations." This is a cognitive model change.
  - **Planning question**: The current developer journey is: encounter deployment task -> iac-minion evaluates 10 criteria -> recommends topology. The proposed journey is: encounter deployment task -> iac-minion checks for blocking concerns -> uses serverless (or documents why not). How does this change cognitive load? Is the "blocking concerns" framing (persistent connections, long-running processes, compliance, cost at scale) the right set of escape hatches, or are there common legitimate deviations missing? Is the shift from "which fits?" to "why not serverless?" a simplification or a different kind of complexity?

- **Usability -- Design** (ux-design-minion, accessibility-minion): **Exclude from planning.** No UI components produced. This is spec and documentation work.

- **Documentation** (software-docs-minion): **Include for planning (ALWAYS).** The CLAUDE.md template is a documentation artifact. `docs/architecture.md` may need a note about the serverless-first stance. The framing shift should be reflected in any docs that reference "topology-neutral."
  - **Planning question**: Which documentation artifacts beyond the CLAUDE.md template reference "topology-neutral" or "criteria-driven" framing that would become inconsistent after this change? Should `docs/architecture.md` mention the serverless-first design philosophy? What documentation changes are needed to make the framing shift discoverable to new contributors?

- **Observability** (observability-minion, sitespeed-minion): **Exclude from planning.** No runtime components produced.

## Anticipated Approval Gates

1. **iac-minion Step 0 rewrite** (MUST gate): High blast radius -- every downstream deployment task routes through Step 0. Hard to reverse -- the framing language shapes all agent recommendations. This is the most consequential change.

2. **margo enforcement mechanism** (MUST gate): High blast radius -- margo reviews every plan in Phase 3.5. The penalty mechanism determines whether the serverless-first stance has enforcement teeth or is aspirational.

3. **CLAUDE.md template** (OPTIONAL gate): Medium blast radius -- affects target projects, not the agent system itself. Easy to reverse -- template is documentation. Gate only if the framing is ambiguous.

## Rationale

**Why these specialists and not others:**

- **iac-minion** is the primary agent being changed. It must self-assess how to shift from neutral to serverless-first without becoming dysfunctional.
- **margo** is the enforcement mechanism. Without margo's active penalty, the stance is aspirational.
- **lucy** governs CLAUDE.md and intent alignment. The template redesign is her domain, and she needs to know how to enforce the new default.
- **test-minion** defines verification criteria. The prior round's test-minion contribution (calibration examples, measurable criteria) was valuable and should be repeated.
- **ux-strategy-minion** reviews the developer journey change. Shifting from "evaluate" to "justify deviation" is a cognitive model change worth validating.
- **software-docs-minion** ensures documentation consistency across the system.

**Why NOT these specialists:**

- **gru**: Technology maturity assessment was done in the advisory round. The serverless platforms are already classified (Lambda ADOPT, Workers ADOPT, Vercel TRIAL). No new technology decisions here.
- **edge-minion**: Boundaries were clarified in the prior round. No boundary changes needed.
- **devx-minion**: DX perspective was captured in the advisory round (50:1 TTFD penalty, escalation path). The framing shift does not change DX boundaries.
- **security-minion**: No new security surface. Prior advisory recommendations already incorporated.
- **ai-modeling-minion**: No prompt engineering novelty. The framing change is conceptual, not structural.

## Scope

**In scope:**
- `the-plan.md` iac-minion spec: reframe Step 0 from neutral to serverless-first, update identity line, update topology recommendation section
- `the-plan.md` margo spec: add active penalty for unnecessary self-managed infrastructure
- `docs/claudemd-template.md`: reframe from neutral to serverless-first default
- Agent rebuilds via `/despicable-lab` for iac-minion and margo (and nefario delegation table if affected)
- Any framing language in RESEARCH.md files that says "topology-neutral" or "no default to any topology"
- Documentation consistency across `docs/` for references to the old framing

**Out of scope:**
- Delegation table changes (already correct from PR #123)
- Edge-minion boundaries (already correct from PR #123)
- New agents
- Creating a new PR (append to PR #123)
- Deleting remote branches
- Changes to the Helix Manifesto or its interpretation

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | ORCHESTRATION | Agent rebuild from specs | Use as DEFERRED task for rebuilding iac-minion and margo after spec changes |
| despicable-prompter | `.claude/skills/despicable-prompter/` | LEAF | Briefing coach | Not relevant to this task |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant to this task |

### Precedence Decisions

No conflicts. `despicable-lab` is the canonical tool for rebuilding agents from `the-plan.md` specs. It was used in the prior execution (PR #123 Task 7) and will be used again here.
