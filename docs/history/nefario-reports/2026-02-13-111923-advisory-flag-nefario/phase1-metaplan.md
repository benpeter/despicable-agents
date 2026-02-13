# Phase 1: Meta-Plan -- Advisory Flag Implementation

## Context

This task implements the `--advisory` flag on `/nefario`, previously analyzed in
an advisory orchestration (report: `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`).
The prior analysis reached unanimous consensus that this should be a flag on
nefario (not a separate skill) and mapped the implementation in detail. The
issue explicitly states this is not YAGNI -- the pattern has been established
through repeated use and the frequency threshold from the prior analysis has
been met.

The implementation touches three artifacts:
1. `skills/nefario/SKILL.md` (~1940 lines) -- the orchestration skill definition
2. `nefario/AGENT.md` -- the nefario agent system prompt
3. `docs/history/nefario-reports/TEMPLATE.md` -- the report template

Prior specialist analysis (preserved in companion directory) provides a detailed
implementation blueprint:
- **ai-modeling-minion**: Phase-by-phase applicability analysis, ~60-70 lines at
  two locations in SKILL.md, advisory synthesis output format
- **devx-minion**: Flag naming (`--advisory` over alternatives), argument parsing
  design, interaction model, 5 implementation tasks
- **lucy**: Report location (`docs/history/nefario-reports/`), `mode: advisory`
  frontmatter, no identity drift
- **margo**: Complexity budget concern (SKILL.md is large), minimal intervention
  principle

## Meta-Plan

### Planning Consultations

#### Consultation 1: Advisory workflow integration in SKILL.md
- **Agent**: devx-minion
- **Planning question**: Given the SKILL.md structure (argument parsing, nine-phase
  workflow, communication protocol, report generation, wrap-up sequence), design the
  precise insertion points for `--advisory` support. Specifically: (a) How should
  `--advisory` flag parsing integrate with the existing argument parsing section
  (position-independence, interaction with `#<issue>` mode)? (b) Where exactly does
  the advisory branch diverge from the normal flow -- after Phase 3 synthesis or
  after Phase 3.5? (c) What does the advisory wrap-up look like vs the normal
  wrap-up (report generation, scratch cleanup, no branch/PR/commit)? (d) How should
  the Team Approval Gate and Phase 3 synthesis prompt be modified (or not) for
  advisory mode? Build on your prior analysis but now produce implementation-ready
  specifications with exact section references in the current SKILL.md.
- **Context to provide**: Current SKILL.md (full), prior phase2-devx-minion.md
  contribution, the GitHub issue acceptance criteria
- **Why this agent**: devx-minion designed the flag interface in the prior advisory.
  Their expertise in CLI design, argument parsing, and developer workflow is needed
  to produce precise insertion specifications for SKILL.md.

#### Consultation 2: Advisory synthesis format and AGENT.md changes
- **Agent**: ai-modeling-minion
- **Planning question**: Design the advisory-specific synthesis behavior. Specifically:
  (a) What MODE does nefario receive for advisory synthesis -- a new `MODE: ADVISORY`
  or is it `MODE: SYNTHESIS` with an `ADVISORY: true` directive? (b) What is the
  exact output format for advisory synthesis (you proposed Executive Summary, Team
  Consensus, Dissenting Views, Recommendation, Supporting Evidence, Risks, Next
  Steps -- refine this into a concrete template)? (c) What changes to AGENT.md are
  needed, if any -- does nefario need a new mode in its Core Knowledge, or is the
  advisory behavior entirely driven by SKILL.md? (d) How does the Phase 1 meta-plan
  prompt differ for advisory (should nefario know the outcome is a report, not code)?
  Build on your prior phase mapping but produce implementation-ready specifications.
- **Context to provide**: Current AGENT.md (relevant sections), current SKILL.md
  (Phase 3 synthesis section), prior phase2-ai-modeling-minion.md, TEMPLATE.md
- **Why this agent**: ai-modeling-minion mapped the phase-by-phase architecture in
  the prior advisory. Their expertise in multi-agent orchestration architecture is
  needed to define the synthesis behavior and mode interactions.

#### Consultation 3: Report template for advisory mode
- **Agent**: software-docs-minion
- **Planning question**: Design the advisory report template modifications to
  TEMPLATE.md. The current template has 12 top-level H2 sections and conditional
  inclusion rules. For advisory mode: (a) Which existing sections apply as-is,
  which need modification, and which should be omitted? (b) What new sections are
  needed (e.g., Team Recommendation, Consensus table, Strongest Arguments, When
  to Revisit)? (c) How should the `mode: advisory` frontmatter interact with
  conditional section rules? (d) Should advisory have its own template file
  (ADVISORY-TEMPLATE.md) or conditional blocks in the existing TEMPLATE.md?
  Reference the existing advisory report at
  `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`
  as a concrete example of what an advisory report looks like in practice.
- **Context to provide**: Current TEMPLATE.md, the existing advisory report
  (as exemplar), SKILL.md report generation section
