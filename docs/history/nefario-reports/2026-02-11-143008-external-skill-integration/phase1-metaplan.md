# Meta-Plan: External Skill Integration

## Task Summary

Enable despicable-agents orchestration to discover, delegate to, and defer to
external domain skills (e.g., AEM/EDS skills, gh-upskill packages) without
requiring those skills to adopt despicable-agents conventions. Two usage modes:
(1) drop-in orchestration for projects with existing skills, (2) documented
integration surface for skill ecosystem maintainers.

## Scope

**In scope:**
- Nefario's discovery/delegation logic for external skills
- Skill integration surface design (conventions for interop)
- Precedence rules when external skills and despicable-agents specialists overlap
- Orchestration deferral mechanism (nefario yields to external orchestration skills)
- Execution-phase skill invocation by agents
- Documentation from both user and maintainer perspectives
- SKILL.md conventions for interop signaling

**Out of scope:**
- Building or modifying any external skills
- AEM/EDS domain knowledge in agents
- Changes to external skill formats (gh-upskill, claude-plugins.dev)
- MCP server integration (deferred)

---

## Planning Consultations

### Consultation 1: Skill Discovery and Invocation Architecture

- **Agent**: devx-minion
- **Planning question**: How should nefario discover external skills at planning
  time? Claude Code already loads skills from `~/.claude/skills/`, project-local
  `.claude/skills/`, and `.skills/` directories. Skills have SKILL.md files with
  YAML frontmatter (name, description) and markdown bodies. Given this existing
  mechanism:
  1. What discovery approach should nefario use during Phase 1 (meta-plan) to
     detect available project-local and global skills? Should it scan directories
     directly, or rely on Claude Code's existing skill loading?
  2. How should execution-phase agents invoke external skills? The `/skill-name`
     slash command pattern works in the main session but may not be available to
     subagents. What invocation mechanism is reliable for agents spawned via the
     Task tool?
  3. What minimal metadata in a SKILL.md would help nefario route work to an
     external skill vs. an internal specialist? Consider that external skills
     should NOT be required to add despicable-agents-specific metadata.
  4. Design the developer experience for combining despicable-agents + external
     skills: `install.sh` runs, `gh upskill` runs, user invokes `/nefario` --
     what should "just work" and what are the failure modes?
- **Context to provide**: `skills/nefario/SKILL.md` (Phase 1 meta-plan logic),
  `install.sh` (deployment), `.claude/skills/despicable-lab/SKILL.md` (project-local
  skill example), external skill examples from `/Users/ben/github/schamdan/.skills/`
  (CDD, block-collection-and-party, building-blocks), Claude Code skill loading
  from `~/.claude/skills/` and `.claude/skills/` and `.skills/`
- **Why this agent**: devx-minion owns CLI design, SDK design, developer
  onboarding, configuration files, and error messages. The core challenge is
  designing a discoverable, zero-config integration experience for developers
  combining two independently-distributed skill sets.

### Consultation 2: Orchestration Deferral and Precedence Design

- **Agent**: ai-modeling-minion
- **Planning question**: The hardest design problem in this task is orchestration
  deferral: when nefario detects that an external skill (like
  content-driven-development) has its own phased workflow, nefario should defer
  to that workflow rather than overriding it with nefario's own phases.
  1. How should nefario detect that an external skill is an "orchestration skill"
     (has its own multi-step workflow) vs. a "leaf skill" (a single capability)?
     The CDD skill has `## The Content-First Process` with explicit phases and
     `## Related Skills` that it invokes. What signals in SKILL.md content
     indicate orchestration capability?
  2. Define precedence rules: when a despicable-agents specialist and an external
     skill cover the same domain, which takes priority? For example, if
     frontend-minion and building-blocks both cover block implementation, how
     does nefario decide?
  3. Design the deferral mechanism: when nefario defers to an external
     orchestration skill, what does the delegation plan look like? Does the
     external skill become a "task" that nefario monitors? Does nefario's
     Phase 3.5 review still apply to work produced under external orchestration?
  4. How should nefario handle hybrid scenarios where some work falls under
     external orchestration and other work needs despicable-agents specialists?
     (e.g., "build a new block" defers to CDD, but the security review and
     documentation still come from despicable-agents).
- **Context to provide**: Full CDD SKILL.md (its phased workflow), building-blocks
  SKILL.md (sub-skill invoked by CDD), nefario AGENT.md (delegation table and
  modes), SKILL.md Phase 1-3 workflow
