# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### (a) Meta-Plan Output Template: Excerptable Exclusion Rationale for Team Gate

**Current state.** The meta-plan output template in AGENT.md (lines 459-500)
produces a Cross-Cutting Checklist that contains inclusion/exclusion reasoning
per mandatory dimension:

```
### Cross-Cutting Checklist
- **Testing**: <include test-minion for planning? why / why not>
- **Security**: <include security-minion for planning? why / why not>
- ...
```

The Team gate in SKILL.md currently renders `ALSO AVAILABLE (not selected):`
as a flat comma list. To render `NOT SELECTED (notable):` with one-line
reasons, the SKILL.md gate rendering logic needs to excerpt exclusion entries
from the meta-plan. Today, the checklist mixes inclusion rationale with
exclusion rationale in the same field. There is no separate, machine-excerptable
list of notable exclusions.

**The problem is not that the data does not exist -- it is that the data is
not in a format the gate renderer can excerpt without re-analyzing the full
checklist.** The checklist entries vary in format: some say "Exclude -- no X",
some say "ALWAYS include", some explain both why included AND what other agents
in the dimension were excluded. A gate renderer scanning for "notable exclusions"
would need to parse natural language.

**Proposed change to AGENT.md meta-plan output template.**

Add a `### Notable Exclusions` subsection after the Cross-Cutting Checklist,
inside the meta-plan output format:

OLD (lines 482-500 of AGENT.md):
```
### Cross-Cutting Checklist
<!-- @domain:meta-plan-checklist BEGIN -->
- **Testing**: <include test-minion for planning? why / why not>
- **Security**: <include security-minion for planning? why / why not>
- **Usability -- Strategy**: ALWAYS include -- <planning question for ux-strategy-minion>
- **Usability -- Design**: <include ux-design-minion / accessibility-minion for planning? why / why not>
- **Documentation**: ALWAYS include -- <planning question for software-docs-minion and/or user-docs-minion>
- **Observability**: <include observability-minion / sitespeed-minion for planning? why / why not>
<!-- @domain:meta-plan-checklist END -->

### Anticipated Approval Gates
```

NEW:
```
### Cross-Cutting Checklist
<!-- @domain:meta-plan-checklist BEGIN -->
- **Testing**: <include test-minion for planning? why / why not>
- **Security**: <include security-minion for planning? why / why not>
- **Usability -- Strategy**: ALWAYS include -- <planning question for ux-strategy-minion>
- **Usability -- Design**: <include ux-design-minion / accessibility-minion for planning? why / why not>
- **Documentation**: ALWAYS include -- <planning question for software-docs-minion and/or user-docs-minion>
- **Observability**: <include observability-minion / sitespeed-minion for planning? why / why not>
<!-- @domain:meta-plan-checklist END -->

### Notable Exclusions
<2-3 agents whose exclusion from planning is most likely to surprise the user,
with a one-line reason each. Choose agents whose domain is adjacent to the task
but who were excluded for a specific reason. Skip agents with no plausible
connection to the task. Maximum 3 entries.>

- <agent-name>: <one-line exclusion reason>
- <agent-name>: <one-line exclusion reason>

### Anticipated Approval Gates
```

**Why this works:**
- The Notable Exclusions subsection is a flat, uniform list: `agent-name: reason`.
  The SKILL.md gate renderer can excerpt it directly into the `NOT SELECTED
  (notable):` block without parsing the cross-cutting checklist.
- The checklist remains the authoritative source for the inclusion/exclusion
  decision per dimension. The Notable Exclusions subsection is a curated
  derivative -- nefario picks the 2-3 most surprising exclusions from the
  checklist and the broader roster.
- The "maximum 3 entries" cap matches the advisory's recommendation and keeps
  the Team gate within the 10-16 line budget.
- Nefario is not copying data mechanically -- it is making a judgment call about
  which exclusions are notable. This is appropriate because nefario already makes
  this judgment when selecting the planning team.

**What the SKILL.md renderer does with this data:**
The Team gate format reads `Notable Exclusions` from phase1-metaplan.md and
renders them as:
```
  NOT SELECTED (notable):
    margo                Will review in Phase 3.5 (mandatory reviewer)
    security-minion      No new attack surface; gate changes are prompt-only
    test-minion          No executable output; will review in Phase 3.5
```

No re-analysis required. The excerpting is a direct copy with formatting.

