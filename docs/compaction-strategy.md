[< Back to Architecture Overview](architecture.md)

# Context Management During Orchestration

Nefario orchestrations accumulate specialist outputs, synthesis results, and review verdicts across nine phases (five planning/execution phases plus four post-execution phases). Without intervention, this context growth can exceed session limits or trigger automatic compaction that discards orchestration state (phase position, task list, branch name). This document describes the two-pronged mitigation: **scratch files** externalize full outputs to disk while retaining compact summaries in session, and **user-prompted compaction checkpoints** at phase boundaries reclaim context space when information has been superseded.

For the operational implementation, see the [nefario skill](../skills/nefario/SKILL.md). This document covers the design rationale.

---

## 1. Problem: Context Overflow in Long Orchestrations

Each phase of an orchestration adds to the session context window. Phase 2 alone generates 500-2000 tokens per specialist contribution; six specialists produce 3000-12000 tokens of raw output. Phase 3 synthesis adds another 1000-3000 tokens. Phase 3.5 review verdicts, while individually compact, accumulate further. By the time Phase 4 execution begins, the session may be carrying 10000-20000+ tokens of planning material that is no longer directly needed -- the synthesis has consumed the specialist contributions, and the finalized plan has consumed the review verdicts.

Two failure modes result:

- **Hard overflow**: The session hits its context limit and cannot proceed.
- **Uncontrolled auto-compaction**: Claude Code automatically compresses the context to make room, but this compression is not aware of orchestration state. It may discard the task list, current phase position, branch name, approval gate status, or scratch directory path -- any of which prevents the orchestrator from continuing correctly.

Programmatic compaction (agent-initiated context trimming) is not available. Claude Code does not expose compaction controls to agents. The only compaction mechanism available is the user-facing `/compact` command, which requires the user to invoke it manually.

---

## 2. Scratch File Pattern

The core idea: write full phase outputs to disk, keep only compact summaries in session context. Subagents read full outputs from disk via tool calls, which do not accumulate in the calling session's context window.

### Directory Structure

Each orchestration session creates a scratch directory at Phase 1 start:

```
nefario/scratch/{slug}/
  phase1-metaplan.md
  phase2-{agent-name}.md        # one per specialist
  phase3-synthesis.md
  phase3.5-{reviewer-name}.md   # one per reviewer (BLOCK/ADVISE only)
```

The `{slug}` is derived from the task description (kebab-case, lowercase, max 40 characters, articles stripped, alphanumeric and hyphens only). It reuses the same slug generated for the execution report filename.

### Inline Summary Template

After writing a specialist's full output to its scratch file, the orchestrator records a compact summary in the session:

```
## Summary: {agent-name}
Recommendation: {1-2 sentences}
Tasks: {N} -- {one-line each, semicolons}
Risks: {critical only, 1-2 bullets}
Conflicts: {cross-domain conflicts, or "none"}
Full output: nefario/scratch/{slug}/phase2-{agent-name}.md
```

Each summary occupies approximately 80-120 tokens. For six specialists, this totals roughly 600 tokens inline -- a 5-20x reduction compared to retaining full contributions (3000-12000 tokens).

Downstream subagents (synthesis nefario, architecture reviewers) receive file paths and read the full outputs themselves. Tool call results inside a subagent are invisible to the calling session's context window. This is the key mechanism that breaks the accumulation chain.

### Lifecycle

- **Creation**: `mkdir -p nefario/scratch/{slug}/` at Phase 1 start.
- **Overwrites**: If the directory already exists (retry of same task), files are overwritten silently.
- **Cleanup**: Never auto-deleted. Scratch files persist for debugging and recovery. Manual cleanup: `rm -rf nefario/scratch/*/`.
- **Git**: `nefario/scratch/` is gitignored (except `.gitkeep`).

---

## 3. Compaction Checkpoints

Scratch files reduce context growth but do not eliminate it. Inline summaries still accumulate, and the orchestrator retains phase metadata, task lists, and operational state. Compaction checkpoints are the second defense: they prompt the user to run `/compact` at phase boundaries where earlier information has been superseded.

### Two Checkpoint Positions

**After Phase 3 (synthesis)**: Specialist contributions from Phase 2 have been consumed by the synthesis. The individual contributions are no longer needed in session context -- the synthesized plan supersedes them, and full outputs remain on disk.

**After Phase 3.5 (architecture review)**: Review verdicts have been folded into the execution plan (ADVISE notes appended to task prompts, BLOCK issues resolved). Individual verdicts are no longer needed in session context.

These positions were chosen because they are **information supersession boundaries** -- points where earlier content is provably consumed by later content. Compaction between Phase 4 execution batches was considered and rejected: mid-execution compaction is too disruptive (risk of losing task tracking, agent assignments, and gate state while agents are actively running).

