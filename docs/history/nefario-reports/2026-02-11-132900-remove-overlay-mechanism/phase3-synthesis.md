# Phase 3: Synthesis -- Remove Overlay Mechanism

## Delegation Plan

**Team name**: remove-overlay
**Description**: Delete all overlay infrastructure and mark nefario as hand-maintained. Issue #32.

---

### Task 1: Delete overlay artifacts
- Agent: code
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are removing the overlay mechanism from the despicable-agents project. Your job is to delete all overlay-specific files and directories. This is a pure deletion task -- do not modify any files, only delete.

**Project root**: `/Users/ben/github/benpeter/2despicable/3`

**Delete the following files**:
1. `validate-overlays.sh` (659 lines -- the overlay drift detection script)
2. `nefario/AGENT.generated.md` (434 lines -- generated intermediate file)
3. `nefario/AGENT.overrides.md` (311 lines -- hand-tuned overrides file)
4. `docs/override-format-spec.md` (660 lines -- overlay format specification, never fully implemented)
5. `docs/validate-overlays-spec.md` (400 lines -- validation script specification)

**Delete the following directory and all contents**:
6. `tests/` (entire directory -- contains only overlay test infrastructure: `run-tests.sh`, `test-commit-hooks.sh`, `test-install-portability.sh`, `test-no-hardcoded-paths.sh`, `README.md`, and `fixtures/` with 10 fixture directories)

**IMPORTANT**: The `tests/` directory contains `test-commit-hooks.sh`, `test-install-portability.sh`, and `test-no-hardcoded-paths.sh` which sound general-purpose but are part of the overlay test harness. Delete the entire directory.

**Do NOT delete**:
- `nefario/AGENT.md` (this is the fully merged deployed agent -- it stays)
- `nefario/RESEARCH.md` (stays)
- Anything in `docs/history/` (immutable historical records)
- `docs/overlay-decision-guide.md` (moved by a later task, not deleted here)

**Do NOT modify any files** -- only delete. Other tasks handle edits.

After deletion, verify:
- `validate-overlays.sh` no longer exists
- `nefario/AGENT.generated.md` no longer exists
- `nefario/AGENT.overrides.md` no longer exists
- `docs/override-format-spec.md` no longer exists
- `docs/validate-overlays-spec.md` no longer exists
- `tests/` directory no longer exists
- `nefario/AGENT.md` still exists

---

### Task 2: Remove x-fine-tuned from nefario/AGENT.md frontmatter
- Agent: code
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are cleaning up the nefario agent file after overlay removal. Your single task is to remove the `x-fine-tuned: true` line from `nefario/AGENT.md` frontmatter.

