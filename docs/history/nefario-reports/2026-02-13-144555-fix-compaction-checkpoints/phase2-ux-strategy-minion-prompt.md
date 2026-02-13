You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Issue #87: Fix compaction checkpoints in the nefario orchestration skill.

Compaction checkpoints (after Phase 3 and Phase 3.5) print a blockquote advisory suggesting the user run `/compact`, but the orchestration proceeds immediately without pausing. The user sees the suggestion flash by and has no opportunity to act on it.

The proposed fix replaces the blockquote advisory with an `AskUserQuestion` gate:

- `header`: "Compact"
- `question`: "Phase N complete. Compact context before continuing?"
- `options`:
  1. label: "Skip", description: "Continue without compaction. Auto-compaction may interrupt later phases." (recommended)
  2. label: "Compact", description: "Compact now. The /compact command will be copied to your clipboard."

**If user selects "Compact":**
1. Copy the full `/compact focus="Preserve: ..."` command to the system clipboard (via `pbcopy` on macOS, with fallback note for other platforms)
2. Print a short note: "Paste and run the command from your clipboard. You can type `continue` and hit Return while compaction is running — it will be queued and executed once compaction completes."
3. Wait for user to say "continue" before proceeding

**If user selects "Skip":**
Proceed immediately with a one-line note: "Continuing without compaction."

## Your Planning Question

Review the proposed AskUserQuestion gate flow (Skip/Compact options, clipboard copy, "type continue while compaction runs" instruction) for cognitive load and friction. Key open questions:
1. Is "Skip" as the recommended default correct?
2. Is the 3-step Compact path (clipboard copy, paste-and-run, type continue) too many steps?
3. Is the "type continue while compaction is running" instruction intuitive?
4. Should the header follow the `P<N> Label` convention used by other gates (e.g., "P3 Compact")?

## Context

The nefario orchestration skill uses AskUserQuestion gates for all user decision points. The visual hierarchy convention is:
- Decision blocks (heaviest): approval gates requiring user action
- Orientation: single-line phase transition markers
- Advisory: blockquote with bold label
- Inline: plain text

Current AskUserQuestion header convention: `P<N> <Label>` (max 12 chars), e.g., "P1 Team", "P3.5 Plan", "P4 Gate".

The two affected checkpoints are at:
- Post-Phase 3 (lines 811-825 of SKILL.md): after synthesis, before architecture review
- Post-Phase 3.5 (lines 1194-1206 of SKILL.md): after architecture review, before execution

Read the SKILL.md at `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` for full context on the existing gate patterns and visual hierarchy.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase2-ux-strategy-minion.md`
