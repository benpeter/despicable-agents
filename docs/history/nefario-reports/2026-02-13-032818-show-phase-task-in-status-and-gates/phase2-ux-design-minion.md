# Domain Plan Contribution: ux-design-minion

## Recommendations

### 1. Status File Updates: Timing and Content

**Update the status file immediately BEFORE the phase announcement marker, not after.**

Rationale: The status file and the phase announcement serve the same orientation purpose through different UI channels. The status line is persistent but sometimes hidden (during AskUserQuestion prompts); the phase announcement is ephemeral but always visible when it fires. By writing the status file first, the status line catches up the moment the prompt UI dismisses -- there is no window where both channels are stale simultaneously.

**Status file content should follow the pattern: `Phase N: Name -- <task summary>`**

This mirrors the phase announcement format (`**--- Phase N: Name ---**`) but adds the task context. The existing 48-character task summary truncation should apply to the task portion only, with the phase prefix exempt from the character budget. Revised format:

```
Phase 1: Meta-Plan -- <task summary, max 48 chars>
Phase 2: Planning (5 agents) -- <task summary>
Phase 3: Synthesis -- <task summary>
Phase 3.5: Review (7 reviewers) -- <task summary>
Phase 4: Execution (3 tasks, 1 gate) -- <task summary>
Phase 5-8: Verifying -- <task summary>
```

The parenthetical counts match the phase announcement parentheticals -- same data, same channel consistency.

**Total status line length budget**: The status line already shows `dir | model | Context: N%` which consumes roughly 40-60 characters. With the ` | Nefario: ` separator (11 chars) and the phase-prefixed status, the total nefario portion should stay under 80 characters. Phase prefix is ~15-30 chars, leaving 50-65 chars for the task summary. The current 48-char truncation is still safe.

### 2. Mid-Execution Gate Names in Status File

**Yes, update the status file at mid-execution gates, but with a lightweight sub-state indicator.**

When an approval gate is presented during Phase 4, update the status to:

```
Phase 4: Gate -- <gate task title, max 48 chars>
```

This replaces the Phase 4 execution status temporarily. When the gate is resolved (approved, rejected, skipped), revert to:

```
Phase 4: Execution (N tasks, M gates) -- <task summary>
```

Rationale: During a gate, the user is making a decision. The status line (if visible in another pane or when the AskUserQuestion prompt dismisses) should reflect that the orchestration is paused at a decision point, not that it is executing. The word "Gate" is the minimal indicator that communicates "waiting for you." After resolution, reverting to the execution status accurately reflects resumed progress.

**Do NOT include sub-gate states** (Post-exec, Confirm reject, Calibrate) in the status file. These are rapid follow-up prompts within the same gate interaction and would cause distracting flicker. Only the primary gate entry and exit should trigger status updates.

### 3. Phase Context in AskUserQuestion Gates

**Add phase context to the `header` field of every AskUserQuestion, not to the `question` field.**

The `header` is the structural label for the prompt -- it is the right semantic location for orientation metadata. The `question` field should remain focused on the decision at hand. Current headers are single words ("Team", "Gate", "Plan"). Prefix them with phase identity:

| Current header | Proposed header | Phase |
|---|---|---|
| `"Team"` | `"Phase 1 -- Team"` | Meta-Plan |
| `"Review"` | `"Phase 3.5 -- Review"` | Architecture Review |
| `"Impasse"` | `"Phase 3.5 -- Impasse"` | Architecture Review (conflict) |
| `"Plan"` | `"Phase 3 -- Plan"` | Synthesis / Execution Plan |
| `"Gate"` | `"Phase 4 -- Gate"` | Mid-execution approval |
| `"Post-exec"` | `"Phase 4 -- Post-exec"` | Post-execution options |
| `"Confirm"` | `"Phase 4 -- Confirm"` | Rejection confirmation |
| `"Calibrate"` | `"Phase 4 -- Calibrate"` | Gate calibration |
| `"Security"` | `"Phase 5 -- Security"` | Code review security finding |
| `"Issue"` | `"Phase 5 -- Issue"` | Code review escalation |
| `"PR"` | `"Wrap-up -- PR"` | PR creation |
| `"Existing PR"` | `"Wrap-up -- Existing PR"` | Existing PR update |

**Format rationale**: `Phase N -- Label` uses an em dash separator (consistent with how the status file separates phase from task). The phase number comes first because it answers the orientation question ("where am I?") before the action question ("what am I deciding?"). The em dash visually separates the two without adding line noise.

**Do NOT add the task summary to the header.** The header is already small UI real estate. Phase identity is sufficient for orientation; the task context is in the question text and in the decision brief above the prompt.

### 4. Interaction Sequencing Between Status Update and Phase Announcement

The sequence at each phase boundary should be:

1. Write status file (shell command, silent -- NEVER SHOW tier)
2. Print phase announcement marker (SHOW tier)
3. Proceed with phase work

This ordering ensures:
- The status line is current before any visible output appears
- If the phase announcement scrolls up quickly (e.g., during fast phases), the status line retains the phase identity
- There is never a state where the announcement has fired but the status file is stale

For mid-execution gates specifically, the sequence is:

1. Write status file with gate state (`Phase 4: Gate -- <title>`)
2. Print the APPROVAL GATE decision brief (conversation output)
3. Present AskUserQuestion with phase-prefixed header
4. On resolution: write status file back to execution state
5. Continue execution

