---
type: nefario-report
version: 3
date: "2026-02-13"
time: "22:01:32"
task: "Separate domain-specific orchestration semantics from domain-independent infrastructure"
source-issue: 56
mode: full
agents-involved: [ai-modeling-minion, lucy, margo, devx-minion, security-minion, test-minion, ux-strategy-minion, user-docs-minion, code-review-minion, software-docs-minion]
task-count: 5
gate-count: 1
outcome: completed
---

# Separate domain-specific orchestration semantics from domain-independent infrastructure

## Summary

Introduced a domain adapter system that separates domain-specific content (agent roster, delegation table, cross-cutting concerns, gate heuristics, reviewer configuration, post-execution pipeline) from domain-independent infrastructure in nefario's AGENT.md. The software-dev adapter is the reference implementation. A bash/awk assembly script composes the adapter into the AGENT.md template at install time, enabling forkers to replace domain content without touching orchestration infrastructure.

## Original Prompt

<details>
<summary>GitHub Issue #56</summary>

**Outcome**: A user forking despicable-agents for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) can identify and replace only the domain-specific parts — agent roster, phase definitions, gate/approval semantics, coordination patterns — without needing to understand or modify the domain-independent infrastructure (skill discovery, tool plumbing, team mechanics, report generation). This makes the system a reusable orchestration framework rather than a software-development-specific tool.

**Success criteria**:
- Clear boundary exists between domain-specific configuration (agents, phases, gates, coordination semantics) and domain-independent infrastructure (skill mechanics, subagent spawning, message delivery, report format)
- A hypothetical domain adapter can define its own phase sequence, gate criteria, and agent roster without editing infrastructure files
- Documentation explains what a domain adapter must provide vs. what the framework handles
- Existing software-development behavior is preserved — current agents and orchestration work identically after the separation

**Scope**:
- In: nefario SKILL.md orchestration logic, phase/gate definitions, agent roster selection, approval semantics, documentation of the separation boundary
- Out: Actually building non-software-domain agent sets (IVDR, linguistics, etc.), changing the agent file format (AGENT.md structure), modifying Claude Code platform integration

**Constraints**:
- Do not narrow or dismiss this work as YAGNI. The separation is a deliberate architectural investment in reusability, not speculative feature-building. The goal is making existing structure explicit and swappable, not adding new capabilities.

</details>

## Key Design Decisions

#### Single-file domain adapter (DOMAIN.md) with H2-section extraction

**Rationale**:
- A single markdown file with YAML frontmatter + H2-delimited body sections is the simplest format that satisfies the extraction requirements
- H2 headings map naturally to assembly markers via kebab-case normalization
- No new tooling dependencies (bash + awk only)

**Alternatives Rejected**:
- Directory-per-section with individual files: Over-engineering for 9 sections. Adds file management overhead without proportional benefit.
- JSON/TOML structured format: Forces domain authors to learn a new format. Markdown is already the project's lingua franca.
- Runtime template engine: Adds latency and complexity. Install-time assembly is sufficient since adapters change rarely.

#### Assembly markers in AGENT.md, section markers in SKILL.md

**Rationale**:
- AGENT.md uses `<!-- @domain:section-id BEGIN/END -->` markers for automated extraction/injection via assemble.sh
- SKILL.md uses `<!-- INFRASTRUCTURE -->` / `<!-- DOMAIN-SPECIFIC -->` HTML comment annotations for human-guided in-place editing
- This asymmetry reflects the different change patterns: AGENT.md sections are cleanly separable; SKILL.md has deeply interleaved domain/infrastructure content

**Alternatives Rejected**:
- Full assembly for both files: SKILL.md's interleaving makes clean marker-based extraction impractical without significant restructuring
- Section markers only (no assembly): Would require manual copy-paste for AGENT.md forking, defeating the automation goal

#### Dropped disassemble.sh (YAGNI)

**Rationale**:
- Three reviewers (margo, ux-strategy-minion, test-minion) independently recommended against building a reverse extraction tool
- The workflow is one-directional: edit DOMAIN.md, run assemble.sh
- A disassembler adds maintenance burden for a workflow nobody uses

**Alternatives Rejected**:
- Build disassemble.sh for round-trip editing: No use case. Adapter authors edit DOMAIN.md directly.

### Conflict Resolutions

**Minimalism vs. structured extraction** (margo vs. ai-modeling/devx): Margo recommended section markers only (no extraction tooling). ai-modeling and devx recommended structured schemas, validation, and directory-based adapters. Resolved with a middle path: single-file extraction for AGENT.md (enough automation to prevent copy-paste errors), markers-only for SKILL.md (no premature tooling for interleaved content), no runtime indirection or plugin infrastructure.

## Phases

### Phase 1: Meta-Plan

Pre-selected team of 4 specialists: ai-modeling-minion (configurable surfaces, adapter schema), lucy (governance invariants, separation boundaries), margo (complexity budget, YAGNI enforcement), devx-minion (developer experience for adapter authors). Team approval gate was skipped per user directive.

