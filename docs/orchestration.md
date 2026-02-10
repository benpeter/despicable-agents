[< Back to Architecture Overview](architecture.md)

# Orchestration and Delegation

For the user-facing orchestration guide, see [Using Nefario](using-nefario.md).

This document covers the architecture of the nine-phase orchestration process (Section 1), the delegation model that routes work to specialists (Section 2), the approval gate mechanism that keeps the user in control of high-impact decisions (Section 3), execution reports (Section 4), and commit points in the execution flow (Section 5).

---

## 1. Nine-Phase Orchestration Architecture

The orchestration system implements a nine-phase process that separates planning intelligence from execution capability, then verifies quality through automated post-execution phases. Nefario provides the planning; the main Claude Code session provides the spawning.

### Phase 1: Meta-Plan

The main session spawns nefario with `MODE: META-PLAN`. Nefario reads the codebase, analyzes the task against the delegation table, and returns a structured meta-plan identifying:

- Which specialists to consult for planning (with specific questions for each)
- Cross-cutting checklist evaluation (all six dimensions assessed)
- Anticipated approval gates
- Scope boundaries (in/out)

The meta-plan is informational. No user approval is required before proceeding to Phase 2.

### Phase 2: Specialist Planning

The main session spawns each specialist identified in the meta-plan as a subagent, passing the specialist-specific planning question and relevant codebase context. Specialists run in parallel.

Each specialist returns a domain plan contribution containing:

- Recommendations grounded in domain expertise
- Proposed tasks with deliverables
- Risks and constraints from their perspective
- Dependencies on or interactions with other specialists' work

### Phase 3: Synthesis

The main session spawns nefario with `MODE: SYNTHESIS`, passing all specialist contributions. Nefario consolidates input into a final execution plan:

1. Resolves conflicts between specialists using project priorities
2. Incorporates risk mitigations from specialist input
3. Adds agents that specialists recommended but were not in the original meta-plan
4. Fills gaps by checking the six cross-cutting dimensions against the plan
5. Classifies approval gates using the reversibility/blast-radius matrix
6. Produces the execution order (topological sort with batch boundaries and gate positions)
7. Identifies which architecture reviewers the plan triggers

The synthesis output includes self-contained prompts for each execution agent -- complete with scope, constraints, deliverables, file paths, and explicit "do NOT do" boundaries.

After synthesis, phase outputs are written to scratch files and a compaction checkpoint is presented to the user. See [Context Management](compaction-strategy.md) for the scratch file pattern and compaction protocol.

### Phase 3.5: Architecture Review

Before execution begins, cross-cutting specialists review the synthesized plan. This phase catches architectural issues that are cheap to fix in a plan and expensive to fix in code.

**Review triggering rules:**

| Reviewer | Trigger | Rationale |
|----------|---------|-----------|
| security-minion | ALWAYS | Security violations in a plan are invisible until exploited |
| test-minion | ALWAYS | Retrofitting test coverage is consistently more expensive than designing it in |
| ux-strategy-minion | ALWAYS | Every plan needs journey coherence and cognitive load assessment |
| software-docs-minion | ALWAYS | Architectural and API surface changes need documentation review |
| lucy | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance |
| margo | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement |
| observability-minion | Conditional: 2+ tasks produce runtime components | Multiple runtime tasks need coordinated observability strategy |
| ux-design-minion | Conditional: 1+ tasks produce user-facing interfaces | UI-producing tasks need accessibility patterns review |
| accessibility-minion | Conditional: 1+ tasks produce web-facing UI | WCAG compliance must be reviewed before UI code is written |
| sitespeed-minion | Conditional: 1+ tasks produce web-facing runtime components | Performance budgets must be established before implementation |

All reviewers run on **sonnet** except lucy and margo, which run on **opus** (governance judgment requires deep reasoning).

**Verdict format:**

Each reviewer returns exactly one of three verdicts:

- **APPROVE** -- No concerns. The plan adequately addresses this reviewer's domain.
- **ADVISE** -- Non-blocking warnings. Advisories are appended to relevant task prompts and presented to the user alongside the plan. They do not block execution.
- **BLOCK** -- Halts execution. The blocking concern is sent to nefario for plan revision. The blocking reviewer re-reviews the revised plan. If still blocked after 2 iteration rounds, the disagreement escalates to the user with both positions presented.

