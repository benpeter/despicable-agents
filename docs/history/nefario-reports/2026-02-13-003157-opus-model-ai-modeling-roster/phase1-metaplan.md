# Meta-Plan: Fix Serverless Infrastructure Bias

## Summary

The agent system has a structural bias against serverless infrastructure.
Three compounding gaps -- iac-minion's zero serverless knowledge, margo's
novelty-penalizing complexity budget, and the delegation table's missing
serverless routing -- combine to produce Docker+Terraform recommendations
for projects where `vercel deploy` would suffice.

The fix is four coordinated spec changes in `the-plan.md`, followed by
`/despicable-lab` rebuilds for affected agents. No new agents, no direct
AGENT.md edits.

## Planning Consultations

### Consultation 1: iac-minion spec expansion

- **Agent**: iac-minion
- **Planning question**: What should iac-minion's deployment strategy selection
  framework look like? Specifically: (a) What decision criteria determine when a
  project needs infrastructure vs. serverless? (b) What serverless platforms and
  patterns should be in iac-minion's remit (Vercel, Cloudflare Pages, AWS Lambda,
  Netlify, etc.)? (c) What does "serverless cost modeling and escalation triggers"
  look like concretely -- what thresholds or signals indicate a project has outgrown
  serverless? (d) How should the "ask if infrastructure is needed first" principle
  be framed to avoid the opposite bias (always-serverless)?
- **Context to provide**: Current iac-minion spec from `the-plan.md` (lines
  722-749), current iac-minion AGENT.md (for understanding what the built agent
  knows), the issue's Gap 1 analysis, and the "Boundary clarifications" section
  (iac-minion owns deployment strategy selection and platform config).
- **Why this agent**: iac-minion is the primary agent being expanded. Its domain
  expertise in infrastructure will ground the serverless additions in operational
  reality -- it knows when self-managed infrastructure IS justified, which prevents
  the spec from swinging to the opposite extreme.

### Consultation 2: margo complexity budget recalibration

- **Agent**: margo
- **Planning question**: How should margo's complexity budget and boring technology
  framework be recalibrated to account for operational burden? Specifically:
  (a) How should the complexity budget score managed/serverless services vs.
  self-managed infrastructure? The issue suggests managed services that eliminate
  ops work should score lower, but what's the right scoring model? (b) Which
  serverless platforms qualify as "boring technology" by margo's own stated criteria
  (production hardening, known failure modes, staffable talent, community docs)?
  (c) How should "infrastructure over-engineering detection" work as a review
  heuristic without making margo prescriptive about topology? (d) What research
  focus areas are needed to ground these additions?
- **Context to provide**: Current margo spec from `the-plan.md` (lines 537-570),
  current margo AGENT.md sections on Complexity Budget (lines 53-62) and Boring
  Technology (lines 171-180), the issue's Gap 2 analysis, and the boundary
  clarification that margo detects disproportionate complexity but does NOT
  prescribe serverless.
- **Why this agent**: Margo is the agent whose complexity scoring is being
  recalibrated. Its expertise in simplicity enforcement ensures the new scoring
  model is internally consistent with its existing principles. Margo also needs
  to validate that the proposed changes do not make it prescriptive about
  technology choices (it enforces simplicity, not topology).

### Consultation 3: edge-minion boundary acknowledgment

- **Agent**: edge-minion
- **Planning question**: The issue notes that edge-minion should acknowledge
  Cloudflare Workers/Pages as a full-stack serverless platform, not only CDN
  compute. (a) Does edge-minion's current spec and research already cover this
  sufficiently, or does the spec need a minor update? (b) Where is the boundary
  between edge-minion's responsibility (edge-specific implementation, Workers
  runtime, Pages deployment patterns) and iac-minion's new serverless
  responsibility (deployment strategy selection, platform choice)? (c) If a user
  deploys a full app on Cloudflare Pages with Workers functions, which agent owns
  what?
- **Context to provide**: Current edge-minion spec from `the-plan.md` (lines
  751-784), the proposed delegation table additions (serverless platform
  deployment lists edge-minion as supporting), and the boundary clarification
  from the issue.
- **Why this agent**: Edge-minion's domain overlaps with serverless platforms
  (Cloudflare Workers/Pages). Its input prevents boundary confusion in the final
  spec and ensures the delegation table routes correctly when serverless platforms
  are also edge platforms.

### Consultation 4: devx-minion perspective on developer workflow

- **Agent**: devx-minion
- **Planning question**: The proposed delegation table lists devx-minion as
  supporting for "Deployment strategy selection." (a) What does devx-minion bring
  to deployment strategy decisions -- is it the developer workflow perspective
  (time-to-deploy, local dev experience, DX of the deployment tool)? (b) Should
  the CLAUDE.md template for target projects (issue item #4) include deployment
  preferences as part of its developer onboarding guidance? (c) What should that
  template look like from a developer experience perspective?
- **Context to provide**: Current devx-minion spec from `the-plan.md` (lines
  973-1011), the issue's solution item #4 (CLAUDE.md template for target
  projects), and the proposed delegation table row.
