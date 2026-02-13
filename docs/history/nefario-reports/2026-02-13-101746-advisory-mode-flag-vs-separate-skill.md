---
type: nefario-report
version: 3
date: "2026-02-13"
time: "10:17:46"
task: "Advisory mode: flag on nefario vs separate skill"
mode: advisory
agents-involved: [nefario, devx-minion, ai-modeling-minion, margo, lucy]
task-count: 0
gate-count: 0
outcome: completed
---

# Advisory mode: flag on nefario vs separate skill

## Summary

The team evaluated whether advisory-only orchestration (assembling specialists for evaluation and report without code changes) should be a `--advisory` flag on `/nefario` or a separate skill. Unanimous agreement: a separate skill is wrong. The central debate -- build the flag now vs. wait -- resolved in favor of waiting, upheld by margo's YAGNI argument and the project's own engineering philosophy. Natural language already works for advisory runs.

## Original Prompt

> should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. or should that be a separate skill?

## Key Design Decisions

#### Separate skill rejected unanimously

**Rationale**:
- 60-70% code duplication with SKILL.md (ai-modeling-minion's estimate)
- Fork maintenance: every SKILL.md change requires mirroring
- Fragments discoverability -- users must know the skill exists
- Violates YAGNI, KISS, Lean and Mean

**Alternatives Rejected**:
- `/nefario-advisory` or `/advisory` as separate skill: all four specialists rejected for reasons above

#### Do nothing now (wait for pain)

**Rationale**:
- YAGNI: one usage (SDK evaluation), zero observed friction
- Natural language directive ("advisory only, no changes") works on first attempt
- SKILL.md is 1,928 lines -- every conditional branch is maintenance cost
- This very conversation proves the pattern works without formalization

**Alternatives Rejected**:
- Build `--advisory` flag now: 3 agents favored this (devx-minion, ai-modeling-minion, lucy) but margo's BLOCK was upheld because the project's engineering philosophy (YAGNI, KISS) explicitly demands waiting for demonstrated need. Low implementation cost (~60-70 lines) is not zero cost.

### Conflict Resolutions

**Build now vs. wait**: Three agents (devx-minion, ai-modeling-minion, lucy) recommended building a `--advisory` flag immediately. Margo issued a BLOCK, arguing YAGNI. Resolution: margo's position upheld because it directly applies the project's stated engineering principles (Helix Manifesto). The pro-flag agents' architectural analysis is preserved for when triggers fire.

## Phases

### Phase 1: Meta-Plan

Nefario identified four specialists for this design question: devx-minion (CLI/skill interface design), ai-modeling-minion (orchestration architecture), margo (YAGNI/KISS challenge), and lucy (intent alignment, identity coherence). No external skills were relevant. The question was framed along two axes: flag vs. separate skill (interface question) and build now vs. wait (timing question).

### Phase 2: Specialist Planning

Four specialists contributed in parallel. devx-minion analyzed discoverability, cognitive load, and the `/despicable-prompter` precedent, concluding that advisory is a flag (same workflow, different terminal condition). ai-modeling-minion mapped the nine phases to advisory mode, finding Phases 1-2 identical, Phase 3 divergent, and Phases 3.5-8 inapplicable -- concluding advisory is architecturally a mode, not a separate process. margo issued a BLOCK on both options, arguing natural language already works and formalization is YAGNI. lucy found no identity drift but noted the SDK evaluation's ad hoc report landed in non-standard locations, suggesting some formalization value.

### Phase 3: Synthesis

Nefario synthesized the positions. The separate-skill option was eliminated unanimously. The central disagreement (build flag now vs. wait) was resolved in margo's favor by applying the project's own YAGNI principle. The synthesis established five concrete triggers for when to revisit, and a two-step escalation path (3-line string expansion first, full MODE: ADVISORY second). The synthesis also noted the irony that this advisory-only conversation is itself the second use of the pattern, providing evidence for both sides.

### Phase 3.5: Architecture Review

Skipped (advisory-only orchestration, no execution plan to review).

### Phase 4: Execution

Skipped (advisory-only orchestration, no code changes).

### Phase 5-8

Skipped (advisory-only orchestration).

<details>
<summary>Agent Contributions (4 planning, 0 review)</summary>

### Planning

**devx-minion**: Strong preference for `--advisory` flag based on discoverability, cognitive load, principle of least surprise, and implementation simplicity. The `/despicable-prompter` precedent actually supports a flag -- that skill exists separately because it has a fundamentally different workflow, whereas advisory shares 80%+ of nefario's workflow.
- Adopted: Analysis of interface options; rejection of separate skill
- Risks flagged: SKILL.md complexity growth; advisory report format differs from execution reports

**ai-modeling-minion**: Advisory mode is architecturally a mode (`MODE: ADVISORY`), not a separate process. Phases 1-2 identical, Phase 3 diverges to recommendation format, Phases 3.5-8 skipped. Implementation estimated at ~60-70 lines concentrated at two locations.
- Adopted: Phase mapping analysis; confirmation that advisory is a subset of existing orchestration
- Risks flagged: Synthesis prompt needs advisory-specific format constraints; may need separate report template

**margo**: BLOCK on both flag and separate skill. YAGNI -- natural language already works. One usage, zero friction, zero reliability failures. Both options add accidental complexity to solve a problem that doesn't exist. If friction emerges later, a 3-line string expansion in argument parsing is the maximum justified intervention.
- Adopted: YAGNI verdict upheld as team recommendation; 3-line string expansion as Step 0; concrete trigger conditions
- Risks flagged: Premature abstraction; encoding the wrong pattern from insufficient samples

**lucy**: Flag on nefario, not separate skill. No identity drift -- advisory is a subset of what nefario already does (precedent: MODE: PLAN already produces plans without executing). Advisory reports should go to same directory with `type: nefario-advisory` frontmatter.
- Adopted: No-identity-drift analysis; report location recommendation (same directory, different type)
- Risks flagged: SDK evaluation's ad hoc report landed in non-standard locations (.local.md, non-standard scratch paths)

</details>

## Team Recommendation

**Do nothing now.** Wait for demonstrated need before formalizing advisory mode.

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Separate skill is wrong | All 4 (unanimous) | Strong |
| Do nothing now (wait for pain) | margo (upheld by synthesis) | Strong (aligned with project philosophy) |
| Build `--advisory` flag now | devx-minion, ai-modeling-minion, lucy | Strong arguments, overridden by YAGNI |

### When to Revisit

Build the `--advisory` flag when ANY of these conditions are met:

1. **Frequency threshold**: 3+ advisory-only runs completed
2. **Reliability failure**: Nefario ignores the "no changes" directive
3. **Report inconsistency**: Ad hoc advisory reports have inconsistent structure/location
4. **Onboarding friction**: A second user needs to discover the capability
5. **Workflow integration**: Advisory reports need structured frontmatter for automation

### Escalation Path (when trigger fires)

- **Step 0**: Add `--advisory` as a string expansion in argument parsing -- 3 lines, zero conditional logic (margo's minimal path)
- **Step 1**: Full `MODE: ADVISORY` if Step 0 proves insufficient -- ~60-70 lines, advisory report template, type-based organization (devx-minion + ai-modeling-minion + lucy's design)

### Strongest Arguments

**For building now** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| Same workflow, different terminal condition = flag territory | devx-minion |
| Phases 1-3 identical, clean branch point at Phase 3/4 boundary | ai-modeling-minion |
| No identity drift, natural third mode | lucy |
| Report location/type consistency prevents future mess | lucy |

**For waiting** (adopted):

| Argument | Agent |
|----------|-------|
| YAGNI: one usage, zero friction | margo |
| Natural language already works on first attempt | margo |
| SKILL.md is 1,928 lines, every branch is maintenance cost | margo |
| 3-line string expansion covers the gap if friction emerges | margo |

### Self-Referential Note

This advisory-only orchestration is itself the second use of the pattern. It worked via natural language, as margo predicted. This is evidence for margo's position (the pattern works without formalization) and evidence toward the frequency threshold (usage count is now 2, not 1). Neither is decisive.

## Working Files

<details>
<summary>Working files (13 files)</summary>

Companion directory: [2026-02-13-101746-advisory-mode-flag-vs-separate-skill/](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/)

- [Original Prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-devx-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-ai-modeling-minion.md)
- [Phase 2: margo](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-margo.md)
- [Phase 2: lucy](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase3-synthesis.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-devx-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: margo prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-margo-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-101746-advisory-mode-flag-vs-separate-skill/phase3-synthesis-prompt.md)

</details>
