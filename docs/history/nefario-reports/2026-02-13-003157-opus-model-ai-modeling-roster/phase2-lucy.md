## Domain Plan Contribution: lucy

### Recommendations

#### (a) Intent Alignment

The issue identifies three gaps and prescribes four coordinated changes. Mapping them:

| Gap | Prescribed Change | Alignment |
|-----|------------------|-----------|
| G1: iac-minion has zero serverless knowledge | C1: Expand iac-minion spec to 1.1 | Direct match |
| G2: margo's complexity budget penalizes novelty, not operational burden | C2: Recalibrate margo spec to 1.1 | Direct match |
| G3: Delegation table has no serverless routing | C3: Update delegation table | Direct match |
| (Enablement) | C4: CLAUDE.md template for target projects | Justified -- the template operationalizes the fix by letting target projects express deployment preferences, which is the mechanism agents use to select approaches |

All four changes trace to stated gaps. No orphaned requirements, no orphaned tasks.

**Drift risks to watch during planning:**

1. **edge-minion scope expansion**: The issue says iac-minion gets serverless knowledge. The planning team may be tempted to also expand edge-minion's spec (since Cloudflare Workers, Vercel Edge Functions, etc. are already in edge-minion's remit as "edge compute" but straddle the serverless boundary). The issue does NOT call for edge-minion spec changes. If the boundary between iac-minion's new serverless scope and edge-minion's existing edge-compute scope needs clarification, that should be handled via "Does NOT do" refinement on iac-minion, not by expanding edge-minion. Any edge-minion spec change would be scope creep unless the planning team can show it is strictly necessary to avoid routing ambiguity.

2. **CLAUDE.md template over-specification**: The template (C4) should express deployment preferences (e.g., "prefer serverless for stateless workloads") but should NOT prescribe specific cloud providers, specific serverless runtimes, or project architecture. The design principle is "Generic domain specialists -- deep expertise in their domain, not tied to any project." The template must stay at the preference-expression level, not become an opinionated infrastructure blueprint. The CLAUDE.md template should be a minimal skeleton with commented examples, not a filled-in document.

3. **margo recalibration scope**: The issue says recalibrate margo's complexity budget. The planning team should constrain this to adjusting the cost model (specifically: adding operational burden as a dimension, or reweighting the "New technology: 10 points" heuristic to distinguish between novel-but-simple-to-operate vs. novel-and-complex-to-operate). The change should NOT be a wholesale rewrite of margo's simplicity philosophy. The current margo AGENT.md (line 55-62) has the specific complexity budget table that needs adjustment -- the fix is surgical.

#### (b) Spec Consistency

When iac-minion spec-version bumps from 1.0 to 1.1 and margo from 1.0 to 1.1, the following locations must be updated for internal consistency:

| Location | What Changes | Why |
|----------|-------------|-----|
| `the-plan.md` iac-minion `spec-version` (line 748) | 1.0 -> 1.1 | Primary spec bump |
| `the-plan.md` margo `spec-version` (line 570) | 1.0 -> 1.1 | Primary spec bump |
| `the-plan.md` delegation table (lines 299-390) | Add serverless routing rows | C3 |
| `minions/iac-minion/AGENT.md` `x-plan-version` | Will diverge from spec; requires regeneration via `/despicable-lab` | Versioning contract (CLAUDE.md lines 69-70) |
| `margo/AGENT.md` `x-plan-version` | Will diverge from spec; requires regeneration | Same |
| `nefario/AGENT.md` | Embeds the delegation table (confirmed at line 106-110 of nefario/AGENT.md). Table changes require nefario regeneration. However, nefario's spec-version (2.0) is NOT changing -- the delegation table is nefario's embedded data, not nefario's spec. The build process should pick up the updated table from `the-plan.md` during regeneration without a nefario spec bump. |  |
| `docs/agent-catalog.md` | May contain agent summaries that reference iac-minion's or margo's capabilities. Should be checked and updated if it lists remit items. | Documentation staleness |
| `docs/orchestration.md` | Contains delegation-related content. Check if it duplicates the delegation table or references specific routing rules that would become stale. | Documentation staleness |

