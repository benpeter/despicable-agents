## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### 1. Use heuristic analysis over hardcoded conditionals, but with structured output guardrails

The current Phase 3.5 conditional rules (e.g., "observability-minion: 2+ tasks produce runtime components") are brittle pattern-matching that fails on edge cases. For example, a plan with 1 service task and 1 background worker technically has 2 runtime components but might not match the text pattern "services, APIs, background processes" depending on how the synthesis describes the tasks.

The Phase 1 meta-plan already solves the same class of problem -- nefario analyzes the task, reasons about which domains are relevant, and produces a structured selection with rationale. Phase 3.5 discretionary selection should reuse this same reasoning pattern rather than introducing a separate rule engine.

**Recommended approach**: Give nefario a structured decision framework (not rigid conditionals) that it applies during synthesis. The framework should be:

1. A **domain relevance checklist** that nefario evaluates per discretionary reviewer, asking: "Does this plan produce artifacts in this reviewer's domain?"
2. A **structured output format** for discretionary picks that forces one-line rationale per pick (prevents hallucinated "just in case" selections).
3. An **exclusion discipline** -- nefario must state why each non-selected discretionary reviewer was excluded (same pattern as the cross-cutting checklist's "explicitly state why it's not needed").

This keeps the LLM doing what it is good at (contextual reasoning about plan content) while the structured output format prevents over-inclusion.

#### 2. Prompt pattern for discretionary selection

The most effective prompt pattern for nefario's discretionary selection is a **constrained enumeration** -- force the model to evaluate each discretionary reviewer against the plan rather than free-associating about who might be useful. This is the same pattern used in the cross-cutting checklist (Section "Cross-Cutting Concerns" in AGENT.md), which already requires explicit evaluation of each dimension.

Recommended prompt structure for nefario during synthesis (or as a focused sub-step after synthesis):

```
## Discretionary Reviewer Selection

Evaluate each discretionary reviewer against the delegation plan. For each,
answer: does this plan produce artifacts that this reviewer should inspect?

| Reviewer | Domain Signal | Include? | Rationale |
|----------|--------------|----------|-----------|
| ux-strategy-minion | Plan includes user-facing workflow changes, journey modifications, or cognitive load implications | yes/no | <one line> |
| ux-design-minion | Plan includes tasks producing UI components, visual layouts, or interaction patterns | yes/no | <one line> |
| accessibility-minion | Plan includes tasks producing web-facing HTML/UI that end users interact with | yes/no | <one line> |
| sitespeed-minion | Plan includes tasks producing web-facing runtime code (pages, APIs serving browsers, assets) | yes/no | <one line> |
| observability-minion | Plan includes 2+ tasks producing runtime components that need coordinated logging/metrics/tracing | yes/no | <one line> |
| user-docs-minion | Plan includes tasks whose output changes what end users see, do, or need to learn | yes/no | <one line> |
```

The "Domain Signal" column is the key innovation here. Rather than hardcoded trigger rules, it provides a **heuristic anchor** -- a concise description of what to look for in the plan. The LLM uses this as a pattern to match against, which is more flexible than rigid conditionals but more constrained than open-ended "decide who should review."

This is analogous to giving an LLM few-shot examples vs. giving it rules. The domain signal column serves as an implicit example of what "relevant" means for each reviewer.

#### 3. Reuse the Phase 2 team approval gate pattern exactly

The discretionary reviewer approval gate should reuse the same AskUserQuestion pattern from Phase 2 (#48). The presentation format should be nearly identical:

```
REVIEWERS: <1-sentence plan summary>
Mandatory: security-minion, test-minion, software-docs-minion, lucy, margo
Discretionary: N selected from pool of 6

  SELECTED:
    ux-design-minion       Plan produces React component layouts (Tasks 2, 4)
    accessibility-minion   Web-facing UI in Task 2 needs WCAG review

  NOT SELECTED (available on request):
    ux-strategy-minion, sitespeed-minion, observability-minion, user-docs-minion

Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md
```

Decision options via AskUserQuestion:
- header: "Reviewers"
- question: "<1-sentence summary of reviewer selection>"
- options (3, multiSelect: false):
  1. label: "Approve reviewers", description: "Run mandatory + selected discretionary reviewers." (recommended)
  2. label: "Adjust reviewers", description: "Add or remove discretionary reviewers before review begins."
  3. label: "Skip discretionary", description: "Run mandatory reviewers only."

The third option ("Skip discretionary") is specific to this gate and does not exist in the Phase 2 gate. It provides a fast path for users who trust the mandatory roster is sufficient. This is important because the reviewer gate is a second approval step in quick succession (right after the synthesis compaction checkpoint), and reducing friction here prevents fatigue.

#### 4. Model selection: all reviewers on opus per user directive

The user explicitly requested "use opus for all agents and tasks." The current AGENT.md says "All reviewers run on sonnet except lucy and margo, which run on opus." This needs to change to opus for all reviewers in Phase 3.5. However, this is a session-level override from the user's additional context, not necessarily a permanent change to the agent specs. The implementation should respect the user's directive for this execution while keeping the default model selection logic intact in the agent definitions.

Recommendation: In the AGENT.md and SKILL.md, keep the default model selection guidance (sonnet for most, opus for governance). The user's "use opus" directive is handled at invocation time by the orchestrator, which already supports model overrides ("Override: If the user explicitly requests a specific model, honor that request" -- AGENT.md line 402).

#### 5. software-docs-minion role narrowing in Phase 3.5

The current role for software-docs-minion as an ALWAYS reviewer is "Architectural and API surface changes need documentation review. Even non-architecture tasks benefit from documentation gap analysis." This is too broad for a reviewer that runs on every single plan.

Narrowing to a **documentation impact checklist** is the right call. The prompt pattern for software-docs-minion in Phase 3.5 should produce a structured checklist (not a narrative review) that Phase 8 consumes as a work order. This is a classic "structured output as handoff artifact" pattern:

```
## Documentation Impact Checklist

For each task in the plan, assess documentation impact:

| Task | Doc Impact | Type | Action | Priority |
|------|-----------|------|--------|----------|
| Task 1 | yes/no | API ref / ADR / README / guide / config ref | <specific action> | high/medium/low |
| Task 2 | yes/no | ... | ... | ... |

Overall: N tasks need documentation. Recommended Phase 8 scope: <1 sentence>.
```

This gives Phase 8 a concrete work order rather than vague "documentation should be updated" advice. The checklist format also makes the APPROVE/ADVISE/BLOCK verdict more meaningful -- BLOCK means "critical documentation gap that will confuse users if not addressed," not "I have opinions about docs."

#### 6. Phase 8 handoff: checklist consumption

Phase 8 currently generates its own checklist from execution outcomes (SKILL.md lines 1256-1269). With the new software-docs-minion Phase 3.5 checklist, Phase 8 should consume BOTH:

1. The Phase 3.5 pre-execution checklist (what the plan intends to change, assessed before code is written)
2. The existing Phase 8 post-execution checklist (what actually changed, assessed after code is written)

The Phase 3.5 checklist is a **prediction**; the Phase 8 checklist is **ground truth**. Phase 8 should union both, using the Phase 3.5 items as a starting point and the Phase 8 items as validation/additions. Items predicted in 3.5 but not reflected in execution outcomes should be flagged as "planned but not implemented -- verify if still needed."

### Proposed Tasks

#### Task 1: Update AGENT.md Architecture Review section
- **What**: Replace the current 6-ALWAYS + 4-conditional reviewer table with 5-ALWAYS + 6-discretionary. Add the discretionary selection framework (domain signal table). Remove ux-strategy-minion from ALWAYS roster. Add user-docs-minion to discretionary pool.
- **Deliverables**: Updated `nefario/AGENT.md` -- Architecture Review section (~lines 546-574)
- **Dependencies**: None

#### Task 2: Update AGENT.md Synthesis output format
- **What**: Update the `Architecture Review Agents` field in the synthesis output template to use ALWAYS/discretionary terminology. Add the structured discretionary selection table to the synthesis output.
- **Deliverables**: Updated `nefario/AGENT.md` -- MODE: SYNTHESIS section (~lines 509-512)
- **Dependencies**: Task 1 (needs the new roster definition)

#### Task 3: Update SKILL.md Phase 3.5 reviewer identification and approval gate
- **What**: Replace the current "Identify Reviewers" logic with the new ALWAYS/discretionary model. Add the reviewer approval gate (AskUserQuestion pattern). Update the "Spawn Reviewers" section to spawn only approved reviewers. Handle "Adjust reviewers" and "Skip discretionary" responses.
- **Deliverables**: Updated `skills/nefario/SKILL.md` -- Phase 3.5 section (~lines 601-660)
- **Dependencies**: Task 1 (needs the new roster definition from AGENT.md)

#### Task 4: Update SKILL.md software-docs-minion 3.5 prompt
- **What**: Replace the current generic review prompt for software-docs-minion with a focused documentation impact checklist prompt. The output should be structured as a table that Phase 8 can consume.
- **Deliverables**: Updated `skills/nefario/SKILL.md` -- Phase 3.5 reviewer spawn template
- **Dependencies**: Task 1

#### Task 5: Update SKILL.md Phase 8 to consume 3.5 checklist
- **What**: Modify Phase 8's checklist generation to read and merge the Phase 3.5 software-docs-minion checklist with the existing execution-outcome-based checklist. Add delta analysis (predicted vs. actual).
- **Deliverables**: Updated `skills/nefario/SKILL.md` -- Phase 8 section (~lines 1253-1330)
- **Dependencies**: Task 4 (needs the checklist format defined)

#### Task 6: Update docs/orchestration.md
- **What**: Update the Phase 3.5 reviewer triggering rules table, add the reviewer approval gate to the approval gates section, update the delegation flow diagram to show the new gate, and update the Phase 8 documentation section to reference the 3.5 checklist handoff.
- **Deliverables**: Updated `docs/orchestration.md` -- Sections 1.3.5, 3, and 1.8
- **Dependencies**: Tasks 1-5 (documentation reflects implementation)

### Risks and Concerns

#### Risk 1: Discretionary selection becoming rubber-stamped
If nefario's discretionary picks are almost always the same (e.g., always including ux-strategy-minion because "every plan has workflow changes"), the gate becomes noise. Mitigation: the exclusion discipline (nefario must justify non-selection) prevents universal inclusion. The "Skip discretionary" option provides a fast escape when the user considers the picks irrelevant.

#### Risk 2: Two approval gates in quick succession causing fatigue
The Phase 2 team gate and Phase 3.5 reviewer gate are both approval steps that happen within minutes of each other (with Phase 3 synthesis between them). Users may develop "click approve" muscle memory. Mitigation: the reviewer gate is lighter than the team gate (no "Adjust" round needed -- just approve/skip), and the "Skip discretionary" option makes it a 1-click pass-through for most cases.

#### Risk 3: Heuristic analysis selecting reviewers inconsistently
Without rigid conditionals, nefario might include accessibility-minion for one plan with web UI and exclude it for another similar plan. Mitigation: the domain signal table provides anchoring that reduces variance. The structured enumeration forces explicit yes/no for each reviewer, preventing accidental omission. Over time, this is actually more consistent than rigid rules because it adapts to task description phrasing.

#### Risk 4: Phase 3.5 checklist diverging from Phase 8 reality
The Phase 3.5 documentation checklist is a prediction made before code is written. Actual execution may produce different artifacts. Mitigation: Phase 8 unions both checklists and flags divergence. The 3.5 checklist is a starting point, not a contract.

#### Risk 5: Token cost increase from structured enumeration
The discretionary selection table adds ~200 tokens to the synthesis output. With all reviewers on opus (per user directive), Phase 3.5 costs approximately 5 * $5/MTok (input) + 5 * $25/MTok (output) for mandatory reviewers, plus 0-6 discretionary reviewers. Adding the approval gate interaction adds one more turn. Mitigation: the whole point of this change is to REDUCE cost by not spawning irrelevant reviewers. Net cost should be lower unless the user always selects all 6 discretionary reviewers.

### Additional Agents Needed

None. The current planning team is sufficient. The changes are to nefario's own orchestration logic (AGENT.md, SKILL.md) and the orchestration documentation -- these are coordination artifacts, not domain-specialist deliverables. The devx-minion or a similar agent would handle the SKILL.md editing, and software-docs-minion would handle orchestration.md, but those are execution-phase concerns, not additional planning input needed.
