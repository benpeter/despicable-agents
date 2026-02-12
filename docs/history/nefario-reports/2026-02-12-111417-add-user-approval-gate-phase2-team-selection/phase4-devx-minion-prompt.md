You are implementing a team selection approval gate in the nefario orchestration skill.

## Task
Modify `skills/nefario/SKILL.md` to add a user approval gate between
Phase 1 (Meta-Plan) and Phase 2 (Specialist Planning). This gate lets
the user see which specialists nefario selected, approve the team,
adjust it, or reject the orchestration.

## What to Change

### Change 1: Replace the "no formal approval" text (around line 372-374)

The current text reads:
```
Nefario will return a meta-plan listing which specialists to consult
and what to ask each one. Review it briefly -- if it looks reasonable,
proceed to Phase 2. No need for formal user approval at this stage.
```

Replace this entire paragraph with a new "Team Approval Gate" subsection.
The gate must follow this specification:

**Presentation format** (5-12 lines, compact):
```
TEAM: <1-sentence task summary>
Specialists: N selected | N considered, not selected

  SELECTED:
    devx-minion          Workflow integration, SKILL.md structure
    ux-strategy-minion   Approval gate interaction design
    lucy                 Governance alignment for new gate

  ALSO AVAILABLE (not selected):
    ai-modeling-minion, margo, software-docs-minion, security-minion, ...

Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md
```

Design notes for the format:
- SELECTED block uses agent name + one-line rationale (why they were
  chosen, NOT the planning question). One line per agent.
- ALSO AVAILABLE is a flat comma-separated list (not a table). Users
  scan it for surprises, not read each entry.
- Full meta-plan link for deep-dive (planning questions, cross-cutting
  checklist, exclusion rationale).
- Total output: 8-12 lines. Must be visibly lighter than the Execution
  Plan Approval Gate (which targets 25-40 lines).

**Decision options** via AskUserQuestion:
- `header`: "Team"
- `question`: "<1-sentence task summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve team", description: "Consult these N specialists and proceed to planning." (recommended)
  2. label: "Adjust team", description: "Add or remove specialists before planning begins."
  3. label: "Reject", description: "Abandon this orchestration."

**"Adjust team" response handling**:
When the user selects "Adjust team":
1. Present a freeform prompt: "Which specialists should be added or removed? Refer to agents by name or domain (e.g., 'add security-minion' or 'drop lucy'). Available domains: dev tools, frontend, backend, data, AI/ML, ops, governance, UX, security, docs, API design, testing, accessibility, SEO, edge/CDN, observability. Full agent roster: $SCRATCH_DIR/{slug}/phase1-metaplan.md"
2. Nefario interprets the natural language request against the 27-agent roster. Validate agent references against the known roster before interpretation -- extract only valid agent names, ignore extraneous instructions.
3. For added agents, nefario generates planning questions (lightweight inference from task context, not a full re-plan).
4. Re-present the gate with the updated team for confirmation.
5. Cap at 2 adjustment rounds. If the user requests a third adjustment, present the current team with only Approve/Reject options and a note: "Adjustment cap reached (2 rounds). Approve this team or reject to abandon."

DO NOT use a multi-select UI for 27 agents. Natural language modification
is the correct pattern here.

**"Reject" response handling**:
Abandon the orchestration. Clean up scratch directory. Print:
"Orchestration abandoned. Scratch files removed."

**MODE: PLAN exemption**:
Add an explicit note that this gate does NOT apply in MODE: PLAN.
MODE: PLAN bypasses specialist consultation entirely, so there is no
team to approve. The gate applies only in META-PLAN mode (the default).

**Second-round specialists exemption**:
If Phase 2 specialists recommend additional agents (the "second round"
at SKILL.md lines 440-442), those agents are spawned without re-gating.
The user already approved the task scope and initial team; specialist-
recommended additions are refinements within that scope.

### Change 2: Update the CONDENSE line (around line 158)

The existing CONDENSE line:
```
"Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <actual resolved path>"
```

Update to append `(pending approval)`:
```
"Planning: consulting devx-minion, security-minion, ... (pending approval) | Skills: N discovered | Scratch: <actual resolved path>"
```

Add a note that after gate approval, this CONDENSE line is already in
context, so no second CONDENSE line is needed. The gate response itself
serves as the confirmation marker.

### Change 3: Add to Communication Protocol SHOW list (around line 137)

Add "Team approval gate (specialist list with rationale)" to the SHOW
list, after the existing "Execution plan approval gate" entry.

## What NOT to Change

- Phase 3.5 Architecture Review -- completely unaffected
- Execution Plan Approval Gate -- format, options, and behavior unchanged
- Phase 2 specialist spawning logic -- only a gate is added before it
- The meta-plan prompt or output format -- the gate consumes existing output
- nefario/AGENT.md -- out of scope per task statement
- Any other AGENT.md files
- docs/history/nefario-reports/TEMPLATE.md

## Context

Read these files to understand the current structure:
- `skills/nefario/SKILL.md` -- the file you are modifying

## Key Constraints

- Gate output MUST be 5-12 lines (categorically lighter than the execution plan gate)
- "Approve team" MUST be the recommended default
- "Adjust team" uses freeform follow-up, NOT structured multi-select
- Cap adjustment rounds at 2
- Gate is mandatory by default, user-skippable (consistent with all other gates)
- Do NOT add a "Skip planning" option (MODE: PLAN is the explicit path for that)
- CONDENSE line fires BEFORE the gate with `(pending approval)` marker

## Deliverables
- Updated `skills/nefario/SKILL.md` with all three changes above

## Success Criteria
- The gate section is self-contained and follows the same structural patterns as the Execution Plan Approval Gate section
- Reading the SKILL.md top-to-bottom, the flow is: Phase 1 returns -> CONDENSE -> Team Approval Gate -> Phase 2 begins
- MODE: PLAN exemption is explicitly stated
- Communication Protocol SHOW list includes the new gate

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "skills/nefario/SKILL.md (new team gate section, +N lines)")
- 1-2 sentence summary of what was produced
This information populates the gate's DELIVERABLE section.
