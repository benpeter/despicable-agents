# Meta-Plan: Evaluate DESPICABLE.md as Project-Local Configuration

## Context

despicable-agents is a globally-installed agent toolkit (27 agents + 2 skills deployed to `~/.claude/`). It operates on any target project from that project's working directory. Currently, all project-specific configuration for despicable-agents lives in the target project's `CLAUDE.md` and `CLAUDE.local.md` -- the same files used for general Claude Code instructions. There is no framework-specific configuration surface.

The proposal under evaluation: introduce `DESPICABLE.md` (checked in) and `DESPICABLE.local.md` (gitignored) as dedicated configuration files for despicable-agents in consuming projects, separating framework concerns from general Claude Code concerns.

**Key design tensions:**
- CLAUDE.md is already the canonical place for project instructions (Decision 5: "All project customization must flow through CLAUDE.md or CLAUDE.local.md")
- The external skill integration mechanism (Decision 28) already handles project-local skill precedence via CLAUDE.md declarations
- Lucy's remit includes CLAUDE.md compliance checking -- a new config file changes what she validates
- The current architecture states: "Project context belongs in the target project's CLAUDE.md, not in agents"
- YAGNI/KISS principles from the Helix Manifesto apply strongly to any new configuration surface

## Planning Consultations

### Consultation 1: Technology Landscape Assessment

- **Agent**: gru
- **Planning question**: From a technology landscape perspective, how do other agent frameworks and AI toolkits handle project-local configuration? Specifically: (1) Do frameworks like LangGraph, CrewAI, AutoGen, or the OpenAI Agents SDK use dedicated config files vs. relying on the host platform's config? (2) Is there an emerging convention for "framework config layered on top of platform config"? (3) What is the risk of inventing a custom config surface (DESPICABLE.md) vs. using the platform's native config (CLAUDE.md sections)?
- **Context to provide**: The current architecture (agents deployed globally, project context via CLAUDE.md), the external skill integration precedence model (CLAUDE.md > project-local > specificity), Decision 26 (decoupling from self-referential paths).
- **Why this agent**: Gru evaluates technology decisions against the broader landscape. The question of "dedicated framework config file vs. section in platform config" is a technology strategy decision with precedent in other ecosystems (e.g., `.eslintrc` vs. `package.json` eslint key, `tsconfig.json` vs. nothing).

### Consultation 2: Intent Alignment and Convention Assessment

- **Agent**: lucy
- **Planning question**: From a governance and convention enforcement perspective: (1) How would DESPICABLE.md interact with CLAUDE.md compliance checking -- does lucy need to validate both files, and what happens when they conflict? (2) Does a separate config file create convention fragmentation (users unsure where to put agent-related instructions)? (3) Is the current approach of using CLAUDE.md sections already sufficient for the configuration use cases identified (agent exclusion, domain spin, orchestration overrides)? (4) What precedence rules would be needed if DESPICABLE.md contradicts CLAUDE.md?
- **Context to provide**: Lucy's current CLAUDE.md compliance remit, the external skill precedence model, the existing `CLAUDE.local.md` public/private split pattern, the specific config options proposed (agent exclusion, domain spin, orchestration overrides).
- **Why this agent**: Lucy owns convention enforcement and CLAUDE.md compliance. A new config file directly impacts her domain -- she needs to assess whether it creates governance complexity or simplifies it.

### Consultation 3: YAGNI and Simplicity Assessment

- **Agent**: margo
- **Planning question**: Apply YAGNI/KISS analysis to the DESPICABLE.md proposal: (1) Is there demonstrated real demand for dedicated framework configuration, or is this speculative? (2) How many consuming projects currently exist, and what configuration do they actually need? (3) Could the identified configuration needs (agent exclusion, domain spin, orchestration overrides) be served by a `## Despicable Agents` section in CLAUDE.md with zero new files? (4) What is the complexity cost of a new config file (discovery logic, precedence rules, documentation, user education) vs. the complexity cost of overloading CLAUDE.md? (5) Apply the "one-agent rule" analog: do not build configuration infrastructure until 2+ consuming projects demonstrate the need.
- **Context to provide**: Decision 27 (removed overlay mechanism applying the one-agent rule), the Helix Manifesto principles, the current state of consuming projects (if any), the full list of proposed config options.
- **Why this agent**: Margo is the YAGNI/KISS guardian. The central question is whether this is solving a real problem or a speculative one. Margo's analysis will be the strongest voice on whether to defer.

### Consultation 4: Configuration File Design and Developer Experience

- **Agent**: devx-minion
- **Planning question**: Evaluate the developer experience of the proposed configuration surface: (1) Compare the DX of `DESPICABLE.md` + `DESPICABLE.local.md` vs. a `## Despicable Agents` section in `CLAUDE.md` -- which is more discoverable, more maintainable, and has lower cognitive overhead for adopters? (2) If a dedicated file is adopted, what should its format be (freeform markdown like CLAUDE.md, structured YAML frontmatter + markdown body, or pure structured data like YAML/TOML)? (3) What configuration options would a consuming project realistically need? Evaluate each proposed option (agent exclusion, domain spin, orchestration overrides) for real-world utility. (4) How should the file be discovered -- by nefario at planning time, by individual agents at runtime, or both? (5) What does the "getting started" experience look like -- does a user need to create this file to use despicable-agents, or is it purely optional? (6) Assess error cases: what happens when the file has invalid content, conflicts with CLAUDE.md, or references agents that do not exist?
- **Context to provide**: The devx-minion's expertise in configuration file design (formats, defaults, overrides, validation), the existing CLAUDE.md/CLAUDE.local.md split pattern, the external skill integration discovery model (filesystem scanning), Decision 26 (CWD-relative detection).
- **Why this agent**: devx-minion owns configuration file design, progressive complexity, and developer onboarding. The format, discoverability, and error handling of any new config surface is core DX work.

