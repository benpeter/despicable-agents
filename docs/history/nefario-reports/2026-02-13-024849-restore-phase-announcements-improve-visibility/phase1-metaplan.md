# Meta-Plan: Restore Phase Announcements and Improve Orchestration Message Visibility

## Scope

**Goal**: Make nefario's orchestration messages (phase transitions, approval gates, status updates) visually distinct from tool output and easy to follow. Approval gates should present clear, meaningful links to artifacts instead of raw scratch directory paths.

**In scope**:
- SKILL.md Communication Protocol / output discipline sections
- Approval gate message formatting (team gate, reviewer gate, execution plan gate, mid-execution gates)
- Scratch directory reference presentation in user-facing messages
- Phase transition announcements (currently suppressed -- need selective restoration)

**Out of scope**:
- Subagent output formatting
- Tool output suppression rules unrelated to nefario messages
- AGENT.md changes
- Scratch directory structure itself
- Session Output Discipline in CLAUDE.md (those rules are for subagent suppression, distinct from nefario output)

## Planning Consultations

### Consultation 1: Terminal UX and Visual Hierarchy for Orchestration Messages

- **Agent**: ux-design-minion
- **Planning question**: Given that Claude Code renders output in a monospace terminal supporting CommonMark markdown (headers, bold, code blocks, horizontal rules, lists -- but no color, no custom fonts, no HTML), what visual formatting patterns would create clear visual distinction between nefario orchestration messages (phase transitions, approval gates, status summaries) and regular tool output? Consider: (a) consistent header/frame patterns for phase announcements, (b) visual hierarchy within approval gate blocks, (c) how to present file references meaningfully (label + path) vs raw paths. Reference the existing gate formats in `skills/nefario/SKILL.md` lines 392-416 (team gate), 717-730 (reviewer gate), 1009-1090 (execution plan gate).
- **Context to provide**: Current SKILL.md Communication Protocol (lines 132-174), existing gate presentation formats, Claude Code terminal rendering capabilities (monospace, CommonMark subset)
- **Why this agent**: UX design expertise in visual hierarchy, interaction patterns, and component design -- specifically the HOW of making orchestration messages scannable and distinguishable in a terminal context.

### Consultation 2: Cognitive Load and Information Architecture for Orchestration Output

- **Agent**: ux-strategy-minion
- **Planning question**: The current Communication Protocol has three output tiers (SHOW, NEVER SHOW, CONDENSE). The issue reveals that phase transitions were over-suppressed -- the user lost orientation during long orchestrations. How should we redesign the information architecture of nefario's output to balance (a) orientation (user always knows what phase they're in and what's happening), (b) noise reduction (tool output stays suppressed), and (c) meaningful artifact references (approval gates link to scratch files the user might want to review)? Specifically: what level of phase announcement is needed to maintain user orientation without creating noise? When should scratch paths be presented with labels vs suppressed entirely?
- **Context to provide**: SKILL.md Communication Protocol (lines 132-174), the three gate formats, CONDENSE patterns (lines 159-171), the issue's success criteria about "visually distinguishable at a glance"
- **Why this agent**: UX strategy covers WHAT information users need and WHY -- the information architecture decisions that determine which messages appear, when, and with what labels. This is the cognitive load and journey coherence perspective.

### Consultation 3: DevX Perspective on File Reference Presentation

- **Agent**: devx-minion
- **Planning question**: Approval gates currently reference scratch files with raw temp directory paths (e.g., `$SCRATCH_DIR/{slug}/phase1-metaplan.md`). These paths are meaningful to the orchestrator but opaque to the user. What labeling conventions would make these references useful to developers? Consider: (a) should labels describe the content ("Specialist contributions") or the file ("phase2-*.md")?, (b) should the full path always be shown or only on request?, (c) how do other CLI tools present references to working files the user might want to inspect? Reference the existing patterns at SKILL.md lines 405, 729, 1084-1086.
- **Context to provide**: Current scratch directory structure (SKILL.md lines 229-261), existing reference patterns in gate formats, the developer's perspective on reviewing orchestration artifacts
- **Why this agent**: DevX expertise in CLI design and developer-facing information presentation. This is about making file references developer-friendly in a CLI context.

### Consultation 4: Documentation Impact Assessment

- **Agent**: software-docs-minion
- **Planning question**: This task modifies the Communication Protocol and output formatting in SKILL.md. Which documentation files need updating to reflect the changes? Consider: `docs/using-nefario.md` (user guide for orchestration workflow), `docs/orchestration.md` (contributor docs for the nine-phase architecture), `docs/compaction-strategy.md` (context management docs that reference CONDENSE patterns). What is the documentation surface area of this change?
- **Context to provide**: The docs structure from `docs/architecture.md` sub-documents table, the scope of changes (Communication Protocol, gate formats, phase announcements)
- **Why this agent**: Identifies documentation that needs updating as a result of the SKILL.md changes, producing the documentation impact assessment that feeds Phase 8.