- **Why this agent**: devx-minion is listed as supporting agent for deployment
  strategy selection and brings the developer experience perspective. Its input
  is particularly valuable for the CLAUDE.md template (item #4), which is
  fundamentally about configuring the agent team's defaults for a target project.

### Consultation 5: ai-modeling-minion perspective on agent prompt design

- **Agent**: ai-modeling-minion
- **Planning question**: The changes require modifying system prompt behavior
  through spec changes -- adding a "serverless-first for greenfield" principle to
  iac-minion and recalibrating margo's scoring. (a) How should these behavioral
  changes be framed in the spec to ensure the built prompts produce the desired
  behavior without being rigidly prescriptive? (b) What prompt engineering
  principles apply to adding decision frameworks (serverless vs. container vs.
  self-managed) to an agent's core knowledge -- how do you structure a decision
  tree in a system prompt so it is followed reliably? (c) Are there risks of
  the expanded iac-minion defaulting to serverless advice regardless of context
  (the opposite bias), and how should the prompt guard against that?
- **Context to provide**: Current iac-minion and margo specs, the build pipeline
  documentation (`docs/build-pipeline.md`), the issue's "What NOT to do" section
  (especially "do NOT hardcode serverless-first"), and the system prompt structure
  from `the-plan.md` (lines 66-74).
- **Why this agent**: ai-modeling-minion is the prompt engineering specialist. The
  changes are fundamentally about modifying agent behavior through prompt design.
  Its expertise ensures the spec changes translate into effective system prompts
  when built by `/despicable-lab`, and guards against the opposite-bias failure
  mode.

### Consultation 6: documentation approach

- **Agent**: software-docs-minion
- **Planning question**: (a) Does the `docs/` directory need updates to reflect
  the expanded iac-minion remit and margo recalibration? Specifically, does
  `docs/agent-catalog.md` or `docs/architecture.md` reference infrastructure
  patterns that would become incomplete? (b) For the CLAUDE.md template (issue
  item #4), what is the right location in the docs directory and what format
  should it follow to be consistent with existing documentation?
- **Context to provide**: The docs directory listing, `docs/architecture.md`
  (first 50 lines), `docs/deployment.md`, and the issue's solution item #4.
- **Why this agent**: software-docs-minion ensures the documentation layer stays
  consistent with spec changes. The CLAUDE.md template is also a documentation
  artifact that needs to follow project conventions.

## Cross-Cutting Checklist

- **Testing**: Not needed for planning. The changes are spec-level (`the-plan.md`
  edits) and documentation. No executable code is produced. Phase 6 will run
  post-execution but there are no tests to execute for markdown spec changes.
  However, `/despicable-lab` rebuild is an execution step that produces AGENT.md
  files -- test-minion should review the execution plan to ensure rebuilt agents
  are validated (e.g., version consistency check).

- **Security**: Not needed for planning. The changes do not introduce attack
  surface, authentication, user input handling, or new dependencies. Security
  review during Phase 3.5 (mandatory) is sufficient.

- **Usability -- Strategy**: ALWAYS include. The entire issue is about the
  agent team recommending disproportionately complex infrastructure to users.
  **Planning question for ux-strategy-minion**: From a user journey perspective,
  how does a user currently experience the infrastructure bias (they ask to deploy,
  get a Docker+Terraform plan they did not need), and how should the fixed
  experience feel? Does the CLAUDE.md template (item #4) need UX framing to
  help users communicate their infrastructure preferences clearly?

- **Usability -- Design**: Not needed. No user-facing interfaces are produced.

- **Documentation**: ALWAYS include. Covered by Consultation 6 (software-docs-minion).
  user-docs-minion is not needed at planning because the changes affect the
  agent system itself, not end-user-facing documentation. However, the CLAUDE.md
  template (item #4) is user-facing in the sense that project developers will
  use it -- software-docs-minion covers this.

- **Observability**: Not needed. No runtime components, APIs, or services are
  produced. The changes are to agent specifications and documentation.

## Anticipated Approval Gates

1. **the-plan.md spec changes** (MUST gate): Hard to reverse (spec version bumps
   propagate to AGENT.md rebuilds), high blast radius (affects iac-minion, margo,
   nefario delegation table, and edge-minion boundary). All downstream tasks
   (AGENT.md rebuilds, documentation, CLAUDE.md template) depend on these spec
   changes being correct.

2. **CLAUDE.md template for target projects** (OPTIONAL gate): Easy to reverse
   (additive documentation), but involves judgment about what defaults to recommend
   to target projects. Low blast radius (no downstream tasks depend on it), but
   the template shapes how ALL future projects interact with the agent team.
   Gate if the template is opinionated enough to warrant user review.

## Rationale

The six planning consultations cover the four solution items from the issue plus
two cross-cutting concerns:

- **Consultations 1-3** cover the three agents whose specs change (iac-minion,
  margo, edge-minion). Each agent's domain expertise is needed to get its own
  spec right and to validate boundary clarity with neighbors.
- **Consultation 4** covers the devx-minion perspective on the CLAUDE.md template
  and deployment strategy DX.
- **Consultation 5** covers ai-modeling-minion's prompt engineering expertise,
  needed because the changes are fundamentally about modifying agent behavior
  through spec-driven prompt design.
- **Consultation 6** covers documentation consistency.
- **ux-strategy-minion** (via cross-cutting checklist) covers the user experience
  of the fix -- ensuring the changed behavior actually feels right from the
  user's perspective.

Agents NOT consulted for planning (and why):
- **gru**: The issue does not ask for technology radar assessment. The serverless
  platforms mentioned are established (Lambda 2014, Workers 2018, Vercel 2020).
- **lucy**: Governance review happens in Phase 3.5 (mandatory). Planning input
  not needed -- the issue is well-scoped with clear intent.
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
