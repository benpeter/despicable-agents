---
type: nefario-report
version: 3
date: "2026-02-13"
time: "17:41:58"
task: "Add skills and tools usage tracking to nefario execution reports"
source-issue: 98
mode: full
agents-involved: [nefario, devx-minion, ai-modeling-minion, test-minion, ux-strategy-minion, security-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 2
gate-count: 1
outcome: completed
---

# Add skills and tools usage tracking to nefario execution reports

## Summary

Replaced the always-empty External Skills section in nefario execution reports with a broader Session Resources section that tracks which skills were invoked and what tools the orchestrator used during a session. Added `skills-used` conditional frontmatter field. Updated conditional rules, collapsibility rules, formatting rules, and the report writing checklist in TEMPLATE.md. Updated SKILL.md with data accumulation instructions and wrap-up sequence references for the new section. Fixed stale reference counts and an orphaned External Skills reference in orchestration.md found during code review.

## Original Prompt

> Add skills and tools usage tracking to nefario execution reports. Use opus for all agents.

## Key Design Decisions

### Evolve External Skills into Session Resources (not a new standalone section)

Three approaches were considered: (1) new standalone Session Resources section separate from External Skills (devx-minion), (2) enrich External Skills table with an Invoked column plus sibling Resource Usage section (ai-modeling-minion), (3) evolve External Skills into a broader Session Resources section that subsumes it (ux-strategy-minion). Adopted approach 3 because External Skills has never appeared in any of 50+ existing reports (always omitted), so renaming and broadening it costs nothing in backward compatibility while preventing two confusingly-similar skills sections from coexisting.

### Collapsed by default with inline counts

The Session Resources section is wrapped in `<details>` tags with a summary line that includes inline counts (e.g., "Session resources (2 skills, 5 tool types)") so users can assess whether to expand without opening it. This follows the pattern already established by Working Files and Agent Contributions sections.

### Best-effort tool counts, orchestrator-only

Tool counts reflect the orchestrator's own tool usage only. Subagent internal tool usage is opaque and not tracked. Counts are best-effort -- if context was heavily compacted, the section gracefully degrades to "Tool counts not available for this session." In advisory mode, the Tool Usage subsection is omitted entirely.

### Conditional `skills-used` frontmatter field

Named `skills-used` (matching the verb pattern of `agents-involved`). Only included when 1+ skills beyond `/nefario` were invoked. `/nefario` is implicit for all nefario reports and listing it adds noise to frontmatter.

### Conflict Resolutions

None beyond the primary structural decision above.

## Phases

**Phase 1 (Meta-Plan):** Identified 4 specialists for planning: devx-minion (workflow integration, SKILL.md structure), ai-modeling-minion (tool usage instrumentation feasibility), test-minion (backward compatibility, conditional rule coherence), ux-strategy-minion (report section hierarchy and scanability). No external skills discovered.

**Phase 2 (Specialist Planning):** All 4 specialists contributed domain plans. Key consensus: session-total granularity only (no per-phase breakdowns), collapsed by default, best-effort tool counts. Key disagreement on section structure (resolved in synthesis). No additional agents requested.

**Phase 3 (Synthesis):** Consolidated into 2 tasks with 1 gate. Task 1 updates TEMPLATE.md (gated). Task 2 updates SKILL.md (depends on Task 1). Resolved the structural disagreement in favor of evolving External Skills.

**Phase 3.5 (Architecture Review):** 5 mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) + 1 discretionary (software-docs-minion). All 6 returned ADVISE verdicts. 5 ADVISE items folded into task prompts: advisory mode precedence for Tool Usage, inline counts in summary tag, Skills Invoked conditional rule row, `/nefario` filtering from frontmatter, skills-invoked to skills-used naming mapping.

**Phase 4 (Execution):** Task 1 (TEMPLATE.md) completed and approved at gate. Task 2 (SKILL.md) completed. Both executed by devx-minion with opus model.

