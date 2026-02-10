[< Back to Architecture Overview](architecture.md)

# Design Decisions

Decision log for the despicable-agents project. Each entry captures what was decided, what was rejected, and why. Organized chronologically by implementation order.

---

## Core Architecture (Decisions 1-8)

These decisions were made during the initial system design and are implemented across all agents.

### Decision 1: Three-Tier Hierarchy

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Three-tier hierarchy: Boss (gru), Foreman (nefario), Minions (17 specialists) |
| **Alternatives rejected** | Flat peer structure where Claude Code delegates directly to any specialist. Rejected because coordination logic would be duplicated across multiple agents, and there would be no clear owner for multi-agent task decomposition. |
| **Rationale** | Complex tasks need an orchestration layer to decompose and coordinate. Strategic technology decisions need a different perspective than execution. A flat structure creates ambiguity about who coordinates multi-agent tasks. |
| **Consequences** | Enables deterministic task routing and clear separation of concerns. Adds complexity to the delegation flow (user -> nefario -> specialists). Nefario becomes a single point of coordination, which is a bottleneck but also a single source of truth for routing. |

### Decision 2: Strict Non-Overlapping Boundaries

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Enforce strict, non-overlapping boundaries with explicit "Does NOT do" sections in every agent prompt. |
| **Alternatives rejected** | Overlapping capabilities for flexibility. Rejected because it leads to inconsistent delegation, multiple agents attempting the same work, and coordination overhead to resolve conflicts. |
| **Rationale** | Eliminates ambiguity in task routing. Makes the delegation table deterministic. Reduces context window waste by avoiding redundant knowledge across agents. |
| **Consequences** | Requires more precise task decomposition and more handoffs between agents. Every piece of work has exactly one primary agent. Forces clear handoff triggers (e.g., "Is this secure?" always routes to security-minion). |

### Decision 3: Separate RESEARCH.md and AGENT.md

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Two files per agent: RESEARCH.md (comprehensive domain research, not deployed) and AGENT.md (dense actionable system prompt, deployed via symlink). |
| **Alternatives rejected** | Single file containing both research and system prompt. Rejected because system prompts would exceed optimal context window size and include noise that dilutes the actionable content. |
| **Rationale** | RESEARCH.md can be comprehensive without bloating the deployed prompt. System prompts stay dense and actionable. Research is reusable for future refinements without re-searching. Clear separation between reference material and deployed artifact. |
| **Consequences** | Two files to maintain per agent. Build pipeline must distill research into prompt. Research can become stale independently of the prompt. |

### Decision 4: Sonnet for Research, Per-Spec Model for Build

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Use sonnet for the research step (web search + summarization). Use the agent-specific model (opus or sonnet, as declared in the-plan.md) for the build step. |
| **Alternatives rejected** | Opus for all steps: rejected due to cost (19 parallel web searches). Sonnet for all steps: rejected because strategic agent build quality suffered measurably. |
| **Rationale** | Research is web search and summarization, not deep reasoning -- sonnet is sufficient. Build step quality directly impacts agent effectiveness, warranting opus for strategic agents (gru, debugger, ai-modeling, security). Cost optimization for the expensive parallel research phase. |
| **Consequences** | Two-step sequential pipeline per agent. Cost-effective without sacrificing build quality for agents that need it. Creates a model-tier distinction that must be maintained in the-plan.md specs. |

### Decision 5: User-Scope Memory

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | All agents use `memory: user` (persists across all projects for that user) rather than project-scoped memory. |
| **Alternatives rejected** | Project-scope memory. Rejected because it couples agents to specific projects, violating the "generic domain specialists" design principle. Agents would accumulate project-specific knowledge that conflicts across projects. |
| **Rationale** | Domain expertise is reusable across projects. Agents learn patterns that apply broadly. Project-specific context belongs in the target project's CLAUDE.md, not in agent memory. |
| **Consequences** | Agents cannot retain project-specific details between sessions. Keeps agents generic and publishable. All project customization must flow through CLAUDE.md or CLAUDE.local.md. |

### Decision 6: Centralized Delegation Table in Nefario

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Centralize the task-to-agent mapping in nefario's delegation table rather than distributing routing logic across individual agents. |
| **Alternatives rejected** | Per-agent routing where each agent knows how to route related tasks. Rejected because it creates circular delegation risks, inconsistent routing decisions, and no single place to verify full coverage. |
| **Rationale** | Single source of truth for task routing. Easier to maintain and update. Prevents inconsistent routing. Enables nefario to identify coverage gaps (tasks with no primary agent). |
| **Consequences** | Nefario's system prompt is larger (carries the full table). All routing changes require updating nefario. Deterministic and auditable routing. |

