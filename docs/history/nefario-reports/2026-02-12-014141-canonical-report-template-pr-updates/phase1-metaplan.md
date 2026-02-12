# Meta-Plan: Canonical Report Template and PR Update Mechanism

## Scope

**Goal**: Establish a canonical report template in SKILL.md that every nefario execution
report and PR description follows identically, and add a mechanism for PR bodies to stay
accurate when additional work lands on the same branch after the initial nefario run.

**In scope**:
- Explicit report template in SKILL.md with every section defined (name, order, content
  guidance, conditional inclusion rules)
- Canonical section order per the issue specification
- Report doubles as PR body (same content, no separate formatting step)
- "Post-Nefario Updates" section and low-friction update mechanism
- Wrap-up sequence updates to enforce the template
- TEMPLATE.md alignment (or deprecation in favor of SKILL.md as single source)

**Out of scope**:
- Modifying existing reports (historical immutability)
- AGENT.md changes
- Report index generation
- Companion directory structure changes
- Complex automation, git hooks, or CI pipelines
- New code or infrastructure

## Planning Consultations

### Consultation 1: Report Template Structure and Developer Experience

- **Agent**: devx-minion
- **Planning question**: Given the inconsistencies across 40+ existing reports (section
  naming variance like "Executive Summary" vs "Summary", frontmatter field drift between
  v1/v2/non-standard, section ordering differences, missing sections), what is the optimal
  template structure that: (a) the LLM can follow deterministically, (b) produces a document
  that doubles cleanly as a PR body after frontmatter stripping, and (c) supports conditional
  sections (Test Plan, External Skills, Post-Nefario Updates) without cluttering reports that
  don't need them? Also: what is the simplest mechanism for PR body updates when subsequent
  commits land on the same branch -- should it be a nefario convention (auto-detect same branch
  on re-run), a standalone skill invocation, or a manual section the user appends?
- **Context to provide**:
  - `skills/nefario/SKILL.md` (Report Generation section, lines 1280-1416)
  - `docs/history/nefario-reports/TEMPLATE.md` (current standalone template)
  - Sample reports showing inconsistencies: #36 (`2026-02-11-143008`), #30 (`2026-02-10-205010`),
    #32 (`2026-02-11-132900`), #27 (`2026-02-11-122254`)
  - The canonical section order from the issue
- **Why this agent**: devx-minion owns developer-facing template design, configuration file
  structure, and error messaging. The template is fundamentally a developer experience artifact --
  it must be clear enough for an LLM to follow without drift, and the PR update mechanism must
  be low-friction for the developer workflow.

### Consultation 2: Documentation Architecture and Template Governance

- **Agent**: software-docs-minion
- **Planning question**: The project currently has two sources defining report structure:
  SKILL.md (inline in wrap-up sequence, incomplete) and TEMPLATE.md (standalone, more complete
  but not authoritative). The issue requires SKILL.md to contain the explicit template. What
  should the relationship between SKILL.md and TEMPLATE.md be after this change -- should
  TEMPLATE.md be deprecated/deleted, kept as a rendered reference, or maintained as a secondary
  view? How should the template encode conditional sections (Test Plan appears only when tests
  ran, External Skills only when skills were discovered, Post-Nefario Updates only on subsequent
  runs) so they are present in the specification but absent from reports that don't trigger them?
  What documentation artifacts need updating beyond SKILL.md itself?
- **Context to provide**:
  - `skills/nefario/SKILL.md` (Report Generation + Wrap-up Sequence sections)
  - `docs/history/nefario-reports/TEMPLATE.md`
  - `CLAUDE.md` project conventions (report-related entries)
  - Sample reports showing TEMPLATE.md adherence vs drift
- **Why this agent**: software-docs-minion specializes in documentation architecture,
  template governance, and cross-reference consistency. The core question here is how to
  structure the template as a single source of truth without creating maintenance burden from
  redundant artifacts.

### Consultation 3: UX Strategy for Report Consumption

