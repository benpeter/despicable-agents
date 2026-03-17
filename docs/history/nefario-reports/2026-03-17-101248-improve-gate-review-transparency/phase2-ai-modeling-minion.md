# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### Pipeline Analysis: Where Gate Data Originates and Where It Gets Lost

The nefario pipeline has four distinct data-producing stages and two compaction
boundaries. Gate transparency failures are not rendering problems -- they are
data flow problems. The system cannot display rationale it never produced or
discarded before rendering.

**Current data flow map:**

```
AGENT.md (meta-plan format)     -> phase1-metaplan.md
                                       |
                              [inline summary template]
                                       |
                                       v
AGENT.md (synthesis format)     -> phase3-synthesis.md
                                       |
                              [inline summary template]
                                       |
                              [compaction checkpoint 1]  <-- Phase 2 contributions discarded
                                       |
                              [Phase 3.5 review verdicts]
                                       |
                              [compaction checkpoint 2]  <-- Review verdicts discarded
                                       |
                                       v
SKILL.md (gate rendering)      -> user-facing gate output
```

Each gate type has a different data source and a different loss point:

| Gate | Data Source | Loss Point | Root Cause |
|------|-----------|------------|------------|
| Team (P1) | phase1-metaplan.md | Never captured in inline summary | Meta-plan format produces planning questions + exclusion rationale, but SKILL.md gate template only renders agent name + one-liner |
| Reviewer (P3.5) | phase3-synthesis.md Architecture Review Agents section | Never expanded beyond one-liner | Synthesis format only captures `reviewer name + one-line rationale` per discretionary pick |
| Exec Plan (P3.5) | phase3-synthesis.md Conflict Resolutions section | Rendered but under-structured | Synthesis format allows free-text conflict resolutions; no Chosen/Over/Why structure enforced |
| Mid-exec (P4) | Execution agent output | Data may not exist | Agent prompt asks for deliverables and summary; RATIONALE/Rejected fields depend on data the agent may not produce |

### Gate-by-Gate Recommendations

#### 1. Team Gate (P1)

**Problem**: The meta-plan output format in AGENT.md produces rich data per
specialist (planning question, context to provide, "why this agent"), but the
SKILL.md gate rendering only shows `agent-name  one-line-rationale`. The
planning questions and exclusion rationale are buried in the scratch file.

**Data already exists but is not rendered.** This is a pure SKILL.md rendering
change -- no AGENT.md format change needed for the core fix.

**Proposed SKILL.md gate format change:**

```
SELECTED:
  devx-minion          Workflow integration, SKILL.md structure
    Question: How should the approval gate interact with existing skill patterns?
  ux-strategy-minion   Approval gate interaction design
    Question: What cognitive load does an additional gate add to the orchestration flow?
  lucy                 Governance alignment for new gate
    Question: Does this new gate align with the existing gate philosophy in CLAUDE.md?

NOT CONSULTED (rationale):
  security-minion      No new attack surface; gate is a prompt change, not a runtime change
  margo                Will review in Phase 3.5 (mandatory reviewer)
```

**Changes required:**
- SKILL.md Team Approval Gate Presentation format: Add `Question:` sub-line per
  selected agent. Replace `ALSO AVAILABLE` with `NOT CONSULTED (rationale):`
  showing top 3-5 exclusions with one-line reasons (not all 19+ remaining agents).
- AGENT.md meta-plan format: No change needed. The existing `Planning question`
  and `Why this agent` fields already produce this data.
- Inline summary: No change needed. The gate reads directly from the
  phase1-metaplan.md scratch file.

**Token impact:** +2 lines per selected agent (question), +5 lines for exclusion
block. For an 8-agent team: +21 lines. Gate grows from 8-12 to ~25-30 lines.
This is acceptable -- the Team gate is currently the lightest gate but the
decision it governs (which specialists to consult) shapes the entire plan.

**Key trade-off:** Showing all 19+ non-selected agents with rationale is too
verbose. Show the top 3-5 exclusions most likely to surprise the user (agents
whose domain is adjacent to the task). The rest go in the scratch file.

#### 2. Execution Plan Gate (P3.5 Plan)

**Problem**: CONFLICTS RESOLVED is free-text with no structure. Real example:
`"Revoked key visibility: exclude by default, ?include=revoked opt-in (api-design-minion)"`
-- this tells you WHAT was decided and WHO recommended it, but not WHAT WAS
REJECTED or WHY the alternative lost.

**Proposed AGENT.md synthesis format change for Conflict Resolutions:**

Current format (free text):
```
### Conflict Resolutions
<any disagreements between specialists and how you resolved them>
```

Proposed structured format:
```
### Conflict Resolutions
- **<topic>**
  Chosen: <approach selected>
  Over: <rejected alternative(s)>
  Why: <rationale for choice>
  Source: <agent-name who advocated chosen> vs <agent-name who advocated rejected>
```

