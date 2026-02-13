# Meta-Plan: Separate Domain-Specific Orchestration from Infrastructure

## Planning Consultations

### Consultation 1: Multi-Agent Architecture Separation Patterns

- **Agent**: ai-modeling-minion
- **Planning question**: The nefario AGENT.md and SKILL.md currently intermingle domain-specific configuration (software-development agent roster, delegation table, cross-cutting concern checklist, Phase 3.5 mandatory/discretionary reviewer lists, gate classification heuristics, post-execution phase semantics) with domain-independent infrastructure (subagent spawning protocol, scratch file management, status line mechanics, compaction checkpoints, report generation, team lifecycle, message delivery). What architectural patterns from multi-agent systems would best support extracting the domain-specific parts into a swappable "domain adapter" without requiring changes to the infrastructure? Specifically: (a) What should the interface contract look like between the orchestration engine and a domain adapter? (b) How should the adapter declare its phase sequence, given that the current 9-phase model (with conditional phases 5-8) is software-development-specific? (c) What are the risks of over-abstraction -- at what point does a generic orchestration framework lose the coherence that makes the current software-dev specialization effective?
- **Context to provide**: `skills/nefario/SKILL.md` (full file -- the 2328-line orchestration workflow), `nefario/AGENT.md` (the orchestrator's system prompt containing the agent roster, delegation table, cross-cutting checklist, gate classification, and architecture review rules), `docs/orchestration.md` (the nine-phase architecture documentation), `docs/external-skills.md` (existing skill integration pattern -- relevant as a precedent for pluggable components)
- **Why this agent**: ai-modeling-minion has deep expertise in multi-agent architectures, prompt engineering patterns, and the Anthropic agent model. The domain adapter concept is fundamentally about designing an interface between an orchestration engine and pluggable domain configurations -- this is a multi-agent architecture design question that requires understanding how prompt composition, agent identity, and coordination semantics interact.

### Consultation 2: Intent Alignment and Convention Enforcement for Domain Adapters

- **Agent**: lucy
- **Planning question**: The current governance model (lucy for intent alignment, margo for simplicity) is hardcoded as mandatory Phase 3.5 reviewers and Phase 5 code reviewers. In a domain-adapted system, governance still needs to operate but the criteria for "intent alignment" and "convention compliance" change per domain. How should the domain adapter declare governance requirements while preserving the unconditional nature of governance review? Specifically: (a) Should governance agents (lucy, margo) remain universal and domain-agnostic, receiving domain context from the adapter, or should each domain define its own governance agents? (b) How do we ensure that CLAUDE.md compliance checking remains functional when the orchestration framework serves domains with different convention structures? (c) What is the minimum set of conventions that are truly domain-independent (and thus belong in the framework) vs. what is domain-specific (and belongs in the adapter)? Consider the current six cross-cutting dimensions (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability) -- which are universal and which are software-development-specific?
- **Context to provide**: `lucy/AGENT.md` (lucy's governance scope -- intent alignment, convention enforcement, goal drift), `margo/AGENT.md` (margo's scope -- YAGNI/KISS, simplicity), `nefario/AGENT.md` sections on Cross-Cutting Concerns and Architecture Review, `skills/nefario/SKILL.md` Phase 3.5 and Phase 5 reviewer spawning, the project's CLAUDE.md
- **Why this agent**: Lucy's expertise is precisely in the boundary between "what the human intended" and "what the system does." The domain adapter separation is fundamentally a question about which governance constraints are universal (belong in the framework) and which are domain-contingent (belong in the adapter). Lucy is the right agent to reason about whether intent-alignment machinery can operate across domains or needs domain-specific calibration.

### Consultation 3: Simplicity Enforcement on the Separation Boundary

- **Agent**: margo
- **Planning question**: The issue explicitly states "do not narrow or dismiss this work as YAGNI" -- the separation is a deliberate architectural investment. Given that constraint, how do we avoid the opposite failure mode: over-engineering the adapter interface? Specifically: (a) What is the minimum viable adapter contract -- what is the smallest set of domain-specific declarations that enables meaningful domain switching? (b) Where is the line between "making existing structure explicit and swappable" (the stated goal) and "building a plugin framework with extension points we don't need yet"? (c) The current SKILL.md is 2328 lines with deeply interleaved domain logic and infrastructure. What decomposition approach keeps the resulting pieces simple rather than creating a complex indirection layer? (d) How should we handle the parts of SKILL.md that are "mostly infrastructure but with domain-specific parameters" (e.g., Phase 4 execution loop is infrastructure, but the commit message format `<type>(<scope>): <summary>` is a software-dev convention)?
- **Context to provide**: `skills/nefario/SKILL.md` (the full orchestration workflow -- primary target for separation), `nefario/AGENT.md` (the agent system prompt -- secondary target), `docs/orchestration.md`, the issue's explicit anti-YAGNI constraint, the project's Helix Manifesto engineering philosophy
- **Why this agent**: Margo's core mission is preventing over-engineering while respecting intentional architectural decisions. This task has a unique tension: the user has explicitly authorized complexity investment for reusability, but the project's engineering philosophy (YAGNI, KISS, Lean and Mean) normally resists it. Margo is the right agent to find the balance point -- the simplest decomposition that achieves the stated reusability goal without building unnecessary abstraction layers.

### Consultation 4: Developer Experience of the Domain Adapter Interface

- **Agent**: devx-minion
- **Planning question**: A domain adapter author (someone forking despicable-agents for regulatory compliance or corpus linguistics) needs to understand: what do I define, what does the framework handle, and how do I test my adapter? Design the developer experience of creating a domain adapter. Specifically: (a) What should the adapter file format look like -- YAML config, markdown with frontmatter, a directory structure, or something else? Consider that the existing system uses markdown extensively (AGENT.md, SKILL.md, CLAUDE.md). (b) What documentation is needed for adapter authors -- a reference spec, a getting-started tutorial, an annotated example adapter (the current software-dev config extracted as the default adapter)? (c) How does the adapter author validate their configuration -- is there a check/lint step (analogous to `/despicable-lab --check`)? (d) What error messages should the framework produce when an adapter is misconfigured -- missing required fields, invalid phase references, etc.? (e) How does install.sh change -- does it need to know about adapters, or is adapter selection a runtime concern?
- **Context to provide**: `skills/nefario/SKILL.md` (the workflow that adapter authors need to understand), `nefario/AGENT.md` (the system prompt that adapter declarations feed into), `.claude/skills/despicable-lab/SKILL.md` (existing validation pattern), `install.sh` (current deployment mechanism), `docs/using-nefario.md` (current user-facing docs), the issue's success criteria about documentation
- **Why this agent**: devx-minion specializes in developer onboarding, configuration file design, CLI design, SDK design, and error messages. The domain adapter is primarily a developer-facing interface -- its success depends on whether a non-contributor can fork the project and create a working adapter without reading the full 2328-line SKILL.md. This is a developer experience design problem as much as an architectural one.

## Cross-Cutting Checklist

- **Testing**: Not included for planning. No executable code will be produced -- the output is architectural documentation and configuration format design. test-minion will be included in execution (Phase 3.5 mandatory reviewer) to validate that test strategy is preserved for the default software-dev adapter.
- **Security**: Not included for planning. The domain separation does not introduce new attack surface, authentication, user input handling, or secrets management. security-minion will be included in execution (Phase 3.5 mandatory reviewer) to verify the separation does not weaken existing security properties.
- **Usability -- Strategy**: ALWAYS include. ux-strategy-minion is not in the pre-selected team, but their concern (journey coherence for adapter authors) is partially covered by devx-minion's planning question on developer experience. At execution time, ux-strategy-minion participates as a mandatory Phase 3.5 reviewer to evaluate journey coherence of the adapter authoring experience.
- **Usability -- Design**: Not included for planning. No user-facing interfaces are being designed -- the adapter is a configuration/file format, not a visual UI. ux-design-minion and accessibility-minion are not needed.
- **Documentation**: ALWAYS include. software-docs-minion is not in the pre-selected team, but documentation is a core deliverable of this task (the issue's success criteria explicitly require documentation explaining the separation boundary). devx-minion's planning question covers the documentation design aspect. software-docs-minion will participate in execution Phase 8 to produce the actual architecture documentation.
- **Observability**: Not included for planning. No runtime components, services, or APIs are being created. observability-minion and sitespeed-minion are not needed.

## Anticipated Approval Gates

1. **Domain Adapter Contract Definition** (MUST gate) -- The interface contract between orchestration engine and domain adapter. Hard to reverse (all downstream work depends on this contract), high blast radius (every adapter-related deliverable depends on it). This is the foundational architectural decision.

2. **SKILL.md Decomposition Plan** (MUST gate) -- How the 2328-line SKILL.md is split into infrastructure vs. domain-specific sections. Hard to reverse (restructuring a 2328-line file creates significant rework if wrong), high blast radius (affects both the framework and the default software-dev adapter).

3. **AGENT.md Domain Extraction** (OPTIONAL gate) -- How domain-specific content (roster, delegation table, cross-cutting checklist) is extracted from nefario/AGENT.md. Easier to reverse (additive configuration), but has 2+ dependents. Gate if the extraction approach involves significant judgment calls.

## Rationale

The four pre-selected specialists cover the critical planning dimensions:

- **ai-modeling-minion**: The separation is fundamentally a multi-agent architecture question -- how to parameterize an orchestration engine over domain-specific agent configurations. ai-modeling-minion brings expertise in agent coordination patterns and interface design.
- **lucy**: Governance (intent alignment, convention enforcement) is the hardest thing to make domain-generic. Lucy's expertise determines whether governance agents can be universal or must be domain-specific.
- **margo**: The tension between "deliberate architectural investment" and "YAGNI/KISS" is exactly margo's domain. Without margo's input, the plan risks over-engineering the adapter interface.
- **devx-minion**: The adapter's success is measured by developer experience -- can a forker create a working adapter without deep framework knowledge? devx-minion ensures the plan optimizes for this outcome.

Agents not included in planning (but relevant to execution):
- **software-docs-minion**: Will produce documentation in Phase 8, but does not need to shape the plan. The documentation structure follows from the adapter contract (defined by ai-modeling-minion + devx-minion).
- **test-minion**, **security-minion**, **ux-strategy-minion**: Mandatory Phase 3.5 reviewers. Their review ensures execution quality but they don't contribute unique planning insight beyond what the four selected specialists cover.

## Scope

**What the overall task is trying to achieve**: Extract domain-specific configuration (agent roster, phase definitions, gate/approval semantics, coordination patterns, cross-cutting concern definitions) from domain-independent infrastructure (skill discovery, subagent spawning, team mechanics, scratch file management, report generation, compaction, status lines) in nefario's SKILL.md and AGENT.md. The result is a separation boundary that enables domain adapters -- a forker can define their own agents, phases, gates, and coordination semantics without modifying infrastructure files.

**In scope**:
- nefario SKILL.md orchestration logic decomposition (2328 lines)
- nefario AGENT.md domain-specific content extraction (agent roster, delegation table, cross-cutting checklist, gate classification, architecture review rules)
- Domain adapter contract definition (what an adapter must provide)
- Documentation of the separation boundary (what is framework vs. what is adapter)
- Default software-development adapter (extracting current behavior as the first adapter)
- Preserving identical behavior for current software-development orchestration

**Out of scope**:
- Building non-software-domain agent sets (IVDR, linguistics, etc.)
- Changing the agent file format (AGENT.md structure, frontmatter schema)
- Modifying Claude Code platform integration
- Changes to install.sh deployment mechanism (unless adapter selection requires it)
- Changes to the-plan.md
- Changes to individual minion AGENT.md files

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent build/rebuild validation | Not relevant to this task. No inclusion in plan. |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Not relevant to this task. No inclusion in plan. |

User-global skills (non-despicable-agents): `daily-recap`, `juli`, `obsidian-tasks`, `recap`, `session-review`, `srf-gruppennewsletter`, `transcribe`. None relevant to this task.

### Precedence Decisions

No precedence conflicts. Neither discovered project-local skill overlaps with any specialist needed for this task.
