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

## Deferred

Nefario-gated complexity classification -- revisit after 20+ full-process runs.