- **Why this agent**: ai-modeling-minion owns multi-agent architectures, prompt
  engineering, and orchestration patterns. The deferral mechanism is fundamentally
  an agent coordination problem: how does one orchestrator recognize and yield to
  another orchestrator's workflow.

### Consultation 3: Integration Surface Documentation

- **Agent**: software-docs-minion
- **Planning question**: This task requires documentation from two perspectives:
  (1) "I'm a user combining despicable-agents with external skills" and (2) "I'm
  a skill maintainer who wants my skills to work with orchestrators like nefario."
  1. What documentation artifacts are needed? Consider: a new doc under `docs/`
     for the architecture, additions to `docs/using-nefario.md` for users,
     a standalone guide for skill maintainers, and updates to existing
     architecture docs.
  2. For the skill maintainer perspective: what is the minimal documentation
     of nefario's integration surface? External skill authors should not need
     to read the full SKILL.md or AGENT.md -- they need a slim contract
     describing what nefario looks for and how to signal compatibility.
  3. How should the documentation handle the "no coupling" requirement? External
     skills must remain independently usable. The integration guide should show
     optional annotations that improve orchestration, not mandatory ones.
  4. Where in the existing doc structure (`docs/architecture.md`,
     `docs/using-nefario.md`, `docs/orchestration.md`) should integration
     content live vs. be its own document?
- **Context to provide**: `docs/architecture.md`, `docs/using-nefario.md`,
  `docs/orchestration.md` (structure), existing doc index
- **Why this agent**: software-docs-minion owns architecture documentation,
  C4 diagrams, and README structure. The integration surface must be documented
  as a clear contract -- this is architecture documentation, not just a how-to.

### Consultation 4: Simplification and Journey Coherence

- **Agent**: ux-strategy-minion
- **Planning question**: The user journey for "combine orchestration with external
  skills" must be simple despite the underlying complexity. Evaluate:
  1. What is the cognitive load for a user who has a project with CDD skills and
     installs despicable-agents? Walk through the journey: install, invoke
     `/nefario 'build a new block'`, see the meta-plan reference CDD phases.
     Where are the confusion points?
  2. The precedence rules between internal specialists and external skills are
     the highest friction point. How should nefario present delegation decisions
     to the user when external skills are involved? Should the execution plan
     show "defers to CDD skill" or "invokes /content-driven-development"?
  3. What happens when integration fails silently? If nefario cannot detect an
     external skill or incorrectly routes work to an internal specialist when an
     external skill exists, what is the user's recovery path?
  4. Simplification audit: is there anything in this task's scope that we should
     NOT build because it adds complexity without proportional user value?
- **Context to provide**: `docs/using-nefario.md` (current UX), the acceptance
  test scenario from the issue, CDD skill structure
- **Why this agent**: ALWAYS included per cross-cutting checklist. Every plan needs
  journey coherence review, cognitive load assessment, and simplification audit.
  The integration surface is user-facing and must be intuitive.

### Consultation 5: Security Implications of External Skill Discovery

