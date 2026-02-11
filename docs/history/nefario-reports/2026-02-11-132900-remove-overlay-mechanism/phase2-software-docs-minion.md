# Domain Plan Contribution: software-docs-minion

## Recommendations

### 1. Decision Record Structure (Decision 27)

The new decision should be **Decision 27** (next sequential number) and should supersede both D9 and D16. The record should follow the established Nygard-style table format used consistently throughout `docs/decisions.md`. Recommended structure:

**Section header**: Place it under a new `---` divider with heading `## Overlay Removal (Decision 27)` to follow the existing pattern of grouping decisions by topic area.

**Key fields**:
- **Status**: `Implemented` (since nefario/AGENT.md is already the fully merged result)
- **Date**: `2026-02-11`
- **Choice**: Remove overlay mechanism entirely. Mark nefario as hand-maintained (`/despicable-lab` skips nefario during rebuilds). Delete all overlay artifacts (~2,900 lines). Apply the "one-agent rule": do not build infrastructure for a pattern until 2+ agents exhibit the need.
- **Alternatives rejected**: (1) Retain overlays -- 2,900 lines for 1 agent violates YAGNI/KISS/Lean-and-Mean. (2) Bake into the-plan.md (Option A) -- rejected to preserve spec/prompt separation; nefario spec would grow to 400-460 lines. (3) Retain but simplify (Option C) -- still introduces infrastructure for a single-agent need.
- **Rationale**: Helix Manifesto alignment. Infrastructure built for one agent's hypothetical future needs. The "one-agent rule" (Lucy's governance input) provides a clear re-evaluation trigger.
- **Consequences**: List both the positives (simpler build pipeline, fewer files, reduced contributor learning curve) and negatives (nefario spec drift undetected, manual propagation of spec changes, special case in build pipeline).

**Critical**: The "Supersedes" field must reference both D9 and D16. Update D9 and D16 status fields to `Superseded by Decision 27` to maintain the immutable-but-linked chain.

### 2. Agent Anatomy After Overlay Removal

After removing the ~130-line Overlay Mechanism section (lines 64-257), the remaining content in `docs/agent-anatomy.md` stands solidly on its own. The three surviving sections form a coherent narrative:

- **AGENT.md Structure** (lines 7-52): Frontmatter schema + system prompt five-section template
- **RESEARCH.md Structure** (lines 54-62): Research backing file purpose and organization

These two sections are the core contributor reference for "what goes in each file." They are self-contained and well-structured.

However, several edits are needed within the surviving content:

1. **Title**: Change from `# Agent Anatomy and Overlay System` to `# Agent Anatomy` (line 1)
2. **Opening paragraph** (line 5): Remove the sentence about overlay mechanism. Rewrite to: "Each agent in despicable-agents consists of two primary files: a deployable agent file (`AGENT.md`) and a research backing file (`RESEARCH.md`)."
3. **Frontmatter table** (line 36): Remove the `x-fine-tuned` row entirely -- this field no longer exists in the schema.
4. **Back link** (line 3): Keep as-is -- still links to `architecture.md`.

The document shrinks from ~258 lines to ~62 lines. This is actually a better document -- it focuses tightly on what contributors need to know about agent file structure without the cognitive overhead of the overlay mechanism.

### 3. Cross-Reference Inventory

I identified the following cross-references that will break or become stale if not updated. Organized by severity:

**Must fix (broken links or factually wrong)**:

| File | Line | Issue | Fix |
|------|------|-------|-----|
| `docs/architecture.md` | 136 | Sub-documents table says "Agent Anatomy and Overlay System" with description mentioning "overlay files" | Change title to "Agent Anatomy", update description to remove overlay references |
| `docs/build-pipeline.md` | 80 | Step 2 writes to `AGENT.generated.md` | Change to `AGENT.md` for all agents (nefario excluded from pipeline, so no special case needed in docs) |
| `docs/build-pipeline.md` | 85 | Output listed as `AGENT.generated.md` | Change to `AGENT.md` |
| `docs/build-pipeline.md` | 89-98 | Entire "Merge Step" section | Delete section entirely |
| `docs/build-pipeline.md` | 94 | Link to `[Agent Anatomy and Overlay System](agent-anatomy.md)` | Removed with section deletion |
| `docs/build-pipeline.md` | 133-135 | Version check paragraph about overlay files and `AGENT.generated.md` | Simplify to just check `x-plan-version` from `AGENT.md` |
| `docs/build-pipeline.md` | 156-157 | `--check` description mentions overlay drift and `validate-overlays.sh` | Remove overlay drift references |
| `docs/build-pipeline.md` | 176-178 | `/despicable-lab` skill description mentions overlay drift | Remove overlay references |
| `docs/deployment.md` | 43 | Mentions `AGENT.generated.md` and `AGENT.overrides.md` as repository files | Simplify to: "Only `AGENT.md` files are deployed. `RESEARCH.md` remains in the repository as source material." |
| `docs/decisions.md` | 109 | D9 status "Partially implemented" | Change to "Superseded by Decision 27" |
| `docs/decisions.md` | 199 | D16 status "Implemented" | Change to "Superseded by Decision 27" |
| `.claude/skills/despicable-lab/SKILL.md` | 37-57 | Overlay drift detection block | Remove entirely |
| `.claude/skills/despicable-lab/SKILL.md` | 94-107 | WITH/WITHOUT overrides branching logic | Simplify: all agents write `AGENT.md` directly; add note that nefario is hand-maintained and skipped |

