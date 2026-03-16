# Domain Plan Contribution: lucy

## Recommendations

### (a) Governance agents: universal framework agents, not domain-specific replacements

Lucy and margo should remain universal, domain-agnostic governance agents that ship with the framework. The reasons are structural, not just convenient:

1. **Governance value is domain-independent.** Lucy's core functions -- goal drift detection, requirements traceability, CLAUDE.md compliance, convention enforcement -- are abstract review patterns. They do not require knowledge of what the domain *is*; they require knowledge of what the human *asked for* versus what the agents *produced*. Margo's YAGNI/KISS/complexity analysis is similarly domain-neutral: accidental complexity is accidental complexity whether you are reviewing a Terraform module or an IVDR compliance checklist.

2. **Domain-specific governance would create a maintenance burden for every adapter.** If each domain had to supply its own lucy and margo equivalents, every domain adapter author would need to (a) understand multi-agent drift patterns, (b) write prompt-engineering-quality governance prompts, and (c) keep them updated as the framework evolves. This is the opposite of what the task wants: making the system accessible to non-software forks.

3. **Domain context should flow through the existing mechanisms, not through governance agent replacement.** Lucy already reads CLAUDE.md files, scans directory structure, and extracts conventions from the target project. In a domain-adapted system, the domain adapter's CLAUDE.md (or equivalent configuration) provides the conventions Lucy checks against. No lucy changes needed -- the conventions change, the checking mechanism does not.

**Recommended design**: The domain adapter declares:
- A `governance` section in its configuration that can *extend* the mandatory reviewer list (e.g., a compliance domain might add a `compliance-reviewer` agent as a third mandatory governance reviewer alongside lucy and margo), but cannot *remove* lucy or margo.
- Domain-specific convention files (CLAUDE.md equivalent) that lucy reads to learn what conventions to enforce for that domain.
- Optional domain-specific review focus hints that get injected into lucy's and margo's reviewer prompts (analogous to the `## Your Review Focus` template in the Phase 3.5 reviewer prompt in `skills/nefario/SKILL.md` lines 1098-1161). This is the lightweight path: instead of replacing the governance agent, you parameterize its review focus.

### (b) CLAUDE.md compliance checking across domains

Lucy's CLAUDE.md compliance checking already works through an indirect, discovery-based mechanism (see `lucy/AGENT.md` lines 80-117). The process is:

1. Read all CLAUDE.md files in the hierarchy.
2. Extract actionable directives from them.
3. Check plans/code against those directives.

This process is inherently domain-agnostic. The compliance checking does not assume the directives are about JavaScript or TypeScript -- it extracts whatever directives exist and checks for compliance. However, several specific items in the "Common CLAUDE.md Directives to Check" list (lucy/AGENT.md lines 109-117) are software-development-specific:

- "Module system requirements (ESM vs CJS)"
- "Build/test/lint commands"
- "Dependency policies (banned packages, preferred alternatives)"

**Recommended approach**:

1. **Split lucy's "Common CLAUDE.md Directives to Check" into two sections**: a universal set (technology preferences, naming conventions, directory structure, workflow requirements, PR/commit standards) and a domain-specific example set that the domain adapter supplies. The universal set stays in lucy's AGENT.md. The domain-specific set is referenced from the adapter's configuration.

2. **The Configuration Consistency section** (lucy/AGENT.md lines 131-138) is entirely software-specific (package manager, runtime version, TypeScript config, linter config, git hooks). In a domain-adapted system, this section must be parameterized. The adapter declares what configuration files exist and what consistency checks apply. Lucy checks for consistency between declarations and actual files -- but the *list of files to check* comes from the adapter.

3. **The Content Patterns section** (lucy/AGENT.md lines 140-144) is similarly software-specific (import/export patterns, error handling, logging, test organization). Same treatment: the adapter declares content patterns; lucy checks them.

4. **No changes to the compliance verification *process*** (read, extract, check, flag, verify). Only the *examples and checklists* need parameterization.

### (c) Cross-cutting dimensions: universal vs. software-specific

