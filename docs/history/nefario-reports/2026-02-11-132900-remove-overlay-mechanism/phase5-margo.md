# Margo Review: Remove Overlay Mechanism

## VERDICT: APPROVE

This execution is a net simplicity gain. It removes ~2,900 lines of accidental
complexity (overlay infrastructure serving exactly one agent) and replaces it
with a single special-case skip in the build pipeline. No new abstractions,
dependencies, or layers were introduced. The complexity budget decreased.

## Findings

### Positive

- [positive] `.claude/skills/despicable-lab/SKILL.md` -- The nefario skip is
  implemented as a simple conditional in the version check loop and an early
  return in the build step. Two lines of branching logic replace an entire
  overlay merge pipeline. This is proportional to the problem.

- [positive] `docs/agent-anatomy.md` -- `x-fine-tuned` field removed from the
  frontmatter schema table. Clean removal, no orphaned references in the
  schema.

- [positive] `docs/build-pipeline.md` -- Merge Step removed entirely. Pipeline
  is now a clean two-step (Research, Build) followed by Cross-Check. The mermaid
  diagram, prose, and step numbering are all consistent. No vestigial overlay
  references remain.

- [positive] `docs/decisions.md` -- Decision 9 and Decision 16 properly marked
  as "Superseded by Decision 27". Decision 27 is well-documented with clear
  rationale, rejected alternatives, and the "one-agent rule" re-introduction
  trigger. This preserves institutional memory without cluttering active docs.

- [positive] `nefario/AGENT.md:1-13` -- `x-fine-tuned: true` removed from
  frontmatter. Clean, no other frontmatter changes.

- [positive] `docs/deployment.md` -- Simplified to remove overlay references.
  The mermaid diagram now shows only AGENT.md files (no generated/overrides).

### Observations (non-blocking)

- [info] `docs/history/overlay-implementation-summary.md` and
  `docs/history/overlay-decision-guide.md` still exist. These are historical
  records and should be retained -- they document the decision journey, not
  active architecture. No action needed.

- [info] Historical nefario reports (e.g., `2026-02-09-003-overlay-drift-detection.md`,
  `2026-02-11-122254-improve-gate-context-clarity/phase1-metaplan.md`) still
  reference overlays and `x-fine-tuned`. These are immutable historical records
  and should not be modified. No action needed.

- [info] `docs/decisions.md:191` -- Decision 15 still references
  "AGENT.overrides.md" in its Consequences field: "Constraints previously encoded
  in `AGENT.overrides.md` (Decision 15) are now maintained directly in
  `nefario/AGENT.md`." This sentence is in Decision 27 and is correct as-is --
  it explains the migration, not an active dependency.

### Complexity Assessment

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Overlay files | 3 (generated, overrides, deployed) | 1 (deployed) | -2 files per customized agent |
| Validation script | 659 lines | 0 | -659 lines |
| Spec documents | ~1,060 lines | 0 | -1,060 lines |
| Test fixtures | 10 fixtures + harness | 0 | removed |
| Build pipeline steps | 3 (Research, Build, Merge) | 2 (Research, Build) | -1 step |
| Special cases in /despicable-lab | 0 (overlay handled all agents uniformly) | 1 (nefario skip) | +1 special case |
| Dependency: bash 4.0+ | required (associative arrays in validate-overlays.sh) | not required | -1 dependency |

**Net assessment**: One special case added (nefario skip) vs. ~2,900 lines and
an entire subsystem removed. The complexity budget math is overwhelmingly
positive. The special case is clearly documented in three places (SKILL.md,
build-pipeline.md, Decision 27) with a concrete re-introduction trigger
("one-agent rule: when a second agent needs customization preservation").

No new abstractions, no new dependencies, no new layers, no scope creep, no
future-proofing beyond the re-introduction trigger. This is a clean removal.