- **Why this agent**: software-docs-minion owns documentation architecture,
  including template design, conditional section rules, and format consistency.
  The report template is a documentation artifact, not an orchestration artifact.

### Cross-Cutting Checklist

- **Testing** (test-minion): EXCLUDE from planning. The implementation modifies
  SKILL.md, AGENT.md, and TEMPLATE.md -- all markdown specification files with no
  executable code. There is no test infrastructure for these artifacts. Testing
  will be manual (run `/nefario --advisory` after implementation). test-minion
  adds no planning value here.

- **Security** (security-minion): EXCLUDE from planning. Advisory mode removes
  capabilities (no branch creation, no commits, no PR, no code execution). It
  does not create new attack surface, handle authentication, process user input
  differently, or manage secrets. The existing security model (scratch directory
  permissions, secret sanitization) applies unchanged.

- **Usability -- Strategy** (ux-strategy-minion): EXCLUDE from planning.
  The prior advisory already established the UX model: same input grammar,
  `--advisory` flag, advisory report as deliverable. devx-minion covered the
  cognitive load analysis, discoverability, and principle of least surprise in
  their prior contribution. The current task is implementation of an already-designed
  interface, not interface design. ux-strategy-minion would duplicate devx-minion's
  prior analysis without adding new insight.

- **Usability -- Design** (ux-design-minion / accessibility-minion): EXCLUDE.
  No user-facing UI components, visual layouts, or web-facing HTML. The output
  is a markdown report and SKILL.md specification changes.

- **Documentation** (software-docs-minion): INCLUDE -- see Consultation 3.
  The report template is a core documentation artifact that needs design for
  advisory mode. user-docs-minion is excluded because there are no end-user
  guides to update (the `argument-hint` in SKILL.md frontmatter IS the user
  documentation for this project).

- **Observability** (observability-minion / sitespeed-minion): EXCLUDE. No
  runtime components, services, APIs, or web-facing code. The status line
  updates (`nefario-status-$SID`) already exist and need only a minor
  variant for advisory mode, which devx-minion can specify.

### Anticipated Approval Gates

1. **SKILL.md advisory workflow design** (MUST gate): Hard to reverse (defines
   the advisory mode contract for all future advisory runs), high blast radius
   (AGENT.md changes and TEMPLATE.md changes depend on SKILL.md decisions about
   mode handling, synthesis format, and wrap-up flow). This is the foundational
   design decision.

2. **Report template design** (no gate): Easy to reverse (additive template
   changes, no downstream dependents beyond the SKILL.md reference). Can be
   adjusted after initial implementation without cascading impact.

### Rationale

Three specialists are selected for planning:

- **devx-minion**: Owns the SKILL.md integration design -- argument parsing,
  workflow branching, gate modifications, wrap-up sequence. This is the largest
  and most complex part of the implementation.

- **ai-modeling-minion**: Owns the synthesis behavior design -- how nefario
  produces advisory output vs execution plans, what changes (if any) to AGENT.md
  and mode handling. This determines the content of advisory reports.

- **software-docs-minion**: Owns the report template design -- how TEMPLATE.md
  accommodates advisory reports. This determines report structure and consistency.

The prior advisory analysis provides a strong foundation. These three agents
refine the prior design into implementation-ready specifications. Governance
agents (lucy, margo) are not needed for planning because: (a) the prior advisory
already established intent alignment (lucy) and YAGNI compliance (margo -- the
user explicitly decided to build this now, overriding the prior wait recommendation);
(b) they will participate in Phase 3.5 architecture review as mandatory reviewers,
which is the appropriate checkpoint for governance concerns on the execution plan.

### Scope

**In scope**:
- `--advisory` flag parsing in SKILL.md argument parsing section
- Advisory workflow branch in SKILL.md (after Phase 3, skip 3.5-8, advisory wrap-up)
- Advisory synthesis prompt/format in SKILL.md Phase 3 section
- Advisory-specific nefario AGENT.md changes (if needed, per ai-modeling-minion's assessment)
- Advisory report template (TEMPLATE.md modifications or new advisory template)
- `mode: advisory` frontmatter value
- Advisory-specific Phase 1 meta-plan prompt variant (if needed)
- Advisory-specific communication protocol (phase announcements, CONDENSE lines, status line)
- No branch creation, no commits, no PR for advisory runs

**Out of scope**:
- `MODE: PLAN + ADVISORY` combination (deferred per ai-modeling-minion's prior analysis)
- Advisory report indexing changes to `build-index.sh` (can be a follow-up)
- Automated testing of advisory mode
- Changes to any agent other than nefario

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuild from specs | Not relevant -- task does not involve agent spec changes in `the-plan.md` |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Not relevant -- advisory status line changes are specified inline in SKILL.md, not via this skill |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain
(SKILL.md/AGENT.md/TEMPLATE.md modification for advisory mode). No external
skills will be used in the execution plan.
