---
name: nefario
description: >
  Orchestrate a team of specialist agents for complex, multi-domain tasks.
  Uses a nine-phase process: nefario creates a meta-plan, specialists
  contribute domain expertise, nefario synthesizes, cross-cutting agents
  review the plan, you execute, then post-execution phases verify code
  quality, run tests, optionally deploy, and update documentation.
argument-hint: "<task description>"
---

# Nefario Orchestrator

You are executing the Nefario orchestration workflow. This skill coordinates
a multi-phase planning process that leverages specialist domain expertise
before execution.

## Core Rules

You ALWAYS follow the full workflow described above. You NEVER skip any phase based on your own judgement, EVEN if it appears to be only a single-file or simple thing, EVEN if it violates YAGNI or KISS. There are NO exceptions to this, only the user can override this.
You NEVER skip any gates or approval steps based on your own judgement, EVEN if it appears to be only a single-file or simple thing, EVEN if it violates YAGNI or KISS. There are NO exceptions to this, only the user can override this.

## Overview

The workflow has nine phases:

1. **Meta-plan** — Nefario identifies which specialists to consult
2. **Specialist planning** — Domain experts contribute their perspective
3. **Synthesis** — Nefario consolidates into an execution plan
3.5. **Architecture Review** — Cross-cutting agents review before execution
4. **Execution** — You spawn agents and coordinate the work
5. **Code Review** — Parallel review of agent-produced code (conditional: code produced)
6. **Test Execution** — Run and validate tests (conditional: tests exist)
7. **Deployment** — Run deployment commands (conditional: user-requested)
8. **Documentation** — Generate/update project documentation (conditional: checklist has items)

## Communication Protocol

The orchestrator MUST minimize chat output. The user should only see:

**SHOW** (these are the only things printed to chat):
- Execution plan approval gate (task list, advisories, risks, review summary)
- Approval gate decision briefs (full structured format)
- PR creation prompt
- Final summary (report path, PR URL, branch name)
- Warnings and errors
- Compaction checkpoints (at phase boundaries)
- Unresolvable BLOCK escalation from post-execution phases (after 2-round cap)
- Security-severity BLOCK escalation (before auto-fix, max 5 lines)

**NEVER SHOW** (suppress entirely):
- Phase transition announcements ("Starting Phase 2...")
- Echoing prompts being sent to subagents
- Agent spawning narration ("Spawning security-minion...")
- Task status polling output
- Agent completion acknowledgments
- Review verdicts (unless BLOCK)
- Post-execution phase transitions ("Starting code review...", "Running tests...")
- Post-execution reviewer spawning and auto-fix iterations

**CONDENSE** to a single line:
- Meta-plan result: "Planning: consulting devx-minion, security-minion, ... | Scratch: <actual resolved path>"
  The scratch path must be the ACTUAL resolved path (e.g., `/tmp/nefario-scratch-a3F9xK/my-slug/`),
  not a template with variables.
- Review verdicts (if no BLOCK): "Review: 4 APPROVE, 0 BLOCK"
- ADVISE notes: fold into relevant task prompts. Show at execution plan
  approval gate using advisory delta format. Do not print during mid-execution.
- Post-execution start: "Verifying: code review, tests, documentation..."
- Post-execution result: fold into wrap-up ("Verification: all checks passed." or "Verification: code review passed, tests passed. Skipped: docs." or "Verification: skipped (--skip-post).")

Heartbeat: for phases lasting more than 60 seconds with no output, print a
single status line (e.g., "Waiting for 3 agents...") to confirm progress.

## Path Resolution

At Phase 1 start, resolve all session paths. These paths are used throughout
the orchestration and must be included in every CONDENSE checkpoint.

### Scratch Directory (secure creation, mandatory)

Create with:
```sh
SCRATCH_DIR=$(mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX") && chmod 700 "$SCRATCH_DIR"
```

The `XXXXXX` suffix is randomized by mktemp, preventing symlink attacks and
directory enumeration. `chmod 700` restricts access to the owning user only.

Create a subdirectory for the slug:
```sh
mkdir "$SCRATCH_DIR/${slug}"
```

All scratch file writes within the session use `$SCRATCH_DIR/${slug}/` as the
base path. The `{slug}` reuses the report slug generated in Phase 1 (kebab-case,
lowercase, max 40 chars, strip articles, alphanumeric and hyphens only).

### Report Directory (cwd-relative detection)

Detection order (first match wins):
1. `docs/nefario-reports/` relative to cwd (if exists)
2. `docs/history/nefario-reports/` relative to cwd (if exists)
3. Default: create `docs/history/nefario-reports/` relative to cwd

Create with `mkdir -p` on first use. When the report directory is first CREATED
(not detected), include a single-line note in the wrap-up output:
"Created report directory: <path>"

### Git Operations

Before branch creation, commits, or PR:
```sh
git rev-parse --is-inside-work-tree 2>/dev/null
```

If no git repo: skip branch creation, commits, PR creation. Print:
"No git repo detected. Run `git init` if you want automatic branching and commits."

For default branch detection (replaces hardcoded `main`):
```sh
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```
Fall back to `main` if the command fails (e.g., no remote configured).

### Scratch Directory Structure