### Decision 7: Symlink Deployment

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Deploy agents to `~/.claude/agents/` via symlinks pointing to AGENT.md files in the repository. |
| **Alternatives rejected** | Copy AGENT.md files to `~/.claude/agents/`. Rejected because it requires manual re-copy after every edit and creates a second source of truth that can drift. |
| **Rationale** | Edits are immediately live without redeployment. Single source of truth in the repository. Full version control via Git. Easy rollback with `git checkout`. |
| **Consequences** | Repository must remain in place on disk (cannot delete the checkout). Symlinks break if the repo moves. Development workflow is dramatically faster -- edit, save, test immediately. |

### Decision 8: Version-Triggered Rebuild

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-01-01 |
| **Choice** | Use spec-version divergence (spec-version in the-plan.md vs. x-plan-version in AGENT.md) to trigger rebuilds. Do not rebuild on every commit. |
| **Alternatives rejected** | Rebuild on every commit to the-plan.md. Rejected because most commits do not change agent specs (documentation, tooling changes), and rebuilds are expensive (19 parallel research + build pipelines). |
| **Rationale** | Version divergence is the precise signal that an agent is outdated. Avoids unnecessary rebuild churn. `/lab --check` makes staleness detection trivial. |
| **Consequences** | Manual version bumps required when specs change. Risk of forgetting to bump. Avoids wasted compute on non-spec commits. |

---

## Build Pipeline Enhancement (Decision 9)

### Decision 9: Overlay Files for Agent Build Pipeline

| Field | Value |
|-------|-------|
| **Status** | Partially implemented |
| **Date** | 2026-02-09 |
| **Choice** | Introduce a three-file overlay pattern: AGENT.generated.md (pure /lab output, never hand-edited) + AGENT.overrides.md (optional hand-tuned customizations) merged into AGENT.md (deployed artifact). Merge rules: YAML frontmatter shallow-merges (overrides win), Markdown body replaces entire H2 sections by heading match. `x-fine-tuned: true` injected automatically when overrides exist. |
| **Alternatives rejected** | (1) **Marker-based partial generation** (`<!-- CUSTOM:START/END -->` markers in AGENT.md, /lab preserves content between them): rejected because fragile HTML comments are easy to accidentally delete, mixes generated and hand-edited content in one file, and requires the generator to parse its own output. (2) **Hooks/customizations directory** (patch files and post-processing scripts per agent): rejected as over-engineered for 19 agents where most have zero customizations; patch files are brittle across regeneration as context lines shift. (3) **Template + data separation** (split into markdown template + YAML data file, render together): rejected because prose-heavy prompts are painful as YAML multiline strings, and the problem is merge preservation, not templating. |
| **Rationale** | The current pipeline destructively overwrites AGENT.md on rebuild. Hand-tuned customizations (demonstrated by nefario's v1.3 refinements) are lost. The overlay pattern preserves customizations across regeneration cycles without polluting the-plan.md with prompt-level details. Familiar pattern (CSS cascading, Kubernetes kustomize, Terraform overrides). |
| **Consequences** | Three files per customized agent (most agents have only two -- generated + deployed, identical). Contributors must learn which file to edit. Merge automation in /lab is not yet implemented; only nefario has overlay files manually created. Heading renames in the generated output can orphan overrides (mitigated by warning on mismatch). |

---

## Orchestration Enhancements (Decisions 10-13)

These decisions were implemented in the nefario v1.4 update.

### Decision 10: Architecture Review Phase (Phase 3.5)

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Insert a new Architecture Review phase between Synthesis (Phase 3) and Execution (Phase 4). Cross-cutting specialists review the synthesized plan before work begins. Four ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion) and two conditional reviewers (observability-minion at 2+ runtime tasks, ux-design-minion at 1+ UI tasks). Structured verdict format: APPROVE / ADVISE (non-blocking) / BLOCK (halts, 2-iteration revision cap, then escalate to user). |
| **Alternatives rejected** | No structured review phase -- rely on cross-cutting checklist during planning only. Rejected because consideration during planning is not the same as review of the synthesized plan. Emergent issues from combining multiple specialists' contributions are only visible after synthesis. |
| **Rationale** | Catches architectural issues that are cheap to fix before execution and expensive to fix after. Security violations in a plan are invisible until exploited. Test strategy must align before code is written. The 2-iteration cap on BLOCK revisions prevents infinite loops while still allowing substantive disagreements to reach human judgment. |
| **Consequences** | Adds $0.10-0.20 per plan (15-30% overhead). Extends planning by 2-5 reviewer spawns. All plans get security and test review regardless of scope. Reduces rework during execution. |

