## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Insertion Point: Between Phase 1 Return and Phase 2 Dispatch

The gate inserts immediately after the Phase 1 meta-plan returns and before Phase 2 specialist spawning begins. In `skills/nefario/SKILL.md`, this means:

- **After** line 374 (the closing of the Phase 1 section: "No need for formal user approval at this stage.")
- **Before** line 377 (the start of Phase 2: "For each specialist in the meta-plan, spawn them as a subagent **in parallel**.")

The current text at line 374 reads:
> "Nefario will return a meta-plan listing which specialists to consult and what to ask each one. Review it briefly -- if it looks reasonable, proceed to Phase 2. No need for formal user approval at this stage."

This sentence must be replaced with the new team approval gate logic. The "no need for formal user approval" phrasing is explicitly removed; it becomes the opposite.

#### 2. Data Extracted from Meta-Plan Output

The meta-plan already produces structured output that nefario returns. The gate needs to extract and present:

- **Selected specialists**: Agent names from the meta-plan's specialist list (these are the agents selected for Phase 2 planning consultation, not Phase 3.5 reviewers or Phase 4 execution agents)
- **Planning question per specialist**: The specific question nefario wrote for each specialist -- this is the rationale. Users need to see WHY each specialist was selected, not just WHO.
- **Scope boundaries**: The in/out scope from the meta-plan, so users can judge whether the team matches the scope
- **External skills discovered**: Count and names (already captured in the CONDENSE line)

The meta-plan does NOT need to be restructured. All this data is already in its output. The gate formats it for user review.

#### 3. CONDENSE Line Update

The current CONDENSE line (SKILL.md line 158):
```
"Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <path>"
```

This line still prints. It fires when the meta-plan returns, BEFORE the gate. The gate then pauses for user input. The CONDENSE line is output that confirms the meta-plan completed and what it found. The gate is the subsequent user interaction.

The flow becomes:
1. Meta-plan returns
2. CONDENSE line prints (informational, confirms what meta-plan found)
3. Team Approval Gate presents (user interaction)
4. User approves/modifies
5. Phase 2 begins

No change to the CONDENSE line content is needed. Its role shifts from "here's what we'll do" to "here's what we found, confirming before proceeding."

#### 4. Gate Presentation Format

Follow the existing approval gate design language (progressive disclosure, AskUserQuestion). The gate should be compact since the user has not yet invested time in the plan -- this is an early checkpoint, not a detailed review.

Proposed format:

```
TEAM: <1-sentence task summary>
REQUEST: "<truncated original prompt, max 80 chars>..."
Specialists: N | Skills: N discovered
Scratch: $SCRATCH_DIR/{slug}/

SPECIALISTS:
  1. devx-minion          — <planning question summary, max 60 chars>
  2. security-minion       — <planning question summary, max 60 chars>
  3. frontend-minion       — <planning question summary, max 60 chars>

SCOPE:
  In: <scope from meta-plan>
  Out: <scope from meta-plan>
```

Line budget: 10-20 lines. Much shorter than the execution plan gate (25-40 lines) because there is less to review.

#### 5. Response Options via AskUserQuestion

Present using AskUserQuestion:
- `header`: "Team"
- `question`: "<1-sentence task summary>"
- `options` (4, `multiSelect: false`):
  1. label: "Approve", description: "Consult these specialists for planning." (recommended)
  2. label: "Modify team", description: "Add or remove specialists before consulting."
  3. label: "Skip planning", description: "Skip specialist consultation. Nefario plans directly."
  4. label: "Abandon", description: "Cancel this orchestration."

The "Modify team" option is the interesting one. When selected:

