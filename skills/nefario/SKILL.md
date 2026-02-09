---
name: nefario
description: >
  Orchestrate a team of specialist agents for complex, multi-domain tasks.
  Uses a five-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, then you execute.
argument-hint: "<task description>"
---

# Nefario Orchestrator

You are executing the Nefario orchestration workflow. This skill coordinates
a multi-phase planning process that leverages specialist domain expertise
before execution.

## Overview

The workflow has five phases:

1. **Meta-plan** — Nefario identifies which specialists to consult
2. **Specialist planning** — Domain experts contribute their perspective
3. **Synthesis** — Nefario consolidates into an execution plan
3.5. **Architecture Review** — Cross-cutting agents review before execution
4. **Execution** — You spawn agents and coordinate the work

## Phase 1: Meta-Plan

Spawn nefario as a planning subagent to analyze the task and determine
which specialists should be consulted for planning.

```
Task:
  subagent_type: nefario
  description: "Create meta-plan"
  model: opus
  prompt: |
    MODE: META-PLAN

    You are creating a meta-plan — a plan for who should help plan.

    ## Task
    <insert the user's task description>

    ## Working Directory
    <insert cwd>

    ## Instructions
    1. Read relevant files to understand the codebase context
    2. Analyze the task against your delegation table
    3. Identify which specialists should be CONSULTED FOR PLANNING
       (not execution — planning). These are agents whose domain
       expertise is needed to create a good plan.
    4. For each specialist, write a specific planning question that
       draws on their unique expertise.
    5. Return the meta-plan in the structured format.
```

Nefario will return a meta-plan listing which specialists to consult
and what to ask each one. Review it briefly — if it looks reasonable,
proceed to Phase 2. No need for formal user approval at this stage.

## Phase 2: Specialist Planning

For each specialist in the meta-plan, spawn them as a subagent **in parallel**.
Each specialist gets:
- The original task description
- Their specific planning question from nefario
- Relevant codebase context
- Instructions to return a domain plan contribution

```
Task:
  subagent_type: <agent-name from meta-plan>
  description: "<agent> planning input"
  model: opus  # planning = opus
  prompt: |
    You are contributing to the PLANNING phase of a multi-agent project.
    You are NOT executing yet — you are providing your domain expertise
    to help build a comprehensive plan.

    ## Project Task
    <insert the user's original task>

    ## Your Planning Question
    <insert the specific question from nefario's meta-plan>

    ## Context
    <insert any relevant codebase context from nefario's meta-plan>

    ## Instructions
    1. Read relevant files to understand the current state
    2. Apply your domain expertise to the planning question
    3. Identify risks, dependencies, and requirements from your perspective
    4. If you believe additional specialists should be involved that
       aren't already part of the planning, say so and explain why
    5. Return your contribution in this format:

    ## Domain Plan Contribution: <your-name>

    ### Recommendations
    <your expert recommendations for this aspect of the task>

    ### Proposed Tasks
    <specific tasks that should be in the execution plan>
    For each task: what to do, deliverables, dependencies

    ### Risks and Concerns
    <things that could go wrong from your domain perspective>

    ### Additional Agents Needed
    <any specialists not yet involved who should be, and why>
    (or "None" if the current team is sufficient)
```

**Important**: If any specialist recommends additional agents, spawn those
agents for planning too (a second round of Phase 2 consultations), then
include their contributions in Phase 3.

## Phase 3: Synthesis

Spawn nefario again with ALL specialist contributions to create the
final execution plan.

```
Task:
  subagent_type: nefario
  description: "Synthesize execution plan"
  model: opus
  prompt: |
    MODE: SYNTHESIS

    You are synthesizing specialist planning contributions into a
    final execution plan.

    ## Original Task
    <insert the user's task>

    ## Specialist Contributions
    <paste ALL specialist plan contributions from Phase 2>

    ## Instructions
    1. Review all specialist contributions
    2. Resolve any conflicts between recommendations
    3. Incorporate risks and concerns into the plan
    4. Create the final execution plan in structured format
    5. Ensure every task has a complete, self-contained prompt
```

Nefario will return a structured delegation plan. **Proceed to Phase 3.5
(Architecture Review)** before presenting the plan to the user.

## Phase 3.5: Architecture Review

After nefario returns the delegation plan from synthesis, run a cross-cutting
review before presenting to the user.

### Identify Reviewers

From the delegation plan, determine which cross-cutting agents should review:
- **Always** (mandatory reviewers):
  - security-minion
  - test-minion
  - ux-strategy-minion
  - software-docs-minion
- **Conditional**:
  - observability-minion: 2+ tasks produce runtime components, services, or APIs
  - ux-design-minion: 1+ tasks produce user-facing interfaces

