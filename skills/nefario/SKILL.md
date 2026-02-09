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

### Branch Creation

Before spawning any execution agents, isolate work on a feature branch.

1. Check the current branch: `git branch --show-current`
2. If on `main` or `master`, create a feature branch:
   `git checkout -b nefario/<slug>` (reuse the slug generated in Phase 1).
3. If already on a non-main branch, use it -- do not create a nested branch.
4. Initialize commit tracking state:
   - Set `commits_used = 0` and `commit_budget = <gate_count> + 1`.
   - Set `defer_all = false`.

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
   - **approve**: Present a commit checkpoint (see below), then continue
     to next batch.
   - **request changes**: Send feedback to the agent for revision.
     Cap at 2 revision rounds. After 2 rounds, ask the user for more
     detailed direction.
   - **reject**: Confirm with the user -- show which dependent tasks will
     also be dropped. Then remove from plan and continue.
   - **skip**: Defer the gate. Continue with non-blocked tasks.
     Re-present skipped gates before the wrap-up phase.

   **Commit checkpoint after gate approval**: If `defer_all` is false and
   `commits_used < commit_budget`, present a commit checkpoint for files
   changed since the last commit:

   ```
   Commit: "<type>(<scope>): <summary>"

     - path/to/changed-file-1
     - path/to/changed-file-2

   Co-Authored-By: Claude <noreply@anthropic.com>
   (Y/n)
   ```

   - **Y** (or Enter): Stage the listed files, commit, increment
     `commits_used`.
   - **n**: Leave changes uncommitted, continue.
   - **defer-all**: Set `defer_all = true`. All subsequent commit prompts
     are suppressed until wrap-up. Continue.
   - Auto-defer (skip silently) if only `.md` files changed with < 5
     lines total diff.
   - Never use `git add -A`. Only stage files modified during this session.
   - See [docs/commit-workflow.md](../docs/commit-workflow.md) for the
     full protocol (sensitive file filtering, safety rails, edge cases).

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

7. **Final commit checkpoint** — before generating the report, check for
   uncommitted changes. If any exist (and `defer_all` was not set to true
   with zero prior commits), present a commit checkpoint. If `defer_all`
   is true, present a single batch commit covering all deferred changes:

   ```
   Commit (deferred batch): "<type>: <overall summary>"

     - path/to/file-1
     - path/to/file-2
     + N more

   Co-Authored-By: Claude <noreply@anthropic.com>
   (Y/n)
   ```

8. **Verify and report** — follow the wrap-up sequence documented in the
   "Report Generation" section below (review deliverables, write report,
   update index, present to user, shutdown teammates, final status).

9. **PR creation** — after the report is committed, if on a feature branch,
   offer to create a pull request:

   ```
   Create PR: "<plan title>" (Y/n)
   ```

   If approved: `git push -u origin <branch>` then `gh pr create`.
   Auto-generate the PR body from gate summaries and the execution report.
   If `gh` is unavailable, print the manual push command instead.
   See [docs/commit-workflow.md](../docs/commit-workflow.md) for details.

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

See `nefario/reports/TEMPLATE.md` for the complete report format, including YAML frontmatter schema, body structure, file naming convention, and index update instructions.

### Incremental Writing

For long-running orchestrations, write a partial report after Phase 3
(synthesis). Include available data and mark sections as "In Progress".
Overwrite with the complete report at wrap-up.

### Wrap-up Sequence (MANDATORY)

When all tasks are complete, you MUST execute every step below. The execution
report is not optional — it is as mandatory as the synthesis phase. Do not
skip it, do not defer it, do not stop before it is written.

1. Review all deliverables
2. Present final commit checkpoint (or deferred batch) for uncommitted changes
3. **Write execution report** to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`
   — follow the template at `nefario/reports/TEMPLATE.md`
4. **Update index** at `nefario/reports/index.md`
5. Commit the report (auto-commit, no prompt needed)
6. Offer PR creation if on a feature branch
7. Present report path and key summary to user
8. Send shutdown_request to teammates
9. TeamDelete
10. Report final status to user

