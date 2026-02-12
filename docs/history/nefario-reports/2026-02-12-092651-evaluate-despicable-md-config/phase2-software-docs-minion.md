## Domain Plan Contribution: software-docs-minion

### Recommendations

**DESPICABLE.md has clear wins and aligns with documentation minimalism principles.**

The documentation impact analysis reveals that introducing DESPICABLE.md (with DESPICABLE.local.md for user-private overrides) is the superior approach compared to CLAUDE.md sections or status quo. Here is why:

#### 1. Dedicated File (DESPICABLE.md) Approach

**Pros:**
- **Separation of concerns**: Keeps framework-specific configuration out of general CLAUDE.md instructions
- **Discoverability**: New contributors immediately see despicable-agents has configuration when they see DESPICABLE.md
- **Reusability**: Configuration pattern can be copied across projects without extracting from larger CLAUDE.md
- **Versioning**: Framework config changes are isolated in git history from general tooling changes
- **Progressive disclosure**: Users learn general Claude Code conventions first (CLAUDE.md), then framework specifics (DESPICABLE.md)

**Cons:**
- **One more file**: Adds to file count in project root
- **Documentation burden**: Need to document the file's existence and precedence rules

#### 2. CLAUDE.md Section Approach

**Pros:**
- **Single source**: All project instructions in one place
- **No new convention**: Uses existing Claude Code pattern

**Cons:**
- **Poor separation**: Framework config mixes with general project instructions
- **Discovery friction**: Contributors must read full CLAUDE.md to find despicable-agents settings
- **Reusability friction**: Copying framework config requires manual extraction
- **Version noise**: Framework updates pollute general project instruction history

#### 3. Status Quo (No Framework Config)

**Cons:**
- **Repeated patterns**: Each project rediscovers conventions like "external skill precedence goes in CLAUDE.md"
- **No guidance**: Users do not know where to put despicable-specific configuration

**Recommendation: Adopt DESPICABLE.md + DESPICABLE.local.md pattern.**

The separation of concerns benefit alone justifies the extra file. The documentation burden is modest (one getting-started section, one reference doc). This aligns with Decision 5's principle: "Project-specific context belongs in the target project's CLAUDE.md" -- by creating DESPICABLE.md, we refine that to "framework-specific context belongs in DESPICABLE.md."

---

### Proposed Tasks

#### Task 1: Document DESPICABLE.md Convention in Architecture Docs

**What:** Add a new section to `docs/architecture.md` (Design Philosophy) explaining the DESPICABLE.md pattern.

**Deliverables:**
- 4-6 paragraph section in `docs/architecture.md` under "Design Philosophy" heading
- Explains when to use DESPICABLE.md vs CLAUDE.md
- States precedence rules (DESPICABLE.local.md > DESPICABLE.md > CLAUDE.md for framework-specific config)
- Examples of what belongs in each file

**Dependencies:** None (can run immediately)

---

#### Task 2: Create DESPICABLE.md Configuration Reference

**What:** Create `docs/consuming-projects.md` (new file) with full reference for DESPICABLE.md and DESPICABLE.local.md.

**Deliverables:**
- New file at `docs/consuming-projects.md`
- Structure:
  - Purpose and motivation (why DESPICABLE.md exists)
  - File locations and precedence
  - Configuration sections (external skill preferences, agent behavior overrides, orchestration defaults)
  - Complete examples for common scenarios (Rails project, Next.js project, Python service)
  - Template DESPICABLE.md file (minimal starter)
- Linked from `docs/architecture.md` sub-documents table

**Dependencies:** Task 1 (architecture section should exist before detailed reference)

---

#### Task 3: Update External Skills Documentation

**What:** Update `docs/external-skills.md` to reference DESPICABLE.md as the canonical location for skill precedence overrides.

**Deliverables:**
- Edit to "Precedence Rules" section in `docs/external-skills.md`
- Change from "If the project's CLAUDE.md declares a skill preference" to "If DESPICABLE.md or CLAUDE.md declares a skill preference"
- Add note: "Prefer DESPICABLE.md for framework-specific preferences; use CLAUDE.md for general project tooling preferences"
- Update example to show DESPICABLE.md usage

**Dependencies:** Task 2 (reference doc should exist before we point to the pattern)

---

#### Task 4: Update Using Nefario Guide

**What:** Add "Configuration" subsection to `docs/using-nefario.md` explaining how to customize nefario behavior in consuming projects.

**Deliverables:**
- New "Configuration" section in `docs/using-nefario.md` (insert after "Working Directory" section)
- 2-3 paragraphs explaining DESPICABLE.md purpose for consuming projects
- Link to `docs/consuming-projects.md` for full reference
- Quick example showing how to set orchestration defaults