### Checkpoint Presentation

Checkpoints follow the SHOW category in the communication protocol (alongside approval gates, warnings, and the final summary). They use horizontal rule delimiters, a `COMPACT` label, and a pre-built `/compact` command with a `focus=` parameter specifying what to preserve and discard:

```
---
COMPACT: Phase 3 complete. Specialist details are now in the synthesis.

Run: /compact focus="Preserve: current phase, synthesized execution plan,
task list, approval gates, team name, branch name, scratch directory path.
Discard: individual specialist contributions from Phase 2."

After compaction, type `continue` to resume at Phase 3.5 (Architecture Review).

Skipping is fine if context is short. Risk: auto-compaction in later
phases may lose orchestration state.
---
```

Design rationale for the format:
- **Pre-built command**: Copy-paste execution, zero cognitive effort.
- **Resume instruction**: After the `/compact` command, a single line tells the user what to type (`continue`) and names the destination phase for post-compaction orientation.
- **"Skipping is fine" framing**: User is in control; this is a suggestion, not a demand.
- **Consequence stated**: The risk of skipping (uncontrolled auto-compaction later) is named once.

### Decline Behavior

If the user declines compaction (types "skip", "continue", or anything other than running `/compact`), the orchestrator prints a single warning and proceeds:

```
Continuing without compaction. Auto-compaction may interrupt later phases.
```

The orchestrator does **not** re-prompt at subsequent boundaries. Nagging undermines trust -- the user has made a judgment call. The cost of a wrong call (auto-compaction fires at an inconvenient time) is recoverable; the cost of persistent nagging is permanent trust erosion.

---

## 4. Constraints

- **No programmatic compaction.** Claude Code does not expose compaction controls to agents. The `/compact` command requires user action, which introduces friction that cannot be eliminated.
- **No auto-compaction reliance.** Auto-compaction is unreliable for preserving structured orchestration state. The strategy treats it as a failure mode to mitigate, not a feature to depend on.
- **No compaction between Phase 4 execution batches.** Mid-execution compaction risks losing task tracking, agent assignments, and gate state while agents are actively running. The disruption outweighs the context savings.
- **Inline summaries still accumulate.** Approximately 600 tokens for six specialists is much better than 12000, but not zero. Compaction checkpoints are the second defense for reclaiming this space.
- **User can always decline compaction.** The strategy warns once and does not nag. A user who declines accepts the risk of uncontrolled auto-compaction in later phases.
- **Focus parameter is best-effort.** The `/compact focus=` parameter guides compaction but does not guarantee specific content is preserved. Critical state (scratch directory path, branch name, current phase) should also be present in scratch files for recovery.

---

## 5. Integration with Orchestration Flow

Scratch file writes and compaction checkpoints map to specific points in the [nine-phase orchestration flow](orchestration.md):

```
Phase 1: Meta-Plan
  - mkdir scratch directory
  - Write metaplan to phase1-metaplan.md

Phase 2: Specialist Planning
  - Write each specialist's full output to phase2-{agent}.md
  - Record inline summary per specialist (~80-120 tokens each)

Phase 3: Synthesis
  - Nefario reads full contributions from scratch files (not from session context)
  - Write synthesis to phase3-synthesis.md
  - Record compact synthesis summary in session
  >>> COMPACTION CHECKPOINT (Phase 2 content superseded by synthesis)

Phase 3.5: Architecture Review
  - Reviewers read full plan from phase3-synthesis.md
  - Write BLOCK/ADVISE verdicts to phase3.5-{reviewer}.md
  - Fold ADVISE notes into task prompts
  >>> COMPACTION CHECKPOINT (review verdicts superseded by finalized plan)

Phase 4: Execution
  - No compaction checkpoints (too disruptive mid-execution)
  - Scratch files available for recovery if auto-compaction fires
  >>> OPTIONAL COMPACTION CHECKPOINT (execution outputs superseded by results)

Phase 5: Code Review
  - Write review findings to scratch files (phase5-{reviewer}.md)
  - Dark kitchen: only unresolvable BLOCKs surface to session

Phase 6: Test Execution
  - Write test results to scratch files (phase6-test-results.md)
  - Dark kitchen: only failures surface to session

Phase 7: Deployment (conditional)
  - Write deployment log to scratch files (phase7-deployment.md)

Phase 8: Documentation (conditional)
  - Write documentation checklist and outcomes to scratch files (phase8-docs.md)
```

The scratch file convention and compaction checkpoints are defined in the [nefario skill](../skills/nefario/SKILL.md), which is the operational specification. This document provides the design rationale for the choices made there.
