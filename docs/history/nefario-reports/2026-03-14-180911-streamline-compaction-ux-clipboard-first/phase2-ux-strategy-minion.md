# UX Strategy Analysis: Streamline Compaction Flow

## Planning Question

Does removing the explicit Skip/Compact choice gate and replacing it with an always-generate clipboard-first pattern genuinely reduce cognitive load, or does it risk confusing users with an unsolicited clipboard change? Should the new "paste to compact or continue to skip" message use AskUserQuestion or freeform text input? What is the clearest phrasing for "queue continue immediately" vs "type continue when ready"?

## Analysis

### 1. Does Removing the Gate Reduce Cognitive Load?

**Yes, unambiguously.** The current flow has a redundant decision point. Let me walk through why.

The current interaction requires two sequential decisions where only one is needed:

1. AskUserQuestion: "Skip" or "Compact?" (binary gate)
2. If Compact: paste the command, wait, then type "continue"

The proposed flow collapses this into a single decision point:

1. Command is already on clipboard. Paste to compact, or type "continue" to skip.

This is a textbook case of eliminating extraneous cognitive load. The user's actual decision is identical in both flows -- "do I want to compact right now?" -- but the current design forces them to express that decision through a formal gate before the system even prepares the compaction command. The gate adds zero information; it exists only to ask permission to prepare something the user might want.

**Heuristic grounding**: Nielsen H7 (flexibility and efficiency of use) -- experts should be able to accelerate through common patterns. The gate forces even experienced users through a two-step sequence for what is functionally one decision. Nielsen H8 (aesthetic and minimal design) -- the gate is an interaction element that doesn't carry unique information.

**JTBD analysis**: The user's job at this checkpoint is "decide whether to compact context before the next phase." The current design makes them do that job twice -- once at the gate, once by acting on the clipboard content. The proposed design lets them do it once.

### 2. Risk: Unsolicited Clipboard Change

**This is a real concern, but manageable.** Overwriting the clipboard without user initiation violates the principle of least surprise (Nielsen H2, match between system and real world). Users expect their clipboard to contain what they last copied.

However, the risk is low in this specific context for three reasons:

- **The user is in an orchestrated CLI session.** They are actively watching nefario output. This is not a background process silently modifying system state. The clipboard change happens at a natural pause point where the user is reading output and deciding what to do next.
- **The message explicitly tells the user what happened.** The clipboard overwrite is announced, not hidden. Visibility of system status (Nielsen H1) is preserved.
- **The clipboard content is immediately actionable.** The user either pastes it right now or doesn't. There's no scenario where they need to remember the clipboard was changed 5 minutes later.

**Mitigation**: The message should lead with what's on the clipboard and why, before presenting the choice. This transforms an "unsolicited change" into "here's something ready for you."

### 3. AskUserQuestion vs. Freeform Text Input

**Use freeform text input (plain message), not AskUserQuestion.**

Rationale:

- **AskUserQuestion creates a modal gate.** The whole point of this change is eliminating the gate. Using AskUserQuestion to present "paste or continue" would reintroduce the exact pattern being removed -- a formal choice that blocks progress until the user selects an option.
- **The user's action space is already constrained by context.** They will either paste the clipboard content or type "continue." These are physical actions (paste, type), not abstract choices that benefit from structured presentation. AskUserQuestion is appropriate when the system needs to route to different code paths based on a selection. Here, the system doesn't need to route -- it's already done its work (generated and copied the command). The user is just choosing whether to act on it.
- **Freeform preserves the "self-service" character of the design.** The proposed pattern is: "Here's the tool, use it if you want." That's a message + wait, not a question + answer.

The flow should: print the message (including the command for manual copy if clipboard fails), then wait for user input. The existing synonym list ("continue", "go", "next", "ok", "resume", "proceed") handles the skip case. Anything that looks like the /compact command handles the compact case. This is effectively how the post-compact "continue" wait already works -- just extend it to also cover the skip-without-compacting path.