After all reviews complete and any BLOCK verdicts are resolved, the plan (with advisories attached) is presented to the user for approval.

A second compaction checkpoint follows Phase 3.5, allowing the user to reclaim context space before execution begins.

### Phase 4: Execution

After user approval, the main session executes the plan using batch-gated execution:

1. Topological sort determines task order from the dependency graph
2. Approval gates create batch boundaries (split points)
3. All tasks that can run before the next gate form a batch
4. The batch executes (parallel where dependencies allow)
5. When a gate is reached, the decision brief is presented to the user
6. On approval, the next batch of unblocked tasks executes
7. The cycle repeats until all tasks complete

At wrap-up, any skipped gates are re-presented. A final report summarizes deliverables, verification results, known issues, and next steps.

### Post-Execution Phases (5-8)

Phases 5-8 run between execution completion and wrap-up using the **dark kitchen** pattern: they execute silently, writing all findings to scratch files. The user sees a single status line when verification starts and a consolidated summary in the wrap-up report. Only unresolvable BLOCKs (after 2 fix iterations) surface to the user.

At each approval gate, after selecting "Approve", a follow-up prompt offers the option to skip post-execution phases (Phases 5, 6, and 8). Phase 7 is already opt-in.

### Phase 5: Code Review

Runs when Phase 4 produced or modified code files. Skipped if Phase 4 produced only documentation or configuration.

Three reviewers run in parallel:

- **code-review-minion** (sonnet): code quality, correctness, bug patterns, cross-agent integration, complexity, DRY, security implementation checks (hardcoded secrets, injection vectors, auth/authz flaws, crypto misuse, dependency CVEs).
- **lucy** (opus): cross-repo consistency, convention adherence, CLAUDE.md compliance, intent drift.
- **margo** (opus): over-engineering, unnecessary abstractions, dependency bloat, YAGNI.

Verdict format reuses APPROVE/ADVISE/BLOCK with per-finding granularity:

```
VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>
```

BLOCK findings are routed to the original producing agent for fix. Re-review covers only changed files. Iteration capped at 2 rounds, then escalate to user. Security-severity BLOCKs (injection, auth bypass, secret exposure, crypto failure) always surface to user before auto-fix proceeds.

### Phase 6: Test Execution

Runs after Phase 5. Even if Phase 5 was skipped, Phase 6 runs if tests exist in the project.

Test discovery follows a 4-step project-aware sequence: check package.json / Makefile / pyproject.toml scripts, check CI config, scan for test files, check framework config. Execution is layered: lint/type-check first, then unit tests, then integration/E2E (skipped gracefully if prerequisites unavailable).

Coverage assessment is qualitative and change-relative (no hard percentage threshold). Minimum bar: all tests pass, new code has at least one happy-path test, no critical path is test-free.

Failure routing: infrastructure issues to test-minion, application logic failures to producing agent. Pre-existing failures are non-blocking via delta analysis against a baseline snapshot captured at Phase 4 start.

Verdict: APPROVE/ADVISE/BLOCK, capped at 2 iteration rounds.

### Phase 7: Deployment (Conditional)

Runs only when the user explicitly requests deployment at plan approval time. Default: skip. Scope is limited to running existing deployment commands (e.g., `./install.sh`), not building deployment pipelines from scratch.

Agent: iac-minion if deployment is non-trivial. Verdict: pass/fail -- if the deployment command fails, BLOCK and escalate.

### Phase 8: Documentation (Conditional)

Runs when nefario's documentation checklist has items. The checklist is generated at the Phase 7-to-8 boundary based on execution outcomes (e.g., new API endpoints trigger API reference docs, architecture changes trigger C4 diagram updates, user-facing features trigger how-to guides).

Two sub-steps:

- **8a** (parallel): software-docs-minion (architecture docs, ADRs, API reference, README technical sections) + user-docs-minion (tutorials, guides, release notes, in-app help).
- **8b** (sequential after 8a): product-marketing-minion reviews README and user-facing docs. Conditional -- only when the checklist includes README or user-facing documentation.

Non-blocking by default. Exception: new project (git init) requires README before PR.

