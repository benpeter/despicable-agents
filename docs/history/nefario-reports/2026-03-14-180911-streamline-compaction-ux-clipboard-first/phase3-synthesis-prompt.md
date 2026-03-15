MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

**Outcome**: The compaction flow no longer asks for permission before generating the compaction prompt. Instead, it always generates the prompt, copies it to the clipboard, and tells the user to paste it back to compact or type "continue" to skip. This eliminates a redundant confirmation step and makes the flow self-service. Additionally, the post-compaction continuation instruction is clarified: the user queues "continue" immediately (it executes once compaction finishes), rather than the misleading "type continue once you are ready."

**Success criteria**:
- Compaction prompt is always generated and copied to clipboard without asking first
- User message clearly says: paste to compact, or type "continue" to skip
- Post-compaction instruction tells user to queue "continue" (not "type once ready")
- No behavioral regression in the orchestration phases that follow compaction

**Scope**:
- In: Compaction flow logic and user-facing messages in the nefario skill
- Out: Compaction prompt content/quality, other nefario phases, Claude Code clipboard internals

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-8uolGq/streamline-compaction-ux-clipboard-first/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-8uolGq/streamline-compaction-ux-clipboard-first/phase2-ai-modeling-minion.md

## Key consensus across specialists:

### ux-strategy-minion
- Remove gate; use plain message + wait. Clipboard-first genuinely reduces cognitive load.
- Do not use AskUserQuestion — user decides by action (paste vs type).
- Retain context-usage display as decision input.
- Prefers "now" phrasing, avoid "queue" (system jargon).

### ai-modeling-minion
- Use numbered-step unconditional sequences with explicit "STOP. Wait for user's next message" instruction.
- Keep context-usage extraction — costs nothing, aids user decision.
- Model risk: may continue generating without explicit STOP. Numbered steps + STOP sentinel mitigate.
- Prefers "queue" to signal immediate typing is safe.
- /compact is handled by Claude Code, not the model — simplifies resume: model only sees "continue".
- Preserve Run: $summary_full trailing line for orchestration identification.

### Conflict to resolve:
- Wording: "queue continue" (ai-modeling) vs "type continue now" (ux-strategy). Both agree the message should convey that typing is safe immediately.

## External Skills Context
No external skills detected.

## Instructions
1. Review all specialist contributions
2. Resolve the wording conflict between "queue" and "now"
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-8uolGq/streamline-compaction-ux-clipboard-first/phase3-synthesis.md
