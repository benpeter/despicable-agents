---
task: "Fix Phase 8 documentation drift safeguards"
date: 2026-03-16
time: "16:43:02"
mode: full
agents-involved: [ai-modeling-minion, lucy, margo, software-docs-minion, ux-strategy-minion, security-minion, test-minion, code-review-minion]
task-count: 3
gate-count: 1
outcome: completed
docs-debt: none
compaction-events: 0
---

## Summary

Root cause analysis and fix for Phase 8 documentation drift safeguards in the nefario orchestration framework. The framework was used to orchestrate 6 PRs on the web-resource-ledger project (Act 1), but significant documentation drift accumulated because Phase 8 (Documentation) was skippable as a single unit — skipping execution also skipped assessment. Five failure patterns identified: user-directed skip with no debt visibility, "handled inline" self-assessment, partial "covered by Task N" claims, scope misjudgment, and cross-PR drift accumulation. Fixed by splitting Phase 8 into 8a (always-run assessment) and 8b (skippable execution), expanding the outcome-action table with 8 new drift categories, and adding docs-debt tracking to the report template.

## Original Prompt

../web-resource-ledger/docs/evolution/0022-docs-drift-audit shows that the work I did on ../web-resource-ledger, although done with this here framework, created docs drift. I had designed this framework to make sure exactly that cannot happen, but it seems it does. Look at why that still happens and why the things that were found in the explicit docs drift analysis were not caught in this framework's usual operations.

## Key Design Decisions

### Phase 8a always-run assessment vs mandatory Phase 8 execution
Chose always-run assessment (8a) with skippable execution (8b) over mandatory full Phase 8. Preserves user autonomy for rapid iteration while making doc debt visible.

### Reject cross-session debt ledger
Reports ARE the ledger. A persistent debt file adds state management complexity for a problem the always-generate checklist has not yet failed to solve. Sided with margo (YAGNI) over ux-strategy-minion.

### Reject diff-based doc scan
Fix the process first — the checklist was skipped, not wrong. The expanded outcome-action table covers the taxonomy gaps. Sided with margo over software-docs-minion.

