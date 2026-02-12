## Domain Plan Contribution: lucy

### Recommendations

**Verdict: The proposed gate aligns with project intent and strengthens the existing governance model.**

Here is the detailed alignment analysis:

#### 1. Requirement Echo-Back

The user wants to see which specialists nefario selected after Phase 1 (meta-plan) and approve, adjust, or veto the team before Phase 2 specialist dispatch proceeds. This is a visibility and control mechanism at the orchestration level.

#### 2. Alignment with Existing Governance Model

The gate is **consistent** with the project's governance philosophy. Evidence:

- **SKILL.md lines 20-21** already declare: "You NEVER skip any gates or approval steps based on your own judgement... only the user can override this." Adding a new gate at Phase 2 team selection is an extension of this principle, not a contradiction.
- **SKILL.md line 374** currently says: "Review it briefly -- if it looks reasonable, proceed to Phase 2. No need for formal user approval at this stage." This is the **only line that conflicts** with the proposed change. It explicitly waives user approval at the meta-plan output point. The proposed gate would replace this waiver with a formal approval step.
- The existing **Execution Plan Approval Gate** (after Phase 3.5) gives the user control over what gets executed but NOT over who does the planning. By the time the user sees the execution plan, specialist compute is already spent. The new gate closes this gap.
- **Phase 3.5 Architecture Review** is unaffected -- it operates on the synthesized plan, not the team composition. The new gate sits between Phase 1 and Phase 2; Phase 3.5 sits between Phase 3 and Phase 4. No interaction.

#### 3. Conflict Analysis: MODE: PLAN Behavior

MODE: PLAN (described in `nefario/AGENT.md` lines 35-38) bypasses specialist consultation entirely -- the user explicitly requests nefario to plan solo. The new gate would be **inapplicable** in MODE: PLAN because there is no team selection to approve. This is not a conflict; it is a natural scope boundary. The implementation should explicitly state: "This gate applies only in META-PLAN mode. In PLAN mode, no specialist team is selected."

#### 4. Conflict Analysis: "NEVER skip" Enforcement Model

The current "NEVER skip" rules (SKILL.md lines 20-21, AGENT.md lines 21-22, 552) apply to phases and gates. If this new gate is added as a mandatory gate, it inherits the same enforcement: nefario cannot skip it autonomously, only the user can override it. This is **fully consistent**. However, the gate MUST be defined as skippable by the user (consistent with "only the user can override this"), not hardcoded as unskippable.

#### 5. Should the Gate Be Mandatory or Skippable?

**Recommendation: Mandatory by default, user-skippable.**

Rationale:
- Making it mandatory is consistent with the existing pattern (Phase 3.5 is "NEVER skipped" by nefario, but user can override).
- Making it optional (nefario decides) would create an inconsistency -- nefario currently has no authority to skip gates.
- The user should be able to say "auto-approve team selection" or "skip team gate" if they find it low-value for a particular session. This is the same model as all other gates.
- Anti-fatigue concern: This adds one more approval step to every orchestration. For simple tasks where nefario selects 2-3 obvious specialists, this may feel like friction. The presentation format must be optimized for fast approval (compact, one-line-per-agent, no verbose rationale unless the user drills in). See "Proportionality" below.

#### 6. Proportionality Assessment

The problem (wasted compute on irrelevant specialists) is real and the solution (a single approval gate with a compact agent list) is proportional. This is **not** over-engineering. The gate adds:
- One `AskUserQuestion` call
- One compact presentation block
- One response handler (approve / adjust / reject)

This is minimal. The risk is anti-fatigue if the gate is verbose. Keep the presentation under 10 lines.

#### 7. Scope Containment Check

The task statement says:
- **In scope**: SKILL.md flow, Phase 2 team selection logic, approval gate UX
- **Out of scope**: Phase 3.5 review gate changes, AGENT.md files, the-plan.md, adding new agents