This is the most impactful single change. Every conflict resolution becomes a
mini-decision record that renders naturally at the gate.

**Corresponding SKILL.md gate format change:**

Current:
```
CONFLICTS RESOLVED:
  - <what was contested>: Resolved in favor of <approach> because <rationale>
```

Proposed:
```
CONFLICTS RESOLVED:
  - <topic>: <chosen approach> (over: <rejected alternative>)
    Why: <rationale>
```

The `Source:` field from synthesis is available in the scratch file but omitted
from the gate rendering (internal attribution, not useful for user decisions).

**ADVISORIES**: The current advisory format (CHANGE + WHY) is already well-
structured. The gap is that advisories do not show what the ORIGINAL plan said
before the advisory modified it. For the gate to show the delta, synthesis needs
to capture both states.

**Proposed addition to AGENT.md advisory format in synthesis output:**

Add an optional `WAS:` field to each advisory note in the synthesis:
```
- [domain] <artifact> (Task N)
  WAS: <what the plan originally said, before this advisory>
  CHANGE: <what the advisory changed it to>
  WHY: <rationale>
```

This is only populated when an advisory actually CHANGED a task. Informational
advisories ("No task changes") omit `WAS:`. The SKILL.md rendering can then
optionally show the delta inline for high-impact advisories.

**Token impact:** +1 line per conflict (structured vs free-text is roughly
equivalent in tokens). +1 line per advisory that has a WAS field (estimated
50-70% of advisories). Net: +5-12 lines on a typical plan. Keeps gate within
the 25-40 line budget if we show WAS only for the first 3 advisories and
collapse the rest behind the Details link.

#### 3. Mid-Execution Gate (P4)

**Problem**: The SKILL.md format specifies RATIONALE and "Rejected: alternative
and why" but the data to populate these fields must come from the executing
agent's output. The current agent prompt (SKILL.md Phase 4, step 3) asks agents
to report only file paths + change scope + summary. There is no instruction to
report rationale or rejected alternatives.

**This is the hardest gate to fix because the data pipeline is the longest:**
synthesis produces a task prompt -> executing agent runs -> agent output is
captured -> gate renders the output. The RATIONALE and Rejected fields in the
gate format are aspirational -- no upstream data feeds them.

**Two sources of rationale data:**

1. **Pre-execution rationale**: WHY this task exists and what alternatives
   were considered during synthesis. This data exists in the synthesis output
   (gate reason, task prompt context) but is not currently rendered at the gate.

2. **Execution-time rationale**: What the agent chose to do and why. This
   requires the agent prompt to explicitly ask for it.

**Proposed changes:**

A. **AGENT.md synthesis format -- add per-task rationale fields:**

```
### Task N: <title>
- **Agent**: <agent-name>
- ...existing fields...
- **Gate rationale**: |
    DECISION: <one-sentence summary of what this task will decide>
    KEY ALTERNATIVES: <1-2 alternatives considered during synthesis>
    WHY THIS APPROACH: <why this approach was chosen over alternatives>
- **Prompt**: |
    ...existing prompt content...
```

The `Gate rationale` field is only populated for gated tasks. It provides the
pre-execution rationale that is KNOWN before the agent runs.

B. **SKILL.md Phase 4 agent prompt -- add deliverable reporting instruction:**

Current instruction at end of agent prompt:
```
When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
```

Proposed:
```
When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
- If this task has an approval gate: what approach you chose and
  what alternative(s) you considered but rejected, with brief reasons
```

C. **SKILL.md gate rendering -- merge pre-execution and execution rationale:**

The RATIONALE section in the mid-execution gate should draw from both:
1. Synthesis-time `Gate rationale` (pre-execution context)
2. Agent's reported rationale (execution-time choices)

When the agent does NOT report rationale (it is a soft ask, not enforceable),
fall back to the synthesis-time rationale only.

**Token impact:** +3 lines in synthesis per gated task (Gate rationale field).
+1-2 lines in agent completion message. +0 lines at gate rendering (RATIONALE
section already exists in the template, just under-populated). Net synthesis
growth: ~15-20 tokens per gated task. Negligible.

#### 4. Reviewer Gate (P3.5 Review)

**Problem**: The gate currently shows mandatory list + discretionary picks with
one-line rationale + not-selected pool. It is the thinnest gate in the system,
which is appropriate for its decision scope (who reviews, not what to build).

**What data exists at this point:**
- The full synthesis plan (phase3-synthesis.md)
- Synthesis-computed Architecture Review Agents section with per-reviewer rationale
- The task list with deliverables
- The cross-cutting coverage checklist

**The decision the user is making:** Which reviewers examine the plan before
execution. The key question is: "Will these reviewers catch the issues that
matter for THIS specific plan?"