```
$SCRATCH_DIR/{slug}/
  prompt.md
  phase1-metaplan.md
  phase2-{agent-name}.md        # one per specialist
  phase3-synthesis.md
  phase3.5-{reviewer-name}.md   # one per reviewer (BLOCK/ADVISE only)
  phase5-code-review-minion.md  # BLOCK/ADVISE only
  phase5-lucy.md                # BLOCK/ADVISE only
  phase5-margo.md               # BLOCK/ADVISE only
  phase6-test-results.md
  phase7-deployment.md          # if Phase 7 ran
  phase8-checklist.md           # generated by nefario
  phase8-software-docs.md       # if Phase 8 ran
  phase8-user-docs.md           # if Phase 8 ran
  phase8-marketing-review.md    # if sub-step 8b ran
```

### Inline Summary Template

After writing a specialist's full output to a scratch file, record a compact
summary in the session context:

```
## Summary: {agent-name}
Phase: {planning | review}
Recommendation: {1-2 sentences}
Tasks: {N} -- {one-line each, semicolons}
Risks: {critical only, 1-2 bullets}
Conflicts: {cross-domain conflicts, or "none"}
Verdict: {APPROVE | ADVISE(details) | BLOCK(details)} (Phase 3.5 reviewers only)
Full output: $SCRATCH_DIR/{slug}/phase2-{agent-name}.md
```

The `Phase` field groups agents in the report's Agent Contributions section.
Planning agents (Phase 2) get `Phase: planning`. Architecture reviewers
(Phase 3.5) get `Phase: review`.

Each summary: ~80-120 tokens (~100-150 for reviewers, verdict field adds ~20 tokens).
Versus 500-2000+ for full contributions.

### Lifecycle

- **Creation**: `mktemp -d` + `mkdir` at Phase 1 start (see above).
- **Overwrites**: Each session gets a unique temp directory (no collisions).
- **Cleanup**: Removed at wrap-up (`rm -rf "$SCRATCH_DIR"`). Interrupted
  sessions leave files in temp, cleaned on reboot.
- **Git**: Not in the working tree. No gitignore entry needed.

## Phase 1: Meta-Plan

**Before spawning nefario**: Generate the session slug from the task description
(same rules as report slug: kebab-case, lowercase, max 40 chars, strip articles,
alphanumeric and hyphens only). Create the scratch directory:

```sh
SCRATCH_DIR=$(mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX") && chmod 700 "$SCRATCH_DIR"
mkdir "$SCRATCH_DIR/${slug}"
```

Detect the report directory (see Path Resolution above). Resolve both paths
before proceeding. Both resolved paths must be included in CONDENSE checkpoints.

Extract a status summary from the first line of the user's task description.
Truncate to 48 characters; if truncated, append "..." (so "Nefario: " 9-char
prefix + 48 + 3 = 60 chars max). Write the sentinel file:
```sh
echo "$summary" > /tmp/nefario-status-${slug}
chmod 600 /tmp/nefario-status-${slug}   # Status file: read from custom statusline scripts
```
Use this summary text in Task `description` fields and TaskCreate `activeForm`
fields throughout the orchestration (see per-phase instructions below).

Capture the verbatim user task description (the text that will be inserted at
`<insert the user's task description>`) and retain it in session context as
`original-prompt`. This is the text that appears in the report's Original Prompt section.
Before including in the report, sanitize: remove any secrets, tokens, API keys,
or credentials. Replace with `[REDACTED]`.

Write the **already-sanitized** original prompt to `$SCRATCH_DIR/{slug}/prompt.md`
as plain markdown (no YAML frontmatter). This file flows to the report's companion
directory via the existing `cp -r` at wrap-up, providing a standalone record of the
original request.

Spawn nefario as a planning subagent to analyze the task and determine
which specialists should be consulted for planning.

```
Task:
  subagent_type: nefario
  description: "Nefario: meta-plan"
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
    6. Write your complete meta-plan to `$SCRATCH_DIR/{slug}/phase1-metaplan.md`
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
  description: "Nefario: <agent> planning"
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
    6. Write your complete contribution to `$SCRATCH_DIR/{slug}/phase2-{your-name}.md`
```

**After each specialist returns**: Write their full output to the scratch file
(if the specialist did not already do so). Record an inline summary using the
template from the Scratch File Convention section. Pass only the summary and
file path forward -- do not paste the full contribution into later prompts.

**Important**: If any specialist recommends additional agents, spawn those
agents for planning too (a second round of Phase 2 consultations), then
include their contributions in Phase 3.

## Phase 3: Synthesis

Spawn nefario again with ALL specialist contributions to create the
final execution plan.

```
Task:
  subagent_type: nefario
  description: "Nefario: synthesis"
  model: opus
  prompt: |
    MODE: SYNTHESIS

    You are synthesizing specialist planning contributions into a
    final execution plan.

    ## Original Task
    <insert the user's task>

    ## Specialist Contributions

    Read the following scratch files for full specialist contributions:
    <list each file path: $SCRATCH_DIR/{slug}/phase2-{agent}.md>

    ## Key consensus across specialists:
    <paste the inline summaries collected during Phase 2>

    ## Instructions
    1. Review all specialist contributions
    2. Resolve any conflicts between recommendations
    3. Incorporate risks and concerns into the plan
    4. Create the final execution plan in structured format
    5. Ensure every task has a complete, self-contained prompt
    6. Write your complete delegation plan to `$SCRATCH_DIR/{slug}/phase3-synthesis.md`
```