### 5. Post-Execution Phase Status (Phases 5-8)

These phases use the dark kitchen pattern -- minimal user-visible output. The status file should still update to reflect the current verification activity, because the status line is the ONLY orientation signal the user has during dark kitchen phases:

```
Phase 5: Code Review -- <task summary>
Phase 6: Tests -- <task summary>
Phase 8: Documentation -- <task summary>
```

This is particularly valuable because dark kitchen phases can take time, and without status updates, the user has no way to know whether nefario is stuck or making progress. The status line becomes the sole heartbeat.

However, if a phase is skipped, do NOT write its status (no flash of a phase that never runs).

## Proposed Tasks

### Task 1: Add Phase-Prefixed Status File Updates to SKILL.md

**What to do**: Modify SKILL.md to add status file write instructions at each phase boundary (Phases 1, 2, 3, 3.5, 4, 5-8) and at mid-execution gate entry/exit. Move the existing Phase 1 status write to before the phase announcement. Add the phase-prefixed format specification.

**Deliverables**:
- Updated SKILL.md with status file write instructions at lines ~362-368 (Phase 1, refactored) and new instructions at each subsequent phase boundary
- A reusable status write pattern (shell snippet) that takes phase label and task summary as inputs, to avoid duplicating the SID lookup and echo logic at every phase

**Dependencies**: None (can run in parallel with Task 2)

### Task 2: Add Phase Context to All AskUserQuestion Headers in SKILL.md

**What to do**: Update every AskUserQuestion `header` field in SKILL.md to use the `"Phase N -- Label"` format per the mapping table above. This is a find-and-replace operation across ~12 AskUserQuestion instances.

**Deliverables**:
- Updated SKILL.md with all header fields prefixed with phase context
- Consistent separator format (` -- `) across all headers

**Dependencies**: None (can run in parallel with Task 1)

### Task 3: Update despicable-statusline Skill Documentation

**What to do**: Update the despicable-statusline SKILL.md to document that the status file now contains phase-prefixed content that changes during orchestration (not just a static summary). No code changes needed -- the status line shell command already reads whatever is in the file. This is documentation-only.

**Deliverables**:
- Updated `.claude/skills/despicable-statusline/SKILL.md` with a note about dynamic phase content

**Dependencies**: Task 1 (to know the final format)

### Task 4: Update user-facing documentation (using-nefario.md)

**What to do**: Update docs/using-nefario.md to mention that (a) the status line now shows current phase, (b) AskUserQuestion prompts include phase context in their headers, so users always know where they are in the orchestration.

**Deliverables**:
- Updated docs/using-nefario.md with brief mention of improved phase awareness

**Dependencies**: Tasks 1 and 2 (to know the final formats)

## Risks and Concerns

### Risk 1: Status line character overflow
The phase prefix adds 15-30 characters to the status content. Combined with the existing `dir | model | Context: N%` segments, long directory paths could push the total status line past terminal width, causing wrapping or truncation. **Mitigation**: The 48-character task summary truncation provides a buffer. The phase prefix for the most common state (`Phase 4: Execution`) is only 20 chars. Monitor in practice and adjust the 48-char budget downward if needed.

### Risk 2: Status file write failures during fast phase transitions
If phases 2 and 3 complete very quickly (e.g., small plans), multiple status file writes in rapid succession could produce transient states that the user never sees. This is harmless but wasteful. **Mitigation**: Accept this as benign. The status line polls on a refresh interval anyway; a write that is overwritten before the next poll is simply invisible.

### Risk 3: Gate status "flicker" for rapid approve-and-continue sequences
If a user quickly approves a gate, the status file briefly shows "Phase 4: Gate -- ..." then reverts to "Phase 4: Execution -- ...". Depending on status line poll interval, this might produce a visible flicker. **Mitigation**: This is acceptable and even desirable -- it briefly confirms the gate was processed. The visual change is informative, not disorienting, because it transitions between two semantically related states.

### Risk 4: Phase 5-8 status writes breaking dark kitchen contract
The dark kitchen pattern says phases 5-8 run silently. Writing to the status file is technically "output" -- but it is output to a file that the user sees only if they look at the status line, which is the lightest possible signal. **Mitigation**: Status file writes are not conversation output. They do not violate the NEVER SHOW tier. They are infrastructure, like writing to the scratch directory. Document this distinction explicitly in the SKILL.md update.

### Risk 5: Inconsistent header format if nefario skips phases
If Phase 3.5 is skipped (user selects "Skip review"), the next gate is the Execution Plan gate at Phase 3/4 boundary. Ensure the phase prefix accurately reflects the current phase, not a skipped one. **Mitigation**: Each AskUserQuestion has its header hardcoded to its specific phase. Skipped phases simply never present their gates, so there is no inconsistency risk -- the mapping table already handles this.

## Additional Agents Needed

**devx-minion** -- The status file write pattern (SID lookup, echo, chmod) is currently inlined once. Extracting it into a reusable shell snippet that is invoked at each phase boundary is a developer experience concern. devx-minion should review whether to define a helper function or keep inline writes.

Beyond that, the current team should be sufficient. The changes are entirely to SKILL.md content and documentation -- no code implementation, no accessibility compliance testing, no security implications.
