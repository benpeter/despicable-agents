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
| **Choice** | Four-tier hierarchy: Boss (gru), Foreman (nefario), Governance (lucy, margo), Minions (23 specialists) |
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
| **Rationale** | Version divergence is the precise signal that an agent is outdated. Avoids unnecessary rebuild churn. `/despicable-lab --check` makes staleness detection trivial. |
| **Consequences** | Manual version bumps required when specs change. Risk of forgetting to bump. Avoids wasted compute on non-spec commits. |

---

## Build Pipeline Enhancement (Decision 9)

### Decision 9: Overlay Files for Agent Build Pipeline

| Field | Value |
|-------|-------|
| **Status** | Superseded by Decision 27 |
| **Date** | 2026-02-09 |
| **Choice** | Introduce a three-file overlay pattern: AGENT.generated.md (pure /despicable-lab output, never hand-edited) + AGENT.overrides.md (optional hand-tuned customizations) merged into AGENT.md (deployed artifact). Merge rules: YAML frontmatter shallow-merges (overrides win), Markdown body replaces entire H2 sections by heading match. `x-fine-tuned: true` injected automatically when overrides exist. |
| **Alternatives rejected** | (1) **Marker-based partial generation** (`<!-- CUSTOM:START/END -->` markers in AGENT.md, /despicable-lab preserves content between them): rejected because fragile HTML comments are easy to accidentally delete, mixes generated and hand-edited content in one file, and requires the generator to parse its own output. (2) **Hooks/customizations directory** (patch files and post-processing scripts per agent): rejected as over-engineered for 19 agents where most have zero customizations; patch files are brittle across regeneration as context lines shift. (3) **Template + data separation** (split into markdown template + YAML data file, render together): rejected because prose-heavy prompts are painful as YAML multiline strings, and the problem is merge preservation, not templating. |
| **Rationale** | The current pipeline destructively overwrites AGENT.md on rebuild. Hand-tuned customizations (demonstrated by nefario's v1.3 refinements) are lost. The overlay pattern preserves customizations across regeneration cycles without polluting the-plan.md with prompt-level details. Familiar pattern (CSS cascading, Kubernetes kustomize, Terraform overrides). |
| **Consequences** | Three files per customized agent (most agents have only two -- generated + deployed, identical). Contributors must learn which file to edit. Merge automation in /despicable-lab is not yet implemented; only nefario has overlay files manually created. Heading renames in the generated output can orphan overrides (mitigated by warning on mismatch). |

---

## Orchestration Enhancements (Decisions 10-13)

These decisions were implemented in the nefario v1.4 update.

### Decision 10: Architecture Review Phase (Phase 3.5)

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Insert a new Architecture Review phase between Synthesis (Phase 3) and Execution (Phase 4). Cross-cutting specialists review the synthesized plan before work begins. Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo) and four conditional reviewers (observability-minion at 2+ runtime tasks, ux-design-minion at 1+ UI tasks, accessibility-minion at 1+ web UI tasks, sitespeed-minion at 1+ web runtime tasks). Structured verdict format: APPROVE / ADVISE (non-blocking) / BLOCK (halts, 2-iteration revision cap, then escalate to user). |
| **Alternatives rejected** | No structured review phase -- rely on cross-cutting checklist during planning only. Rejected because consideration during planning is not the same as review of the synthesized plan. Emergent issues from combining multiple specialists' contributions are only visible after synthesis. |
| **Rationale** | Catches architectural issues that are cheap to fix before execution and expensive to fix after. Security violations in a plan are invisible until exploited. Test strategy must align before code is written. The 2-iteration cap on BLOCK revisions prevents infinite loops while still allowing substantive disagreements to reach human judgment. |
| **Consequences** | Adds $0.10-0.20 per plan (15-30% overhead). Extends planning by 2-5 reviewer spawns. All plans get security and test review regardless of scope. Reduces rework during execution. |

> **Update (2026-02-12)**: ALWAYS reviewer count reduced from 6 to 5. ux-strategy-minion moved to discretionary pool (Phase 3.5 reviewer composition rework, [report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)). Discretionary pool expanded from 4 to 6 members.

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
| **Consequences** | 6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5), increasing minimum review cost. Cleaner separation between UX strategy and UX design responsibilities. Every plan gets documentation review. |