The proposed work should touch:
1. `skills/nefario/SKILL.md` -- Phase 1/2 transition flow, Communication Protocol (SHOW list), new gate format
2. Possibly `nefario/AGENT.md` -- if the META-PLAN working pattern needs to reference the gate (but this is close to out-of-scope AGENT.md changes)

**Flag**: The scope says "agent AGENT.md files" are out of scope. But `nefario/AGENT.md` describes the META-PLAN output format which is directly upstream of this gate. If the meta-plan output format needs adjustment to support the gate presentation, `nefario/AGENT.md` may need a minor update. The implementation team should clarify whether `nefario/AGENT.md` is truly out of scope or whether minimal changes to the meta-plan output format are permitted.

### Proposed Tasks

**Task 1: Add team selection approval gate to SKILL.md**
- **What**: Modify `skills/nefario/SKILL.md` to insert a formal approval gate between Phase 1 (Meta-Plan) and Phase 2 (Specialist Planning).
- **Deliverables**:
  - Replace the "No need for formal user approval at this stage" text (line 374) with a structured gate.
  - Add a "Team Selection Gate" section after Phase 1, before Phase 2.
  - Define the presentation format (agent list with rationale, compact).
  - Define `AskUserQuestion` with options: Approve / Adjust team / Reject.
  - Define "Adjust team" response handler: user can remove agents, add agents, or modify planning questions.
  - Add this gate to the Communication Protocol SHOW list.
  - Add the gate to the CONDENSE meta-plan line or replace it.
  - State explicitly that this gate does not apply in MODE: PLAN.
- **Dependencies**: None.

**Task 2: Verify no regression in Phase 3.5 flow**
- **What**: After Task 1, read the complete SKILL.md and verify that Phase 3.5 Architecture Review is unchanged and that the new gate does not interfere with compaction checkpoints, scratch file naming, or the existing execution plan approval gate.
- **Deliverables**: Confirmation that no downstream flow is broken.
- **Dependencies**: Task 1.

### Risks and Concerns

1. **Anti-fatigue risk (MEDIUM)**: Adding another approval step increases the "gate tax" per orchestration. The existing flow already has: execution plan approval gate, mid-execution gates (3-5), post-exec options, PR gate, and potentially impasse/security escalations. Adding a team selection gate means the user sees at minimum 3 mandatory interactions before any work starts (team gate, execution plan gate, first mid-execution gate). Mitigation: keep the team gate presentation extremely compact (under 10 lines) and make it fast to approve.

2. **Adjust team complexity (LOW)**: The "adjust team" response path needs to handle: removing an agent, adding an agent not in the meta-plan, and modifying planning questions. This is more complex than a simple approve/reject. Mitigation: keep the initial implementation simple -- user types freeform adjustments, nefario re-runs meta-plan logic for added agents only.

3. **AGENT.md scope boundary (LOW)**: If `nefario/AGENT.md` META-PLAN output format needs changes to support the gate, this brushes against the "out of scope" boundary. Mitigation: design the gate to consume the existing meta-plan output format without requiring changes. The SKILL.md calling session can extract agent names and planning questions from the current format.

4. **Second-round specialists (LOW)**: Phase 2 currently allows specialists to recommend additional agents, triggering a second round. The team selection gate approves the initial team; should the user also approve second-round additions? Recommendation: for v1, auto-include second-round recommendations without a re-gate. The execution plan approval gate (after Phase 3.5) is the backstop. Flag this for future consideration if users report surprise additions.

### Additional Agents Needed

**margo** should review the gate's complexity relative to its value. The anti-fatigue concern (adding mandatory interaction to every orchestration) is squarely in margo's YAGNI/KISS domain. If margo concludes the gate adds disproportionate friction for the visibility it provides, that should inform whether the gate defaults to mandatory or optional.

No other additional agents needed. The task is scoped to SKILL.md orchestration flow, which is nefario's domain. The implementation is text editing, not code.