Nefario will return a structured delegation plan. **After synthesis returns**:
Write the full execution plan to `$SCRATCH_DIR/{slug}/phase3-synthesis.md`
(if nefario did not already do so). Record a compact summary (task count, gate
count, execution order) in session context. **Proceed to Phase 3.5
(Architecture Review)** before presenting the plan to the user.

### Compaction Checkpoint

After writing the synthesis to the scratch file, present a compaction prompt:

```
---
COMPACT: Phase 3 complete. Specialist details are now in the synthesis.

Run: /compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, scratch directory path. Discard: individual specialist contributions from Phase 2."

After compaction, type `continue` to resume at Phase 3.5 (Architecture Review).

Skipping is fine if context is short. Risk: auto-compaction in later phases may lose orchestration state.
---
```

If the user runs `/compact`, wait for them to say "continue" then proceed.
If the user types anything else (or says "skip"/"continue"), print:
`Continuing without compaction. Auto-compaction may interrupt later phases.`
Then proceed to Phase 3.5. Do NOT re-prompt at subsequent boundaries.

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
  - lucy
  - margo
- **Conditional**:
  - observability-minion: 2+ tasks produce runtime components, services, or APIs
  - ux-design-minion: 1+ tasks produce user-facing interfaces
  - accessibility-minion: 1+ tasks produce web-facing UI
  - sitespeed-minion: 1+ tasks produce web-facing runtime components

### Spawn Reviewers

Spawn all identified reviewers in parallel. Use opus for lucy and margo
(governance reviewers requiring deeper reasoning); use sonnet for all others:

```
Task:
  subagent_type: <reviewer agent>
  description: "Nefario: <agent> review"
  model: opus  # for lucy, margo; sonnet for all other reviewers
  prompt: |
    You are reviewing a delegation plan before execution begins.
    Your role: identify gaps, risks, or concerns from your domain.

    ## Delegation Plan
    Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

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
- **Any BLOCK**: Enter the revision loop below.

#### Revision Loop (BLOCK path)

Follow these steps exactly. **Global cap: 2 revision rounds total.**

1. **Collect feedback from the current round.** Gather:
   - All BLOCK verdicts (reviewer name, ISSUE, RISK, SUGGESTION).
   - All ADVISE verdicts as secondary, non-blocking context.

2. **Write scratch files.** For each reviewer that returned BLOCK or ADVISE,
   write their verdict to `$SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md`.
   On re-review rounds, overwrite the same file (the final verdict is what
   matters; git preserves history if needed). APPROVE verdicts do not need
   scratch files.

3. **Revise the plan.** Send a single revision request to nefario
   (MODE: SYNTHESIS). The prompt must include:
   - Every BLOCK verdict from this round (reviewer name, ISSUE, RISK,
     SUGGESTION).
   - Every ADVISE verdict as secondary context.
   - Instruction: "Address ALL listed BLOCKs in the revised plan."
   - Warning: "The revised plan will be re-reviewed by ALL reviewers,
     not just the blockers."
   - Instruction: "Overwrite `$SCRATCH_DIR/{slug}/phase3-synthesis.md`
     with the revised plan."

4. **Re-review the revised plan.** Spawn ALL reviewers who participated in
   the initial Phase 3.5 review (not just the blockers). Use the same
   reviewer spawning logic as the initial round. Each re-review prompt must
   tell the reviewer:
   - This is a re-review of a revised plan (revision round N of 2).
   - What changed and why (from nefario's revision output).
   - Which BLOCK verdicts triggered the revision.
   - The reviewer's own previous verdict.
   - They may raise NEW concerns introduced by the revision.
   - They should not re-raise concerns the revision adequately addressed.

5. **Evaluate re-review verdicts.**
   - All APPROVE or ADVISE: Done. Write any ADVISE scratch files per step 2.
     Append ADVISE notes to task prompts. Present the plan to the user for
     approval. Proceed to Phase 4.
   - Any BLOCK and revision rounds remaining (< 2 used): Return to step 1
     for the next revision round.
   - Any BLOCK and revision rounds exhausted (2 used): Present the impasse
     to the user with all reviewer positions and let the user decide how
     to proceed.

### Compaction Checkpoint

After processing all review verdicts, present a compaction prompt:

```
---
COMPACT: Phase 3.5 complete. Review verdicts are folded into the plan.

Run: /compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, scratch directory path. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."

After compaction, type `continue` to resume at Phase 4 (Execution).

