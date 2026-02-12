# Meta-Plan: Rework Phase 3.5 Reviewer Composition

## Planning Consultations

### Consultation 1: Approval Gate UX for Discretionary Reviewer Selection

- **Agent**: ux-strategy-minion
- **Planning question**: Phase 3.5 currently spawns 6 mandatory reviewers unconditionally. We are splitting this into 5 ALWAYS reviewers and 6 discretionary reviewers that nefario picks and the user approves before spawning. The Phase 2 Team Approval Gate (PR #51, now merged) established a pattern: compact presentation (8-12 lines), freeform adjust, 3 options (Approve/Adjust/Reject). Should the Phase 3.5 reviewer gate reuse that exact pattern, or does the reviewer selection context warrant a different interaction model? Consider: the user has already approved one team (Phase 2); this is a second "who participates" gate in the same session. How do we avoid approval fatigue from two team-composition gates while still giving the user meaningful control? What is the right information density for presenting discretionary picks with one-line rationale?
- **Context to provide**: `skills/nefario/SKILL.md` (Team Approval Gate section, lines 378-456), `docs/orchestration.md` (Phase 3.5 section, lines 53-84, and Team Approval Gate section, lines 342-373)
- **Why this agent**: UX strategy expertise on interaction design for sequential approval gates. The key risk is approval fatigue from two team-composition gates in one session; ux-strategy-minion can assess cognitive load and recommend the right weight for this gate.

### Consultation 2: SKILL.md Integration and Documentation Impact Checklist Design

- **Agent**: devx-minion
- **Planning question**: The task requires three coordinated changes to nefario's orchestration infrastructure: (1) modifying the Phase 3.5 "Identify Reviewers" and "Spawn Reviewers" sections in SKILL.md to implement the ALWAYS/discretionary split with a user approval gate, (2) narrowing software-docs-minion's Phase 3.5 role to produce a documentation impact checklist instead of a full review, and (3) adding a handoff mechanism so Phase 8 consumes this checklist as its work order. What is the cleanest way to structure the checklist format so it serves both as a 3.5 output (lightweight, fast) and a Phase 8 input (actionable, specific)? Where exactly in SKILL.md does the Phase 8 checklist generation logic (lines 1253-1268) need to change to reference the 3.5 checklist instead of generating from scratch? How should the discretionary reviewer gate be inserted relative to the existing compaction checkpoint (line 729)?
- **Context to provide**: `skills/nefario/SKILL.md` (Phase 3.5 section lines 601-728, Phase 8 section lines 1252-1330), `nefario/AGENT.md` (Architecture Review section lines 546-613)
- **Why this agent**: DevX expertise on workflow configuration files and developer-facing tool design. The SKILL.md is a complex workflow specification; devx-minion understands how to structure changes that maintain internal consistency across interdependent phases.

### Consultation 3: Governance Alignment for Reviewer Roster Changes

- **Agent**: lucy
- **Planning question**: We are demoting ux-strategy-minion from ALWAYS to discretionary in Phase 3.5. The cross-cutting checklist in AGENT.md (line 263) says "Usability -- Strategy: ALWAYS include." The Phase 3.5 triggering rules (AGENT.md line 563) also list ux-strategy-minion as ALWAYS. Does demoting ux-strategy-minion from ALWAYS 3.5 reviewer create a governance conflict with the cross-cutting checklist's ALWAYS-include directive? The distinction is: the cross-cutting checklist governs planning inclusion (Phase 1-3), while Phase 3.5 is a review gate. Are these separable? Also: software-docs-minion is currently ALWAYS in 3.5 but we are narrowing its role to a documentation impact checklist. The cross-cutting checklist says documentation is ALWAYS included. Does narrowing the 3.5 role while keeping the Phase 8 full review satisfy the ALWAYS-include requirement, or does it create a gap? Finally, confirm that the AGENT.md changes required are limited to the Architecture Review section (lines 546-613) and do not cascade into other sections.
- **Context to provide**: `nefario/AGENT.md` (Cross-Cutting Concerns lines 257-272, Architecture Review lines 546-613), `docs/orchestration.md` (Phase 3.5 section lines 53-84), issue scope constraints (Out: the-plan.md, reviewer agent AGENT.md files)
- **Why this agent**: Lucy is the governance agent responsible for intent alignment and convention enforcement. This change modifies a core invariant (the ALWAYS reviewer roster) and needs governance validation that the new structure still satisfies the project's review guarantees.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task produces no executable code -- it modifies markdown workflow specifications (AGENT.md, SKILL.md, orchestration.md). test-minion will still participate in Phase 3.5 architecture review of the execution plan. No planning contribution needed.
- **Security**: Exclude from planning. The changes do not alter attack surface, authentication, user input processing, or secrets handling. The discretionary reviewer gate reuses the existing AskUserQuestion pattern (no new input vectors). security-minion will participate in Phase 3.5 review.
- **Usability -- Strategy**: INCLUDED as Consultation 1. The core design challenge is approval gate UX for the discretionary reviewer selection, avoiding fatigue from two team-composition gates per session.
- **Usability -- Design**: Exclude. No user-facing interfaces are produced. The approval gate is text-based CLI interaction using existing AskUserQuestion patterns.
- **Documentation**: INCLUDED via devx-minion (Consultation 2) for SKILL.md structural changes. software-docs-minion will participate in Phase 3.5 review to validate that orchestration.md changes are consistent. user-docs-minion is not needed for planning -- using-nefario.md updates are straightforward and can be specified at synthesis time.
- **Observability**: Exclude. No runtime components are produced or modified.

## Anticipated Approval Gates

One mid-execution approval gate is anticipated:

1. **Reviewer roster and gate design** (Task 1, likely devx-minion): The SKILL.md changes define the ALWAYS/discretionary split and the approval gate format. This is hard to reverse (all future orchestrations use this) and has high blast radius (Tasks 2 and 3 depend on it). MUST gate per the classification matrix. Confidence: MEDIUM -- the roster composition is specified by the issue, but the gate interaction design involves judgment where multiple valid approaches exist.

## Rationale

Three specialists are consulted because this task has three distinct planning challenges:

1. **Interaction design** (ux-strategy-minion): The approval gate is the most design-sensitive element. Adding a second team-composition gate risks approval fatigue; the interaction model needs careful calibration.
2. **Workflow integration** (devx-minion): The SKILL.md is a 1600+ line workflow specification with interdependent phases. The checklist handoff from Phase 3.5 to Phase 8 is a new cross-phase data flow that needs clean integration.
3. **Governance validation** (lucy): Demoting agents from ALWAYS to discretionary changes a core invariant. Lucy validates that the new structure still satisfies the project's review guarantees.

Other agents are not needed for planning:
- **margo**: Will review during Phase 3.5, but the scope is tightly constrained by the issue (exact rosters specified) -- no risk of scope creep to assess during planning.
- **software-docs-minion**: Will update orchestration.md during execution, but the changes follow directly from the SKILL.md changes. No planning contribution beyond what devx-minion covers.

## Scope

**Goal**: Restructure Phase 3.5 Architecture Review to use a smaller mandatory reviewer roster (5 ALWAYS) and a discretionary pool (6 conditional reviewers) selected by nefario and approved by the user before spawning.

**In scope**:
- Phase 3.5 reviewer triggering rules (ALWAYS/discretionary roster split)
- Discretionary reviewer approval gate (presentation, response handling)
- software-docs-minion 3.5 role narrowing to documentation impact checklist
- Phase 8 handoff to consume the 3.5 checklist as work order
- nefario AGENT.md updates (Architecture Review section)
- skills/nefario/SKILL.md updates (Phase 3.5, Phase 8 sections)
- docs/orchestration.md updates (Phase 3.5 section)

**Out of scope**:
- Phase 2 approval gate (handled by #48, already merged)
- Reviewer agent AGENT.md files (agent system prompts unchanged)
- the-plan.md (source of truth, human-edited only)
- Phase 5/6 post-execution phases (unchanged)
- Changes to the ALWAYS roster beyond what the issue specifies

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent building/rebuilding | Not relevant -- task does not rebuild agents from the-plan.md specs |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Claude Code status line config | Not relevant -- task does not modify status line behavior |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain (orchestration workflow configuration).