### Keep checklist generation in calling session
Delegating to software-docs-minion (lucy's proposal) adds a subagent call to every orchestration. Evidence requirement on the calling session is lighter-weight and sufficient.

### Binary docs-debt state (none | deferred)
Removed `not-evaluated` — it's a dead state with no valid population path after the 8a-always fix. Sided with ux-strategy-minion.

## Phases

### Phase 1: Meta-Plan
Identified 5 specialists: ai-modeling-minion (Phase 8 prompt pipeline), lucy (governance gap analysis), margo (simplicity/YAGNI), software-docs-minion (outcome-action table gaps), ux-strategy-minion (skip mechanism UX).

### Phase 2: Specialist Planning
All 5 consulted in parallel. Universal consensus: checklist generation must always run, outcome-action table needs expansion, "handled inline" must be banned. Key tension: cross-session debt tracking (ux-strategy wants it, margo says YAGNI).

### Phase 3: Synthesis
3 tasks, 1 gate. Resolved tensions in favor of minimum viable fix (margo's position) plus ux-strategy's lightweight docs-debt frontmatter field.

### Phase 3.5: Architecture Review
5 mandatory reviewers. 3 APPROVE (security, test, margo), 2 ADVISE (ux-strategy, lucy). Advisories: make Tasks 1+2 sequential (overlapping line ranges), show only MUST-priority items in debt CONDENSE line, remove `not-evaluated` state, update Phase 8 header explicitly. All incorporated.

### Phase 4: Execution
- **Task 1**: Phase 8 restructure — split into 8a (always-run assessment) and 8b (skippable execution), banned "handled inline", added debt recording, updated all skip paths and CONDENSE lines. GATE approved.
- **Task 2**: Outcome-action table expansion — 7 new category rows + 1 catch-all, updated priority assignments.
- **Task 3**: Report template + AGENT.md — added docs-debt frontmatter field, Documentation Debt section, updated Phase 8 description.

### Phase 5: Code Review
3 reviewers (code-review-minion, lucy, margo). All ADVISE, 0 BLOCK. Findings fixed: stale SKILL.md overview line, stale AGENT.md skip description, advisory-mode docs-debt guidance.

### Phase 6: Test Execution
Skipped — no test infrastructure exists in this project.

### Phase 8: Documentation
Phase 8a assessment found 2 stale doc references (using-nefario.md, orchestration.md). Phase 8b executed: both files updated to reflect 8a/8b split.

## Agent Contributions

### Planning Phase
| Agent | Contribution |
|-------|-------------|
| ai-modeling-minion | Phase 8 prompt pipeline analysis; 8a/8b split architecture; evidence requirement design |
| lucy | Governance gap analysis; ALWAYS/Conditional contradiction identification; Phase 5 scope analysis |
| margo | YAGNI assessment; rejected debt ledger, diff scan, Phase 5 expansion; 3-fix minimum viable scope |
| software-docs-minion | 7 outcome-action table additions; OpenAPI Phase 6/8 split analysis; partial coverage verification |
| ux-strategy-minion | Skip mechanism UX; cry-wolf risk; debt visibility through existing interaction points |

### Review Phase
| Agent | Verdict | Key Finding |
|-------|---------|-------------|
| security-minion | APPROVE | No attack surface; checklist metadata, not credentials |
| test-minion | APPROVE | Verify Phase 8a scratch write is outside skip conditional |
| ux-strategy-minion | ADVISE | Debt CONDENSE line cry-wolf risk; remove not-evaluated state |
| lucy | ADVISE | Tasks 1+2 overlapping line ranges; overview line inconsistency |
| margo | APPROVE | Proportional fix; no rejected proposals leaked |

### Code Review Phase
| Agent | Verdict | Key Finding |
|-------|---------|-------------|
| code-review-minion | ADVISE | Stale AGENT.md skip description; advisory-mode docs-debt guidance |
| lucy | ADVISE | SKILL.md overview contradiction; the-plan.md spec divergence (known — requires human approval) |
| margo | ADVISE | Table row overlap (noted, kept for WRL drift pattern specificity) |

## Execution

| Task | Agent | Status | Files | Lines |
|------|-------|--------|-------|-------|
| 1. Phase 8 restructure | ai-modeling-minion | Complete | skills/nefario/SKILL.md | +52 |
| 2. Table expansion | ai-modeling-minion | Complete | skills/nefario/SKILL.md | +14 |
| 3. Report template + AGENT.md | ai-modeling-minion | Complete | TEMPLATE.md, AGENT.md | +12 |
| Code review fixes | orchestrator | Complete | SKILL.md, AGENT.md, TEMPLATE.md | +5/-4 |
| Doc updates | orchestrator | Complete | using-nefario.md, orchestration.md | +6/-5 |

## Decisions

### Gate: Phase 8 Restructure
- **Decision**: Approve Phase 8 split into 8a (always-run assessment) and 8b (skippable execution)
- **Confidence**: HIGH
- **Rejected**: Mandatory Phase 8 execution (creates approval fatigue), diff-based scan (premature tooling), external checklist agent (unnecessary latency)

## Verification

Verification: code review passed (3 ADVISE findings fixed), no tests applicable (no test infrastructure), docs updated (2 files: using-nefario.md, orchestration.md).

## Session Resources

<details>
<summary>Skills Invoked</summary>

- `/nefario` — primary orchestration

</details>

<details>
<summary>Compaction</summary>

0 compaction events.

</details>

## Working Files

Companion directory: `docs/history/nefario-reports/2026-03-16-164302-docs-drift-root-cause-analysis/`

Contains phase prompts, specialist contributions, synthesis, review verdicts, and execution prompts.