Skipping is fine if context is short. Risk: auto-compaction during execution may lose task/agent tracking.
---
```

Same response handling: if user runs `/compact`, wait for "continue". If
anything else, print the continuation message and proceed. Do NOT re-prompt.

## Execution Plan Approval Gate

After Phase 3.5 completes, present the execution plan to the user for approval
using progressive disclosure optimized for anomaly detection. The user knows
what they asked for; they need to spot surprises and decide whether to proceed.

### Plan Presentation Format

**Instant orientation** (one line + stats):
```
EXECUTION PLAN: <1-sentence goal summary>
Tasks: N | Gates: N | Advisories incorporated: N
```

**Task list** (compact numbered list, 2-4 lines per task):
```
TASKS:
  1. <Task title>                                    [agent-name, model]
     Produces: <deliverable summary>
     Depends on: none

  2. <Task title>                                    [agent-name, model]
     Produces: <deliverable summary>
     Depends on: Task 1
     GATE: Approval required before Tasks 3, 4 proceed
```
Format rules:
- Title on line 1, metadata indented below
- Agent name and model in brackets (secondary info, right side)
- Dependencies by task number
- GATE marker inline with the blocking task
- One blank line between tasks, no blank lines within a task

**Advisories** (presented as a SEPARATE block after task list):

Advisories are plan changes (delta model), not reviewer opinions. Attribute to
the DOMAIN (testing, security, usability, etc.), not the agent name.

Format:
```
ADVISORIES:
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>

  [<domain>] Task M: <task title>
    CHANGE: ...
    WHY: ...
```

Advisory principles:
- Two-field format (CHANGE, WHY) makes each advisory self-contained
- Maximum 3 lines per advisory. If more complex, add:
  "Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md"
- Maximum 5 advisories explained individually. Beyond 5, group related advisories
- Beyond 7, the plan needs rework (too many course corrections)
- If an advisory did NOT change the task (informational only), say:
  "[domain]: <note>. No task changes."

**Risks and conflict resolutions** (if any exist):
```
RISKS:
  - <risk description> — Mitigation: <what the plan does about it>

CONFLICTS RESOLVED:
  - <what was contested>: Resolved in favor of <approach> because <rationale>
```
Omit if no conflicts. If no risks, note: "No risks identified by specialists."

**Review summary** (one line):
```
REVIEW: N APPROVE, N ADVISE, N BLOCK
```

**Full plan reference**:
```
FULL PLAN: $SCRATCH_DIR/{slug}/phase3-synthesis.md
```

**Line budget guidance**: Target 25-40 lines for the complete gate output
(orientation + task list + advisories + risks + review summary + plan reference).
This is soft guidance, not a hard ceiling — clarity wins over brevity.

### What NOT to Show

Do not include at the plan approval gate:
- Full agent prompts (implementation detail — in the scratch file)
- Model selection (opus vs sonnet)
- Mode selection (bypassPermissions, plan, default)
- File ownership assignments
- Cross-cutting coverage checklist (internal bookkeeping)
- Architecture review agent list (the results matter, not who reviewed)

### Decision Options

Present the plan for approval using AskUserQuestion:
- `header`: "Plan"
- `question`: "<the orientation line goal summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve", description: "Accept plan and begin execution." (recommended)
  2. label: "Request changes", description: "Revise the plan before execution."
  3. label: "Reject", description: "Abandon this plan entirely."

### Request Changes Workflow

When the user selects "Request changes":
1. The user provides feedback on what to change
2. Nefario revises the affected parts of the plan (may re-run synthesis for changed tasks)
3. The gate is presented again with the updated plan

After "Approve", proceed to Phase 4 execution.

## Phase 4: Execution

After user approval, execute the plan. If the plan contains **approval gates**,
execution proceeds in batches separated by gate checkpoints.

### Branch Creation

Before spawning any execution agents, isolate work on a feature branch.

**Git repo check**: If not in a git repo (see Path Resolution), skip branch
creation entirely. Print: "No git repo detected. Run `git init` if you want
automatic branching and commits." Proceed directly to Setup.

1. Get current branch: `git branch --show-current`
2. Detect default branch:
   `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
   (fall back to `main`).
3. If already on a non-default feature branch, use it (do not create a nested
   branch, do not switch to the default branch).
4. If on the default branch:
   a. Check working tree: `git status --porcelain`
   b. If dirty, warn: "Working tree has uncommitted changes. Stash or commit
      before proceeding." and STOP.
   c. Pull latest: `git pull --rebase`
   d. If pull fails, warn and STOP.
   e. Create feature branch: `git checkout -b nefario/<slug>` (reuse the slug
      generated in Phase 1).

After branch resolution (whether creating a new branch or using an existing one),
create the orchestrated-session marker to suppress commit hook noise:
`touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`

### Setup

1. **Create a team** using TeamCreate with the team name from the plan.

2. **Create tasks** using TaskCreate for each task in the plan.
   Set dependencies via TaskUpdate.
   Set `activeForm` to `"Nefario: <summary> -- <task-specific activeForm>"`.
   If the combined string exceeds 80 characters, use just the task-specific
   activeForm.

### Execution Loop

Group tasks into batches based on dependencies and approval gates.
A batch contains all tasks that can run before the next gate.

