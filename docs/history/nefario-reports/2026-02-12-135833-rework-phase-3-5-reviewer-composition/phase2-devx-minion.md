# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Checklist Format: A Single Artifact Serving Two Consumers

The planning question asks how to structure the documentation impact checklist so it works as both a lightweight Phase 3.5 output and an actionable Phase 8 input. The answer is a structured markdown checklist with two tiers of information density.

**Phase 3.5 produces the checklist; Phase 8 consumes it unchanged.** No intermediate transformation step. The same file (`$SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md`) is written by software-docs-minion during Phase 3.5 and read by the Phase 8 agents as their work order. This eliminates the current Phase 8 step 1 ("Generate checklist from execution outcomes") for items software-docs-minion already identified -- Phase 8 only needs to *supplement* the 3.5 checklist with items that emerged during execution (new endpoints, unanticipated architectural changes, etc.).

**Recommended checklist format:**

```markdown
# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Reviewer: software-docs-minion
Plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md

## Items

- [ ] **[software-docs]** Update orchestration.md reviewer table
  Scope: Remove ux-strategy-minion from ALWAYS row, add to conditional pool
  Files: docs/orchestration.md (Section 1, Phase 3.5 table)
  Priority: MUST (directly implements the change)

- [ ] **[software-docs]** Add discretionary reviewer gate to delegation flow diagram
  Scope: New gate between "Determine reviewers" and "Parallel Review" in Mermaid sequence
  Files: docs/orchestration.md (Section 1, delegation flow diagram)
  Priority: SHOULD (diagram accuracy)

- [ ] **[user-docs]** Update using-nefario.md Phase 3.5 description
  Scope: Explain that some reviewers are now conditional and user-approved
  Files: docs/using-nefario.md
  Priority: SHOULD (user-facing workflow change)

## Not Applicable
- API reference: No API surface changes
- ADR: No architectural decision requiring a record (this is a process change, not a technical architecture decision)
```

**Why this format works for both phases:**

- **Phase 3.5 speed**: software-docs-minion only has to identify WHAT needs documenting and WHERE, not write the documentation. The `Scope` field is one line of intent, not a paragraph of prose. The `Priority` field helps Phase 8 triage if time is constrained. The `Owner` tag (`[software-docs]` vs `[user-docs]`) pre-routes items to the right Phase 8 agent. This should take software-docs-minion 30-60 seconds, not 3-5 minutes of full review.
- **Phase 8 actionability**: Each item has an explicit file path, a scope description that tells the agent exactly what to change, and a priority for ordering. Phase 8 agents can iterate the list directly without re-analyzing the plan.
- **Machine-parseable**: The checkbox format (`- [ ]`) lets Phase 8 mark items complete as they go, and the wrap-up can report completion status.

### 2. Where Phase 8 Logic Changes in SKILL.md

Currently, Phase 8 step 1 (SKILL.md lines ~1253-1268) generates the documentation checklist entirely from execution outcomes. This needs to become a **merge** operation:

**Current flow:**
```
Phase 8 start --> Generate checklist from execution outcomes --> Write phase8-checklist.md --> Spawn doc agents
```

**Proposed flow:**
```
Phase 8 start --> Read phase3.5-docs-checklist.md (if exists) --> Supplement with execution-outcome items not already covered --> Write phase8-checklist.md (merged) --> Spawn doc agents
```

The specific edit location in SKILL.md is Phase 8 step 1 (the table and surrounding text at lines 1253-1268). The current table of outcome-to-action mappings remains valid -- it just becomes the *supplementation* logic rather than the *generation* logic. Items already covered by the 3.5 checklist are not duplicated.

The Phase 8 agent prompts (sub-step 8a, lines 1272-1276) need to reference the merged checklist rather than only the execution-derived one. The prompt should say: "Your work order is `$SCRATCH_DIR/{slug}/phase8-checklist.md`. Items marked `[software-docs]` are yours. Items from Phase 3.5 are pre-analyzed; execution-derived items may need you to inspect the changed files for scope."

### 3. Discretionary Reviewer Gate: Placement and Interaction Design

The discretionary reviewer gate should be inserted **between** the "Identify Reviewers" step and the "Spawn Reviewers" step in SKILL.md Phase 3.5 (currently lines 606-653). The flow becomes:

```
Identify ALWAYS reviewers (5: security-minion, test-minion, software-docs-minion, lucy, margo)
    |
    v
Evaluate discretionary pool (6: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion)
    |
    v
[Discretionary Reviewer Gate] -- nefario presents picks with rationale, user approves
    |
    v
Spawn ALL approved reviewers in parallel (ALWAYS + approved discretionary)
```

