# Meta-Plan: Improve Context and Clarity at Nefario Gates and Approval Prompts

## Planning Consultations

### Consultation 1: Gate Information Architecture Audit

- **Agent**: ux-strategy-minion
- **Planning question**: Audit every gate type in the nefario orchestration (execution plan approval gate, mid-execution decision briefs, Phase 5 escalation briefs, Phase 6 test failure escalations, compaction checkpoints, PR creation prompt, calibration check) and for each one, identify: (a) what information a user needs to make an informed decision, (b) what information is currently specified in the gate format, and (c) the gap. Consider cognitive load -- the user should not be overwhelmed, but should not have to open files to understand what they are approving. Pay special attention to the "DELIVERABLE" field in mid-execution gates, which currently shows a single file path but may need to surface a snippet or summary of what the deliverable contains.
- **Context to provide**: `skills/nefario/SKILL.md` (full file -- contains all gate format specifications), `nefario/AGENT.md` (the Decision Brief Format and Approval Gates sections), `docs/orchestration.md` (Section 3: Approval Gates). Also note the issue success criteria: "User can understand what they are approving/rejecting without opening additional files."
- **Why this agent**: UX strategy specializes in cognitive load reduction and information architecture at decision points. The core problem is "what context do users need at each gate?" -- a user journey question, not a formatting one.

### Consultation 2: CLI Gate Presentation Patterns

- **Agent**: devx-minion
- **Planning question**: Given the current gate format specifications in SKILL.md, how should contextual information be presented in a terminal/CLI environment to maximize scannability and decision quality? Consider: (a) how to inline relevant context (artifact summaries, key changes) without exceeding terminal readability limits, (b) whether scratch file paths should be absolute or include a "quick peek" mechanism, (c) how to handle varying amounts of context (simple single-file changes vs. complex multi-file deliverables), (d) terminal line budget -- the current execution plan approval gate targets 25-40 lines; is this adequate when context is added? Propose specific formatting patterns for surfacing context inline.
- **Context to provide**: `skills/nefario/SKILL.md` (Execution Plan Approval Gate section, Phase 4 approval gate section, Phase 5 escalation briefs, Communication Protocol section), the existing CONDENSE and SHOW/NEVER SHOW rules.
- **Why this agent**: DevX specializes in CLI design, developer onboarding, and error message design. Gate prompts are a CLI interaction pattern; the devx-minion can recommend concrete formatting approaches that work in terminal environments.

### Consultation 3: Documentation Consistency

- **Agent**: software-docs-minion
- **Planning question**: The gate format specifications currently live in three files that must stay consistent: `skills/nefario/SKILL.md` (operational specification), `nefario/AGENT.md` (agent system prompt -- Decision Brief Format section), and `docs/orchestration.md` (architecture documentation -- Section 3: Approval Gates). If we change gate output formatting, which files need updating and in what order? Are there other files that reference gate formats? What is the minimum set of changes to keep documentation consistent?
- **Context to provide**: `skills/nefario/SKILL.md`, `nefario/AGENT.md`, `docs/orchestration.md`. Note that AGENT.md has `x-fine-tuned: true` and uses an overlay mechanism (AGENT.generated.md + AGENT.overrides.md), so changes there have a specific update process.
- **Why this agent**: Software-docs-minion understands the documentation architecture of this project and can identify all locations that need synchronized updates when a format specification changes.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. The task changes prompt/output formatting in markdown specification files. No executable code is produced; there is nothing to test beyond manual verification that gate formats are coherent. test-minion will still participate in Phase 3.5 architecture review.
- **Security**: Exclude from planning. The task does not change gate logic, does not introduce new input surfaces, and does not affect authentication or data handling. The existing scratch file sanitization and secret scanning are not modified. security-minion will still participate in Phase 3.5 architecture review.
- **Usability -- Strategy**: INCLUDED as Consultation 1 above. This is the primary domain for the task -- every gate is a user decision point, and the issue is fundamentally about information sufficiency at those points.
- **Usability -- Design**: Exclude from planning. There are no GUI/web interfaces involved. Gates are text-based CLI output. The devx-minion (Consultation 2) covers CLI presentation patterns, which is the relevant design dimension here.
- **Documentation**: INCLUDED as Consultation 3 above. Changes to gate format specifications must propagate consistently across SKILL.md, AGENT.md, and docs/orchestration.md.
- **Observability**: Exclude from planning. No runtime components, services, or APIs are created or modified by this task.

## Anticipated Approval Gates

**None anticipated.** The task is scoped to output formatting changes in specification files (SKILL.md, AGENT.md, docs/orchestration.md). All changes are:
- Easy to reverse (markdown specification text)
- Low blast radius (format changes do not affect gate logic or phase structure)
- No judgment calls where multiple valid architectural approaches compete

The execution plan approval gate (Phase 3.5 -> Phase 4 boundary) will still be presented as part of the standard nefario workflow, but no mid-execution gates should be needed within the plan itself.

## Rationale

Three specialists are consulted because the task sits at the intersection of three domains:

1. **ux-strategy-minion**: Determines WHAT information to surface (content audit, gap analysis). This is the core question -- what context does a user need to approve/reject each gate type?
2. **devx-minion**: Determines HOW to present that information in a CLI (formatting, progressive disclosure, terminal constraints). Without this, we might specify information that is awkward to display.
3. **software-docs-minion**: Determines WHERE to make changes consistently (file mapping, update order, overlay awareness). Without this, we risk spec drift between SKILL.md, AGENT.md, and docs/.

The task explicitly excludes gate logic changes, phase structure changes, and specialist agent behavior changes. No protocol, infrastructure, intelligence, or web quality agents are relevant.

## Scope

**In scope**:
- Gate output formatting across all gate types (execution plan approval, mid-execution decision briefs, Phase 5 code review escalation, Phase 6 test failure escalation, compaction checkpoints, PR creation prompt, calibration check)
- Approval prompt content -- what information is shown alongside each decision point
- Question presentation in nefario orchestration
- Updating the format specifications in SKILL.md, AGENT.md, and docs/orchestration.md

**Out of scope**:
- Gate logic changes (APPROVE/ADVISE/BLOCK verdicts, gate classification matrix, anti-fatigue rules)
- Adding or removing gates
- Changes to the phase structure
- Changes to specialist agent behavior
- AGENT.generated.md / AGENT.overrides.md rebuild (the overlay mechanism is not affected; AGENT.md can be edited directly as it is marked x-fine-tuned)
