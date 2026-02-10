---
type: nefario-report
version: 1
date: "2026-02-09"
sequence: 2
task: "Bump nefario spec to v1.4, fix cross-cutting inconsistencies, create overlay files, verify consistency"
mode: full
agents-involved: [ai-modeling-minion, software-docs-minion, devx-minion, ux-strategy-minion]
task-count: 6
gate-count: 0
outcome: completed
---

# Nefario v1.4 Update Report

**Date**: 2026-02-09
**Orchestration**: Full nefario five-phase process (all opus)
**Scope**: Bump nefario spec to v1.4, fix cross-cutting inconsistencies, create overlay files, verify consistency

## Executive Summary

Updated the nefario agent ecosystem from v1.3 to v1.4 across all touchpoints:
the-plan.md, AGENT.md, SKILL.md, and ARCHITECTURE.md. Expanded the cross-cutting
checklist from 5 to 6 dimensions, promoted ux-strategy-minion and
software-docs-minion to ALWAYS reviewers, created overlay files for rebuild
protection, and verified 33 consistency assertions with zero failures.

## Changes Made

### 1. the-plan.md — Nefario Spec v1.4

**What changed**:
- Bumped spec-version from 1.2 to 1.4
- Rewrote invocation model to five-phase (added Phase 3.5 Architecture Review)
- Expanded cross-cutting checklist from 5 to 6 dimensions
- Split "Accessibility" into "Usability — Strategy" (ALWAYS) and "Usability — Design" (conditional 1+)
- Promoted "Documentation" to ALWAYS
- Added architecture review triggering table with 4 ALWAYS + 2 conditional reviewers
- Added gate classification matrix (reversibility × blast radius)
- Documented x-fine-tuned in frontmatter pattern
- Restricted MODE: PLAN to user-explicit-only

### 2. nefario/AGENT.md — v1.4 Update

**What changed**:
- x-plan-version bumped from "1.3" to "1.4"
- Cross-cutting checklist: "five dimensions" → "six dimensions"
- Added Usability — Strategy (ux-strategy-minion, ALWAYS)
- Changed Accessibility → Usability — Design (ux-design-minion, conditional 1+)
- Promoted Documentation to ALWAYS
- Architecture Review trigger table: 2 ALWAYS → 4 ALWAYS reviewers
- Synthesis output template: "Mandatory" → "Always", expanded reviewer list
- Meta-plan checklist: 5 items → 6 items
- x-fine-tuned: true retained

### 3. SKILL.md — Reviewer Expansion + Calibration

**What changed**:
- Phase 3.5 mandatory reviewers: 2 → 4 (added ux-strategy-minion, software-docs-minion)
- ux-design-minion threshold: "plan includes UI work" → "1+ tasks produce user-facing interfaces"
- observability-minion threshold: clarified to "2+ tasks produce runtime components"
- Added calibration check to anti-fatigue guidelines

### 4. ARCHITECTURE.md — Five-Phase Alignment

**What changed**:
- "four-phase" → "five-phase" in all references (Task Delegation, Planning heading)
- Sequence diagram: added Phase 3.5 Architecture Review block
- Nefario Tier 2 description: updated delegation pattern to name all five phases
- Frontmatter schema: documented x-fine-tuned as optional field
- Cross-cutting concerns: 5 items → 6 items with ALWAYS/conditional annotations

### 5. Overlay Files Created

**nefario/AGENT.generated.md** (401 lines):
- Clean /lab build output from v1.4 spec
- No x-fine-tuned flag
- Simpler approval gates (no decision brief template, no response handling details)
- Simpler architecture review (no verdict format templates, no ARCHITECTURE.md template)

**nefario/AGENT.overrides.md** (126 lines):
- Documents all hand-tuned enhancements beyond generated baseline
- Approval Gates: decision brief format, response handling, anti-fatigue rules, cascading gates, gate vs. notification
- Architecture Review: triggering rationale, detailed verdict formats, ARCHITECTURE.md template
- Conflict Resolution: enhanced from single paragraph to three named patterns
- Output Standards: added Final Deliverables subsection