### Phase 2: Specialist Planning

All 4 specialists consulted in parallel. ai-modeling-minion identified 8 configurable surfaces and proposed a typed phase system. lucy established that governance agents (lucy, margo) must remain universal while all 6 cross-cutting dimensions are software-dev-specific. margo set the complexity ceiling: section markers only, 5 data structures as minimum contract, no plugin infrastructure. devx-minion recommended markdown+YAML in a directory structure and extending despicable-lab for validation. The key conflict between margo's minimalism and ai-modeling/devx's structured extraction was flagged for synthesis resolution.

### Phase 3: Synthesis

Resolved the minimalism vs. structure conflict with a middle path: single DOMAIN.md file with H2-section extraction for AGENT.md, HTML comment markers for SKILL.md, no runtime indirection. Produced 5 tasks with 1 approval gate: audit (gated) -> adapter format + extraction (parallel) -> assembly script + docs -> verification.

### Phase 3.5: Architecture Review

6 reviewers (5 mandatory + user-docs-minion discretionary). All returned ADVISE, 0 BLOCK. Key advisories: drop disassemble.sh (3 reviewers), strengthen verification with runtime checks, add content sanitization to assembly script, improve documentation with troubleshooting section, update CLAUDE.md deployment section. All advisories folded into task prompts.

### Phase 4: Execution

5 tasks executed across 4 batches. Task 1 (audit) classified 41 sections, identifying ~1040 domain-specific lines. Task 2 (adapter + extraction) created DOMAIN.md (619 lines), added 12 assembly markers to AGENT.md, annotated SKILL.md with 33 section markers. Task 3 (assembly script) created assemble.sh (180 lines) and updated install.sh. Task 4 (documentation) created docs/domain-adaptation.md (273 lines) and updated README.md and CLAUDE.md. Task 5 (verification) found 3 failures: F1 (critical awk code fence bug), F2 (extra content in architecture review), F3 (missing discretionary reviewer paragraph and post-execution overview). All three failures were fixed and verified.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all returned ADVISE. Two cross-reviewer BLOCK findings on the same issue (assemble.sh CLI syntax documented incorrectly as `--domain` flag instead of positional argument in CLAUDE.md and docs/domain-adaptation.md). Fixed immediately. Additional advisories noted: dead YAML frontmatter fields, orphaned DOMAIN.md sections without markers, hardcoded alias table, dead exit code logic. These are documented as known limitations for future iteration.

### Phase 6: Test Execution

Skipped (no test infrastructure in repository).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Documentation was produced during Phase 4 execution (Task 4). docs/domain-adaptation.md (273 lines), README.md update, CLAUDE.md deployment section update. No additional Phase 8 work needed.

<details>
<summary>Agent Contributions (4 planning, 6 review, 3 code review)</summary>

### Planning

**ai-modeling-minion**: Identified 8 configurable surfaces in nefario AGENT.md. Proposed typed phase system with conditional execution and adapter-declared phase sequences.
- Adopted: configurable surface inventory, phase sequence in YAML frontmatter
- Risks flagged: adapter schema versioning, migration path for existing deployments

**lucy**: Established governance universality principle. lucy and margo remain framework-level. All 6 cross-cutting dimensions are domain-specific. The pattern (evaluate dimensions) is universal; the specific dimensions are adapter-supplied.
- Adopted: governance invariant rules, cross-cutting dimension extraction
- Risks flagged: intent drift if governance agents become domain-customizable

**margo**: Set complexity ceiling. Section markers only for SKILL.md. 5 data structures as minimum viable contract. No plugin infrastructure, no runtime indirection, no disassemble.sh.
- Adopted: minimal extraction approach, YAGNI on disassembler
- Risks flagged: over-engineering risk if structured extraction expands beyond current scope

**devx-minion**: Recommended markdown+YAML format in directory structure. Proposed extending despicable-lab for assembly validation and adapter linting.
- Adopted: DOMAIN.md format design, developer workflow documentation
- Risks flagged: discoverability of adapter format without validation tooling

### Architecture Review

**security-minion**: ADVISE. SCOPE: assemble.sh content injection. CHANGE: Add injection guard rejecting DOMAIN.md files containing assembly markers. WHY: Prevents marker-in-marker injection that could corrupt the template.

**test-minion**: ADVISE. SCOPE: verification task. CHANGE: Add assembly idempotence check and behavioral equivalence diffing. WHY: Ensures assembled output matches original semantics.

**ux-strategy-minion**: ADVISE. SCOPE: disassemble.sh. CHANGE: Drop reverse extraction tool. WHY: One-directional workflow (edit DOMAIN.md -> assemble) is simpler; no user need for reverse path.

**lucy**: ADVISE. SCOPE: governance boundaries. CHANGE: Ensure adapter cannot remove mandatory reviewers. WHY: Governance invariant must survive domain adaptation.

**margo**: ADVISE. SCOPE: assembly tooling. CHANGE: Drop disassemble.sh, keep assemble.sh minimal. WHY: YAGNI -- no demonstrated need for reverse extraction.