**File**: `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

The frontmatter currently contains (line 13):
```yaml
x-fine-tuned: true
```

Remove this line entirely. The `x-fine-tuned` field was part of the overlay system -- it was auto-injected during merge when overrides existed. Since overlays are being removed, this field has no meaning.

**Do NOT change anything else in the file.** Do not modify the system prompt body, other frontmatter fields, or any other content.

---

### Task 3: Move overlay-decision-guide.md to history
- Agent: code
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are archiving a stale overlay document. Move the overlay decision guide to the history directory.

**Action**: Move (git mv) the file:
- From: `/Users/ben/github/benpeter/2despicable/3/docs/overlay-decision-guide.md`
- To: `/Users/ben/github/benpeter/2despicable/3/docs/history/overlay-decision-guide.md`

Use `git mv` so git tracks the rename.

The file's internal back-link (`[< Back to Architecture Overview](architecture.md)`) will become stale after the move, but this is acceptable -- historical documents in `docs/history/` are treated as immutable snapshots. Do NOT modify the file contents.

**Do NOT** modify any other files.

---

### Task 4: Simplify despicable-lab SKILL.md (remove overlay logic)
- Agent: devx-minion
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are simplifying the `/despicable-lab` skill after the overlay mechanism has been removed from the project. The overlay system (validate-overlays.sh, AGENT.overrides.md, AGENT.generated.md) is being deleted. nefario is now a hand-maintained agent -- its AGENT.md is edited directly and is NOT rebuilt by the pipeline.

**File**: `/Users/ben/github/benpeter/2despicable/3/.claude/skills/despicable-lab/SKILL.md`

Make these changes:

**1. Argument Parsing section (line 24)**
Change `--all`: Force-rebuild all 27 agents regardless of version` to `--all`: Force-rebuild all agents regardless of version (nefario excluded -- hand-maintained)`.

**2. Version Check section (lines 29-58)**
- In the version check loop (lines 29-35), add a skip condition: If the agent is nefario, report it as "hand-maintained (skipped)" and continue to the next agent. Place this check at the top of the loop body, before reading AGENT.md frontmatter.
- Delete lines 37-58 entirely. This is the "overlay drift detection" block that runs `validate-overlays.sh --summary` and the example output showing drift detection. All of it is overlay-specific.
- Replace the deleted example with a simpler example table that shows nefario as skipped:

```
AGENT           VERSION    SPEC       STATUS
-------------------------------------------
gru             1.0        1.0        ✓ up-to-date
nefario         --         --         ⊘ hand-maintained (skipped)
lucy            1.0        1.0        ✓ up-to-date
...
```

**3. File Locations table (line 65)**
Change the nefario row's Build Location from `nefario/AGENT.md` to `nefario/AGENT.md (hand-maintained, not built)`.

**4. Step 2 Build section (lines 88-107)**
- Add a skip guard at the start of Step 2: "If the agent is nefario, skip the build step entirely. nefario/AGENT.md is hand-maintained and not generated by the pipeline. Report: 'nefario: skipped (hand-maintained). Edit nefario/AGENT.md directly or via the-plan.md spec updates.'"
- Delete lines 102-107 (the "For agents WITH overrides" branch that writes `AGENT.generated.md` and reports manual merge required, including the link to `docs/agent-anatomy.md`).
- Remove the conditional framing from lines 94-101. Change "3. **For agents WITHOUT overrides** (no `AGENT.overrides.md`):" to simply be unconditional build instructions (just "3." or renumber appropriately). The qualifier "WITHOUT overrides" is no longer meaningful.

**5. Verify Constraints section (lines 124-134)**
Review the Constraints section for any implicit overlay references. Currently it has no overlay mentions -- confirm and leave unchanged.

**Do NOT**:
- Modify any files other than `.claude/skills/despicable-lab/SKILL.md`
- Change the overall structure of the skill (frontmatter, main sections)
- Remove the cross-check or report sections

**Error message quality**: If someone explicitly runs `/despicable-lab nefario`, the skip message should explain three things: what happened (skipped), why (hand-maintained), and what to do instead (edit directly).

---

### Task 5: Update docs/agent-anatomy.md (remove overlay content)
- Agent: software-docs-minion
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are updating the agent anatomy documentation after the overlay mechanism has been removed from the project. The overlay system is gone. nefario is now hand-maintained.

**File**: `/Users/ben/github/benpeter/2despicable/3/docs/agent-anatomy.md`

Make these changes:

**1. Title (line 1)**: Change `# Agent Anatomy and Overlay System` to `# Agent Anatomy`.

**2. Opening paragraph (line 5)**: Replace the current paragraph with:
"Each agent in despicable-agents consists of two primary files: a deployable agent file (`AGENT.md`) and a research backing file (`RESEARCH.md`)."

Remove the sentence about overlay mechanism and intermediate files.

**3. Frontmatter table (around line 36)**: Remove the entire row for `x-fine-tuned`. This field no longer exists in the schema.

**4. Delete the entire Overlay Mechanism section (lines 64-257)**: Everything from `## Overlay Mechanism` through the end of the file must be deleted. This includes:
- Problem statement
- Three-File Pattern
- Build Flow diagram
- Merge Rules
- Version Tracking
- Merging Process
- Drift Detection
- Real-World Example: Nefario Overrides
- Which File to Edit

**5. Back link (line 3)**: Keep `[< Back to Architecture Overview](architecture.md)` as-is.

The document should end after the RESEARCH.md Structure section (around line 62 after edits). It becomes a focused, ~62-line reference for agent file structure.

**Do NOT** modify any other files.

---

### Task 6: Update docs/build-pipeline.md (remove overlay references)
- Agent: software-docs-minion
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are updating the build pipeline documentation after the overlay mechanism has been removed. nefario is now hand-maintained and excluded from the pipeline.

**File**: `/Users/ben/github/benpeter/2despicable/3/docs/build-pipeline.md`

Make these changes:

**1. Step 2 Build output (line 80, line 84-85)**: Change `AGENT.generated.md` to `AGENT.md`. The pipeline now writes `AGENT.md` directly for all agents (no intermediate generated file).

