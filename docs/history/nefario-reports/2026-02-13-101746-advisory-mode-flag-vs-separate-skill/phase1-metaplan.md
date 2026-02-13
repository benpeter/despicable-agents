# Meta-Plan: Advisory Mode -- Flag vs. Separate Skill

## Task Summary

Should nefario support an advisory-only mode (team evaluates a question and produces a consensus report with no code changes), and if so: should this be a flag on `/nefario` or a separate skill?

## Scope

**In scope**: Whether to add advisory-only orchestration to the nefario workflow, and the architectural question of where it lives (nefario flag vs. separate skill). Design of the advisory output format. How advisory mode interacts with existing phases (which phases apply, which are skipped). Governance implications (should advisory plans get Phase 3.5 review?).

**Out of scope**: Implementation. This is an advisory orchestration -- the team will evaluate and produce a recommendation report, not code.

## Context

The project already has a de facto advisory pattern: the `sdk-evaluation-proposal.local.md` file was produced by consulting specialists (gru, lucy, ai-modeling-minion, ux-strategy-minion) and synthesizing their recommendations into a decision document. This was done ad-hoc without formal orchestration support. The question is whether to formalize this pattern.

Key codebase context:
- Nefario currently has 3 modes: META-PLAN, SYNTHESIS, PLAN
- The nine-phase process assumes code execution (Phases 4-8)
- Decision 13 restricts MODE: PLAN to user-explicit-only
- The project follows strict YAGNI/KISS principles (Helix Manifesto)
- External skill integration (Decision 28) provides a precedent for extending capabilities
- SKILL.md is ~1200 lines and growing; complexity is a real concern

## Planning Consultations

### Consultation 1: DevX Perspective on CLI/Skill Interface Design

- **Agent**: devx-minion
- **Planning question**: From a developer experience perspective, should advisory-only orchestration be a flag on the existing `/nefario` command (e.g., `/nefario --advisory <question>`) or a separate skill (e.g., `/nefario-advisory <question>`)? Consider: discoverability, cognitive load of the `/nefario` interface, the principle of least surprise, how users currently invoke nefario (free text or `#<issue>`), whether a flag changes the mental model of what `/nefario` does, and the precedent of `/despicable-prompter` as a separate skill for a distinct workflow. What is the cleanest interface for the user?

- **Context to provide**: Current invocation patterns from `docs/using-nefario.md`, argument parsing from SKILL.md (lines 25-100), the existing modes (META-PLAN, SYNTHESIS, PLAN), and the `/despicable-prompter` skill as a precedent for separating distinct workflows.

- **Why this agent**: devx-minion owns CLI design, developer onboarding, and interface ergonomics. The core question is about command-line interface design and user mental models.

### Consultation 2: Orchestration Architecture Impact

- **Agent**: ai-modeling-minion
- **Planning question**: If advisory mode is added to nefario, which phases of the nine-phase process apply and which are skipped? Specifically: (1) Does advisory mode need Phase 3.5 architecture review, given there is no execution plan to review? (2) What replaces Phase 4 execution -- is the "execution" just writing a report, or do specialists produce deliverables that get synthesized? (3) Do post-execution phases (5-8) apply at all? (4) How does the advisory workflow differ from the current META-PLAN -> consultation -> SYNTHESIS pipeline -- is advisory mode essentially "stop after Phase 3 and format the synthesis as a report instead of an execution plan"? Evaluate whether a new MODE: ADVISORY in nefario's AGENT.md is architecturally cleaner than modifying the existing phases.

- **Context to provide**: The nine-phase architecture from `docs/orchestration.md`, the `sdk-evaluation-proposal.local.md` as an example of advisory output, nefario's current three modes from AGENT.md.

- **Why this agent**: ai-modeling-minion handles multi-agent architecture design. The question is fundamentally about whether the advisory workflow is a mode of the existing orchestration or a structurally different process.

### Consultation 3: Simplicity and Scope Creep Assessment

- **Agent**: margo
- **Planning question**: The nefario SKILL.md is already ~1200 lines. Adding advisory mode (whether as a flag or mode) would add more conditional branching to the orchestration flow. Is formalizing advisory mode justified by current usage, or is this YAGNI -- building infrastructure for an ad-hoc pattern that has worked once? Consider: (1) How many times has the advisory pattern actually been used? (2) Could the same outcome be achieved by simply running `/nefario` with a task description that says "evaluate X and produce a report, do not make changes"? (3) What is the simplicity cost of adding another mode/flag to nefario vs. the simplicity cost of a separate skill? Apply the one-agent rule from Decision 27: do not build infrastructure until the pattern is proven.