**user-docs-minion**: ADVISE. SCOPE: domain-adaptation.md. CHANGE: Add troubleshooting section with symptom/cause/solution format. WHY: Adapter authors need debugging guidance for common assembly failures.

### Code Review

**code-review-minion**: ADVISE. 2 BLOCK findings (CLI syntax mismatch, fixed), 2 ADVISE (dead exit code, orphaned sections), 3 NIT.

**lucy**: ADVISE. 4 ADVISE (CLI mismatch, dead frontmatter references, orchestration vocabulary leak, dead frontmatter field), 1 NIT. Governance invariants verified: PASS.

**margo**: ADVISE. 4 ADVISE (CLI mismatch, redundant deploy instructions, dead YAML, alias coupling), 1 ADVISE (unmatched markers), 3 NIT. Core design proportional to problem.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Audit and classify AGENT.md sections | ai-modeling-minion | completed |
| 2 | Create adapter format and extract domain content | ai-modeling-minion | completed |
| 3 | Build assembly script and update install.sh | devx-minion | completed |
| 4 | Write domain adaptation documentation | software-docs-minion | completed |
| 5 | Verify behavioral equivalence | ai-modeling-minion | completed (FAIL -> fixed) |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [assemble.sh](../../../assemble.sh) | created | Bash/awk script for composing DOMAIN.md into AGENT.md template (+180) |
| [domains/software-dev/DOMAIN.md](../../../domains/software-dev/DOMAIN.md) | created | Software-dev domain adapter with agent roster, phases, reviewers (+619) |
| [nefario/AGENT.md](../../../nefario/AGENT.md) | modified | 12 assembly markers inserted at domain/infrastructure seams (+181) |
| [install.sh](../../../install.sh) | modified | Added --domain flag and assembly step (+27/-18) |
| [docs/domain-adaptation.md](../../../docs/domain-adaptation.md) | created | Adapter authoring guide with walkthrough and troubleshooting (+273) |
| [README.md](../../../README.md) | modified | Added link to domain-adaptation.md (+1) |
| [CLAUDE.md](../../../CLAUDE.md) | modified | Updated deployment section with --domain flag (+7) |
| [skills/nefario/SKILL.md](../../../skills/nefario/SKILL.md) | modified | 33 section markers added as HTML comment annotations (+38) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Section audit classification | ai-modeling-minion | HIGH | approved | 1 |

## Decisions

#### Section Audit Classification

**Decision**: Accepted the 41-section classification with 9 sections extracted into DOMAIN.md and 3 markers preserving inline content.
**Rationale**: The audit correctly identified domain-specific vs. infrastructure boundaries. The 3 unmatched markers (meta-plan-checklist, synthesis-cross-cutting, synthesis-review-agents) contain template patterns filled at runtime, justifying their preservation as inline content.
**Rejected**: Full extraction of all domain-referencing content (would break template patterns that reference domain agents dynamically).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE verdicts. 2 BLOCK findings (CLI syntax) auto-fixed. Remaining advisories documented as known limitations. |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Produced during execution (Task 4). 273-line adapter guide, README and CLAUDE.md updates. |

<details>
<summary>Session Resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 0 events

</details>

<details>
<summary>Working Files (33 files)</summary>

Companion directory: [2026-02-13-220132-separate-domain-orchestration-from-infra/](./2026-02-13-220132-separate-domain-orchestration-from-infra/)

- [Original Prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase1-metaplan.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-ai-modeling-minion.md)
- [Phase 2: devx-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-devx-minion.md)
- [Phase 2: lucy](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-lucy.md)
- [Phase 2: margo](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-margo.md)
- [Phase 3: Synthesis](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3-synthesis.md)
- [Phase 3.5: lucy](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-margo.md)
- [Phase 3.5: security-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-test-minion.md)
- [Phase 3.5: user-docs-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-user-docs-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-ux-strategy-minion.md)
- [Audit Classification](./2026-02-13-220132-separate-domain-orchestration-from-infra/audit-classification.md)
- [Adapter Format](./2026-02-13-220132-separate-domain-orchestration-from-infra/adapter-format.md)
- [Verification Report](./2026-02-13-220132-separate-domain-orchestration-from-infra/verification-report.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase1-metaplan-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-devx-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-lucy-prompt.md)
- [Phase 2: margo prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase2-margo-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3-synthesis-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-margo-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-test-minion-prompt.md)
- [Phase 3.5: user-docs-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-user-docs-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 4: ai-modeling-task1 prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase4-ai-modeling-task1-prompt.md)
- [Phase 4: ai-modeling-task2 prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase4-ai-modeling-task2-prompt.md)
- [Phase 4: devx-task3 prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase4-devx-task3-prompt.md)
- [Phase 4: softwaredocs-task4 prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase4-softwaredocs-task4-prompt.md)
- [Phase 4: ai-modeling-task5 prompt](./2026-02-13-220132-separate-domain-orchestration-from-infra/phase4-ai-modeling-task5-prompt.md)

</details>
