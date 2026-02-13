# Meta-Plan: Fix Serverless Infrastructure Bias (Revised)

## Summary

The agent system has a structural bias against serverless infrastructure.
Three compounding gaps -- iac-minion's zero serverless knowledge, margo's
novelty-penalizing complexity budget, and the delegation table's missing
serverless routing -- combine to produce Docker+Terraform recommendations
for projects where `vercel deploy` would suffice.

The fix is four coordinated spec changes in `the-plan.md`, followed by
`/despicable-lab` rebuilds for affected agents. No new agents, no direct
AGENT.md edits.

## Team Adjustment Summary

Original 6-agent team: iac-minion, margo, edge-minion, devx-minion,
ai-modeling-minion, software-docs-minion.

Revised 5-agent team: **margo, edge-minion, devx-minion, ai-modeling-minion,
lucy**. Removed iac-minion and software-docs-minion. Added lucy.

Key implications of the adjustment:
- **iac-minion removed from planning**: iac-minion is the primary agent being
  *modified* but is not consulted for planning. Its spec expansion will be
  informed by edge-minion (who shares deployment platform territory),
  ai-modeling-minion (prompt design for the new decision framework), and lucy
  (governance alignment of the spec changes). The risk of missing iac-minion's
  self-assessment is mitigated by edge-minion's operational knowledge of
  serverless platforms and the existing iac-minion spec providing baseline
  context.
- **software-docs-minion removed**: lucy absorbs the consistency-checking
  role -- verifying that the spec changes and any documentation artifacts
  conform to repo conventions and existing patterns. Documentation updates
  will still be handled in Phase 8 post-execution.
- **lucy added**: Brings governance alignment, repo convention enforcement,
  and intent-drift detection. Particularly valuable for ensuring the spec
  changes faithfully address the issue without overcorrecting or drifting
  into prescriptive territory.
- **Precedence note**: Edge-minion's domain perspective takes priority over
  devx-minion when they conflict on deployment strategy boundaries (per user
  directive).

## Planning Consultations

### Consultation 1: margo -- complexity budget recalibration

- **Agent**: margo
- **Model**: opus
- **Planning question**: How should margo's complexity budget and boring
  technology framework be recalibrated to account for operational burden?
  Specifically: (a) The current complexity budget scores "New technology:
  10 points" and "New service: 5 points" -- but a managed/serverless
  platform eliminates the ops burden that justifies those costs. How should
  managed services that eliminate deployment, monitoring, and scaling work
  score relative to self-managed infrastructure? What scoring model preserves
  the spirit of the budget (penalizing genuine complexity) while recognizing
  that operational simplicity IS simplicity? (b) Which serverless platforms
  qualify as "boring technology" by margo's own stated criteria (production
  hardened, known failure modes, staffable talent, community docs)? Vercel,
  Cloudflare Pages, and AWS Lambda have 5-10+ years of production track
  records -- should they graduate from "new technology" (10 points) to
  effectively zero marginal cost? (c) How should "infrastructure
  over-engineering detection" work as a review heuristic -- what signals
  indicate a project has more infrastructure than it needs, without making
  margo prescriptive about topology? (d) The issue explicitly says "do NOT
  make margo block self-hosted proposals." How do you frame the recalibration
  so margo can flag disproportionate complexity without vetoing legitimate
  infrastructure choices?
- **Context to provide**: Current margo spec from `the-plan.md` (lines
  537-570), current margo AGENT.md sections on Complexity Budget (lines 53-62)
  and Boring Technology (lines 171+), the issue's Gap 2 analysis, the boundary
  clarification that margo detects disproportionate complexity but does NOT
  prescribe serverless, and the "What NOT to do" section (do NOT make margo
  block self-hosted proposals).
- **Why this agent**: Margo is the agent whose complexity scoring is being
  recalibrated. Its expertise in simplicity enforcement ensures the new
  scoring model is internally consistent with existing principles. Margo
  needs to validate that the changes do not make it prescriptive about
  technology choices -- it enforces simplicity, not topology. No other agent
  on the team has this self-assessment capability for margo's spec.

