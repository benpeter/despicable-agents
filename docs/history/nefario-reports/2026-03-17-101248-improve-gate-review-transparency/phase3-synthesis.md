## Advisory Report

**Question**: How should gate review transparency be improved across ALL four gate types (Team, Reviewer, Execution Plan, Mid-execution) so users see decision rationale at every approval point?
**Confidence**: HIGH
**Recommendation**: Adopt a universal Chosen/Over/Why micro-format for decision entries across all four gates, with density proportional to each gate's decision scope. This is convergence on an existing philosophy (already spec'd for mid-execution gates) rather than new design. Four artifacts need changes: SKILL.md (gate rendering), AGENT.md (upstream data formats), TEMPLATE.md (report capture), and docs/orchestration.md (developer documentation).

### Executive Summary

The nefario orchestration system has a well-articulated gate philosophy -- "progressive-disclosure decision briefs" where "most approvals should be decidable from the first two layers" and "rejected alternatives [are] mandatory" as "the primary anti-rubber-stamping measure." This philosophy is only actualized at the mid-execution gate. The other three gates present conclusions without reasoning: the Team gate shows a roster with one-liners, the Execution Plan gate shows conflicts as opaque one-liners, and the Reviewer gate shows a thin roster. Production session data confirms the cost: users add agents at the Team gate because they cannot tell why agents were excluded, and cannot evaluate conflict resolutions without opening scratch files.

The fix is not new design -- it is consistent application of the existing philosophy across all four gates. All specialists converge on a Chosen/Over/Why micro-format as the structural mechanism for surfacing decision rationale. The format is compact (3 lines per decision), self-contained (readable without opening scratch files), and already proven in concept by the mid-execution gate spec and the WRL decisions.md pattern. The density scales with decision scope: the Team gate gets 2-3 notable exclusions, the Reviewer gate gets per-member rationales (feasible because the pool is only 5 agents), the Execution Plan gate gets structured conflict resolutions, and the mid-execution gate gets quality examples for its existing format.

This is a prompt-engineering change touching two primary files (SKILL.md, AGENT.md) and two secondary files (TEMPLATE.md, docs/orchestration.md). No code, no infrastructure, no new runtime behavior. The risk profile is low: the changes are additive (new fields, not breaking changes), the line budget growth is modest (the Execution Plan gate grows the most, from ~30 to ~45 lines), and the mid-execution gate format is untested regardless of whether we change it.

### Team Consensus

All four specialists agree on these points:

1. **The root cause is data flow, not rendering.** Gates cannot display rationale they never received or that was discarded before rendering. The meta-plan produces rich data (planning questions, exclusion rationale) that the Team gate never surfaces. The synthesis produces free-text conflict resolutions that the Execution Plan gate cannot structure. The mid-execution gate spec asks for RATIONALE but the agent prompt does not instruct agents to produce it.

2. **Chosen/Over/Why is the right micro-format.** All four specialists independently converge on a three-field decision entry (what was chosen, what was rejected, why) as the universal transparency mechanism. The terminology varies slightly ("Over" vs. "Alternatives considered" vs. "Rejected"), but the structure is identical: every non-trivial decision shows the chosen path, the road not taken, and the reasoning.

3. **Density should scale with decision scope.** The Team gate is lighter than the Execution Plan gate. The Reviewer gate is the lightest. No specialist proposes making all gates equally heavy. The consensus is: same structure, proportional depth.

4. **"CONFLICTS RESOLVED" should be renamed "DECISIONS."** The current label implies adversarial agents and process dysfunction. Many synthesis decisions are trade-off resolutions or scope choices, not conflicts. "DECISIONS" is neutral and accurate.

5. **The mid-execution gate needs quality guidance, not format redesign.** The spec is structurally sound (RATIONALE + Rejected). The problem is that it has never been tested in production, and agent prompts do not instruct agents to report rationale. The fix is better examples and explicit agent instructions.

6. **Progressive disclosure still works, but the primary layer must be self-sufficient.** The scratch file link remains the escape hatch for deep dives. But every gate must be decidable from its inline content alone -- "never clicks Details" is the design target.

### Dissenting Views

#### Team Gate: Planning questions -- show or hide?

