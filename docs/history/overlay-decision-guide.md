[< Back to Architecture Overview](architecture.md)

# Overlay Removal Decisioning Guide

The overlay mechanism exists to preserve hand-tuned customizations for nefario during `/despicable-lab` rebuilds. Four specialist agents analyzed whether this mechanism should be retained or removed. This document presents the decision space, options, and tradeoffs to support an informed decision.

## Problem Statement

When `/despicable-lab` rebuilds an agent from `the-plan.md`, it generates `AGENT.md` from the spec. For nefario, this rebuild would lose hand-tuned customizations that are not captured in the spec:

- Approval gate details (when to request human sign-off)
- Architecture review procedures (governance verdicts, conflict resolution)
- Post-execution phase specifications (execution reports, documentation updates)
- Model selection rules for different phase types
- Conflict resolution protocols between governance agents

The overlay mechanism solves this by splitting nefario into three files:

1. `AGENT.generated.md` -- output from the build pipeline (identical to other agents' AGENT.md)
2. `AGENT.overrides.md` -- hand-written customizations specific to nefario
3. `AGENT.md` -- merged result of generated + overrides (the deployed agent file)

During rebuilds, the build pipeline creates a new `AGENT.generated.md`, the human reviews and updates `AGENT.overrides.md` if needed, then manually merges both into the final `AGENT.md`. The overlay mechanism preserves customizations across spec updates.

The underlying problem is real: nefario requires operational details (approval workflows, verdict formats, phase-specific behavior) that are difficult to specify declaratively in `the-plan.md` but critical to its function as orchestrator.

## Current State

The overlay mechanism is used by 1 of 27 agents (nefario only). The total footprint is approximately 2,900 lines across code, specifications, documentation, tests, and fixtures.

### Key Artifacts and Sizes

| Artifact | Lines | Purpose |
|----------|-------|---------|
| `validate-overlays.sh` | ~660 | Validates overlay file structure, cross-references, and merge consistency |
| `docs/override-format-spec.md` | ~660 | Specification for override file format (never implemented beyond basic structure) |
| `docs/validate-overlays-spec.md` | ~400 | Specification for validation script behavior |
| `nefario/AGENT.overrides.md` | ~300 | Hand-written customizations for nefario |
| `nefario/AGENT.generated.md` | ~430 | Generated baseline (duplicates most of AGENT.md) |
| `docs/agent-anatomy.md` (overlay sections) | ~130 | Documentation of overlay concepts and workflow |
| `tests/fixtures/` (overlay test cases) | ~414 | 10 directories, 34 files for validation script tests |
| References across codebase | 372 occurrences in 56+ files | Overlay mentions in docs, scripts, skills, tests |

### Decision History

- **Decision 9** (2025-01-27): Introduced overlay mechanism for nefario. Rationale: preserve hand-tuned orchestration logic through automated rebuilds.
- **Decision 16** (2025-02-03): Rejected automated merge, adopted validation-only approach. Rationale: merging is context-sensitive and error-prone; human review is safer.

The validation-only decision meant that most of `override-format-spec.md` (which described merge automation features) was never implemented. The spec describes a future that did not materialize.

## Analysis Against Helix Manifesto

The project follows the [Helix Manifesto](https://github.com/adobe/helix-home/blob/main/manifesto.md). The overlay mechanism's alignment with core principles:

### YAGNI (You Aren't Gonna Need It)

The overlay mechanism was built for generality but is used by exactly one agent. The 660-line `override-format-spec.md` describes features (automated merging, conflict markers, section-level overrides) that were never implemented. This is speculative infrastructure for a future that has not arrived.

**Assessment**: Violates YAGNI. Infrastructure built in anticipation of multiple consumers, but 26 agents do not need it.

### KISS (Keep It Simple, Stupid)

The overlay mechanism requires understanding:

- A three-file pattern (generated, overrides, merged)
- Merge rules and precedence
- A 660-line validation script
- A decision tree for "Which File to Edit" (overlay sections in `agent-anatomy.md`)

For 26 of 27 agents, none of this applies. Developers must learn this complexity to work on the build pipeline, even though it affects only one agent.

**Assessment**: Violates KISS. The mechanism is harder to explain than the underlying problem.

### Lean and Mean

Approximately 2,900 lines of code, documentation, specifications, and test fixtures exist to support customization preservation for one agent. This is 8 complexity points in the technical debt inventory (the highest-scoring item).

**Assessment**: Violates Lean and Mean. The solution is disproportionate to the problem.

### Important Note

This analysis evaluates the proportionality of the solution, not the validity of the problem. The problem (customization loss on rebuild) is real. The question is whether ~2,900 lines of infrastructure is the right solution for a single-agent need.

## Options

Three options are presented with honest pros, cons, and tradeoffs. The team has a strong opinion (remove), but the retention case is included for completeness.

### Option A: Remove Overlays, Bake Customizations into the-plan.md

**How**: Merge the content of `AGENT.overrides.md` into the nefario spec section of `the-plan.md`. Delete all overlay artifacts (`AGENT.generated.md`, `AGENT.overrides.md`, validation scripts, specs, fixtures). Nefario rebuilds like any other agent via `/despicable-lab`.

**Pros**:
- Single source of truth for nefario behavior
- Uniform build pipeline for all 27 agents (no special cases)
- No manual merge step required during rebuilds
- Changes tracked via spec-version bumps in `the-plan.md`
- Simplest long-term maintenance model
- Removes ~2,900 lines of infrastructure

**Cons**:
- Nefario spec grows to approximately 400-460 lines (10-15x a typical minion spec of 30-40 lines)
- Blurs the spec/prompt boundary further (the spec section becomes implementation detail)
- Future prompt tweaks require editing the canonical `the-plan.md` (higher-stakes file)
- Nefario spec contains operational rules (verdict formats, routing tables, phase procedures) at a different abstraction level than other agent specs

**Advocates**: devx-minion, margo

**Key Argument**: The spec/prompt boundary has already collapsed for nefario. The `the-plan.md` nefario spec already contains 165+ lines of operational rules: approval gate trigger conditions, verdict format specifications, phase execution details, governance routing logic. The overrides are refinements of exactly this content, not a different kind of information. Moving them into the spec aligns the source of truth with current reality.

**Example Comparison**:

Current `the-plan.md` nefario spec (excerpt):
```
- Governance review (Phase 3.5 Architecture Review):
  - Mandatory for all plans before execution
  - lucy evaluates intent alignment
  - margo evaluates simplicity and necessity
  - Verdicts: APPROVE, APPROVE_WITH_CONDITIONS, BLOCK
```

Current `AGENT.overrides.md` (excerpt):
```
When governance agents disagree:
- If one APPROVE and one APPROVE_WITH_CONDITIONS: proceed with conditions
- If one APPROVE and one BLOCK: escalate to human
- If both BLOCK: abandon plan
```

The second is a refinement of the first, at the same abstraction level. Both are operational rules.

### Option B: Remove Overlays, Mark Nefario as Hand-Maintained

**How**: Delete all overlay artifacts. Mark `nefario/AGENT.md` as directly edited (no generation). Modify `/despicable-lab` to skip nefario during rebuilds. The `the-plan.md` nefario spec remains as-is (high-level specification only, approximately 165 lines).

**Pros**:
- Cleanest documentation outcome (removes ~1,700 lines of overlay documentation)
- Preserves spec/prompt distinction (`the-plan.md` remains a specification document, not a prompt-engineering surface)
- The `the-plan.md` stays consistent (all agent specs at similar abstraction levels)
- Nefario is genuinely different from other agents; this acknowledges the difference architecturally
- Still removes ~2,900 lines of overlay infrastructure

**Cons**:
- Nefario spec in `the-plan.md` can drift from `AGENT.md` with no automated detection
- Version tracking (spec-version vs. x-plan-version) becomes advisory-only for nefario
- Creates a special case in the build pipeline (26 agents auto-build, 1 does not)
- Spec updates require manual propagation to `AGENT.md` (must remember to update both places)
- Loses automated verification that nefario implementation aligns with spec intent

**Advocate**: software-docs-minion

**Key Argument**: `the-plan.md` should remain a specification document accessible to non-technical stakeholders, not a prompt-engineering surface full of implementation details. Nefario is the orchestrator -- it coordinates the other 26 agents and runs a nine-phase process with governance integration. It is reasonable for nefario to be hand-maintained while the agents it orchestrates remain auto-built. The spec/prompt distinction has value and should be preserved.

**Architectural Precedent**: Build systems commonly have a meta-build step that is hand-maintained (e.g., `Makefile` generation tools that are themselves configured manually). Nefario is the "build system" for task execution; hand-maintaining it while auto-building its dependencies is a coherent pattern.

### Option C: Retain But Simplify

**How**: Keep the concept of customization preservation but reduce the infrastructure. Possible approaches:

- **Git-diff-based recovery**: Before rebuild, `git diff nefario/AGENT.md` captures customizations. After rebuild, human reviews diff and re-applies relevant changes.
- **Simple CUSTOM-SECTIONS.md reference**: A markdown file listing which sections of `nefario/AGENT.md` contain hand-tuned content. Serves as a checklist during rebuilds.
- **Inline comments in AGENT.md**: Mark customized sections with comments (`<!-- CUSTOM: approval gate details -->`). Developer checks these during rebuild.

**Pros**:
- Preserves a safety net for rebuild scenarios
- Lower infrastructure cost than current three-file system
- Acknowledges that the problem is real without over-engineering the solution
- Flexibility to choose simplest mechanism that works

**Cons**:
- Still requires some mechanism and documentation (non-zero maintenance)
- May re-grow in complexity over time (mechanism creep)
- Does not address the 660-line `override-format-spec.md` (should be deleted regardless)
- Git-diff approach requires human discipline (easy to miss customizations)
- Comment-based approach pollutes the agent file with build metadata

**Note**: Even under Option C, the following should be deleted as speculative infrastructure:
- `docs/override-format-spec.md` (660 lines, features never implemented)
- `docs/validate-overlays-spec.md` (400 lines, validates unimplemented features)
- `validate-overlays.sh` (660 lines, replaced by simpler mechanism)
- Test fixtures for validation script (414 lines, no longer needed)

A simplified Option C would retain approximately 300-500 lines of infrastructure (down from ~2,900), primarily in documentation explaining the chosen lightweight mechanism.

## Blast Radius of Removal

The following table shows artifacts affected by removal (applicable to both Option A and Option B).

| Artifact | Action | Lines |
|----------|--------|-------|
| `validate-overlays.sh` | Delete | ~660 |
| `docs/override-format-spec.md` | Delete | ~660 |
| `docs/validate-overlays-spec.md` | Delete | ~400 |
| `nefario/AGENT.overrides.md` | Delete (after preserving content) | ~300 |
| `nefario/AGENT.generated.md` | Delete | ~430 |
| `tests/fixtures/` (overlay tests) | Delete | ~414 |
| `docs/agent-anatomy.md` (overlay sections) | Remove overlay documentation | ~130 |
| `docs/build-pipeline.md` (merge step) | Simplify to single-file generation | ~20 |
| `docs/decisions.md` | Add superseding decision | +20 |
| `.claude/skills/despicable-lab/SKILL.md` | Simplify overlay logic | ~15 |
| `docs/architecture.md` | Update sub-documents table title | ~5 |

**Total removed**: Approximately 2,900 lines.

**Functional impact**: None. `nefario/AGENT.md` already contains the fully merged result of generated + overrides. No agent functionality is lost by removing the intermediate files and build infrastructure.

## Decision Criteria

Use these criteria to choose an option:

| Priority | Option |
|----------|--------|
| You value uniform build pipeline and single source of truth | **Option A** |
| You value spec/prompt separation and accept a hand-maintained exception | **Option B** |
| You believe the problem will recur or worsen and want a safety net | **Option C** |
| You want to minimize documentation complexity | **Option B** |
| You want to minimize special-case logic in the build pipeline | **Option A** |
| You want to preserve `the-plan.md` as a stakeholder-readable specification | **Option B** |

**Regardless of choice**: The 660-line `override-format-spec.md` should be deleted. It describes features (automated merging, conflict resolution, section-level precedence) that were never implemented. This is speculative infrastructure regardless of whether overlays are retained.

## Team Recommendation

**This section represents the specialist team's opinion, not a predetermined conclusion.**

**Unanimous**: Remove the overlay mechanism. The complexity is disproportionate to the problem. Approximately 2,900 lines of infrastructure for one agent violates YAGNI, KISS, and Lean-and-Mean principles.

**Majority (devx-minion, margo)**: **Option A** -- bake customizations into `the-plan.md`. Rationale: The spec/prompt boundary has already collapsed for nefario. The spec contains 165+ lines of operational detail (verdict formats, approval triggers, phase procedures) at the same abstraction level as the overrides. Moving the overrides into the spec aligns the source of truth with reality. A 400-460 line spec section is large but acceptable for the orchestrator role.

**Minority (software-docs-minion)**: **Option B** -- hand-maintain nefario. Rationale: `the-plan.md` should remain a specification document, not a prompt-engineering surface. Nefario is architecturally different (the orchestrator, not a worker) and deserves different treatment. Preserves the spec as stakeholder-readable.

**Governance (lucy)**: Whichever option is chosen, apply the **"one-agent rule"** going forward: Do not build infrastructure for a pattern until at least two agents exhibit the need. Infrastructure built for hypothetical future needs violates YAGNI. If a second agent requires customization preservation, re-evaluate whether a generalized mechanism is warranted.

**Note on Option C**: No team member advocated strongly for Option C (retain but simplify). The consensus is that the problem is real but small (affects 1 agent) and does not justify ongoing infrastructure. The choice is between two clear positions: bake into spec (Option A) or hand-maintain (Option B).

## Recommended Next Steps (If Removal Is Approved)

This section provides a high-level implementation outline. Detailed task breakdowns were produced by devx-minion and software-docs-minion during planning and can be referenced when execution begins.

**Implementation sequence**:

1. **Preserve nefario customization content**
   - Option A: Merge `AGENT.overrides.md` sections into `the-plan.md` nefario spec
   - Option B: Ensure `nefario/AGENT.md` contains all necessary content (already true)

2. **Delete overlay artifacts**
   - Remove `nefario/AGENT.generated.md`, `nefario/AGENT.overrides.md`
   - Delete `validate-overlays.sh`, `docs/override-format-spec.md`, `docs/validate-overlays-spec.md`
   - Remove `tests/fixtures/` overlay test directories

3. **Update documentation**
   - `docs/agent-anatomy.md`: Remove overlay sections (~130 lines), rename to "Agent Anatomy"
   - `docs/build-pipeline.md`: Remove merge step, simplify to single-file generation
   - `docs/decisions.md`: Add decision record superseding Decisions 9 and 16
   - `docs/architecture.md`: Update sub-documents table (remove "Overlay System" from title)

4. **Simplify `/despicable-lab` SKILL.md**
   - Option A: Remove overlay-specific logic (already unified pipeline)
   - Option B: Add skip condition for nefario, document in skill description

5. **Verify deployment artifacts**
   - Check `install.sh` for overlay references (none expected, but verify)
   - Confirm CI workflows have no stale overlay validation steps

**Execution owner**: devx-minion (infrastructure changes) with software-docs-minion (documentation updates).

**Estimated effort**: 2-3 hours for artifact removal and documentation updates. Low risk -- no runtime behavior changes, only build-time infrastructure.

**Testing**: Rebuild all agents via `/despicable-lab` after changes. Verify nefario spec-version and build-date update correctly (Option A) or skip correctly (Option B).