**Token impact:** +3-5 lines in meta-plan output. The Notable Exclusions
subsection adds ~50-80 tokens to the meta-plan. This is negligible -- the
meta-plan is already 200-400 tokens and the scratch file stores it in full.


### (b) Synthesis Output Template: Structured Chosen/Over/Why for Execution Plan Gate

**Current state.** The synthesis output template in AGENT.md (lines 563-564)
specifies conflict resolutions as free text:

```
### Conflict Resolutions
<any disagreements between specialists and how you resolved them>
```

The SKILL.md Execution Plan gate renders this as:
```
CONFLICTS RESOLVED:
  - <what was contested>: Resolved in favor of <approach> because <rationale>
```

Both are one-liners that tell you WHAT was decided but not WHAT was rejected.

**Proposed change to AGENT.md synthesis output template.**

OLD (lines 563-564 of AGENT.md):
```
### Conflict Resolutions
<any disagreements between specialists and how you resolved them>
```

NEW:
```
### Decisions
<non-trivial choices made during synthesis: conflicts between specialists,
trade-offs between approaches, scope decisions. Use Chosen/Over/Why format.
Include only decisions where a real alternative was considered and rejected.
Do not fabricate alternatives -- if a decision was uncontested, it does not
belong here. Maximum 5 entries.>

- **<topic>**
  Chosen: <the approach selected>
  Over: <the rejected alternative(s), with attribution when clear>
  Why: <rationale for this choice over the alternative>

- **<topic>**
  Chosen: ...
  Over: ...
  Why: ...
```

**Key design choices in this format:**

1. **Renamed from "Conflict Resolutions" to "Decisions."** The advisory's
   consensus: many synthesis decisions are trade-offs or scope choices, not
   conflicts. "DECISIONS" is neutral and accurate.

2. **Attribution in "Over" is best-effort.** The format says "with attribution
   when clear" rather than a mandatory `Source:` field. If nefario knows which
   agent advocated the rejected alternative, include it in parentheses:
   `Over: always-visible with status field (security-minion)`. If attribution
   is unclear, omit it. Never fabricate.

3. **Maximum 5 entries.** The advisory recommends capping at 5 inline decisions
   at the Execution Plan gate, with overflow linked to the scratch file. The
   same cap applies here in the synthesis template -- nefario selects the 5 most
   consequential decisions. Additional decisions are captured in the scratch file
   but not in the structured Decisions section.

4. **"Do not fabricate alternatives."** This instruction is critical. Without it,
   the model may invent alternatives to fill the format. The instruction makes
   explicit that uncontested decisions are excluded -- the Decisions section is
   not a changelog, it is a decision record.

**What the SKILL.md renderer does with this data:**
The Execution Plan gate reads the Decisions section from the synthesis and
renders it directly. The `DECISIONS:` block in the gate is a 1:1 copy of the
synthesis Decisions entries with formatting applied:

```
DECISIONS:
  Revoked key visibility
    Chosen: exclude by default, ?include=revoked opt-in
    Over: always-visible with status field (security-minion), soft-delete only (data-minion)
    Why: opt-in aligns with API minimalism; status-field approach leaks internal state
```

The SKILL.md renderer does not need to restructure or interpret. It copies the
entries, applies the gate's visual formatting (backtick labels, indentation),
and caps at 5. If more than 5 exist in the synthesis, the gate shows 5 plus:
`(N more in plan details)`

**Token impact:** The structured format is roughly equivalent in tokens to
free text -- a 3-line Chosen/Over/Why entry is comparable to a detailed
one-line resolution. The structure does not add tokens; it redistributes them.
For 3 decisions: ~120-180 tokens, comparable to 3 detailed one-liners.


### (b.1) Synthesis Output Template: Architecture Review Agents Enrichment

**Current state.** The Architecture Review Agents section (lines 556-561)
captures per-reviewer rationale but not review focus or exclusion rationale:

```
### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: <reviewer name + one-line rationale; reference task numbers>
- **Not selected**: <remaining pool members, comma-separated>
```

**Proposed change.**

OLD:
```
### Architecture Review Agents
<!-- @domain:synthesis-review-agents BEGIN -->
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: <for each discretionary reviewer selected, list: reviewer name + one-line rationale grounded in specific plan content; reference task numbers>
- **Not selected**: <remaining discretionary pool members not selected, comma-separated>
<!-- @domain:synthesis-review-agents END -->
```