### Decision 11: Approval Gate Classification

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Classify approval gates on two dimensions: reversibility (easy/hard to undo) and blast radius (0-1 vs. 2+ downstream dependents). Matrix: hard-to-reverse + high-blast-radius = MUST gate; all other combinations = OPTIONAL or NO gate. Supplementary rule: judgment calls with downstream dependents are always gated. Progressive disclosure decision briefs (5-second scan / 30-second read / full deliverable). 3-5 gate budget per plan. Confidence indicator (HIGH/MEDIUM/LOW). Calibration check after 5 consecutive approvals. |
| **Alternatives rejected** | Binary gate flag (approval_gate: true/false) with no classification guidance. This was the previous state. Rejected because it provided no guidance on which tasks to gate, leading to either over-gating (fatigue) or under-gating (missed review of critical decisions). |
| **Rationale** | Approval fatigue is the primary threat -- a fatigued user rubber-stamps everything, making gates worse than useless. The reversibility x blast radius matrix focuses gates on decisions that are both hard to undo and have downstream propagation. Progressive disclosure respects user time. Rejected alternatives in Layer 2 are the strongest anti-rubber-stamping lever. |
| **Consequences** | More structured gate presentation. 3-5 gate budget constrains plan complexity. Calibration feedback loop tunes gate frequency over time. Rejected alternatives must be included in every decision brief, adding work for producing agents. |

### Decision 12: Six-Dimension Cross-Cutting Checklist

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Expand the cross-cutting checklist from 5 to 6 dimensions by splitting "Accessibility" into two: "Usability -- Strategy" (ux-strategy-minion, ALWAYS: journey coherence, cognitive load, simplification audit) and "Usability -- Design" (ux-design-minion, conditional at 1+ UI tasks: accessibility, visual hierarchy, interaction patterns). Promote "Documentation" (software-docs-minion) to ALWAYS. |
| **Alternatives rejected** | Both UX agents as ALWAYS reviewers (proposed by ux-strategy-minion). Rejected for ux-design-minion because many plans have no UI component, and design review of non-UI plans adds cost without value. The strategy/design split gives clear non-overlapping boundaries: WHAT/WHY (strategy) vs. HOW (design). |
| **Rationale** | The previous "Accessibility" dimension conflated strategic usability concerns (journey coherence, cognitive load) with tactical design concerns (visual hierarchy, interaction patterns). These require different expertise and different trigger conditions. Documentation promoted to ALWAYS because even non-architecture tasks benefit from documentation gap analysis. |
| **Consequences** | 4 ALWAYS reviewers instead of 2, increasing minimum review cost. Cleaner separation between UX strategy and UX design responsibilities. Every plan gets documentation review. |

### Decision 13: MODE: PLAN Restricted to User-Explicit-Only

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Nefario's MODE: PLAN shortcut (skip specialist consultation, go directly to plan output) is restricted to user-explicit invocation only. Nefario does not autonomously classify tasks as "simple enough" to skip the full five-phase process. |
| **Alternatives rejected** | Nefario-gated complexity classification where nefario assesses task complexity (simple/standard/complex) and routes accordingly. Deferred, not rejected. See Deferred section. |
| **Rationale** | The full process needs enough runs to establish baseline quality before shortcuts are introduced. Misclassifying a complex task as simple skips critical planning steps -- the cost of a false "simple" (missed security review, inadequate test strategy) far exceeds the cost of over-planning a genuinely simple task. Every full-process run generates data for future evidence-based classification rules. |
| **Consequences** | Every nefario invocation runs the full five-phase process unless the user explicitly requests MODE: PLAN. Higher per-task cost. Consistent quality baseline. Accumulates data for future simplification. |

---

## Reporting (Decision 14)