**Relationship to compaction checkpoint**: The discretionary gate goes BEFORE the Phase 3.5 compaction checkpoint (which is at lines 729-746, AFTER processing all review verdicts). This is correct because:
- The compaction checkpoint marks the end of Phase 3.5
- The discretionary gate marks the start of Phase 3.5 reviewer spawning
- They are on opposite ends of the phase and do not interact

**Relationship to the existing Phase 3 compaction checkpoint** (lines 582-599): The discretionary gate comes AFTER this checkpoint. The Phase 3 checkpoint compacts specialist contributions. The discretionary gate needs the synthesis output (to evaluate which conditional reviewers are relevant), which is preserved through compaction. This ordering is clean.

**Gate presentation format** -- following the same pattern as the Team Approval Gate from #48:

```
REVIEWERS: <1-sentence plan summary>
Mandatory: 5 (security, test, software-docs, lucy, margo)

  DISCRETIONARY PICKS:
    ux-strategy-minion       Plan changes user-facing approval flow
    accessibility-minion     Gate UI needs keyboard navigation review

  NOT SELECTED (available):
    ux-design-minion, sitespeed-minion, observability-minion, user-docs-minion

Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md
```

This is deliberately lighter than the Team Approval Gate (target 6-10 lines vs 8-12) because the user just approved the execution plan team and this is a refinement gate, not a scope gate. The mandatory reviewers are stated but not individually rationalized (they are unconditional; no justification needed).

**Decision options** via AskUserQuestion:
- `header`: "Reviewers"
- `question`: "<1-sentence plan summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve reviewers", description: "Run mandatory + N discretionary reviewers." (recommended)
  2. label: "Adjust reviewers", description: "Add or remove discretionary reviewers."
  3. label: "Skip discretionary", description: "Run only the 5 mandatory reviewers."

The "Skip discretionary" option is important -- it gives users who want maximum speed a one-click path to skip the conditional reviewers entirely, without having to reject each one individually.

### 4. software-docs-minion Phase 3.5 Role: Narrowed Prompt

The current Phase 3.5 prompt for software-docs-minion (visible in the example at `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-software-docs-minion-prompt.md`) asks for a general documentation coverage review. The narrowed role should produce the checklist instead:

```
You are reviewing a delegation plan before execution begins.
Your role: produce a documentation impact checklist for Phase 8.

## Delegation Plan
Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

## Your Review Focus
Identify all documentation that needs creating or updating as a result of this plan.
Do NOT write the documentation. Produce a checklist of what needs to change.

## Instructions
1. Read the plan and identify documentation impacts
2. For each impact, specify:
   - Owner tag: [software-docs] or [user-docs]
   - What to update (one line)
   - Scope: what specifically changes (one line)
   - Files: exact file path(s) affected
   - Priority: MUST (required for correctness) | SHOULD (improves completeness) | COULD (nice to have)
3. List items that are NOT applicable with brief rationale
4. Return your verdict (APPROVE/ADVISE/BLOCK) based on whether the plan has adequate documentation coverage in its task prompts

Write the checklist to: $SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md
Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-software-docs-minion.md
```

This produces two outputs: the checklist (consumed by Phase 8) and the verdict (consumed by the Phase 3.5 verdict processing loop). The verdict is still APPROVE/ADVISE/BLOCK -- software-docs-minion can still BLOCK if the plan has no documentation consideration at all, or ADVISE if coverage is thin. The checklist is the actionable artifact.

### 5. Consistency with #48 Approval Gate Pattern

The discretionary reviewer gate should reuse the same structural pattern introduced in #48 for the Team Approval Gate:
- Same AskUserQuestion structure (header, question, 3 options)
- Same adjustment cap (2 rounds)
- Same reject semantics (no reject here -- "Skip discretionary" is the lightweight alternative)
- Same CONDENSE behavior (no separate CONDENSE line after gate approval)

This consistency reduces cognitive load for the user: they learn one gate interaction pattern and it works everywhere.

## Proposed Tasks