- **Agent**: ux-strategy-minion
- **Planning question**: The report serves three audiences with different needs: (1) the PR
  reviewer who wants a quick decision on whether to merge, (2) the orchestrating user who wants
  to verify what was accomplished, and (3) the future investigator tracing a decision. The
  canonical section order is prescribed (Summary -> Original Prompt -> Key Design Decisions ->
  Phases -> Agent Contributions -> Execution -> Decisions -> Conflict Resolutions -> Verification
  -> External Skills -> Files Changed -> Working Files -> Test Plan -> Post-Nefario Updates).
  Does this ordering serve all three audiences well? Are there cognitive load issues with the
  prescribed order? The "Post-Nefario Updates" section must communicate what changed after the
  original nefario run without undermining the main report's narrative -- what UX pattern best
  serves this (appended section, inline annotations, or something else)?
- **Context to provide**:
  - The canonical section order from the issue
  - Sample reports showing current ordering variations
  - Current PR body generation (frontmatter stripping via tail/sed)
  - The three audience personas
- **Why this agent**: ux-strategy-minion handles user journey design, cognitive load assessment,
  and progressive disclosure -- all directly relevant to whether the prescribed section order
  and the update mechanism will be usable by all three audiences.

## Cross-Cutting Checklist

- **Testing** (test-minion): Exclude from planning. This task produces only markdown template
  changes in SKILL.md and possibly TEMPLATE.md. No executable code, no testable artifacts.
  Testing relevance is zero. Phase 3.5 mandatory review will still evaluate test strategy.

- **Security** (security-minion): Exclude from planning. The task modifies template prose
  and report formatting. No new attack surface, auth, user input handling, or secrets. The
  existing secret-scanning in the wrap-up sequence is unchanged. Phase 3.5 mandatory review
  will still evaluate security.

- **Usability -- Strategy** (ux-strategy-minion): INCLUDED as Consultation 3. The report
  template is a user-facing artifact consumed by three distinct audiences. Section ordering,
  progressive disclosure (collapsible sections), and the Post-Nefario Updates UX pattern all
  require journey coherence review.

- **Usability -- Design** (ux-design-minion, accessibility-minion): Exclude from planning.
  No user-facing UI is produced. Reports are markdown rendered by GitHub -- no custom
  interaction design or WCAG concerns beyond standard markdown rendering.

- **Documentation** (software-docs-minion): INCLUDED as Consultation 2. This task IS
  fundamentally a documentation architecture task -- the report template is a documentation
  artifact, and the relationship between SKILL.md and TEMPLATE.md is a documentation
  governance question.

- **Observability** (observability-minion, sitespeed-minion): Exclude from planning. No
  runtime components, services, APIs, or web-facing output. The task produces markdown
  template definitions only.

## Anticipated Approval Gates

1. **Report template design** (HIGH blast radius, HARD to reverse): The canonical template
   defines the structure for all future reports and PR descriptions. Every downstream task
   (wrap-up sequence, PR body generation, Post-Nefario Updates) depends on this. Every
   future nefario run will follow it. This is a MUST-gate.

   Likely the only gate. The wrap-up sequence edits and PR update mechanism are mechanical
   implementations of the approved template. Low blast radius, easy to revise.

## Rationale

Three specialists selected for planning, each bringing non-overlapping expertise:

- **devx-minion**: Template as developer-facing artifact. LLM-followability. PR update
  mechanism design. Practical workflow concerns.
- **software-docs-minion**: Documentation architecture. TEMPLATE.md vs SKILL.md governance.
  Conditional section encoding. Cross-reference consistency.
- **ux-strategy-minion**: Audience analysis. Section ordering validation. Progressive
  disclosure. Post-Nefario Updates UX pattern.

Other agents were considered and excluded:
- **product-marketing-minion**: Reports are internal/technical artifacts, not user-facing
  marketing content. The PR description aspect is developer-to-developer, not product
  positioning.
- **ai-modeling-minion**: No LLM architecture, prompt engineering, or multi-agent design
  involved. The template is consumed by the LLM but the design challenge is document
  structure, not prompt engineering.
- **lucy/margo**: Governance reviewers participate in Phase 3.5 mandatory review, not
  planning. Their domain (intent alignment, simplicity) is better applied to the finished
  plan than to planning consultations.
