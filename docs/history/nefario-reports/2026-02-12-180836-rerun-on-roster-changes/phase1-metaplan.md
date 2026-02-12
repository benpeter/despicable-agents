# Meta-Plan: Re-run on Roster Changes

## Planning Consultations

### Consultation 1: Gate Interaction Design for Re-run Paths

- **Agent**: devx-minion
- **Planning question**: The "Adjust team" flow in SKILL.md (lines 428-445) currently generates planning questions for added agents via "lightweight inference from task context, not a full re-plan." The "Adjust reviewers" flow (lines 693-697) similarly constrains adjustments to the 6-member discretionary pool. The issue asks that substantial changes (3+ agents) trigger a re-run of the original phase (meta-plan re-run for Team gate, reviewer re-identification for Reviewer gate), while minor changes (1-2 agents) keep the fast lightweight path. How should the SKILL.md "Adjust team" and "Adjust reviewers" response handling sections be restructured to: (a) classify adjustments as minor vs. substantial, (b) default to the appropriate path for each, (c) let the user override the default (e.g., force lightweight for a large change or force re-run for a small one), and (d) ensure the re-run output feeds back into the same gate without introducing new approval gates? Consider the 2-round adjustment cap interaction -- does a re-run count as an adjustment round?
- **Context to provide**: `skills/nefario/SKILL.md` lines 379-457 (Team Approval Gate) and lines 608-703 (Reviewer Approval Gate). Also `nefario/AGENT.md` lines 1-50 (MODE: META-PLAN invocation). The existing flow structure: user selects "Adjust team" -> freeform input -> nefario interprets -> generates questions -> re-presents gate.
- **Why this agent**: devx-minion specializes in CLI and skill interaction design, decision tree workflows, and developer-facing configuration. The gate adjustment flow is fundamentally a decision tree that needs careful design to remain intuitive while adding the re-run path.

### Consultation 2: Approval Gate Journey Coherence

- **Agent**: ux-strategy-minion
- **Planning question**: The current approval gates (Team and Reviewer) have a clean 3-option flow: Approve / Adjust / Reject (or Skip). Adding a re-run path to the "Adjust" flow introduces a secondary decision point: after the user says what to change, they may be offered "lightweight adjustment" vs. "re-run the planning phase." How should this be presented to minimize cognitive load while preserving the user's ability to control the process? Specifically: (1) Should the minor/substantial threshold be communicated to the user, or should it be invisible with just a recommendation? (2) When the re-run produces a new meta-plan, the gate re-presents with potentially different specialists -- is the user's mental model of "I'm adjusting my team" preserved, or does it feel like starting over? (3) The issue says "no additional approval gates introduced" -- does the re-run result naturally fit into the existing gate, or does the gate need to be reshaped? Consider the anti-fatigue rules and gate budget.
- **Context to provide**: `skills/nefario/SKILL.md` lines 379-457 (Team Approval Gate), lines 643-703 (Reviewer Approval Gate), and the Communication Protocol section (lines 134-172) for CONDENSE/SHOW rules. The user interaction pattern: gate -> adjust -> freeform input -> (new: classify change size) -> (new: recommend lightweight or re-run) -> re-present gate.
- **Why this agent**: UX strategy evaluates the user journey holistically. Adding decision points to an approval gate risks cognitive overload, especially since the user is already in a multi-gate orchestration flow. ux-strategy-minion will assess whether the re-run path can be added without disrupting the existing flow's simplicity.

### Consultation 3: Multi-Agent Re-run Coordination

- **Agent**: ai-modeling-minion
- **Planning question**: When a substantial team change triggers a meta-plan re-run, nefario is spawned again in META-PLAN mode. This re-run needs to be context-aware: it should know what the original meta-plan contained, what the user changed, and why. Similarly, at the Reviewer Approval Gate, substantial reviewer changes require re-running the reviewer identification logic within nefario's synthesis context. Design the re-run prompts: (1) For the Team gate re-run: should the re-spawned nefario receive the original meta-plan as context, or start fresh? What information from the user's adjustment request should be included? How do we ensure the re-run produces output at the same depth as the original? (2) For the Reviewer gate re-run: this is not a nefario subagent spawn -- it is the calling session re-evaluating discretionary reviewers. What context does it need to produce plan-grounded rationales for the new reviewer set? (3) Cost implications: a meta-plan re-run spawns nefario on opus. Is this justified for the value it provides over lightweight question generation?
- **Context to provide**: `skills/nefario/SKILL.md` Phase 1 (lines 291-375, nefario spawn with META-PLAN prompt), Phase 3.5 reviewer identification (lines 608-640). `nefario/AGENT.md` META-PLAN mode behavior. The distinction between "lightweight inference" (current approach: calling session generates questions from task context) vs. "full re-plan" (spawning nefario in META-PLAN mode with the updated team composition as a constraint).
- **Why this agent**: ai-modeling-minion specializes in multi-agent architecture, prompt engineering for subagent coordination, and cost optimization. The re-run involves designing prompts that carry forward context while producing fresh analysis -- a prompt engineering challenge. The cost-benefit tradeoff of opus re-runs is also squarely in this agent's domain.

### Consultation 4: Intent Alignment for Gate Modification