**Modification Flow**:
1. Present the user with a freeform prompt: "Which specialists to add or remove? You can name agents directly or describe what expertise is needed."
2. The user types something like "remove seo-minion, add debugger-minion" or "add someone who knows databases" or "drop the frontend one"
3. Nefario interprets the request against the 27-agent roster (4 leads + 23 minions). For fuzzy requests ("someone who knows databases"), nefario maps to the correct agent (data-minion).
4. For added agents, nefario generates a planning question (it knows the task and the agent's domain -- this is a lightweight inference, not a full re-plan).
5. Present the updated team list and loop back to the same AskUserQuestion gate.

This avoids a complex multi-select UI. Natural language modification is more flexible than a 27-item checkbox list and more aligned with how users think ("I need a database expert" vs. scrolling through agent names).

**DO NOT use a multi-select UI for 27 agents.** This is terrible UX. The user cannot meaningfully evaluate 27 options they did not select. Instead, show what WAS selected (typically 3-6 agents) and let the user modify by exception. The meta-plan already did the hard work of selection.

The "Skip planning" option supports the edge case where the user knows what they want and does not want to wait for specialist consultation. This maps to MODE: PLAN behavior (nefario plans directly without Phase 2). This is a power-user escape hatch, not the recommended path.

#### 6. Documentation Updates for docs/orchestration.md

The following sections need updates:

**Section 1, Phase 2 description** (lines 26-36): Add a paragraph before "The main session spawns each specialist" explaining the team approval gate. State that team composition is confirmed by the user before specialist dispatch.

**Mermaid sequence diagram** (lines 163-281): Add an interaction between `Main` and `User` after Phase 1 and before Phase 2:
```mermaid
    Note over Main,User: Team Approval Gate
    Main->>User: Team composition + planning questions
    User->>Main: Approve / Modify / Skip / Abandon
```

**Section 3, Approval Gates** (lines 333-453): Add a new subsection for the Team Approval Gate. It sits between the intro paragraph and the "Execution Plan Approval Gate" subsection. Describe:
- When it occurs (after Phase 1, before Phase 2)
- What it presents (specialist list with planning questions)
- Response options (4 options as above)
- How modification works (natural language, looping)
- How it differs from the execution plan gate (team composition vs. full plan)

**using-nefario.md** (line 103): The Phase 1 description currently says "No action needed from you -- this is informational." This must change to describe the team approval interaction. The Phase 2 description should note that specialists were already confirmed.

#### 7. Impact on Phase 2's "Second Round" Logic

SKILL.md lines 441-443:
> "If any specialist recommends additional agents, spawn those agents for planning too (a second round of Phase 2 consultations)"

This still works unchanged. The team approval gate confirms the INITIAL team. If specialists in Phase 2 recommend additional agents, those agents are spawned without a second gate. Rationale: the user already approved the task scope and initial team; specialist-recommended additions are refinements within that scope, not scope changes.

If we gated second-round additions too, it would create approval fatigue for a low-value checkpoint (specialists recommending specialists is a natural part of planning, not a high-risk decision point).

### Proposed Tasks

**Task 1: Modify SKILL.md -- Add Team Approval Gate Section**
- What: Replace the "no need for formal user approval" text with a new "Team Approval Gate" subsection between Phase 1 and Phase 2. Define the presentation format, AskUserQuestion structure, modification flow, and all four response paths.
- Deliverables: Updated `skills/nefario/SKILL.md`
- Dependencies: None

**Task 2: Update SKILL.md -- Adjust CONDENSE and Communication Protocol**
- What: In the Communication Protocol "SHOW" section, add "Team approval gate (specialist list, planning questions, scope)" to the list of things shown to the user. In the "CONDENSE" section, add a note that the CONDENSE line fires before the gate, not after.
- Deliverables: Updated `skills/nefario/SKILL.md` (same file as Task 1, must be sequenced)
- Dependencies: Task 1

**Task 3: Update docs/orchestration.md**
- What: Add Team Approval Gate subsection to Section 3, update Phase 2 description in Section 1, update the Mermaid diagram to include the user interaction between Phase 1 and Phase 2.
- Deliverables: Updated `docs/orchestration.md`
- Dependencies: Task 1 (need the SKILL.md spec to document against)

**Task 4: Update docs/using-nefario.md**
- What: Revise Phase 1 user-facing description from "No action needed" to describe the team confirmation step. Revise Phase 2 description accordingly.
- Deliverables: Updated `docs/using-nefario.md`
- Dependencies: Task 1

### Risks and Concerns

**Risk 1: Approval fatigue from adding another gate.** The flow already has the execution plan approval gate (after Phase 3.5) and mid-execution gates (Phase 4). Adding a team approval gate creates a third interaction before any work starts. Mitigation: keep the gate lightweight (10-20 lines, one-click approve), and make "Approve" the recommended default. The gate is fast to dismiss when the team looks right, but catches expensive mistakes (wrong specialists = wasted compute on irrelevant planning).

**Risk 2: "Modify team" could become a rabbit hole.** Users adding and removing agents in multiple rounds before even starting planning. Mitigation: cap modification rounds at 2 (same pattern as BLOCK resolution). After 2 modifications, proceed with whatever the team is. This prevents analysis paralysis.

**Risk 3: Inconsistency in gate design language.** The team gate has a different shape than the execution plan gate (shorter, different data, different options). This is intentional -- they serve different purposes -- but the visual structure (header/question/options pattern) should be identical. Use the same AskUserQuestion conventions to maintain consistency.

**Risk 4: "Skip planning" escape hatch complexity.** When the user selects "Skip planning," the flow needs to jump from Phase 1 directly to Phase 3 with nefario doing synthesis alone (MODE: PLAN behavior). This path must be tested to ensure it does not break the Phase 3 prompt which expects specialist contributions. If no contributions exist, the synthesis prompt must handle that gracefully.

**Risk 5: Context window cost.** The gate presentation adds ~15-20 lines to the conversation. This is negligible relative to the full orchestration context, but worth noting since every line matters in long sessions. The CONDENSE line already exists and is not duplicated, so the net new context is just the gate format plus the user's response.

### Additional Agents Needed

None. This is a SKILL.md orchestration flow change and documentation update. The existing team (devx-minion for UX of the gate, software-docs-minion for documentation updates) is sufficient. No agent AGENT.md files change. No new agents are introduced.

Lucy and margo should review the final plan (which they will in Phase 3.5) to ensure the gate does not overcomplicate the flow or violate KISS. But they are already mandatory reviewers, so no additional agents are needed.
