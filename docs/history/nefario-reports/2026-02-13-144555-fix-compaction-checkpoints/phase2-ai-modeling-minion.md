# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### 1. Static focus strings are sufficient -- do not dynamically compose them

The current static focus strings are well-designed for their purpose. They enumerate
the semantic categories of state to preserve (phase number, execution plan, inline
summaries, session variables) and what to discard (raw specialist contributions).

Dynamic composition would require the orchestrator to introspect its own context
window at checkpoint time -- enumerating which inline summaries exist, how many gate
briefs have been recorded, etc. This adds complexity for marginal benefit because:

- The `/compact` focus string is a **natural language hint** to the compaction model,
  not a programmatic filter. The compaction model interprets "inline agent summaries"
  as a category, not a list of specific blocks. Enumerating each summary by name
  does not meaningfully improve retention.
- The static strings already cover the right categories. The Phase 3 string correctly
  says to preserve "inline agent summaries" (plural, category-level) rather than
  listing "Summary: devx-minion, Summary: security-minion, ..." -- the compaction
  model handles this correctly.
- Dynamic composition adds tokens to the orchestrator's reasoning, which is
  counterproductive at the exact moment we are trying to reduce context pressure.

**One exception**: The `$summary` and scratch directory path tokens in the focus
string should be **resolved to their actual values** before being presented to the
user (and before clipboard copy). The compaction model cannot resolve session
variables. The current SKILL.md text shows `$summary` literally in the focus string
template -- this should be interpolated to the actual summary value at runtime.
Verify the existing SKILL.md intent here: the `$summary` in the focus string
templates (lines ~817 and ~1200) may be intended as a literal variable reference
for the orchestrator to expand, or as a placeholder for the spec reader. The
implementation should ensure the clipboard-copied command contains fully resolved
values, not template variables.

### 2. The user-triggered /compact approach is the correct architecture