### 6. Non-Nefario Agent Check

All 18 non-nefario agents (gru + 17 minions) are at x-plan-version "1.0" matching
their spec-version "1.0" in the-plan.md. No rebuilds needed.

## Consistency Verification

**33 assertions checked, 33 PASS, 0 FAIL.**

Categories verified:
- Version & metadata (6 assertions): all synchronized
- Phase count (4 assertions): "five-phase" everywhere, no "four-phase" remnants
- Cross-cutting checklist (7 assertions): 6 dimensions, ALWAYS flags correct
- Architecture review triggers (5 assertions): 4 ALWAYS reviewers consistent across 3 files
- ARCHITECTURE.md specifics (3 assertions): sequence diagram, x-fine-tuned, 6 items
- Overlay files (4 assertions): both exist with documented enhancements
- SKILL.md (2 assertions): calibration check present, correct reviewer list
- Cross-file consistency (2 assertions): synthesis template and meta-plan checklist aligned

## Conflict Resolutions

### 1. ux-design-minion: ALWAYS vs. Conditional

**Specialists disagreed**: ux-strategy-minion proposed both UX agents as ALWAYS.
ai-modeling-minion proposed ux-design conditional.

**Resolution**: ux-strategy-minion is ALWAYS (reviews WHAT/WHY — journey coherence,
cognitive load, JTBD). ux-design-minion is conditional at 1+ UI tasks (reviews HOW —
accessibility, visual hierarchy, interaction patterns). Clear non-overlapping boundary.

### 2. software-docs-minion: Conditional vs. ALWAYS

**Previous state**: Conditional at "2+ tasks change architecture or API surface."
**User directive**: Documentation should be ALWAYS.
**Resolution**: Promoted to ALWAYS. Even non-architecture tasks benefit from
documentation gap analysis.

### 3. x-fine-tuned Flag

**Question**: Should overlay system change how x-fine-tuned works?
**Resolution**: Keep x-fine-tuned: true as a simple signal in AGENT.md frontmatter.
The overlay files (AGENT.generated.md + AGENT.overrides.md) provide the detailed
mechanism. x-fine-tuned is the quick check; overlays are the implementation.

### 4. MODE: PLAN Restriction

**Previous state**: Nefario could shortcut to PLAN mode on its own judgment.
**Resolution**: MODE: PLAN restricted to user-explicit-only. Nefario does not
shortcut to it autonomously. This ensures the full five-phase process runs unless
the user deliberately opts out.

## Backup

Tar backup created before any changes: `~/despicable-agents-backup-*.tar.gz`
Snapshot of pre-update AGENT.md: `nefario/AGENT.md.snapshot`

## Files Modified

| File | Action |
|------|--------|
| the-plan.md | Updated nefario spec to v1.4 |
| nefario/AGENT.md | Updated to v1.4 (6 dimensions, 4 ALWAYS reviewers) |
| nefario/SKILL.md | Expanded reviewers, added calibration check |
| ARCHITECTURE.md | Five-phase alignment, Phase 3.5, 6 cross-cutting items |
| nefario/AGENT.generated.md | **Created** — clean build baseline |
| nefario/AGENT.overrides.md | **Created** — hand-tuning documentation |
| report-v2.md | **Created** — this file |

## Outstanding Items

- **Nefario-gated simplification**: DEFERRED from v1.3. Nefario would classify task
  complexity (simple/standard/complex) and route accordingly. Not implemented —
  full process always runs per user directive.
- **Overlay build automation**: The overlay files are created but /lab does not yet
  implement the merge logic (AGENT.generated.md + AGENT.overrides.md → AGENT.md).
  This is documented in architecture-update-build.md as a PROPOSED enhancement.
- **AGENT.md.snapshot cleanup**: Can be removed once this report is reviewed.
  It was a safety backup for the v1.3 → v1.4 transition.
