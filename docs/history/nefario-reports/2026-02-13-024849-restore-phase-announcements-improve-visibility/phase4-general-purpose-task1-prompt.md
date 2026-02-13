You are editing `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` to restore phase announcements and improve orchestration message visibility. Make ALL of the following changes in a single pass.

## Context

The Communication Protocol controls what nefario shows to users. Phase transition announcements are currently in NEVER SHOW, which destroyed user orientation. This task restores them and improves gate formatting.

## Changes to make

### 1. Restore phase announcements in Communication Protocol

In the **SHOW** list, add a new bullet after the existing items:
```
- Phase transition announcements (one-line markers at phase boundaries)
```

In the **NEVER SHOW** list, REMOVE this line:
```
- Phase transition announcements ("Starting Phase 2...")
```
Keep "Post-execution phase transitions" in NEVER SHOW -- the dark kitchen stays silent.

### 2. Add phase announcement format specification

After the Heartbeat line, add a new subsection:

```markdown
### Phase Announcements

At each phase boundary, print a single-line marker:

```
**--- Phase N: <Name> ---**
```

Phase markers by phase:
- Phase 1: `**--- Phase 1: Meta-Plan ---**`
- Phase 2: `**--- Phase 2: Specialist Planning (<N> agents) ---**`
- Phase 3: `**--- Phase 3: Synthesis ---**`
- Phase 3.5: `**--- Phase 3.5: Architecture Review (<N> reviewers) ---**`
- Phase 4: `**--- Phase 4: Execution (<N> tasks, <N> gates) ---**`
- Phase 5-8: No individual markers. The existing CONDENSE line (`Verifying: ...`) serves as the combined entry marker for post-execution phases. The dark kitchen pattern is preserved.

Rules:
- One line maximum. No multi-line frames.
- Parenthetical context is optional -- include agent/task/gate counts where they set user expectations.
- Phase markers appear at the START of each phase, before any other phase output.
- Do not use "Starting..." or "Entering..." verbs. The marker itself implies transition.
```

### 3. Normalize file reference labels across all gates

Apply this pattern to ALL file references in gate presentations:
- Label: `Details:` (universal "read more" reference)
- Always show full resolved path
- Add parenthetical content hint (2-6 words describing what the user will find)

Specific changes:

a) **Team Approval Gate**: Find `Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md`
   Change to: `Details: $SCRATCH_DIR/{slug}/phase1-metaplan.md  (planning questions, cross-cutting checklist)`

b) **Reviewer Approval Gate**: Find `Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md`
   Change to: `Details: $SCRATCH_DIR/{slug}/phase3-synthesis.md  (task prompts, agent assignments, dependencies)`

c) **Plan Impasse**: Find `Full context: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md`
   Change to: `Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md  (reviewer positions, revision history)`

d) **Execution Plan Gate -- Working dir**: Keep as-is: `Working dir: $SCRATCH_DIR/{slug}/`

e) **Execution Plan Gate -- Full plan**: Find `FULL PLAN: $SCRATCH_DIR/{slug}/phase3-synthesis.md (task prompts, agent assignments, dependencies)`
   Change to: `Details: $SCRATCH_DIR/{slug}/phase3-synthesis.md  (task prompts, agent assignments, dependencies)`

f) **Advisory references**: Where there are `Details:` and `Prompt:` references, add content hint to Details:
   Change `Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md`
   To: `Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md  (reviewer analysis and recommendations)`
   Keep `Prompt:` label unchanged.

### 4. Add universal path display rule to Path Resolution section

After the existing Path Resolution introductory text (before the "Scratch Directory" subsection), add:

```markdown
**Path display rule**: All file references shown to the user must use the
resolved absolute path. Never abbreviate, elide, or use template variables
in user-facing output. Users copy-paste these paths into `cat`, `less`, or
their editor -- shortened or templated paths break that workflow.
```

### 5. Convert compaction checkpoints to blockquote format

IMPORTANT (from lucy's ADVISE): Preserve the risk sentences when converting.

a) **Phase 3 compaction checkpoint**: Find the compaction checkpoint block that starts with `---` and `COMPACT: Phase 3 complete.`
   Replace the entire block (from `---` to `---`) with:

```markdown
> **COMPACT** -- Phase 3 complete. Specialist details are now in the synthesis.
>
> Run: `/compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, scratch directory path. Discard: individual specialist contributions from Phase 2."`
>
> After compaction, type `continue` to resume at Phase 3.5 (Architecture Review).
> Skipping is fine if context is short. Risk: auto-compaction in later phases may lose orchestration state.
```

b) **Phase 3.5 compaction checkpoint**: Find the compaction checkpoint that starts with `---` and `COMPACT: Phase 3.5 complete.`
   Replace the entire block (from `---` to `---`) with:

```markdown
> **COMPACT** -- Phase 3.5 complete. Review verdicts are folded into the plan.
>
> Run: `/compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, scratch directory path. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."`
>
> After compaction, type `continue` to resume at Phase 4 (Execution).
> Skipping is fine if context is short. Risk: auto-compaction during execution may lose task/agent tracking.
```

### 6. Add Visual Hierarchy reference to Communication Protocol

After the Phase Announcements subsection (added in change 2), add:

```markdown
### Visual Hierarchy

Orchestration messages use three visual weights:

| Weight | Pattern | Use |
|--------|---------|-----|
| **Decision** | `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
| **Orientation** | `**--- Phase N: Name ---**` | Phase transitions -- glance and continue |
| **Advisory** | `>` blockquote with bold label | Compaction checkpoints -- optional user action |
| **Inline** | Plain text, no framing | CONDENSE lines, heartbeats, informational notes |

Decision blocks are the heaviest: multi-line with structured fields. Orientation
is a single bold line. Advisory uses blockquote indentation. Inline flows without
interruption. This hierarchy maps to attention demands: the heavier the visual
signal, the more attention needed.
```

## What NOT to change

- Do not rename the tier labels (SHOW / NEVER SHOW / CONDENSE stay as-is)
- Do not add `NEFARIO |` prefix to gate headers
- Do not add `---` top/bottom framing to approval gates
- Do not change the AskUserQuestion parameters or option labels
- Do not modify post-execution phase internals (dark kitchen preserved)
- Do not change the CONDENSE line formats
- Do not change the Heartbeat specification

## Verification

After making all changes, read back the Communication Protocol section and verify:
1. "Phase transition announcements" is in SHOW, not in NEVER SHOW
2. "Post-execution phase transitions" is still in NEVER SHOW
3. Phase announcement format is specified with the one-line bold marker pattern
4. Visual Hierarchy subsection exists
5. Path display rule exists in Path Resolution
6. All gate file references use `Details:` label with content hints
7. Both compaction checkpoints use blockquote format with risk sentences preserved
8. `Working dir:` label is unchanged
