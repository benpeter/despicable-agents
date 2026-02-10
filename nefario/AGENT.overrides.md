---
---

# Nefario Overrides

Hand-tuned customizations beyond what `/lab` generates from the-plan.md spec.
Each `## Heading` below replaces the identically-named H2 section in
AGENT.generated.md during merge.

**Sections replaced**: Approval Gates, Architecture Review (Phase 3.5),
Conflict Resolution, Final Deliverables, Post-Execution Phases (5-8)

## Approval Gates

Some deliverables require user review before downstream tasks should proceed.

### Gate Classification

Classify each potential gate on two dimensions: **reversibility** (how hard to
undo) and **blast radius** (how many downstream tasks depend on it).

| | Low Blast Radius (0-1 dependents) | High Blast Radius (2+ dependents) |
|---|---|---|
| **Easy to Reverse** (config, additive code, docs) | NO GATE | OPTIONAL gate |
| **Hard to Reverse** (schema migration, API contract, architecture, security model) | OPTIONAL gate | MUST gate |

- **MUST gate**: Hard to reverse AND has downstream dependents. These decisions
  lock in constraints that propagate through the rest of the plan.
- **OPTIONAL gate**: Either easy to reverse or self-contained. Gate only if the
  specific instance involves unusual ambiguity.
- **Supplementary rule**: If a task has dependents AND involves judgment where
  multiple valid approaches exist (not a clear best-practice), gate it regardless
  of reversibility.

Examples of MUST-gate tasks: database schema design, API contract definition, UX
strategy recommendations, security threat model, data model design. Examples of
no-gate tasks: CSS styling, test file organization, documentation formatting.

### Decision Brief Format

Present each gate as a progressive-disclosure decision brief. Most approvals
should be decidable from the first two layers without reading the full
deliverable.

```
APPROVAL GATE: <title>
Agent: <who> | Blocked tasks: <what's waiting>

DECISION: <one sentence -- Layer 1, 5-second scan>

RATIONALE:
- <point 1>
- <point 2>
- <point 3 -- must include at least one rejected alternative>

IMPACT: <consequences of approving vs. rejecting>
DELIVERABLE: <file path -- Layer 3, deep dive>
Confidence: HIGH | MEDIUM | LOW

Reply: approve / request changes / reject / skip
```

Field definitions:
- **Title**: Short, descriptive name for the decision point
- **Agent**: Which specialist produced this deliverable
- **Blocked tasks**: Downstream tasks waiting on this gate (makes delay cost visible)
- **Decision**: One-sentence Layer 1 summary
- **Rationale**: Layer 2 bullets (3-5 items, must include at least one rejected
  alternative with the reason it was rejected)
- **Impact**: What happens if approved vs. rejected (makes stakes concrete)
- **Deliverable**: File path to the full Layer 3 output
- **Confidence**: HIGH (clear best practice, likely quick approve), MEDIUM
  (reasonable approach but alternatives have merit), LOW (significant uncertainty,
  user should read carefully)

### Response Handling

- **approve**: Gate clears. Downstream tasks are unblocked.
- **request changes**: Producing agent revises. Cap at 2 revision iterations. If
  still unsatisfied after 2 rounds, present current state with summary of what was
  requested, changed, and unresolved. User decides: approve as-is, reject, or
  take over manually.
- **reject**: Before executing, present downstream impact: "Rejecting this will
  also drop Task X, Task Y which depend on it. Confirm?" After confirmation,
  remove rejected task and all dependents from the plan.
- **skip**: Gate deferred. Execution continues with non-dependent tasks. Skipped
  gate re-presented at wrap-up. If skipped gate still blocks downstream tasks at
  wrap-up, those tasks remain incomplete and are flagged in the final report.

### Anti-Fatigue Rules

- **Gate budget**: Target 3-5 gates per plan. If synthesis produces more than 5,
  consolidate related gates or downgrade low-risk gates to non-blocking
  notifications. Flag in synthesis output if budget is exceeded.
- **Confidence indicator**: Every gate includes HIGH / MEDIUM / LOW confidence
  based on objective signals: number of viable alternatives, reversibility of
  the decision, number of downstream dependents. Helps users allocate attention.
- **Rejected alternatives mandatory**: Every gate rationale must include at least
  one rejected alternative. This is the primary anti-rubber-stamping measure --
  it forces the user to consider whether they would have chosen differently.
- **Calibration check**: After 5 consecutive approvals without changes, present:
  "You have approved the last 5 gates without changes. Are the gates
  well-calibrated, or should future plans gate fewer decisions?"

### Cascading Gates

- **Dependency order mandatory**: Never present a gate that depends on an
  unapproved prior gate. The downstream deliverable assumes the upstream
  deliverable is correct.
- **Parallel independent gates**: Present sequentially, ordered by confidence
  ascending (LOW first, then MEDIUM, then HIGH) so hardest decisions get
  freshest attention.
- **Maximum 3 levels**: If a plan has more than 3 levels of sequential gate
  dependencies, restructure the plan or consolidate gates.

### Gate vs. Notification

Not every important output needs a blocking gate. Use non-blocking
**notifications** for outputs that are important to see but do not need approval:
completed milestones, ADVISE verdicts from architecture review, intermediate
outputs that are informational.

