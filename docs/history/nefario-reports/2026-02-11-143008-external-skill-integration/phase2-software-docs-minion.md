# Phase 2 Contribution: software-docs-minion

## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Documentation Artifacts Needed

The integration surface requires **three documentation artifacts**, not one monolithic document. Each serves a distinct audience with distinct goals:

**Artifact A: `docs/external-skills.md` (new file)**
The architecture-level document. Covers the integration model: how nefario discovers external skills, the precedence rules, the deferral mechanism, and the trust boundaries. This is the "how it works" reference for anyone who needs to understand the system design. Uses C4 component-level detail to show the discovery and delegation flow. Linked from `docs/architecture.md` in the Sub-Documents table.

**Artifact B: Section additions to `docs/using-nefario.md`**
The user perspective. A new section ("Working with External Skills") added after the existing "Tips for Success" section. Task-oriented: "I have a project with CDD skills and I installed despicable-agents. What happens when I run `/nefario`?" Shows the user experience, not the internals. Covers: what the user sees in the meta-plan when external skills are detected, how to override precedence if nefario picks the wrong handler, and common failure modes with recovery paths.

**Artifact C: Standalone integration guide (location TBD -- see recommendation 4)**
The skill maintainer perspective. A slim, self-contained document that a skill author can read without any other despicable-agents documentation. Covers: what nefario looks for in SKILL.md, optional annotations that improve orchestration quality, and what "compatible with orchestrators" means in practice. This document must be readable in under 5 minutes and must not require understanding of nefario's nine-phase process.