### Spawn Reviewers

Spawn all identified reviewers in parallel on sonnet:

```
Task:
  subagent_type: <reviewer agent>
  description: "<agent> architecture review"
  model: sonnet
  prompt: |
    You are reviewing a delegation plan before execution begins.
    Your role: identify gaps, risks, or concerns from your domain.

    ## Delegation Plan
    <paste the full plan from Phase 3>

    ## Your Review Focus
    <domain-specific: security gaps / test coverage / observability gaps / etc.>

    ## Instructions
    Return exactly one verdict:
    - APPROVE: No concerns from your domain.
    - ADVISE: <list specific non-blocking warnings>
    - BLOCK: <describe the blocking issue and what must change>

    Be concise. Only flag issues within your domain expertise.
```

### Process Verdicts

- **All APPROVE or ADVISE**: Append any ADVISE notes to the relevant task
  prompts. Present the plan to the user for approval. Proceed to Phase 4.
- **Any BLOCK**: Send the BLOCK feedback back to nefario (MODE: SYNTHESIS)
  to revise the plan. Then re-submit the revised plan to the blocking
  reviewer only. Cap at 2 revision rounds. If still blocked after 2 rounds,
  present the impasse to the user for decision.

## Phase 4: Execution

After user approval, execute the plan. If the plan contains **approval gates**,
execution proceeds in batches separated by gate checkpoints.

### Setup

1. **Create a team** using TeamCreate with the team name from the plan.

2. **Create tasks** using TaskCreate for each task in the plan.
   Set dependencies via TaskUpdate.

### Execution Loop

Group tasks into batches based on dependencies and approval gates.
A batch contains all tasks that can run before the next gate.

3. **Spawn teammates** for the current batch using the Task tool:
   ```
   Task:
     subagent_type: <agent name>
     description: <short summary>
     model: <from plan — usually sonnet for execution>
     mode: <from plan>
     team_name: <team name>
     name: <agent name>
     prompt: <prompt from plan>
   ```
   Spawn independent tasks in parallel. In each agent's prompt, include
   this instruction at the end:

   > When you finish your task, mark it completed with TaskUpdate and
   > send a message to the team lead summarizing what you produced and
   > where the deliverables are. Include file paths.

4. **Actively monitor completion.** After spawning agents, DO NOT just
   wait passively. You are the orchestrator — you must drive progress:

   - After spawning, immediately call `TaskList` to show current status.
   - When you receive a message from a teammate (delivered as a new turn),
     acknowledge it, call `TaskList` to check overall progress, and decide
     what to do next (spawn next batch, present gate deliverable, etc.).
   - When a teammate goes idle, check `TaskList`. If their task is marked
     completed, proceed. If not, send them a message asking for status.
   - **When ALL tasks in the current batch are complete**, immediately
     proceed to the next step (next batch, gate checkpoint, or wrap-up).
     Do not wait for the user to tell you to continue.
   - If you're unsure whether an agent is done, call `TaskList` and check
     task status. Trust the task status over idle notifications.

5. **At approval gates**: When a gated task completes, present its
   deliverable using the structured decision brief:

   ```
   APPROVAL GATE: <Task title>
   Agent: <who produced this> | Blocked tasks: <what's waiting>

   DECISION: <one-sentence summary of the deliverable/decision>

   RATIONALE:
   - <key point 1>
   - <key point 2>
   - <rejected alternative and why>

   IMPACT: <what approving/rejecting means for the project>
   DELIVERABLE: <file path(s) to review>
   Confidence: HIGH | MEDIUM | LOW

   Reply: approve / request changes / reject / skip
   ```

   Response handling:
   - **approve**: Continue to next batch.
   - **request changes**: Send feedback to the agent for revision.
     Cap at 2 revision rounds. After 2 rounds, ask the user for more
     detailed direction.
   - **reject**: Confirm with the user -- show which dependent tasks will
     also be dropped. Then remove from plan and continue.
   - **skip**: Defer the gate. Continue with non-blocked tasks.
     Re-present skipped gates before the wrap-up phase.

   Anti-fatigue guidelines:
   - Budget 3-5 approval gates per plan. If synthesis produces more,
     consolidate related gates.
   - Include rejected alternatives in every brief -- this is the key lever
     against rubber-stamping.
   - Set confidence based on: number of viable alternatives (more = lower),
     reversibility (harder = lower), downstream dependents (more = lower).
   - Calibration check: After 5 consecutive approvals without changes, present:
     "You have approved the last 5 gates without changes. Are the gates
     well-calibrated, or should future plans gate fewer decisions?"

6. Repeat steps 3-5 for each batch until all tasks are complete.

