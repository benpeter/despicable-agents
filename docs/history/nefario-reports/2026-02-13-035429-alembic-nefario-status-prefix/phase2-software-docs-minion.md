# Planning Contribution: software-docs-minion

## Planning Question

> Are there other documentation files (README, `docs/architecture.md`, `the-plan.md`) that reference nefario's output format verbatim and would need updating for consistency? Identify any docs that quote phase markers or status line format.

## Analysis

I audited all documentation files in the repository for verbatim references to nefario's phase markers, status line format, gate headers, and output templates. Here is the complete inventory of files that quote these formats, organized by impact level.

### Files That Quote Phase Markers or Status Line Format Verbatim

**1. `docs/using-nefario.md` (line 191) -- MUST UPDATE**

Contains a verbatim status line example that will need the alembic prefix:

```
`~/my-project | Claude Opus 4 | Context: 12% | P2 Planning | Build MCP server with OAuth...`
```

This is the only user-facing documentation that shows what the status line looks like. After the change, it should show the symbol preceding the phase marker. This is the single highest-priority documentation update outside the primary edit targets.

**2. `skills/nefario/SKILL.md` (multiple lines) -- PRIMARY EDIT TARGET (already scoped)**

Contains all `echo` commands that write to the status file:
- Line 367: `echo "P1 Meta-Plan | $summary"`
- Line 580: `echo "P2 Planning | $summary"`
- Line 654: `echo "P3 Synthesis | $summary"`
- Line 730: `echo "P3.5 Review | $summary"`
- Line 1184: `echo "P4 Execution | $summary"`
- Line 1314: `echo "P4 Gate | $task_title"`
- Line 1331: `echo "P4 Execution | $summary"`

Also contains the `P<N> <Label>` convention note (line 469) and all AskUserQuestion `header` values (lines 471, 1039, 1319, 1398, 1507, 1536).

**3. `.claude/skills/despicable-statusline/SKILL.md` -- ALREADY SCOPED**

Contains the shell command that reads from `/tmp/nefario-status-$sid` and appends to the status line. The statusline skill itself does not need changes -- it reads and displays whatever the nefario skill writes. However, verify that the default status line command's total length budget still works with the added symbol character.

### Files That Reference Nefario Output Format Generically (NO UPDATE NEEDED)

**4. `docs/orchestration.md`**

References "Phase 1", "Phase 2", etc. in prose and Mermaid sequence diagrams, but does NOT quote the `P<N>` shorthand format or the status file content. No update needed.

**5. `docs/compaction-strategy.md`**

References phase names in prose ("Phase 1: Meta-Plan", "Phase 2: Specialist Planning") and shows compaction checkpoint examples with `**COMPACT**` labels. Does NOT quote the `P<N>` shorthand or status file format. No update needed.

**6. `docs/architecture.md`**

References nefario's nine-phase process in prose ("meta-plan, specialist consultation, synthesis, architecture review, execution..."). Does NOT quote any output format. No update needed.

**7. `README.md`**

References "phased orchestration" and "nine structured phases" generically. Does NOT quote output format. No update needed.

**8. `nefario/AGENT.md`**

Already scoped as a primary edit target. References MODE labels ("MODE: META-PLAN", "MODE: SYNTHESIS", "MODE: PLAN") but does NOT contain status file `echo` commands or `P<N>` shorthand. Any changes here would be to phase announcement messaging templates, if they exist in the agent.

**9. `the-plan.md`**

Per CLAUDE.md rules, this file must NOT be modified. I confirmed it does NOT contain any references to the `P<N>` format, status line format, or `nefario-status` patterns. No conflict.

**10. `docs/decisions.md`**

Does NOT reference status line format or phase markers. No update needed.

**11. `docs/agent-catalog.md`**

Does NOT reference status line format or phase markers. No update needed.

**12. `docs/history/nefario-reports/TEMPLATE.md`**

Contains phase names in section headers ("Phase 1: Meta-Plan", "Phase 2: Specialist Planning") but these are report section titles, not status line format. No update needed.

**13. Historical execution reports (`docs/history/nefario-reports/*.md`)**

Multiple reports reference `P<N>` format in their content (particularly the `2026-02-13-032818-show-phase-task-in-status-and-gates.md` report). These are historical records and should NOT be modified -- they document what happened at the time of that orchestration.

### Summary: Required Documentation Updates

| File | What to Update | Priority |
|------|---------------|----------|
| `skills/nefario/SKILL.md` | All `echo` commands writing to status file; `P<N>` convention note; gate header values | Primary target (already scoped) |
| `nefario/AGENT.md` | Phase announcement templates if present | Primary target (already scoped) |
| `docs/using-nefario.md` line 191 | Verbatim status line example | **Must update for consistency** |
| `.claude/skills/despicable-statusline/SKILL.md` | Already scoped; verify length budget | Already scoped |

### Risks

1. **AskUserQuestion header length constraint**: SKILL.md line 468-469 states headers must not exceed 12 characters, and the `P<N> <Label>` convention reserves 3-5 chars for the phase prefix. Adding the alembic symbol (1-2 characters depending on variant) to gate headers may push some headers over the 12-character limit. Headers like "P4 Calibrate" (12 chars) are already at the boundary. The executing agent should verify whether the symbol goes in the header or only in the status file / phase announcements.

2. **Text variant selector in `echo` commands**: The status file `echo` commands use shell strings. The text variant selector (U+FE0E) is an invisible character that could be lost during copy-paste or editing. Recommendation: add a comment in SKILL.md next to the first `echo` command explaining the variant selector, so future editors do not accidentally strip it.

3. **Historical report consistency**: Past execution reports describe the `P<N>` format without the alembic symbol. This is expected and correct -- historical reports should not be retroactively modified. But the execution report for THIS task should note the format change in its Key Design Decisions section for future reference.

### Dependencies

- The `docs/using-nefario.md` update depends on knowing the final format chosen for the status line (whether the symbol goes before `P<N>` or elsewhere). This should be updated in the same PR as the SKILL.md changes.

### No Additional Specialists Needed

The files identified are all within the scope of the agents already involved in this task. No additional specialist consultation is needed for the documentation aspect.
