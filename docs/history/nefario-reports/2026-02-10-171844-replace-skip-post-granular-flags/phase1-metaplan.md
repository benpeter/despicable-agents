# Phase 1: Meta-Plan -- Replace --skip-post with Granular Skip Flags

## Meta-Plan

### Context: Prior Attempt and Current State

A previous attempt at this task (`nefario/scratch/granular-skip-flags-nefario/`) produced
a complete meta-plan, specialist contributions (devx-minion + ux-strategy-minion), and a
synthesis. That work was never executed. More importantly, SKILL.md has been significantly
refactored since then -- the approval gate now uses `AskUserQuestion` with structured
options and a **follow-up question pattern** (lines 492-501). The previous synthesis was
written against the old text-based `approve --skip-post` command pattern.

The previous specialist contributions remain highly relevant for design decisions (flag
naming, risk-ordering, backward compatibility, deprecation framing). The new meta-plan
accounts for the changed interaction model.

### Key Differences from Prior Attempt

1. **Approval gate interaction model changed**: SKILL.md now uses `AskUserQuestion` with
   a follow-up prompt after "Approve" that offers "Run all" vs "Skip post-execution"
   (lines 492-501). The granular flags need to integrate with this structured prompt
   pattern, not the old freeform text `approve --skip-post`.

2. **`docs/orchestration.md` changed**: Line 104 now says "At each approval gate, after
   selecting 'Approve', a follow-up prompt offers the option to skip post-execution
   phases (Phases 5, 6, and 8)." -- referencing the follow-up prompt, not `--skip-post`.

3. **`the-plan.md` has no `--skip-post` references**: No changes needed there.

4. **The gating logic at line 556 and verification summary at line 887 still use the old
   `--skip-post` text** and need updating.

### Planning Consultations

#### Consultation 1: CLI Flag Design and AskUserQuestion Integration
- **Agent**: devx-minion
- **Planning question**: The nefario SKILL.md now uses `AskUserQuestion` structured prompts
  for approval gates, with a follow-up question after "Approve" that offers "Run all" vs
  "Skip post-execution" (2 options, `multiSelect: false`). We want to replace this binary
  follow-up with granular skip control. Two design paths exist:

  (A) Replace the 2-option follow-up with a multi-select prompt listing individual phases
  to **run** (pre-checked) or **skip** (unchecked). E.g., `multiSelect: true` with options
  "Code review", "Tests", "Documentation" -- all checked by default, user unchecks to skip.

  (B) Replace the 2-option follow-up with granular skip options: "Run all" (default),
  "Skip code review", "Skip tests", "Skip docs", "Skip all post-execution". This uses
  `multiSelect: true` so users can combine skips.

  (C) Keep freeform text flags (`--skip-review`, `--skip-tests`, `--skip-docs`) as the
  primary interface, removing or simplifying the `AskUserQuestion` follow-up.

  Which approach best serves developer ergonomics given that: (1) the AskUserQuestion tool
  provides structured selection with labels/descriptions, (2) the LLM still accepts
  freeform text input alongside structured prompts, (3) the goal is conscious individual
  decisions about what to skip? Also: should `--skip-post` be retained as a text-input
  shorthand even if the primary UI is structured? Read `skills/nefario/SKILL.md` lines
  480-501 for the current implementation.

- **Context to provide**: `skills/nefario/SKILL.md` (full file, especially lines 480-501
  for the current follow-up prompt, lines 549-560 for post-execution gating, lines 880-890
  for verification summary). Also the prior devx-minion contribution at
  `nefario/scratch/granular-skip-flags-nefario/phase2-devx-minion.md` which has flag naming
  decisions that should be reused.
- **Why this agent**: devx-minion specializes in CLI design and developer ergonomics. The
  critical design question is how granular skip options integrate with AskUserQuestion's
  structured prompt model -- this is fundamentally a developer interface design problem.

#### Consultation 2: User Journey and Cognitive Load in the Structured Prompt
- **Agent**: ux-strategy-minion
- **Planning question**: The current approval gate follow-up uses AskUserQuestion with
  2 options ("Run all" / "Skip post-execution"). Replacing this with granular options
  changes the cognitive load profile of every gate interaction. Three interaction patterns
  are possible:

  (A) Multi-select with pre-checked phases (user unchecks to skip) -- "opt-out" model.
  (B) Multi-select with skip options (user checks to skip) -- "opt-in to skip" model.
  (C) Single-select with explicit combinations ("Run all", "Skip docs only",
  "Skip docs + tests", "Skip all") -- enumerated paths.

  Which pattern best serves the goals of: (1) making the safe default (run all) the path
  of least resistance, (2) enabling conscious individual skip decisions, (3) keeping the
  interaction fast for users who want the default, (4) maintaining asymmetric disclosure
  where skipping safety-critical phases (review, tests) requires more cognitive effort than
  skipping low-risk phases (docs)?

  Also consider: the prior ux-strategy-minion contribution
  (`nefario/scratch/granular-skip-flags-nefario/phase2-ux-strategy-minion.md`) recommended
  risk-gradient ordering (docs first, review last) and no confirmation dialogs. Those
  principles still apply but the interaction modality has changed from freeform text to
  structured selection.