### Consultation 5: User Documentation Perspective

- **Agent**: user-docs-minion
- **Planning question**: The `docs/using-nefario.md` guide explains the orchestration workflow to end users. If we restore phase transition announcements and improve approval gate formatting, what changes does the user guide need? Specifically: does the guide currently set expectations about what the user will see during orchestration? Would users benefit from a "What to Expect" section showing example orchestration output with the new formatting?
- **Context to provide**: Current `docs/using-nefario.md`, the nature of the changes (visual formatting of orchestration messages)
- **Why this agent**: User-facing documentation perspective -- ensures the user guide accurately describes what users will see during orchestration.

### Consultation 6: Product Positioning Lens

- **Agent**: product-marketing-minion
- **Planning question**: This change improves the user experience of nefario orchestration by making phase progress visible and artifact references meaningful. From a product messaging perspective, does this change warrant any README or positioning updates? Or is this an internal quality improvement (Tier 3) that only needs documentation coverage? Evaluate against the tier framework: does this change what the project can do (Tier 1), would a user notice during normal usage (Tier 2), or is it an internal improvement (Tier 3)?
- **Context to provide**: The issue's outcome statement, the nature of changes (formatting/presentation, not new capabilities), current README.md
- **Why this agent**: Determines whether this change warrants README/positioning changes or is purely a documentation-level improvement.

## Cross-Cutting Checklist

- **Testing**: No -- this task produces changes to SKILL.md (a markdown specification file) and potentially documentation files. No executable code, no configuration, no infrastructure. Test-minion has nothing to test. Test-minion remains in Phase 3.5 mandatory review (reviewing the plan, not the output).
- **Security**: No -- no attack surface changes, no auth changes, no user input processing, no secret handling changes. The scratch path presentation changes are purely cosmetic (label + existing path). Security-minion remains in Phase 3.5 mandatory review.
- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning question: information architecture of orchestration output -- balancing orientation, noise reduction, and meaningful artifact references.
- **Usability -- Design**: INCLUDED as Consultation 1 (ux-design-minion). Planning question: visual formatting patterns for terminal-based orchestration messages. accessibility-minion NOT included -- no web-facing HTML/UI is produced; this is terminal text formatting.
- **Documentation**: INCLUDED as Consultations 4 and 5 (software-docs-minion and user-docs-minion). Planning questions: documentation impact assessment and user guide updates.
- **Observability**: No -- no runtime components, no production services, no logging/metrics/tracing changes. This is a specification file change.

## Anticipated Approval Gates

This task has a narrow scope (SKILL.md formatting changes + documentation updates) and all changes are easily reversible (markdown files, no schema changes, no API contracts). Applying the gate classification:

- **Reversibility**: Easy (markdown specification and documentation files)
- **Blast radius**: Low-to-medium (SKILL.md is consumed by the calling session, so formatting changes affect all future orchestrations, but are trivially revertible)

Expected gates: **0-1 gates**. The execution plan approval gate is the primary checkpoint. Mid-execution gates are unlikely since all tasks produce easily-reversible markdown changes. If synthesis identifies a design decision where multiple valid approaches exist (e.g., whether phase announcements should use a specific frame character), that could warrant a gate.

## Rationale

This task is primarily a UX/formatting improvement to a specification file (SKILL.md). The core expertise needed is:

1. **Visual design for terminal output** (ux-design-minion) -- the HOW of making messages visually distinct
2. **Information architecture** (ux-strategy-minion) -- the WHAT and WHEN of orchestration messages
3. **Developer experience** (devx-minion) -- file reference presentation conventions for CLI tools
4. **Documentation impact** (software-docs-minion, user-docs-minion, product-marketing-minion) -- ensuring docs reflect the changes

No infrastructure, code, API, database, or security work is involved. The task is self-contained within SKILL.md and supporting documentation.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent build/rebuild pipeline | Not relevant -- this task does not modify agent specs or AGENT.md files |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Claude Code status line configuration | Not relevant -- this task modifies SKILL.md orchestration output, not the status line sentinel mechanism |
| despicable-prompter | .claude/skills/despicable-prompter/ (symlink) | ORCHESTRATION | Briefing coach for /nefario prompts | Not relevant -- this task already has a well-defined issue with clear scope and success criteria |

### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with the task domain (SKILL.md formatting and documentation). All three skills are excluded from the plan.