3. **Spawn teammates** for the current batch using the Task tool:
   ```
   Task:
     subagent_type: <agent name>
     description: "Nefario: <short task summary>"
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
   deliverable using the structured decision brief.

   First, print the decision brief as normal conversation output:

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
   ```

   Then present the decision using AskUserQuestion:
   - `header`: "Gate"
   - `question`: the DECISION line from the brief
   - `options` (4, `multiSelect: false`):
     1. label: "Approve", description: "Accept and continue execution." (recommended)
     2. label: "Request changes", description: "Send feedback for revision (max 2 rounds)."
     3. label: "Reject", description: "Drop this task and its dependents from the plan."
     4. label: "Skip", description: "Defer; re-presented before wrap-up."

   Response handling:
   - **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
     - `header`: "Post-exec"
     - `question`: "Post-execution phases for this task?"
     - `options` (4, `multiSelect: false`):
       1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
       2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
       3. label: "Skip tests", description: "Skip test execution (Phase 6)."
       4. label: "Skip review", description: "Skip code review (Phase 5)."
     Options are ordered by ascending risk (docs = lowest, review = highest).
     If "Run all": run post-execution phases (5-8) after execution completes.
     If "Skip docs/tests/review": skip the selected phase, run the rest.
     Then auto-commit changes (see below) and continue to next batch.
     The user may also type a freeform response instead of selecting an option,
     using flags to skip multiple phases (e.g., "--skip-docs --skip-tests",
     or "--skip-post" to skip all). Interpret natural language skip intent as
     equivalent to the corresponding flags. Flag reference:
     - `--skip-docs` = skip Phase 8
     - `--skip-tests` = skip Phase 6
     - `--skip-review` = skip Phase 5
     - `--skip-post` = skip Phases 5, 6, 8 (all post-execution)
     Flags can be combined: `--skip-docs --skip-tests` skips both.
   - **"Request changes"**: Follow up with a brief conversational message asking
     "What changes are needed?" (keep it minimal). Send feedback to agent.
     Cap at 2 revision rounds.
   - **"Reject"**: Present a SECONDARY AskUserQuestion for confirmation:
     - `header`: "Confirm"
     - `question`: "Reject <task>? This will also drop: <list dependents>"
     - `options` (2, `multiSelect: false`):
       1. label: "Confirm reject", description: "Remove task and dependents."
       2. label: "Cancel", description: "Go back to the gate decision."
     If confirmed, remove from plan and continue. If canceled, return to gate.
   - **"Skip"**: Defer the gate. Continue with non-blocked tasks.
     Re-present skipped gates before the wrap-up phase.

   **Auto-commit after gate approval**: After a gate is approved, silently:
   1. Identify files changed since the last commit (use the change ledger).
   2. Filter against sensitive patterns (existing safety rails apply).
   3. If no changes or all changes are sensitive, skip silently.
   4. Stage and commit with conventional commit message:
      `<type>(<scope>): <summary>` with
      `Co-Authored-By: Claude <noreply@anthropic.com>`
   5. Print ONE informational line:
      `Committed N files: path1, path2, ...`
      (list up to 5 files; if more, show first 4 and "+ N more").
   6. If commit fails, print a warning and continue (do not block execution).

   Never use `git add -A` — only stage files from the change ledger.

   Anti-fatigue guidelines:
   - Budget 3-5 approval gates per plan. If synthesis produces more,
     consolidate related gates.
   - Include rejected alternatives in every brief -- this is the key lever
     against rubber-stamping.
   - Set confidence based on: number of viable alternatives (more = lower),
     reversibility (harder = lower), downstream dependents (more = lower).
   - Calibration check: After 5 consecutive approvals without changes, present using AskUserQuestion:
     - `header`: "Calibrate"
     - `question`: "5 consecutive approvals without changes. Gates well-calibrated?"
     - `options` (2, `multiSelect: false`):
       1. label: "Gates are fine", description: "Continue with current gating level."
       2. label: "Fewer gates next time", description: "Note for future plans: consolidate more aggressively."

6. Repeat steps 3-5 for each batch until all tasks are complete.

### Post-Execution Phases (5-8)

After all execution batches complete, run post-execution verification.
These phases follow the **dark kitchen** pattern: they run silently. The
user sees one CONDENSE line at the start and one consolidated result in
the wrap-up summary.

Determine which post-execution phases to run based on the user's follow-up
response (structured selection or freeform text flags):
- Phase 5 (Code Review): Skip if user selected "Skip review" or typed
  --skip-review or --skip-post. Also skip if Phase 4 produced no code
  files (existing conditional, unchanged).
- Phase 6 (Test Execution): Skip if user selected "Skip tests" or typed
  --skip-tests or --skip-post. Also skip if no tests exist (existing
  conditional, unchanged).
- Phase 8 (Documentation): Skip if user selected "Skip docs" or typed
  --skip-docs or --skip-post. Also skip if checklist has no items
  (existing conditional, unchanged).

Print a CONDENSE status line listing only the phases that will actually run:
- No skips: `Verifying: code review, tests, documentation...`
- Skip docs: `Verifying: code review, tests...`
- Skip review + tests: `Verifying: documentation...`
- All skipped (by user or by existing conditionals): skip the status line
  entirely and proceed directly to Wrap-up.

**Optional compaction**: If context pressure is high after Phase 4,
consider a compaction checkpoint here. Not mandatory -- it breaks the
dark kitchen silence. Note as future optimization if needed.

#### Phase 5: Code Review

Skip if Phase 4 produced no code files (only docs/config). Note the skip.

Spawn three reviewers **in parallel**:

```
Task:
  subagent_type: <code-review-minion | lucy | margo>
  description: "Nefario: <agent> code review"
  model: <sonnet for code-review-minion, opus for lucy/margo>
  prompt: |
    You are reviewing code produced during an orchestrated execution.

    ## Changed Files
    <list files created/modified during Phase 4, from the change ledger>

    ## Execution Context
    Read scratch files for context: $SCRATCH_DIR/{slug}/phase3-synthesis.md

    ## Your Review Focus
    <code-review-minion: code quality, correctness, bug patterns,
     cross-agent integration, complexity, DRY, security implementation
     (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs)>
    <lucy: convention adherence, CLAUDE.md compliance, intent drift>
    <margo: over-engineering, YAGNI, dependency bloat>

    ## Instructions
    Review the actual code files listed above. Return verdict:

    VERDICT: APPROVE | ADVISE | BLOCK
    FINDINGS:
    - [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
      AGENT: <producing-agent>
      FIX: <specific fix>

    Write findings to: $SCRATCH_DIR/{slug}/phase5-{your-name}.md
```

**Process verdicts**:
- All APPROVE/ADVISE: write ADVISE findings to scratch. Proceed to Phase 6.
- Any BLOCK: group findings by producing agent. Spawn fix tasks with the
  specific findings. Re-review changed files only. Cap at 2 rounds.
- Security-severity BLOCKs (injection, auth bypass, secret exposure, crypto):
  surface to user before auto-fix (SHOW: max 5-line escalation brief).
- After 2 rounds unresolved: escalate to user. Print the structured brief:
  ```
  VERIFICATION ISSUE: <title>
  Phase: Code Review | Agent: <reviewer>
  Finding: <one-sentence description>
  Producing agent: <who wrote the code> | File: <path>
  Auto-fix attempts: 2 (unsuccessful)
  ```

  Then present the decision using AskUserQuestion:
  - `header`: "Issue"
  - `question`: the one-sentence finding description from the brief
  - `options` (3, `multiSelect: false`):
    1. label: "Accept as-is", description: "Proceed with current code. Log finding for later." (recommended)
    2. label: "Fix manually", description: "Pause orchestration. You fix the code, then resume."
    3. label: "Skip verification", description: "Skip all remaining code review and test checks."

#### Phase 6: Test Execution

Runs after Phase 5 (or after Phase 4 if Phase 5 was skipped). Skip if no
tests exist AND Phase 4 did not produce tests. Note the skip.

1. **Test discovery** (4-step sequence):
   - Check for test commands: `package.json` scripts, `Makefile` targets,
     `pyproject.toml` pytest config
   - Check CI config: `.github/workflows/*.yml`, `.circleci/config.yml`
   - Scan for test files: `**/*.test.{ts,js}`, `**/*.spec.*`, `**/test_*.py`,
     `**/*_test.go`, `tests/`, `__tests__/`
   - Check framework config: `vitest.config.*`, `jest.config.*`, `pytest.ini`

2. **Baseline comparison**: Compare against baseline captured at Phase 4
   start (if available). New failures = blocking. Pre-existing = non-blocking.
   Heuristic fallback: if failing test was not modified in Phase 4, treat as
   likely pre-existing.

3. **Layered execution**: lint/type-check -> unit tests -> integration/E2E
   (skip integration/E2E if prerequisites unavailable).

4. **Process results**:
   - All pass: write summary to scratch. Proceed to Phase 7/8.
   - New failures: route to producing agent for fix (infrastructure issues
     to test-minion instead). Cap at 2 rounds. Escalate if unresolved.
   - Pre-existing failures: document as non-blocking ADVISE.
   - No test infrastructure found: ADVISE with note, not a silent pass.

5. Write output to: `$SCRATCH_DIR/{slug}/phase6-test-results.md`

#### Phase 7: Deployment (Conditional)

Skip unless user opted in at plan approval. This is a separate opt-in,
not part of the default flow.

1. Run deployment command (e.g., `./install.sh`). Report pass/fail.
2. If command fails: BLOCK and escalate to user.
3. Write output to: `$SCRATCH_DIR/{slug}/phase7-deployment.md`

#### Phase 8: Documentation (Conditional)

1. **Generate checklist** from execution outcomes:

   | Outcome | Action | Owner |
   |---------|--------|-------|
   | New API endpoints | API reference, OpenAPI prose | software-docs-minion |
   | Architecture changed | C4 diagrams, component docs | software-docs-minion |
   | Gate-approved decision | ADR | software-docs-minion |
   | New user-facing feature | Getting-started / how-to | user-docs-minion |
   | New CLI command/flag | Usage docs | user-docs-minion |
   | User-visible bug fix | Release notes | user-docs-minion |
   | README not updated | README review | software-docs + product-marketing |
   | New project (git init) | Full README (blocking) | software-docs + product-marketing |
   | Breaking change | Migration guide | user-docs-minion |
   | Config changed | Config reference | software-docs-minion |

   Write checklist to: `$SCRATCH_DIR/{slug}/phase8-checklist.md`

2. If checklist is empty, skip entirely.

3. **Sub-step 8a** (parallel): spawn software-docs-minion + user-docs-minion
   with their respective checklist items and paths to execution artifacts.