- **Context to provide**: Decision 27 (overlay removal, one-agent rule), Decision 13 (MODE: PLAN restriction), SKILL.md size and complexity, the `sdk-evaluation-proposal.local.md` as the sole example of advisory use, Helix Manifesto principles.

- **Why this agent**: margo is the YAGNI/KISS/simplicity guardian. This question needs a hard look at whether formalization is premature optimization.

### Consultation 4: Intent Alignment and Convention Coherence

- **Agent**: lucy
- **Planning question**: If advisory mode produces reports (like `sdk-evaluation-proposal.local.md`), how does this fit with the existing report infrastructure (Decision 14, execution reports, `docs/history/nefario-reports/`)? Should advisory reports use the same directory and index, or a different location? Does adding advisory mode change what `/nefario` fundamentally IS (a task orchestrator) into something broader (a team coordination tool)? Does this align with or drift from the project's stated identity: "specialist agent team for Claude Code"? Also: should advisory reports be committed (like execution reports) or treated as local artifacts (like `.local.md` files)?

- **Context to provide**: Report infrastructure from `docs/orchestration.md` Section 4, the current CLAUDE.md project description, the `sdk-evaluation-proposal.local.md` naming convention, Decision 14 (report generation).

- **Why this agent**: lucy handles intent alignment, repo convention enforcement, and goal drift detection. The question is whether advisory mode aligns with or drifts from the project's identity.

### Cross-Cutting Checklist

- **Testing**: Not included for planning. This is a design evaluation with no executable output. If the decision is to build something, testing would be included in the implementation plan.
- **Security**: Not included for planning. Advisory mode does not create attack surface, handle auth, or process user input beyond what nefario already handles. No new security concerns specific to advisory mode.
- **Usability -- Strategy**: Included via devx-minion (Consultation 1). The core question IS a usability/DX question -- how users discover and invoke advisory mode. devx-minion covers this from the CLI design angle. ux-strategy-minion would add journey coherence review, but the "journey" here is a nefario invocation pattern, which devx-minion is better positioned to evaluate.
- **Usability -- Design**: Not included for planning. No user-facing interface changes beyond CLI invocation syntax.
- **Documentation**: Not included for planning. This is a design decision, not an implementation. If the decision is to build, documentation would be included in the implementation plan. software-docs-minion would document the decision itself, but the decision log format (Decision N in `docs/decisions.md`) is well-established and does not need planning input.
- **Observability**: Not included for planning. Advisory mode does not create runtime components.

### Anticipated Approval Gates

None. This is an advisory-only orchestration. The output is a recommendation report, not an execution plan. There are no code changes, no irreversible decisions, and no downstream dependencies to gate.

### Rationale

Four specialists were selected to cover the key dimensions of this design question:

1. **devx-minion** covers the interface design question (flag vs. skill, discoverability, mental model)
2. **ai-modeling-minion** covers the architectural question (which phases apply, MODE: ADVISORY vs. separate workflow)
3. **margo** provides the YAGNI/KISS challenge (is this even needed, or is it premature)
4. **lucy** provides the intent alignment check (does advisory mode fit the project identity, convention coherence)

Agents NOT included and why:
- **software-docs-minion**: Would normally be ALWAYS included, but this is a pure design evaluation where the output is a decision recommendation, not documentation artifacts. The documentation impact (updating docs/decisions.md, docs/orchestration.md, docs/using-nefario.md) would be assessed in an implementation plan if the team recommends building it.
- **ux-strategy-minion**: The usability dimension is covered by devx-minion, whose CLI design expertise is more relevant than journey coherence for this question.
- **gru**: Not a technology decision (adopt/hold/wait). This is an internal architectural question about nefario's interface.
- **test-minion**: No executable output to test.
- **security-minion**: No attack surface changes.

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent build pipeline | Not relevant to this task |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant to this task |

#### Precedence Decisions

No conflicts. Neither discovered skill overlaps with the advisory-mode design question.