### Decision 14: Execution Report Generation

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Report generation is a SKILL.md responsibility, not a nefario agent mode. The calling session accumulates structured data at phase boundaries and writes a markdown report at wrap-up. Reports use progressive disclosure (header block, executive summary + decisions, process detail) with 10-field YAML frontmatter. Written to `nefario/reports/<YYYY-MM-DD>-<NNN>-<slug>.md`. Index maintained at `nefario/reports/index.md`. |
| **Alternatives rejected** | (1) **New nefario MODE: REPORT** where nefario generates the report as a subagent: rejected because nefario's modes are stateless single-turn invocations, a report mode would need all phase data passed in, and the calling session already has this data. (2) **Separate template file** (`nefario/reports/.template.md`): rejected because it creates a coordination point that must stay in sync with SKILL.md; template is small enough to embed directly. (3) **Continue ad-hoc reports** (like report.md and report-v2.md): rejected because inconsistent structure undermines findability and cross-report comparison. |
| **Rationale** | Reports serve three personas: immediate confirmation (5-second header scan), precedent seeking (findable decisions table), and process comparison (consistent YAML frontmatter). SKILL.md is the right home because it controls the operational workflow. Reporting is operational, not spec-level — no the-plan.md change or version bump needed. |
| **Consequences** | Every `/nefario` run produces a report. Reports accumulate in `nefario/reports/`. SKILL.md grows by ~150 lines. Reports tracked in git as decision logs. |

### Decision 15: Phase 3.5 Architecture Review Is Non-Skippable

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Phase 3.5 Architecture Review is never skipped by the orchestrator, regardless of task type (documentation-only, config-only, single-file) or perceived simplicity. ALWAYS reviewers are always invoked. Only the user can explicitly request skipping Phase 3.5. |
| **Alternatives rejected** | **Orchestrator-judged skip** where nefario assesses whether review is warranted based on task type: rejected because the whole point of mandatory review is that the orchestrator should not be the sole judge. SKILL.md changes are "documentation" but drive all future orchestrations — skipping review for them is precisely the wrong call. |
| **Rationale** | The orchestrator skipped Phase 3.5 twice for "documentation-only" tasks, which the user corrected. ALWAYS means ALWAYS — the authority to skip belongs to the user, not the system. The cost of unnecessary review (~$0.10) is trivial compared to the cost of a missed issue in a workflow-controlling file. |
| **Consequences** | Every `/nefario` run incurs review cost (4 ALWAYS + 0-2 conditional reviewers). No exceptions without explicit user opt-out. Constraint encoded in AGENT.overrides.md and AGENT.md. |

---

## Overlay System (Decision 16)

### Decision 16: Validation-Only Approach for Overlay Drift Detection

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Implement drift detection with `validate-overlays.sh` that identifies orphaned overrides, merge staleness, and frontmatter inconsistencies. Manual merge remains the workflow. No automated merge, no LLM-based semantic analysis. |
| **Alternatives rejected** | (1) **LLM-based automated merge**: Parse `AGENT.overrides.md` as natural language instructions, use LLM to apply them to `AGENT.generated.md`. Rejected due to non-determinism (different LLM runs produce different outputs), prompt injection risk (overrides file content is executed as instructions), and opacity (hard to predict/review what merge will produce). (2) **Validation + automated merge**: Add `--fix` mode to auto-merge after detecting drift. Rejected because it couples detection (low-risk, read-only) with modification (high-risk, alters deployed agents). (3) **Description + content hybrid format**: Overlay file contains both descriptions AND literal replacement content. Rejected as "way over the top" complexity for current needs. |
| **Rationale** | The core problem is detection, not automation. Manual merge works -- users requested a safety net to catch mistakes, not a replacement for the merge process. Validation-only keeps the script simple, deterministic, and trustworthy. LLM-based merge introduces non-determinism into a build artifact (AGENT.md), which violates the deterministic build principle. Drift detection runs in 1 second and integrates cleanly into `/lab --check`. |
| **Consequences** | Drift detection catches orphaned sections (removed from spec but still in overrides), stale merges (manual edit in AGENT.md), and frontmatter errors. Merge remains manual for agents with overrides (currently only nefario). Script requires bash 4.0+ (macOS users: `brew install bash`). Test infrastructure (10 fixtures, test harness) exists but requires redesign to match script architecture. |

---

## Reporting Automation (Decision 17)

### Decision 17: Report Generation Enforcement

| Field | Value |
|-------|-------|
| **Status** | Revised |
| **Date** | 2026-02-09 |
| **Choice** | Enforce report generation via mandatory wrap-up instructions in the nefario SKILL.md. The wrap-up sequence is marked as mandatory and non-skippable, using the same enforcement mechanism as all other orchestration phases. |
| **Alternatives rejected** | (1) **Stop hook with transcript scanning** (`.claude/hooks/nefario-report-check.sh`): Originally implemented, then removed. The hook fired on every Stop event in the project, was noisy in non-orchestration sessions, and triggered false positives when nefario files were edited outside orchestration. The hook's value as a safety net did not justify its noise and maintenance cost. (2) **SessionEnd hook with marker file**: Rejected because SessionEnd hooks cannot instruct Claude directly. (3) **Manual reporting only**: Rejected because reports were inconsistently generated. |
| **Rationale** | The SKILL.md wrap-up instructions are loaded when `/nefario` is invoked and govern the entire session flow. Report generation is step 3-4 of a 10-step wrap-up sequence. The same mechanism reliably enforces all other steps (synthesis, architecture review, team cleanup). A separate hook added complexity without adding reliability — the hook could only detect orchestration, not enforce the full wrap-up. |
| **Consequences** | Simpler hook configuration (one fewer Stop hook). No transcript scanning overhead on session exit. Report generation depends on the SKILL.md being loaded (i.e., `/nefario` invocation). Sessions that perform ad-hoc orchestration without `/nefario` will not auto-generate reports — this is an acceptable trade-off since such sessions are rare and can generate reports manually. |