Given the constraint that agents cannot invoke `/compact` programmatically
(claude-code#19877), user-triggered compaction with a focus string is the
best available approach. The focus string mechanism leverages the compaction
model's ability to prioritize retention of specified content -- this is
fundamentally sound.

The alternative of writing ALL state to disk before compaction and reading it
back after is technically possible (the scratch directory already exists) but
is the wrong tradeoff for two reasons:

- **Context quality degrades on full reload.** Reading back a large state file
  after compaction produces a different context topology than organic conversation
  flow. The model processes the reloaded content as new input rather than as
  accumulated conversation history. This subtly degrades the model's ability to
  maintain coherent reasoning about prior decisions.
- **The existing hybrid approach is already correct.** The SKILL.md uses a
  two-tier state strategy: scratch files on disk (full outputs, recovery) plus
  inline summaries in context (~80-120 tokens each, quick reference). Compaction
  with a focus string preserves the inline summaries in their natural conversational
  position. This is better than discarding them and re-reading from disk.

### 3. Auto-compaction during Phase 4 is the real risk -- and it is already mitigated

If Claude Code's auto-compaction fires during Phase 4 (execution), the following
orchestration state is at risk:

**High risk of loss (not on disk):**
- Current batch tracking (which tasks are in-flight, which completed)
- Gate decision briefs from mid-execution gates
- The change ledger (files modified per task)
- Team/task dependency state for remaining batches

**Low risk of loss (on disk as scratch files):**
- Specialist contributions (Phase 2 outputs)
- Synthesized execution plan (phase3-synthesis.md)
- Review verdicts (phase3.5-*.md)
- Individual task prompts

**Already mitigated:**
- The SKILL.md already has a "Fallback for compacted summaries" mechanism
  (lines ~1987-1991) that reads scratch files to reconstruct lost inline
  summaries at wrap-up time. This is the right safety net.

**Not yet mitigated:**
- Mid-execution gate decision briefs are tracked in session context only
  (lines ~1969-1972). If auto-compaction fires between a gate approval and
  wrap-up, these briefs may be lost with no scratch file fallback. The
  execution plan scratch file records the planned gates, but not the runtime
  decision outcomes.

**Recommendation:** This is a pre-existing gap, not caused by this issue.
However, the compaction checkpoint is the right place to document the risk.
The focus strings should explicitly mention "gate decision briefs" in the
Phase 3.5 checkpoint's Preserve list (it already does), and the Phase 4
optional compaction mention (line ~1595) should note that gate briefs
accumulated during execution are at risk. This is an observation for the
synthesis, not a blocking concern for issue #87.

### 4. The checkpoint should NOT attempt to measure context pressure

The issue mentions "Skipping is fine if context is short." One might consider
having the orchestrator estimate context usage and conditionally skip the gate
if context is below a threshold. Do not do this. The orchestrator has no
reliable way to measure its own context consumption in tokens. Heuristics
(counting messages, estimating based on phase count) would be unreliable and
add complexity. Let the user decide -- they can see the Claude Code context
usage indicator. Making "Skip" the recommended default is the right design
because it respects the user's time while still offering the option.

### 5. Focus string should mention SKILL.md itself

The compaction model needs to know to preserve the orchestration instructions.
The SKILL.md content is loaded into the system prompt via the skill mechanism,
so it is part of the cached system prompt and not subject to conversation-level
compaction. However, if the model's understanding of SKILL.md instructions has
been reinforced by in-conversation references (e.g., the model "reminding itself"
of phase rules), those reinforcements could be lost. The focus strings do not need
to mention SKILL.md explicitly because the system prompt is not subject to
`/compact` -- `/compact` operates on the conversation turns, not the system prompt.
No change needed here; noting for completeness.

## Proposed Tasks

### Task 1: Replace blockquote checkpoints with AskUserQuestion gates

**What to do:** Replace the two compaction checkpoint blockquotes in SKILL.md
(post-Phase 3, lines ~811-825 and post-Phase 3.5, lines ~1194-1206) with
AskUserQuestion gates following the pattern established throughout the file.

**Key implementation details from LLM perspective:**
- Focus strings should remain static templates (no dynamic composition)
- Ensure focus string values like `$summary` and `$SCRATCH_DIR/{slug}/` are
  described as needing runtime interpolation before clipboard copy (the
  orchestrator must expand these to actual values)
- Keep "Skip" as the recommended (first) option -- this aligns with the
  insight that compaction is beneficial but not required, and the user is
  best positioned to judge context pressure
- Use `P3 Compact` and `P3.5 Compact` headers per the existing `P<N> <Label>`
  convention (not bare "Compact") to maintain phase context

**Deliverable:** Updated SKILL.md with two AskUserQuestion gates replacing
the blockquote checkpoints.

**Dependencies:** Depends on devx-minion's clipboard mechanism recommendation
and ux-strategy-minion's interaction flow recommendation.

### Task 2: Update visual hierarchy table

**What to do:** Update the visual hierarchy table (SKILL.md lines ~233-237)
to reclassify compaction checkpoints from "Advisory" weight to "Decision" weight,
since they now use AskUserQuestion (which pauses execution).

**Deliverable:** Updated row in the visual hierarchy table.

**Dependencies:** Depends on Task 1.

## Risks and Concerns

### Risk 1: Focus string template variable expansion (Medium)

The focus strings contain `$summary` and reference `$SCRATCH_DIR/{slug}/`.
When these are copied to the clipboard, they must contain the actual resolved
values, not template placeholders. If the orchestrator copies the template
literally, the `/compact` command will contain unexpanded variables, and the
compaction model will try to preserve the literal string "$summary" rather than
the actual summary text. The SKILL.md already has a "Path display rule" (line ~250)
requiring resolved absolute paths in user-facing output -- the same principle
applies here. Ensure the implementation spec makes this explicit.

### Risk 2: Auto-compaction racing with the gate (Low)

If the context window is already near capacity when the compaction checkpoint
is reached, auto-compaction could fire *during* the AskUserQuestion presentation,
before the user responds. This would be disorienting (the gate prompt might be
partially lost) but is not catastrophic -- the user would see a compacted context
and could re-run the skill. This is a pre-existing platform-level race condition,
not introduced by this change. No mitigation needed in scope.

### Risk 3: Compaction checkpoint gate fatigue (Low)

Adding two more AskUserQuestion gates (one after Phase 3, one after Phase 3.5)
increases the total gate count per orchestration. The existing anti-fatigue
guidelines (lines ~1540-1553) apply to Phase 4 execution gates, not to
infrastructure gates. However, having "Skip" as the recommended default and
keeping the question text minimal mitigates this. Users who never compact can
quickly click "Skip" twice and move on. The overhead is ~2 seconds per checkpoint.

## Additional Agents Needed

None. The current team (ux-strategy-minion for interaction design, devx-minion
for clipboard mechanics) covers the planning questions adequately. The LLM
context management concerns analyzed above are within ai-modeling-minion's
domain and do not require additional specialist input.