**Dependencies:** Task 2 (must link to the reference doc)

---

#### Task 5: Create Template DESPICABLE.md

**What:** Add `templates/DESPICABLE.md` to the repository with commented examples.

**Deliverables:**
- New file at `templates/DESPICABLE.md`
- Heavily commented template showing:
  - External skill precedence overrides
  - Agent behavior customization
  - Orchestration defaults (e.g., "always skip Phase 7 deployment")
  - Common project types (monorepo, microservice, documentation site)
- Instructions at top: "Copy to your project root and customize"

**Dependencies:** Task 2 (template should match reference documentation structure)

---

#### Task 6: Update Deployment Documentation

**What:** Add "For Consuming Projects" section to `docs/deployment.md` pointing to configuration docs.

**Deliverables:**
- New section in `docs/deployment.md` after "Using the Toolkit"
- 1-2 paragraphs explaining that consuming projects can customize via DESPICABLE.md
- Link to `docs/consuming-projects.md`
- Note that configuration is optional (zero-config works)

**Dependencies:** Task 2 (must link to reference doc)

---

#### Task 7: Update README with Configuration Pointer

**What:** Add one-line mention in project README about configuration for consuming projects.

**Deliverables:**
- Edit to `/README.md` (likely in "Structure" or after "Deployment" section)
- Single line: "For project-specific configuration, see [Consuming Projects Guide](docs/consuming-projects.md)"
- Or add to existing "Using the Toolkit" section if one exists in README

**Dependencies:** Task 2 (must have reference doc to link to)

---

### Risks and Concerns

#### Risk 1: Configuration Sprawl

**Concern:** Users put everything in DESPICABLE.md instead of maintaining proper separation.

**Mitigation:** Clear documentation with "belongs in DESPICABLE.md" vs "belongs in CLAUDE.md" decision tree. Template file with strong comments showing boundaries.

#### Risk 2: Precedence Confusion

**Concern:** Users are confused about DESPICABLE.md vs CLAUDE.md vs DESPICABLE.local.md precedence.

**Mitigation:** Explicit precedence rules in every doc that mentions the files. Visual diagram in `docs/consuming-projects.md` showing how settings cascade.

#### Risk 3: Documentation Drift

**Concern:** As despicable-agents evolves, DESPICABLE.md examples become outdated.

**Mitigation:** Template file and examples live in the repository and are versioned. Updates to agent behavior trigger review of consuming-projects.md examples (add to checklist for spec version bumps).

#### Risk 4: Over-Engineering

**Concern:** We are creating infrastructure for a problem that does not exist yet (violates YAGNI).

**Counter-evidence:** The problem already exists -- external-skills.md references "project's CLAUDE.md" for preferences, meaning projects are already putting framework config somewhere. This formalizes existing practice rather than speculating about future needs. The one-agent rule (Decision 27) would say "wait for 2 projects to need this" -- but this is a toolkit meant to be used by multiple projects, so we cannot wait for 2 consumers before documenting consumption patterns.

---

### Additional Agents Needed

**None.** The current team is sufficient.

- **software-docs-minion** (me): Owns all documentation tasks listed above
- **lucy**: Should review the precedence rules and configuration boundaries for intent alignment
- **margo**: Should review for simplicity (are we over-engineering the configuration pattern?)
- **devx-minion**: Optional consult on whether the template and configuration pattern creates good developer experience for consuming projects

No new specialists are required. This is a documentation exercise with governance review.

---

### Documentation Burden Assessment

**Dedicated File (DESPICABLE.md) Approach:**
- New files: 1 reference doc (~800-1200 lines), 1 template (~50-80 lines)
- Updated files: 4 existing docs (architecture.md, external-skills.md, using-nefario.md, deployment.md)
- Total effort: ~1200-1500 lines of new content, ~100-150 lines of edits
- Maintenance: Template needs updates when agent roster or delegation rules change

**CLAUDE.md Section Approach:**
- New files: None
- Updated files: 1 doc (create "Configuration" guide as new doc, but smaller since no precedence rules needed)
- Total effort: ~400-600 lines of new content
- Maintenance: Same as dedicated file (examples need updates)

**Status Quo Approach:**
- New files: None
- Updated files: None
- Total effort: 0 lines
- Maintenance: 0 (but users rediscover patterns, ask questions, and create inconsistent conventions)

**Verdict:** Dedicated file adds 800-1000 lines over CLAUDE.md section approach, but delivers significantly better separation of concerns, discoverability, and reusability. The incremental documentation cost is justified by long-term benefits to consuming projects.
