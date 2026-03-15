# Meta-Plan: Enforce Serverless-First Stance Across Agent System (Revised)

## Context

PR #123 on branch `nefario/fix-serverless-bias` (6 commits ahead of main) completed the first phase: it added serverless knowledge to iac-minion, introduced a two-column complexity budget to margo, added delegation table rows, and created a CLAUDE.md template. That work was explicitly **topology-neutral** -- it corrected a structural anti-serverless bias by making the system evaluate all topologies on equal criteria.

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

### Team Adjustment Rationale

The revised team is: **iac-minion, margo, lucy, edge-minion**.

Changes from original:
- **Removed**: ux-strategy-minion (the developer journey change is straightforward enough that margo's simplification lens and lucy's intent alignment cover it), software-docs-minion (documentation consistency can be handled as part of execution, not planning), test-minion (verification scenarios can be defined during synthesis without dedicated planning input).
- **Added**: edge-minion (brings platform-specific expertise on serverless edge platforms -- Cloudflare Workers/Pages, Vercel, Netlify -- which are central to the serverless-first default. Edge-minion knows the capabilities and constraints of these platforms from the runtime side, complementing iac-minion's deployment perspective).

## Planning Consultations

### Consultation 1: iac-minion Step 0 Redesign

- **Agent**: iac-minion
- **Model**: opus
- **Planning question**: Your Step 0 currently says "criteria-driven, not preference-driven. No default to any topology." The new framing is: "Start with serverless. The first question is 'can this be done serverless without blocking concerns?' If yes, serverless. If no, document which blocking concern (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale) drives the deviation." How should Step 0 be restructured to encode this? Specifically: (a) What should the opening framing statement replace "criteria-driven, not preference-driven" with? (b) Should the 10-dimension evaluation checklist stay as-is (used to validate blocking concerns) or be restructured as a "blocking concern detector"? (c) How should the topology recommendation section change from four equal options to serverless-default with escalation? (d) Your identity line says "topology-neutral" -- what should it say instead? (e) The RESEARCH.md (line 493) says "The decision must be neutral -- no default to any topology" -- what should this become? Note: edge-minion is also being consulted on the serverless platform landscape. Your recommendations should focus on the decision framework and Step 0 structure, not on enumerating platform capabilities.
- **Context to provide**: Current iac-minion spec (the-plan.md lines 726-757), current AGENT.md Step 0 (lines 164-188), the Helix Manifesto principles ("lean and mean", "ops reliability wins"), the blocking concerns list (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale).
- **Why this agent**: iac-minion is the primary agent being changed. Its self-assessment is critical for getting the framing right without making the agent dysfunctional for legitimate non-serverless work.

### Consultation 2: Margo Complexity Budget Enforcement

- **Agent**: margo
- **Model**: opus
- **Planning question**: Your two-column complexity budget already scores self-managed higher than managed/serverless. The new requirement is that you **actively penalize** self-managed infrastructure when a serverless alternative exists without blocking concerns. This means: when reviewing a plan that proposes containers or VMs, you should ask "why not serverless?" and require a documented blocking concern (not just "the team prefers Docker" or "we already know Terraform"). How should this be encoded? Specifically: (a) Should this be a new detection pattern (like "Unnecessary Infrastructure Detection") or a modification to the existing budget? (b) What language makes this a strong preference without making margo unable to approve legitimate non-serverless plans? (c) How does this interact with your "Flag disproportion, not topology" framing rule? That rule was designed for neutrality -- does it need to change to accommodate the serverless-first stance, or can it coexist? (d) Your current framing rule #3 says "Ask 'is this complexity justified?' not 'is this the right platform?'" -- under the new stance, margo IS partially asking about platform when the answer might be "serverless is simpler." How do you reconcile this without overstepping into gru's domain? Note: this enforcement is the mechanism that gives the serverless-first stance teeth. Without it, the stance is aspirational. Lucy is being consulted on CLAUDE.md and governance enforcement separately.
- **Context to provide**: Current margo spec (the-plan.md lines 539-574), current AGENT.md complexity budget (lines 53-84) and framing rules (lines 304-316), the blocking concerns list, the Helix Manifesto anchor.
- **Why this agent**: Margo is the enforcement mechanism. If margo's heuristics don't actively penalize unnecessary self-managed infrastructure, the serverless-first stance has no teeth during architecture review.

### Consultation 3: CLAUDE.md Template and Governance Enforcement

- **Agent**: lucy
- **Model**: opus
- **Planning question**: The CLAUDE.md template (`docs/claudemd-template.md`) is currently topology-neutral -- it says "agents recommend an approach" when no section exists, and presents serverless, self-managed, and general preference examples as equals. The new requirement is that the template encodes serverless-first as the strong default. When a project has no Deployment section, the system should default to serverless (not "recommend an approach"). When a project has a Deployment section, it should be framed as "we deploy on X (deviation from serverless default because: Y)." How should the template change? Specifically: (a) What should the "When to omit this section" guidance say now that omission means "use serverless default"? (b) How should the examples change -- should the self-managed example explicitly show the "deviation because" framing? (c) Does the "What this section is not" paragraph need updating? (d) How do you enforce this at governance level -- when reviewing a plan, do you check that non-serverless choices have documented blocking concerns? (e) Which documentation artifacts beyond the template reference "topology-neutral" or "criteria-driven" framing that would become inconsistent? (This last question absorbs the documentation consistency concern that software-docs-minion would have addressed.) Note: margo is being consulted on enforcement mechanics. Your focus should be on template design, governance checking, and cross-document consistency.
- **Context to provide**: Current template (`docs/claudemd-template.md`), lucy's prior advisory analysis (publishability, enforceability), the blocking concerns list, the Helix Manifesto anchor, the fact that RESEARCH.md line 493 says "The decision must be neutral" and needs updating.
- **Why this agent**: Lucy governs CLAUDE.md compliance and intent alignment. The template change is a convention design question -- lucy's domain. Lucy also needs to know how to enforce the new default during architecture review. Additionally, lucy's cross-document consistency expertise covers the gap left by removing software-docs-minion from the planning team.

### Consultation 4: Edge Platform Perspective on Serverless-First Default

- **Agent**: edge-minion
- **Model**: opus
- **Planning question**: The agent system is shifting from "evaluate all topologies equally" to "serverless unless blocked." As the specialist for edge platforms (Cloudflare Workers/Pages, Vercel, Netlify, Fastly Compute), you have deep knowledge of what these platforms can and cannot do. Your input is needed on two aspects: (a) The blocking concerns list for the serverless-first default is: persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale. From your experience with edge serverless platforms, is this list complete? Are there common legitimate blocking concerns at the edge layer that are missing -- for example, execution environment constraints (CPU time limits, memory limits, no native binaries), storage access patterns that don't fit edge KV/D1, or multi-platform coordination issues? (b) iac-minion's Step 0 will become "start with serverless." When the workload fits serverless, there's often a secondary decision: full-cloud serverless (Lambda, Cloud Functions) vs. edge serverless (Workers, Vercel Functions). Should the serverless-first default have a sub-preference for edge-first within serverless, given the Helix Manifesto's latency principle ("<300ms fast. Always.")? Or would that over-prescribe and create confusion? Note: your boundary with iac-minion is clear (edge-layer behavior vs. deployment strategy). This consultation asks for your platform expertise to inform iac-minion's decision framework, not to expand your remit.
- **Context to provide**: Current edge-minion spec (the-plan.md lines 760-800), the iac-minion Step 0 dimensions (lines 170-188), the blocking concerns list, the Helix Manifesto principles (especially the latency principle).
- **Why this agent**: Edge-minion has the deepest knowledge of serverless platform capabilities and constraints at the edge. The blocking concerns list needs validation from someone who works with these platforms daily. The edge-first sub-question is directly relevant because the Helix Manifesto's latency principle naturally favors edge platforms within the serverless category.

## Cross-Cutting Checklist

- **Testing** (test-minion): **Exclude from planning.** Test-minion was in the original team but has been removed. Verification scenarios (dry-run scenarios with expected outcomes confirming the framing shift works) will be defined during synthesis. The changes are to spec files and markdown, not executable code -- Phase 6 test execution will handle any testable outcomes post-build.

- **Security** (security-minion): **Exclude from planning.** No new attack surface, no auth changes, no user input handling. The prior round's security advisory (add serverless security patterns) was already incorporated in PR #123. The framing shift does not change security posture.

- **Usability -- Strategy** (ux-strategy-minion): **Exclude from planning (removed from team).** The developer journey change (from "evaluate options" to "use serverless, justify deviations") is a simplification, not a new complexity. Margo's consultation explicitly covers the simplification dimension (how the new enforcement interacts with complexity assessment). Lucy's consultation covers the CLAUDE.md template usability (how project owners express their deployment preferences). The cognitive model shift is real but straightforward enough that dedicated UX strategy planning is not needed for a framing change to internal agent specs.

- **Usability -- Design** (ux-design-minion, accessibility-minion): **Exclude from planning.** No UI components produced. This is spec and documentation work.

- **Documentation** (software-docs-minion): **Exclude from planning (removed from team).** Documentation consistency is absorbed into lucy's consultation (question (e) explicitly asks about cross-document consistency for "topology-neutral" references). Execution will handle the actual doc changes. Phase 8 post-execution documentation will catch anything missed.

- **Observability** (observability-minion, sitespeed-minion): **Exclude from planning.** No runtime components produced.

## Anticipated Approval Gates

1. **iac-minion Step 0 rewrite** (MUST gate): High blast radius -- every downstream deployment task routes through Step 0. Hard to reverse -- the framing language shapes all agent recommendations. This is the most consequential change.

2. **margo enforcement mechanism** (MUST gate): High blast radius -- margo reviews every plan in Phase 3.5. The penalty mechanism determines whether the serverless-first stance has enforcement teeth or is aspirational.

3. **CLAUDE.md template** (OPTIONAL gate): Medium blast radius -- affects target projects, not the agent system itself. Easy to reverse -- template is documentation. Gate only if the framing is ambiguous.

## Rationale

**Why these specialists and not others:**

- **iac-minion** is the primary agent being changed. It must self-assess how to shift from neutral to serverless-first without becoming dysfunctional. The Step 0 restructuring is the most consequential change in the plan.
- **margo** is the enforcement mechanism. Without margo's active penalty for unnecessary self-managed infrastructure, the stance is aspirational. Her consultation addresses how to encode the preference without overstepping domain boundaries.
- **lucy** governs CLAUDE.md and intent alignment. The template redesign is her domain. She also absorbs the documentation consistency concern (which files reference "topology-neutral"), reducing the need for a separate software-docs-minion consultation.
- **edge-minion** brings platform-specific expertise that validates the blocking concerns list and informs the serverless-first sub-question (edge-first within serverless). This is expertise that iac-minion's deployment-strategy perspective does not fully cover -- edge-minion knows the runtime capabilities and constraints of Cloudflare Workers, Vercel Functions, etc. from the inside.

**Why NOT these specialists:**

- **ux-strategy-minion** (removed): The developer journey change is a simplification (fewer decision branches), not a new user experience problem. Margo covers the simplification dimension; lucy covers the template usability. Dedicated UX strategy planning adds cost without proportional insight for this specific framing shift.
- **software-docs-minion** (removed): Documentation consistency is absorbed into lucy's consultation question (e). The changes touch CLAUDE.md template, AGENT.md files, and RESEARCH.md -- all of which lucy can audit for consistency. Phase 8 handles post-execution documentation.
- **test-minion** (removed): Verification scenarios will be defined during synthesis. No executable code is produced -- the changes are to markdown specs and agent definitions. Phase 6 post-execution testing handles the /despicable-lab rebuild validation.
- **gru**: Technology maturity assessment was done in the advisory round. The serverless platforms are already classified (Lambda ADOPT, Workers ADOPT, Vercel TRIAL). No new technology decisions here.
- **devx-minion**: DX perspective was captured in the advisory round. The framing shift does not change DX boundaries.
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
