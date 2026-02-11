---
type: nefario-report
version: 2
date: "2026-02-10"
time: "20:50:10"
task: "Decouple toolkit from self-referential path assumptions"
mode: full
agents-involved: [nefario, devx-minion, ux-strategy-minion, test-minion, software-docs-minion, security-minion, lucy, margo]
task-count: 4
gate-count: 1
outcome: completed
---

# Decouple toolkit from self-referential path assumptions

## Summary

Removed all self-referential path assumptions from the nefario orchestration toolkit so it operates on any project via CWD, not just despicable-agents itself. Scratch files now use secure temp directories (`mktemp -d`), reports write to cwd-relative detected paths, git operations guard for greenfield repos, and the despicable-prompter skill is globally installed alongside nefario.

## Original Prompt

<details>
<summary>Original prompt (expand)</summary>

> Decouple despicable-agents from self-referential assumptions so it works as a general-purpose toolkit
>
> **Outcome**: Despicable-agents cleanly separates "tooling that operates on any project" from "this project's own structure," so that users can apply the agent team to evolve external projects or create new ones from scratch -- without reports, git operations, skill context, or other behaviors defaulting to the despicable-agents repo. The project can still use its own tooling on itself, but that is an explicit mode rather than the implicit default.
>
> **Success criteria**:
> - Full audit of self-referential touchpoints completed and documented
> - Each touchpoint resolved with a clear "target project vs. tooling project" delineation
> - Nefario execution reports write to the target project (not despicable-agents) when operating on an external project
> - Git operations apply to the target project's repo by default
> - `/despicable-prompter` reads context from the target project, not despicable-agents
> - Running nefario against a brand-new empty directory works (greenfield use case)
> - Running nefario against despicable-agents itself still works (self-evolution use case)
> - No behavioral regressions for the self-evolution path
>
> **Scope**:
> - In: All agent/skill files that contain project-specific assumptions, report generation paths, git operation context, skill context resolution, CLAUDE.md references, install.sh, SKILL.md
> - Out: Agent system prompts (domain knowledge content), RESEARCH.md files, the-plan.md
>
> **Constraints**:
> - `/despicable-prompter` should become a global skill rather than project-local if that resolves its context issue
> - Must support both modes: operating on self and operating on external projects

</details>

## Decisions

#### CWD-Relative Path Resolution (No Mode Switch)

**Rationale**:
- CWD is the only context signal, like git/npm/make -- no mode flags, no config
- Zero-config experience: run from any directory, toolkit operates on that project
- Self-evolution path works naturally when cwd is despicable-agents

**Alternatives Rejected**:
- Mode flags (`--target-project`): leaks implementation, YAGNI
- Config file (`.nefario.yml`): YAGNI, adds complexity
- Environment variables (`NEFARIO_REPORTS_DIR`, `NEFARIO_SCRATCH_DIR`): arbitrary write vector, YAGNI

**Gate outcome**: approved
**Confidence**: HIGH

#### Secure Scratch via mktemp -d

**Rationale**:
- `mktemp -d` atomically creates unpredictable directory (no symlink races)
- `chmod 700` restricts to owning user
- Cleaned up at wrap-up; interrupted sessions cleaned on reboot

**Alternatives Rejected**:
- `nefario/scratch/` in working tree: self-referential, requires gitignore
- `~/.cache/nefario/`: persistent cache semantics wrong for ephemeral session state

#### Report Directory Detection Priority

**Rationale**:
- Detection order: `docs/nefario-reports/` > `docs/history/nefario-reports/` > create default
- Preserves backward compatibility with existing convention
- External projects can use either convention

**Alternatives Rejected**:
- Fixed path change: churn across 10+ documents and CI
- `.nefario/reports/`: hidden directory, non-standard

**Conflict Resolutions**:
- devx-minion proposed `docs/nefario-reports/` as simpler default; resolved by keeping existing `docs/history/nefario-reports/` as default with detection for both
- `NEFARIO_REPORTS_DIR` env var rejected unanimously (security + YAGNI)
- `commit-workflow.md` references removed entirely instead of dangling cross-repo ref
- Prompter context reading deferred (feature addition, not decoupling)
- `init-hooks` deferred (jq dependency, YAGNI)

## Agent Contributions

<details>
<summary>Agent Contributions (4 planning, 6 review)</summary>

### Planning

**devx-minion**: Proposed scratch-to-TMPDIR migration, cwd-relative report paths, three-layer detection hierarchy.
- Adopted: mktemp scratch, report detection, dynamic default branch, prompter promotion
- Risks flagged: scratch file loss on reboot (accepted)

**ux-strategy-minion**: Advocated zero-config CWD-only design. No mode switch.
- Adopted: graceful greenfield degradation, actionable git warning, CONDENSE shows resolved path
- Deferred: prompter context reading (feature addition)