### Delegation Flow

```mermaid
sequenceDiagram
    participant User
    participant Main as Main Session
    participant Nef as Nefario
    participant Spec as Specialists
    participant Rev as Reviewers
    participant Exec as Execution Agents

    Note over Main,Nef: Phase 1: Meta-Plan
    Main->>Nef: Task(MODE: META-PLAN)
    Nef->>Main: Meta-plan (specialists to consult)

    Note over Main,Spec: Phase 2: Specialist Planning
    par Parallel Consultation
        Main->>Spec: Task(planning questions)
        Spec->>Main: Domain plan contributions
    end

    Note over Main,Nef: Phase 3: Synthesis
    Main->>Nef: Task(MODE: SYNTHESIS, all contributions)
    Nef->>Main: Synthesized execution plan

    Note over Main: Scratch files written + compaction checkpoint

    Note over Main,Rev: Phase 3.5: Architecture Review
    Main->>Main: Determine reviewers (trigger rules)
    par Parallel Review
        Main->>Rev: Task(review synthesized plan)
        Rev->>Main: Verdict (APPROVE / ADVISE / BLOCK)
    end

    alt Any BLOCK verdict
        Main->>Nef: Task(revise plan, blocking feedback)
        Nef->>Main: Revised plan
        Main->>Rev: Task(re-review)
        Rev->>Main: Verdict
        alt Still BLOCK after 2 iterations
            Main->>User: Escalate disagreement
        end
    end

    Note over Main: Scratch files written + compaction checkpoint

    Main->>User: Present plan + advisories + gate map

    Note over User,Main: Plan Approval Gate
    User->>Main: Approve / request changes / reject (structured prompt)

    Note over Main,Exec: Phase 4: Execution (batch-gated)
    Main->>Main: Topological sort, identify batches

    loop For each batch
        par Parallel Execution
            Main->>Exec: Spawn agents for batch
            Exec->>Main: Deliverables
        end

        alt Batch boundary is an approval gate
            Main->>User: Decision brief + structured prompt
            User->>Main: Approve / Request changes / Reject / Skip
            alt Request changes
                Main->>Exec: Revise (max 2 iterations)
                Exec->>Main: Revised deliverable
            end
        end
    end

    Note over Main,Exec: Post-Execution (dark kitchen)

    opt Phase 5: Code Review (code files produced)
        par Parallel Review
            Main->>Rev: code-review-minion + lucy + margo
            Rev->>Main: Verdicts + findings
        end
        alt Any BLOCK finding
            Main->>Exec: Route fix to producing agent
            Exec->>Main: Fix applied
            Main->>Rev: Re-review changed files
            Rev->>Main: Verdict
            alt Still BLOCK after 2 rounds
                Main->>User: Escalate unresolvable finding
            end
        end
    end

    opt Phase 6: Test Execution (tests exist)
        Main->>Main: Discover tests, run layered execution
        alt New test failures
            Main->>Exec: Route failure to producing agent
            Exec->>Main: Fix applied
            Main->>Main: Re-run failed tests
        end
    end

    opt Phase 7: Deployment (user-requested)
        Main->>Main: Run deployment commands
    end

    opt Phase 8: Documentation (checklist has items)
        par 8a: Parallel Documentation
            Main->>Exec: software-docs-minion + user-docs-minion
            Exec->>Main: Documentation deliverables
        end
        opt 8b: README or user-facing docs produced
            Main->>Exec: product-marketing-minion review
            Exec->>Main: Review feedback
        end
    end

    Note over Main,User: Wrap-up
    Main->>Main: Re-present skipped gates
    Main->>User: Final report + verification summary + open items
```

---

## 2. Delegation Model

The delegation model ensures every piece of work has exactly one primary agent, with clear supporting roles and no overlaps.

### Boundary Enforcement Mechanisms

Four mechanisms enforce strict agent boundaries:

**"Does NOT do" sections.** Every agent's system prompt explicitly lists what it does not handle, with named delegation targets. These create hard boundaries. For example, security-minion does not implement authentication flows -- it delegates to oauth-minion.

**Delegation table.** Nefario's embedded routing table maps task types to primary and supporting agents deterministically. The table covers all six domain groups and eliminates ambiguity in task assignment.

