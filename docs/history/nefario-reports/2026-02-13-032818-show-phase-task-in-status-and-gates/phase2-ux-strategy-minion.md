# Domain Plan Contribution: ux-strategy-minion

## Analysis Summary

The core UX problem is an **orientation gap**: users lose "where am I?" context in two situations: (a) when the status line is visible but shows only the task title with no phase, and (b) when AskUserQuestion hides the status line entirely, leaving the user with no phase or task context at all.

This is a Nielsen heuristic #1 violation (visibility of system status). Users need to know their position in a multi-phase process at all times. The fix must address both channels (status line and gate UI) because they are never simultaneously visible.

### Current State

- **Status file** (`/tmp/nefario-status-$sid`): Written once at orchestration start. Contains a 48-char task summary. Never updated during phase transitions.
- **Status line rendering**: `$dir | $model | Context: N% | $ns` where `$ns` is the raw file content. The pipe-delimited format means each segment competes for horizontal space.
- **AskUserQuestion gates**: Use generic `header` values ("Team", "Plan", "Gate", etc.) with no phase or task context. When these appear, the status line is hidden.
- **Phase announcements**: Exist in the conversation stream as `**--- Phase N: Name ---**` but scroll away and are not referenced in gates.

### Space Budget Analysis

A typical status line at full width:

```
2despicable/2 | Opus 4.6 | Context: 47% | Build MCP server with OAuth support...
```

That is roughly 75-80 characters. Terminal widths vary (80-200+ columns), but the status line likely renders in a constrained widget, not a full terminal row. Adding a phase prefix to the existing 48-char summary creates pressure:

```
... | Context: 47% | Phase 4: Execution | Build MCP server with OAuth support...
```

This is too long. The phase label alone adds 18-25 characters. Combined with the existing summary, the nefario segment could hit 70+ characters, competing with other segments.

## Recommendations

### 1. Status File: Phase-Prefixed, Shortened Task Summary

The status file content should follow the pattern:

```
P<N> <phase-label> | <task-summary>
```

Concrete examples:
- `P1 Meta-Plan | Build MCP server with OAuth...`
- `P2 Planning | Build MCP server with OAuth...`
- `P3 Synthesis | Build MCP server with OAuth...`
- `P4 Execution | Build MCP server with OAuth...`
- `P5-8 Verify | Build MCP server with OAuth...`

**Rationale**: The "P" + number notation is compact (2-3 chars) and scannable. Users learn the pattern after one orchestration. The abbreviated phase label provides just enough semantic context to disambiguate "P3" from "P4" without reading the number. The pipe separator is consistent with the existing status line delimiter.

**Character budget**: Phase prefix = 12-16 chars (e.g., "P4 Execution | "). Task summary should be reduced from 48 to 32 characters to keep total nefario segment under 50 chars. This gives the status line room to breathe.

The status file must be **rewritten at each phase boundary**, not just at orchestration start. This is the key behavioral change.

### 2. Status Line: No Changes to the Shell Command

The status line shell command (`despicable-statusline`) already reads the file and appends its content. No changes needed to the rendering logic. The information density change happens entirely through the file content. This is the right separation of concerns -- the status line is a dumb pipe; nefario controls what it displays.

### 3. AskUserQuestion Gates: Phase Context in the Header

The `header` field is the single most prominent element when a gate appears. Currently it uses generic labels ("Team", "Plan", "Gate"). This is the right place to inject phase context because:

- It is always visible (unlike the status line)
- It is the first thing the user reads
- It establishes framing before the user processes the question

**Change the header format to**: `"Phase N: <gate-type>"`

Current vs. proposed:

| Gate | Current Header | Proposed Header |
|------|---------------|-----------------|
| Team approval | "Team" | "P1 Team" |
| Impasse | "Impasse" | "P2 Impasse" |
| Architecture review | "Review" | "P3.5 Review" |
| Plan approval | "Plan" | "P3 Plan" |
| Execution gate | "Gate" | "P4 Gate" |
| Post-exec options | "Post-exec" | "P4 Post-exec" |
| Reject confirmation | "Confirm" | "P4 Confirm" |
| Calibration | "Calibrate" | "P4 Calibrate" |
| Security | "Security" | "P4 Security" |
| Issue | "Issue" | "P4 Issue" |
| PR | "PR" | "PR" |
| Existing PR | "Existing PR" | "Existing PR" |

**Note**: PR gates do not need phase prefixes. They happen during wrap-up and are self-evident. Overloading the phase prefix onto every gate would dilute its orienting value.

**Why not put the task title in the header too?** The `question` field already carries task-specific context (e.g., "Restore phase announcements and improve visibility"). The header should be a quick-scan category label, not a sentence. Combining phase + gate type + task title in the header would create cognitive overload in the most attention-demanding UI element.

### 4. AskUserQuestion Gates: Task Context in the Question

The `question` field should continue carrying the task-specific summary, as it already does for most gates. No change needed here for most gate types.