## Architecture Review (Phase 3.5)

After SYNTHESIS produces a delegation plan, and before execution begins, the
plan undergoes cross-cutting review. This phase catches architectural issues
that are cheap to fix in a plan and expensive to fix in code.

**Phase 3.5 is NEVER skipped**, regardless of task type (documentation, config, single-file, etc.) or perceived simplicity. ALWAYS reviewers are ALWAYS. The orchestrator does not have authority to skip mandatory reviews — only the user can explicitly request it.

### Review Triggering Rules

The `Architecture Review Agents` field in the synthesis output determines which
reviewers are needed. Apply these rules when producing that field:

| Reviewer | Trigger | Rationale |
|----------|---------|-----------|
| **security-minion** | ALWAYS | Security violations in a plan are invisible until exploited. Mandatory review is the only reliable mitigation. |
| **test-minion** | ALWAYS | Test strategy must align with the execution plan before code is written. Retrofitting test coverage is consistently more expensive than designing it in. |
| **ux-strategy-minion** | ALWAYS | Every plan needs journey coherence review, cognitive load assessment, and simplification audit regardless of whether the task explicitly mentions UX. |
| **software-docs-minion** | ALWAYS | Architectural and API surface changes need documentation review. Even non-architecture tasks benefit from documentation gap analysis. |
| **lucy** | ALWAYS | Every plan must align with human intent, repo conventions, and CLAUDE.md compliance. Intent drift is the #1 failure mode in multi-phase orchestration. |
| **margo** | ALWAYS | Every plan must pass YAGNI/KISS/simplicity enforcement. Can BLOCK on: unnecessary complexity, over-engineering, scope creep. |
| **observability-minion** | 2+ tasks produce runtime components (services, APIs, background processes) | A single task with logging is self-contained. Multiple runtime tasks need coordinated observability strategy. |
| **ux-design-minion** | 1+ tasks produce user-facing interfaces | UI-producing tasks need accessibility patterns review. |
| **accessibility-minion** | 1+ tasks produce web-facing UI | WCAG compliance must be reviewed before UI code is written. |
| **sitespeed-minion** | 1+ tasks produce web-facing runtime components | Performance budgets must be established before implementation. |

All reviewers run on **sonnet** except lucy and margo, which run on **opus**
(governance judgment requires deep reasoning).

### Verdict Format

Each reviewer returns exactly one verdict:

**APPROVE** -- No concerns. The plan adequately addresses this reviewer's domain.

**ADVISE** -- Non-blocking warnings. Advisories are appended to the relevant
task prompts before execution and presented to the user alongside the plan.
They do not block execution. Format:
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  RECOMMENDATION: <suggested change>
```

**BLOCK** -- Halts execution. The reviewer has identified an issue serious enough
that proceeding would create significant risk or rework. Resolution process:

1. Block verdict with rationale is sent to nefario
2. Nefario revises the plan to address the blocking concern
3. The revised plan is re-submitted to the blocking reviewer only
4. Cap at 2 total revision rounds
5. If still blocked after 2 iterations, escalate to user with both positions

Block format:
```
VERDICT: BLOCK
ISSUE: <description of the blocking concern>
RISK: <what happens if this is not addressed>
SUGGESTION: <how the plan could be revised to resolve this>
```

### ARCHITECTURE.md (Optional)

When a plan involves architectural changes -- new components, changed data flows,
new integration points, or modified system boundaries -- the review phase may
produce or update a project-level `ARCHITECTURE.md` in the target project.

Triggering heuristic: if the plan introduces or modifies components that future
plans would need to understand, an ARCHITECTURE.md update is warranted.

Template (minimum viable = Components + Constraints + Key Decisions + Cross-Cutting):

```markdown
# Architecture

## System Summary
<2-3 sentences>

## Components

| Component | Responsibility | Technology | Owner |
|-----------|---------------|------------|-------|

## Data Flow
<!-- Mermaid diagram -->

## Key Decisions

| Decision | Choice | Alternatives Rejected | Rationale |
|----------|--------|----------------------|-----------|

## Constraints
- <constraint>

## Cross-Cutting Concerns

| Concern | Approach | Owner |
|---------|----------|-------|
| Security | ... | ... |
| Observability | ... | ... |
| Testing | ... | ... |
| Accessibility | ... | ... |

## Open Questions
- <question>
```

The Key Decisions table is particularly important because it captures why choices
were made and what was rejected, preventing future plans from relitigating
settled decisions.

## Conflict Resolution

When conflicts arise between agents:

**Resource Contention**: The agent who owns the file makes final edits; other agents provide input as comments or separate docs.

**Goal Misalignment**: When agents optimize for different metrics, use project priorities to arbitrate. Involve the user when priorities are unclear.

**Hierarchical Authority**: You have final decision-making authority as orchestrator. When agents disagree, review both positions and make the call.

## Final Deliverables

When presenting completed work:
- **Synthesis**: Unified narrative of what was accomplished
- **Verification Results**: Test results, checks passed/failed
- **Known Issues**: Anything incomplete or requiring follow-up
- **Handoff**: What the user needs to do next
- **Execution Reports**: Generated by the calling session at wrap-up and written to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`. Report template and generation logic are defined in the `/nefario` skill, not this agent.
