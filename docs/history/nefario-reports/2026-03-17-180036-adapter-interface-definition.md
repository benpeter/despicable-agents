---
type: nefario-report
version: 3
date: "2026-03-17"
time: "18:00:36"
task: "Adapter Interface Definition"
source-issue: 138
mode: full
agents-involved: [software-docs-minion, api-design-minion, devx-minion, ai-modeling-minion, ux-strategy-minion, security-minion, test-minion, lucy, margo, code-review-minion]
task-count: 2
gate-count: 5
outcome: completed
docs-debt: none
---

# Adapter Interface Definition

## Summary

Defined the `DelegationRequest`, `DelegationResult`, and `FileChange` types as a Markdown specification document (`docs/adapter-interface.md`), completing Issue 1.1 of the external harness roadmap. The spec includes field tables, YAML examples, a security-hardened behavioral contract, and an excluded fields table with decay clause. All 9 downstream issues (1.2 through 3.4) implement against this document.

## Original Prompt

> Adapter Interface Definition (Issue #138) — Define the `DelegationRequest` and `DelegationResult` types that all adapters implement. Types and contracts only, no implementation.

## Key Design Decisions

#### Format for Type Definitions

**Rationale**:
- The codebase is Markdown-native with zero TypeScript files
- Consumers are humans and LLMs, not compilers
- Matches the existing `docs/agent-anatomy.md` pattern (YAML examples + field tables)

**Alternatives Rejected**:
- TypeScript interface notation (api-design-minion): would create false expectations in a codebase with no TypeScript runtime
- JSON Schema (considered by devx-minion): adds tooling overhead with no present benefit

#### Status Representation

**Rationale**:
- Binary `success` boolean matches the orchestrator's decision model (proceed or handle failure)
- Prevents abstraction leakage — orchestrator never needs per-tool exit code knowledge
- Raw `exit_code` preserved for debugging and adapter-specific diagnostics

**Alternatives Rejected**:
- Three-value `status` enum (api-design-minion): adds vocabulary without adding information beyond `success` + `exit_code`
- `adapter_error` boolean (ai-modeling-minion): third state (infra vs. task failure) not yet distinguished by orchestrator error handling

#### Field Naming Refinements

**Rationale**:
- Four field names refined from roadmap working vocabulary for clarity
- `translated_instruction_path` (was `instruction_file_path`): communicates Issue 1.3 already produced the file
- `task_summary` (was `stdout_summary`): describes meaning, not provenance
- `raw_diff_path` (was `raw_diff_reference`): pins representation as file path
- `required_agent_tools` (was `required_tools`): disambiguates from adapter tools

**Alternatives Rejected**:
- Keep roadmap names unchanged: would cause adapter authors to misunderstand field semantics on first read

### Decisions

- **Additional fields beyond roadmap**
  Chosen: Add `timeout_ms`, `success`, `duration_ms` only
  Over: Including `context_files`, `requires_rationale`, `rationale`, `adapter_error` (ai-modeling-minion, api-design-minion)
  Why: Included fields are either required for abstraction integrity (`success`), referenced by downstream acceptance criteria (`timeout_ms`), or have a known roadmap consumer (`duration_ms`). Excluded fields have no consumer in M1-M4 and can be added non-breakingly.

- **Behavioral contract scope**
  Chosen: Flat boundary rules grouped by concern (validation, invocation safety, cleanup, error handling, success normalization, prohibitions)
  Over: 8-step numbered lifecycle sequence (original synthesis)
  Why: Lifecycle choreography belongs to adapter implementation issues (2.1/3.2). The contract defines what adapters must and must not do, not how they do it.

- **YAGNI scope override (user directive)**
  Chosen: Keep `duration_ms` in DelegationResult
  Over: Move to excluded fields (margo recommendation)
  Why: User vetoed — roadmap-planned items with known consumers should not be deferred under YAGNI. M4 progress monitoring is the planned consumer. CLAUDE.local.md updated with "YAGNI Scope: Roadmap-Aware, Not Myopic" section. Issue #151 filed for margo calibration.

## Phases

### Phase 1: Meta-Plan

Nefario identified 5 specialists for planning: software-docs-minion (primary author domain), devx-minion (developer experience for adapter authoring), api-design-minion (type definition patterns), ai-modeling-minion (LLM integration considerations), and ux-strategy-minion (field naming and mental model). The scope was constrained to "types and contracts only" per Issue 1.1.

### Phase 2: Specialist Planning

Five specialists contributed in parallel. Key outputs: devx-minion recommended Markdown field tables over TypeScript (matching codebase convention), api-design-minion proposed a status enum and TypeScript notation (both later rejected), ai-modeling-minion proposed `duration_ms` and `rationale` fields (duration kept, rationale excluded), ux-strategy-minion identified four field naming improvements (all adopted), and software-docs-minion recommended the `agent-anatomy.md` pattern.

### Phase 3: Synthesis

Nefario resolved three conflicts: format (Markdown over TypeScript), status representation (`success` boolean over enum), and field scope (3 additions, 4 exclusions via YAGNI filter). Four field renames adopted from ux-strategy-minion. Final plan: 2 tasks, 1 gate.

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo). No discretionary reviewers needed — task produces only a Markdown spec with no UI or runtime output. Verdicts: 2 APPROVE (test-minion, ux-strategy-minion), 3 ADVISE (security-minion with 5 security hardening items, margo with lifecycle trim + duration_ms + decay clause, lucy with field rename mapping + back-link format).

