# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. "Skip" as the recommended default is correct

The compaction checkpoint is an operational maintenance action, not a decision about the work itself. Most of the time, context is short enough that compaction is unnecessary. Making "Skip" the default aligns with several principles:

- **Satisficing behavior**: Users take the first reasonable option. The recommended option should be the one that's right most of the time. "Skip and keep going" is right more often than "stop and compact."
- **Flow preservation**: Every interruption costs re-engagement time. The user is in the middle of an orchestration flow. The default should keep them moving unless they have a specific reason to pause.
- **Calm technology**: The checkpoint should inform without demanding. By marking Skip as recommended, the gate communicates "you probably don't need to act here" while preserving the option for users who know they're running long.

One refinement: the description for Skip currently says "Auto-compaction may interrupt later phases." This is a mild fear appeal. It's appropriate -- it gives the user the information needed to make an informed choice -- but should remain factual and brief, not escalated.

### 2. The 3-step Compact path is acceptable but should be simplified where possible

The proposed Compact flow is: (1) clipboard copy, (2) paste and run, (3) type "continue". Three steps is at the upper bound of what I'd recommend for an infrequent operational action. Here's the analysis:

**Why it's acceptable**:
- This is a power-user path. The user has actively chosen to compact rather than skip. They've signaled willingness to do manual work.
- Each step is a single discrete action (paste, run, type a word). The cognitive load per step is low.
- The user only encounters this 0-2 times per orchestration session.

**How to reduce friction further**:
- **Combine steps 2 and 3**: Instead of asking the user to "type continue while compaction is running," consider whether nefario can detect that compaction has completed and auto-resume. If not technically feasible, the explicit "continue" is fine -- but this should be investigated.
- **Pre-fill the clipboard silently**: The clipboard copy should happen automatically when the user selects "Compact," not require an additional confirmation. The current proposal does this correctly.
- **Shorten the instruction text**: The current proposal says "Paste and run the command from your clipboard. You can type `continue` and hit Return while compaction is running -- it will be queued and executed once compaction completes." This is 2 sentences and 34 words. Proposed reduction: "Paste and run the clipboard command, then type `continue` to resume (works during or after compaction)." -- 15 words, same information.

### 3. The "type continue while compaction is running" instruction needs clarification

This is the weakest point in the proposed flow from a cognitive load perspective. The instruction introduces a non-obvious concept: that you can type a command while another command is running and it will be queued. This violates the "Don't make me think" principle because:

- Users may not know that Claude Code queues input during compaction.
- "While compaction is running" implies timing sensitivity, which creates anxiety.
- The user may wonder: "Do I type it now? Wait until it finishes? What if I type it too early/late?"

**Recommendation**: Reframe to remove timing ambiguity. Instead of explaining the queuing mechanism, just tell the user what to do:

> "Paste and run the clipboard command. Type `continue` when ready to resume."

This works whether compaction is still running or already finished. The user doesn't need to understand queuing. They paste, they run, they type continue whenever they're ready. If it queues, it queues -- that's an implementation detail the user doesn't need to carry in working memory.

### 4. Header should follow the `P<N> Label` convention

Yes. The header should be `"P3 Compact"` for the post-Phase 3 checkpoint and `"P3.5 Compact"` for the post-Phase 3.5 checkpoint. Rationale:

- **Consistency** (Nielsen heuristic 4): Every other AskUserQuestion gate in the system uses `P<N> <Label>`. Breaking this pattern forces the user to process a different format, adding extraneous cognitive load.
- **Phase orientation**: The `P<N>` prefix tells the user where they are in the orchestration flow. This is especially valuable for the compaction gate because context length is the exact moment users might be disoriented.
- **Character budget**: "P3 Compact" is 10 characters, "P3.5 Compact" is 12 characters -- both within the 12-character limit.

Note: a bare "Compact" header without phase prefix would lose the orientation cue. Since this gate is literally about managing context, helping the user stay oriented is doubly important.

### 5. Visual hierarchy promotion is appropriate

The current design classifies compaction checkpoints as **Advisory** weight (blockquote). The proposal promotes them to **Decision** weight (AskUserQuestion gate). This promotion is justified:

- The advisory weight was chosen because the checkpoint was "optional user action." But the problem described in the issue is precisely that advisory weight doesn't create enough pause -- the user can't act on it.
- The checkpoint is a genuine decision point: continue without compacting vs. stop and compact. Decision weight is semantically correct.
- The visual hierarchy table in SKILL.md should be updated to reflect that compaction checkpoints are now Decision weight, not Advisory.

### 6. The "Do NOT re-prompt at subsequent boundaries" rule should be preserved

The current spec says: if the user skips compaction at the Phase 3 boundary, don't re-prompt at Phase 3.5. This is good UX -- it respects the user's expressed preference and avoids nagging. With the upgrade to AskUserQuestion gates, this rule becomes even more important because gates are heavier-weight than blockquotes. Being asked the same question twice with a structured prompt is more annoying than seeing the same blockquote twice.

