## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### 1. Add a `Decisions` field to the Inline Summary Template

The current inline summary template captures `Recommendation`, `Tasks`, `Risks`, and `Conflicts` but NOT the specialist's design decisions with their rationale. Synthesis can only surface what the summaries preserve. Add a `Decisions` field that captures the key choices each specialist made:

```
## Summary: {agent-name}
Phase: {planning | review}
Recommendation: {1-2 sentences}
Tasks: {N} -- {one-line each, semicolons}
Risks: {critical only, 1-2 bullets}
Conflicts: {cross-domain conflicts, or "none"}
Decisions: {key design choices with brief rationale, semicolons; or "none"}
Verdict: {APPROVE | ADVISE(details) | BLOCK(details)} (Phase 3.5 reviewers only)
Full output: $SCRATCH_DIR/{slug}/phase2-{agent-name}.md
```

Token impact: +20-40 tokens per summary (one line of semicolon-separated choices). For a 6-agent team, that is +120-240 tokens total -- well within budget.

The `Decisions` field captures WHAT was chosen and WHY in compressed form. Example:
```
Decisions: structured output over freeform text (guaranteed schema compliance, 0.1x validation cost); Haiku for triage, Opus for synthesis (cost: $0.003/req vs $0.015/req)
```

This is the critical link. Without decisions flowing through inline summaries, synthesis can only reconstruct them by reading scratch files. After compaction, the inline summaries are all that remain in context -- and right now they carry no decision information.

#### 2. Require synthesis to emit a `Key Design Decisions` block

The AGENT.md synthesis output format (MODE: SYNTHESIS) has `Conflict Resolutions` and `Risks and Mitigations` sections but no dedicated section for design decisions that were NOT conflicts. Most design decisions are uncontested choices where one specialist recommended an approach and nobody disagreed. These are invisible in the current format.

Add a `Key Design Decisions` section to the synthesis delegation plan output:

```
### Key Design Decisions

| Decision | Choice | Rejected Alternatives | Rationale | Source |
|----------|--------|----------------------|-----------|--------|
| <what was decided> | <chosen approach> | <what was not chosen> | <why> | <agent-name> |
```

This table is the structured equivalent of what the WRL `decisions.md` files contain. It flows directly to the gate.

Synthesis already reads scratch files to resolve conflicts. The incremental cost of also extracting decisions from specialist contributions is near zero -- the scratch files are already being read. The new `Decisions` field in inline summaries gives synthesis the key inputs without re-reading scratch files in compacted contexts.

#### 3. Surface the decisions table at the Execution Plan Approval Gate

The Execution Plan Approval Gate currently shows: orientation, task list, advisories, risks, conflicts resolved, review summary, and plan link. Add a `DECISIONS:` block between ADVISORIES and RISKS:

```
`DECISIONS:`
  TSA provider: DigiCert — Rejected: FreeTSA (untrusted CA), custom TSA (over-engineering)
  ASN.1 parsing: Hand-rolled codec — Rejected: asn1.js (8K lines for 2 types)
  Chain validation: Deferred — Rationale: no node:tls in Workers runtime
```

Format: one line per decision. Choice on the left, rejected alternative or rationale on the right. Maximum 5 decisions shown; if more, show top 5 by downstream impact and add "N more in plan details."

Token impact at the gate: +5-15 lines (50-150 tokens). The gate's target is 25-40 lines; this stretches it to 30-55 lines. That is acceptable -- decisions are the highest-value information at the gate, and the user's primary complaint is that they are missing.

#### 4. Preserve decisions through compaction checkpoints

The compaction focus strings are the critical survival mechanism. Currently:

Phase 3 checkpoint preserves: "synthesized execution plan, inline agent summaries, task list, approval gates."
Phase 3.5 checkpoint preserves: "final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates."

Neither mentions decisions. The compactor has no signal to retain decision rationale.

Update both focus strings to explicitly mention decisions:

Phase 3: `"Preserve: current phase (3.5 review next), synthesized execution plan, key design decisions table, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2."`

Phase 3.5: `"Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, key design decisions table, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path, skills-invoked. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."`

Adding "key design decisions table" to the focus string costs 4 tokens in the focus string itself but signals the compactor to preserve potentially 100-200 tokens of decision data.

#### 5. Reviewer verdicts should annotate the decisions table, not duplicate it

Currently, reviewer ADVISE verdicts are structured as standalone blocks (SCOPE, CHANGE, WHY, TASK). These are well-designed for task prompt injection but do not cross-reference the decisions table.

Add an optional `DECISION:` field to the ADVISE format:

```
- [security]: HTTPS default for TSA endpoint
  SCOPE: TSA URL configuration in src/rfc3161.js
  CHANGE: Default to HTTPS endpoint
  WHY: Zero-cost security improvement over HTTP
  TASK: Task 2
  DECISION: HTTP vs HTTPS for TSA URL
```

When present, the DECISION field links the advisory to a specific row in the decisions table. At the gate, these linked advisories appear as annotations on the relevant decision row, not as separate advisory blocks. This reduces duplication and makes the relationship between reviewer feedback and design choices visible.

This field is optional -- most advisories are about implementation details, not high-level decisions. Only advisories that directly challenge or modify a design choice should include it.

#### 6. Do NOT create a separate "decisions summary" scratch file

The planning question asks whether synthesis should produce a separate "decisions summary" block. I recommend against this. The decisions table belongs INSIDE the delegation plan (phase3-synthesis.md), not as a separate file. Reasons:

