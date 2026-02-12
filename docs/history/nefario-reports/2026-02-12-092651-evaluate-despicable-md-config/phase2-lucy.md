# Domain Plan Contribution: lucy

## Recommendations

### 1. CLAUDE.md Compliance Interaction: Dual-File Validation Creates Unbounded Complexity

If DESPICABLE.md is introduced, lucy must validate both files. This is not merely additive work -- it is multiplicative. Every directive in DESPICABLE.md must be checked for:

- Internal consistency (does DESPICABLE.md contradict itself?)
- Cross-file consistency (does DESPICABLE.md contradict CLAUDE.md?)
- Precedence resolution (which wins when they conflict?)

Currently, lucy validates one hierarchy (CLAUDE.md / CLAUDE.local.md / .claude/rules/). Adding DESPICABLE.md and DESPICABLE.local.md creates a second parallel hierarchy with cross-cutting interactions. The validation matrix grows from N directives to N x M directive pairs. This is a structural complexity increase to lucy's compliance checking that is not justified by the configuration use cases identified.

**My recommendation: BLOCK the introduction of DESPICABLE.md.**

### 2. Convention Fragmentation Is the Primary Risk

The core governance concern is: where does a user put "exclude security-minion from reviews"? With a single configuration surface (CLAUDE.md), the answer is unambiguous. With two surfaces (CLAUDE.md + DESPICABLE.md), the answer depends on whether the user considers this "general project configuration" or "agent framework configuration." This is a distinction that:

- Has no crisp boundary (agent behavior IS project behavior when agents operate on the project)
- Varies by user mental model (some users think of agents as tools, others as team members)
- Creates discovery problems (a new team member looking at CLAUDE.md sees no agent configuration and assumes there is none)

Decision 5 explicitly states: "All project customization must flow through CLAUDE.md or CLAUDE.local.md." Introducing DESPICABLE.md violates this decision. The decision was made for good reason -- agents are generic specialists, project context belongs in the project's standard configuration surface. Creating a parallel surface fragments that principle.

### 3. Current CLAUDE.md Sections Are Sufficient

The three proposed configuration use cases map cleanly to CLAUDE.md sections:

| Use Case | CLAUDE.md Expression | Example |
|----------|---------------------|---------|
| Agent exclusion | Declarative statement in CLAUDE.md | `"Do not use seo-minion or sitespeed-minion for this project"` |
| Domain spin | Technology preferences section | `"Prefer Fastly for edge compute; prefer Coralogix for observability"` (already works via CLAUDE.local.md) |
| Orchestration overrides | Workflow section | `"Skip Phase 7 (deployment) in nefario orchestration"` |

These are already the patterns that external-skills.md establishes (Decision 28): "CLAUDE.md explicit preferences (highest) -- If the project's CLAUDE.md declares a skill preference or override, it wins unconditionally." The mechanism exists. No new file is needed.

A dedicated section heading in CLAUDE.md (e.g., `## Agent Team Configuration` or `## despicable-agents`) provides discoverability without introducing a separate file. This is strictly simpler and strictly more discoverable than a parallel file.

### 4. Precedence Rules Would Be Necessary But Unjustifiable

If DESPICABLE.md were introduced, the following precedence questions arise:

- DESPICABLE.local.md vs CLAUDE.local.md: which wins for agent-related directives?
- DESPICABLE.md vs CLAUDE.md: which wins when CLAUDE.md says "always run security review" and DESPICABLE.md says "exclude security-minion"?
- DESPICABLE.md vs .claude/rules/*.md: can a rule file override DESPICABLE.md?
- Parent-directory DESPICABLE.md files: do they recurse upward like CLAUDE.md?

Each question requires a decision. Each decision creates a convention that must be documented, enforced, and debugged when it goes wrong. The existing CLAUDE.md precedence hierarchy (6 tiers, documented in lucy's AGENT.md) already handles all known configuration needs. Adding a parallel hierarchy doubles the precedence surface without addressing a new class of problem.

### 5. SECURITY: Agent Exclusion Can Create Blind Spots (Critical Finding)

This concern applies regardless of whether the configuration surface is DESPICABLE.md or CLAUDE.md, but a separate file makes it harder to audit.

Decision 10 established that security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, and margo are ALWAYS reviewers in Phase 3.5. The external-skills.md cross-cutting exception states: "Internal specialists always retain ownership of cross-cutting concerns regardless of external skill specificity. Security-minion, test-minion, accessibility-minion, and governance agents (lucy, margo) are never overridden by external skills."

If project configuration can exclude ALWAYS reviewers, it undermines the architectural safety guarantee. This is the same category of risk as allowing a Dockerfile to disable security scanning -- the configuration surface becomes an attack vector against the quality process.

**Recommendation**: Any configuration mechanism (whether in CLAUDE.md or a hypothetical DESPICABLE.md) must enforce a non-overridable floor:

- security-minion, test-minion, lucy, and margo cannot be excluded from Phase 3.5 review
- Phase 3.5 itself cannot be skipped via project configuration (only the user can skip it, per Decision 15)

This constraint should be encoded in nefario's AGENT.md and SKILL.md, not just documented. Nefario should validate exclusion lists against the ALWAYS reviewer roster and reject configurations that exclude protected reviewers, surfacing the rejection to the user.

### Summary Position

**BLOCK on DESPICABLE.md introduction.** The proposal:

1. Violates Decision 5 (all customization through CLAUDE.md)
2. Creates convention fragmentation with no crisp boundary
3. Multiplies compliance checking complexity without addressing new use cases
4. Requires precedence rules that duplicate existing CLAUDE.md precedence
5. Existing CLAUDE.md sections already handle all three identified configuration use cases

**ADVISE on agent exclusion guardrails.** Regardless of the configuration surface decision, the ALWAYS reviewer protection needs explicit enforcement, not just documentation.

---

## Proposed Tasks

### Task 1: Document CLAUDE.md Section Convention for Agent Configuration

**What**: Add a recommended section pattern to `docs/using-nefario.md` showing how consuming projects should configure despicable-agents via CLAUDE.md sections. Include examples for agent exclusion, domain spin, and orchestration overrides.

**Deliverables**: Updated `docs/using-nefario.md` with a "Configuring for Your Project" section containing copy-pasteable CLAUDE.md snippet examples.

**Dependencies**: None. This is documentation of existing capability.

### Task 2: Enforce ALWAYS Reviewer Protection in Nefario

**What**: Add validation logic to nefario's Phase 1 (meta-plan) that checks any agent exclusion directives from CLAUDE.md against the ALWAYS reviewer list. If a protected reviewer is excluded, nefario surfaces a warning and proceeds with the reviewer included. The user can override at the approval gate, but the system does not silently comply.

**Deliverables**: Updated `nefario/AGENT.md` and `skills/nefario/SKILL.md` with ALWAYS reviewer guardrail. Updated `docs/orchestration.md` documenting the guardrail.

**Dependencies**: Task 1 (the CLAUDE.md section convention must be defined before nefario can parse it).

### Task 3: Record Decision Against DESPICABLE.md

**What**: Add a design decision to `docs/decisions.md` recording the evaluation and rejection of DESPICABLE.md, with rationale traceable to Decision 5 and the findings in this analysis.

**Deliverables**: New decision entry in `docs/decisions.md`.

**Dependencies**: Completion of the evaluation (this planning phase).

---

## Risks and Concerns

### Risk 1: Scope Creep Toward DESPICABLE.md in Future

Even if rejected now, the idea may resurface. The decision record (Task 3) mitigates this by documenting the rationale. Future proposals should demonstrate a configuration use case that cannot be expressed as a CLAUDE.md section before re-opening the discussion.

### Risk 2: CLAUDE.md Configuration Parsing Is Unstructured

The current approach relies on natural language directives in CLAUDE.md ("do not use seo-minion"). This is flexible but imprecise. Nefario must interpret these directives heuristically. If the configuration surface grows in complexity, structured configuration (YAML block in CLAUDE.md, for example) may become necessary. But that is a future problem to solve when evidence demands it -- not now (YAGNI).

### Risk 3: ALWAYS Reviewer Bypass Via CLAUDE.local.md

CLAUDE.local.md is gitignored and not team-visible. A user could add "exclude security-minion" in CLAUDE.local.md without team awareness. The guardrail in Task 2 mitigates this by having nefario validate at runtime regardless of which file the directive comes from. The warning is visible in the session output and in the execution report.

### Risk 4: Convention Fragmentation Through .claude/rules/ Files

Even without DESPICABLE.md, users could put agent configuration in `.claude/rules/despicable.md` or similar. This is not a new problem introduced by this evaluation -- it exists today for all CLAUDE.md configuration. The recommended section approach (Task 1) provides a canonical location that reduces the chance of rules-file fragmentation.

---

## Additional Agents Needed

- **security-minion**: Should validate the ALWAYS reviewer protection guardrail (Task 2) from a security perspective. The guardrail is a security control and should be reviewed by the security specialist.
- **margo**: Should validate that the recommended CLAUDE.md section approach (Task 1) is proportional and not over-engineered. The risk of over-specifying the section format is real.

No other agents needed beyond those already involved.