**Proposed SKILL.md gate format enrichment:**

Current:
```
DISCRETIONARY (nefario recommends):
  observability-minion   6+ new log event types need coordinated schema review (Tasks 1, 3)
```

Proposed:
```
DISCRETIONARY (nefario recommends):
  observability-minion   6+ new log event types need coordinated schema review (Tasks 1, 3)
    Review focus: structured log schema consistency across auth + admin handlers

NOT SELECTED (with rationale):
  ux-design-minion       No UI components produced (all API + config changes)
  accessibility-minion   No web-facing HTML/UI in plan
  sitespeed-minion       No browser-facing runtime code in plan
  user-docs-minion       No end-user behavior changes (admin-only feature)
```

Changes:
- Add `Review focus:` sub-line per discretionary reviewer, stating what they
  will specifically look at (derived from synthesis Architecture Review Agents
  section + plan content).
- Replace `NOT SELECTED from pool:` flat list with structured rationale for
  each non-selected pool member. The pool is only 5 agents, so showing all
  with rationale is feasible (unlike Team gate's 19+ non-selected agents).

**Data source:** The synthesis `Architecture Review Agents` section already has
`Discretionary picks: reviewer name + one-line rationale grounded in specific
plan content`. The `Review focus` is a new field that needs to be added to the
synthesis format.

**AGENT.md synthesis format change:**

```
### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - <reviewer>: <selection rationale> | Review focus: <what specifically to examine>
  - ...
- **Not selected**:
  - <reviewer>: <exclusion rationale referencing specific plan content>
  - ...
```

**Token impact:** +1 line per discretionary reviewer (review focus). +4-5 lines
for not-selected rationales (replacing flat comma list). Gate grows from 6-10
to ~12-16 lines. Still lighter than the execution plan gate.

### 5. Compaction Survival Strategy

**Current state:** Two compaction checkpoints exist:
1. After Phase 3 synthesis (discards Phase 2 specialist contributions)
2. After Phase 3.5 review (discards review verdicts)

The compaction focus strings explicitly name what to preserve and discard.

**Impact of enriched gates on compaction:**

The enriched data lives in three places:
1. **Scratch files** (survive compaction by design -- they are on disk)
2. **Inline summaries** (in session context, subject to compaction)
3. **Synthesis output** (in session context, subject to compaction)

The good news: most of the new data lives in the synthesis output
(phase3-synthesis.md), which is already preserved through both compaction
checkpoints. The compaction focus string explicitly says "Preserve: synthesized
execution plan" and "final execution plan with ADVISE notes incorporated."

**What needs to change in compaction focus strings:**

Compaction checkpoint 1 (after Phase 3) currently preserves:
```
synthesized execution plan, inline agent summaries, task list, approval gates
```

This already covers the enriched synthesis fields (conflict resolutions with
structure, gate rationale, advisory WAS fields, reviewer focus). No change
needed to the focus string content -- the synthesis is preserved as a unit.

Compaction checkpoint 2 (after Phase 3.5) currently preserves:
```
final execution plan with ADVISE notes incorporated, inline agent summaries,
gate decision briefs, task list with dependencies, approval gates
```

The "gate decision briefs" preservation covers the enriched conflict and
advisory data. The Phase 3.5 reviewer rationale is captured in the synthesis
plan (Architecture Review Agents section), not in the review verdicts that get
discarded. No change needed.

**Token budget impact on compaction:**

Current synthesis output size: estimated 3,000-5,000 tokens for a 6-task plan.
Enriched synthesis output: estimated 3,500-6,000 tokens (+15-20%).

The increase is modest because:
- Structured conflict resolutions are roughly equal in tokens to free-text ones
- Gate rationale adds ~15-20 tokens per gated task (1-2 gated tasks typical)
- Advisory WAS fields add ~10-15 tokens per advisory
- Reviewer review-focus adds ~10-15 tokens per discretionary reviewer

For context, the 200K context window comfortably holds this growth. Even the
1M beta context gives enormous headroom. The compaction checkpoints are
sufficient at their current positions.

**One potential addition:** For very large plans (8+ tasks, 5+ gates), an
optional third compaction checkpoint could be added mid-Phase 4 (between
execution batches). This is already noted in SKILL.md as a future optimization.
The enriched gates do not change the calculus on whether to add it -- context
pressure from Phase 4 agent communication is the primary driver, not gate data.

### 6. Cross-Cutting: The Inline Summary Template

The inline summary template (SKILL.md, Scratch File Convention section) is the
bridge between full agent output and session context. It currently captures:

```
## Summary: {agent-name}
Phase: {planning | review}
Recommendation: {1-2 sentences}
Tasks: {N} -- {one-line each, semicolons}
Risks: {critical only, 1-2 bullets}
Conflicts: {cross-domain conflicts, or "none"}
Verdict: {APPROVE | ADVISE(details) | BLOCK(details)}
Full output: $SCRATCH_DIR/{slug}/phase2-{agent-name}.md
```

This template serves Phase 2 (planning) and Phase 3.5 (review) agents. For the
enriched gates, the template needs one addition:

**Add `Exclusion rationale:` field for meta-plan inline summaries.** Wait -- the
meta-plan is produced by nefario itself, not by specialist agents. The inline
summary template applies to specialist outputs, not nefario outputs. The
meta-plan data is captured directly in phase1-metaplan.md.

The inline summary template does NOT need changes for the gate enrichment work.
The enriched data flows through the synthesis plan and scratch files, both of
which bypass the inline summary.

## Proposed Tasks

### Task 1: Enrich AGENT.md synthesis output format
- **What**: Add structured conflict resolution format (Chosen/Over/Why/Source),
  per-task Gate rationale field, advisory WAS field, reviewer Review focus and
  exclusion rationale to the synthesis output format in AGENT.md
- **Deliverables**: Modified `nefario/AGENT.md` MODE: SYNTHESIS output template
- **Dependencies**: None (format specification change)

### Task 2: Enrich SKILL.md Team gate rendering
- **What**: Add planning questions per selected agent, replace ALSO AVAILABLE
  with NOT CONSULTED showing top 3-5 exclusions with rationale
- **Deliverables**: Modified `skills/nefario/SKILL.md` Team Approval Gate section
- **Dependencies**: None (reads from existing meta-plan format)

### Task 3: Enrich SKILL.md Reviewer gate rendering
- **What**: Add Review focus sub-line per discretionary reviewer, add exclusion
  rationale per non-selected pool member
- **Deliverables**: Modified `skills/nefario/SKILL.md` Reviewer Approval Gate section
- **Dependencies**: Task 1 (requires enriched synthesis format)

### Task 4: Enrich SKILL.md Execution Plan gate rendering
- **What**: Update CONFLICTS RESOLVED rendering to show Chosen/Over/Why,
  optionally show WAS field for high-impact advisories
- **Deliverables**: Modified `skills/nefario/SKILL.md` Execution Plan Approval Gate section
- **Dependencies**: Task 1 (requires enriched synthesis format)

### Task 5: Enrich SKILL.md Mid-execution gate data pipeline
- **What**: Add agent prompt instruction for rationale reporting, merge
  synthesis-time and execution-time rationale in gate rendering
- **Deliverables**: Modified `skills/nefario/SKILL.md` Phase 4 execution and gate sections
- **Dependencies**: Task 1 (requires Gate rationale field in synthesis)

## Risks and Concerns

### Risk 1: Gate verbosity may trigger user fatigue
The whole point of the current compact gate format is to minimize friction.
Adding planning questions, exclusion rationale, and structured conflicts
increases gate size significantly. The Team gate grows from ~10 to ~28 lines.
**Mitigation**: Apply the same progressive disclosure principle used in the
Execution Plan gate. Show the most decision-relevant data inline; put the rest
behind the scratch file link. Test with the user on a real session to calibrate.

### Risk 2: Synthesis output growth creates prompt pressure
The enriched synthesis format adds ~500-1,000 tokens. This is fed to every
Phase 3.5 reviewer as part of their prompt (they read the plan). More tokens
in the reviewer prompt means higher cost per review cycle.
**Mitigation**: The growth is modest relative to the typical plan size
(3,000-5,000 tokens). At Sonnet pricing ($3/MTok input), the additional cost
is ~$0.003 per reviewer. For 7 reviewers, ~$0.02 per orchestration run.
Negligible.

### Risk 3: Mid-execution gate rationale depends on agent cooperation
The executing agent may not report rationale even when asked. The instruction
is a soft ask in the completion message template, not an enforced output schema.
**Mitigation**: Always have the synthesis-time Gate rationale as a fallback.
The gate can render pre-execution rationale even when the agent does not report
execution-time rationale. This is a graceful degradation, not a failure.

### Risk 4: Nefario as subagent may not faithfully produce enriched format
The enriched synthesis format adds more structure. Nefario runs as a subagent
(MODE: SYNTHESIS) which means its output is a function of its system prompt
(AGENT.md). If the format specification is ambiguous or under-exemplified,
the model may produce inconsistent output.
**Mitigation**: Add concrete examples of the enriched conflict resolution and
gate rationale formats in the AGENT.md output template. Examples are the most
reliable format enforcement for Claude models.

## Additional Agents Needed

None. The changes are localized to two files (AGENT.md and SKILL.md) which are
both in the ai-modeling-minion's domain (prompt engineering, orchestration rule
changes). A ux-strategy-minion review of the enriched gate format is valuable
but should happen in Phase 3.5 (architecture review), not as an additional
planning specialist.
