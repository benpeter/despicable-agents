# Lucy Review: AGENT.md Instruction Translator (Issue #140)

## Verdict: APPROVE

---

## Requirements Traceability

| #140 Acceptance Criterion | Plan Coverage |
|---|---|
| Output file contains no YAML frontmatter | Task 1: awk frontmatter stripping + post-translation validation (no `---` in first 3 lines). Task 2: frontmatter stripping tests (group 2), golden-file regression (group 5), corpus smoke (group 8). |
| Output file contains no TaskUpdate, SendMessage, or scratch file references | Task 1: sed pattern file strips `TaskUpdate`, `SendMessage`, `nefario-scratch`, `scratch directory conventions`. Task 2: Claude Code stripping tests (group 4), corpus smoke (group 8). |
| Output is valid Markdown readable by the target tool | Task 1: output is clean Markdown with no injected content. Task 2: happy-path tests verify non-empty output with at least one `#` heading (group 1). |

| Roadmap scope element | Plan Coverage |
|---|---|
| Strip YAML frontmatter entirely | Task 1: awk state machine. |
| Pass frontmatter fields as adapter runtime config | Task 1: JSON on stdout (`name`, `model`, `tools`, `description`). |
| Strip Claude Code-specific task instructions | Task 1: hybrid awk section removal + sed token stripping. |
| Write AGENTS.md format for Codex CLI | Task 1: `--format agents-md`. |
| Write CONVENTIONS.md format for Aider | Task 1: `--format conventions-md` with provenance comment. |
| Translator invoked per delegation; output is temporary file | Task 1: caller provides `--output` path; translator does not manage temp lifecycle. Consistent with adapter-interface.md contract. |

All stated requirements are covered. No unaddressed requirements.

---

## Scope Assessment

No scope creep detected. The three tasks map cleanly to the issue:

- **Task 1** (devx-minion): implementation -- the core deliverable.
- **Task 2** (test-minion): tests -- required by cross-cutting checklist and proportional to the implementation.
- **Task 3** (software-docs-minion): two small doc updates (Translator Rules section in adapter-interface.md, spec link in roadmap) -- consistent with patterns established by #138 and #139.

The plan does not introduce new technologies, new abstractions, new dependencies, or features beyond #140 scope. Zero external dependencies (POSIX only) aligns with CLAUDE.md "Lean and Mean" and "no frameworks by default."

---

## CLAUDE.md Compliance

| Directive | Status |
|---|---|
| All artifacts in English | OK -- all prompts and deliverables are English. |
| No PII, no proprietary data | OK -- no agent-specific hardcoding, no credentials. |
| Do NOT modify `the-plan.md` | OK -- not touched. |
| YAGNI | OK -- no cross-model rewriting, no preamble injection, no speculative features. Deferral decisions are explicit and traced to validation issues (#146, #147). |
| KISS | OK -- POSIX tools only (bash, awk, sed). Hybrid awk+sed is the simplest approach for the two distinct stripping categories. |
| Prefer lightweight, vanilla solutions | OK -- no yq, no jq, no framework. |
| Never delete remote branches | N/A -- no branch operations in plan. |
| Session output discipline | OK -- subagent prompts; orchestration conventions apply to nefario, not to delegated tasks. |
| External harness PRs target `external-harness` branch | Not addressed in plan -- nefario handles branch targeting at execution time. No violation. |

No CLAUDE.md violations found.

---

## Convention Consistency

- **File placement**: `lib/translate-agent-md.sh` and `lib/claude-code-patterns.sed` follow the existing `lib/` pattern (`lib/load-routing-config.sh`). `tests/test-translator.sh` follows `tests/test-routing-config.sh`. `tests/fixtures/translator/` follows fixture directory patterns.
- **CLI conventions**: Exit codes (0/1/2), error message format (what/where/how), `set -euo pipefail` -- all specified to match `load-routing-config.sh`.
- **Test conventions**: Bare bash tests with `pass()`/`fail()` helpers, no test framework -- matches `test-routing-config.sh`.
- **Documentation pattern**: Translator Rules section placed inside `adapter-interface.md` (not a new file) with a spec link from the roadmap entry -- matches #138 and #139 patterns exactly.

---

## Findings

No DRIFT, CONVENTION, COMPLIANCE, SCOPE, or TRACE findings.

One observation (not a finding): The `AskUserQuestion` token appears in the sed stripping list (Task 1 prompt, line 87) but is not mentioned in the #140 acceptance criteria or roadmap scope. This is not scope creep -- it is a reasonable stripping target discovered during specialist analysis (it is a Claude Code tool primitive like `TaskUpdate`). Flagging for awareness only.