### Phase 4: Execution

Task 1 (software-docs-minion): wrote `docs/adapter-interface.md` (226 lines) with all 9 advisories incorporated — security-hardened behavioral contract, boundary rules, field rename mapping table, and excluded fields decay clause. Approved at gate.

Task 2 (software-docs-minion): added architecture.md hub link and roadmap forward pointer. Two single-line edits.

### Phase 5: Code Review

Three reviewers in parallel: lucy (ADVISE — stale roadmap field name, forward pointer display text), margo (ADVISE — working_directory validation duplication across 3 locations), code-review-minion (ADVISE — stale roadmap field names in Issues 1.1 and 3.1, missing FileChange renamed semantics, loose cross-reference). All findings auto-fixed: deduplicated validation rule, added renamed semantics note, updated roadmap field names, fixed cross-reference and display text.

### Phase 6: Test Execution

Skipped (no executable code produced — specification document only).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a assessment: 0 items identified. The task IS documentation — the deliverable is itself the architecture contract. Architecture hub already updated (Task 2). Phase 8b: skipped (empty checklist).

<details>
<summary>Agent Contributions (5 planning, 5 review)</summary>

### Planning

**software-docs-minion**: Recommended `agent-anatomy.md` pattern for document structure.
- Adopted: document structure, YAML example patterns
- Risks flagged: premature abstraction before adapter implementation validates types

**devx-minion**: Recommended Markdown field tables, rejected TypeScript notation.
- Adopted: format decision (Markdown over TypeScript), spec-implementation drift risk
- Risks flagged: no type checker means adapters could diverge from spec

**api-design-minion**: Proposed TypeScript notation, status enum, `timeout` and `contextFiles` fields.
- Adopted: `timeout_ms` field
- Risks flagged: premature abstraction, `success` boolean may be insufficient for retry logic

**ai-modeling-minion**: Proposed `duration_ms`, `rationale`, `adapter_error`, `requires_rationale` fields.
- Adopted: `duration_ms` field
- Risks flagged: rationale quality degradation for external harnesses

**ux-strategy-minion**: Identified four field naming issues, proposed `success` boolean.
- Adopted: all four renames, `success` boolean design
- Risks flagged: none

### Architecture Review

**security-minion**: ADVISE. 5 findings: working_directory path traversal prevention, task_prompt CWE-78 mitigation, secrets handling guidance, temp file permissions (mode 0600), success normalization constraints. All incorporated into behavioral contract.

**test-minion**: APPROVE. No concerns.

**ux-strategy-minion**: APPROVE. No concerns.

**lucy**: ADVISE.
- SCOPE: Three fields beyond roadmap scope. CHANGE: No change (plan already justified). WHY: YAGNI filter applied, three passed with documented rationale.
- SCOPE: Field renames from roadmap vocabulary. CHANGE: Add mapping note in spec. WHY: Downstream issues reference original names.

**margo**: ADVISE.
- SCOPE: Behavioral contract lifecycle section. CHANGE: Trim to boundary rules only. WHY: Implementation choreography belongs to Issues 2.1/3.2.
- SCOPE: `duration_ms` field. CHANGE: Move to excluded (user vetoed). WHY: No consumer in M1-M4.
- SCOPE: Excluded fields table. CHANGE: Add decay clause. WHY: Prevent calcification into change-control gate.

### Code Review

**lucy**: ADVISE. Stale field name in roadmap Issue 3.1 (`stdout_summary` → `task_summary`), forward pointer display text inconsistency. Both fixed.

**margo**: ADVISE. Working_directory validation duplicated across 3 locations (field table, semantics notes, behavioral contract). Deduplicated to behavioral contract as single authority.