- A separate file creates a synchronization problem: if synthesis revises the plan during BLOCK resolution, the separate decisions file may diverge.
- The compaction focus string can reference "key design decisions table" as part of the execution plan. A separate file would need its own compaction mention and its own lifecycle management.
- The WRL decisions.md is a post-hoc record for human consumption. The in-flow decisions table is a planning artifact for gate presentation. Different purposes, different locations.

#### 7. CONDENSE lines for reviewer verdicts should preserve decision-relevant findings

Currently, reviewer CONDENSE lines are: `"Review: 4 APPROVE, 0 BLOCK"`. This discards which decisions reviewers validated or challenged. Add decision-relevant detail to the review CONDENSE:

```
Review: 4 APPROVE, 1 ADVISE (security: HTTPS default for TSA URL) | 0 BLOCK
```

When there are ADVISE verdicts, name the decision they relate to (if the DECISION field is present) or the SCOPE. This costs ~10-20 tokens per CONDENSE line but preserves the most important review finding in session context.

### Proposed Tasks

#### Task 1: Update the Inline Summary Template in SKILL.md
- **What**: Add the `Decisions` field to the inline summary template. Update the token budget estimate from ~80-120 to ~100-160 tokens per summary.
- **Deliverables**: Modified SKILL.md (Inline Summary Template section)
- **Dependencies**: None

#### Task 2: Add Key Design Decisions section to the AGENT.md synthesis output format
- **What**: Add a `### Key Design Decisions` table to the MODE: SYNTHESIS output format in AGENT.md. Add instructions for nefario to extract decisions from specialist contributions (via inline summary `Decisions` fields + scratch file reading).
- **Deliverables**: Modified AGENT.md (MODE: SYNTHESIS section)
- **Dependencies**: Task 1 (synthesis needs to know the new inline summary format)

#### Task 3: Add DECISIONS block to the Execution Plan Approval Gate in SKILL.md
- **What**: Add the `DECISIONS:` block to the gate presentation format. Update line budget guidance from 25-40 to 30-55. Add format rules for decisions (one line per decision, max 5 shown, rejected alternatives required).
- **Deliverables**: Modified SKILL.md (Execution Plan Approval Gate section)
- **Dependencies**: Task 2 (gate presents what synthesis produces)

#### Task 4: Update compaction focus strings in SKILL.md
- **What**: Add "key design decisions table" to both Phase 3 and Phase 3.5 compaction focus strings. This is a surgical text replacement in two locations.
- **Deliverables**: Modified SKILL.md (Compaction Checkpoint sections)
- **Dependencies**: Task 2 (the decisions table must exist before we tell compaction to preserve it)

#### Task 5: Add optional DECISION field to ADVISE verdict format
- **What**: Add the optional `DECISION:` field to the ADVISE format in AGENT.md and in the reviewer prompt template in SKILL.md. Document that this field links an advisory to a row in the decisions table. Update gate presentation logic to render linked advisories as decision annotations.
- **Deliverables**: Modified AGENT.md (Verdict Format section), modified SKILL.md (reviewer prompt template, gate advisory rendering)
- **Dependencies**: Task 2 (the decisions table must exist for the field to reference)

### Risks and Concerns

1. **Context window growth risk (MEDIUM)**: The new `Decisions` field in inline summaries adds ~120-240 tokens across a 6-agent team. The decisions table in synthesis adds ~100-200 tokens. The DECISIONS block at the gate adds ~50-150 tokens. Total: ~270-590 tokens of new persistent content. This is manageable (under 1% of a 200K context window) but should be monitored. If decision tables grow large (10+ decisions), the max-5-at-gate rule becomes important.

2. **Compaction fidelity risk (MEDIUM)**: Adding "key design decisions table" to the compaction focus string signals intent but does not guarantee preservation. The `/compact` command uses a model to summarize; it may still compress decisions if context pressure is high. Mitigation: the decisions table uses a structured format (markdown table) that compacts well and resists lossy summarization better than prose.

3. **Specialist adoption risk (LOW)**: Specialists need to populate the `Decisions` field in their inline summaries. If they do not (because the field is new and their prompts do not emphasize it), synthesis falls back to extracting decisions from scratch files. This is the current behavior, so the fallback is no worse than today. The prompt template in Phase 2 should include a note about the Decisions field.

4. **Gate length creep risk (LOW)**: The execution plan approval gate grows from 25-40 to 30-55 lines. This is still within a single screen for most terminals. The max-5-decisions cap prevents unbounded growth. However, if a plan has 5 decisions + 5 advisories + 3 risks + 3 conflicts, the gate could reach 70+ lines. Consider a combined "design rationale" section that merges decisions and conflicts if both are present.

5. **BLOCK revision loop complexity (LOW)**: When a BLOCK triggers plan revision, the decisions table in the revised synthesis must be updated. This is natural (nefario rewrites the synthesis) but adds to the revision prompt's cognitive load. The decisions table is small and structured, so this is low risk.

### Additional Agents Needed

- **ux-strategy-minion**: Already included in this advisory. The gate presentation format is a user-facing interaction design problem -- ux-strategy should evaluate whether the DECISIONS block adds cognitive load or reduces it. They should also assess progressive disclosure: should decisions be collapsed by default?

- **software-docs-minion**: The execution report template in `docs/history/nefario-reports/TEMPLATE.md` has a "Key Design Decisions" section. Changes to how decisions flow through the system should be reflected in how they appear in reports. software-docs-minion should ensure consistency between the gate presentation and the report format.

No other additional agents needed. The changes are concentrated in SKILL.md and AGENT.md, which are prompt engineering artifacts within ai-modeling-minion's domain.
