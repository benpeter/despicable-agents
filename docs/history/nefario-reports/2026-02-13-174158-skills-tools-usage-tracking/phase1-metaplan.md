## Meta-Plan

### Task Analysis

Add a "Skills & Tools Used" section to the nefario execution report template and update the skill instructions so the calling session populates it from conversation context. This is a documentation and template change -- no runtime code, no hooks, no shell instrumentation. The scope touches three files: `docs/history/nefario-reports/TEMPLATE.md`, `skills/nefario/SKILL.md`, and the nefario agent prompt (for awareness of the new section). Existing reports must remain valid (new section is additive with conditional inclusion).

### Planning Consultations

#### Consultation 1: Report Template and DevX Design

- **Agent**: devx-minion
- **Model**: opus
- **Planning question**: The report template (`docs/history/nefario-reports/TEMPLATE.md`) needs a new section tracking skills invoked and tools used during an orchestration session. Skills are known by name (e.g., `/nefario`, `/despicable-lab`). Tool counts would come from conversation context (the calling session can observe which tools it called). Design the section: What fields should appear? Should skills and tools be separate subsections or one table? What is the right level of granularity for tool counts (per-agent, per-phase, or session-total)? How should the section degrade gracefully when tool counts are not extractable? Consider that the template already has `agents-involved` in frontmatter and an `External Skills` section -- how does this new section relate to and avoid redundancy with those?
- **Context to provide**: `docs/history/nefario-reports/TEMPLATE.md` (full), relevant sections of `skills/nefario/SKILL.md` (Data Accumulation, Report Template, Report Writing Checklist), a recent report for reference pattern
- **Why this agent**: DevX expertise in designing developer-facing documentation formats, information hierarchy, and graceful degradation patterns

#### Consultation 2: Session Context and Data Flow

- **Agent**: ai-modeling-minion
- **Model**: opus
- **Planning question**: The calling session (main Claude Code session running the `/nefario` skill) needs to track which skills were invoked and which tools were used, then populate the report section at wrap-up. Currently, session context tracks phase data at boundaries (timestamps, agent names, verdicts, task outcomes). How should skills and tools tracking be added to this data accumulation pattern? Specifically: (1) At what phase boundaries should skill invocations be recorded? (2) Can tool usage counts be extracted from conversation context reliably, or is this inherently best-effort? (3) What is the minimal session context overhead to track this data without contributing to context bloat? (4) The existing `External Skills` section tracks project-local skills discovered during meta-plan. The new section should track ALL skills actually invoked during the session (including the nefario skill itself, despicable-lab if used, etc.). How should the data accumulation instructions distinguish "discovered" from "invoked"?
- **Context to provide**: `skills/nefario/SKILL.md` sections on Data Accumulation, Inline Summary Template, and Session Context; the `External Skills` section of TEMPLATE.md
- **Why this agent**: Expertise in prompt engineering and context management -- this agent understands how Claude Code sessions accumulate and manage context, and can advise on the most reliable extraction patterns

### Cross-Cutting Checklist

- **Testing** (test-minion): Include for planning. The template changes need validation criteria -- how do we verify that a generated report with the new section is correct? test-minion should advise on: what constitutes a valid skills/tools section, what edge cases exist (no skills invoked, tool counts unavailable, advisory-mode sessions), and whether the template's conditional inclusion rules need a new entry.
- **Security** (security-minion): Exclude from planning. This change adds a documentation section to a markdown template. No attack surface, no user input processing, no secrets handling, no new dependencies. The existing sanitization rules in SKILL.md (credential pattern scanning) already cover report content.
- **Usability -- Strategy** (ux-strategy-minion): Include for planning. The report is a user-facing artifact. ux-strategy-minion should advise on: Does this section add cognitive load without proportional value? Where in the report should it appear (the current section ordering has a deliberate information hierarchy)? Should it be collapsed by default? Is there a risk of information overload in an already-detailed report format?
- **Usability -- Design** (ux-design-minion / accessibility-minion): Exclude from planning. The report is a markdown document rendered by GitHub -- no UI components, no interaction patterns, no visual hierarchy decisions beyond what ux-strategy covers.
- **Documentation** (software-docs-minion): Exclude from planning. The change IS documentation -- the template and skill instructions are the deliverables. devx-minion and ai-modeling-minion cover the design. A separate documentation review would be circular.
- **Observability** (observability-minion / sitespeed-minion): Exclude from planning. No runtime components, no services, no web-facing output.

### Anticipated Approval Gates

1. **Template section design** (MUST gate): The section format, field definitions, and placement within the template. This is hard to reverse (all future reports will use it) and has downstream dependents (SKILL.md data accumulation instructions depend on the template design). Confidence: MEDIUM -- multiple valid approaches exist for granularity and layout.

No other gates anticipated. The SKILL.md data accumulation changes follow directly from the approved template design.

### Rationale

This task is a focused template and documentation change touching three files. Two specialists are needed for planning:

- **devx-minion** owns the template design question -- what the section looks like, how it relates to existing sections, and how it degrades gracefully. This is the core design decision.
- **ai-modeling-minion** owns the data flow question -- how the calling session tracks and populates the data. This is the feasibility and integration question.
- **ux-strategy-minion** provides the user perspective -- whether the section adds value proportional to its cognitive cost, and where it fits in the report's information hierarchy.
- **test-minion** advises on validation criteria and edge cases for the conditional inclusion rules.

Security, observability, and UI design are not relevant -- this is a markdown template change with no runtime behavior.

### Scope

**In scope**:
- New section in `docs/history/nefario-reports/TEMPLATE.md` for skills invoked and tools used
- Updated conditional inclusion rules in the template
- Updated data accumulation instructions in `skills/nefario/SKILL.md`
- Updated report writing checklist in `skills/nefario/SKILL.md`
- Updated CONDENSE/session context tracking for skills and tools

**Out of scope**:
- Runtime hooks or shell-based instrumentation
- Modifying Claude Code internals
- Backfilling existing reports
- Changes to agent AGENT.md files
- Changes to the nefario agent prompt (AGENT.md) -- it references the template, which is the source of truth

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | ORCHESTRATION | Agent rebuild/check | Not relevant -- task does not involve agent rebuilding |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant -- task does not involve status line |
| despicable-prompter | `skills/despicable-prompter/` | ORCHESTRATION | Briefing coach | Not relevant -- task does not involve prompt refinement |

#### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with the task domain (report template design and session context tracking).