**code-review-minion**: ADVISE. Stale roadmap field names (Issues 1.1, 3.1), missing FileChange renamed semantics, loose `raw_diff_path` cross-reference. All fixed.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Write `docs/adapter-interface.md` | software-docs-minion | completed |
| 2 | Cross-reference links | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [docs/adapter-interface.md](../../adapter-interface.md) | created | Full adapter interface spec: DelegationRequest, DelegationResult, FileChange types, behavioral contract, excluded fields |
| [docs/architecture.md](../../architecture.md) | modified | Added Adapter Interface row to Contributor / Architecture table |
| [docs/external-harness-roadmap.md](../../external-harness-roadmap.md) | modified | Added specification forward pointer to Issue 1.1, updated `stdout_summary` → `task_summary` in Issue 3.1 |

### Approval Gates

| Gate | Type | Outcome | Notes |
|------|------|---------|-------|
| Team selection | Team | approved | 5 specialists |
| Reviewer selection | Reviewer | auto-approved | 5 mandatory, 0 discretionary |
| Execution plan | Plan | approved | User vetoed margo YAGNI on `duration_ms`; CLAUDE.local.md updated; #151 filed |
| Task 1: adapter-interface.md | Mid-execution | approved | Root contract for 9 downstream issues |
| Post-execution phases | Post-exec | run all | Code review, tests, documentation |

#### Execution Plan Approval

**Decision**: Accept plan with user override on `duration_ms` YAGNI advisory.
**Rationale**: User directive — YAGNI should not apply to roadmap-planned items with known consumers. `duration_ms` has a planned consumer in M4 progress monitoring.
**Rejected**: Margo's recommendation to move `duration_ms` to excluded fields.

## Decisions

#### Task 1: Write docs/adapter-interface.md

**Decision**: Full adapter interface spec with security-hardened behavioral contract, field tables, YAML examples, and all advisories incorporated.
**Rationale**: Behavioral contract structured as flat boundary rules grouped by concern (validation, invocation safety, cleanup, error handling, success normalization, prohibitions). Rejected numbered lifecycle sequence (belongs to implementation issues). Rejected must/must-not table format (security requirements needed prose).
**Rejected**: 8-step lifecycle sequence (margo: implementation choreography, not contract); must/must-not table (security rules need prose to be actionable).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK — 6 findings auto-fixed (dedup validation, add renamed semantics, fix cross-ref, update stale field names, fix display text) |
| Test Execution | Skipped (specification document, no executable code) |
| Deployment | Skipped (not requested) |
| Documentation | Phase 8a: 0 items. Phase 8b: skipped (empty checklist) |

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 3 events

</details>

<details>
<summary>Working files (27 files)</summary>

Companion directory: [2026-03-17-180036-adapter-interface-definition/](./2026-03-17-180036-adapter-interface-definition/)

- [Original Prompt](./2026-03-17-180036-adapter-interface-definition/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-17-180036-adapter-interface-definition/phase1-metaplan.md)
- [Phase 2: ai-modeling-minion](./2026-03-17-180036-adapter-interface-definition/phase2-ai-modeling-minion.md)
- [Phase 2: api-design-minion](./2026-03-17-180036-adapter-interface-definition/phase2-api-design-minion.md)
- [Phase 2: devx-minion](./2026-03-17-180036-adapter-interface-definition/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-03-17-180036-adapter-interface-definition/phase2-software-docs-minion.md)
- [Phase 2: ux-strategy-minion](./2026-03-17-180036-adapter-interface-definition/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-03-17-180036-adapter-interface-definition/phase3-synthesis.md)
- [Phase 3.5: lucy](./2026-03-17-180036-adapter-interface-definition/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-03-17-180036-adapter-interface-definition/phase3.5-margo.md)
- [Phase 3.5: security-minion](./2026-03-17-180036-adapter-interface-definition/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-03-17-180036-adapter-interface-definition/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-03-17-180036-adapter-interface-definition/phase3.5-ux-strategy-minion.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-03-17-180036-adapter-interface-definition/phase1-metaplan-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: api-design-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase2-api-design-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase2-devx-minion-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase2-software-docs-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase2-ux-strategy-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-03-17-180036-adapter-interface-definition/phase3-synthesis-prompt.md)
- [Phase 3.5: lucy prompt](./2026-03-17-180036-adapter-interface-definition/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-03-17-180036-adapter-interface-definition/phase3.5-margo-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-03-17-180036-adapter-interface-definition/phase4-software-docs-minion-prompt.md)
- [Phase 4: software-docs-minion Task 2 prompt](./2026-03-17-180036-adapter-interface-definition/phase4-software-docs-minion-task2-prompt.md)

</details>