NEW:
```
### Architecture Review Agents
<!-- @domain:synthesis-review-agents BEGIN -->
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - <reviewer-name>: <selection rationale referencing task numbers>
    Review focus: <what specifically this reviewer will examine>
  - ...
- **Not selected**:
  - <reviewer-name>: <exclusion rationale referencing specific plan content>
  - ...
<!-- @domain:synthesis-review-agents END -->
```

**Key design choices:**

1. **Discretionary picks become a bullet list with a sub-line.** The
   `Review focus:` sub-line tells the user what specifically the reviewer will
   examine. This is derived from the plan content (e.g., "structured log schema
   consistency across auth + admin handlers") not the reviewer's generic
   capability (e.g., "observability").

2. **Not selected becomes a bullet list with per-member rationale.** The pool is
   only 5 agents (ux-design-minion, accessibility-minion, sitespeed-minion,
   observability-minion, user-docs-minion), so showing all with rationale is
   feasible. Each rationale references specific plan content or absence thereof.

**What the SKILL.md renderer does with this data:**
The Reviewer gate reads the enriched Architecture Review Agents section and
renders both the Review focus sub-lines and the per-member exclusion rationale
directly. No re-analysis needed.

**Token impact:** +1 line per discretionary pick (Review focus), +4-5 lines for
not-selected rationales replacing the comma list. ~60-100 additional tokens in
the synthesis output. Negligible.


### (c) "Gate Rationale" Fallback Field for Gated Tasks

**Current state.** The synthesis task template (lines 530-546) has no field for
pre-execution rationale. The mid-execution gate spec in SKILL.md (lines 1606-1626)
shows RATIONALE and "Rejected: alternative and why" fields, but the data to
populate them must come from the executing agent's output. The agent prompt
(SKILL.md line 1577-1583) only asks for file paths + summary, not rationale.

**The problem:** The mid-execution gate format is aspirational. The RATIONALE
and Rejected fields have no reliable data source. The agent may or may not report
what alternatives it considered. When it does not, the gate renders with empty
or shallow RATIONALE.

**Proposed change to AGENT.md synthesis task template.**

OLD (lines 530-546):
```
### Task 1: <title>
- **Agent**: <agent-name>
- **Delegation type**: standard | DEFERRED (project skill)
- **Model**: opus | sonnet
- **Mode**: bypassPermissions | plan | default
- **Blocked by**: none | Task N, Task M
- **Approval gate**: yes | no
- **Gate reason**: <why this deliverable needs user review before proceeding>
- **Prompt**: |
    <complete, self-contained prompt for the agent>

    ## Available Skills
    The following project skills are available for this task. Read and follow
    their instructions when they are relevant to your work:
    - <name>: <path> (<one-line description>)
- **Deliverables**: <what this agent produces>
- **Success criteria**: <how to verify>
```

NEW:
```
### Task 1: <title>
- **Agent**: <agent-name>
- **Delegation type**: standard | DEFERRED (project skill)
- **Model**: opus | sonnet
- **Mode**: bypassPermissions | plan | default
- **Blocked by**: none | Task N, Task M
- **Approval gate**: yes | no
- **Gate reason**: <why this deliverable needs user review before proceeding>
- **Gate rationale** (gated tasks only): |
    Chosen: <the approach this task will implement>
    Over: <1-2 alternatives considered during synthesis>
    Why: <why this approach was selected>
- **Prompt**: |
    <complete, self-contained prompt for the agent>

    ## Available Skills
    The following project skills are available for this task. Read and follow
    their instructions when they are relevant to your work:
    - <name>: <path> (<one-line description>)
- **Deliverables**: <what this agent produces>
- **Success criteria**: <how to verify>
```

**Key design choices:**

1. **Uses the same Chosen/Over/Why micro-format as Decisions.** This is the
   advisory's universal micro-format applied at the task level. The format is
   identical, making it learnable -- nefario uses the same pattern for
   plan-level decisions and per-task gate rationale.

2. **"(gated tasks only)" annotation.** The field is omitted entirely for
   non-gated tasks. This prevents format bloat on the majority of tasks (typically
   only 1-2 of 6 tasks have gates).

3. **Pre-execution vs. execution-time rationale.** The Gate rationale field
   captures what nefario knows BEFORE the agent runs: the synthesis-time
   reasoning about approach and alternatives. This is distinct from execution-time
   rationale (what the agent actually chose and why during implementation).

   At the mid-execution gate, SKILL.md should merge both:
   - If the agent reported execution-time rationale: render it as the primary
     RATIONALE, and include the Gate rationale as supporting context.
   - If the agent did NOT report rationale: render the Gate rationale as the
     RATIONALE fallback. The gate will show pre-execution reasoning rather than
     nothing.

4. **Structured, not prose.** The field uses labeled lines (Chosen/Over/Why)
   rather than prose. This makes the fallback rendering mechanical -- the SKILL.md
   gate renderer can copy the lines into the RATIONALE section without
   reformatting.

**How this interacts with the agent completion instruction.**

The advisory recommends enriching the SKILL.md Phase 4 agent completion
instruction to ask agents to report approach and rejected alternatives. The
enriched instruction (proposed in the advisory synthesis) is:

```
When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
- If this task has an approval gate: what approach you chose and
  what alternative(s) you considered but rejected, with brief reasons
```

The Gate rationale field and the enriched completion instruction are complementary:
- Gate rationale is the floor: always available, never empty for gated tasks.
- Agent-reported rationale is the ceiling: richer (informed by actual execution)
  but not guaranteed.
- The SKILL.md gate rendering logic uses both, preferring execution-time when
  available, falling back to synthesis-time when not.

**Token impact:** +3 lines per gated task in the synthesis output (~30-50 tokens
per gated task). For a typical plan with 1-2 gates: +60-100 tokens total.
Negligible relative to the synthesis size.


### (d) Compaction Focus Strings: Do They Need to Name "Key Design Decisions"?

**Current compaction focus strings:**

Checkpoint 1 (after Phase 3):
```
Preserve: current phase (3.5 review next), synthesized execution plan,
inline agent summaries, task list, approval gates, team name, branch name,
$summary, scratch directory path.
Discard: individual specialist contributions from Phase 2.
```

Checkpoint 2 (after Phase 3.5):
```
Preserve: current phase (4 execution next), final execution plan with ADVISE
notes incorporated, inline agent summaries, gate decision briefs, task list
with dependencies, approval gates, team name, branch name, $summary, scratch
directory path, skills-invoked.
Discard: individual review verdicts, Phase 2 specialist contributions, raw
synthesis input.
```

**Analysis: do these need changes?**

The key question is whether the enriched data (Decisions section with
Chosen/Over/Why, Gate rationale fields, Notable Exclusions, per-reviewer
Review focus and exclusion rationale) survives compaction through these focus
strings.

**The answer is: no changes needed to the focus string content.** Here is why:

1. **The enriched data lives inside the synthesis output.** The Decisions
   section, Gate rationale fields, and Architecture Review Agents enrichments
   are all part of the synthesis plan (phase3-synthesis.md). Both focus strings
   preserve "synthesized execution plan" / "final execution plan" -- this
   covers the synthesis as a unit, including all its subsections.

2. **Notable Exclusions live in the meta-plan.** The meta-plan is captured
   in phase1-metaplan.md (scratch file, survives compaction by being on disk).
   It is also summarized in the inline summary and the Team gate output, both
   of which are in the conversation context. The Team gate happens before
   either compaction checkpoint, so by the time compaction runs, the Notable
   Exclusions have already been presented to the user and the gate decision is
   recorded.

3. **"Gate decision briefs" in checkpoint 2 covers the enriched Execution Plan
   gate output.** The Decisions section renders at the Execution Plan gate,
   which happens after Phase 3.5 review. The gate output is in the conversation
   context and explicitly preserved by "gate decision briefs."

4. **Compaction operates on the conversation context, not scratch files.**
   The scratch files are on disk and survive compaction regardless of focus
   strings. The focus strings guide what the compaction model retains from the
   conversation history. Since the enriched data is either (a) inside the
   synthesis plan (preserved as a unit) or (b) in scratch files (not subject
   to compaction), the focus strings do not need to name specific subsections.

**Should we add "key design decisions" to the focus string anyway, as a safety
margin?** No. Adding it would be harmless but misleading -- it implies the
compaction model needs explicit guidance to preserve that subsection, when in
fact it is preserved because it is part of the "execution plan" that is already
named. Over-specifying focus strings risks the opposite problem: the model
treats unlisted subsections as less important, potentially discarding other
synthesis data we forgot to name. The current approach -- preserving the plan
as a unit -- is more robust.

**One narrow exception:** If a future change moves decision data OUT of the
synthesis (e.g., into a separate section in the conversation context), then
the focus strings would need updating. But the current design keeps all
decision data inside the synthesis output, so this is not an issue.


## Proposed Tasks

### Task 1: Enrich AGENT.md upstream data formats

**What**: Apply four targeted format changes to AGENT.md:

1. Add `### Notable Exclusions` subsection to meta-plan output template (after
   Cross-Cutting Checklist, before Anticipated Approval Gates). 2-3 agents
   whose exclusion is most likely to surprise, with one-line reasons. Max 3.

2. Rename `### Conflict Resolutions` to `### Decisions` in synthesis output
   template. Replace free-text format with structured Chosen/Over/Why entries.
   Max 5 entries. Include instruction: "Do not fabricate alternatives."

3. Add `- **Gate rationale** (gated tasks only):` field to synthesis task
   template, between `Gate reason` and `Prompt`. Uses same Chosen/Over/Why
   micro-format.

4. Enrich `### Architecture Review Agents` section: Discretionary picks become
   bullet list with `Review focus:` sub-line. Not selected becomes bullet list
   with per-member exclusion rationale.

**Deliverables**: Modified `nefario/AGENT.md`
**Dependencies**: None (upstream format specification, must complete before
SKILL.md rendering changes)

### Task 2: Enrich SKILL.md gate rendering formats

**What**: Apply rendering changes to all four gate types in SKILL.md, consuming
the enriched upstream data from Task 1:

1. **Team gate**: Add `NOT SELECTED (notable):` block excerpted from meta-plan
   Notable Exclusions. Replace `ALSO AVAILABLE (not selected):` flat list with
   `NOT SELECTED (notable):` + shorter `Also available:` remainder. Update line
   budget from 8-12 to 10-16.

2. **Reviewer gate**: Add `Review focus:` sub-line per discretionary pick.
   Replace flat `NOT SELECTED from pool:` comma list with per-member exclusion
   rationale. Update line budget from 6-10 to 7-13.

3. **Execution Plan gate**: Rename `CONFLICTS RESOLVED:` to `DECISIONS:`.
   Render Chosen/Over/Why entries directly from synthesis. Cap at 5 inline,
   overflow linked to scratch file. Update line budget from 25-40 to 35-55.

4. **Mid-execution gate**: Add good/bad RATIONALE examples. Enrich agent
   completion instruction to ask for approach and rejected alternatives.
   Add rendering logic: prefer execution-time rationale, fall back to Gate
   rationale from synthesis. No format change to the gate template itself.

**Deliverables**: Modified `skills/nefario/SKILL.md`
**Dependencies**: Task 1 (AGENT.md upstream formats must be defined first so
SKILL.md rendering matches)


## Risks and Concerns

### Risk 1: Nefario may produce inconsistent Notable Exclusions

The Notable Exclusions subsection asks nefario to make a judgment call about
which exclusions are "most likely to surprise the user." This is subjective.
Different nefario invocations may produce different selections for similar tasks.

**Mitigation**: The selection criteria is constrained: "agents whose domain is
adjacent to the task but who were excluded for a specific reason." The max 3
cap limits the variability surface. And the cross-cutting checklist remains the
authoritative source -- Notable Exclusions is a curated excerpt, not a
replacement.

### Risk 2: "Do not fabricate alternatives" may be ignored under pressure

The instruction to avoid fabricating alternatives in the Decisions section is a
soft constraint. Under high task complexity, the model may generate plausible-
sounding alternatives that were never actually considered by any specialist.

**Mitigation**: The format includes optional attribution ("with attribution when
clear"). Fabricated alternatives would lack attribution, which is a detectable
signal. The advisory recommends making attribution best-effort, not mandatory --
this naturally flags entries where the model is less confident. During review,
lucy can verify that Decision entries map to actual specialist recommendations.

### Risk 3: Gate rationale may duplicate the task prompt context

The Gate rationale field captures approach and alternatives at the synthesis
level. The task prompt itself also contains context about why this approach was
chosen. There is a risk of duplication.

**Mitigation**: The Gate rationale is structured (Chosen/Over/Why) while the
prompt context is prose. They serve different purposes: the Gate rationale feeds
the gate renderer directly, while the prompt context guides the executing agent.
Duplication of ~30-50 tokens is acceptable for the reliability gain of having
a structured fallback.


## Additional Agents Needed

None. The two tasks (AGENT.md upstream + SKILL.md rendering) are both in the
prompt engineering domain. The advisory already provided the analysis; this
planning phase translates it into precise specs.