- **Agent**: security-minion
- **Planning question**: Nefario will be reading and potentially executing
  external skills that were not authored by the despicable-agents team. Evaluate:
  1. What are the trust boundaries? Nefario reads SKILL.md files from the target
     project's `.skills/` or `.claude/skills/` directories. These files contain
     instructions that Claude Code follows. Is there a prompt injection risk if
     a malicious SKILL.md is present in a project?
  2. When execution-phase agents invoke external skills, what guardrails should
     exist? Should there be a whitelist/allowlist mechanism, or is the existing
     Claude Code permission model sufficient?
  3. The discovery mechanism reads filesystem paths. Are there path traversal
     or symlink-following risks in the discovery logic?
  4. Should nefario's integration surface include any security-related signaling
     (e.g., "this skill requires elevated permissions" or "this skill modifies
     files outside the project")?
- **Context to provide**: `skills/nefario/SKILL.md` (existing security measures
  like content boundary markers for issue fetch), the trust model (external skills
  are already loaded by Claude Code's native mechanism)
- **Why this agent**: ALWAYS included per cross-cutting checklist. External skill
  discovery introduces a new trust boundary that must be evaluated.

---

## Cross-Cutting Checklist

- **Testing** (test-minion): Include for planning. The acceptance test scenario
  (install despicable-agents + CDD, run `/nefario 'build a new block'`, verify
  meta-plan references CDD) needs a concrete test strategy. test-minion should
  advise on how to validate the integration works without depending on live
  external skills. However, this task produces no runtime code -- it produces
  design artifacts and documentation changes to the orchestration logic. Test
  strategy should focus on validation criteria for the design, not automated
  tests. **Include in Phase 3.5 review, not planning.**

- **Security** (security-minion): **Included above as Consultation 5.** External
  skill discovery is a new trust boundary.

- **Usability -- Strategy** (ux-strategy-minion): **ALWAYS included. Included
  above as Consultation 4.**

- **Usability -- Design** (ux-design-minion): Not needed for planning. This task
  produces no user-facing interfaces. The "UI" is the execution plan output and
  documentation, which ux-strategy-minion covers from the journey/cognitive load
  angle.

- **Documentation** (software-docs-minion): **ALWAYS included. Included above as
  Consultation 3.** Documentation is a primary deliverable of this task.

- **Observability** (observability-minion): Not needed for planning. This task
  does not produce runtime components, services, or APIs. No logging, metrics,
  or tracing concerns.

---

## Anticipated Approval Gates

1. **Integration Surface Design** (MUST gate): The design of how nefario
   discovers, evaluates, and delegates to external skills. This is an
   architectural decision with high blast radius -- it will constrain all future
   external skill integration. Hard to reverse once documented and adopted.
   Multiple valid approaches exist (scan-based vs. metadata-based vs. hybrid).
   All downstream tasks (nefario AGENT.md changes, SKILL.md changes,
   documentation) depend on this design.

2. **Deferral Mechanism Design** (MUST gate): How nefario detects and defers to
   external orchestration skills. This defines the precedence rules and shapes
   the user experience. Hard to reverse once encoded in nefario's logic.
   Downstream documentation tasks depend on this.

3. **Documentation Structure** (no gate): Easy to reverse, low blast radius.
   Documentation can be revised after initial creation without cascading effects.

---

## Rationale

Five specialists are consulted for planning:

- **devx-minion** (primary): The integration surface is fundamentally a developer
  experience problem -- how do two independently-distributed toolkits combine
  seamlessly? devx-minion owns this space.

- **ai-modeling-minion**: The orchestration deferral mechanism is a multi-agent
  coordination problem. When should one orchestrator yield to another? This is
  ai-modeling-minion's core expertise in multi-agent architectures.

- **software-docs-minion**: Documentation is a primary deliverable, not an
  afterthought. The "integration contract" documentation defines the external
  surface area. software-docs-minion should shape this from the start.

- **ux-strategy-minion**: The user journey must be simple despite the underlying
  complexity. ALWAYS included, but also genuinely critical here -- the integration
  must feel effortless to users who do not understand the orchestration internals.

- **security-minion**: External skill discovery introduces a trust boundary.
  ALWAYS included, and particularly relevant here because nefario will be
  reading and routing to files not authored by the despicable-agents team.

**Not consulted for planning** (but may appear in execution):
- test-minion: Will review in Phase 3.5 but does not need planning input. This
  task's primary deliverables are design + documentation, not testable code.
- lucy, margo: Governance reviewers triggered unconditionally in Phase 3.5.
  They review the plan, not contribute to planning.
- product-marketing-minion: May be needed in Phase 8 if README/user-facing docs
  change, but does not contribute to integration design planning.
- user-docs-minion: The user-facing documentation is more of an architecture
  contract than a tutorial. software-docs-minion is the right lead. user-docs-minion
  may contribute during execution for the "getting started" perspective.

---

## Scope

**What this achieves**: A design and implementation plan for making nefario
aware of external skills in the target project's environment. After execution,
users can drop despicable-agents into a project with pre-existing skills and
get orchestration benefits immediately. Skill maintainers can read a documented
integration surface without adopting despicable-agents conventions.

**In scope**:
- Discovery mechanism (how nefario finds external skills)
- Evaluation logic (how nefario decides to delegate to vs. orchestrate around
  external skills)
- Deferral mechanism (how nefario yields to external orchestration workflows)
- Precedence rules (internal specialist vs. external skill)
- Changes to nefario AGENT.md and/or SKILL.md
- Documentation for both user and skill maintainer perspectives
- Acceptance test validation approach

**Out of scope**:
- Modifying any external skill (CDD, building-blocks, etc.)
- Adding AEM/EDS domain knowledge to any agent
- Changes to external distribution mechanisms (gh-upskill, claude-plugins.dev)
- MCP server routing (future enhancement)
- Automated testing infrastructure (manual validation of acceptance scenario)