**No fix needed (immutable history)**:

| File | Reason |
|------|--------|
| `docs/history/nefario-reports/2026-02-09-002-*.md` | Immutable execution report |
| `docs/history/nefario-reports/2026-02-09-003-*.md` | Immutable execution report |
| `docs/history/nefario-reports/2026-02-10-*.md` (multiple) | Immutable execution reports |
| `docs/history/overlay-implementation-summary.md` | Being moved to history (already there) |
| `docs/history/validation-verification-report.md` | Already in history |

**Move to history (stale but worth preserving)**:

| File | Action |
|------|--------|
| `docs/overlay-decision-guide.md` | Move to `docs/history/overlay-decision-guide.md` |

### 4. Build Pipeline Simplification

After removing the Merge Step section from `docs/build-pipeline.md`, the document needs narrative flow repair at two points:

1. **Phase 1 to Phase 2 transition**: The current flow is Phase 1 -> Merge Step -> Phase 2. After removing Merge Step, Phase 1's Step 2 output becomes `AGENT.md` directly, and the text flows naturally into Phase 2 Cross-Check. Add a one-sentence transition: "After all 27 pipelines complete, the cross-check verifies consistency." (This sentence already exists at line 101, so the gap is seamless after deletion.)

2. **Nefario exception**: Add a brief note either in the "Constraints" subsection or a new "Exceptions" subsection: "nefario is hand-maintained and excluded from the build pipeline. Its `AGENT.md` is edited directly. See Decision 27 in Design Decisions."

3. **Version check paragraph** (line 133-135): The paragraph about reading `x-plan-version` from `AGENT.generated.md` for overlay agents is now wrong. Simplify to: version check reads `x-plan-version` from `AGENT.md`.

4. **Mermaid diagram** (lines 13-49): The pipeline diagram shows output as `agent1[gru/AGENT.md]` etc. -- this is already correct. No change needed to the diagram.

### 5. Decisions.md Section Organization

The current `decisions.md` has a section header `## Overlay System (Decision 16)` (line 195). After superseding D16:

- Keep the section header and content (decisions are immutable records)
- Add the new Decision 27 under a new section: `## Overlay Removal (Decision 27)` with its own `---` divider
- Place it after Decision 26 (the current last decision), before the Deferred section

## Proposed Tasks

### Task 1: Update docs/agent-anatomy.md

**What**: Remove overlay content, retitle, clean up surviving content.

**Deliverables**:
- Title changed to `# Agent Anatomy`
- Opening paragraph simplified (remove overlay sentence)
- `x-fine-tuned` row removed from frontmatter table
- Lines 64-257 (Overlay Mechanism section through end of file) deleted
- No other structural changes

**Dependencies**: None. Can execute independently.

### Task 2: Update docs/build-pipeline.md

**What**: Remove Merge Step section, simplify overlay references throughout, add nefario hand-maintained note.

**Deliverables**:
- "Merge Step" section (lines 89-98) deleted
- Step 2 Build output changed from `AGENT.generated.md` to `AGENT.md`
- Version check paragraph (lines 133-135) simplified
- `--check` description (line 156) updated to remove overlay drift references
- `/despicable-lab` skill description (lines 176-178) updated
- Note added about nefario being hand-maintained and excluded from pipeline
- Cross-check transition reads naturally after Merge Step removal

**Dependencies**: None. Can execute independently.

### Task 3: Add Decision 27 to docs/decisions.md

**What**: Add new decision record superseding D9 and D16. Update D9 and D16 status fields.

**Deliverables**:
- Decision 9 status changed to `Superseded by Decision 27`
- Decision 16 status changed to `Superseded by Decision 27`
- New Decision 27 section added after Decision 26, before Deferred section
- Decision follows established table format with all required fields
- Consequences section is honest about both gains and losses

**Dependencies**: None. Can execute independently.