### 4. Clearest Phrasing for Continuation

The current post-compaction instruction is:

> Type `continue` when ready to resume.

The proposed replacement conveys: "you can queue 'continue' immediately; it will execute once compaction finishes."

**Recommended phrasing**:

For the combined checkpoint message (pre-compaction decision):

```
Compaction command copied to clipboard.

  Paste and run to compact, or type `continue` to skip.
```

For the post-compaction continuation (if they paste and compact):

```
Type `continue` now -- it will run after compaction finishes.
```

**Why this phrasing works**:

- **"now"** is the critical word. It replaces the ambiguous "when ready" (which implies waiting for some state change the user must monitor) with a clear directive to act immediately.
- **"it will run after compaction finishes"** explains the queuing mechanism in cause-and-effect terms. The user doesn't need to understand Claude Code's message queue -- they just need to know their input won't be lost.
- **"Paste and run to compact, or type continue to skip"** frames both options as immediate actions with clear outcomes. No decision paralysis -- both paths are one action.

Avoid: "Queue continue immediately" -- "queue" is a system-internals term that violates Nielsen H2 (match real world). Users don't think in terms of message queues. They think "type something, it happens."

### 5. Context Display Retention

The current gates include a context usage line (`[Context: X% used -- Yk remaining]`). This information is genuinely useful for the compaction decision -- it's the primary input the user needs to decide whether compaction is worthwhile. **Retain this in the new message.** It should appear before the action instruction so the user has the information before the decision:

```
Phase 3 complete. Context: 67% used -- 48k remaining.
Compaction command copied to clipboard.

  Paste and run to compact, or type `continue` to skip.
```

The context percentage serves as a natural nudge: high percentages make compaction feel more urgent, low percentages make skipping feel safe. This is the same information architecture, just without the modal gate.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Clipboard overwrite destroys user's prior clipboard content | Low (CLI session, user is actively engaged) | Announce clipboard change explicitly in the message; also print the command so manual copy is possible |
| User doesn't notice the message and types something unrelated | Low (this is a blocking wait point) | The existing synonym matching already handles unexpected input gracefully -- unrecognized input can re-prompt |
| "continue" is ambiguous -- does it mean "skip compaction" or "resume after compaction"? | Medium | Context disambiguates: before compaction, "continue" means skip. After pasting /compact and it completes, "continue" means resume. The message wording makes this clear at each point. |
| Removing AskUserQuestion means losing structured telemetry on Skip vs. Compact rates | Low (nefario is a personal tool, not a SaaS product) | If tracking matters, log the choice implicitly based on whether /compact was detected in user input |

## Dependencies

- The implementation must handle the case where `pbcopy` fails silently (non-macOS, clipboard unavailable). The current flow already has this concern but only hits it on the "Compact" path. The new flow hits it every time. The printed command serves as fallback.
- The "wait for user input" logic after the message needs to recognize both paste-of-compact-command and continue-synonyms. Current code already handles both -- this is a simplification (merging two wait states into one), not new capability.

## Requirements from This Perspective

1. **Always print the command visually**, even after clipboard copy succeeds. The printed command is the fallback and also gives the user confidence about what's on their clipboard.
2. **Retain context usage display.** Move it from the AskUserQuestion header into the plain message. It's the key decision input.
3. **Use plain message + wait, not AskUserQuestion.** The decision is expressed through action (paste or type), not through option selection.
4. **Use "now" instead of "when ready"** in post-compaction continuation instruction. Clearly convey queuing behavior without using system jargon.
5. **Keep the existing synonym list** for "continue" detection. No changes needed to the input matching logic.
6. **Both checkpoints (post-Phase 3, post-Phase 3.5) should use identical interaction patterns** with only the context-specific text differing (phase number, what to preserve/discard).

## Specialist Involvement

No additional specialists needed beyond what's already in the planning. This is a pure interaction-pattern change within a single file. The implementation is straightforward text and control-flow editing in SKILL.md.
