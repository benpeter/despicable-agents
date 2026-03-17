---
type: nefario-report
version: 3
date: "2026-03-17"
time: "12:21:00"
task: "Iterate external harness report with user feedback and create Codex-first roadmap"
mode: full
agents-involved: [ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy, margo, security-minion, test-minion, ux-strategy-minion]
task-count: 3
gate-count: 1
outcome: completed
docs-debt: none
---

# Iterate external harness report with user feedback and create Codex-first roadmap

## Summary

Second orchestration on the external harness integration branch. Iterated [docs/external-harness-integration.md](../../external-harness-integration.md) with five user feedback items (routing configuration DX, model specification, worktree isolation, quality parity, Aider result collection) and created [docs/external-harness-roadmap.md](../../external-harness-roadmap.md) with 13 sequenced issues across 4 milestones for the Codex-first implementation path.

## Original Prompt

> Feed user feedback into the research report: configuration gap (how users specify routing), model specification (how model: maps across tools), worktree isolation (state definitively), quality parity (user's responsibility), Aider result collection (LLM diff summarization is the answer). Create a Codex-first roadmap with sequenced issues, extensible for future tools, formatted for GitHub issue creation.

## Key Design Decisions

#### Routing Configuration via .nefario/routing.yml

**Rationale**:
- Follows dotfile convention (.github/, .vscode/)
- Three granularity levels (default, group, agent) cover all use cases
- Zero-config preserves existing behavior

**Alternatives Rejected**:
- CLAUDE.md (wrong concern — routing is orthogonal to agent instructions)
- AGENT.md frontmatter (conflates identity with invocation)

#### Quality-Tier Model Mapping

**Rationale**:
- AGENT.md model: (opus/sonnet) stays as quality-tier intent
- Routing config maps tiers to provider-specific IDs per harness
- Users explicitly choose models; no auto-routing

**Alternatives Rejected**:
- Auto-quality-tracking: user explicitly said this is their responsibility
- Direct model IDs in AGENT.md: would make agent specs harness-specific

#### YAGNI-Enforced Roadmap

**Rationale**:
- Only Codex adapter fully decomposed
- Aider adapter validates the abstraction
- Future tools get headline-level milestones only

**Alternatives Rejected**:
- Pre-building abstractions for all tools: premature without second adapter validation

### Conflict Resolutions

Config location (.despicable/ vs .nefario/ vs .claude/): adopted .nefario/routing.yml as proposed convention. Milestone count (4-6 proposals): consolidated to 4 concrete + 4 future. Adapter interface timing (define-first vs extract-after): minimal interface in M1, validated by M3.

## Phases

### Phase 1: Meta-Plan

Same 6-agent team reused per user instruction (ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy). Team gate auto-approved per user directive.

### Phase 2: Specialist Planning

Six specialists contributed. Key additions: devx-minion designed the routing config surface (3 granularity levels, YAML format). gru confirmed worktrees as definitive answer and advised against TypeScript SDK. mcp-minion defined adapter interface shape. lucy validated no contradictions in user feedback and identified nefario scope boundary (Phase 4 step 3 only).

### Phase 3: Synthesis

Consolidated into 3-task plan: report iteration (gated), roadmap creation, cross-link update. Five conflicts resolved. Advisories from Phase 3.5 pre-incorporated (YAGNI trims to roadmap issues).

### Phase 3.5: Architecture Review

Five mandatory reviewers. 3 APPROVE (security, test, ux-strategy), 2 ADVISE (lucy, margo). Lucy: reframe M7 Quality Logging as optional user-side tooling. Margo: drop premature features from Issue 1.2.

### Phase 4: Execution

Task 1: Updated report (319 lines). Task 2: Created roadmap (320 lines, 13 issues). Task 3: Added cross-link to architecture.md.

### Phase 5: Code Review

Skipped (--skip-post).

### Phase 6: Test Execution

Skipped (docs-only changes).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a: 0 items (deliverables ARE documentation). Phase 8b: skipped.

<details>
<summary>Agent Contributions (6 planning, 5 architecture review)</summary>

### Planning

**ai-modeling-minion**: Layered routing config with quality-tier abstraction. Four roadmap milestones.
- Adopted: Quality-tier mapping, milestone structure, model resolver concept
- Risks flagged: Reasoning effort controls, config complexity

**gru**: Codex CLI stability assessment, worktree isolation definitive answer, TypeScript SDK rejection.
- Adopted: Worktrees as standard, SDK avoidance, version pinning strategy
- Risks flagged: Codex pre-1.0 breaking changes

**devx-minion**: .nefario/routing.yml with three granularity levels, zero-config defaults.
- Adopted: Config location, granularity model, capability gating
- Risks flagged: Config file discovery, capability gating complexity

**mcp-minion**: DelegationRequest/DelegationResult interface shape, frontmatter stripping, LLM summarization service.
- Adopted: Interface types, pre-invocation git ref capture, instruction file lifecycle
- Risks flagged: Git state mutation, interface versioning

**software-docs-minion**: Report restructuring approach, roadmap format (milestone/issue hierarchy).
- Adopted: Full report change plan, docs/external-harness-roadmap.md location, issue template
- Risks flagged: Report bloat, roadmap over-decomposition

**lucy**: No contradictions in feedback, nefario scope boundary, YAGNI enforcement.
- Adopted: Phase 4-only change boundary, Codex-only concrete decomposition
- Risks flagged: Premature abstraction in roadmap

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: APPROVE. Testing exclusion appropriate.

**ux-strategy-minion**: APPROVE. Report serves developer reader, roadmap serves issue creator.

**lucy**: ADVISE. Reframe M7 as user-side tooling. Narrow Issue 4.2 to Codex+Aider.

**margo**: ADVISE. Drop premature features from Issue 1.2 (JSON Schema, "did you mean?", CI/CD env vars). 13-issue ceiling.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Iterate docs/external-harness-integration.md | software-docs-minion | completed |
| 2 | Create docs/external-harness-roadmap.md | software-docs-minion | completed |
| 3 | Update docs/architecture.md cross-link | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [docs/external-harness-integration.md](../../external-harness-integration.md) | modified | Added routing/config section, resolved 3 open questions, added frontmatter note |
| [docs/external-harness-roadmap.md](../../external-harness-roadmap.md) | created | Codex-first roadmap: 4 milestones, 13 issues, 4 future milestones |
| [docs/architecture.md](../../architecture.md) | modified | Added roadmap to sub-documents table |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Iterate research report | software-docs-minion | HIGH | approved | 1 |

## Decisions

#### Iterate research report

**Decision**: Accept report iteration with all 5 user feedback items addressed.
**Rationale**: Routing config section fills the main gap. Three open questions resolved definitively per user direction. Forward reference to roadmap in place.
**Rejected**: Keeping open questions open (user gave definitive answers).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (--skip-post) |
| Test Execution | Skipped (docs-only changes) |
| Deployment | Skipped (not requested) |
| Documentation | Phase 8a: 0 items (deliverables are documentation) |

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 0 events (skipped per user instruction)

</details>

## Working Files

<details>
<summary>Working files (15 files)</summary>

Companion directory: [2026-03-17-122100-harness-iteration-roadmap/](./2026-03-17-122100-harness-iteration-roadmap/)

- [Original Prompt](./2026-03-17-122100-harness-iteration-roadmap/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-17-122100-harness-iteration-roadmap/phase1-metaplan.md)
- [Phase 2: ai-modeling-minion](./2026-03-17-122100-harness-iteration-roadmap/phase2-ai-modeling-minion.md)
- [Phase 2: gru](./2026-03-17-122100-harness-iteration-roadmap/phase2-gru.md)
- [Phase 2: devx-minion](./2026-03-17-122100-harness-iteration-roadmap/phase2-devx-minion.md)
- [Phase 2: mcp-minion](./2026-03-17-122100-harness-iteration-roadmap/phase2-mcp-minion.md)
- [Phase 2: software-docs-minion](./2026-03-17-122100-harness-iteration-roadmap/phase2-software-docs-minion.md)
- [Phase 2: lucy](./2026-03-17-122100-harness-iteration-roadmap/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-03-17-122100-harness-iteration-roadmap/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-03-17-122100-harness-iteration-roadmap/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-03-17-122100-harness-iteration-roadmap/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-03-17-122100-harness-iteration-roadmap/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-03-17-122100-harness-iteration-roadmap/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-03-17-122100-harness-iteration-roadmap/phase3.5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-03-17-122100-harness-iteration-roadmap/phase1-metaplan-prompt.md)

</details>
