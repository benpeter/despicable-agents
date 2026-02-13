# Meta-Plan: Remove software-docs-minion from Phase 3.5

## Summary

Remove software-docs-minion from the mandatory Phase 3.5 Architecture Review
roster and simplify Phase 8 documentation to derive its checklist solely from
the synthesis plan and execution outcomes. This eliminates one agent call per
orchestration and removes the divergence-flagging complexity from Phase 8.

Four artifacts need coordinated edits: the-plan.md, nefario AGENT.md,
skills/nefario/SKILL.md, and docs/orchestration.md.

## Planning Consultations

### Consultation 1: Documentation workflow impact assessment

- **Agent**: software-docs-minion
- **Planning question**: You currently produce a documentation impact checklist
  during Phase 3.5 that feeds into Phase 8. We plan to remove you from Phase 3.5
  entirely and have Phase 8 self-derive its checklist from the synthesis plan
  (task list, deliverables, file paths) plus execution outcomes (files changed,
  gates approved). What information do you currently capture in the Phase 3.5
  checklist that would be difficult to reconstruct from those two sources alone?
  Are there documentation needs you routinely identify at plan-review time that
  execution outcomes would miss?
- **Context to provide**: Current Phase 3.5 software-docs-minion prompt
  (SKILL.md lines 910-970), Phase 8 merge logic (SKILL.md lines 1581-1666),
  outcome-action table from the-plan.md (lines 251-264)
- **Why this agent**: software-docs-minion is the agent being removed from
  Phase 3.5. It has direct experience with what value the pre-execution checklist
  provides and what would be lost.

### Consultation 2: Phase 8 self-derivation design

- **Agent**: lucy
- **Planning question**: Phase 8 currently merges two sources: the Phase 3.5
  docs checklist (pre-execution) and execution outcomes (post-execution). We want
  Phase 8 to derive its checklist from a single source: the synthesis plan
  (available before execution) plus execution outcomes (available after). The
  synthesis plan already contains task prompts with deliverables, file paths,
  and agent assignments. How should Phase 8 construct its checklist to maintain
  the same coverage? Specifically: (1) should the outcome-action table remain
  the primary driver with synthesis plan as supplementary context, or should
  the synthesis plan tasks be scanned first? (2) should owner tags and priority
  be assigned by the orchestrator or by the doc agents themselves?
- **Context to provide**: Phase 8 current logic (SKILL.md lines 1581-1666),
  outcome-action table (the-plan.md lines 251-264), synthesis plan format
  (AGENT.md synthesis output template)
- **Why this agent**: lucy validates intent alignment. The Phase 8 checklist
  derivation change must not lose documentation coverage that the user
  implicitly expects. lucy can assess whether the single-source approach
  maintains the same effective coverage.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task modifies documentation and
  configuration files (YAML frontmatter, markdown prose, orchestration logic).
  No executable code is produced. Phase 6 will still run if tests exist in the
  project, but test-minion has no planning contribution here.
- **Security**: Exclude from planning. No attack surface, authentication,
  user input, secrets, or infrastructure changes. The change removes an agent
  call, which reduces compute but introduces no security risk.
- **Usability -- Strategy**: Exclude from planning. This is an internal
  orchestration optimization. No user-facing workflow, journey, or cognitive
  load changes. The user experience of nefario orchestration is unchanged
  (Phase 3.5 still runs with 5 mandatory reviewers; Phase 8 still produces
  documentation).
- **Usability -- Design**: Exclude. No user-facing interfaces produced.
- **Documentation**: ALWAYS include. software-docs-minion is consulted above
  (Consultation 1) specifically for the documentation workflow impact. The
  documentation cross-cutting concern is directly addressed by this task --
  the task itself is about documentation workflow. software-docs-minion
  will also participate in Phase 8 post-execution if documentation artifacts
  change.
- **Observability**: Exclude. No runtime components, services, or logging changes.

## Anticipated Approval Gates

1. **the-plan.md changes** (MUST gate): The task constraint explicitly requires
   user approval of the-plan.md diff before committing. This is hard to reverse
   (canonical spec, source of truth for all agents) and has high blast radius
   (all four artifacts derive from it). Confidence: HIGH -- the changes are
   narrowly scoped and well-defined by the issue.

No other gates anticipated. The remaining artifact changes (AGENT.md, SKILL.md,
docs/orchestration.md) are mechanical derivations from the-plan.md changes and
are easy to reverse.

## Rationale

This task is a focused refactoring of orchestration documentation and
configuration. Only two specialists are needed for planning:

- **software-docs-minion**: Directly affected agent. Uniquely positioned to
  identify information loss from removing its Phase 3.5 role.
- **lucy**: Intent alignment reviewer. Ensures the Phase 8 simplification
  maintains the same effective documentation coverage the user expects.

Other specialists are excluded because:
- No code is written (no test-minion, security-minion, code-review-minion)
- No user-facing interfaces (no ux-design-minion, accessibility-minion)
- No runtime components (no observability-minion, sitespeed-minion)
- No user-facing workflow changes (no ux-strategy-minion)
- margo's simplicity review will occur during Phase 3.5 (mandatory) but
  does not need to contribute to planning -- the task IS a simplification

## Scope

**In scope**:
- Phase 3.5 mandatory reviewer list (remove software-docs-minion): the-plan.md,
  AGENT.md, SKILL.md, docs/orchestration.md
- software-docs-minion custom Phase 3.5 prompt: SKILL.md
- Phase 8 checklist derivation logic (single-source): the-plan.md, SKILL.md
- Scratch directory structure (remove phase3.5-docs-checklist.md): SKILL.md
- Reviewer Approval Gate presentation (mandatory count 6->5): SKILL.md
- Architecture Review Agents synthesis template (mandatory count 6->5): AGENT.md
- software-docs-minion exception paragraph: AGENT.md, docs/orchestration.md

**Out of scope**:
- Phase 8 sub-steps (8a, 8b) and agent spawning logic (unchanged)
- user-docs-minion discretionary role in Phase 3.5 (unchanged)
- Phase 1 cross-cutting checklist Documentation item (unchanged -- ALWAYS include)
- software-docs-minion's own agent definition (minions/software-docs-minion/AGENT.md)
- Delegation table references to software-docs-minion (unchanged)
- Phase 5 code review (unchanged)
- Any other Phase 3.5 mechanics (BLOCK resolution, discretionary pool, etc.)

## External Skill Integration

No external skills detected in project. The two project-local skills
(despicable-lab, despicable-statusline) are unrelated to this task.
User-global skills (nefario, despicable-prompter) are symlinks from this
project and not external.