### Task 4: Update docs/architecture.md sub-documents table

**What**: Update one row in the sub-documents table.

**Deliverables**:
- Row for `agent-anatomy.md` changed from "Agent Anatomy and Overlay System" to "Agent Anatomy"
- Description updated from "AGENT.md structure, frontmatter schema, five-section prompt template, RESEARCH.md role, overlay files" to "AGENT.md structure, frontmatter schema, five-section prompt template, RESEARCH.md role"

**Dependencies**: None. Can execute independently.

### Task 5: Update docs/deployment.md line 43

**What**: Remove references to `AGENT.generated.md` and `AGENT.overrides.md`.

**Deliverables**:
- Line 43 changed from: `Only AGENT.md files are deployed. RESEARCH.md, AGENT.generated.md, and AGENT.overrides.md remain in the repository as build artifacts and source material -- they are not visible to Claude Code.`
- To: `Only AGENT.md files are deployed. RESEARCH.md remains in the repository as source material -- it is not visible to Claude Code.`

**Dependencies**: None. Can execute independently.

### Task 6: Move docs/overlay-decision-guide.md to history

**What**: Move the overlay decision guide to the history folder.

**Deliverables**:
- `docs/overlay-decision-guide.md` moved to `docs/history/overlay-decision-guide.md`
- Verify the "< Back to Architecture Overview" link at top of the moved file -- it will become stale, but since this is now a historical document, this is acceptable (consistent with how other history files work)

**Dependencies**: None. Can execute independently.

### Task 7: Update .claude/skills/despicable-lab/SKILL.md

**What**: Remove overlay logic from the build skill.

**Deliverables**:
- Remove overlay drift detection block (lines 37-57)
- Simplify Step 2 Build to remove WITH/WITHOUT overrides branching (lines 94-107)
- All agents write `AGENT.md` directly
- Add note that nefario is hand-maintained and skipped during rebuild
- Remove reference to `docs/agent-anatomy.md` merge rules (line 107)

**Dependencies**: None. Can execute independently. (Note: this is infrastructure, not documentation. The documentation tasks are independent of this one, but it is part of the same coherent change set.)

## Risks and Concerns

### Risk 1: Decision 15 References AGENT.overrides.md

Decision 15 (line 191) says: "Constraint encoded in AGENT.overrides.md and AGENT.md." After overlay removal, `AGENT.overrides.md` no longer exists. However, decisions are immutable records. The text describes what was true at the time of the decision, not current state. Decision 27's consequences section should note that constraints previously encoded in `AGENT.overrides.md` are now maintained directly in `nefario/AGENT.md`. Do NOT edit Decision 15's text.

### Risk 2: Broken Narrative in build-pipeline.md

The Merge Step section currently serves as a bridge between "Step 2: Build" and "Phase 2: Cross-Check". After deletion, verify that the transition reads naturally. The existing sentence at line 101 ("After all 27 pipelines complete and merge steps finish...") must be updated to remove "and merge steps finish".

### Risk 3: SKILL.md Is Not Pure Documentation

`.claude/skills/despicable-lab/SKILL.md` is an operational file, not just documentation. Changes to it affect the build pipeline's behavior. This task should be owned by devx-minion or the infrastructure agent, not software-docs-minion. I have included it in the task list for completeness but recommend a different execution owner.

### Risk 4: Grep for Stale References Post-Execution

After all six documentation files are updated, a final sweep should grep the entire docs/ directory and .claude/ directory for residual overlay references (`overlay`, `AGENT.generated`, `AGENT.overrides`, `x-fine-tuned`, `validate-overlays`, `override-format-spec`, `validate-overlays-spec`). The cross-reference inventory above is thorough but a mechanical sweep catches anything missed.

### Risk 5: The build-pipeline.md Mermaid Diagram

The "Phase 1" Mermaid diagram (lines 13-49) shows output as `gru/AGENT.md`, `nefario/AGENT.md`, `minions/*/AGENT.md`. This is correct for the post-removal state -- no changes needed. However, the nefario entry in the output is technically misleading since nefario will be excluded from the pipeline. Consider whether to annotate this in the diagram or leave it (my recommendation: leave it, since the diagram shows what the pipeline produces for the agents it handles, and a separate text note explains nefario's exclusion).

## Additional Agents Needed

None for the documentation tasks. The current team (software-docs-minion for documentation, devx-minion for SKILL.md infrastructure) is sufficient.

However, if devx-minion is not already scoped to update `.claude/skills/despicable-lab/SKILL.md`, that task should be explicitly assigned to them. SKILL.md changes are operational, not documentation -- software-docs-minion should review the SKILL.md changes for consistency with documentation, but not own the execution.