> **Update (2026-02-12)**: ALWAYS reviewer count subsequently reduced from 6 to 5 when ux-strategy-minion moved to discretionary pool ([report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).

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
| **Choice** | Report generation is a SKILL.md responsibility, not a nefario agent mode. The calling session accumulates structured data at phase boundaries and writes a markdown report at wrap-up. Reports use progressive disclosure (header block, executive summary + decisions, process detail) with 10-field YAML frontmatter. Written to `docs/history/nefario-reports/<YYYY-MM-DD>-<NNN>-<slug>.md`. Index maintained at `docs/history/nefario-reports/index.md`. |
| **Alternatives rejected** | (1) **New nefario MODE: REPORT** where nefario generates the report as a subagent: rejected because nefario's modes are stateless single-turn invocations, a report mode would need all phase data passed in, and the calling session already has this data. (2) **Separate template file** (`docs/history/nefario-reports/.template.md`): rejected because it creates a coordination point that must stay in sync with SKILL.md; template is small enough to embed directly. (3) **Continue ad-hoc reports** (like report.md and report-v2.md): rejected because inconsistent structure undermines findability and cross-report comparison. |
| **Rationale** | Reports serve three personas: immediate confirmation (5-second header scan), precedent seeking (findable decisions table), and process comparison (consistent YAML frontmatter). SKILL.md is the right home because it controls the operational workflow. Reporting is operational, not spec-level — no the-plan.md change or version bump needed. |
| **Consequences** | Every `/nefario` run produces a report. Reports accumulate in `docs/history/nefario-reports/`. SKILL.md grows by ~150 lines. Reports tracked in git as decision logs. |
| **Note** | Naming convention (`<NNN>`) superseded by Decision 25 (2026-02-10). Index generation approach unchanged. |

### Decision 15: Phase 3.5 Architecture Review Is Non-Skippable

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-09 |
| **Choice** | Phase 3.5 Architecture Review is never skipped by the orchestrator, regardless of task type (documentation-only, config-only, single-file) or perceived simplicity. ALWAYS reviewers are always invoked. Only the user can explicitly request skipping Phase 3.5. |
| **Alternatives rejected** | **Orchestrator-judged skip** where nefario assesses whether review is warranted based on task type: rejected because the whole point of mandatory review is that the orchestrator should not be the sole judge. SKILL.md changes are "documentation" but drive all future orchestrations — skipping review for them is precisely the wrong call. |
| **Rationale** | The orchestrator skipped Phase 3.5 twice for "documentation-only" tasks, which the user corrected. ALWAYS means ALWAYS — the authority to skip belongs to the user, not the system. The cost of unnecessary review (~$0.10) is trivial compared to the cost of a missed issue in a workflow-controlling file. |
| **Consequences** | Every `/nefario` run incurs review cost (5 ALWAYS + 0-6 discretionary reviewers). No exceptions without explicit user opt-out. Constraint encoded in AGENT.md (overlay mechanism removed per Decision 27). |

---

## Overlay System (Decision 16)

### Decision 16: Validation-Only Approach for Overlay Drift Detection

| Field | Value |
|-------|-------|
| **Status** | Superseded by Decision 27 |
| **Date** | 2026-02-09 |
| **Choice** | Implement drift detection with `validate-overlays.sh` that identifies orphaned overrides, merge staleness, and frontmatter inconsistencies. Manual merge remains the workflow. No automated merge, no LLM-based semantic analysis. |
| **Alternatives rejected** | (1) **LLM-based automated merge**: Parse `AGENT.overrides.md` as natural language instructions, use LLM to apply them to `AGENT.generated.md`. Rejected due to non-determinism (different LLM runs produce different outputs), prompt injection risk (overrides file content is executed as instructions), and opacity (hard to predict/review what merge will produce). (2) **Validation + automated merge**: Add `--fix` mode to auto-merge after detecting drift. Rejected because it couples detection (low-risk, read-only) with modification (high-risk, alters deployed agents). (3) **Description + content hybrid format**: Overlay file contains both descriptions AND literal replacement content. Rejected as "way over the top" complexity for current needs. |
| **Rationale** | The core problem is detection, not automation. Manual merge works -- users requested a safety net to catch mistakes, not a replacement for the merge process. Validation-only keeps the script simple, deterministic, and trustworthy. LLM-based merge introduces non-determinism into a build artifact (AGENT.md), which violates the deterministic build principle. Drift detection runs in 1 second and integrates cleanly into `/despicable-lab --check`. |
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
| **Date** | 2026-02-09 (revised 2026-02-10, 2026-02-11) |
| **Choice** | Auto-commit after gate approvals and at wrap-up -- no interactive commit prompts. Feature branch per session (`nefario/<slug>` for orchestrated, `agent/<name>/<slug>` for single-agent) with PR creation at wrap-up. Branching logistics: pull --rebase before branch creation, stay on feature branch after PR. Two hooks: PostToolUse hook for file change tracking (change ledger), Stop hook for auto-commit and branching. Informational one-line commit log printed for audit trail. Change ledger and safety rails (sensitive file filtering, branch protection) unchanged from original design. |
| **Alternatives rejected** | (1) **git-minion specialist agent**: Deferred (see Decision 19) due to 4-to-1 specialist consensus against; agent count inflation for a workflow integration concern rather than a domain expertise gap. (2) **Separate commit interruptions** (independent of approval gates): Rejected because cognitive load analysis shows folding commits into existing gate pauses is strictly better -- the user is already in "review and decide" mode. (3) **Interactive commit checkpoints with defer-all** (original Decision 18): Superseded because the commit prompt was the wrong interaction point. Gate approval already represents user consent for the work -- adding a separate commit prompt creates interaction overhead without meaningful human judgment. The defer-all escape hatch confirmed that users wanted fewer prompts, not more granular commit control. Auto-commit achieves the same safety properties (ledger-only staging, sensitive file filtering, branch protection) without the interaction cost. |
| **Rationale** | Gate approval IS the consent signal -- separate commit approval is redundant. Commit safety comes from technical rails (change ledger, sensitive file patterns, branch protection), not from human review of a file list. The defer-all pattern in the original design showed users prefer fewer interruptions. Informational commit log preserves the audit trail without requiring interaction. |
| **Consequences** | Two hook scripts to maintain. No interactive commit prompts -- reduced cognitive load. Auto-commit after each gate provides semantic commit granularity. Branching logistics (pull --rebase before branch, stay on feature branch after PR) ensure clean workflow -- developer can continue local testing; final summary includes escape hatch to return to default branch. Informational commit output provides audit trail. Full design: [commit-workflow.md](commit-workflow.md). Security assessment: [commit-workflow-security.md](commit-workflow-security.md). |

### Decision 19: Defer git-minion Creation

| Field | Value |
|-------|-------|
| **Status** | Deferred |
| **Date** | 2026-02-09 |
| **Choice** | Defer git-minion creation. The commit workflow is implemented as hooks and orchestration integration, not as a specialist agent. |
| **Alternatives rejected** | **Create git-minion now** as a specialist for branching strategy, PR workflow, commit hook maintenance, and merge conflict resolution. Rejected based on 4-to-1 specialist consensus: the job-to-be-done is workflow integration (hooks + orchestration), not git domain expertise. Adding an agent inflates the team without a clear expertise gap that existing agents cannot cover. |
| **Rationale** | Hook scripts are infrastructure (devx-minion/iac-minion territory), not a specialist domain. Branching conventions are simple enough to encode in documentation and orchestration prompts. Revisit when concrete demand emerges for deep git expertise -- complex branching strategies, PR workflow automation, or commit hook maintenance that exceeds what infrastructure agents handle. |
| **Consequences** | Git workflow knowledge is distributed across documentation and hook scripts rather than concentrated in a specialist. If git complexity grows, a future decision can introduce git-minion without breaking existing architecture. |

---

## Agent Team Expansion (Decision 20)

### Decision 20: Eight New Agents (19 → 27)

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Expand from 19 to 27 agents by adding 8 new agents: 2 governance agents (lucy, margo) as top-level directories alongside gru/nefario, and 6 new minions (accessibility-minion, seo-minion, sitespeed-minion, api-spec-minion, code-review-minion, product-marketing-minion). Governance agents are ALWAYS reviewers in Phase 3.5. Existing agents updated: api-design-minion (v1.1, boundary narrowed for api-spec-minion handoff), ux-design-minion (v1.1, a11y deep work to accessibility-minion), frontend-minion (v1.1, perf measurement to sitespeed-minion). Nefario updated to v1.5 (expanded roster, delegation table, reviewer table). |
| **Alternatives rejected** | (1) **Fewer agents, broader remits**: Combine accessibility + sitespeed into ux-design-minion; combine api-spec into api-design-minion. Rejected because it violates the strict-boundary principle (Decision 2) and creates agents with too many concerns. (2) **All agents as minions**: Make lucy and margo minions rather than top-level. Rejected because governance agents serve a structurally different role -- they review every plan rather than executing domain work. Top-level directories signal this distinction. |
| **Rationale** | Coverage gaps identified in web quality (no WCAG specialist, no SEO specialist, no performance measurement specialist), API lifecycle (no spec authoring specialist), code quality (no review specialist), product messaging (no marketing specialist), and governance (no intent alignment or simplicity enforcement). Each new agent fills a gap that existing agents explicitly disclaimed in their "Does NOT do" sections. |
| **Consequences** | Agent count increases by 42% (19→27). Build pipeline parallelism increases. Phase 3.5 minimum review cost increases (6 ALWAYS reviewers). Delegation table grows by 35 rows. Three existing agents receive boundary adjustments (minor version bumps). |

> **Update (2026-02-12)**: ALWAYS reviewer count subsequently reduced from 6 to 5 when ux-strategy-minion moved to discretionary pool ([report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).

---

## Context Management (Decision 21)

### Decision 21: Scratch Files and Compaction Checkpoints for Context Overflow Prevention

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Two-pronged approach: (1) Write full phase outputs to scratch files (`nefario/scratch/{slug}/`) and retain only compact inline summaries (~80-120 tokens each) in session context. (2) Prompt the user to run `/compact` at two phase boundaries (after Phase 3 synthesis, after Phase 3.5 review) with pre-built focus parameters and non-nagging decline behavior. |
| **Alternatives rejected** | (1) **Programmatic compaction**: Not possible -- Claude Code does not expose compaction as an API to agents or skills. (2) **Reliance on auto-compaction**: Proven unreliable for preserving structured orchestration state (task lists, phase tracking, agent assignments). Auto-compaction optimizes for conversation continuity, not orchestration recovery. (3) **Compaction between Phase 4 execution batches**: Rejected as too disruptive -- mid-execution compaction risks losing agent tracking and task state during the most critical phase. (4) **Full inline outputs with no scratch files**: The previous approach. Rejected because 6 specialists x 500-2000 tokens accumulates 3000-12000 tokens from Phase 2 alone, pushing context limits by Phase 4. |
| **Rationale** | Context overflow during orchestration causes either truncated agent responses or auto-compaction that loses orchestration state. The scratch file pattern reduces Phase 2 context from ~6000-12000 tokens to ~600 tokens (10x reduction). Phase 3 synthesis and Phase 3.5 reviews read from files (tool calls are invisible to the main session's context window). Compaction checkpoints at information supersession boundaries (where earlier phase data is consumed by the next phase) allow safe context reclamation. The two checkpoints are capped to avoid prompt fatigue. |
| **Consequences** | Session-specific scratch directories under `nefario/scratch/` (gitignored). Two user-facing compaction prompts per orchestration. SKILL.md grows by ~100 lines (scratch convention, compaction protocol). Phase 3 synthesis agent reads from files instead of receiving inline content. Design rationale: [compaction-strategy.md](compaction-strategy.md). |
| **Note** | Scratch file path convention (`nefario/scratch/`) superseded by Decision 26 (2026-02-10). Compaction checkpoint design remains current. |

---

## Post-Execution Phases (Decisions 22-24)

These decisions were made during the nefario v2.0 update, extending orchestration with post-execution quality verification.

### Decision 22: Post-Execution Phases (Phases 5-8)

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Extend orchestration with four post-execution phases: Phase 5 (Code Review), Phase 6 (Test Execution), Phase 7 (Deployment, conditional), Phase 8 (Documentation, conditional). All follow the "dark kitchen" pattern -- run silently, surface only unresolvable issues. |
| **Alternatives rejected** | (1) **Fold into wrap-up sub-steps** (margo): Rejected because the user explicitly requested distinct phases. Wrap-up sub-steps provide less structure and no iteration protocol. (2) **Single "Phase 5: Verification"** (margo merge recommendation): Rejected for the same reason -- user specified four phases, not one. (3) **Mandatory phases** (no conditionality): Rejected per margo -- phases should only run when relevant (code exists, tests exist, deployment requested, docs needed). |
| **Rationale** | Post-execution quality verification catches implementation issues that plan review (Phase 3.5) cannot -- runtime bugs, cross-agent integration mismatches, test failures, documentation gaps. Conditionality and dark kitchen pattern minimize overhead. |
| **Consequences** | Phase count increases from 5 to 9. SKILL.md grows by ~150 lines. Context window pressure increases (mitigated by scratch files). Nefario spec-version bumped to 2.0. |

### Decision 23: Dark Kitchen Communication Pattern for Post-Execution

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Post-execution phases run silently by default. User sees one line at start ("Verifying...") and consolidated results in wrap-up. Only unresolvable BLOCKs surface to user. |
| **Alternatives rejected** | (1) **Per-finding visibility** (code-review-minion): Rejected because it creates engagement loss. Users are psychologically "done" after execution; detailed findings feel like bureaucracy. (2) **Fully silent** (no start line): Rejected because total silence after execution creates anxiety -- users need confirmation that verification is happening. |
| **Rationale** | UX strategy analysis showed post-execution is a "descending arc" -- the exciting work is done. The dark kitchen pattern maintains engagement by treating verification as invisible quality assurance, not another round of review. Findings are still written to scratch files for full traceability. |
| **Consequences** | Users do not interact with Phases 5-8 unless escalation occurs. Scratch files provide audit trail. Wrap-up summary gains a "Verification" section. |

### Decision 24: Autonomous Fix Resolution in Post-Execution

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | BLOCK findings in Phase 5/6 are automatically routed back to the original producing agent for fix. 2-round cap. User only involved if auto-fix fails. Security-severity BLOCKs are an exception: they surface to user before auto-fix. |
| **Alternatives rejected** | (1) **Manual approval per finding**: Rejected because it exceeds the gate budget (3-5 gates) and pushes complexity back to the user. (2) **No fix iteration** (document and proceed): Rejected because known bugs should not be shipped to the user. |
| **Rationale** | Consistent with Phase 3.5 BLOCK resolution pattern (2-round cap, then escalate). Producing agents have the context to fix their own code. Code-review-minion and test-minion validate but do not write application code. |
| **Consequences** | Fix iterations are invisible to the user unless they fail twice or involve security. Producing agents bear the cost of their own rework. 2-round cap prevents infinite loops while allowing substantive fixes. |

---

## Report Naming (Decision 25)

### Decision 25: Report Naming -- Timestamps Replace Sequence Numbers

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Report filenames use `<YYYY-MM-DD>-<HHMMSS>-<slug>.md` instead of `<YYYY-MM-DD>-<NNN>-<slug>.md`. YAML frontmatter uses `time: "HH:MM:SS"` instead of `sequence: NNN`. The index file (`docs/history/nefario-reports/index.md`) is regenerated by `docs/history/nefario-reports/build-index.sh` rather than mutated directly. Supersedes the naming portion of Decision 14. |
| **Alternatives rejected** | (1) **Keep sequence numbers with locking**: rejected because POSIX shell lacks reliable file locking, and the glob-count-increment pattern has a TOCTOU race when multiple sessions run in parallel. (2) **UUID-based filenames**: rejected because UUIDs are not human-readable and do not sort chronologically. (3) **Migrate existing files to new format**: rejected because original creation timestamps are unavailable; fabricating them is worse than handling dual formats in the script. |
| **Rationale** | Parallel nefario sessions (e.g., during team work or concurrent branches) can produce reports simultaneously. The old sequence-number scheme required reading existing files to determine the next number (TOCTOU race) and the index file was mutated in place (merge conflict on concurrent writes). Timestamps are globally unique without coordination. A generated index eliminates the mutable shared state entirely. |
| **Consequences** | Report filenames use timestamps instead of sequence numbers. The `build-index.sh` script must handle both legacy (sequence) and new (time) frontmatter formats. Legacy files (11 existing reports) retain their original names and frontmatter. Decision 14's naming convention description is superseded by this decision. |

---

## Toolkit Portability (Decision 26)

### Decision 26: Decouple Toolkit from Self-Referential Path Assumptions

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-10 |
| **Choice** | Remove hardcoded paths that assume the toolkit operates on itself. Scratch files use `mktemp -d` in `$TMPDIR` with secure creation (`chmod 700`) and wrap-up cleanup. Report directory is detected CWD-relative (check `docs/nefario-reports/` then `docs/history/nefario-reports/`, default to creating `docs/history/nefario-reports/`). Git operations include greenfield guards (graceful skip when no git repo). Default branch is detected dynamically, not hardcoded to `main`. |
| **Alternatives rejected** | (1) **Configuration file** (`.nefario.yml` or similar): rejected as YAGNI -- detection logic handles all known cases without user configuration. (2) **Mode flags** (`--self` vs `--external`): rejected because it leaks implementation detail to the user and creates a maintenance burden. (3) **Fixed paths** (`docs/history/nefario-reports/` always): rejected because it breaks portability for projects that use a different convention. (4) **Environment variable overrides** (`NEFARIO_REPORTS_DIR`): rejected as YAGNI -- no known user needs custom report paths. |
| **Rationale** | The project assumed it would always operate on itself. As a globally-installed toolkit, it must operate on any project. Hardcoded paths to `nefario/scratch/`, `docs/history/nefario-reports/TEMPLATE.md`, and `main` branch created coupling that broke when invoked from other projects. Supersedes the scratch file portions of Decision 21. |
| **Consequences** | Scratch files no longer live in the project tree (moved to `$TMPDIR`). `.gitignore` entries for `nefario/scratch/` removed. Report paths are resolved at runtime. Git operations are safe in repositories without a `main` branch or without git at all. `install.sh` now installs 2 skills (nefario + despicable-prompter). |

---

## Overlay Removal (Decision 27)

### Decision 27: Remove Overlay Mechanism, Hand-Maintain Nefario

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-11 |
| **Supersedes** | Decision 9 (Overlay Files), Decision 16 (Validation-Only Drift Detection) |
| **Choice** | Remove the overlay mechanism entirely. Mark nefario as hand-maintained (`/despicable-lab` skips nefario during rebuilds). Delete all overlay artifacts: `validate-overlays.sh` (659 lines), `AGENT.generated.md`, `AGENT.overrides.md`, `override-format-spec.md` (660 lines), `validate-overlays-spec.md` (400 lines), `tests/` directory (harness + 10 fixtures), overlay documentation sections. Apply the "one-agent rule": do not build infrastructure for a pattern until 2+ agents exhibit the need. |
| **Alternatives rejected** | (1) **Retain overlays** (status quo): ~2,900 lines of infrastructure serving exactly one agent violates YAGNI, KISS, and Lean-and-Mean from the Helix Manifesto. Contributors must learn a complex three-file system used by 1 of 27 agents. (2) **Bake nefario customizations into the-plan.md** (Option A from issue #32): Rejected to preserve spec/prompt separation -- nefario's spec section would grow from ~150 to 400-460 lines, mixing high-level specification with prompt-level engineering detail. (3) **Retain but simplify overlay system** (Option C from issue #32): Still introduces build infrastructure for a single-agent need, violating the one-agent rule. |
| **Rationale** | The overlay mechanism was built for nefario alone. No other agent developed a need for it. Per Helix Manifesto ("Lean and Mean", "YAGNI"), infrastructure should not exist for hypothetical future needs. nefario/AGENT.md is already the fully merged result of generated + overrides -- no content is lost by removing the intermediate files. The "one-agent rule" provides a clear re-introduction trigger: when a second agent needs customization preservation, revisit the mechanism. Until then, nefario is hand-maintained. |
| **Consequences** | **Gained**: Simpler build pipeline (no merge step, no drift detection). ~2,900 lines removed. Reduced contributor learning curve. No bash 4.0+ dependency for drift detection. **Lost**: nefario spec drift goes undetected by tooling (manual vigilance required). Spec changes in the-plan.md must be manually propagated to nefario/AGENT.md. `/despicable-lab` has a special case (skip nefario). Constraints previously encoded in `AGENT.overrides.md` (Decision 15) are now maintained directly in `nefario/AGENT.md`. |

---

## External Skill Integration (Decision 28)

### Decision 28: Prompt-Level External Skill Discovery and Deferral

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-11 |
| **Choice** | Prompt-level external skill discovery using filesystem scanning and content-signal classification. Three-tier precedence (CLAUDE.md > project-local > specificity). Deferred macro-tasks for orchestration skills. |
| **Alternatives rejected** | (1) **Skill registry/manifest**: rejected because filesystem IS the registry (YAGNI). (2) **Mandatory metadata fields on external skills**: rejected because it couples external skills to despicable-agents. (3) **Configurable precedence system**: rejected because one simple heuristic + user override at approval gate is sufficient. |
| **Rationale** | External skills already exist in known directories with SKILL.md frontmatter. Nefario can read and reason about them at planning time without any new infrastructure. Loose coupling preserves both ecosystems' independence. |
| **Consequences** | Nefario's meta-plan phase gains a discovery step. Execution plans can include DEFERRED tasks. Routing accuracy depends on SKILL.md description quality (mitigated by approval gate override). |

---

## Configuration (Decision 29)

### Decision 29: Reject DESPICABLE.md, Adopt CLAUDE.md Section Convention

| Field | Value |
|-------|-------|
| **Status** | Decided |
| **Date** | 2026-02-12 |
| **Choice** | Do not introduce DESPICABLE.md or DESPICABLE.local.md. Consuming projects configure despicable-agents behavior via a `## Despicable Agents` section in their existing CLAUDE.md (public) and CLAUDE.local.md (private). Nefario reads this section via Claude Code's automatic CLAUDE.md loading -- no new discovery logic required. Re-evaluate when 2+ consuming projects demonstrate configuration needs that CLAUDE.md sections cannot serve, or when Claude Code adopts AGENTS.md support (whichever comes first). |
| **Alternatives rejected** | (1) **Dedicated DESPICABLE.md + DESPICABLE.local.md files** for framework-specific config. Rejected because: zero consuming projects exist to demonstrate need (YAGNI); contradicts Decisions 26 (.nefario.yml rejected) and 27 (overlay removal) made within the same week; requires explicit Read calls in agents since Claude Code does not auto-load custom files; creates precedence complexity (4-file hierarchy); industry consolidating toward fewer config files (AGENTS.md standard). (2) **Status quo with no guidance**. Rejected because consuming projects would rediscover configuration patterns inconsistently. |
| **Rationale** | 4 of 5 consulted specialists recommended against DESPICABLE.md. Key factors: CLAUDE.md is auto-loaded by Claude Code (zero infrastructure); the configuration surface is small (few preferences, not a plugin architecture); Decision 5 establishes CLAUDE.md as the canonical project customization surface; the ecosystem is consolidating config files, not proliferating them. The dissenting view (software-docs-minion) valued separation of concerns, but the configuration volume does not justify a dedicated file -- the analogy is Prettier (section in package.json) not ESLint (dedicated file). Lucy additionally identified that any configuration mechanism must protect ALWAYS reviewers (security-minion, test-minion, lucy, margo) from exclusion -- this constraint applies regardless of config surface and should be enforced in nefario. |
| **Consequences** | Consuming projects add a `## Despicable Agents` section to CLAUDE.md for framework preferences. CLAUDE.local.md handles private/local overrides. No new files, discovery logic, or precedence rules needed. Future documentation should include examples of the section convention when external adoption occurs. ALWAYS reviewer protection should be enforced in nefario (separate future task). If AGENTS.md support arrives in Claude Code, the section convention migrates trivially. |

---

## Deferred

- Nefario-gated complexity classification -- revisit after 20+ full-process runs.
- git-minion specialist agent (Decision 19) -- revisit when concrete demand for branching strategy, PR workflow, or commit hook maintenance emerges.
- Automatic context usage monitoring -- revisit if Claude Code exposes context metrics to agents.
