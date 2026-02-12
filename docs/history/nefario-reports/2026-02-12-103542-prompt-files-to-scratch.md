---
type: nefario-report
version: 3
date: "2026-02-12"
time: "10:35:42"
task: "Write agent prompts to scratch files before invocation"
source-issue: 45
mode: full
agents-involved: [nefario, devx-minion, ux-strategy-minion, ai-modeling-minion, security-minion, test-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 1
gate-count: 1
outcome: completed
---

# Write agent prompts to scratch files before invocation

## Summary

Added side-effect prompt file writing to all agent invocation points in the nefario orchestration skill. Before each agent spawn, the orchestrator now writes the constructed prompt to a `-prompt.md` scratch file. Agents continue receiving prompts inline -- the files are persistence artifacts for transparency and context preservation. Updated the report template Working Files section with Outputs/Prompts group headers.

## Original Prompt

**Outcome**: Agent input prompts are written to named files in the scratch directory before invocation, and agents receive a file reference rather than the full prompt inline. This serves two goals: users can trace any advisory back to the exact prompt that produced it (transparency), and prompts persist as durable artifacts that survive context compression and can be re-read by agents or the orchestrator later (context preservation).

**Success criteria**:
- Each agent invocation writes its input prompt to a file in scratch before the agent runs
- Agents read their prompt from the file rather than receiving it entirely inline
- Agent output files in scratch are clearly paired with their input prompt files
- Advisory summaries presented to the user include a file path reference to the corresponding input prompt
- Existing orchestration behavior (phase flow, agent selection, synthesis) is unchanged

**Scope**:
- In: Prompt file creation and agent file-reference delivery for all phases that invoke agents, advisory formatting with prompt links
- Out: Changes to agent system prompts, changes to META-PLAN or SYNTHESIS content format, scratch dir cleanup/retention policy

## Agent Contributions

### Planning Phase

| Agent | Recommendation | Tasks |
|-------|---------------|-------|
| devx-minion | `-prompt` suffix naming convention, hybrid file-reference delivery, input/output pairing by filename | 4 |
| ux-strategy-minion | Side-effect writing over file-reference delivery; both goals achievable without changing delivery mechanism | 2 |
| ai-modeling-minion | Confirmed side-effect writing; inline delivery has better positional fidelity, file-reference has silent degradation risk | 0 (advisory only) |

### Review Phase

| Agent | Verdict | Key Finding |
|-------|---------|-------------|
| security-minion | ADVISE | Extend secret sanitization to all -prompt.md files |
| test-minion | APPROVE | No executable code; validation via next orchestration session |
| ux-strategy-minion | APPROVE | Side-effect approach maintains simplicity |
| software-docs-minion | ADVISE | Keep flat list in TEMPLATE.md (overruled by user) |
| lucy | ADVISE | Flag scope deviation at approval gate |
| margo | ADVISE | All-phases persistence is mild overkill but acceptable |

## Decisions

### Approval Gate: Prompt persistence changes

- **Decision**: Accept side-effect prompt writing with all advisories incorporated
- **Rationale**: Side-effect model confirmed by ai-modeling-minion (better reliability, no silent degradation risk, better prompt positional fidelity). `-prompt` suffix keeps input/output paired alphabetically. All phases included for audit trail consistency.
- **Rejected**: File-reference delivery (silent failure risk, positional fidelity loss per ai-modeling-minion). Selective persistence (inconsistent companion directories per margo).
- **Confidence**: HIGH
- **Outcome**: Approved

## Key Design Decisions

#### Side-effect writing over file-reference delivery

The issue's literal success criterion says "agents read their prompt from the file rather than receiving it entirely inline." The plan intentionally does NOT deliver file-reference delivery. ai-modeling-minion provided the decisive technical argument: instructions in the Task tool's `prompt:` parameter (user turn) receive higher attention weight than instructions retrieved via tool call. Additionally, file-reference delivery carries a silent degradation risk -- if the file read fails, the agent has just enough context from its system prompt to plausibly attempt the task with hallucinated instructions.

### Conflict Resolutions

**File-reference delivery vs side-effect writing**: Resolved in favor of side-effect writing. devx-minion's naming convention and directory structure adopted; delivery mechanism kept as-is per ux-strategy-minion and ai-modeling-minion.

**Selective vs complete persistence**: Resolved in favor of all-phases. Consistency outweighs marginal Write cost.

**TEMPLATE.md group headers vs flat list**: software-docs-minion, lucy, and margo recommended flat list. User overruled in favor of group headers.

## Execution

| # | Task | Agent | Status | Deliverables |
|---|------|-------|--------|-------------|
| 1 | Update SKILL.md and TEMPLATE.md with prompt persistence | devx-minion | Completed | `skills/nefario/SKILL.md` (+84 lines), `docs/history/nefario-reports/TEMPLATE.md` (+26 lines) |

## Files Changed

| File | Action | Description |
|------|--------|-------------|
| skills/nefario/SKILL.md | modified | Added prompt persistence instructions at 8 invocation points, updated scratch directory structure, updated advisory format with optional Prompt: field |
| docs/history/nefario-reports/TEMPLATE.md | modified | Added Outputs/Prompts group headers in Working Files, extended skeleton to cover all phases, added label convention for -prompt.md files |

## Verification

| Phase | Status | Details |
|-------|--------|---------|
| Code Review | Passed | 1 ADVISE finding auto-fixed (TEMPLATE.md Working Files completeness) |
| Tests | Skipped | No executable code produced; markdown skill files have no test infrastructure |
| Documentation | Skipped | Documentation artifacts were the primary deliverable |

## Working Files

<details>
<summary>Working files (9 files)</summary>

Companion directory: [2026-02-12-103542-prompt-files-to-scratch/](./2026-02-12-103542-prompt-files-to-scratch/)

- [Original Prompt](./2026-02-12-103542-prompt-files-to-scratch/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-12-103542-prompt-files-to-scratch/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-12-103542-prompt-files-to-scratch/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-12-103542-prompt-files-to-scratch/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-12-103542-prompt-files-to-scratch/phase2-ai-modeling-minion.md)
- [Phase 3: Synthesis](./2026-02-12-103542-prompt-files-to-scratch/phase3-synthesis.md)
- [Phase 5: code-review-minion](./2026-02-12-103542-prompt-files-to-scratch/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-12-103542-prompt-files-to-scratch/phase5-lucy.md)
- [Phase 5: margo](./2026-02-12-103542-prompt-files-to-scratch/phase5-margo.md)

</details>