### Consultation 2: edge-minion -- serverless platform boundaries and iac-minion spec input

- **Agent**: edge-minion
- **Model**: opus
- **Planning question**: Edge-minion has the deepest operational knowledge of
  serverless deployment platforms on this team, which makes its input critical
  for shaping the iac-minion spec expansion (even though iac-minion is not
  being consulted). Four questions: (a) **Boundary with iac-minion**: When
  iac-minion gains serverless knowledge, where should the line be between
  iac-minion's responsibility (deployment strategy selection, platform choice,
  serverless cost modeling) and edge-minion's responsibility (platform-specific
  implementation patterns, Workers runtime, Pages config, edge storage)? If a
  user deploys a full app on Cloudflare Pages with Workers functions, which
  agent owns what? (b) **Full-stack serverless framing**: The issue notes
  edge-minion should acknowledge Cloudflare Workers/Pages as a full-stack
  serverless platform, not only CDN compute. Does edge-minion's current spec
  and research already cover this sufficiently, or does the spec need explicit
  acknowledgment? What about Vercel (Next.js deployment), Netlify, and similar
  platforms -- should edge-minion's "Does NOT do" or "Remit" mention these to
  clarify boundaries? (c) **iac-minion's decision framework**: From
  edge-minion's operational experience, what criteria actually determine when
  serverless is the right deployment choice vs. container-based infrastructure?
  What are the real escalation triggers -- request volume, execution duration,
  cold start sensitivity, data locality, stateful workloads -- that would
  signal a project has outgrown serverless? (d) **Delegation table routing**:
  The issue proposes new rows for "Deployment strategy selection" and
  "Serverless platform deployment." From edge-minion's perspective, are these
  the right task-type names, and is the primary/supporting split correct
  (iac-minion primary, edge-minion + devx-minion supporting)?
- **Context to provide**: Current edge-minion spec from `the-plan.md` (lines
  751-784), current iac-minion spec from `the-plan.md` (lines 722-749), the
  proposed delegation table additions from the issue, and the boundary
  clarification that edge-minion's opinions weigh stronger than devx-minion
  on deployment strategy boundaries.
- **Why this agent**: Edge-minion is the team's primary source of operational
  knowledge about serverless platforms (Cloudflare Workers/Pages, edge
  deployment patterns). With iac-minion removed from planning, edge-minion's
  input is essential for grounding the iac-minion spec expansion in
  operational reality. Edge-minion also needs to validate its own boundary
  with the expanded iac-minion to prevent routing confusion, and its domain
  overlaps with several serverless platforms. Per user directive, edge-minion's
  perspective takes priority over devx-minion on deployment strategy.

### Consultation 3: devx-minion -- developer workflow and CLAUDE.md template