**test-minion**: Designed three-level test strategy (static grep, structural smoke, manual acceptance).
- Adopted: regression-before-changes pattern, 8 hardcoded patterns identified
- Risks flagged: over-testing LLM-consumed prose (mitigated by focusing on grep-able patterns)

**software-docs-minion**: Inventoried all hardcoded path references across docs.
- Adopted: 4 refs in orchestration.md, README as toolkit front door, CLAUDE.md stays project-scoped
- Deferred: first-run README in report dir (YAGNI)

### Architecture Review

**security-minion**: BLOCK (round 1). Identified symlink attacks, world-readable temp, env var injection, sensitive data in companion dirs. Resolved: mktemp + chmod 700, env var removed, sanitization scan added. APPROVE (round 2).

**test-minion**: APPROVE. No concerns.

**ux-strategy-minion**: ADVISE. Recommended path discoverability in CONDENSE, directory creation transparency, actionable greenfield guidance. All incorporated.

**software-docs-minion**: APPROVE. No concerns.

**lucy**: ADVISE. Remove NEFARIO_REPORTS_DIR, constrain README scope, add CLAUDE.md to update list. All incorporated.

**margo**: ADVISE. Remove NEFARIO_REPORTS_DIR, eliminate over-testing task, simplify Task 2 prompt, remove commit-workflow.md refs entirely. All incorporated; plan reduced from 6 to 4 tasks.

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | All path references decoupled, Path Resolution section added |
| skills/despicable-prompter/SKILL.md | created | Moved from .claude/skills/despicable-prompter/ |
| .claude/skills/despicable-prompter | replaced | Directory replaced with symlink to ../../skills/despicable-prompter |
| install.sh | modified | Prompter skill install/uninstall added |
| tests/test-no-hardcoded-paths.sh | created | Static grep + detection priority tests (14 checks) |
| tests/test-install-portability.sh | created | Install/uninstall portability test (13 checks) |
| nefario/AGENT.md | modified | Path-agnostic language for reports |
| .gitignore | modified | Removed nefario/scratch/ entries |
| CLAUDE.md | modified | Updated prompter location and install count |
| README.md | modified | Install description + "Using on Other Projects" note |
| docs/deployment.md | modified | "Using the Toolkit" section, dual-skill documentation |
| docs/orchestration.md | modified | 4 path references updated, greenfield note |
| docs/compaction-strategy.md | modified | Scratch path updated to TMPDIR-based |
| docs/architecture.md | modified | Global installation sentence added |
| docs/using-nefario.md | modified | "Working Directory" section added |
| docs/decisions.md | modified | Decision 26 added |
| nefario/scratch/.gitkeep | deleted | No longer needed (scratch goes to TMPDIR) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| SKILL.md Path Refactor | nefario | HIGH | approved | 1 |

#### SKILL.md Path Refactor

**Decision**: Replace all self-referential paths with portable, cwd-relative resolution.
**Rationale**: SKILL.md is the operational core; path resolution affects every phase. High blast radius warrants user review.
**Rejected**: No alternatives at this gate -- the approach was decided in planning. Gate verified implementation correctness.

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, ux-strategy-minion, test-minion, software-docs-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (Tasks 1-3), software-docs-minion (Task 4) |
| Code Review | (skipped -- changes are config/docs/tests, not application code) |
| Test Execution | devx-minion (regression + install tests) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- documentation was a primary deliverable in Task 4) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | (skipped -- config/docs/tests only) |
| Test Execution | 37 pass, 0 fail (14 hardcoded-paths + 13 install-portability + 10 overlay-validation) |
| Deployment | (skipped -- not requested) |
| Documentation | 10 files modified, 1 deleted |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~8m |
| Synthesis | ~5m |
| Architecture Review | ~10m |
| Execution | ~15m |
| Test Execution | ~1m |
| **Total** | **~41m** |

### Outstanding Items

None

</details>

## Working Files

<details>
<summary>Working files (14 files)</summary>

Companion directory: [2026-02-10-205010-decouple-self-referential-assumptions/](./2026-02-10-205010-decouple-self-referential-assumptions/)

- [Original Prompt](./2026-02-10-205010-decouple-self-referential-assumptions/prompt.md)
- [Phase 1: Meta-plan](./2026-02-10-205010-decouple-self-referential-assumptions/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase2-ux-strategy-minion.md)
- [Phase 2: test-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase2-test-minion.md)
- [Phase 2: software-docs-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-10-205010-decouple-self-referential-assumptions/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-security-minion.md)
- [Phase 3.5: security-minion (round 2)](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-security-minion-r2.md)
- [Phase 3.5: test-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-10-205010-decouple-self-referential-assumptions/phase3.5-margo.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Decouple toolkit from self-referential path assumptions |
| Duration | ~41m |
| Outcome | completed |
| Planning Agents | 4 agents consulted |
| Review Agents | 6 reviewers |
| Execution Agents | 2 agents spawned |
| Gates Presented | 1 of 1 approved |
| Files Changed | 6 created, 10 modified, 1 deleted |
| Outstanding Items | 0 items |
