# Meta-Plan: Add User Approval Gate for Phase 2 Team Selection

## Planning Consultations

### Consultation 1: UX Strategy for the Approval Gate Interaction

- **Agent**: ux-strategy-minion
- **Planning question**: The user currently sees a single CONDENSE line after Phase 1 ("Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <path>"). We want to insert an approval gate between Phase 1 and Phase 2 where the user can approve, remove, or add specialists before dispatch. How should this gate be structured to give the user meaningful control without creating friction? Consider: (1) what information the user needs to make a good decision (agent name, planning question, rationale), (2) progressive disclosure -- how much to show by default vs. on request, (3) interaction patterns for add/remove/approve (structured prompt vs. freeform), (4) how to handle the "I just want to approve and move on" case without creating approval fatigue, and (5) how this gate relates to the existing execution plan approval gate (Phase 3.5) in the user's mental model of the process.
- **Context to provide**: `skills/nefario/SKILL.md` (especially the Communication Protocol section, the CONDENSE patterns, Phase 1 flow, and the Execution Plan Approval Gate format), `docs/orchestration.md` (Phase 1 and Phase 2 descriptions, Approval Gates section, Anti-Fatigue Rules)
- **Why this agent**: This is fundamentally a UX question -- designing an interaction that gives control without overhead. ux-strategy-minion can evaluate cognitive load, information hierarchy, and the overall journey coherence of having two approval gates (team selection + execution plan) in the workflow.

### Consultation 2: Orchestration Workflow Integration

- **Agent**: devx-minion
- **Planning question**: The nefario SKILL.md currently says "Review it briefly -- if it looks reasonable, proceed to Phase 2. No need for formal user approval at this stage." and the CONDENSE line compresses the meta-plan to one line. We need to change the Phase 1 -> Phase 2 transition to include an approval gate. Consider: (1) where exactly in SKILL.md this gate should be inserted (after the nefario meta-plan subagent returns, before specialist spawning), (2) what data from the meta-plan output needs to be extracted and presented (agent names, planning questions, cross-cutting checklist evaluation, rationale), (3) how to handle the response options (approve as-is, remove agents, add agents -- what does "add agents" look like when the user picks from 27 possible agents?), (4) what happens to the CONDENSE line (does it move after the gate? does it stay as-is and the gate is a separate output?), (5) how to handle the "add agent" case -- does nefario need to generate a planning question for the newly added agent, or can the user provide one? (6) impact on the scratch file convention (does the gate response get written anywhere?), and (7) how does docs/orchestration.md need to be updated to reflect this change?
- **Context to provide**: `skills/nefario/SKILL.md` (full file, especially Phase 1, Phase 2, Communication Protocol, and Scratch Directory Structure), `docs/orchestration.md`, the meta-plan output format from nefario's AGENT.md (the structured format with Planning Consultations, Cross-Cutting Checklist, etc.)
- **Why this agent**: devx-minion specializes in developer-facing workflow design, configuration files, and the user experience of CLI tools. The SKILL.md is effectively a configuration/workflow definition that drives a developer-facing CLI experience. devx-minion can evaluate the integration points, flag consistency issues, and recommend patterns that fit the existing file structure.

### Consultation 3: Governance Alignment Check