**Handoff triggers.** Specific phrases or request types trigger delegation to named specialists. When an agent encounters work outside its boundary, it names the target agent rather than attempting the work.

**File ownership.** No two agents modify the same file in a single plan. If multiple perspectives are needed on a file, work is sequenced (one agent writes, another reviews) or one agent integrates changes from multiple sources.

### Primary vs. Supporting Agent Roles

**Primary agent**: Owns the deliverable. Performs the core work. Has final decision-making authority within its domain. For REST API design, api-design-minion is primary.

**Supporting agent**: Provides input, reviews from its perspective, handles secondary concerns. Does not own the deliverable. For REST API design, software-docs-minion provides a documentation perspective as supporting.

**Collaboration pattern**: The primary agent produces initial work. Supporting agents review and contribute their specialized perspective. The primary agent integrates feedback and delivers the final output.

### Cross-Cutting Concerns

Every plan is evaluated against a six-dimension checklist. For each dimension, nefario either includes the relevant agent or provides explicit justification for excluding it. Silent omission is not permitted.

| Dimension | Agent | Inclusion Rule |
|-----------|-------|---------------|
| Testing | test-minion | Include unless the task is purely research or design with no executable output |
| Security | security-minion | Include for any task touching auth, APIs, user input, or infrastructure |
| Usability -- Strategy | ux-strategy-minion | ALWAYS include |
| Usability -- Design | ux-design-minion, accessibility-minion | Include when tasks produce user-facing interfaces |
| Documentation | software-docs-minion / user-docs-minion | ALWAYS include |
| Observability | observability-minion, sitespeed-minion | Include for any runtime component; sitespeed-minion for web-facing components |

The checklist applies in all modes (META-PLAN, SYNTHESIS, PLAN). The default is to include; exclusion requires justification.

### Escalation Paths

**To gru**: When strategic technology decisions are needed (adopt/hold/wait framework), protocol evaluation, or technology radar assessment.

**To nefario**: When a single-agent task grows into multi-domain complexity requiring coordination.

**To user**: When priorities are unclear, requirements are ambiguous, specialists disagree after arbitration, or major risks are identified that require human judgment.

---

## 3. Approval Gates

Approval gates pause execution to get user input on a deliverable before downstream work proceeds. The mechanism is designed to gate high-impact decisions without creating approval fatigue.

### Gate Classification

Gates are classified on two dimensions: **reversibility** (how hard is it to undo this decision?) and **blast radius** (how many downstream tasks depend on it).

| | Low Blast Radius (0-1 dependents) | High Blast Radius (2+ dependents) |
|---|---|---|
| **Easy to Reverse** (config, additive code, docs) | NO GATE | OPTIONAL gate |
| **Hard to Reverse** (schema, API contract, architecture, security model) | OPTIONAL gate | MUST gate |

**Supplementary rule**: If a task has dependents AND involves judgment where multiple valid approaches exist (not a clear best-practice situation), gate it regardless of reversibility.

Examples of MUST-gate tasks: database schema design, API contract definition, UX strategy recommendations, security threat model. Examples of no-gate tasks: CSS styling, test file organization, documentation formatting.

### Decision Brief Format

Decision briefs use three layers of progressive disclosure to respect the user's time:

**Layer 1 (5-second scan)**: One-sentence description of the decision.
**Layer 2 (30-second read)**: Rationale with 3-5 bullets, including at least one rejected alternative and the reason it was rejected.
**Layer 3 (deep dive)**: The full deliverable at its file path.

CLI format:

```
APPROVAL GATE: <title>
Agent: <who> | Blocked tasks: <what's waiting>

DECISION: <one sentence>

RATIONALE:
- <point 1>
- <point 2>
- <point 3 -- must include at least one rejected alternative>

IMPACT: <consequences of approving vs. rejecting>
DELIVERABLE: <file path>
Confidence: HIGH | MEDIUM | LOW

Decision points use Claude Code's `AskUserQuestion` tool for structured selection.
```

### Response Handling

Gates present four options via structured prompt:

