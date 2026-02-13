## Meta-Plan

### Planning Consultations

#### Consultation 1: Workflow Simplification and SKILL.md Structure
- **Agent**: devx-minion
- **Model**: opus
- **Planning question**: The Team Approval Gate in `skills/nefario/SKILL.md` (lines 524-604) currently has two adjustment paths: minor (1-2 changes, lightweight inline question generation) and substantial (3+ changes, full Phase 1 re-run). We want to collapse these into a single path: any roster change always triggers a full Phase 1 re-run. What is the cleanest way to restructure the "Adjust team" response handling (steps 3-4b) into a single flow? Specifically: (a) how should the adjustment classification definition (lines 524-532) be rewritten to remove the threshold while preserving the 0-change no-op, (b) what happens to the re-run cap rule on line 544-546 now that every change triggers a re-run, and (c) how should the CONDENSE line on line 191 be updated given there is no longer a "substantial" qualifier?
- **Context to provide**: `skills/nefario/SKILL.md` lines 460-608 (full Team Approval Gate section), lines 185-192 (CONDENSE line references), `docs/orchestration.md` lines 382-390 (adjustment description in orchestration docs)
- **Why this agent**: devx-minion specializes in CLI design, developer workflows, and configuration file structure. The SKILL.md is a configuration/workflow specification, and the restructuring is fundamentally about simplifying a developer-facing workflow definition.

#### Consultation 2: Gate Interaction Coherence
- **Agent**: ux-strategy-minion
- **Model**: opus
- **Planning question**: The Team Approval Gate currently provides different processing depth based on change magnitude (minor vs. substantial). Collapsing to always-re-run changes the user's mental model: every adjustment now has the same processing cost (a full Phase 1 re-run). Does this create any cognitive load or expectation mismatch for users who make a small change (e.g., adding 1 agent) and then wait for a full re-run? Should the gate's delta summary message ("Refreshed for team change (+N, -M). Planning questions regenerated.") be adjusted to set expectations? Also: the re-run cap (line 544-546) currently says "if a second substantial adjustment occurs, use lightweight path" -- with always-re-run, the cap still applies (1 re-run per gate) but the fallback behavior needs a new definition since there is no lightweight path. What should happen on a second adjustment after the re-run cap is hit?
- **Context to provide**: `skills/nefario/SKILL.md` lines 460-608 (Team Approval Gate), the user-facing presentation format (lines 472-498), the adjustment flow
- **Why this agent**: ux-strategy-minion evaluates user journey coherence and cognitive load. The change affects how users perceive the cost of adjustments and what happens at cap boundaries.

#### Consultation 3: Intent Alignment and Scope Containment
- **Agent**: lucy
- **Model**: opus
- **Planning question**: This change removes the minor/substantial classification from the Team Approval Gate adjustment handling. The issue explicitly scopes out the Phase 3.5 Reviewer Approval Gate, which has its own parallel minor/substantial classification (lines 1009-1043). After this change, SKILL.md will have an inconsistency: the Team Approval Gate always re-runs, but the Reviewer Approval Gate still uses minor/substantial paths. Is this inconsistency acceptable given the explicit scope boundary? Are there any references in AGENT.md or the-plan.md to the minor/substantial distinction that would need updating? (My search found none, but governance review should confirm.) Finally, verify that the "1 re-run cap per gate" and "2 adjustment round cap" constraints remain coherent after removing the classification.
- **Context to provide**: `skills/nefario/SKILL.md` lines 524-604 (Team gate adjustment), lines 1009-1043 (Reviewer gate adjustment for comparison), `nefario/AGENT.md` (confirmed no references), `the-plan.md` (confirmed no references), `docs/orchestration.md` lines 382-390
- **Why this agent**: lucy enforces repo conventions, intent alignment, and consistency. The scope boundary creates a deliberate asymmetry between two parallel gate mechanisms -- governance should validate this is intentional and acceptable.

### Cross-Cutting Checklist
- **Testing**: Exclude from planning. This task modifies a SKILL.md specification file (Markdown), not executable code. There are no tests to run or write. Phase 6 (test execution) will be a no-op.
- **Security**: Exclude from planning. No authentication, authorization, user input handling, or attack surface changes. The re-run prompt construction already includes secret sanitization (line 572), which is preserved unchanged.
- **Usability -- Strategy**: INCLUDED as Consultation 2 (ux-strategy-minion). Planning question addresses cognitive load of always-re-run and cap boundary behavior.
- **Usability -- Design**: Exclude from planning. No user-facing UI components are produced. The gate presentation format (AskUserQuestion structure) is unchanged.
- **Documentation**: Include in execution (not planning). `docs/orchestration.md` line 385 describes the minor/substantial distinction and must be updated to reflect the simplified always-re-run behavior. This is a straightforward doc update that does not need specialist planning input -- the executing agent can handle it directly.
- **Observability**: Exclude from planning. No runtime components, logging, or metrics are affected.

### Anticipated Approval Gates

None anticipated. This is a single-file change (SKILL.md) with a documentation sync (orchestration.md). Both changes are additive simplifications (removing code paths, not adding them), easy to reverse, and have no downstream execution dependents. Per the gate classification matrix: low blast radius + easy to reverse = NO GATE.

### Rationale

Three specialists are consulted because this change touches three distinct concerns:

1. **devx-minion** provides the structural expertise for cleanly rewriting the SKILL.md workflow specification. The core deliverable is a restructured adjustment handling section, and devx-minion's workflow design expertise ensures the new single-path flow is clear and unambiguous.

2. **ux-strategy-minion** evaluates whether always-re-run creates user-facing friction or expectation mismatches, particularly at the re-run cap boundary where a fallback behavior must be defined.

3. **lucy** validates that the deliberate asymmetry (Team gate simplified, Reviewer gate unchanged) is acceptable and that no cross-file references are missed.

Agents not included in planning:
- **margo** is not consulted for planning because this change IS a simplification (removing a code path). Margo's YAGNI/KISS value is already embedded in the task goal. Margo will still review the plan at Phase 3.5 (mandatory).
- **software-docs-minion** is not consulted for planning because the `docs/orchestration.md` update is a mechanical sync with the SKILL.md change, not a documentation design decision.
- **ai-modeling-minion** is not relevant -- no LLM prompt design or multi-agent architecture decisions.

### Scope

**In scope**:
- Remove minor/substantial adjustment classification from `skills/nefario/SKILL.md` Team Approval Gate section (lines 524-604)
- Replace with always-re-run behavior for any roster change (preserving 0-change no-op)
- Update re-run cap rule (line 544-546) for the new single-path behavior
- Update CONDENSE line reference (line 191) to remove "substantial" qualifier
- Update `docs/orchestration.md` line 385 to reflect simplified behavior
- Preserve: 1 re-run cap per gate, 2 adjustment round cap, 0-change no-op handling

**Out of scope**:
- Phase 1 meta-plan logic itself (how META-PLAN mode works)
- Phase 3.5 Reviewer Approval Gate adjustment handling (lines 1009-1043) -- deliberately left with its own minor/substantial classification
- Other approval gates (Execution Plan, etc.)
- Any AGENT.md or the-plan.md changes (confirmed no references to the distinction)

### External Skill Integration

#### Discovered Skills
| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding from specs | Not relevant -- no AGENT.md changes needed |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Not relevant -- no status line changes |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Task briefing generation | Not relevant -- no briefing format changes |
| nefario | skills/nefario/ | ORCHESTRATION | Orchestration workflow | This IS the file being modified; not used as a skill in execution |

#### Precedence Decisions
No precedence conflicts. The nefario skill is the target of modification, not a tool to be invoked during execution.
