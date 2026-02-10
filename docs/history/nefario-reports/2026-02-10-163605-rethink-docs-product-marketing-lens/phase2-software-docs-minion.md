# Phase 2: Domain Plan Contribution -- software-docs-minion

## Documentation Information Architecture

### Current State Assessment

The project has 13 docs/*.md files plus the README. Here is my audit:

**Current docs/ inventory with audience classification:**

| Document | Current audience | Correct audience | Status |
|----------|-----------------|------------------|--------|
| `architecture.md` | Mixed (hub) | Both (split needed) | Restructure |
| `orchestration.md` | Mixed | Both (split needed) | Restructure |
| `agent-anatomy.md` | Contributors | Contributors | Fine as-is |
| `build-pipeline.md` | Contributors | Contributors | Fine as-is |
| `deployment.md` | Mixed | Both (split needed) | Restructure |
| `decisions.md` | Contributors | Contributors | Fine as-is |
| `commit-workflow.md` | Contributors | Contributors | Fine as-is |
| `commit-workflow-security.md` | Contributors | Contributors | Fine as-is |
| `compaction-strategy.md` | Contributors | Contributors | Fine as-is |
| `override-format-spec.md` | Contributors | Contributors | Fine as-is |
| `overlay-implementation-summary.md` | Internal/stale | Archive candidate | Stale |
| `validate-overlays-spec.md` | Contributors | Contributors | Fine as-is |
| `validation-verification-report.md` | Internal/stale | Archive candidate | Stale |

**Key findings:**

1. **architecture.md serves dual duty and fails at both.** It is simultaneously the project introduction for users (system context diagram, hierarchy explanation, agent groups) and the hub page for contributor reference docs. A user who wants to understand the system hits a wall of sub-document links to build pipeline specs and overlay mechanisms. A contributor who needs the sub-document index must scroll past user-facing narrative.

2. **orchestration.md is the strongest document but misorganized.** Section 1 ("Using Nefario") is excellent user-facing content -- clear examples, when-to-use guidance, what-to-expect walkthrough. But it is buried in a document that then dives into nine-phase architecture, delegation model internals, and approval gate classification. The user content and the contributor content are interleaved.

3. **deployment.md mixes user install with contributor deployment architecture.** The install.sh section is user-facing. The symlink model explanation, hook deployment details, and nefario skill deployment are contributor-facing.

4. **Two docs are stale implementation artifacts.** `overlay-implementation-summary.md` and `validation-verification-report.md` are point-in-time status reports, not living documentation. They document what was built during a specific orchestration run, including checkboxes, "next steps" that may or may not have been completed, and implementation details that belong in the spec docs they reference. These add noise to the docs/ directory.

---

### Recommendation 1: Split docs/ into two sections

Create a clear two-section structure. Do not create subdirectories (KISS -- the file count does not warrant subdirectory overhead). Instead, use naming convention and a clear navigation page.

**User-facing docs (understand and use):**

| New path | Source | Content |
|----------|--------|---------|
| `docs/overview.md` | New (extracted from architecture.md) | System context diagram, four-tier hierarchy explanation, agent groups table, cross-cutting concerns summary. The "what is this and how does it work" page. No links to build pipeline or overlay specs. |
| `docs/using-nefario.md` | Extracted from orchestration.md Section 1 | When to use nefario vs. direct agents, invocation examples, nine-phase walkthrough (user-facing version -- what happens, not how it is architected), tips for success. Standalone page, not embedded in a 600-line architecture doc. |
| `docs/agent-catalog.md` | New | Per-agent reference: name, one-line description, when to use, example invocation, model tier. The roster table in README is the summary; this is the full reference. Enables README to stay concise while giving users a click-through for depth. |

**Contributor/reference docs (build and extend):**

The existing contributor docs are well-written and well-structured. Keep them as-is with minor adjustments:

- `docs/architecture.md` -- Strip user-facing narrative (moved to overview.md). Keep as contributor-facing architecture reference: design philosophy, sub-document index, cross-cutting concerns detail.
- `docs/orchestration.md` -- Strip Section 1 (moved to using-nefario.md). Keep Sections 2-6 as the orchestration architecture reference.
- `docs/deployment.md` -- Strip user install instructions (README covers this). Keep as contributor deployment architecture reference.
- All other contributor docs remain unchanged.

**Stale docs to archive:**

Move `overlay-implementation-summary.md` and `validation-verification-report.md` to `docs/history/` (alongside nefario-reports/). They are historical artifacts, not living documentation.

---

### Recommendation 2: architecture.md should NOT remain the hub

**Current role**: architecture.md is the single entry point linked from README's "Documentation" section. It serves as both introduction and index.

**Problem**: This forces every reader through the same funnel regardless of intent. A user wanting to learn how to use agents sees links to build-pipeline.md and commit-workflow-security.md. A contributor wanting the overlay spec must scroll past system context diagrams.

**Proposed replacement**: Two entry points, linked from README:

1. **For users**: README links to `docs/overview.md` (system overview) and `docs/using-nefario.md` (orchestration usage). These are the "understand the system" and "use the orchestrator" pages. `docs/agent-catalog.md` is linked from the roster table for per-agent depth.

2. **For contributors**: README's "Contributing" section links to `docs/architecture.md` (now a pure contributor hub). architecture.md retains its sub-document index but drops user-facing narrative.

**README Documentation section becomes:**

```markdown
## Documentation

**Using the agents:**
- [System Overview](docs/overview.md) -- how the four tiers work, what each agent group does
- [Using Nefario](docs/using-nefario.md) -- when and how to use the orchestrator
- [Agent Catalog](docs/agent-catalog.md) -- per-agent reference with examples

**Contributing and extending:**
- [Architecture Reference](docs/architecture.md) -- design philosophy, sub-documents index
- [Design Decisions](docs/decisions.md) -- why things are the way they are
```

This gives users a three-click-max path to any user-facing information and gives contributors direct access to reference material.

---

### Recommendation 3: Content gaps for "first 30 seconds" experience

**Gap 1: No post-install "what now?" guidance.**
After `git clone && ./install.sh`, the README says nothing about what to do next. There is no "try this first" prompt. The "What you get" code block shows syntax but does not explain where to type those commands or what happens when you do. Fix: Add a "Try it" section to README immediately after Install, showing one concrete command with expected output.

**Gap 2: No prerequisites listed.**
README assumes the reader has Claude Code installed and knows what `@agent` and `/skill` syntax means. A developer who finds this project via GitHub search or a blog post may not. Fix: Add a one-line prerequisite note: "Requires [Claude Code](https://code.claude.com). Agents are invoked with `@agent-name` in any Claude Code session."

**Gap 3: Agent catalog lives only as a flat table.**
The README roster table has 27 rows. A developer scanning for "which agent handles my problem" must read all 27. There is no way to jump to a specific agent's documentation. Fix: Link agent names in the roster table to the agent catalog page (or to individual agent sections within it).

**Gap 4: orchestration.md Section 1 is excellent but undiscoverable.**
The best "how to use this" content is buried three clicks deep (README -> Documentation -> Architecture -> Orchestration). It should be one click from README. Fix: Extract to `docs/using-nefario.md` and link directly from README.

---

### Recommendation 4: Cross-linking strategy

**Principle: README is the hub, docs/ pages are spokes. No cross-referencing between docs/ pages unless there is a direct dependency.**

Specific linking rules:

1. **README links outward to docs/ pages.** Every docs/ page referenced in README should be accessible in one click. README should never link to a docs/ page that links to another docs/ page to get the user where they need to go.

2. **User-facing docs/ pages link back to README** (for orientation) but not to contributor docs. A user reading `docs/using-nefario.md` should not be routed to `docs/orchestration.md` (the 600-line architecture doc).

3. **Contributor docs/ pages link to each other** as needed (they already do this well with the `[< Back to Architecture Overview]` pattern). They should NOT link to user-facing pages.

4. **Agent catalog links to individual AGENT.md files** (the raw source) for developers who want to read the system prompt. This is the natural bridge between user docs and contributor docs.

5. **README roster table links to agent-catalog.md sections**, not to raw AGENT.md files. The catalog provides context; the raw file does not.

---

### Recommendation 5: Rewrite vs. restructure vs. fine-as-is assessment

**Needs rewriting (content changes):**

| Document | What to rewrite | Why |
|----------|----------------|-----|
| `README.md` | Full rewrite of structure and messaging | Current README is functional but does not tell a compelling story. "What you get" before "why you want it" is backwards. Product-marketing-minion should drive the messaging; I provide the structural scaffold. |
| `docs/architecture.md` | Major trim -- remove user-facing content | Content is moving to overview.md. What remains is the contributor hub: design philosophy, sub-document index. |
| `docs/orchestration.md` | Remove Section 1 | Section 1 is moving to using-nefario.md. Sections 2-6 stay as contributor reference. |
| `docs/deployment.md` | Minor trim -- remove user install section | User install instructions live in README. |

**Needs new content (gap filling):**

| Document | What to create | Why |
|----------|---------------|-----|
| `docs/overview.md` | System overview for users | Extracted and refined from architecture.md. No contributor details. |
| `docs/using-nefario.md` | Orchestration usage guide for users | Extracted and refined from orchestration.md Section 1. |
| `docs/agent-catalog.md` | Per-agent reference | No equivalent exists. Fills the gap between README's roster table and raw AGENT.md files. |

**Fine as-is (no changes needed):**

| Document | Why it is fine |
|----------|---------------|
| `docs/agent-anatomy.md` | Well-structured contributor reference. Clear audience. Good diagrams. |
| `docs/build-pipeline.md` | Well-structured contributor reference. Clear audience. Good diagrams. |
| `docs/decisions.md` | Proper ADR-style log. Clear, honest, well-organized. |
| `docs/commit-workflow.md` | Thorough contributor reference. Correct audience. |
| `docs/commit-workflow-security.md` | Thorough contributor reference. Correct audience. |
| `docs/compaction-strategy.md` | Thorough contributor reference. Correct audience. |
| `docs/override-format-spec.md` | Specification document. Correct audience. |
| `docs/validate-overlays-spec.md` | Specification document. Correct audience. |

---

## Proposed Tasks

### Task 1: Create docs/overview.md (user-facing system overview)

**What to do**: Extract the user-facing content from architecture.md (system context diagram, three-tier hierarchy diagram and explanation, agent groups table, cross-cutting concerns summary) into a new `docs/overview.md`. Rewrite for a user audience: explain what the system does and how it is organized, without referencing build pipelines, overlay mechanisms, or deployment internals. The system context C4 diagram and hierarchy diagram should move here. Add a "What makes this different" section that highlights: coordinated specialist team (not just a bag of prompts), governance layer (intent alignment + simplicity enforcement), cross-cutting review (security/testing/docs on every plan), and deterministic delegation (every task has exactly one owner).

**Deliverables**: `docs/overview.md`
**Dependencies**: Product-marketing-minion's positioning strategy (the "what makes this different" framing should use their messaging hierarchy). Must be written before README rewrite so README can link to it.
**Audience**: Users (developers evaluating or using the project)

### Task 2: Create docs/using-nefario.md (orchestration usage guide)

**What to do**: Extract orchestration.md Section 1 ("Using Nefario") into a standalone `docs/using-nefario.md`. Keep the user-facing content: when to use nefario, how to invoke, what the nine phases are (walkthrough, not architecture), tips for success. Remove the platform constraint paragraph (contributor detail). Rewrite the nine-phase walkthrough to emphasize the user's experience at each phase (what they see, what they decide, what happens in the background) rather than the technical implementation. Add 2-3 concrete end-to-end examples showing a real invocation from prompt to completion summary.

**Deliverables**: `docs/using-nefario.md`
**Dependencies**: None (can be written independently). Should be reviewed by devx-minion for onboarding flow coherence.
**Audience**: Users (developers using nefario for multi-agent tasks)

### Task 3: Create docs/agent-catalog.md (per-agent reference)

**What to do**: Create a reference page listing all 27 agents with structured entries. Each entry should include: agent name, one-line description, tier and group, model tier (opus/sonnet), example invocation (one concrete `@agent` command showing a realistic use case), what it does NOT do (abbreviated "Does NOT do" with delegation targets). Organize by group (matching the README roster table order). Include a "How to choose the right agent" decision tree or flowchart at the top.

**Deliverables**: `docs/agent-catalog.md`
**Dependencies**: Needs to read all 27 AGENT.md files for accurate descriptions and boundary information. Can be done in parallel with other tasks.
**Audience**: Users (developers choosing which agent to invoke)

### Task 4: Trim architecture.md to contributor hub

**What to do**: Remove content that moved to overview.md (system context diagram, hierarchy explanation, agent groups table). Keep: design philosophy section, sub-documents index table (updated to reflect new docs), cross-cutting concerns detail. Update the sub-documents table to include the new user-facing docs and clearly label which docs are user-facing vs. contributor-facing. Add a note at the top: "Looking for how to use the agents? See [System Overview](overview.md) and [Using Nefario](using-nefario.md)."

**Deliverables**: Updated `docs/architecture.md`
**Dependencies**: Tasks 1 and 2 must be complete first (so we know exactly what moved out).
**Audience**: Contributors

### Task 5: Trim orchestration.md to contributor reference

**What to do**: Remove Section 1 ("Using Nefario") which moved to using-nefario.md. Add a redirect note at the top: "For user-facing orchestration usage guide, see [Using Nefario](using-nefario.md)." Renumber remaining sections (Section 2 becomes Section 1, etc.). Update the back-link to architecture.md.

**Deliverables**: Updated `docs/orchestration.md`
**Dependencies**: Task 2 must be complete first.
**Audience**: Contributors

### Task 6: Rewrite README.md

**What to do**: Rewrite the README following product-marketing-minion's positioning strategy and messaging hierarchy. Structural requirements from my analysis:
- **Prerequisites**: One-line Claude Code requirement with link.
- **Value proposition**: Lead with what the project does for the developer (the "job to be done"), not what it is. Current README leads with "27 specialist agents" which is a feature, not a benefit.
- **Try it**: Immediately after install, show one concrete example with expected behavior (not just syntax).
- **How it works**: The four-tier explanation, condensed. Link to overview.md for depth.
- **Agent roster**: Keep the table but link agent names to agent-catalog.md sections. Consider collapsing into a summary (count per group) with link to full catalog if the table is too overwhelming (per ux-strategy-minion's cognitive load analysis).
- **Documentation**: Two-section link structure (user docs, contributor docs) per Recommendation 2.
- **Contributing**: Keep concise. Link to architecture.md for contributor reference.
- **Length target**: 1-2 screenfuls. Current README is borderline acceptable in length but the roster table dominates.

**Deliverables**: Updated `README.md`
**Dependencies**: Tasks 1, 2, 3 (new docs must exist before README can link to them). Product-marketing-minion's positioning strategy (messaging hierarchy, value proposition language).
**Audience**: Everyone (first impression)

### Task 7: Archive stale docs

**What to do**: Move `docs/overlay-implementation-summary.md` and `docs/validation-verification-report.md` to `docs/history/`. Update any links that reference them (check architecture.md sub-documents table).

**Deliverables**: Files moved, links updated
**Dependencies**: None (can be done anytime).
**Audience**: N/A (cleanup)

### Task 8: Update cross-linking

**What to do**: After all other tasks are complete, verify and update cross-links across the entire docs/ directory. Ensure: README links to all user-facing docs, user-facing docs link back to README and to each other where appropriate, contributor docs link to architecture.md hub, no broken links, no user-facing docs linking into contributor internals.

**Deliverables**: All docs verified for link integrity
**Dependencies**: All other tasks (this is the final pass).
**Audience**: N/A (quality assurance)

---

## Risks and Concerns

### Risk 1: Content duplication between overview.md and README

Splitting user-facing content across README and docs/overview.md creates a duplication risk. The README will have a condensed version of the system description; overview.md will have the full version. If one is updated without the other, they will drift.

**Mitigation**: README should use "teaser + link" pattern, not a condensed restatement. For example, README says "Four tiers of agents work together -- [see how](docs/overview.md)" rather than restating the four-tier explanation in abbreviated form. This makes README clearly subordinate to overview.md for system description.

### Risk 2: Agent catalog maintenance burden

A 27-entry agent catalog is a maintenance surface. When agents are added, renamed, or have boundaries adjusted, the catalog must be updated.

**Mitigation**: The agent catalog can be partially generated from AGENT.md frontmatter (name, description, model) with manual additions (example invocations, abbreviated "Does NOT do"). Consider a lightweight script that extracts frontmatter into a table, with manually-maintained example sections. This is not a blocker for the initial creation but should be noted for future maintainability.

### Risk 3: Three new docs pages add to total doc count

Adding overview.md, using-nefario.md, and agent-catalog.md increases the docs/ page count from 13 to 14 (after archiving 2 stale docs). This is manageable but worth noting -- the project should not keep growing the doc surface without periodic pruning.

**Mitigation**: The two archival moves offset the three additions. The net increase is one page. Future documentation additions should pass a "does this justify its own page or should it be a section in an existing page" test.

### Risk 4: Orchestration.md Section 1 extraction may lose context

Section 1 of orchestration.md was written as part of a larger document. Extracting it to a standalone page may lose contextual references to Sections 2-6 (e.g., "see Section 4 below for approval gate details"). These references need to be rewritten as cross-document links.

**Mitigation**: During Task 2, explicitly audit all internal references in Section 1 and convert them to either self-contained explanations or links to orchestration.md.

### Risk 5: "First 30 seconds" experience depends on Claude Code knowledge

Even with prerequisites stated, a developer who does not have Claude Code installed cannot try anything. The docs cannot solve a platform dependency.

**Mitigation**: The prerequisite note should include a link to Claude Code's installation page. The "Try it" section should show expected output so even a reader who has not installed yet gets a mental model of what happens.

---

## Additional Agents Needed

None beyond those already in the meta-plan. The four-specialist consultation (product-marketing-minion, software-docs-minion, ux-strategy-minion, devx-minion) covers all relevant domains for this documentation-only task:

- **product-marketing-minion**: Positioning and messaging (what to say)
- **software-docs-minion**: Information architecture (how to organize it) -- this contribution
- **ux-strategy-minion**: User journey and cognitive load (how to present it)
- **devx-minion**: Developer onboarding (how to make it actionable)

user-docs-minion is not needed because this project's documentation is developer-facing technical docs, not end-user tutorials. The software-docs-minion and devx-minion together cover the user-facing doc needs.