### Consultation 5: Documentation Impact Assessment

- **Agent**: software-docs-minion
- **Planning question**: If DESPICABLE.md is adopted, what documentation changes would be needed? Specifically: (1) Which existing docs reference "project context belongs in CLAUDE.md" and would need updating? (2) What new documentation would be needed (configuration reference, getting-started guide for consuming projects, precedence rules)? (3) Does the introduction of a new config file warrant an update to architecture.md? (4) If the recommendation is to use a CLAUDE.md section instead, what documentation is needed for that convention? Assess the documentation burden of each approach (dedicated file vs. CLAUDE.md section vs. status quo).
- **Context to provide**: The current documentation structure (architecture.md hub, external-skills.md, deployment.md, using-nefario.md), the "Generic domain specialists" design principle, Decision 5 (user-scope memory, project customization via CLAUDE.md).
- **Why this agent**: software-docs-minion assesses documentation impact of architectural decisions. The documentation burden is a real cost that factors into the adopt/defer/reject decision.

## Cross-Cutting Checklist

- **Testing**: Not applicable. This is a consultation producing a decision document, not code or configuration. No executable output to test.
- **Security**: Not applicable to the consultation itself. However, security-minion input would be relevant if DESPICABLE.md could contain instructions that override security-related agent behavior (e.g., excluding security-minion from reviews). **Include a security question as a sub-question in lucy's consultation** rather than a standalone consultation: "Can DESPICABLE.md configuration create security blind spots (e.g., by excluding security-minion or overriding review requirements)?"
- **Usability -- Strategy**: Covered by devx-minion (Consultation 4) and margo (Consultation 3). The UX strategy dimension is the DX question here -- devx-minion's configuration file design expertise is more precisely relevant than ux-strategy-minion's journey mapping for this tool-configuration task. **Not included as separate consultation** because the task has no end-user interface; the "users" are developers configuring a CLI toolkit.
- **Usability -- Design**: Not applicable. No user-facing interface is produced.
- **Documentation**: Included as Consultation 5 (software-docs-minion).
- **Observability**: Not applicable. No runtime components.

## Anticipated Approval Gates

**Zero approval gates for the consultation itself.** The output is a decision document (ADR-style), not an execution plan with dependent tasks. The decision document will be presented to the user as the final deliverable for their judgment (adopt/defer/reject).

If the recommendation is "adopt," a follow-up implementation plan would go through the normal nefario process with its own gates. That plan is out of scope for this consultation.

## Rationale

**Five consultations selected** (gru, lucy, margo, devx-minion, software-docs-minion). The four user-specified agents are included. software-docs-minion is added because the documentation impact is a material factor in the decision.

**Agents not included and why:**
- **ux-strategy-minion**: The "users" here are developers configuring a CLI toolkit. devx-minion covers this DX concern more precisely. ux-strategy-minion's journey mapping and cognitive load analysis are less relevant for a config-file decision than devx-minion's configuration file design expertise.
- **security-minion**: Security concern (can config override security reviews?) is addressed as a sub-question in lucy's consultation rather than a full standalone consultation. The risk surface is narrow and well-bounded.
- **test-minion**: No executable output to test.
- **All other minions**: Not relevant to a configuration convention decision.

**Why not fewer?** Margo and devx-minion address overlapping concerns (simplicity vs. DX) but from different angles -- margo evaluates "should we build this at all?" while devx-minion evaluates "if we build it, what should it look like?" Both perspectives are needed for a well-reasoned recommendation.

## Scope

**In scope:**
- File naming convention (DESPICABLE.md, .despicable.yml, or alternatives)
- Public/private split (.md vs .local.md)
- Interaction with existing CLAUDE.md/CLAUDE.local.md
- Discoverability for adopters (how do they learn about it?)
- Configuration options these files would support (agent exclusion, domain spin, orchestration overrides)
- Comparison with alternative approaches (CLAUDE.md section, status quo)
- Precedence rules if adopted (DESPICABLE.md vs CLAUDE.md conflicts)
- YAGNI analysis: real demand vs speculative need

**Out of scope:**
- Implementation of file parsing or discovery logic
- Changes to agent runtime or AGENT.md files
- Changes to nefario orchestration code
- Changes to the-plan.md

**Deliverable:** A decision document in ADR format with a clear recommendation (adopt, defer, or reject), rationale, and precedence rules (if adopt).

## External Skill Integration

No external skills detected in project that are relevant to this consultation task. The two project-local skills (despicable-lab, despicable-prompter) are agent build/coaching tools, not relevant to a configuration convention decision.