Specifically:
- Line 80: "4. Write `AGENT.generated.md`" → "4. Write `AGENT.md`"
- Line 85: "**Output**: `<agent-dir>/AGENT.generated.md`" → "**Output**: `<agent-dir>/AGENT.md`"

**2. Delete the entire Merge Step section (lines 89-98)**: Remove everything from `## Merge Step` through the line before `## Phase 2: Cross-Check`. This includes the explanation of with/without overrides, why-manual paragraph, and drift detection reference.

**3. Phase 2 transition (line 102)**: After removing the Merge Step, update the Phase 2 opening text. Change "After all 27 pipelines complete and merge steps finish, the cross-check verifies..." to "After all pipelines complete, the cross-check verifies...".

**4. Add nefario exception note**: After the Phase 2 section, or within the existing Constraints subsection at the bottom if one exists, add a brief note:
"**Exception**: nefario is hand-maintained and excluded from the build pipeline. Its `AGENT.md` is edited directly. See Decision 27 in Design Decisions."

If there is no natural place for this, add it as a brief paragraph after the Phase 2 section.

**5. Version check / divergence detection (lines 133-135)**: Change references from `AGENT.generated.md` to `AGENT.md`. The paragraph currently says version check reads from `AGENT.generated.md` for overlay agents -- simplify to: version check reads `x-plan-version` from `AGENT.md`.

Specifically: Remove the paragraph about "For agents with overlay files, the version check reads `x-plan-version` from `AGENT.generated.md`..." and simplify to just say the check compares `x-plan-version` from `AGENT.md` against `spec-version` in `the-plan.md`.

**6. Build Triggers table (lines 155-158)**:
- Remove "and overlay drift" from the `--check` description. Remove the sentence about `./validate-overlays.sh --summary`.
- Remove "For agents with overrides, writes `AGENT.generated.md` and reports 'Manual merge required'" from the agent-name description. Simplify to: rebuilds named agents.

**7. The /despicable-lab Skill section (lines 168-178)**: Remove mentions of overlay drift detection and overlay-specific behavior. Specifically:
- Remove "Runs `./validate-overlays.sh --summary` during `--check` mode to detect overlay drift."
- Change "For agents without overrides, writes `AGENT.md` directly. For agents with overrides, writes `AGENT.generated.md` and reports 'Manual merge required'." to "Writes `AGENT.md` for each rebuilt agent."
- Add: "nefario is excluded from the pipeline (hand-maintained)."

**8. Mermaid diagram (lines 13-49)**: Leave unchanged. The diagram shows correct output (`gru/AGENT.md`, `nefario/AGENT.md`, etc.). A separate text note explains nefario's exclusion.

**Do NOT** modify any other files.

---

### Task 7: Add Decision 27 and update D9/D16 status in docs/decisions.md
- Agent: software-docs-minion
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are adding Decision 27 (overlay removal) to the design decisions document and superseding two prior overlay decisions.

**File**: `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md`

Make these three changes:

**1. Update Decision 9 status (line 109)**:
Change `| **Status** | Partially implemented |` to `| **Status** | Superseded by Decision 27 |`

Do NOT modify any other field in Decision 9.

**2. Update Decision 16 status (line 201)**:
Change `| **Status** | Implemented |` to `| **Status** | Superseded by Decision 27 |`

Do NOT modify any other field in Decision 16.