The six current cross-cutting dimensions from `the-plan.md` lines 412-433 and `nefario/AGENT.md` lines 271-286 classify as follows:

| Dimension | Current Agent(s) | Classification | Rationale |
|-----------|-----------------|----------------|-----------|
| **Testing** | test-minion | **Domain-specific** | "Test" means different things in different domains. In software, it means unit/integration/e2e tests. In regulatory compliance, it means validation audits. In corpus linguistics, it means annotation inter-rater reliability. The *concept* of verification is universal, but the agent and its expertise are domain-bound. |
| **Security** | security-minion | **Domain-specific** | The current agent is specifically an OWASP/threat-modeling/container-security agent. A regulatory compliance domain needs a different kind of security (data protection, audit trails). The *concept* of risk mitigation is universal; the agent is domain-bound. |
| **Usability -- Strategy** | ux-strategy-minion | **Domain-specific** | Focused on user journeys, cognitive load for software users, and simplification of software features. A linguistics domain has no "users" in the UX sense. The *concept* of coherence review is universal; the agent is domain-bound. |
| **Usability -- Design** | ux-design-minion, accessibility-minion | **Domain-specific** | Focused on visual/interaction design and WCAG. Entirely software/web-specific. |
| **Documentation** | software-docs-minion, user-docs-minion | **Partially universal** | Every domain produces artifacts that need documentation. But "software-docs-minion" (C4 diagrams, ADRs, API docs) is software-specific. The *slot* for documentation review is universal; the agent filling it is domain-specific. |
| **Observability** | observability-minion, sitespeed-minion | **Domain-specific** | Logging, metrics, tracing, Core Web Vitals are entirely software/infrastructure concepts. A regulatory domain has no "observability" in this sense, though it may have audit logging requirements. |

**Key finding: None of the six dimensions are universal as currently defined.** The *pattern* of mandatory cross-cutting review is universal. The *specific dimensions and agents* are all software-development-specific.

**Recommended approach**:

1. The framework defines the *mechanism* for declaring mandatory cross-cutting dimensions (the checklist pattern, the "include by default, exclude with justification" rule, the Phase 3.5 mandatory/discretionary reviewer structure).

2. The domain adapter supplies the *specific dimensions* and the agents that fill them. The software-development adapter supplies the current six. A regulatory compliance adapter might supply: Regulatory Compliance (compliance-reviewer), Audit Trail (audit-minion), Risk Assessment (risk-minion), Documentation (regulatory-docs-minion).

3. Lucy and margo remain outside the cross-cutting checklist, as they already are today (`the-plan.md` line 438-440: "lucy and margo are governance reviewers triggered unconditionally in Phase 3.5. They operate outside this task-driven checklist."). This confirms the right separation: governance (lucy + margo) is framework-level; cross-cutting dimensions are domain-level.

4. The adapter may *add* mandatory governance reviewers beyond lucy and margo, but may not remove them.

## Proposed Tasks

### Task 1: Parameterize lucy's compliance checklists

Extract the software-specific items from lucy's AGENT.md into a domain-adapter-supplied configuration. Preserve the compliance verification *process* unchanged. Specifically:
- "Common CLAUDE.md Directives to Check" (lines 109-117): split into universal and domain-specific.
- "Configuration Consistency" (lines 131-138): make the file list adapter-supplied.
- "Content Patterns" (lines 140-144): make the pattern list adapter-supplied.

The software-development adapter provides the current values as its defaults, preserving backward compatibility.

### Task 2: Define the governance extension point in the domain adapter spec

The domain adapter configuration must include:
- `governance.mandatory_reviewers`: list that always includes `lucy` and `margo`; adapter can append domain-specific governance agents.
- `governance.review_focus_hints`: per-reviewer hints injected into the `## Your Review Focus` section of the Phase 3.5 reviewer prompt template.
- `governance.phase5_reviewers`: list that always includes `lucy` and `margo` for post-execution review; adapter can append.

### Task 3: Define the cross-cutting dimensions as adapter-supplied, not hardcoded