- **Context to provide**: `skills/nefario/SKILL.md` lines 480-501 (current follow-up prompt),
  the Communication Protocol (lines 39-68), and the prior ux-strategy-minion contribution.
- **Why this agent**: ux-strategy-minion evaluates cognitive load, user journeys, and
  simplification. The follow-up prompt fires at every approval gate (3-5 times per session).
  Getting the interaction pattern right directly affects whether users make thoughtful
  skip decisions or reflexively choose the fastest option.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. No executable code is produced. All changes are to
  markdown/prompt text files (SKILL.md, AGENT.md, AGENT.overrides.md, orchestration.md).
  The "parsing" is done by an LLM following instructions, not by a code parser.

- **Security**: Exclude from planning. The skip flags control which verification phases run.
  Skipping code review or tests reduces safety coverage, but this is an explicit user
  choice (the current "Skip post-execution" option already permits this). No new attack
  surface. security-minion should review in Phase 3.5 to confirm the new design does not
  make it easier to accidentally skip safety-critical phases (e.g., the default must remain
  "run all").

- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning
  question: How should the structured AskUserQuestion follow-up present granular skip
  options without increasing cognitive load or nudging users toward unsafe defaults?

- **Usability -- Design**: Exclude from planning. No graphical UI is produced. The
  "interface" is a structured text prompt in a CLI, which ux-strategy-minion covers.

- **Documentation**: Include in execution but not planning consultation. The changes to
  docs/orchestration.md and the SKILL.md itself are documentation updates. software-docs-
  minion will review in Phase 3.5 for completeness. No separate planning input needed
  because the documentation mirrors the design decisions from devx-minion and ux-strategy-
  minion.

- **Observability**: Exclude from planning. No runtime components, services, or APIs.

### Anticipated Approval Gates

**None anticipated.** All changes are additive edits to markdown/prompt text files:

- `skills/nefario/SKILL.md` -- flag definitions, gate follow-up prompt, gating logic,
  verification summary
- `nefario/AGENT.overrides.md` -- one-line update
- `nefario/AGENT.md` -- one-line update (derived from overrides)
- `docs/orchestration.md` -- paragraph update

These are easy to reverse (markdown), low blast radius (internal orchestration tool,
no downstream code depends on exact flag names), and the design direction is clear
(granular > coarse is established CLI convention). The only judgment call -- interaction
pattern for the AskUserQuestion follow-up -- will be resolved by the two planning
consultations before execution begins.

### Rationale

This task is a **developer interaction design problem** applied to a prompt-based skill.
Two specialists are needed for planning:

1. **devx-minion** brings CLI/developer tooling expertise. The critical question is how
   granular skip flags integrate with the AskUserQuestion structured prompt model that was
   introduced after the prior attempt. This is a new design dimension not covered by the
   previous contributions.

2. **ux-strategy-minion** brings cognitive load and user journey expertise. The follow-up
   prompt fires at every approval gate. The interaction pattern choice (multi-select vs.
   enumerated options vs. text flags) directly determines whether users engage thoughtfully
   or reflexively.

Both specialists produced excellent prior contributions that established foundational
decisions (flag naming, risk-gradient ordering, no confirmation dialogs, `--skip-post`
as shorthand not deprecated). The new consultations focus specifically on the
AskUserQuestion integration question that did not exist in the prior attempt.

Other agents excluded from planning:
- **software-docs-minion**: Documentation changes follow directly from design decisions.
  Phase 3.5 review is sufficient.
- **lucy/margo**: Governance review at Phase 3.5 will catch consistency and simplicity
  issues.

### Scope

**In scope**:
- Replace the binary "Run all" / "Skip post-execution" follow-up with granular skip
  options in `skills/nefario/SKILL.md`
- Update post-execution phase gating logic in SKILL.md (line 556)
- Update verification summary format in SKILL.md (line 887)
- Update CONDENSE status line in SKILL.md (line 553)
- Update `nefario/AGENT.overrides.md` line 53
- Update `nefario/AGENT.md` line 595 (or rebuild via /despicable-lab)
- Update `docs/orchestration.md` line 104
- Decide on `--skip-post` backward compatibility as text input

**Out of scope**:
- Post-execution phase implementations (Phases 5-8 logic)
- Nefario planning phases (1-3.5)
- Agent specs in `the-plan.md` (no references to `--skip-post` exist there)
- Any executable code changes (all changes are markdown/prompt text)