**3. Add Decision 27**: Insert a new section AFTER Decision 26 (after line 348, the "---" divider after D26's consequences) and BEFORE the "## Deferred" section (line 351). Add:

```markdown

## Overlay Removal (Decision 27)

### Decision 27: Remove Overlay Mechanism, Hand-Maintain Nefario

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-11 |
| **Supersedes** | Decision 9 (Overlay Files), Decision 16 (Validation-Only Drift Detection) |
| **Choice** | Remove the overlay mechanism entirely. Mark nefario as hand-maintained (`/despicable-lab` skips nefario during rebuilds). Delete all overlay artifacts: `validate-overlays.sh` (659 lines), `AGENT.generated.md`, `AGENT.overrides.md`, `override-format-spec.md` (660 lines), `validate-overlays-spec.md` (400 lines), `tests/` directory (harness + 10 fixtures), overlay documentation sections. Apply the "one-agent rule": do not build infrastructure for a pattern until 2+ agents exhibit the need. |
| **Alternatives rejected** | (1) **Retain overlays** (status quo): ~2,900 lines of infrastructure serving exactly one agent violates YAGNI, KISS, and Lean-and-Mean from the Helix Manifesto. Contributors must learn a complex three-file system used by 1 of 27 agents. (2) **Bake nefario customizations into the-plan.md** (Option A from issue #32): Rejected to preserve spec/prompt separation -- nefario's spec section would grow from ~150 to 400-460 lines, mixing high-level specification with prompt-level engineering detail. (3) **Retain but simplify overlay system** (Option C from issue #32): Still introduces build infrastructure for a single-agent need, violating the one-agent rule. |
| **Rationale** | The overlay mechanism was built for nefario alone. No other agent developed a need for it. Per Helix Manifesto ("Lean and Mean", "YAGNI"), infrastructure should not exist for hypothetical future needs. nefario/AGENT.md is already the fully merged result of generated + overrides -- no content is lost by removing the intermediate files. The "one-agent rule" provides a clear re-introduction trigger: when a second agent needs customization preservation, revisit the mechanism. Until then, nefario is hand-maintained. |
| **Consequences** | **Gained**: Simpler build pipeline (no merge step, no drift detection). ~2,900 lines removed. Reduced contributor learning curve. No bash 4.0+ dependency for drift detection. **Lost**: nefario spec drift goes undetected by tooling (manual vigilance required). Spec changes in the-plan.md must be manually propagated to nefario/AGENT.md. `/despicable-lab` has a special case (skip nefario). Constraints previously encoded in `AGENT.overrides.md` (Decision 15) are now maintained directly in `nefario/AGENT.md`. |
```

Follow the established Nygard-style table format used throughout the file. Place the new section with its own `---` divider before it.

**Do NOT** modify any decisions other than D9 status, D16 status, and adding D27. Decisions are immutable records -- only status fields are updated when superseded.

---

### Task 8: Update docs/architecture.md and docs/deployment.md
- Agent: software-docs-minion
- Model: sonnet
- Mode: bypassPermissions
- Depends on: none
- Gate: no

#### Prompt

You are updating two documentation files to remove overlay references after the overlay mechanism has been removed.

**File 1**: `/Users/ben/github/benpeter/2despicable/3/docs/architecture.md`

At line 136, the sub-documents table has a row for agent-anatomy.md:
```
| [Agent Anatomy and Overlay System](agent-anatomy.md) | AGENT.md structure, frontmatter schema, five-section prompt template, RESEARCH.md role, overlay files |
```

Change this to:
```
| [Agent Anatomy](agent-anatomy.md) | AGENT.md structure, frontmatter schema, five-section prompt template, RESEARCH.md role |
```

Remove "and Overlay System" from the link text and "overlay files" from the description.

**File 2**: `/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`

At line 43, the current text is:
```
Only `AGENT.md` files are deployed. `RESEARCH.md`, `AGENT.generated.md`, and `AGENT.overrides.md` remain in the repository as build artifacts and source material -- they are not visible to Claude Code.
```

Change this to:
```
Only `AGENT.md` files are deployed. `RESEARCH.md` remains in the repository as source material -- it is not visible to Claude Code.
```

**Do NOT** modify any other content in either file.

---

### Task 9: Verify no stale overlay references remain
- Agent: code
- Model: sonnet
- Mode: default
- Depends on: Task 1, Task 2, Task 3, Task 4, Task 5, Task 6, Task 7, Task 8
- Gate: no

#### Prompt

You are performing a final verification sweep after the overlay mechanism has been removed from the despicable-agents project. Your job is to confirm that no stale references to the overlay system remain in active files.

**Project root**: `/Users/ben/github/benpeter/2despicable/3`

**Search for these terms** across the entire project (excluding `docs/history/` and `.git/`):

1. `overlay` (case-insensitive)
2. `AGENT.generated`
3. `AGENT.overrides`
4. `x-fine-tuned`
5. `validate-overlays`
6. `override-format-spec`
7. `validate-overlays-spec`

**Expected legitimate hits** (do NOT flag these):
- `docs/history/` -- immutable historical documents, expected to reference overlays
- `the-plan.md` lines 44-45 -- contains an `x-fine-tuned` comment that MUST NOT be modified (project constraint)
- `docs/decisions.md` -- Decision 9, 15, and 16 bodies are immutable records and may reference overlay concepts. Only their Status fields were changed. Decision 27 references overlays in context of the removal.
- `nefario/AGENT.md` system prompt -- may reference overlay concepts in the context of agent architecture knowledge. Check whether any reference is stale vs. still-relevant context.
- `.orchestrated-session` and `nefario/scratch/` -- session artifacts, not project files

**Report format**:
For each search term, list:
- Total hits (excluding expected legitimate hits above)
- File path and line number for any unexpected hit
- Whether each unexpected hit needs fixing (with suggested fix) or is a false positive

If all searches come back clean (only expected hits), report: "Verification passed. No stale overlay references found in active project files."

If unexpected hits are found, report them clearly with file path, line number, and the matching text so they can be addressed.

---

## Cross-Cutting Coverage

1. **Testing**: No test-minion needed. The `tests/` directory being deleted IS the overlay test infrastructure. No production code is being written that needs testing. This is a deletion/documentation task.
2. **Security**: No security-minion needed. No attack surface created, no auth changes, no user input handling, no new dependencies. Pure removal of infrastructure.
3. **Usability -- Strategy**: Not applicable. No user-facing features are being created or changed. The overlay removal simplifies the contributor experience (fewer files to understand), which is the UX improvement itself.
4. **Usability -- Design**: Not applicable. No user-facing interfaces involved.
5. **Documentation**: Covered by Tasks 5-8 (software-docs-minion handles agent-anatomy, build-pipeline, decisions, architecture, deployment updates).
6. **Observability**: Not applicable. No runtime components, services, or APIs involved.

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no web UI, no new infrastructure)