### Task 1: Update SKILL.md Phase 3.5 Reviewer Identification
- **What**: Replace the current ALWAYS/Conditional roster in SKILL.md (lines ~607-621) with the new 5-ALWAYS / 6-discretionary split. Add the discretionary reviewer gate between "Identify Reviewers" and "Spawn Reviewers".
- **Deliverables**: Updated `skills/nefario/SKILL.md` Phase 3.5 section
- **Dependencies**: None (but should be consistent with #48 gate pattern if already merged)

### Task 2: Narrow software-docs-minion Phase 3.5 Prompt in SKILL.md
- **What**: Update the Phase 3.5 reviewer prompt template for software-docs-minion to produce the documentation impact checklist instead of a full review. Add the checklist output path (`phase3.5-docs-checklist.md`) to the scratch directory convention.
- **Deliverables**: Updated prompt template in SKILL.md, updated scratch directory structure documentation
- **Dependencies**: Task 1 (needs the new reviewer spawning structure)

### Task 3: Update Phase 8 Checklist Generation Logic in SKILL.md
- **What**: Change Phase 8 step 1 from "generate checklist" to "merge 3.5 checklist with execution-outcome items". Update Phase 8 agent prompts to reference the merged checklist with owner tags. Add conditional skip: "If checklist is empty after merge, skip entirely."
- **Deliverables**: Updated `skills/nefario/SKILL.md` Phase 8 section
- **Dependencies**: Task 2 (needs the checklist format defined)

### Task 4: Update nefario AGENT.md Architecture Review Section
- **What**: Update the "Architecture Review Agents" field in the synthesis output template and the review triggering rules table to reflect the new ALWAYS/discretionary split. Update model selection section if needed.
- **Deliverables**: Updated `nefario/AGENT.md`
- **Dependencies**: Task 1 (needs the roster defined)

### Task 5: Update docs/orchestration.md
- **What**: Update Section 1 Phase 3.5 (review triggering rules table, verdict format, delegation flow diagram) and Section 1 Phase 8 to reflect the checklist handoff. Update the Mermaid sequence diagram to show the discretionary reviewer gate.
- **Deliverables**: Updated `docs/orchestration.md`
- **Dependencies**: Tasks 1-4 (documents the final state)

## Risks and Concerns

### Risk 1: Checklist Staleness After Execution
The Phase 3.5 checklist is generated from the *plan*, not the *execution outcome*. If execution deviates from the plan (new files created, unexpected architectural changes), the checklist will be incomplete. The Phase 8 merge step mitigates this, but the execution-outcome table (SKILL.md lines 1253-1268) must remain as the supplementation source. If it is accidentally removed during the edit, Phase 8 loses its ability to catch execution-time documentation needs.

**Mitigation**: The Phase 8 merge logic should be explicit: "Start with the 3.5 checklist. Then evaluate execution outcomes against the outcome-action table. Add any items not already covered." The outcome table is retained, not replaced.

### Risk 2: Discretionary Gate Adds Interaction Fatigue
The user already goes through the Team Approval Gate (#48) and the Execution Plan Approval Gate. Adding a third gate (discretionary reviewers) between Phase 3 compaction and Phase 3.5 execution creates a three-gate sequence before any code runs. This risks the user developing "click approve" muscle memory.

**Mitigation**: The "Skip discretionary" option gives impatient users a fast path. The gate is deliberately compact (6-10 lines). For plans where no discretionary reviewers are triggered, the gate should be skipped entirely (auto-approve with a CONDENSE note: "Reviewers: 5 mandatory, 0 discretionary"). Only show the gate when there are actual discretionary picks to present.

### Risk 3: ux-strategy-minion Demotion May Miss Journey Issues
Moving ux-strategy-minion from ALWAYS to discretionary means purely backend/infrastructure plans will skip journey coherence review. The current ALWAYS rationale ("every plan needs journey coherence review") was intentional. If nefario misjudges a plan as non-UX-relevant, journey coherence gaps will not be caught.

**Mitigation**: This is an accepted tradeoff per the issue scope. Nefario's discretionary selection logic should include a trigger rule like "1+ tasks affect user-visible workflow or interaction patterns" for ux-strategy-minion, which is broader than the current ux-design-minion trigger.

### Risk 4: Two Output Files from software-docs-minion Creates Ambiguity
Having software-docs-minion write both a checklist (`phase3.5-docs-checklist.md`) and a verdict (`phase3.5-software-docs-minion.md`) breaks the current pattern where each reviewer writes one file. The verdict processing loop in SKILL.md reads `phase3.5-{reviewer-name}.md` -- it will need to be aware that software-docs-minion produces an additional artifact.

**Mitigation**: Keep the verdict file as the primary output (consistent with all other reviewers). The checklist is a secondary artifact referenced from the verdict. The verdict processing loop does not need to change; Phase 8 is the only consumer of the checklist file.

### Risk 5: user-docs-minion in the Discretionary Pool
The issue places user-docs-minion in the discretionary pool for Phase 3.5. This means user-docs-minion may or may not review the plan before execution, but will still be spawned in Phase 8 if the checklist has `[user-docs]` items. This is fine -- Phase 3.5 review and Phase 8 execution are different roles. But the Phase 8 prompt for user-docs-minion should not assume it has Phase 3.5 context.

## Additional Agents Needed

None. The current planning team is sufficient for this task. The changes are to nefario orchestration infrastructure (SKILL.md, AGENT.md, orchestration.md) and do not require additional domain expertise beyond what the planning question targets.

One note: if ux-strategy-minion is part of this planning session, they should weigh in on Risk 3 (their own demotion from ALWAYS to discretionary). Their perspective on which trigger rule adequately captures "plans that need journey coherence review" would strengthen the discretionary selection criteria.
