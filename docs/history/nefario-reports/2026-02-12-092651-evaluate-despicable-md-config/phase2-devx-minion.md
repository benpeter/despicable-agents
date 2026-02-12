## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Dedicated File vs. CLAUDE.md Section: CLAUDE.md Section Wins

After evaluating both approaches against DX fundamentals, I strongly recommend **against** introducing `DESPICABLE.md` / `DESPICABLE.local.md` as dedicated files. A `## Despicable Agents` section within the existing `CLAUDE.md` / `CLAUDE.local.md` is the better choice. Here is the analysis across three dimensions:

**Discoverability**: `CLAUDE.md` is already the canonical place developers look for project-level AI configuration. Every Claude Code user knows this file. A `DESPICABLE.md` file is invisible until someone tells you it exists. There is no `claude --help` output, no Claude Code documentation, and no IDE integration that would surface `DESPICABLE.md` as meaningful. A section in `CLAUDE.md` is discovered by anyone reading the file they already know about. The existing external skill precedence system (Decision 28, Tier 1) already routes through `CLAUDE.md` -- splitting configuration across two files means developers must check two places to understand routing behavior.

**Maintainability**: One file to maintain vs. two. A dedicated file introduces a new file lifecycle (creation, updates, git tracking, `.local.md` variant gitignoring). Every project that adopts despicable-agents adds two potential files to manage. The CLAUDE.md section approach means zero new files -- configuration lives where it already belongs. Drift between CLAUDE.md and DESPICABLE.md is a real risk: what happens when CLAUDE.md says "prefer vanilla JS" but DESPICABLE.md tells the frontend-minion to use React? Precedence rules create hidden complexity.

**Cognitive overhead**: Tool proliferation is the enemy of developer experience. Every new config file is a concept a developer must learn, remember, and maintain. The `.eslintrc` vs. `package.json` eslint key comparison is instructive: the ecosystem moved TOWARD consolidation (`eslint.config.js` flat config), not away from it. `tsconfig.json` exists because TypeScript genuinely needs its own file -- the configuration surface is enormous. Despicable-agents configuration is small enough (a few preferences, maybe agent exclusions) to fit comfortably in a CLAUDE.md section.

The Helix Manifesto principle applies: "YAGNI -- don't build it until you need it." No consuming project has yet expressed a need for more configuration surface than CLAUDE.md provides. Decision 26 already rejected a `.nefario.yml` config file as YAGNI.

#### 2. If a Dedicated File Is Adopted Anyway: Freeform Markdown

If the team overrides my recommendation and introduces a dedicated file, the format should be **freeform markdown** (same as CLAUDE.md), not YAML frontmatter + body or pure structured data.

Rationale:
- **Consistency**: CLAUDE.md and CLAUDE.local.md are freeform markdown. A third config file in a different format breaks the mental model.
- **LLM-native**: Claude reads and reasons about markdown natively. Structured YAML/TOML requires parsing logic in agent prompts -- and if nefario or individual agents must parse it, that is prompt bloat for the one agent (nefario) that reads this file.
- **Low barrier**: A developer can start with `## Agent Preferences\n\nSkip seo-minion for this project.` and it works. No schema to learn, no validation to pass.
- **Flexible**: Freeform text handles both well-known preferences ("exclude X") and emergent ones ("prefer monorepo patterns for all infrastructure") without schema changes.

The only case for structured data would be if tooling (not LLMs) needs to parse the file programmatically. There is no such tooling in the current architecture, and building it would be speculative.

#### 3. Configuration Options: Realistic Utility Assessment

**Agent exclusion** (e.g., "skip seo-minion for this project"):
- Utility: **LOW**. The current system already handles this implicitly -- nefario's meta-plan only consults agents relevant to the task. A project that never touches SEO never invokes seo-minion. Explicit exclusion is only needed when nefario consistently misjudges relevance, which is a bug to fix in nefario, not a config to work around. Edge case: a backend-only project where nefario still recommends frontend-minion review. Even then, Phase 3.5 conditional reviewer logic already gates on task type.
- Recommendation: **Do not implement**. If needed, a one-line note in CLAUDE.md suffices: "This is a backend API project; no frontend or web UI work."

**Domain spin** (e.g., "this project uses Kubernetes heavily, emphasize edge-minion"):
- Utility: **MEDIUM**. This is essentially what CLAUDE.local.md already does in the despicable-agents project itself (technology bias preferences). Any project can add `## Technology Preferences` to CLAUDE.md today and agents will read it. A dedicated mechanism adds no value over what already works.
- Recommendation: **Document the pattern** rather than building a mechanism. Show examples of how CLAUDE.md sections influence agent behavior.

**Orchestration overrides** (e.g., "skip Phase 3.5 for this project", "max 2 gates"):
- Utility: **LOW to DANGEROUS**. Phase 3.5 is non-skippable by design (Decision 15). Gate budgets are already calibrated. Allowing per-project orchestration overrides undermines the governance model. If a project can disable security review, the security guarantee is worthless. The user can already override at runtime (`MODE: PLAN`, explicit skip requests).
- Recommendation: **Do not implement**. Orchestration parameters belong in the skill, not in per-project config. Runtime overrides via user commands already cover legitimate use cases.

**Default reviewers / always-skip reviewers**:
- Utility: **VERY LOW**. Conditional reviewers are already gated by task type. Forcing a reviewer on or off for an entire project is too coarse -- it should be per-task, which is already handled by nefario's reviewer selection logic.
- Recommendation: **Do not implement**.

**Skill preferences** (e.g., "Always use .skills/deploy for deployment"):
- Utility: **ALREADY EXISTS**. This is Precedence Tier 1 in the external skill integration system (Decision 28). It already reads from CLAUDE.md. No new mechanism needed.
- Recommendation: **Already done**. Just document it.