4. **Sub-step 8b -- Marketing lens** (sequential, after 8a): if checklist
   includes README or user-facing docs, spawn product-marketing-minion with
   the following inputs and instructions. Otherwise skip.

   **Inputs to product-marketing-minion**:
   - The Phase 8 checklist (`$SCRATCH_DIR/{slug}/phase8-checklist.md`)
   - The execution summary (what changed and why)
   - Current `README.md`

   **Instructions**: Classify each user-visible change into one of three tiers
   using the decision criteria below. Return a tier classification for each
   change and the corresponding recommendation.

   **Tier definitions**:

   | Tier | Name | Criteria | Action |
   |------|------|----------|--------|
   | 1 | Headline Feature | New capability (user can do something new) AND strengthens a core differentiator (orchestration, governance, specialist depth, install-once) OR changes the user's mental model | Recommend specific README changes with proposed copy. Flag if core positioning needs update. |
   | 2 | Notable Enhancement | Improves existing capability in a user-visible way, OR removes a friction point in getting-started or daily-use, OR is a breaking change | Recommend where to mention in existing docs. Include in release notes. For breaking changes: flag migration guide need. |
   | 3 | Document Only | Internal improvement, bug fix, refactor, or maintenance. User experience unchanged. | Confirm documentation coverage is sufficient. No README or positioning changes. |

   **Decision criteria** (evaluate in order, stop at first match):
   1. Does this change what the project can do? (new capability = Tier 1 candidate)
   2. Would a user notice during normal usage? (yes = Tier 2 minimum; no = Tier 3)
   3. Does it strengthen a core differentiator? (if yes, promote one tier)
   4. Does it change the user's mental model? (if yes = Tier 1)
   5. Is it a breaking change? (always Tier 2 minimum)

   **Output format**: For each change, return:
   - Change description (one line)
   - Tier classification (1, 2, or 3) with rationale (one sentence)
   - Recommendation per the action column above

   Write output to: `$SCRATCH_DIR/{slug}/phase8-marketing-review.md`

   **Example triage** (reference test case):
   - Change: "Added accessibility-minion as conditional Phase 3.5 reviewer"
   - Tier: 2 (Notable Enhancement). Improves governance coverage for web UI
     tasks -- user-visible when working on web projects -- but does not
     introduce a new capability or change the mental model.
   - Recommendation: Mention in docs/orchestration.md reviewer table. Include
     in release notes. No README change needed.

5. Non-blocking by default. Exception: new project requires README before PR.

6. Write output to: `$SCRATCH_DIR/{slug}/phase8-software-docs.md`,
   `phase8-user-docs.md`, `phase8-marketing-review.md`

### Wrap-up

7. **Review all deliverables** and consolidate verification results.

   Build the **Verification summary** from Phase 5-8 outcomes. List what
   ran with outcomes; omit phases that didn't run. Format examples:
   - All ran, all passed: "Verification: all checks passed."
   - All ran, with fixes: "Verification: 2 code review findings auto-fixed, all tests pass, docs updated (3 files)."
   - Partial skip: "Verification: code review passed, tests passed. Skipped: docs."
   - All skipped: "Verification: skipped (--skip-post)."
   The "Skipped:" suffix tracks user-requested skips only. Phases skipped
   by existing conditionals (e.g., "no code files") are not listed.

8. **Auto-commit remaining changes** — if in a git repo, silently commit any
   uncommitted files from the change ledger before generating the report. Print
   the informational commit line (`Committed N files: ...`). Skip if no git repo.

9. **Verify and report** — follow the wrap-up sequence documented in the
   "Report Generation" section below (review deliverables, write report,
   present to user, shutdown teammates, final status).

10. **PR creation** — after the report is committed, if in a git repo and on
    a feature branch, offer to create a pull request using AskUserQuestion:

    - `header`: "PR"
    - `question`: "Create PR for nefario/<slug>?"
    - `options` (2, `multiSelect: false`):
      1. label: "Create PR", description: "Push branch and open pull request on GitHub." (recommended)
      2. label: "Skip PR", description: "Keep branch local. Push later."

    If "Create PR" is selected: `git push -u origin <branch>` then create the PR.
    Use the report body as the PR description. Write the stripped body to a
    temp file to avoid shell expansion issues:
    ```sh
    body_file=$(mktemp)
    tail -n +2 "$report_file" | sed '1,/^---$/d' > "$body_file"
    # Secret scan on PR body
    if grep -qEi 'sk-|key-|ghp_|github_pat_|AKIA|token:|bearer|password:|passwd:|BEGIN.*PRIVATE KEY' "$body_file"; then
      echo "WARNING: PR body may contain secrets. Review $body_file before proceeding."
      rm -f "$body_file"
      exit 1
    fi
    gh pr create --title "$pr_title" --body-file "$body_file"
    rm -f "$body_file"
    ```
    The `--title` comes from the frontmatter `task` field. If the temp file
    is empty or starts with `---`, warn and fall back to the executive summary only.
    If `gh` is unavailable, print the manual push command instead.