Note: All six ALWAYS reviewers will review this plan per Phase 3.5 rules. The cross-cutting coverage above explains why domain-specific work is not needed for each dimension, but the plan-level review is mandatory.

## Conflict Resolutions

No conflicts between specialists. devx-minion and software-docs-minion both identified the SKILL.md as needing changes and agreed that devx-minion should own execution (software-docs-minion explicitly noted "SKILL.md is operational, not documentation" in Risk 3). Both specialists' recommendations for SKILL.md changes are consistent and have been merged into Task 4.

software-docs-minion recommended Task 7 (SKILL.md updates) as part of their task list but assigned it to devx-minion. This is reflected in Task 4 of this plan.

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Stale overlay references missed in docs | Medium | Task 9 performs a comprehensive grep sweep across all search terms |
| Broken cross-references between docs after edits | Medium | Each doc task includes specific line numbers; Task 9 catches residual references |
| SKILL.md behavior change for `--all` not communicated | Low | Task 4 updates the argument description to mention nefario exclusion |
| the-plan.md x-fine-tuned comment left stale | Low | This is a project constraint (MUST NOT modify the-plan.md). Decision 27 documents this as a known consequence. |
| Decision 15 references AGENT.overrides.md | Low | Decisions are immutable records. Decision 27's consequences section notes that D15 constraints are now in nefario/AGENT.md directly. |
| build-pipeline.md narrative breaks after Merge Step deletion | Medium | Task 6 includes specific transition repair instructions |

## Execution Order

**Batch 1** (parallel, no dependencies):
- Task 1: Delete overlay artifacts
- Task 2: Remove x-fine-tuned from nefario/AGENT.md
- Task 3: Move overlay-decision-guide.md to history
- Task 4: Simplify despicable-lab SKILL.md
- Task 5: Update agent-anatomy.md
- Task 6: Update build-pipeline.md
- Task 7: Add Decision 27 to decisions.md
- Task 8: Update architecture.md and deployment.md

All 8 tasks are independent (no file overlap, no content dependencies). They can execute in parallel.

**Batch 2** (sequential, depends on all of Batch 1):
- Task 9: Verification sweep

## Verification Steps

After all tasks complete:
1. Task 9's grep sweep confirms no stale references
2. Verify `nefario/AGENT.md` exists and has no `x-fine-tuned` in frontmatter
3. Verify `validate-overlays.sh`, `nefario/AGENT.generated.md`, `nefario/AGENT.overrides.md`, `docs/override-format-spec.md`, `docs/validate-overlays-spec.md`, and `tests/` are gone
4. Verify `docs/history/overlay-decision-guide.md` exists
5. Verify `docs/overlay-decision-guide.md` does not exist
6. Verify Decision 27 exists in `docs/decisions.md`
7. Verify D9 and D16 status fields say "Superseded by Decision 27"