Net assessment: **None of the proposed configuration options justify a new file.** Everything either already works via CLAUDE.md, or should not be configurable.

#### 4. Discovery Mechanism: Nefario at Planning Time Only

If any file-based configuration is adopted, it should be discovered by **nefario at Phase 1 (meta-plan) only**, not by individual agents at runtime.

Rationale:
- **Single reader**: Only one agent (nefario) needs to understand project-level orchestration preferences. Individual minions receive their instructions through task prompts that nefario constructs.
- **Context efficiency**: Reading a config file in 27 agents wastes 27x the context for information that should be absorbed once and distributed through task prompts.
- **Consistency**: If each agent independently reads the config, they may interpret it differently. Nefario as the single interpreter ensures consistent application.
- **Already the pattern**: Nefario already reads CLAUDE.md during meta-planning for external skill preferences. Extending this to read a section of CLAUDE.md is zero additional discovery logic.

#### 5. Getting Started Experience: Purely Optional, Zero-Config Default

The "getting started" experience must be: install (`./install.sh`), use (`/nefario <task>`). No file creation required.

This aligns with the zero-config principle: 80% of users should never need to change configuration. The existing CLAUDE.md (which every Claude Code project already has or quickly creates) is sufficient. If a user wants to influence agent behavior, they add a section to their existing CLAUDE.md. No new file, no new concept, no new documentation page to read.

Time to first success should not increase by even one step. The current TTFS for despicable-agents is already good (install + invoke). Adding a "create DESPICABLE.md" step would be a regression.

#### 6. Error Cases Assessment

If CLAUDE.md section approach is used (recommended):
- **Invalid content**: Not possible in the traditional sense -- it is freeform markdown interpreted by an LLM. "Invalid" means "unclear", which the LLM handles gracefully by ignoring or asking for clarification. No parsing errors, no startup validation needed.
- **Conflicts with CLAUDE.md**: Cannot conflict because it IS CLAUDE.md. The section is part of the same document.
- **References to nonexistent agents**: Nefario already resolves agent names against its delegation table. An unknown agent name in a CLAUDE.md preference is handled the same way as an unknown agent name in any other context -- nefario ignores it or maps to the closest match. No special error handling needed.

If dedicated DESPICABLE.md were adopted (not recommended):
- **Invalid content**: With freeform markdown, same as above. With structured YAML, you need schema validation, error messages, and a validation step. This is build complexity for marginal value.
- **Conflicts with CLAUDE.md**: This is the dangerous case. CLAUDE.md says "vanilla JS", DESPICABLE.md says "use React for frontend-minion." Precedence must be defined and documented. Users must understand which file wins. This is exactly the cognitive overhead that makes dedicated files worse.
- **Missing file**: Must be optional. Must not produce warnings or errors. Must not degrade behavior.
- **References to nonexistent agents**: Must fail gracefully. Error message should list valid agent names. Must not crash nefario or block orchestration.

### Proposed Tasks

**Task 1: Document the CLAUDE.md configuration pattern**
- What: Write a section in the user-facing documentation (e.g., `docs/using-nefario.md` or a new `docs/project-configuration.md`) showing how consuming projects can influence despicable-agents behavior through CLAUDE.md sections.
- Deliverables: Documentation with 3-4 examples (technology preferences, skill routing, project context for agent selection).
- Dependencies: None.

**Task 2: Add example CLAUDE.md sections to getting-started documentation**
- What: Show concrete examples in quickstart/onboarding docs: "If your project is backend-only, add this to CLAUDE.md: ..." and "If you prefer certain technologies, add this: ..."
- Deliverables: 4-6 example snippets integrated into existing docs.
- Dependencies: Task 1.

**Task 3: Validate that nefario already reads CLAUDE.md preferences correctly**
- What: Confirm that nefario's Phase 1 meta-plan step already reads and applies CLAUDE.md preferences for skill routing and project context. If gaps exist, document them.
- Deliverables: Verification report; any gaps logged as issues.
- Dependencies: None.

### Risks and Concerns

1. **Scope creep into configuration infrastructure**: The biggest risk is that evaluating configuration surface leads to building configuration infrastructure. Decision 26 explicitly rejected `.nefario.yml` as YAGNI. The same principle applies here. The existing CLAUDE.md pattern covers all realistic needs. Building a new file format, discovery mechanism, validation layer, and error handling for it would violate YAGNI, KISS, and Lean-and-Mean simultaneously.

2. **Precedence complexity**: Introducing a second configuration file immediately creates precedence questions. CLAUDE.md says X, DESPICABLE.md says Y -- which wins? This is the same problem that plagued the `package.json` vs `.eslintrc` split in the ESLint ecosystem, which they ultimately resolved by moving toward a single flat config file.

3. **Onboarding friction**: Every new file a project must know about increases the learning curve. despicable-agents is a globally-installed toolkit -- it should feel invisible, not demand project-level setup. The best developer tool is the one nobody notices because it just works.

4. **Documentation debt**: A dedicated file requires its own documentation: what it does, how to create it, what options exist, how it interacts with CLAUDE.md, the .local.md variant for private settings, error handling. This is documentation that does not need to exist if the answer is "put it in CLAUDE.md."

### Additional Agents Needed

- **software-docs-minion**: Should review whatever documentation approach is chosen to ensure it integrates with existing docs structure and maintains consistent style. Already likely involved in the planning phase.
- **margo**: Should validate that the chosen approach satisfies YAGNI/KISS. Given that my recommendation is "do not build this," margo's assessment is particularly relevant as a second opinion on whether the complexity is justified.

No other additional agents are needed. This is primarily a DX design decision, not a multi-domain technical problem.