**Phase 5 (Code Review):** Three reviewers (code-review-minion, lucy, margo) all returned ADVISE. 3 findings auto-fixed: stale frontmatter field count (10-11 → 10-12), stale section count (12 → 13), orphaned External Skills reference in docs/orchestration.md. Remaining NIT findings (summary tag ambiguity when Tool Usage omitted, conditional table imprecision) accepted as-is.

**Phase 6 (Tests):** Skipped (no test infrastructure for documentation changes).

**Phase 8 (Documentation):** Skipped (no checklist items -- the deliverables ARE documentation).

<details>
<summary>Agent Contributions</summary>

### Planning

- **devx-minion**: Recommended standalone Session Resources section with `skills-invoked` frontmatter field. Proposed conditional inclusion rules and `<details>` collapsibility. Contributions adopted in merged form.
- **ai-modeling-minion**: Analyzed tool usage instrumentation feasibility. Recommended best-effort approach with graceful degradation. Proposed enriching External Skills table. Table approach not adopted; best-effort framing adopted.
- **test-minion**: Identified backward compatibility requirements and conditional rule coherence criteria. Recommended explicit conditional rules for all subsections. Adopted.
- **ux-strategy-minion**: Recommended evolving External Skills into Session Resources (decisive argument). Proposed collapsed by default, inline counts in summary tag, session-total granularity only. All adopted.

### Architecture Review

- **security-minion**: ADVISE (2 low-risk items -- no security-relevant concerns for documentation changes).
- **test-minion**: ADVISE (4 items -- conditional rule coherence, Skills Invoked always-included row, advisory mode edge case, empty state handling).
- **ux-strategy-minion**: ADVISE (4 items -- inline counts in summary, advisory mode precedence, progressive disclosure, naming consistency).
- **lucy**: ADVISE (2 items -- convention adherence confirmed, naming mapping documentation).
- **margo**: ADVISE (3 items -- complexity budget acceptable, acknowledged evolving existing section is lowest-cost approach).
- **software-docs-minion**: ADVISE (5 items -- structural consistency, conditional rule clarity, collapsibility pattern, SKILL.md instruction completeness).

### Code Review

- **code-review-minion**: ADVISE (2 ADVISE: stale frontmatter count, stale section count; 3 NIT: summary tag ambiguity, conditional table imprecision, table alignment).
- **lucy**: ADVISE (3 ADVISE: orphaned External Skills reference in orchestration.md, stale frontmatter count; 1 NIT: section count pre-existing).
- **margo**: ADVISE (2 ADVISE: Skills Invoked no-op conditional rule, formatting rule complexity; 2 NIT: stale frontmatter count, summary dynamic counts).

</details>

## Execution

### Tasks

| # | Task | Agent | Model | Status |
|---|------|-------|-------|--------|
| 1 | Update TEMPLATE.md -- Session Resources section and related rules | devx-minion | opus | completed |
| 2 | Update SKILL.md -- Data Accumulation and Wrap-up Sequence | devx-minion | opus | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| docs/history/nefario-reports/TEMPLATE.md | modified | Replaced External Skills with Session Resources (3 subsections), added skills-used frontmatter, updated conditional/collapsibility/formatting rules and checklist (+47/-3) |
| skills/nefario/SKILL.md | modified | Added skills-invoked and orchestrator-tools to Data Accumulation, updated wrap-up step 6, added skills-invoked to compaction focus string, corrected reference counts (+27/-5) |
| docs/orchestration.md | modified | Replaced orphaned External Skills reference with Session Resources description (+1/-1) |

### Approval Gates

| Gate | Task | Decision | Outcome |
|------|------|----------|---------|
| 1 | Task 1: Update TEMPLATE.md | Approve | Approved -- Session Resources structure with 3 subsections, conditional rules, collapsed by default |

#### Gate 1: Update TEMPLATE.md -- Session Resources section

**Decision:** Replace External Skills with Session Resources (3 subsections, collapsed, conditional rules for all subsections)

**Rationale:**
- Evolves the always-omitted External Skills section into a useful container for session metadata
- All 5 ADVISE items from Phase 3.5 incorporated
- Rejected: standalone new section (would create duplicate skills sections), enriched table column (table was never rendered)