**Not a separate artifact**: Updates to `docs/architecture.md` are minimal -- add one row to the Sub-Documents table linking to `docs/external-skills.md`. The Context diagram does not need modification because external skills are already part of the "Target Codebase" system boundary (they live in the project's `.skills/` directory). A Container-level annotation showing skill discovery paths may be useful if the architecture of discovery warrants it.

**Not a separate artifact**: No ADR is needed for the integration mechanism itself. The design decision should be recorded in `docs/decisions.md` as a new numbered decision (Decision 28 or later), following the existing format. An ADR is the wrong format here because this project uses its own decision log format, not standalone ADR files.

#### 2. Minimal Integration Contract for Skill Maintainers

The contract must be ruthlessly minimal. External skill authors should not need to learn despicable-agents to benefit from it. The contract has three tiers:

**Tier 0 (zero effort -- works already):**
Any SKILL.md with a `name:` and `description:` in YAML frontmatter is discoverable. Nefario reads the description to understand what the skill does. This is already the Claude Code skill format -- no changes needed from skill authors.

**Tier 1 (optional -- improves orchestration routing):**
A skill can add a `keywords:` field to its frontmatter (a list of domain terms) that helps nefario match tasks to skills more precisely. Example: `keywords: [aem, edge delivery, content, blocks]`. This is purely additive. Skills without keywords work fine; skills with keywords get better routing.

**Tier 2 (optional -- enables deferral):**
A skill that has its own multi-step workflow (like CDD's content-first process) can signal this to orchestrators. The exact signaling mechanism should be defined by devx-minion and ai-modeling-minion. From the documentation perspective, whatever they decide must be documented as "optional -- your skill works without this, but adding it enables orchestrators to defer to your workflow instead of wrapping it."

**Critical constraint**: The contract document must explicitly state that tiers 1 and 2 are backwards-compatible annotations. A skill with these annotations continues to work identically in Claude Code without despicable-agents installed. The annotations are metadata, not behavioral changes.

#### 3. Documenting "No Coupling"

The "no coupling" principle is the hardest documentation challenge in this task. The risk is that documentation *implies* coupling even when the mechanism does not require it. Three documentation strategies:

**Strategy A: Lead with "works without changes"**
Every section about integration should open with what works at zero effort. The CDD skills example: "Install despicable-agents into a project with CDD skills. Run `/nefario 'build a new block'`. Nefario reads the existing SKILL.md descriptions and includes CDD in the plan. No changes to CDD skills required." Then, and only then, describe optional improvements.

**Strategy B: Use "enhances" language, never "requires"**
The maintainer guide should consistently use framing like "Adding keywords to your SKILL.md frontmatter enhances orchestration routing" rather than "Orchestration requires keywords." Every annotation section should include a callout: "This annotation is optional. Your skill works with nefario without it."

**Strategy C: Show the skill working both ways**
The maintainer guide should include a concrete example of a SKILL.md that works both standalone (invoked directly via `/skill-name`) and under orchestration (discovered and delegated to by nefario). The example should be the same file in both cases -- no despicable-agents-specific configuration file.

#### 4. Where Integration Content Should Live

The existing doc structure has a clear separation:

- **User-facing**: `using-nefario.md`, `agent-catalog.md`
- **Contributor/Architecture**: `architecture.md`, `orchestration.md`, `decisions.md`, etc.

Integration content spans both. Recommended placement:

| Content | Location | Rationale |
|---------|----------|-----------|
| Architecture of discovery/deferral | `docs/external-skills.md` (new) | Contributor-facing reference. Too detailed for using-nefario.md, too specific for architecture.md. Follows the existing pattern of topic-specific sub-documents. |
| User-facing "how to combine" | `docs/using-nefario.md` new section | Users already go here for orchestration guidance. A new section keeps it findable. |
| Skill maintainer integration guide | `docs/external-skills.md` section OR standalone file in repo root | This is the debatable one. See below. |
| Design decision | `docs/decisions.md` new entry | Follows existing pattern. |
| Architecture overview update | `docs/architecture.md` Sub-Documents table | One row addition, minimal change. |

**The maintainer guide placement debate**: The skill maintainer guide could live in `docs/external-skills.md` as a section, or as a standalone file (e.g., `INTEGRATION.md` at repo root or `docs/skill-integration-guide.md`). Arguments for standalone: skill maintainers should not need to navigate the despicable-agents doc tree; a single linkable URL is easier to share. Arguments against standalone: another top-level file adds clutter; the content is small (under 100 lines). My recommendation: put it in `docs/external-skills.md` as a clearly labeled section with its own heading anchor, then link to that anchor from the README. The README link serves the "single URL to share" need without adding a top-level file.

### Proposed Tasks

#### Task 1: Write `docs/external-skills.md`

**What to do**: Create the architecture-level document covering the external skill integration model. Structure:
1. Introduction (one paragraph: what this document covers, who it is for)
2. Discovery model (how nefario finds skills, what it reads, the three-tier contract)
3. Precedence rules (internal specialist vs. external skill, with examples)
4. Deferral mechanism (orchestration skills vs. leaf skills, what deferral looks like)
5. Integration guide for skill maintainers (the standalone-readable section)
6. Trust and security considerations (summary of security-minion findings)

Include a Mermaid sequence diagram showing the discovery flow during Phase 1.

**Deliverables**: `docs/external-skills.md`

**Dependencies**: Depends on the integration surface design (Gate 1) and deferral mechanism design (Gate 2) being finalized. This task cannot be written until devx-minion and ai-modeling-minion have defined the discovery mechanism, precedence rules, and deferral approach. Documentation describes the design, it does not create the design.

#### Task 2: Add "Working with External Skills" section to `docs/using-nefario.md`

**What to do**: Add a user-facing section to the existing using-nefario guide. Task-oriented structure:
- "What happens when external skills are present" (the zero-config experience)
- "How nefario shows external skills in the plan" (reading the meta-plan output)
- "Overriding skill selection" (when nefario picks the wrong handler)
- "Troubleshooting" (skill not detected, wrong skill selected, deferral not working)

**Deliverables**: Updated `docs/using-nefario.md`

**Dependencies**: Same as Task 1 (needs finalized design). Also benefits from ux-strategy-minion input on the user journey to ensure the section addresses the right confusion points.

#### Task 3: Update `docs/architecture.md` Sub-Documents table

**What to do**: Add one row to the Contributor/Architecture table linking to `docs/external-skills.md`. Optionally add a brief mention in the "Design Philosophy" section about composability with external skills (extends the existing "Composable" bullet).

**Deliverables**: Updated `docs/architecture.md`

**Dependencies**: Task 1 (the document must exist before linking to it).

#### Task 4: Add design decision to `docs/decisions.md`

**What to do**: Add a new numbered decision entry documenting the external skill integration design choice. Follow the existing format (Status, Date, Choice, Alternatives rejected, Rationale, Consequences). This should capture whatever design devx-minion and ai-modeling-minion propose and whatever is ultimately approved at the design gates.

**Deliverables**: Updated `docs/decisions.md`

**Dependencies**: Depends on the design being finalized and approved. This is a post-execution documentation task (Phase 8 material), not a pre-execution task.

#### Task 5: Update README.md

**What to do**: Add a brief mention of external skill integration to the README. Candidates:
- A sentence under "Using on Other Projects" about external skill compatibility
- A link to `docs/external-skills.md` in the Documentation section under "Using the agents"

Keep changes minimal. The README should signal that this capability exists and point to the full docs, not explain the mechanism.

**Deliverables**: Updated `README.md`

**Dependencies**: Task 1 (document must exist to link to).

### Risks and Concerns

**Risk 1: Documentation preceding design.**
Documentation tasks depend entirely on the design decisions made by devx-minion (discovery) and ai-modeling-minion (deferral). If the design is not crisp, the documentation will be vague. Mitigation: documentation tasks should be scheduled after the design gates, not in parallel with design tasks.

**Risk 2: Maintainer guide implying mandatory coupling.**
The skill maintainer guide is the highest-risk document for accidentally creating perceived coupling. If the guide is too detailed about nefario internals, skill maintainers may conclude they need to understand nefario to integrate. Mitigation: the maintainer section should be reviewed by someone outside the despicable-agents team (or at least by margo for over-engineering of the contract itself).

**Risk 3: Documentation scope creep.**
The integration surface could generate extensive documentation about every edge case (what if two external skills conflict? what if an external orchestrator has different phase names?). Mitigation: document only what the MVP mechanism supports. Edge cases that are not yet handled should not be documented as if they are.

**Risk 4: Staleness of external skill examples.**
If the documentation uses specific external skills (CDD, building-blocks) as examples, those examples become stale if the external skills change. Mitigation: use external skills as illustrative examples but define the contract in terms of SKILL.md fields, not specific skill behavior. Consider a synthetic minimal example alongside the real-world example.

**Risk 5: Two-audience document may serve neither well.**
Putting both the architecture reference and the maintainer guide in one file (`docs/external-skills.md`) risks making the document too long for maintainers and too shallow for contributors. Mitigation: use clear section headings and make the maintainer section self-contained (can be read without reading the preceding sections). If the document exceeds 300 lines during writing, split the maintainer guide into its own file.

### Additional Agents Needed

**user-docs-minion** should be involved in execution (not planning) for Task 2. The "Working with External Skills" section in `using-nefario.md` is a user-facing how-to guide. While software-docs-minion can draft it (it is closely tied to the architecture), user-docs-minion should review it for task-oriented clarity and readability from a non-expert user perspective.

**product-marketing-minion** should review the README changes (Task 5) during Phase 8 to ensure the external skill integration message is positioned clearly for developers evaluating whether to adopt despicable-agents.

No additional planning specialists are needed beyond what the meta-plan already identified.