- **Agent**: devx-minion
- **Model**: opus
- **Planning question**: devx-minion brings the developer experience
  perspective -- how the deployment strategy choice affects the humans using
  the agent system. Three questions, scoped to avoid overlap with edge-minion's
  platform expertise: (a) **Developer workflow impact**: When the agent team
  recommends a deployment strategy, what DX dimensions matter? Time-to-deploy,
  local development experience, CI/CD simplicity, debugging and logs access,
  rollback ease? Which of these are systematically better with serverless vs.
  self-managed, and which are platform-dependent? (b) **CLAUDE.md template
  design**: The issue's solution item #4 proposes a CLAUDE.md template for
  target projects that lets users declare deployment preferences. From a
  developer experience perspective, what should this template look like? What
  fields or sections help a user communicate their infrastructure context
  clearly to the agent team (e.g., "We deploy on Vercel," "We use Docker
  Compose," "No infra preference -- keep it simple")? What format follows
  existing CLAUDE.md conventions? (c) **Sensible defaults**: The template
  should embody "sensible defaults, progressive complexity" (devx-minion's
  own principle). What is the right default for a project with NO deployment
  preference stated -- should the agents assume simplest-viable (serverless)
  or ask? Note: defer to edge-minion's perspective on which platforms qualify
  as "simplest" -- devx-minion's input here is about the template design and
  default-selection UX, not platform ranking.
- **Context to provide**: Current devx-minion spec from `the-plan.md` (lines
  973-1011), the issue's solution item #4 (CLAUDE.md template), example
  CLAUDE.md files from this project and user's global CLAUDE.md for format
  conventions, and the precedence note that edge-minion's platform opinions
  outweigh devx-minion's on deployment strategy.
- **Why this agent**: devx-minion owns developer onboarding and configuration
  file design. The CLAUDE.md template is fundamentally a configuration artifact
  for developer teams. devx-minion's "sensible defaults, progressive
  complexity" principle directly applies to how deployment preferences should
  be expressed. No other agent on the team has this DX expertise. Questions
  are scoped to avoid treading into edge-minion's platform territory.

### Consultation 4: ai-modeling-minion -- prompt engineering for behavioral spec changes

- **Agent**: ai-modeling-minion
- **Model**: opus
- **Planning question**: The changes require modifying agent behavior through
  spec changes that `/despicable-lab` will convert into system prompts. This
  is fundamentally a prompt engineering challenge. Four questions: (a) **Decision
  framework encoding**: iac-minion needs a deployment strategy selection
  framework (serverless vs. container vs. self-managed) in its system prompt.
  How should decision trees be structured in agent system prompts so they are
  followed reliably? What patterns prevent the agent from ignoring the
  framework or applying it rigidly? (b) **Opposite-bias prevention**: The issue
  explicitly warns "do NOT hardcode serverless-first." How should the prompt
  guard against swinging from always-infrastructure to always-serverless? What
  prompt engineering techniques balance between two valid options without
  creating a default bias toward either? (c) **Complexity scoring in prompts**:
  Margo's complexity budget is being recalibrated to score operational burden.
  How do you encode nuanced scoring heuristics (not just numbers) in a system
  prompt so the agent applies them consistently across different contexts?
  (d) **Cross-agent coherence**: When iac-minion and margo both get updated
  specs, their behaviors need to be complementary (iac-minion selects strategy,
  margo validates complexity). How should the prompt framing ensure these two
  agents reinforce rather than contradict each other?
- **Context to provide**: Current iac-minion and margo specs from `the-plan.md`,
  the build pipeline documentation (`docs/build-pipeline.md`), the system
  prompt structure from `the-plan.md` (lines 66-74), the issue's "What NOT
  to do" section (especially "do NOT hardcode serverless-first in AGENT.md"),
  and the current AGENT.md files for both iac-minion and margo (to understand
  how specs translate to built prompts).
- **Why this agent**: ai-modeling-minion is the prompt engineering specialist.
  No other agent on the team has expertise in how system prompt design
  translates to agent behavior. The changes are fundamentally about modifying
  behavior through spec-driven prompt design, and ai-modeling-minion's input
  guards against both the opposite-bias failure mode and the risk of prompts
  that are too rigid or too vague to produce consistent behavior.

### Consultation 5: lucy -- governance alignment and consistency review

- **Agent**: lucy
- **Model**: opus
- **Planning question**: Lucy brings governance alignment and repo convention
  enforcement. Five questions covering the territory that both iac-minion's
  self-assessment and software-docs-minion's documentation review would have
  covered: (a) **Intent alignment**: The issue states four specific changes.
  Do the proposed changes faithfully address the three gaps identified without
  introducing scope beyond what was requested? Are there any risks of the
  planning team drifting from the issue's intent (e.g., expanding edge-minion's
  spec more than the issue calls for, or making the CLAUDE.md template more
  opinionated than needed)? (b) **Spec consistency**: When iac-minion's spec
  is bumped to 1.1 and margo's spec to 1.1, do the changes need to be
  reflected anywhere else in `the-plan.md` for internal consistency? Are there
  cross-references between agent specs, the delegation table, the nefario
  working patterns, or the build process section that would become stale?
  (c) **Boundary coherence**: The expanded iac-minion will overlap with
  edge-minion on serverless platforms. Does the `the-plan.md` structure have
  conventions for how "Does NOT do" sections and remit boundaries are expressed
  that the new spec must follow? Are there existing boundary patterns between
  other agents that should serve as templates? (d) **CLAUDE.md compliance**:
  The project's CLAUDE.md says "Do NOT modify the-plan.md unless the human
  owner approves." The issue constitutes that approval. Are there other
  CLAUDE.md rules that constrain how this work should proceed? (e) **Repo
  convention review**: If the CLAUDE.md template (issue item #4) is placed
  in the `docs/` directory, does it follow existing documentation patterns?
  What naming and format conventions should it adhere to?
- **Context to provide**: The full issue text, `the-plan.md` (particularly
  the Design Principles section lines 1-74, versioning section lines 50-64,
  the delegation table lines 293-390, and the "Does NOT do" sections for
  iac-minion and edge-minion), the project's `CLAUDE.md`, the `docs/`
  directory listing, and examples of existing documentation files in `docs/`
  for format reference.
- **Why this agent**: Lucy replaces two removed agents' planning roles. From
  iac-minion: lucy provides governance review of the spec changes to ensure
  they are internally consistent and do not drift from intent (iac-minion
  would have self-validated its spec, but lucy's external perspective may
  actually be more reliable for catching drift). From software-docs-minion:
  lucy ensures repo conventions are followed for any documentation artifacts
  and checks cross-references for staleness. Lucy's goal-drift detection is
  particularly valuable here because the risk of overcorrection (swinging
  from infrastructure bias to serverless bias) is a form of intent drift.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. The changes are spec-level
  (`the-plan.md` edits) and documentation. No executable code is produced.
  Phase 6 will run post-execution but there are no tests to execute for
  markdown spec changes. However, `/despicable-lab` rebuild is an execution
  step that produces AGENT.md files -- test-minion should review the
  execution plan to ensure rebuilt agents are validated (e.g., version
  consistency check).

- **Security**: Not needed for planning. The changes do not introduce attack
  surface, authentication, user input handling, or new dependencies. Security
  review during Phase 3.5 (mandatory) is sufficient.

- **Usability -- Strategy**: ALWAYS include. The entire issue is about the
  agent team recommending disproportionately complex infrastructure to users.
  **Planning question for ux-strategy-minion**: From a user journey
  perspective, how does a user currently experience the infrastructure bias
  (they ask to deploy a simple app, get a Docker+Terraform plan they did not
  need), and how should the fixed experience feel? Does the CLAUDE.md template
  (item #4) need UX framing to help users communicate their infrastructure
  preferences clearly? *Note: ux-strategy-minion is not on the revised team
  but is covered by Phase 3.5 mandatory review, where it will evaluate the
  execution plan from a journey coherence perspective.*

- **Usability -- Design**: Not needed. No user-facing interfaces are produced.

- **Documentation**: ALWAYS include. With software-docs-minion removed from
  the team, documentation consistency is covered by two mechanisms: (1) lucy's
  planning consultation (Consultation 5) covers repo convention review and
  cross-reference staleness checks for `the-plan.md` changes, and (2) Phase 8
  post-execution will handle any documentation artifacts that need creation
  (CLAUDE.md template) or updates (docs/ directory). user-docs-minion is not
  needed at planning because the changes affect the agent system itself, not
  end-user-facing documentation.

- **Observability**: Not needed. No runtime components, APIs, or services are
  produced. The changes are to agent specifications and documentation.

## Anticipated Approval Gates

1. **the-plan.md spec changes** (MUST gate): Hard to reverse (spec version
   bumps propagate to AGENT.md rebuilds), high blast radius (affects
   iac-minion, margo, nefario delegation table, and edge-minion boundary).
   All downstream tasks (AGENT.md rebuilds, documentation, CLAUDE.md template)
   depend on these spec changes being correct.

2. **CLAUDE.md template for target projects** (OPTIONAL gate): Easy to reverse
   (additive documentation), but involves judgment about what defaults to
   recommend to target projects. Low blast radius (no downstream tasks depend
   on it), but the template shapes how ALL future projects interact with the
   agent team. Gate if the template is opinionated enough to warrant user
   review.

## Rationale

The five planning consultations form a coherent set with minimal overlap:

- **Consultation 1 (margo)**: Self-assessment of the complexity budget
  recalibration. Only margo can validate that the scoring changes are
  internally consistent with its existing principles. Covers Gap 2.

- **Consultation 2 (edge-minion)**: Operational knowledge of serverless
  platforms, boundary definition with the expanded iac-minion, and input on
  the iac-minion decision framework. With iac-minion removed from planning,
  edge-minion is the primary source of deployment platform expertise. Covers
  Gap 1 (iac-minion spec) and Gap 3 (delegation table routing). Per user
  directive, edge-minion's opinions take precedence over devx-minion on
  deployment strategy.

- **Consultation 3 (devx-minion)**: Developer workflow perspective and
  CLAUDE.md template design. Scoped to avoid platform-level opinions (that's
  edge-minion's territory) and focused on the configuration artifact design
  and DX impact of deployment strategy decisions. Covers issue item #4.

- **Consultation 4 (ai-modeling-minion)**: Prompt engineering for the spec
  changes. Ensures the behavioral modifications translate into effective
  system prompts and guards against opposite-bias failure. Covers the
  cross-cutting concern that all spec changes must produce reliable agent
  behavior. No other agent has this expertise.

- **Consultation 5 (lucy)**: Governance alignment, intent-drift detection,
  spec consistency, and repo convention review. Replaces the governance
  aspects of iac-minion's removed self-assessment (external validation may
  be more reliable) and software-docs-minion's documentation consistency
  role. Covers cross-cutting governance for all four solution items.

Agents NOT consulted for planning (and why):
- **iac-minion**: Removed by user. Its spec expansion is informed by
  edge-minion (platform expertise), ai-modeling-minion (prompt design), and
  lucy (governance alignment).
- **software-docs-minion**: Removed by user. Documentation consistency is
  covered by lucy (Consultation 5) and Phase 8 post-execution.
- **gru**: The issue does not ask for technology radar assessment. The
  serverless platforms mentioned are established (Lambda 2014, Workers 2018,
  Vercel 2020).
- **ux-strategy-minion**: Not on the team but covered by Phase 3.5 mandatory
  review.
- **test-minion, security-minion, observability-minion**: Cross-cutting review
  in Phase 3.5 is sufficient. No executable code or runtime components.

## Scope

**In scope**:
- Edit `the-plan.md` to update iac-minion spec (1.0 -> 1.1)
- Edit `the-plan.md` to update margo spec (1.0 -> 1.1)
- Edit `the-plan.md` to add delegation table rows for serverless routing
- Edit `the-plan.md` to update edge-minion spec if boundary clarification is needed (1.0 -> 1.1)
- Run `/despicable-lab` to rebuild affected agents (iac-minion, margo, edge-minion if changed)
- Rebuild nefario's delegation table in AGENT.md (hand-maintained, needs manual update)
- Create CLAUDE.md template documentation for target projects (docs/ directory)
- Update any existing docs that reference infrastructure patterns

**Out of scope**:
- Creating new agents
- Hardcoding "serverless-first" as a rigid rule in any AGENT.md
- Direct AGENT.md or RESEARCH.md edits (those are generated by /despicable-lab)
- Modifying the build pipeline itself
- Changes to the nefario skill (SKILL.md)
- Changes to install.sh

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | ORCHESTRATION | Agent rebuild pipeline | DEFER -- use as macro-task for rebuilding affected agents after spec changes |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line config | Not relevant to this task |
| despicable-prompter | `skills/despicable-prompter/` | LEAF | Briefing coach | Not relevant to this task |
| nefario | `skills/nefario/` | ORCHESTRATION | Task orchestration | This is the invoking skill -- not used as a task |

### Precedence Decisions

`/despicable-lab` is the canonical tool for rebuilding agents from spec changes.
It will be used as a DEFERRED macro-task in the execution plan after
`the-plan.md` edits are complete. No precedence conflict exists -- no other
skill or agent covers the build pipeline.