For the **execution approval gate** (`header: "Gate"`), the DECISION brief printed before the AskUserQuestion already contains the task title on line 1 (`APPROVAL GATE: <Task title>`). The `question` field carries the decision summary. This is sufficient -- the user reads the brief, then sees the question. Adding the task title to the question would be redundant.

### 5. Do NOT Add Phase to the Conversation-Stream Decision Brief

The `APPROVAL GATE: <Task title>` block printed before the AskUserQuestion already has enough information. Adding "Phase 4:" to it would be redundant because (a) the phase announcement marker already appeared earlier in the stream, and (b) the header on the AskUserQuestion prompt now carries the phase. Double-encoding the same information in adjacent UI elements is noise, not signal.

## Proposed Tasks

### Task A: Update nefario SKILL.md -- Status File Write at Phase Boundaries

**What**: Modify the status file write logic in SKILL.md. Currently the file is written once at orchestration start (lines 362-368). Add a rewrite at each phase boundary (after the phase announcement marker).

**Deliverables**:
- New section in SKILL.md defining the status file content format: `P<N> <label> | <summary-32-chars>`
- Phase-to-label mapping: P1=Meta-Plan, P2=Planning, P3=Synthesis, P3.5=Review, P4=Execution, P5-8=Verify
- Instruction to rewrite `/tmp/nefario-status-$SID` at each phase boundary with the updated prefix
- Reduce task summary from 48 to 32 characters (with "..." truncation rule adjusted)
- Total nefario segment budget: 50 characters max

**Dependencies**: None. This is the foundational change.

### Task B: Update nefario SKILL.md -- AskUserQuestion Header Format

**What**: Update all AskUserQuestion gate specifications to use phase-prefixed headers.

**Deliverables**:
- Updated `header` values across all gate definitions in SKILL.md (Team, Plan, Gate, Post-exec, Confirm, Calibrate, Security, Issue, Impasse, Review)
- PR and Existing PR gates exempted (no phase prefix)
- Clear rule: "All AskUserQuestion gates during orchestration phases 1-4 must use `P<N> <gate-type>` as the header value."

**Dependencies**: Depends on Task A (phase numbering convention must be defined first).

### Task C: No changes to despicable-statusline SKILL.md

**What**: Explicitly confirm no changes needed. The shell command reads the file as-is and appends it. The phase prefix flows through automatically.

**Deliverables**: None (this is a non-task; documenting it here to prevent unnecessary work).

**Dependencies**: None.

## Risks and Concerns

### Risk 1: Header Truncation in AskUserQuestion UI

**Concern**: The AskUserQuestion UI widget may truncate long headers. Adding "P4 " (3 chars) to existing headers is minimal, but it has not been tested. "P3.5 Review" is the longest at 11 chars.

**Mitigation**: Keep the prefix to the "P<N> " format (not "Phase N: ") to minimize character cost. Test the longest header variant in a real Claude Code session.

### Risk 2: User Confusion About Phase Numbers

**Concern**: New users may not know what "P3" means. Phase numbers are an internal convention.

**Mitigation**: This is acceptable because (a) the phase label provides semantic context ("P3 Synthesis" is self-describing even without knowing the numbering), (b) users who run nefario regularly will internalize the pattern within one session, and (c) the conversation stream still shows the full `**--- Phase 3: Synthesis ---**` announcement for detailed context. The status line and gate headers serve returning users' need for quick orientation, not first-time learnability.

### Risk 3: Status File Rewrite Timing

**Concern**: If the status file is rewritten at a phase boundary but the status line polls between the old phase ending and the new write, there could be a brief stale display.

**Mitigation**: Non-issue. The write happens at the start of each phase (same moment as the phase announcement). The status line reads on demand. The window of staleness is negligible, and even if it occurs, showing the previous phase for a few seconds is not disorienting.

### Risk 4: Task Summary Shortened from 48 to 32 Characters

**Concern**: 32 characters may truncate task titles to the point of being unrecognizable.

**Mitigation**: Test with real task titles. Most nefario tasks can be summarized in 32 chars: "Build MCP server with OAuth..." (31 chars), "Add phase context to gates..." (29 chars). If 32 proves too tight, 36 is the fallback (total nefario segment = 54 chars). The phase prefix is more valuable than the last 16 chars of a task title that users already know from the conversation.

### Risk 5: Cognitive Load of Learning Two Orientation Systems

**Concern**: Users now have orientation in two places (status line and gate header) with slightly different formats. Could this cause confusion?

**Mitigation**: No. The two systems serve different contexts and are never simultaneously visible. The format is deliberately similar (both use "P<N>") to build a transferable pattern. This is consistent with Nielsen's heuristic #4 (consistency and standards) -- same concept, same notation, different channels.

## Additional Agents Needed

None. The changes are entirely to SKILL.md specification files (nefario's orchestration instructions). No code implementation, no visual design, no architecture changes. The nefario-minion (or whoever implements SKILL.md edits) can execute these changes directly from the task specifications above.
