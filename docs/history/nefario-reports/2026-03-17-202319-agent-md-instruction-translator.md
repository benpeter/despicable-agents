---
type: nefario-report
version: 3
date: "2026-03-17"
time: "20:23:19"
task: "Translate AGENT.md to tool-native instruction files (AGENTS.md/CONVENTIONS.md)"
source-issue: 140
mode: full
agents-involved: [devx-minion, security-minion, ai-modeling-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 3
gate-count: 0
outcome: completed
docs-debt: none
---

# AGENT.md Instruction Translator (#140)

## Summary

Implemented `lib/translate-agent-md.sh` -- a shell-based translator that converts AGENT.md files to AGENTS.md (Codex CLI) and CONVENTIONS.md (Aider) formats. Strips YAML frontmatter, Claude Code-specific tool primitives, build markers, and orchestration sections. Emits extracted frontmatter as JSON to stdout. Zero external dependencies beyond POSIX tools. 35 integration tests pass including a 27-agent corpus smoke test. Translator Rules documented in adapter-interface.md.

## Original Prompt

> Translate an AGENT.md file to a tool-native instruction file (AGENTS.md or CONVENTIONS.md), stripping frontmatter and Claude Code-specific content. Strip YAML frontmatter entirely; pass frontmatter fields as adapter runtime config. Strip Claude Code-specific task instructions (TaskUpdate, SendMessage, scratch directory conventions) from the Markdown body. Write tool-native file: AGENTS.md format for Codex CLI; CONVENTIONS.md format for Aider. Translator is invoked per delegation call; output is a temporary file cleaned up after the harness exits.

## Key Design Decisions

#### Frontmatter Extraction via awk (not yq)

**Rationale**:
- AGENT.md frontmatter is flat key-value YAML; yq adds a dependency for zero benefit
- Zero external dependencies: only bash, awk, sed, cat, printf
- Consistent with existing codebase patterns

**Alternatives Rejected**:
- yq: Adds dependency management for simple frontmatter parsing

#### Hybrid Stripping (awk section removal + sed token patterns)

**Rationale**:
- Section removal (awk) for blocks that are entirely Claude Code content (Main Agent Mode)
- Token removal (sed) for inline references embedded in valuable paragraphs
- Separate `claude-code-patterns.sed` file makes stripping rules explicit and maintainable

**Alternatives Rejected**:
- Pure token deletion: Would leave orphaned prose when removing section-spanning content
- Pure section removal: Too aggressive for inline tool references in otherwise valuable text

#### Markdown Body Passthrough (no structural transformation)

**Rationale**:
- Both AGENTS.md and CONVENTIONS.md accept plain Markdown
- AGENT.md five-section structure maps directly to both formats
- No per-model rewriting needed; instructions use model-agnostic Markdown

**Alternatives Rejected**:
- Format-specific restructuring: No evidence either format requires it
- Cross-model prompt rewriting: ai-modeling-minion confirmed unnecessary

### Decisions

- **Output format differentiation**
  Chosen: Identical body content; conventions-md adds a provenance HTML comment
  Over: Format-specific structural differences (ai-modeling-minion confirmed unnecessary)
  Why: Both formats consume plain Markdown; minimal differentiation reduces complexity

- **Stripping scope**
  Chosen: Defensive (all Claude Code primitives: TaskUpdate, TaskList, TaskCreate, SendMessage, TeamCreate, TeamUpdate, AskUserQuestion)
  Over: Conservative (only patterns currently found in agents)
  Why: AGENT.md files evolve through spec rebuilds; new patterns can appear at any time

## Phases

### Phase 1: Meta-Plan

Identified 6 specialists: devx-minion (CLI design), security-minion (translation pipeline security), ai-modeling-minion (instruction fidelity across models), test-minion (test strategy), ux-strategy-minion (internal developer experience), software-docs-minion (documentation coverage).

### Phase 2: Specialist Planning

All 6 contributed in parallel. Key consensus: awk for frontmatter (not yq), caller-provided output path, defensive stripping with hybrid approach, both formats are Markdown passthrough, no separate spec doc needed (add to adapter-interface.md). False-positive risks identified for "scratch" and "Task" bare words.

### Phase 3: Synthesis

Produced a 3-task plan with 0 approval gates (low blast radius). No conflicts to resolve -- specialists converged on the hybrid stripping approach. Security concerns (umask 077, fail-closed validation, no content injection) embedded directly in implementation requirements.

### Phase 3.5: Architecture Review

5 mandatory reviewers. Results: 4 APPROVE (security, test, ux-strategy, lucy), 1 ADVISE (margo: size sanity check is borderline YAGNI). test-minion advised pinning no-frontmatter behavior and adding idempotency test.

### Phase 4: Execution

Task 1 (devx-minion): Implemented `lib/translate-agent-md.sh` (~580 lines) and `lib/claude-code-patterns.sed` (~130 lines). Three-stage pipeline: awk frontmatter extraction, awk body extraction with section removal, sed pattern stripping. Fixed UTF-8 null-byte detection bug during testing (LC_ALL=C tr rejected multi-byte characters).

Task 2 (test-minion, parallel): Created `tests/test-translator.sh` with 35 tests. Synthetic fixtures, golden-file regression, 27-agent corpus smoke test, idempotency check. All pass.

Task 3 (software-docs-minion, parallel): Added Translator Rules section to `docs/adapter-interface.md` and spec link in roadmap.

### Phase 5: Code Review

3 reviewers (code-review-minion, lucy, margo), all ADVISE. Key findings fixed: GNU grep -P replaced with portable tr/cmp for macOS compatibility, argument value guards added for --agent-md/--format/--output flags. Known limitation documented: token stripping can leave grammatically broken prose in synthetic fixtures (real agents use tokens in structural positions that strip cleanly).

### Phase 6: Test Execution

35 tests passed, 0 failures. Full corpus of 27 agents translates cleanly.

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a: No documentation debt. Translator Rules section already added to adapter-interface.md.

## Agent Contributions

<details>
<summary>Agent Contributions (6 planning, 5 review, 3 code review)</summary>

### Planning

**devx-minion**: Flag-based CLI matching load-routing-config.sh patterns, awk for frontmatter, hybrid stripping, frontmatter JSON on stdout.
- Adopted: All recommendations
- Risks: Content stripping leaving awkward residue

**security-minion**: Caller-provided output path, structural frontmatter parsing, section-level stripping, strip @domain markers, output validation.
- Adopted: All recommendations
- Risks: Crafted AGENT.md instruction injection (mitigated by format-only translation)

**ai-modeling-minion**: Markdown body passthrough for both formats, defensive stripping, no cross-model rewriting needed.
- Adopted: All recommendations
- Risks: Large agent files consuming context on smaller models

**test-minion**: Follow test-routing-config.sh pattern, synthetic + corpus tests, golden files, narrow grep patterns.
- Adopted: All recommendations
- Risks: False positives in bare-word stripping patterns

**ux-strategy-minion**: Keep purely functional, fail loudly with context, explicit stripping rules.
- Adopted: Folded into implementation requirements
- Risks: None

**software-docs-minion**: No separate spec doc, add Translator Rules to adapter-interface.md.
- Adopted: All recommendations
- Risks: None

### Architecture Review

**security-minion**: APPROVE. Sound security design.
**test-minion**: APPROVE. Pin no-frontmatter behavior, add idempotency test.
**ux-strategy-minion**: APPROVE. Clean developer experience.
**lucy**: APPROVE. Tight scope alignment.
**margo**: ADVISE. Size sanity check is borderline YAGNI.

### Code Review

**code-review-minion**: ADVISE. grep -P portability, arg value guards, awk variable init.
**lucy**: ADVISE. Golden file broken prose, grep -P portability.
**margo**: ADVISE. grep -P portability, broken prose as known limitation.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Implement Translator | devx-minion | completed |
| 2 | Write Tests | test-minion | completed |
| 3 | Update Documentation | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| lib/translate-agent-md.sh | created | AGENT.md translator script |
| lib/claude-code-patterns.sed | created | Curated sed patterns for Claude Code stripping |
| tests/test-translator.sh | created | 35 integration tests |
| tests/fixtures/translator/* | created | 8 fixture and golden files |
| docs/adapter-interface.md | modified | Added Translator Rules section |
| docs/external-harness-roadmap.md | modified | Added spec link under #140 |

### Approval Gates

| Gate | Type | Outcome | Notes |
|------|------|---------|-------|
| Team Selection | Team | approved | 6 specialists, Lucy proxy |
| Reviewer Selection | Reviewer | auto-approved | 5 mandatory, 0 discretionary |
| Execution Plan | Plan | approved | 3 tasks, 0 gates, Lucy proxy |

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK. 2 findings fixed (portability, arg guards). |
| Test Execution | 35 passed, 0 failed |
| Deployment | Skipped (not requested) |
| Documentation | Translator Rules section added to adapter-interface.md |

## Session Resources

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 0 events

</details>

## Working Files

<details>
<summary>Working files (14 files)</summary>

Companion directory: [2026-03-17-202319-agent-md-instruction-translator/](./2026-03-17-202319-agent-md-instruction-translator/)

| File | Description |
|------|-------------|
| prompt.md | Original task description |
| phase1-metaplan.md | Meta-plan output |
| phase2-devx-minion.md | devx-minion planning contribution |
| phase2-security-minion.md | security-minion planning contribution |
| phase2-ai-modeling-minion.md | ai-modeling-minion planning contribution |
| phase2-test-minion.md | test-minion planning contribution |
| phase2-ux-strategy-minion.md | ux-strategy-minion planning contribution |
| phase2-software-docs-minion.md | software-docs-minion planning contribution |
| phase3-synthesis.md | Final delegation plan |
| phase3.5-security-minion.md | Security review verdict |
| phase3.5-test-minion.md | Test review verdict |
| phase3.5-ux-strategy-minion.md | UX strategy review verdict |
| phase3.5-lucy.md | Lucy review verdict |
| phase3.5-margo.md | Margo review verdict |

</details>