- **Agent**: lucy
- **Planning question**: The existing gate flows in SKILL.md are recent additions (Team Approval Gate added in the last few sessions, Reviewer Approval Gate added in the PR currently on main). Modifying them introduces risk of intent drift -- the gates exist to give the user control, and the re-run path must preserve that intent without introducing new failure modes. Review: (1) Does adding a "substantial change -> re-run" path align with the documented gate purpose in `docs/orchestration.md`? (2) The issue says "no additional approval gates introduced" -- does the proposed flow satisfy this constraint? (3) Are there CLAUDE.md or repo conventions that constrain how the SKILL.md adjustment flows should be structured? (4) Does the 3+ agent threshold for "substantial" align with the existing design philosophy (e.g., the cross-cutting checklist has 6 mandatory dimensions -- would removing/adding 3 agents from a 4-agent team be different from 3 agents on an 8-agent team)?
- **Context to provide**: `skills/nefario/SKILL.md` Team Approval Gate and Reviewer Approval Gate sections. `docs/orchestration.md` gate documentation. `CLAUDE.md` engineering philosophy (YAGNI, KISS). The issue's success criteria, particularly "no additional approval gates."
- **Why this agent**: lucy enforces intent alignment and repo convention compliance. Gate modification is a governance-sensitive change -- the gates are control points designed to preserve human agency. lucy will verify that the re-run mechanism doesn't dilute that control.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task modifies skill specification text (SKILL.md and potentially AGENT.md). No executable code, no test infrastructure. Testing coverage is limited to manual verification that the described flows are coherent and implementable.
- **Security**: Exclude from planning. No new attack surface, authentication, user input handling, or secrets management. The re-run prompts will follow existing sanitization patterns already in SKILL.md.
- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning question covers cognitive load, mental model preservation, and journey coherence for the modified gate flows.
- **Usability -- Design**: Exclude from planning. No UI components, visual layouts, or interaction patterns beyond text-based CLI gates. The "design" here is interaction flow, covered by ux-strategy-minion.
- **Documentation**: Include for execution (not planning consultation). software-docs-minion will participate in Phase 3.5 architecture review (mandatory) and Phase 8 if documentation updates are needed. The orchestration docs (`docs/orchestration.md`) will need updating to reflect the re-run paths. user-docs-minion may need to update `docs/using-nefario.md`. These are execution concerns, not planning questions.
- **Observability**: Exclude from planning. No runtime components, no production services.

## Anticipated Approval Gates

Given the scope (modifying two sections of SKILL.md, potentially updating AGENT.md), I anticipate **1 approval gate**:

1. **SKILL.md gate flow design** (MUST gate): The restructured "Adjust team" and "Adjust reviewers" response handling sections. This is hard to reverse (changes the orchestration protocol) and has high blast radius (all future nefario orchestrations use these gates). Multiple valid design approaches exist (threshold-based vs. heuristic, user-visible vs. invisible classification, re-run-counts-as-adjustment-round vs. separate budget). User should review the concrete flow before it is written.

## Rationale

Four specialists are selected because this task spans four distinct domains that each contribute materially to planning quality:

- **devx-minion**: The primary domain. Gate adjustment flows are developer-facing interaction patterns. devx-minion will propose the concrete structure of the modified SKILL.md sections.
- **ux-strategy-minion**: The gates are user journey checkpoints. Adding complexity to a gate requires journey coherence analysis to prevent cognitive overload in an already multi-gate process.
- **ai-modeling-minion**: Explicitly requested by the user. The meta-plan re-run is a multi-agent prompt engineering challenge -- designing re-run prompts that carry context forward while producing fresh, deep analysis. Cost implications of additional opus spawns also need evaluation.
- **lucy**: Governance review of gate modifications. The gates are the user's primary control points; modifying them requires intent alignment verification. Lucy also checks for convention compliance.

**Not included for planning** (will participate in Phase 3.5 mandatory review):
- margo: Will review the execution plan for over-engineering. Not needed for planning because the scope is well-defined.
- security-minion: Mandatory Phase 3.5 reviewer. No security-specific planning question.
- test-minion: Mandatory Phase 3.5 reviewer. No testable code output.
- software-docs-minion: Mandatory Phase 3.5 reviewer. Documentation impact assessment deferred to review.

## Scope

**In scope**:
- Team Approval Gate "Adjust team" response handling in `skills/nefario/SKILL.md` (lines 428-445)
- Reviewer Approval Gate "Adjust reviewers" response handling in `skills/nefario/SKILL.md` (lines 693-697)
- `nefario/AGENT.md` meta-plan mode if the re-run requires changes to how nefario processes META-PLAN invocations (e.g., accepting an "original meta-plan" context parameter)
- Minor/substantial change classification logic
- Re-run prompt design (what context to include when re-spawning nefario for meta-plan re-run)

**Out of scope**:
- Phase 2/3 specialist planning and synthesis logic
- Phase 5 code review workflow
- Other approval gates (Execution Plan Approval Gate, mid-execution gates)
- Nefario core orchestration flow beyond the two affected gates
- Adding new phases or new approval gates

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent rebuild/check | Not relevant to this task. No inclusion needed. |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant to this task. No inclusion needed. |

### Precedence Decisions

No conflicts between external skills and built-in specialists. Neither discovered skill overlaps with the task domain.