**Critical finding**: Nefario's AGENT.md embeds the delegation table verbatim. Adding serverless routing rows to `the-plan.md` without regenerating nefario's AGENT.md means the deployed nefario will still route based on the old table. The plan MUST include a `/despicable-lab` regeneration step for nefario (even though nefario's spec-version does not change), or the delegation table fix is dead on arrival. The versioning system tracks spec changes via `spec-version` vs `x-plan-version` divergence. Since the delegation table is part of nefario's section in `the-plan.md` but nefario's `spec-version` is not changing, the build process might NOT flag nefario as needing regeneration. This is a subtle consistency gap: the delegation table can change without a nefario spec bump, causing the deployed AGENT.md to go stale silently. The plan should either (a) bump nefario's spec-version to 2.1 (minor refinement), or (b) explicitly include a manual nefario regeneration step with a note explaining why.

#### (c) Boundary Coherence

**Existing "Does NOT do" pattern**: Every agent in `the-plan.md` uses the same format: `**Does NOT do**: <list of excluded activities> (-> <handoff target>)`. This is consistent across all 27 agents. The iac-minion expansion must follow this pattern exactly.

**The iac-minion / edge-minion boundary**: Currently:
- iac-minion (line 736): "Does NOT do: Application-level security audits (-> security-minion), OAuth implementation (-> oauth-minion), application code (-> relevant minion)"
- edge-minion (line 771): "Does NOT do: Origin server infrastructure (-> iac-minion), application security policies (-> security-minion), API design (-> api-design-minion)"

The boundary is currently clean: iac-minion handles origin/server infrastructure; edge-minion handles CDN/edge compute. Adding serverless to iac-minion introduces overlap risk because:
- Cloudflare Workers and Vercel Edge Functions are already in edge-minion's remit (lines 756-764) as "edge workers and edge-side compute"
- AWS Lambda, Google Cloud Functions are clearly iac-minion territory (server-side compute, not edge)
- But services like Cloudflare Workers when used as full backends (not just edge logic) straddle both

**Required boundary clarification**: The expanded iac-minion must add a "Does NOT do" entry clarifying the edge/serverless split. Suggested demarcation: iac-minion handles serverless compute platforms used as backend services (Lambda, Cloud Functions, Cloud Run, Vercel serverless functions); edge-minion handles edge-side compute that runs at CDN PoPs (Cloudflare Workers for edge logic, Fastly Compute). The delegation table row should encode this same split.

**Template from existing boundary pairs**:
- mcp-minion / oauth-minion: "MCP-specific OAuth" vs "General OAuth" -- clean functional split
- api-design-minion / api-spec-minion: "API design decisions" vs "API spec authoring" -- clean artifact split
- iac-minion / edge-minion: should follow the same pattern -- "serverless backend compute" vs "edge-side compute at CDN PoPs"

#### (d) CLAUDE.md Compliance

The project CLAUDE.md (line 26) states: "Do NOT modify the-plan.md unless you are the human owner or the human owner approves you making changes." The issue constitutes that approval. No compliance issue.

Other CLAUDE.md constraints that apply to this work:

1. **"All artifacts in English"** (line 28) -- All spec text, template content, documentation must be in English. Trivial but worth noting for the CLAUDE.md template.

2. **"Agent boundaries are strict: check 'Does NOT do' sections for handoff points"** (line 30) -- Reinforces finding (c): boundary coherence is a CLAUDE.md directive, not just good practice.

3. **"No PII, no proprietary data -- agents must remain publishable (Apache 2.0)"** (line 29) -- The CLAUDE.md template must not include specific project infrastructure details. It must be generic and example-based.

4. **Versioning contract** (lines 69-70): "When they diverge, use /despicable-lab to regenerate." -- The plan must include a regeneration step.

5. **Engineering Philosophy** (lines 34-47): YAGNI, KISS, Lean and Mean -- The spec changes should be minimal. Do not add serverless knowledge that is not needed to close the routing gap. The iac-minion spec expansion should cover the major serverless platforms and patterns, not attempt an exhaustive catalog.

6. **"Never delete remote branches"** (line 27) -- Operational constraint for the git workflow during execution.

#### (e) Repo Convention Review (CLAUDE.md Template Placement)

**Existing docs/ conventions observed:**

| Convention | Evidence |
|-----------|----------|
| Files are kebab-case `.md` | `agent-anatomy.md`, `build-pipeline.md`, `commit-workflow.md`, `external-skills.md` |
| First line is back-link: `[< Back to Architecture Overview](architecture.md)` | Present in `deployment.md`, `decisions.md`, `external-skills.md`, `compaction-strategy.md`, `orchestration.md` |
| Second line is `# Title` heading | Consistent across all docs |
| Content follows after a `---` separator or directly after the heading | Consistent |
| No subdirectories in docs/ except `history/` for nefario reports | Only exception is `docs/history/nefario-reports/` |
| architecture.md serves as the index/hub | Cross-referenced from CLAUDE.md and other docs |

**Recommended placement and naming for the CLAUDE.md template:**

The template is not architecture documentation about the despicable-agents project itself. It is a reusable artifact that target projects copy. This places it somewhere between "docs" and "deliverable."

Two valid options:

1. **`docs/claudemd-template.md`**: Follows existing naming convention (kebab-case, in docs/). Include the standard back-link. Pro: discoverable alongside other docs. Con: it is not documentation about the project; it is a deliverable.

2. **`templates/claudemd-infrastructure.md`** (new directory): Separates deliverables from project docs. Pro: semantically correct. Con: introduces a new top-level directory that has no precedent in the project structure.

**Recommendation**: Use option 1 (`docs/claudemd-template.md`) -- it follows existing conventions, avoids introducing new directory structure, and aligns with KISS. If more templates are needed in the future, they can be moved to a `templates/` directory then (YAGNI). The file should follow the existing docs format: back-link to architecture.md, title heading, content.

### Proposed Tasks

From lucy's governance perspective, these tasks must be present in the execution plan:

1. **Modify iac-minion spec in the-plan.md**: Add serverless platforms to remit, update "Does NOT do" with edge-minion boundary clarification, bump spec-version to 1.1. Scope: lines 720-748 of the-plan.md.

2. **Modify margo spec in the-plan.md**: Adjust complexity budget to account for operational burden (not just novelty), bump spec-version to 1.1. Scope: lines 537-570 of the-plan.md. The change should be surgical -- adjust the budget heuristic, do not rewrite margo's philosophy.

3. **Update delegation table in the-plan.md**: Add serverless deployment routing rows under "Infrastructure & Data" section. Scope: lines 308-317 of the-plan.md.

4. **Create CLAUDE.md template**: Place at `docs/claudemd-template.md` following existing docs conventions. Content should be a minimal, commented skeleton showing how to express infrastructure deployment preferences (serverless vs. container vs. hybrid). Must not be opinionated about specific providers or runtimes.

5. **Regenerate affected AGENT.md files via `/despicable-lab`**: At minimum, regenerate iac-minion and margo (spec-version divergence). Additionally, regenerate nefario (delegation table changed, even though spec-version did not change). See finding (b) for the nefario versioning gap.

6. **Update docs if stale**: Check `docs/agent-catalog.md` and `docs/orchestration.md` for references to iac-minion capabilities or delegation routing that would become stale.

### Risks and Concerns

| ID | Category | Risk | Severity | Mitigation |
|----|----------|------|----------|------------|
| R1 | DRIFT | Planning team expands edge-minion's spec beyond what the issue requests | Medium | The issue prescribes changes to iac-minion, margo, delegation table, and a template. Edge-minion changes are out of scope unless strictly required for boundary disambiguation. Any edge-minion change must be justified as necessary for boundary coherence, not as a "while we're at it" improvement. |
| R2 | SCOPE | CLAUDE.md template becomes an opinionated infrastructure blueprint | Medium | Template must be a skeleton with commented examples, not a filled-in decision document. Follow the design principle: "Project context belongs in the target project's CLAUDE.md, not in agents." The template helps projects express context; it should not make decisions for them. |
| R3 | TRACE | Nefario AGENT.md not regenerated after delegation table change | High | Nefario embeds the delegation table. Without regeneration, the deployed nefario routes from the old table. The plan must either bump nefario's spec-version to 2.1 or include an explicit manual regeneration note. |
| R4 | CONVENTION | New template file does not follow docs/ conventions (back-link, naming) | Low | Enforce kebab-case naming, back-link to architecture.md, title heading format. |
| R5 | COMPLIANCE | Margo recalibration drifts into a full rewrite of the complexity philosophy | Medium | The change is surgical: adjust the complexity budget table (currently 4 bullet points in margo AGENT.md lines 55-59) to weight operational burden alongside novelty. Do not rewrite the YAGNI enforcement section or simplicity assessment framework. |
| R6 | TRACE | docs/agent-catalog.md and docs/orchestration.md go stale | Low | Include a doc-review pass in the plan. These docs may reference iac-minion's capabilities or specific delegation routes. |

### Additional Agents Needed

No additional agents beyond those already identified by nefario's meta-plan are needed from a governance perspective. The task is a spec-editing exercise, not a code-writing or architecture exercise.

However, I note one concern: **if the planning team includes iac-minion itself as a planning contributor** (which is reasonable since it self-assessed and identified the gap), its contribution should be scoped to "what serverless knowledge should be in my spec" -- not "what the overall solution architecture should look like." iac-minion should not be routing its own delegation table entries. That is nefario's responsibility.