11. **Return to default branch** — after PR creation (or if declined),
    if in a git repo:
    Remove the orchestrated-session marker and status sentinel:
    `rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`
    `rm -f /tmp/nefario-status-${slug}`
    Detect default branch:
    `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
    (fall back to `main`). Then: `git checkout <default-branch> && git pull --rebase`.
    Include branch name in final summary.
    If not in a git repo, skip this step.

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

Phase data is tracked in two places:
- **Scratch files** (on disk): Full phase outputs for reference and recovery.
  See Scratch File Convention above.
- **Session context** (in memory): Compact summaries for report generation.
  The items below describe what to retain in session context at each boundary.

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
- Gate decision briefs: for each gate presented, retain the full decision brief
  (rationale bullets, rejected alternatives, confidence level, and outcome) in
  session context. These populate the enriched gate briefs in the report's
  Decisions and Execution sections.

**After Phase 5-8 (Post-Execution)**:
- Code review findings count (BLOCK/ADVISE/NIT) and resolution status
- Test results (pass/fail/skip counts, coverage assessment)
- Deployment status (pass/fail/skipped)
- Documentation files created/updated (count and paths)

**At Wrap-up**:
- Outstanding items
- Approximate total duration

**Fallback for compacted summaries**: If inline summaries or gate decision
briefs were lost to compaction, read scratch files from
`$SCRATCH_DIR/{slug}/phase2-*.md` and `$SCRATCH_DIR/{slug}/phase3.5-*.md`
at wrap-up to reconstruct agent contribution summaries and gate briefs for
the report.

### Report Template

The report format is defined inline below in the Wrap-up Sequence section.
No external template file dependency is required.

### Incremental Writing

For long-running orchestrations, write a partial report after Phase 3
(synthesis). Include available data and mark sections as "In Progress".
Overwrite with the complete report at wrap-up.

### Wrap-up Sequence (MANDATORY)

When all tasks are complete, you MUST execute every step below. The execution
report is not optional — it is as mandatory as the synthesis phase. Do not
skip it, do not defer it, do not stop before it is written.

1. Review all deliverables
2. **Capture timestamp** — record the current local time as HHMMSS
   (24-hour, zero-padded). This timestamp is used for both the companion
   directory name and the report filename. Capture it once; reuse it
   throughout wrap-up.
3. **Verification summary** — consolidate Phase 5-8 outcomes into a single
   block for the report and user summary. List what ran with outcomes;
   omit phases that didn't run. Format examples:
   - All ran, all passed: "Verification: all checks passed."
   - All ran, with fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
   - Partial skip: "Verification: code review passed, tests passed. Skipped: docs."
   - All skipped: "Verification: skipped (--skip-post)."
   The "Skipped:" suffix tracks user-requested skips only. Phases skipped
   by existing conditionals (e.g., "no code files") are not listed.
4. Auto-commit remaining changes (silent, informational line only)
5. **Collect working files** — if `$SCRATCH_DIR/{slug}/` exists and
   contains files, copy them to a companion directory alongside the report:
   - Derive the companion directory name from the report filename:
     `<REPORT_DIR>/<YYYY-MM-DD>-<HHMMSS>-<slug>/`
     (report filename without `.md` extension)
   - **Sanitization before copy**: scan scratch files for common credential
     patterns: `sk-`, `-----BEGIN.*PRIVATE KEY`, `AKIA`, `ghp_`,
     `github_pat_`, `token:`, `bearer`, `password:`, `passwd:`,
     long base64 strings (40+ chars of `[A-Za-z0-9+/=]`).
     If matches are found, warn the user and request confirmation before
     copying. Provide option to skip companion directory creation entirely.
   - Create the companion directory: `mkdir -p <companion-dir>`
   - Copy all files: `cp -r $SCRATCH_DIR/{slug}/* <companion-dir>/`
   - Record the list of copied filenames for the report's Working Files section
   - **Security check before committing**: scan copied files for secrets.
     Look for: API keys (`sk-`, `key-`, `AKIA`), tokens (`token:`,
     `bearer`, `ghp_`, `github_pat_`), passwords (`password:`, `passwd:`),
     connection strings (`://` with credentials), private keys
     (`BEGIN.*PRIVATE KEY`).
     Remove or redact any matches before proceeding.
   - If the scratch directory does not exist or is empty, skip this step.
     The report's Working Files section will say "None".
   - **Scratch cleanup**: After copying (or skipping), remove the scratch
     directory: `rm -rf "$SCRATCH_DIR"`. Interrupted orchestrations leave
     scratch files in temp, cleaned on reboot.
6. **Write execution report** to `<REPORT_DIR>/<YYYY-MM-DD>-<HHMMSS>-<slug>.md`
   — use the HHMMSS captured in step 2
   — follow the report format defined in this skill (see Data Accumulation above)
   — include a Verification section with Phase 5-8 outcomes
   — include a Working Files section linking to the companion directory
7. Commit the report and companion directory together (auto-commit, no prompt needed; skip if no git repo)
8. Offer PR creation if on a feature branch (skip if no git repo)
9. Return to default branch (if git repo): detect with
   `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
   (fall back to `main`), then `git checkout <default-branch> && git pull --rebase`
10. Present report path, PR URL, branch name, and Verification summary to user
11. Send shutdown_request to teammates
12. TeamDelete
13. Report final status to user

