---
type: nefario-report
version: 3
date: "2026-03-17"
time: "19:38:06"
task: "Define YAML schema for .nefario/routing.yml and implement config loader with validation"
source-issue: 139
mode: full
agents-involved: [devx-minion, api-design-minion, ai-modeling-minion, security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 3
gate-count: 1
outcome: completed
docs-debt: none
---

# Routing Configuration Schema (#139)

## Summary

Defined the YAML schema for `.nefario/routing.yml` and implemented a shell-based config loader with 8-category validation, capability gating, shallow-per-section merge for user overrides, and a `--resolve` subcommand for Phase 4 dispatch. The loader uses yq+jq, requires zero dependencies for the zero-config path, and produces actionable error messages. 85 integration tests pass. Full specification documented at `docs/routing-config.md`.

## Original Prompt

> Define the YAML schema for `.nefario/routing.yml` and implement config loading with validation.
>
> Scope: Schema with `default` harness, optional `groups` (per-agent-group), optional `agents` (per-agent), optional `model-mapping` (tier to provider ID per harness). Resolution order: agent > group > default > implicit `claude-code`. Capability gating validates agent `tools:` requirements against harness capability list at load time. Zero-config path: no file means everything routes to `claude-code`. Config loading reads from project-level `.nefario/routing.yml` and optional user-level override.

## Key Design Decisions

#### YAML Parsing Tool: yq (Mike Farah Go binary)

**Rationale**:
- De facto standard for shell YAML processing, consistent with existing jq usage in the project
- Zero-config path skips yq entirely (no dependency needed when no config file exists)

**Alternatives Rejected**:
- Pure awk: Brittle for YAML edge cases (nested maps, multiline strings)
- Python loader: Adds dependency management the project does not have (no pip)

#### Category-Batched Validation

**Rationale**:
- Reports ALL errors within the first failing validation category before stopping
- Balances "actionable feedback" (no meaningless errors from later categories) with "no fix-reload cycles" (all errors of one kind at once)

**Alternatives Rejected**:
- Stop-at-first-error (devx-minion): Forces fix-one-reload-fix-another cycles within a category
- Report-all-errors (ux-strategy-minion): Shows meaningless errors from categories that depend on earlier fixes

#### Canonical Group IDs Only

**Rationale**:
- 9 canonical group IDs derived from the agent roster (e.g., `development-quality`, `governance`)
- Recognition over recall — users pick from a known list instead of inventing names
- Per-agent `agents:` override covers any case where canonical grouping doesn't match routing intent

**Alternatives Rejected**:
- Arbitrary user-defined groups: Creates a membership-assignment indirection layer and an entire class of silent misconfiguration

#### User-Level Config at `~/.claude/nefario/routing.yml`

**Rationale**:
- Users already know `~/.claude/` as the despicable-agents config root (agents, skills, hooks live there)
- Recognition over recall — consistent with existing hierarchy

**Alternatives Rejected**:
- `~/.nefario/routing.yml`: Discoverable but disconnected from existing `~/.claude/` hierarchy

### Decisions

- **Error batching strategy**
  Chosen: Category-batched (report all errors within first failing category)
  Over: Stop-at-first-error (devx-minion) and report-all-errors (ux-strategy-minion)
  Why: Best of both — actionable without fix-reload cycles within a category

- **User-level merge semantics**
  Chosen: Shallow-per-section merge (user sections replace corresponding project sections)
  Over: Full replacement (security-minion) where user config entirely replaces project config
  Why: Full replacement forces users to copy entire project config for one-section overrides

- **Codex capability set**
  Chosen: `[Read, Write, Edit, Bash, Glob, Grep]` (6 tools)
  Over: `[Read, Write, Edit, Bash]` (4 tools, api-design-minion)
  Why: Glob/Grep achievable via Bash in Codex sandbox. One-line change if M2 validation shows otherwise.

## Phases

### Phase 1: Meta-Plan

Identified 7 specialists: devx-minion (config loader DX), api-design-minion (capability gating vocabulary), ai-modeling-minion (group taxonomy and merge logic), security-minion (trust boundary), test-minion (test approach), ux-strategy-minion (progressive disclosure), software-docs-minion (spec document format). No external skills relevant.

### Phase 2: Specialist Planning

All 7 specialists contributed in parallel. Strong consensus on: yq for YAML parsing, canonical group IDs (not arbitrary), exact tool names for capability vocabulary (matching AGENT.md and DelegationRequest), shallow merge for user overrides, user config at `~/.claude/nefario/`. No additional agents recommended.

### Phase 3: Synthesis

Produced a 3-task plan with 1 approval gate. Resolved 4 conflicts: error batching strategy (category-batched compromise), merge semantics (shallow-per-section over full-replacement), user config path (`~/.claude/nefario/` over `~/.nefario/`), Codex capability set (6 tools over 4).

### Phase 3.5: Architecture Review

6 reviewers (5 mandatory + software-docs-minion discretionary). Results: 1 APPROVE (lucy), 5 ADVISE. 14 advisory items incorporated into task prompts. Key advisories: smarter YAML anchor detection (security), CLI override path validation (security), `--resolve` test coverage (testing), derive agent names from filesystem (margo), merge asymmetry documentation (ux-strategy, margo), stale feasibility study text (software-docs).

### Phase 4: Execution

Task 1 (devx-minion): Implemented `lib/load-routing-config.sh` (~1001 lines) with 8-category validation, capability registry, merge logic, `--resolve` subcommand. Also produced `.nefario/routing.example.yml`.

Task 2 (test-minion, parallel): Created `tests/test-routing-config.sh` with 85 integration tests across 15+ fixtures. All acceptance criteria covered. Group membership drift detection included.

Task 3 (software-docs-minion, parallel): Created `docs/routing-config.md` following adapter-interface.md pattern. Updated 3 existing docs with cross-links. Fixed stale "proposed convention" text and non-canonical group names in feasibility study.

### Phase 5: Code Review

3 reviewers (code-review-minion, lucy, margo). All ADVISE, 0 BLOCK. 6 findings auto-fixed: predictable temp file names replaced with mktemp, --user-config path validation added, dead emit_errors function removed, full-power-user fixture fixed, YAML anchor test added, canon_path tilde expansion fixed. All 85 tests pass after fixes.

### Phase 6: Test Execution

85 tests, 0 failures. All 4 acceptance criteria verified. Edge cases covered including group membership drift, YAML anchor rejection, and explicit --user-config missing file.

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a assessment: 1 SHOULD-priority item (CLAUDE.md structure update for new directories). Fixed immediately — added `lib/`, `tests/`, `.nefario/` to CLAUDE.md Structure section.

## Agent Contributions

<details>
<summary>Agent Contributions (7 planning, 6 review, 3 code review)</summary>

### Planning

**devx-minion**: Recommended yq for YAML parsing, single shell script emitting JSON, ordered validation, canonical group IDs, shallow merge.
- Adopted: All recommendations
- Risks flagged: yq version fragmentation (two incompatible tools named yq)

**api-design-minion**: Recommended exact tool names matching AGENT.md vocabulary, hardcoded capability registry.
- Adopted: All recommendations
- Risks flagged: Agents omitting tools: field default to all tools

**ai-modeling-minion**: Recommended canonical group IDs only, shallow merge per top-level section, model-mapping defaults in code.
- Adopted: All recommendations
- Risks flagged: Canonical groups may not match user routing intent (covered by per-agent override)

**security-minion**: Recommended user-level override project-level, safe YAML parser, 64KB limit, path validation.
- Adopted: Trust hierarchy, YAML safety, path validation. Overridden: full replacement (shallow merge chosen instead)
- Risks flagged: Malicious routing.yml redirecting tasks to unintended provider

**test-minion**: Recommended self-contained bash test script, 14+ fixtures, black-box integration tests.
- Adopted: All recommendations
- Risks flagged: Parser choice affects test dependencies

**ux-strategy-minion**: Recommended progressive disclosure, canonical group names, batch error reporting, user config at ~/.claude/nefario/.
- Adopted: All recommendations
- Risks flagged: User-defined group names cause silent misrouting

**software-docs-minion**: Recommended new standalone docs/routing-config.md following adapter-interface.md pattern.
- Adopted: All recommendations
- Risks flagged: Doc timing relative to implementation

### Architecture Review

**lucy**: APPROVE. All requirements have bidirectional traceability. Implementation proportional to problem.

**security-minion**: ADVISE. 4 items: YAML anchor detection false positives, CLI override path validation, silent user-level override logging, AGENT.md trust boundary documentation.

**test-minion**: ADVISE. 3 items: mock AGENT.md format mismatch, --resolve subcommand test coverage, group membership drift test.

**ux-strategy-minion**: ADVISE. 3 items: merge semantics inconsistency documentation, capability gating error completeness, --resolve unknown agent handling.

**margo**: ADVISE. 2 items: derive agent names from filesystem instead of hardcoding, document merge asymmetry.

**software-docs-minion**: ADVISE. 2 items: stale "proposed convention" text in feasibility study, non-canonical group names in feasibility study examples.

### Code Review

**code-review-minion**: ADVISE. 7 findings including predictable temp files, --user-config path inconsistency, default harness capability gating gap (doc fix for M1).

**lucy**: ADVISE. Traceability verified. Dead fixture flagged. CLAUDE.md structure update recommended.

**margo**: ADVISE. Dead emit_errors function, predictable temp files, no YAML anchor test. Scope alignment confirmed tight.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Implement Config Loader | devx-minion | completed |
| 2 | Write Tests | test-minion | completed |
| 3 | Document Spec | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| lib/load-routing-config.sh | created | Config loader with validation, merge, resolve |
| .nefario/routing.example.yml | created | Progressive example config |
| tests/test-routing-config.sh | created | 85 integration tests |
| tests/fixtures/routing/*.yml | created | 16 test fixtures |
| docs/routing-config.md | created | Full specification document |
| docs/architecture.md | modified | Added routing-config.md cross-link |
| docs/external-harness-roadmap.md | modified | Added specification link under #139 |
| docs/external-harness-integration.md | modified | Updated routing section, fixed examples |
| CLAUDE.md | modified | Added lib/, tests/, .nefario/ to structure |

### Approval Gates

| Gate | Type | Outcome | Notes |
|------|------|---------|-------|
| Team Selection | Team | approved | 7 specialists, Lucy proxy |
| Reviewer Selection | Reviewer | approved | 5 mandatory + 1 discretionary, Lucy proxy |
| Execution Plan | Plan | approved | 3 tasks, 1 gate, Lucy proxy |
| Config Loader Schema | Mid-execution | approved | Lucy proxy |

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK. 6 findings auto-fixed. |
| Test Execution | 85 passed, 0 failed |
| Deployment | Skipped (not requested) |
| Documentation | 1 item assessed and fixed (CLAUDE.md structure) |

## Session Resources

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 0 events

</details>

## Working Files

<details>
<summary>Working files (18 files)</summary>

Companion directory: [2026-03-17-193806-routing-configuration-schema/](./2026-03-17-193806-routing-configuration-schema/)

| File | Description |
|------|-------------|
| prompt.md | Original task description |
| phase1-metaplan-prompt.md | Meta-plan input prompt |
| phase1-metaplan.md | Meta-plan output |
| phase2-devx-minion.md | devx-minion planning contribution |
| phase2-api-design-minion.md | api-design-minion planning contribution |
| phase2-ai-modeling-minion.md | ai-modeling-minion planning contribution |
| phase2-security-minion.md | security-minion planning contribution |
| phase2-test-minion.md | test-minion planning contribution |
| phase2-ux-strategy-minion.md | ux-strategy-minion planning contribution |
| phase2-software-docs-minion.md | software-docs-minion planning contribution |
| phase3-synthesis-prompt.md | Synthesis input prompt |
| phase3-synthesis.md | Final delegation plan |
| phase3.5-security-minion.md | Security review verdict |
| phase3.5-test-minion.md | Test review verdict |
| phase3.5-ux-strategy-minion.md | UX strategy review verdict |
| phase3.5-lucy.md | Lucy review verdict |
| phase3.5-margo.md | Margo review verdict |
| phase3.5-software-docs-minion.md | Software docs review verdict |

</details>
