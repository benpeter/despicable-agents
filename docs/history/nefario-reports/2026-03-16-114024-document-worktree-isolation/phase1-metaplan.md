# Phase 1: Meta-Plan -- Document Worktree Isolation

## Meta-Plan

### Task Analysis

The task is to document an already-working capability: running parallel nefario
orchestrations in separate git worktrees. No code changes, no framework changes,
no new features. Pure documentation of existing infrastructure behavior.

The issue is well-scoped with explicit "What to document" and "What NOT to
build" sections. The target is `docs/orchestration.md` or a linked sub-doc,
plus updates to the architecture hub and user-facing guide.

### Planning Consultations

#### Consultation 1: Documentation Structure
- **Agent**: software-docs-minion
- **Planning question**: Where should worktree isolation documentation live within the existing docs structure? Options: (a) new section in `docs/orchestration.md` Section 5 area, (b) new linked sub-doc `docs/worktree-isolation.md`, (c) section in the user-facing `docs/using-nefario.md`. Consider the existing hub-and-spoke architecture in `docs/architecture.md` and the split between contributor/architecture docs and user-facing docs. What cross-references are needed?
- **Context to provide**: `docs/architecture.md` (hub structure, sub-document table), `docs/orchestration.md` (current sections), `docs/using-nefario.md` (user-facing guide)
- **Why this agent**: software-docs-minion understands documentation architecture and can recommend optimal placement that maintains consistency with the existing structure

### Cross-Cutting Checklist

- **Testing**: EXCLUDE -- no executable output. Pure documentation task.
- **Security**: EXCLUDE -- no attack surface, auth, user input, secrets, or infrastructure changes. Documenting an existing git workflow.
- **Usability -- Strategy**: INCLUDE -- even a documentation task benefits from reviewing whether the content structure serves users effectively. However, given the narrow scope (single doc section), this can be handled by software-docs-minion's planning rather than a separate consultation. EXCLUDE from planning consultation, include in execution via Phase 3.5 review.
- **Usability -- Design**: EXCLUDE -- no user-facing interfaces produced.
- **Documentation**: INCLUDE -- this IS the documentation task. software-docs-minion is the primary planner. user-docs-minion relevance: the `docs/using-nefario.md` file is user-facing, so if content is added there, user-docs-minion should review. Include user-docs-minion in execution (Phase 3.5 or Phase 8), not planning.
- **Observability**: EXCLUDE -- no runtime components.

### Anticipated Approval Gates

**Zero mid-execution gates expected.** The deliverable is additive documentation
(easy to reverse) with no downstream dependents (low blast radius). Per the
gate classification matrix, this is a NO GATE scenario.

The standard Team Approval Gate (Phase 1) and Execution Plan Approval Gate
(Phase 3.5) still apply per protocol, though the user has pre-approved all gates.

### Rationale

This is a narrow documentation task with a single domain (technical writing /
doc architecture). Only software-docs-minion brings planning value -- the
question of WHERE to place the content and how to cross-reference it within the
existing doc structure is the only non-obvious planning decision.

All other agents either cover irrelevant domains (security, testing, frontend,
infrastructure) or cover concerns that are handled by Phase 3.5 mandatory
reviewers (lucy for intent alignment, margo for simplicity, ux-strategy-minion
for journey coherence). No specialist beyond software-docs-minion needs to
contribute to the PLAN -- cross-cutting reviewers participate at review time,
not planning time.

### Scope

**In scope:**
- Add documentation section covering worktree-based parallel nefario orchestration
- Content: how it works, when to use it, merge-back workflow, limitations
- Update cross-references in architecture hub and/or user-facing guide as needed

**Out of scope:**
- Framework-level worktree orchestration features
- Cross-session coordination mechanisms
- Changes to nefario AGENT.md or SKILL.md
- Changes to any agent behavior

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent build/rebuild | Not relevant -- no agents are being built |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- no status line changes |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the documentation task.