---

## Git Workflow Integration (Decision 18)

### Decision 18: Hook-Based Commit Workflow (Revised: Auto-Commit)

| Field | Value |
|-------|-------|
| **Status** | Revised |
| **Date** | 2026-02-09 (revised 2026-02-10) |
| **Choice** | Auto-commit after gate approvals and at wrap-up -- no interactive commit prompts. Feature branch per session (`nefario/<slug>` for orchestrated, `agent/<name>/<slug>` for single-agent) with PR creation at wrap-up. Branching logistics: pull --rebase before branch creation, return to main after PR. Two hooks: PostToolUse hook for file change tracking (change ledger), Stop hook for auto-commit and branching. Informational one-line commit log printed for audit trail. Change ledger and safety rails (sensitive file filtering, branch protection) unchanged from original design. |
| **Alternatives rejected** | (1) **git-minion specialist agent**: Deferred (see Decision 19) due to 4-to-1 specialist consensus against; agent count inflation for a workflow integration concern rather than a domain expertise gap. (2) **Separate commit interruptions** (independent of approval gates): Rejected because cognitive load analysis shows folding commits into existing gate pauses is strictly better -- the user is already in "review and decide" mode. (3) **Interactive commit checkpoints with defer-all** (original Decision 18): Superseded because the commit prompt was the wrong interaction point. Gate approval already represents user consent for the work -- adding a separate commit prompt creates interaction overhead without meaningful human judgment. The defer-all escape hatch confirmed that users wanted fewer prompts, not more granular commit control. Auto-commit achieves the same safety properties (ledger-only staging, sensitive file filtering, branch protection) without the interaction cost. |
| **Rationale** | Gate approval IS the consent signal -- separate commit approval is redundant. Commit safety comes from technical rails (change ledger, sensitive file patterns, branch protection), not from human review of a file list. The defer-all pattern in the original design showed users prefer fewer interruptions. Informational commit log preserves the audit trail without requiring interaction. |
| **Consequences** | Two hook scripts to maintain. No interactive commit prompts -- reduced cognitive load. Auto-commit after each gate provides semantic commit granularity. Branching logistics (pull --rebase before branch, return to main after PR) ensure clean workflow. Informational commit output provides audit trail. Full design: [commit-workflow.md](commit-workflow.md). Security assessment: [commit-workflow-security.md](commit-workflow-security.md). |

### Decision 19: Defer git-minion Creation

| Field | Value |
|-------|-------|
| **Status** | Deferred |
| **Date** | 2026-02-09 |
| **Choice** | Defer git-minion creation. The commit workflow is implemented as hooks and orchestration integration, not as a specialist agent. |
| **Alternatives rejected** | **Create git-minion now** as a specialist for branching strategy, PR workflow, commit hook maintenance, and merge conflict resolution. Rejected based on 4-to-1 specialist consensus: the job-to-be-done is workflow integration (hooks + orchestration), not git domain expertise. Adding an agent inflates the team without a clear expertise gap that existing agents cannot cover. |
| **Rationale** | Hook scripts are infrastructure (devx-minion/iac-minion territory), not a specialist domain. Branching conventions are simple enough to encode in documentation and orchestration prompts. Revisit when concrete demand emerges for deep git expertise -- complex branching strategies, PR workflow automation, or commit hook maintenance that exceeds what infrastructure agents handle. |
| **Consequences** | Agent count stays at 19. Git workflow knowledge is distributed across documentation and hook scripts rather than concentrated in a specialist. If git complexity grows, a future decision can introduce git-minion without breaking existing architecture. |

---

## Deferred

- Nefario-gated complexity classification -- revisit after 20+ full-process runs.
- git-minion specialist agent (Decision 19) -- revisit when concrete demand for branching strategy, PR workflow, or commit hook maintenance emerges.