**Confidence:** HIGH

## Decisions

### Gate 1: Session Resources template structure

Approved the replacement of External Skills with Session Resources containing three subsections (External Skills, Skills Invoked, Tool Usage). The template establishes: `skills-used` conditional frontmatter field, 4 conditional section rules (parent always present, External Skills conditional on discovery, Skills Invoked always present, Tool Usage conditional on mode and availability), collapsed by default with inline counts in summary tag.

**Rejected alternatives:**
- Standalone new section alongside External Skills -- risk of two confusingly-similar sections
- Enriched External Skills table with Invoked column -- table was never rendered in 50+ reports

## Verification

| Phase | Outcome |
|-------|---------|
| Code Review | ADVISE -- 3 findings auto-fixed (stale counts, orphaned reference) |
| Tests | Skipped (no test infrastructure) |
| Documentation | Skipped (deliverables are documentation) |

## Session Resources

<details>
<summary>Session resources (1 skill, 7 tool types)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

### Tool Usage

| Tool | Count |
|------|-------|
| Task (subagent) | 12 |
| Read | 5 |
| Edit | 2 |
| Write | 8 |
| Bash | 18 |
| Grep | 1 |
| Glob | 0 |

Counts are best-effort, reflecting the orchestrator's own tool usage only.
Subagent internal tool usage is not tracked.

</details>

## Working Files

<details>
<summary>Working files</summary>

Companion directory: [2026-02-13-174158-skills-tools-usage-tracking/](./2026-02-13-174158-skills-tools-usage-tracking/)

| File | Description |
|------|-------------|
| prompt.md | Original user prompt |
| phase1-metaplan-prompt.md | Meta-plan input prompt |
| phase1-metaplan.md | Meta-plan output |
| phase2-devx-minion-prompt.md | devx-minion planning prompt |
| phase2-devx-minion.md | devx-minion planning contribution |
| phase2-ai-modeling-minion-prompt.md | ai-modeling-minion planning prompt |
| phase2-ai-modeling-minion.md | ai-modeling-minion planning contribution |
| phase2-test-minion-prompt.md | test-minion planning prompt |
| phase2-test-minion.md | test-minion planning contribution |
| phase2-ux-strategy-minion-prompt.md | ux-strategy-minion planning prompt |
| phase2-ux-strategy-minion.md | ux-strategy-minion planning contribution |
| phase3-synthesis-prompt.md | Synthesis input prompt |
| phase3-synthesis.md | Final delegation plan |
| phase3.5-security-minion-prompt.md | security-minion review prompt |
| phase3.5-security-minion.md | security-minion ADVISE verdict |
| phase3.5-test-minion-prompt.md | test-minion review prompt |
| phase3.5-test-minion.md | test-minion ADVISE verdict |
| phase3.5-ux-strategy-minion-prompt.md | ux-strategy-minion review prompt |
| phase3.5-ux-strategy-minion.md | ux-strategy-minion ADVISE verdict |
| phase3.5-lucy-prompt.md | lucy review prompt |
| phase3.5-lucy.md | lucy ADVISE verdict |
| phase3.5-margo-prompt.md | margo review prompt |
| phase3.5-margo.md | margo ADVISE verdict |
| phase3.5-software-docs-minion-prompt.md | software-docs-minion review prompt |
| phase3.5-software-docs-minion.md | software-docs-minion ADVISE verdict |
| phase4-devx-minion-task1-prompt.md | Task 1 execution prompt |
| phase4-devx-minion-task2-prompt.md | Task 2 execution prompt |
| phase5-code-review-minion-prompt.md | Code review prompt |
| phase5-code-review-minion.md | Code review ADVISE verdict |
| phase5-lucy-prompt.md | lucy code review prompt |
| phase5-lucy.md | lucy ADVISE verdict |
| phase5-margo-prompt.md | margo code review prompt |
| phase5-margo.md | margo ADVISE verdict |

</details>