- **Agent**: lucy
- **Planning question**: We are adding a user approval gate between Phase 1 (meta-plan) and Phase 2 (specialist dispatch). This changes the user's control surface over the orchestration process. Review: (1) does this change align with the project's stated intent of keeping the user in control of orchestration decisions? (2) does it conflict with any existing CLAUDE.md instructions (especially "ALWAYS follow the full workflow" and the core rules about not skipping gates)? (3) the existing Phase 3.5 architecture review is "NEVER skipped" -- should this new gate have the same enforcement level, or is it acceptable for it to be skippable? (4) how does this interact with the MODE: PLAN alternative (where the user explicitly requests a simplified process -- should that mode skip this new gate)? (5) are there any repo convention concerns with modifying SKILL.md and orchestration.md together?
- **Context to provide**: `CLAUDE.md`, `skills/nefario/SKILL.md` (Core Rules section, Phase 1, Phase 2), `docs/orchestration.md` (Phase 1, Phase 2, Approval Gates section), `nefario/AGENT.md` (Core Rules, Invocation Modes -- MODE: PLAN)
- **Why this agent**: lucy is the governance reviewer responsible for intent alignment and repo convention enforcement. Adding a new gate is a governance-relevant change -- it alters the user's control surface and the process enforcement model. lucy can flag if the proposed gate conflicts with existing conventions or if its enforcement level needs careful thought.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task modifies documentation/skill files (SKILL.md, orchestration.md), not executable code. No tests exist for SKILL.md content, and the output is prose/workflow instructions. Test coverage would be validated at execution time if any test-related files were changed.
- **Security**: Exclude from planning. The approval gate does not create new attack surface, handle authentication, process untrusted input, or manage secrets. The existing secret sanitization in SKILL.md (which applies to scratch file writes) is unchanged.
- **Usability -- Strategy**: INCLUDED as Consultation 1 (ux-strategy-minion). Planning question: How should the team selection approval gate be structured to give meaningful control without friction?
- **Usability -- Design**: Exclude from planning. This task does not produce user-facing UI. The "interface" is text-based CLI output following existing patterns (CONDENSE lines, AskUserQuestion prompts). ux-strategy-minion covers the interaction design at the strategic level; no visual/component design is needed.
- **Documentation**: INCLUDED implicitly in Consultation 2 (devx-minion covers docs/orchestration.md updates). software-docs-minion is not needed for planning because the documentation scope is clear and bounded (update the existing orchestration.md to reflect the new gate). Phase 8 post-execution will handle the actual documentation update.
- **Observability**: Exclude from planning. No runtime components, services, or APIs are created or modified. The changes are to orchestration workflow instructions.

## Anticipated Approval Gates

**Zero mid-execution gates expected.** The task scope is two files (SKILL.md and orchestration.md) with a clear, bounded change. The deliverables are additive text edits to existing files. Both files are easy to reverse (text edits, version controlled). This task has low blast radius (no downstream tasks depend on the output format of these specific files in a build pipeline sense).

The plan approval gate (execution plan gate after Phase 3.5) will be the sole user checkpoint, which is appropriate for this scope.

## Rationale

Three planning consultants were selected:

1. **ux-strategy-minion** (mandatory cross-cutting + primary domain relevance): The task is fundamentally about designing an approval gate UX. The success criteria explicitly mention "approval gate UX" as in-scope. This agent's cognitive load and journey coherence expertise is directly relevant to designing a gate that adds value without creating fatigue.

2. **devx-minion** (workflow integration expertise): The primary deliverable is a modification to SKILL.md -- a workflow definition file that drives a CLI developer experience. devx-minion's expertise in CLI design, configuration files, and developer onboarding maps directly to understanding how the gate integrates into the existing multi-phase flow. This agent will identify technical integration points, consistency requirements, and documentation impacts.

3. **lucy** (governance -- mandatory for process changes): Adding a gate changes the user's control surface over the orchestration process. This is a governance-relevant change that needs intent alignment review. Lucy can catch conflicts with existing rules (e.g., MODE: PLAN behavior, the "NEVER skip" enforcement model for Phase 3.5) before they become execution-time surprises.

**Agents considered but excluded from planning:**

- **margo** (simplicity governance): While margo is relevant for YAGNI/KISS enforcement, the task scope is explicitly defined by the issue and unlikely to suffer scope creep. Margo will review at Phase 3.5 as a mandatory architecture reviewer. Planning input is not needed because the simplicity question ("is one gate too many? too little?") is better answered by ux-strategy-minion who can reason about it from a user journey perspective.
- **software-docs-minion**: The documentation change is straightforward (update orchestration.md to reflect new gate). devx-minion can cover this as part of the integration analysis. No separate planning consultation needed.
- **ai-modeling-minion**: No LLM prompt design, cost optimization, or multi-agent architecture changes. The gate is a workflow mechanism, not an AI pattern change.

## Scope

**In scope:**
- Nefario SKILL.md: Phase 1 -> Phase 2 transition flow, Communication Protocol (CONDENSE line), approval gate insertion
- docs/orchestration.md: Phase 1 and Phase 2 descriptions, Approval Gates section
- Approval gate interaction design (structured prompt options, response handling)

**Out of scope (per issue):**
- Phase 3.5 architecture review gate (must continue to work unchanged)
- Agent AGENT.md files (no changes to any agent's system prompt)
- the-plan.md (no changes to the canonical spec)
- Adding new agents to the roster
- nefario/AGENT.md (the nefario agent file itself -- the gate is in SKILL.md, not the agent prompt)

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | ORCHESTRATION | Agent rebuild/check | Not relevant to this task. No inclusion. |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Not relevant to this task. No inclusion. |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain (approval gate design, orchestration workflow modification).