In `nefario/AGENT.md` "Cross-Cutting Concerns (Mandatory Checklist)" section and in `skills/nefario/SKILL.md` Phase 3.5 reviewer lists:
- Replace the hardcoded six dimensions with a reference to the adapter's declared dimensions.
- Preserve the structural rules: "include by default, exclude with justification," mandatory vs. discretionary classification, forced yes/no enumeration with rationale.
- The software-development adapter declares the current six dimensions as its defaults.

### Task 4: Document the governance contract

Create documentation specifying:
- What the framework guarantees (lucy + margo always run, CLAUDE.md compliance checking always runs, drift detection always runs, APPROVE/ADVISE/BLOCK verdict protocol always applies).
- What the adapter controls (which cross-cutting dimensions exist, which agents fill them, what convention checklists lucy checks, what review focus hints are provided).
- What the adapter cannot do (remove lucy, remove margo, skip Phase 3.5 programmatically, change the verdict protocol).

## Risks and Concerns

### Risk 1: Review focus hints become a back door for weakening governance

If domain adapters can inject arbitrary "review focus hints" into lucy's and margo's reviewer prompts, a poorly constructed adapter could effectively neuter governance by providing hints that say "focus only on X" and thereby suppress checks on Y and Z. **Mitigation**: The review focus hints must be *additive* -- they extend the default review focus, they do not replace it. Lucy's core checks (drift detection, CLAUDE.md compliance, traceability) always run regardless of hints. Document this as a constraint.

### Risk 2: Cross-cutting dimension flexibility could lead to adapters with zero cross-cutting review

If the framework allows adapters to define their own cross-cutting dimensions, an adapter could declare an empty list, effectively skipping all cross-cutting review except governance. **Mitigation**: Require at least one cross-cutting dimension per adapter. Or, more pragmatically, make it a documented recommendation rather than an enforcement -- the framework cannot prevent misconfiguration, but it can make the correct path obvious.

### Risk 3: Backward compatibility -- existing orchestration must not break

The software-development adapter must produce identical behavior to the current hardcoded system. Every place in `skills/nefario/SKILL.md` and `nefario/AGENT.md` that currently hardcodes agent names (security-minion, test-minion, ux-strategy-minion in the mandatory list; the discretionary pool of five; the Phase 5 three-reviewer list) must resolve to the same agents when the software-development adapter is active. **Mitigation**: The first implementation step should be a "software-dev adapter" that is a thin wrapper over the current hardcoded values, verified by checking that no behavioral change occurs.

### Risk 4: Complexity of the adapter configuration itself

The adapter must declare governance extensions, cross-cutting dimensions, convention checklists, review focus hints, and more. If the adapter configuration becomes complex, we defeat the purpose of making the system accessible to non-software forks. **Mitigation**: Keep the adapter configuration minimal and well-defaulted. A domain adapter should be able to start with just an agent roster and a phase sequence; governance, cross-cutting, and convention checking should have sensible defaults that work without explicit configuration.

### Risk 5: Lucy's AGENT.md becomes domain-aware in the wrong way

If lucy's prompt is modified to say "read the domain adapter configuration and apply its checklists," we are coupling lucy to the adapter mechanism. Lucy should remain unaware of "adapters" as a concept. Instead, lucy reads CLAUDE.md files and checks conventions -- the adapter mechanism ensures the right CLAUDE.md content is in place. **Mitigation**: The adapter writes/generates the appropriate CLAUDE.md and configuration files; lucy discovers them through its existing mechanisms. No adapter-awareness in lucy's prompt.

## Additional Agents Needed

- **ai-modeling-minion**: The changes to lucy's and margo's AGENT.md prompts, nefario's AGENT.md, and SKILL.md are all prompt engineering work. ai-modeling-minion should review the proposed parameterization to ensure the prompts remain effective when parameterized (prompt quality can degrade when you replace specific instructions with generic templates).

- **devx-minion**: The domain adapter configuration format is a developer experience problem. devx-minion should contribute to the design of the adapter configuration schema to ensure it is intuitive and well-documented for the target audience (people forking for non-software domains who are not deeply familiar with the framework internals).