- **ai-modeling-minion** recommends showing planning questions as sub-lines under each selected agent ("`Question:` How should the approval gate interact with existing skill patterns?"). This adds +2 lines per agent, growing the Team gate from 8-12 to ~25-30 lines.
- **ux-strategy-minion** explicitly recommends NOT showing planning questions at the gate ("planning questions are implementation detail -- the user cares about team composition, not the prompts nefario will send").
- **lucy** does not take a position on planning questions but recommends keeping the Team gate at 13-18 lines.

**Resolution**: Exclude planning questions from the Team gate. The user's decision at this gate is "are the right specialists included?" not "what will nefario ask them?" Planning questions add verbosity without aiding the composition decision. They remain accessible via the meta-plan Details link. This keeps the Team gate within 10-16 lines (ux-strategy-minion's budget) rather than bloating to 25-30 (ai-modeling-minion's budget).

#### Team Gate: Exclusion naming -- "NOT SELECTED (notable)" vs. "NOT CONSULTED (rationale)"

- **ux-strategy-minion** proposes "NOT SELECTED (notable)" with a cap of 3 entries for agents the user might wonder about.
- **ai-modeling-minion** proposes "NOT CONSULTED (rationale)" with a cap of 3-5 entries.
- Both agree on showing only surprising exclusions, not the full roster.

**Resolution**: Adopt "NOT SELECTED (notable)" with a cap of 3 entries. The label "notable" signals that these are the exclusions worth explaining, not a complete list. "NOT CONSULTED" is unnecessarily different from the Reviewer gate's "NOT SELECTED" label. Consistency across gates matters.

#### Execution Plan Gate: Should ADVISORIES get an "Over" line?

- **ux-strategy-minion** recommends adding an explicit "OVER" line to advisories when they changed an existing plan decision, replacing the implicit "not X" buried in the CHANGE line.
- **ai-modeling-minion** proposes a "WAS" field showing the original plan text before the advisory modified it.
- **software-docs-minion** argues advisories should keep their CHANGE/WHY format because they are modifications, not choices between alternatives.

**Resolution**: Do not add OVER or WAS to advisories. software-docs-minion's analysis is correct: advisories are plan modifications (delta model), not binary choices. Adding OVER or WAS conflates the decision micro-format with the advisory micro-format. The current CHANGE/WHY format is already well-structured and self-contained. If an advisory implicitly rejects an alternative, the CHANGE line already captures that ("Use binding-presence check" implicitly communicates "not KV content scan"). Making this explicit adds a line per advisory (~4 extra lines for a 6-advisory gate) for marginal clarity gain. Keep the advisory format clean.

#### Execution Plan Gate: Should RISKS be absorbed into DECISIONS?

- **lucy** recommends absorbing RISKS into DECISIONS as tagged entries ("[constraint]" or "[trade-off]").
- **ux-strategy-minion** and **ai-modeling-minion** keep RISKS as a separate section.
- **software-docs-minion** does not take a position.

**Resolution**: Keep RISKS as a separate section. Risks are informational ("this could go wrong; here is the mitigation"), not decisions ("we chose X over Y"). Merging them into DECISIONS dilutes the decision format's clarity. A reader scanning DECISIONS expects choices; a risk entry ("Late delivery risk -- Mitigation: buffer time") does not fit the Chosen/Over/Why pattern without contorting the format. The current RISKS format (risk + mitigation, one line each) is adequate.

#### Reviewer Gate: Per-member rationale vs. composition-level rationale

- **lucy** recommends 2-3 RATIONALE bullets covering the reviewer composition as a whole ("why this set of reviewers matters for this plan"), not per-reviewer decision entries.
- **ux-strategy-minion** recommends per-member exclusion rationales for the NOT SELECTED pool (replacing the flat comma list).
- **ai-modeling-minion** recommends adding a "Review focus" sub-line per discretionary reviewer.

**Resolution**: Use per-member rationales for both selected and not-selected pool members. The discretionary pool is only 5 agents -- showing all 5 with one-line rationales is feasible and eliminates "why wasn't X included?" entirely. This is more concrete and actionable than abstract composition-level reasoning. Adding "Review focus" per discretionary pick (ai-modeling-minion's recommendation) is a worthwhile enrichment: it tells the user what specifically the reviewer will examine. Adopt both: discretionary picks get rationale + review focus, not-selected pool members get exclusion rationale.

#### Mid-execution Gate: Restructure or improve examples?

- **ux-strategy-minion** proposes restructuring the mid-execution gate to replace the bullet-list RATIONALE with a structured APPROACH block (Chosen/Over), remove the standalone IMPACT line, and reposition DELIVERABLE after APPROACH.
- **lucy** proposes no format changes -- only add good/bad examples to guide agent output quality.
- **ai-modeling-minion** proposes adding a "Gate rationale" field to the synthesis format (pre-execution rationale) and merging it with execution-time rationale at the gate.

**Resolution**: Adopt lucy's lighter approach. The mid-execution gate format is already the most complete gate spec. It has RATIONALE with "Rejected: alternative and why" -- this IS the Chosen/Over/Why pattern, just using bullet syntax instead of labeled fields. Restructuring an untested format is premature optimization. Add quality examples (good vs. bad RATIONALE) and add explicit agent prompt instructions to report rationale. Also adopt ai-modeling-minion's pre-execution "Gate rationale" field in the synthesis format as a fallback data source -- this ensures the gate has SOMETHING to show even when the agent does not report execution-time rationale.

### Supporting Evidence

#### UX Strategy (ux-strategy-minion)

The core diagnostic is precise: gates present "conclusions without reasoning." The self-containment test -- "can a user who reads ONLY the gate output make a well-informed decision?" -- is the right quality bar. Today, only the mid-execution spec (untested) comes close. The Chosen/Over/Why micro-format directly addresses this by mechanically forcing the reasoning that current gate formats omit.

Key findings:
- Line budget analysis is sound: Team grows from 8-12 to 10-16, Reviewer from 6-10 to 7-13, Execution Plan from 25-40 to 35-55, Mid-execution stays at 12-18.
- The recommendation to rename CONFLICTS RESOLVED to DECISIONS is well-grounded ("not every decision is a conflict").
- The "Over" attribution (which agent proposed the rejected alternative) is valuable but should be best-effort, not mandatory. Fabricated attribution erodes trust.
- Progressive disclosure principle is correctly preserved: raise the floor of the primary layer rather than eliminate the Details link.

#### Prompt Engineering (ai-modeling-minion)

The pipeline analysis is the most architecturally valuable contribution. It maps exactly where data originates and where it gets lost:
- Team gate: meta-plan has the data, SKILL.md gate template does not render it.
- Execution Plan gate: synthesis allows free-text conflicts, no structure enforced.
- Mid-execution gate: data pipeline is longest -- synthesis produces task prompt, agent runs, output captured, gate renders. RATIONALE/Rejected depend on data the agent may not produce.
- Compaction: enriched data survives both compaction checkpoints because synthesis output is already preserved as a unit. No compaction changes needed.

Key finding: the compaction survival analysis confirms that enriched gates do not create context window pressure. The synthesis output grows ~15-20% (from ~3K-5K to ~3.5K-6K tokens), which is negligible relative to the 200K/1M context window.

#### Governance (lucy)

The alignment analysis is the most incisive contribution. Lucy correctly identifies that:
- The previous advisory's YAGNI-based deferral was overridden by the user, and YAGNI does not apply when the user explicitly requests the feature.
- The philosophy is sound but "inconsistently absent" -- the fix is convergence, not new complexity.
- All gates should converge on STRUCTURE (DECISION, RATIONALE, Confidence, Details link) while varying in DENSITY.
- The Chosen/Over/Why format is an enforcement mechanism: "it is not possible to write a Chosen/Over/Why entry without stating the rejected alternative" -- the format itself prevents shallow reasoning.
- The mid-execution gate should be treated as "design intent, not verified implementation."

The AGENT.md consistency recommendation (Task 5 in lucy's contribution) is important: establish in AGENT.md that all gate types use the progressive-disclosure decision brief pattern, with SKILL.md defining per-gate format. This anchors the philosophy at the spec level.

#### Documentation (software-docs-minion)

The artifact impact analysis is comprehensive:
- SKILL.md needs a shared "Decision Transparency" preamble defining the micro-format, then per-gate format updates.
- AGENT.md meta-plan output needs an "Over" field per consultation (or at minimum, an exclusion rationale) to feed the Team gate. Synthesis needs "Why not selected" per NOT SELECTED reviewer.
- TEMPLATE.md needs broadening: rename "Approval Gates" to cover all four gate types, add a "Type" column, define type-aware H4 briefs for Team and Reviewer gates. Routine approvals (approve as-is) get table row only; adjusted gates get full Decisions entries.
- docs/orchestration.md needs the Reviewer gate elevated to Section 3 as a first-class gate type, a gate philosophy preamble, and decision transparency expectations per gate type.

Key insight: the Chosen/Over/Why format should NOT apply to ADVISORIES (they are modifications, not choices) or mandatory reviewers (they are unconditional, not decisions). These exceptions prevent the format from being applied where it does not fit.

### Risks and Caveats

1. **Line budget growth may cause scanning fatigue at the Execution Plan gate.** The gate grows from ~30 to ~45 lines. At 45 lines, it may exceed one terminal screen. Mitigation: the DECISIONS block is the variable-length section; cap at 5 inline decisions. The Chosen/Over/Why format has strong visual rhythm (labeled lines) that supports rapid scanning.

2. **The mid-execution gate format remains untested.** Any changes to it -- whether structural (ux-strategy-minion's APPROACH block) or quality-focused (lucy's examples) -- are theoretical until a production session hits a gated task. The recommendation is to add examples and explicit agent instructions, then validate on the first real session. If agent-produced RATIONALE is shallow despite examples, a follow-up is needed.

3. **The meta-plan may not produce excerptable reasoning for Team gate exclusions.** The meta-plan's cross-cutting checklist already contains exclusion reasoning, but the excerpting quality is untested. If the meta-plan output is too coarse to produce clean "NOT SELECTED (notable)" entries, a follow-up to enrich the meta-plan output format will be needed.

4. **Attribution in "Over" lines may be inaccurate.** The synthesis may misattribute which agent proposed a rejected alternative. Mitigation: make attribution best-effort (include when clear, omit when uncertain). Never fabricate.

5. **TEMPLATE.md version bump has a ripple effect.** Changing the report template from v3 to v4 may affect `build-index.sh` parsing. Mitigation: the changes are additive (new columns, new brief types) so v3 reports remain valid.

6. **This recommendation could be invalidated by a shift in gate philosophy** -- for example, if a future decision eliminates gates entirely or moves to a batch-approval model. Given the user's explicit request to improve gate transparency (not eliminate gates), this risk is low in the near term.

### Next Steps

If this recommendation is adopted, implementation would proceed as a single `/nefario` execution with the following work breakdown:

**Primary artifacts (2 files, ~80% of the work):**

1. **SKILL.md gate rendering updates** -- Modify all four gate presentation formats:
   - Team gate: Add "NOT SELECTED (notable)" block (3 entries max), update line budget to 10-16
   - Reviewer gate: Replace flat NOT SELECTED with per-member rationales, add "Review focus" per discretionary pick, update line budget to 7-13
   - Execution Plan gate: Rename CONFLICTS RESOLVED to DECISIONS, define Chosen/Over/Why format, update line budget to 35-55
   - Mid-execution gate: Add good/bad RATIONALE examples, add agent prompt instruction for rationale reporting
   - Add a shared "Decision Transparency" preamble defining the micro-format

2. **AGENT.md upstream data formats** -- Enrich the formats that feed gate rendering:
   - Meta-plan output: Ensure exclusion rationale is excerptable for the Team gate
   - Synthesis output: Structure conflict resolutions as Chosen/Over/Why/Source, add per-task "Gate rationale" field for gated tasks, add "Review focus" and exclusion rationale per discretionary reviewer
   - Establish at the AGENT.md level that all gate types follow the progressive-disclosure decision brief pattern

**Secondary artifacts (2 files, ~20% of the work):**

3. **TEMPLATE.md** -- Broaden gate capture to all four gate types:
   - Add "Type" column to summary table
   - Define type-aware H4 briefs for Team and Reviewer gates
   - Routine approvals get table row only; adjusted/contested gates get full Decisions entry
   - Distinguish "Key Design Decisions" (non-gate reasoning) from "Decisions" (gate outcomes)

4. **docs/orchestration.md** -- Update developer documentation:
   - Elevate Reviewer gate to Section 3 as a first-class gate type
   - Add gate philosophy preamble
   - Add decision transparency expectations per gate type
   - Document information flow between gates

**Estimated scope**: 4 tasks (one per artifact), all assigned to ai-modeling-minion (prompt engineering domain). Sequential dependency: AGENT.md upstream formats before SKILL.md rendering (SKILL.md renders what AGENT.md produces). TEMPLATE.md and docs/orchestration.md can run in parallel after SKILL.md.

**Verification**: After implementation, the first production `/nefario` session should be treated as a validation run. Specifically observe:
- Whether the Team gate's "NOT SELECTED (notable)" entries help the user evaluate team composition without adding agents via freeform
- Whether the Execution Plan gate's DECISIONS block surfaces enough reasoning to evaluate conflict resolutions without opening the scratch file
- Whether mid-execution gate RATIONALE (if one appears) contains substantive reasoning or remains shallow

### Conflict Resolutions

Three substantive conflicts were resolved (detailed in Dissenting Views above):

1. **Planning questions at Team gate**: ux-strategy-minion's "exclude" position adopted over ai-modeling-minion's "include." Rationale: planning questions are implementation detail, not relevant to the team composition decision. Keeps Team gate at 10-16 lines rather than 25-30.

2. **Advisory OVER/WAS lines**: software-docs-minion's "no change" position adopted over ux-strategy-minion's "add OVER" and ai-modeling-minion's "add WAS." Rationale: advisories are modifications, not binary choices. The current CHANGE/WHY format is already self-contained.

3. **RISKS absorption into DECISIONS**: ux-strategy-minion and ai-modeling-minion's "keep separate" position adopted over lucy's "absorb." Rationale: risks are informational, not decisions. Merging them dilutes the Chosen/Over/Why format.

No unresolved conflicts remain.

### Appendix: Before/After Examples

#### Team Gate

**Before:**
```
`----------------------------------------------------`
`TEAM:` Improve gate review transparency across all gate types
`Specialists:` 4 selected | 23 considered, not selected

  `SELECTED:`
    ux-strategy-minion   Approval gate interaction design
    ai-modeling-minion   Gate data pipeline, prompt format changes
    lucy                 Governance alignment for gate changes
    software-docs-minion Documentation impact across 4 artifacts

  `ALSO AVAILABLE (not selected):`
    gru, margo, mcp-minion, oauth-minion, api-design-minion, api-spec-minion,
    iac-minion, edge-minion, data-minion, frontend-minion, test-minion, ...

`Details:` [meta-plan]($SCRATCH_DIR/improve-gate-review-transparency/phase1-metaplan.md)
`----------------------------------------------------`
```

**After:**
```
`----------------------------------------------------`
`TEAM:` Improve gate review transparency across all gate types
`Specialists:` 4 selected | 23 considered, not selected

  `SELECTED:`
    ux-strategy-minion   Approval gate interaction design
    ai-modeling-minion   Gate data pipeline, prompt format changes
    lucy                 Governance alignment for gate changes
    software-docs-minion Documentation impact across 4 artifacts

  `NOT SELECTED (notable):`
    margo                Will review in Phase 3.5 (mandatory reviewer)
    security-minion      No new attack surface; gate changes are prompt-only
    test-minion          No executable output; will review in Phase 3.5

  Also available: gru, mcp-minion, oauth-minion, frontend-minion, ...

`Details:` [meta-plan]($SCRATCH_DIR/improve-gate-review-transparency/phase1-metaplan.md)
`----------------------------------------------------`
```

**What changed**: The flat ALSO AVAILABLE list is split into "NOT SELECTED (notable)" (3 agents whose exclusion might surprise the user, with one-line reasons) and a shorter "Also available" remainder. The user can now see WHY margo and security-minion were not selected for planning without opening the meta-plan. Line growth: +4 lines (from ~10 to ~14).

---

#### Reviewer Gate

**Before:**
```
`----------------------------------------------------`
`REVIEWERS:` Architecture review for gate transparency plan
`Mandatory (5):` security-minion, test-minion, ux-strategy-minion, lucy, margo

  `DISCRETIONARY (nefario recommends):`
    user-docs-minion     Gate changes affect what users see at approval points (Tasks 1-4)

  `NOT SELECTED from pool:`
    ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion

`Details:` [plan]($SCRATCH_DIR/improve-gate-review-transparency/phase3-synthesis.md)
`----------------------------------------------------`
```

**After:**
```
`----------------------------------------------------`
`REVIEWERS:` Architecture review for gate transparency plan
`Mandatory (5):` security-minion, test-minion, ux-strategy-minion, lucy, margo

  `DISCRETIONARY (nefario recommends):`
    user-docs-minion     Gate changes affect what users see at approval points (Tasks 1-4)
      Review focus: gate presentation wording clarity and user-facing terminology

  `NOT SELECTED:`
    ux-design-minion       No UI components produced (all prompt/doc changes)
    accessibility-minion   No web-facing HTML in plan
    sitespeed-minion       No browser-facing runtime code
    observability-minion   No runtime components; all changes are prompt/doc artifacts

`Details:` [plan]($SCRATCH_DIR/improve-gate-review-transparency/phase3-synthesis.md)
`----------------------------------------------------`
```

**What changed**: Discretionary picks get a "Review focus" sub-line stating what specifically they will examine. The flat NOT SELECTED comma list becomes per-member exclusion rationales (feasible because the pool is only 5 agents). The user can now evaluate every pool member's inclusion/exclusion without opening the plan. Line growth: +4 lines (from ~9 to ~13).

---

#### Execution Plan Gate

**Before (CONFLICTS RESOLVED section):**
```
`CONFLICTS RESOLVED:`
  - Revoked key visibility: exclude by default, ?include=revoked opt-in (api-design-minion)
  - Name uniqueness: not enforced for MVP (avoids key rotation friction)
  - Rate limit placement: edge worker, not origin (edge-minion)
```

**After (DECISIONS section):**
```
`DECISIONS:`
  Revoked key visibility
    Chosen: exclude by default, ?include=revoked opt-in
    Over: always-visible with status field (security-minion), soft-delete only (data-minion)
    Why: opt-in aligns with API minimalism; status-field approach leaks internal state

  Name uniqueness
    Chosen: not enforced for MVP
    Over: unique-per-tenant constraint (api-design-minion)
    Why: enforcement blocks key rotation workflows; revisit post-MVP if collision reports

  Rate limit placement
    Chosen: edge worker enforcement
    Over: origin-level rate limiting (api-design-minion)
    Why: edge rejection avoids origin load; origin fallback adds latency on every request
```

**What changed**: Each conflict resolution becomes a three-line decision record showing what was chosen, what was rejected (with attribution), and why. The user can evaluate trade-offs without opening the synthesis file. The section is renamed from "CONFLICTS RESOLVED" to "DECISIONS." Line growth: +9 lines (from 4 to 13 for 3 decisions). For a plan with 5+ decisions, cap at 5 inline and link to synthesis for the rest.

---

#### Mid-Execution Gate

**Before (current spec, never observed in production):**
```
`----------------------------------------------------`
`APPROVAL GATE: Auth module rewrite`
`Agent:` security-minion | `Blocked tasks:` Tasks 3, 4

`DECISION:` Implemented PKCE-based OAuth flow with automatic token refresh

`DELIVERABLE:`
  src/auth/oauth.ts (new OAuth flow, +142 lines)
  src/auth/token-store.ts (token persistence, +67 lines)
  `Summary:` Complete OAuth implementation with PKCE, refresh token rotation, and secure storage.

`RATIONALE:`
- PKCE chosen for public client security (no client secret needed)
- Token refresh uses sliding window to minimize re-auth prompts
- Rejected: Implicit grant flow -- deprecated in OAuth 2.1, no refresh tokens

`IMPACT:` Approving unblocks admin API integration (Task 3) and CLI auth (Task 4).
`Confidence:` HIGH
`Details:` [task-prompt]($SCRATCH_DIR/auth-module/phase4-security-minion-prompt.md)
`----------------------------------------------------`
```

**After (same format, with quality guidance added to SKILL.md):**

The format does not change. What changes is the guidance in SKILL.md that tells agents HOW to produce substantive RATIONALE. New example block added to SKILL.md:

```
Good RATIONALE (substantive -- exposes real reasoning):
- PKCE chosen for public client security (no client secret storage needed)
- Rejected: Implicit grant flow -- deprecated in OAuth 2.1, no refresh token support
- Rejected: Client credentials grant -- requires secret storage, unsuitable for CLI

Bad RATIONALE (shallow -- restates the DECISION without reasoning):
- Implemented the OAuth flow as requested
- Used best practices for token management
- Followed the task prompt requirements
```

Additionally, the agent completion message instruction is enriched:
```
When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
- If this task has an approval gate: what approach you chose and
  what alternative(s) you considered but rejected, with brief reasons
```

And the synthesis format gains a "Gate rationale" field for gated tasks, providing pre-execution rationale as a fallback when agents do not report execution-time reasoning.