**Recommendation**: Preserve this rule. If the user selects "Skip" at P3 Compact, suppress the P3.5 Compact gate entirely. Print a one-line inline note instead: "Compaction skipped (per earlier choice)."

### 7. Option ordering

The proposal puts "Skip" first and "Compact" second, with Skip as recommended. This is correct. The recommended/default option should be first (top of list), and the less common action second. This follows the convention in other gates (e.g., P4 Gate puts "Approve" first as recommended, with alternatives below).

## Proposed Tasks

### Task 1: Design the AskUserQuestion gate specification

**What**: Write the exact AskUserQuestion specification for both compaction checkpoints (post-Phase 3 and post-Phase 3.5), including header, question text, options with labels and descriptions, and response handling for each option.

**Deliverables**:
- Gate spec for P3 Compact (header, question, options, response handling)
- Gate spec for P3.5 Compact (header, question, options, response handling)
- Updated visual hierarchy table entry (Advisory -> Decision for compaction)

**Key constraints from this review**:
- Headers: `"P3 Compact"` and `"P3.5 Compact"`
- Question must end with `\n\nRun: $summary`
- Skip = option 1 (recommended), Compact = option 2
- Skip description: "Continue without compaction. Auto-compaction may interrupt later phases."
- Compact description: "Compact now. The /compact command will be copied to your clipboard."
- Post-Compact instruction: "Paste and run the clipboard command. Type `continue` when ready to resume." (no queuing explanation)
- Preserve "Do NOT re-prompt" rule: if user skips at P3, suppress P3.5 gate

**Dependencies**: None -- this is spec work.

### Task 2: Validate clipboard mechanism and fallback

**What**: Confirm `pbcopy` works in the Claude Code terminal context. Define the fallback for non-macOS platforms (display the command as copyable text instead of auto-clipboard).

**Deliverables**:
- Clipboard copy command for macOS (`pbcopy`)
- Fallback behavior for Linux/WSL (print command with clear "copy this" framing)
- Error handling if `pbcopy` fails silently

**Dependencies**: None -- technical validation.

### Task 3: Implement the spec changes in SKILL.md

**What**: Replace the two blockquote compaction checkpoints with the specified AskUserQuestion gates. Update the visual hierarchy table. Update the response handling sections.

**Deliverables**: Updated SKILL.md with both gates implemented.

**Dependencies**: Task 1 (spec), Task 2 (clipboard mechanism).

## Risks and Concerns

### Risk 1: Gate fatigue

Adding two more AskUserQuestion gates to the orchestration flow increases the total gate count. The system already has gates at P1 Team, P3.5 Review, P3.5 Plan, every P4 task, P5 security findings, and PR creation. If users routinely hit 8-12 gates per orchestration, two more compaction gates could contribute to approval fatigue (mindless clicking through). **Mitigation**: The "Do NOT re-prompt" rule reduces this to at most one compaction gate in practice. The Skip-as-default also reduces friction -- the user just hits Enter/Return.

### Risk 2: Clipboard command length

The `/compact focus="Preserve: ..."` string is long (100+ characters). Long clipboard contents that the user must paste into a terminal can feel fragile -- did the whole thing copy? Is it correct? **Mitigation**: The clipboard copy is invisible to the user. They paste and run. If the focus string is truncated or mangled, the worst case is a suboptimal compaction, not a failure. This risk is low.

### Risk 3: "Continue" as a magic word

The flow requires the user to type the literal word "continue" to resume. This is an implicit protocol -- the user must remember or re-read the instruction. **Mitigation**: This is an existing pattern in the current blockquote design, not new to this proposal. It's also a common conversational convention (ChatGPT, Claude.ai, etc. all use "continue" as a resume signal). The risk is low but worth noting: if the user types "go", "next", "ok", or "resume" instead, the system should interpret these as equivalent to "continue" rather than treating them as unknown input. The current spec (line 822-824) handles this correctly by accepting "anything else" as a skip signal, but the new design should be explicit about accepting synonyms as resume signals in the Compact path.

### Risk 4: Platform detection complexity

The proposal includes clipboard copy via `pbcopy` with a fallback. Platform detection in shell scripts adds conditional logic. **Mitigation**: Keep it simple. Check for `pbcopy` existence; if absent, print the command as text. Don't try to detect `xclip`, `xsel`, `wl-copy`, etc. -- the target user base is overwhelmingly macOS (Claude Code's primary platform as of 2026).

## Additional Agents Needed

None. The current team is sufficient. This is a spec change to SKILL.md (a markdown file defining orchestration behavior). No frontend code, no visual design, no architecture changes. The implementation is text editing guided by a clear spec.