- **Approve** -- Gate clears. A follow-up prompt offers "Run all" (post-execution phases) or "Skip post-execution". Downstream tasks are unblocked.
- **Request changes** -- A follow-up message asks what changes are needed. The producing agent revises. Capped at 2 revision iterations. If still unsatisfied, the current state is presented with a summary of what was requested, changed, and unresolved. The user then decides to approve as-is, reject, or take over manually.
- **Reject** -- A confirmation prompt shows downstream impact: "Rejecting this will also drop Task X, Task Y which depend on it." After confirmation, the rejected task and all dependents are removed from the plan.
- **Skip** -- Gate deferred. Execution continues with non-dependent tasks. Skipped gates are re-presented at wrap-up. If skipped gates still block downstream tasks at wrap-up, those tasks remain incomplete and are flagged in the final report.

### Anti-Fatigue Rules

Approval fatigue is the primary threat to this mechanism. A fatigued user rubber-stamps everything, which makes gates worse than useless.

**Gate budget.** Target 3-5 gates per plan. If synthesis produces more than 5, nefario consolidates related gates or downgrades low-risk gates to non-blocking notifications. The synthesis output flags when the budget is exceeded.

**Confidence indicator.** Every gate includes HIGH, MEDIUM, or LOW confidence. HIGH means clear best practice (likely quick approve). MEDIUM means reasonable approach but alternatives have merit. LOW means significant uncertainty -- the user should read Layer 2 carefully and may want to inspect Layer 3.

**Rejected alternatives mandatory.** Every gate's Layer 2 rationale must include at least one rejected alternative. This is the primary anti-rubber-stamping measure: it forces the user to consider whether the chosen approach is genuinely better than the alternatives.

**Calibration check.** After 5 consecutive approvals without any "request changes" or "reject" response, nefario presents a calibration prompt via structured choice (neither option marked as recommended, forcing a conscious decision). The response is recorded in nefario's memory to tune future plans.

### Cascading Gates

When a plan has multiple gates with dependencies between them:

- **Dependency order is mandatory.** A gate that depends on an unapproved prior gate is never presented. The downstream deliverable assumes the upstream deliverable is correct.
- **Parallel independent gates are presented sequentially**, ordered by confidence ascending (LOW first, then MEDIUM, then HIGH) so the hardest decisions get the user's freshest attention.
- **Maximum 3 levels of dependent gates.** If a plan has more than 3 levels of sequential gate dependencies, nefario restructures the plan or consolidates gates.

**Gate vs. notification.** Not every important output needs a blocking gate. Non-blocking notifications are used for completed milestones, ADVISE verdicts from architecture review, and intermediate outputs that are informational but do not require approval.

---

## 4. Execution Reports

Every `/nefario` orchestration produces a decision log documenting the agents involved, key decisions, and outcomes. Reports serve three use cases: immediate confirmation ("what just happened?"), future decision reference ("why did we choose X six months ago?"), and process comparison ("are gates being overused?").

### Report Location and Naming

Reports are written to `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>.md`:

- `<YYYY-MM-DD>`: Orchestration date
- `<HHMMSS>`: Local time at report creation, 24-hour format, zero-padded (e.g., `143022` for 2:30:22 PM)
- `<slug>`: Kebab-case task summary derived from the task description (max 40 characters)

Example: `docs/history/nefario-reports/2026-02-09-143022-build-mcp-server-with-oauth.md`

The `docs/history/nefario-reports/` directory is created automatically on first use.

### Report Structure

Reports follow an inverted pyramid: most important information first, progressive detail last. A reader can stop at any section and still have a useful understanding of the orchestration outcome.

- **Summary**: 2-3 sentences covering what happened and why it matters. Enough for a PR reviewer to decide whether to read further.
- **Task**: The verbatim user request (inline blockquote for short prompts, collapsible for long ones). Secrets and credentials are redacted before inclusion.
- **Decisions**: Structured entries for each key choice. Non-gate decisions include rationale and rejected alternatives. Gate decision briefs additionally include outcome and confidence fields. Conflict resolutions between specialists are documented here if any occurred.
- **Agent Contributions**: Collapsible section grouped into Planning (specialist input with adopted recommendations and flagged risks) and Architecture Review (verdicts with proportional detail -- one line for APPROVE, 2-3 lines for ADVISE, 3-4 lines for BLOCK with resolution).
- **Execution**: Files changed table (path, action, description) and approval gates table (title, agent, confidence, outcome, rounds) with enriched briefs for each gate.
- **Process Detail**: Collapsible section containing phases executed (with agents per phase), verification results, timing breakdown, and outstanding items checklist.
- **Metrics**: Reference data table with key numbers (date, duration, outcome, agent counts, gates, files changed, outstanding items).