### Wrap-up

7. **Verify and report** — after all complete, follow the wrap-up sequence
   documented in the "Report Generation" section below (review deliverables,
   write report, update index, present to user, shutdown teammates, final status).

### Troubleshooting: Orchestrator Not Progressing

If the main session seems stuck after agents complete (not reacting to
completion messages), this may be a Claude Code message delivery timing
issue, especially in TMUX mode. Workarounds:

- Tell the main session "check task status" or "agents are done" to
  nudge it forward — it will call TaskList and catch up.
- The monitoring instructions above are designed to minimize this, but
  if it persists, it's a platform limitation, not a configuration issue.

## Report Generation

After completing the orchestration, generate an execution report to document
the process, decisions, and outcomes. The calling session (main Claude Code
session executing this skill) generates the report, not nefario as a subagent.

### Data Accumulation

Track data at phase boundaries:

**After Phase 1 (Meta-plan)**:
- Timestamp
- Task description (one-line summary)
- Specialists identified
- Generate filename slug: kebab-case, lowercase, max 40 chars from task
  description. Strip articles (a/an/the). Only alphanumeric and hyphens.
  No path separators or special characters.

**After Phase 2 (Specialist Planning)**:
- Which specialists contributed
- Key recommendation from each (1 sentence)

**After Phase 3 (Synthesis)**:
- Task count
- Gate count
- Conflict resolutions (if any)

**After Phase 3.5 (Architecture Review)**:
- Reviewers consulted
- Verdicts (APPROVE/ADVISE/BLOCK)
- Revision rounds (if any)

**After Phase 4 (Execution)**:
- Per-task outcomes
- Files created or modified
- Gate decisions and responses

**At Wrap-up**:
- Outstanding items
- Approximate total duration

### Report Template

The report uses YAML frontmatter with exactly 10 fields followed by a
three-layer progressive disclosure body.

#### Frontmatter

```yaml
---
type: nefario-report
version: 1
date: "<YYYY-MM-DD>"
sequence: <N>
task: "<one-line task description>"
mode: full | plan
agents-involved: [<list>]
task-count: <N>
gate-count: <N>
outcome: completed | partial | aborted
---
```

#### Body Structure

**Layer 1 — Header Block** (max 15 lines):

A markdown table with key metrics:
- Date
- Task (one-line description)
- Duration (~Xm for approximate minutes)
- Outcome
- Agent counts (planning/review/execution)
- Gates presented/approved
- Files changed
- Outstanding items

**Layer 2 — Executive Summary + Decisions**:

2-3 sentence summary of what was done.

For each decision:
- Structured subsection with decision statement
- Rationale (2-5 key points)
- Alternatives rejected

Conflict resolutions if any (else "None").

**Layer 3 — Process Detail**:

Sections with detailed breakdowns:

- **Phases executed**: which phases ran, agents per phase (tables)
- **Files created/modified**: table with file path, action, description
- **Approval gates**: table with title, confidence, outcome, rounds
- **Outstanding items**: markdown checklist
- **Timing**: table with phase durations (use `~` prefix for approximate)

Sections with no content display "None" (never omitted).

### File Naming Convention

Reports are written to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`:

- `<YYYY-MM-DD>`: date of orchestration
- `<NNN>`: zero-padded sequence number. Determine by globbing
  `nefario/reports/<YYYY-MM-DD>-*.md` and counting. First report of
  the day is 001, second is 002, etc.
- `<slug>`: kebab-case, lowercase, max 40 chars, derived from task
  description. Strip articles (a/an/the). Only alphanumeric characters
  and hyphens. No path separators or special characters.

Create `nefario/reports/` directory if it doesn't exist.

### Index File Update

After writing the report, update `nefario/reports/index.md`.

If index.md doesn't exist, create it with:

```markdown
# Nefario Orchestration Reports

Reports from nefario orchestration runs.

| Date | Seq | Task | Outcome | Agents |
|------|-----|------|---------|--------|
```

Prepend a new row to the table with:
- Date (YYYY-MM-DD)
- Sequence (NNN)
- Task (slug as markdown link to report file: `[slug](YYYY-MM-DD-NNN-slug.md)`)
- Outcome (completed/partial/aborted)
- Agent count (total agents involved)

### Incremental Writing

For long-running orchestrations, write a partial report after Phase 3
(synthesis). Include available data and mark sections as "In Progress".
Overwrite with the complete report at wrap-up.

### Updated Wrap-up Sequence

When all tasks are complete:

1. Review all deliverables
2. Write execution report to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`
3. Update `nefario/reports/index.md`
4. Present report path and key summary to user
5. Send shutdown_request to teammates
6. TeamDelete
7. Report final status to user