The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here.

### Index

All reports are cataloged in `docs/history/nefario-reports/index.md`, a table listing date, time, task summary (as a link to the report), outcome, and agent count. The index is a derived view, regenerated by `docs/history/nefario-reports/build-index.sh` from report frontmatter. It provides a chronological view of all orchestration runs for cross-run analysis.

### When Reports Are Generated

Reports are generated at wrap-up, after execution completes but before team cleanup. For long-running orchestrations, a partial report may be written after synthesis (Phase 3) and overwritten with the complete report at wrap-up. Interrupted orchestrations may leave partial reports in place -- these are marked with `outcome: partial` in the frontmatter.

### Report Enforcement

Report generation is enforced by the nefario SKILL.md wrap-up sequence. The wrap-up steps are marked as mandatory and the orchestrator is instructed to never skip or defer the report. This is the same mechanism that enforces all other orchestration steps (synthesis, architecture review, etc.) — the skill instructions govern the process end-to-end.

### Troubleshooting

**Report not generated:**
- Verify the nefario skill is loaded (invoked via `/nefario`)
- Check that `docs/history/nefario-reports/` directory exists and is writable
- Review the conversation for error messages from the Write tool

**Reports generated multiple times:**
- Report generation is governed by the SKILL.md wrap-up sequence, which runs once per orchestration. If duplicates appear, check whether the session was interrupted and restarted mid-wrap-up.
- File an issue if this occurs consistently.

---

## 5. Commit Points in Execution Flow

Execution sessions produce file changes that need version control. Commit checkpoints are integrated into the orchestration flow at natural pause points, so committing work does not introduce separate interruptions.

### Feature Branch Creation

At the start of any session that will modify files, a feature branch is created from HEAD before any edits occur:

- **Orchestrated sessions**: `nefario/<slug>` (e.g., `nefario/build-mcp-server-with-oauth`)
- **Single-agent sessions**: `agent/<agent-name>/<slug>` (e.g., `agent/frontend-minion/fix-header-layout`)

If already on a non-main branch (user-created), the existing branch is used. If the working tree has uncommitted changes, the user is warned before branching.

### Commit Checkpoints and Approval Gates

In orchestrated sessions, commit checkpoints are co-located with approval gates. After the user approves a gate, a commit checkpoint immediately follows, proposing to commit the files changed since the last commit. This reuses the existing "review and decide" pause rather than creating a separate interaction.

```
[Gate approved] --> [Commit checkpoint] --> [Next batch executes]
```

For single-agent sessions, a single commit checkpoint is presented at session end via a Stop hook.

### Commit Budget

The number of commit prompts is bounded:

```
commit_budget = gate_budget + 1
```

For orchestrated sessions with a 3-5 gate budget (Decision 11), this means 4-6 commit checkpoints: one per gate plus one at wrap-up. For single-agent sessions, the budget is 1 (the wrap-up commit).

### The `defer-all` Escape Hatch

At any commit checkpoint, the user can respond `defer-all` to suppress all remaining mid-session commit prompts. Deferred changes accumulate and are presented as a single batch commit at wrap-up. This is the primary anti-fatigue mechanism for users who prefer fewer interactions.

Auto-deferral also applies to trivial changes (Markdown-only edits under 5 lines), which are silently batched into the wrap-up commit.

### PR Creation at Wrap-Up

After the final commit checkpoint, the session offers to create a pull request via `gh pr create`. The PR body is auto-generated from gate summaries (orchestrated) or the agent's completion summary (single-agent). If `gh` CLI is unavailable, the session prints manual push instructions.

### Full Design Reference

The complete commit workflow specification -- including file change tracking, hook composition, safety rails, sensitive file detection, and edge cases -- is documented in [commit-workflow.md](commit-workflow.md). The security assessment covering input validation, fail-closed behavior, and git command safety is at [commit-workflow-security.md](commit-workflow-security.md).
