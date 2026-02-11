VERDICT: ADVISE

## Summary

The changes are proportional to the problem: reducing noisy git output during orchestrated sessions. The core change (adding `--quiet` flags to git commands in SKILL.md) is a one-word-per-site fix applied to the right places. Documentation updates accurately describe the new behavior. The new tests verify real behavior rather than speculative edge cases.

Two items warrant attention but are non-blocking.

## Findings

- [ADVISE] `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md`:47-61 -- The "Session Output Discipline" subsection adds 14 lines to CLAUDE.md that partially duplicate what SKILL.md already specifies. CLAUDE.md is loaded into every session (not just orchestrated ones), adding cognitive overhead for all agents. The scope qualifier ("These conventions apply only during orchestrated sessions") mitigates runtime impact, but it means every agent reads instructions that do not apply to it. Consider whether this belongs in CLAUDE.md at all, or whether a one-line cross-reference ("For orchestrated session output conventions, see SKILL.md Communication Protocol") would suffice. The `--quiet` behavior is already encoded in SKILL.md git command examples; CLAUDE.md risks becoming a second source of truth that can drift.

- [ADVISE] `/Users/ben/github/benpeter/despicable-agents/tests/test-commit-hooks.sh`:595-715 -- The four "Noise Reduction Tests" test git's own `--quiet` flag behavior, not the project's hook code. `test_quiet_commit_suppresses_output` (line 595) verifies that `git commit --quiet` produces empty stdout -- this is testing git itself, not the commit-point-check hook. Same for `test_quiet_push_suppresses_output` (line 678). Tests that verify vendor tool behavior are brittle (a git version change could alter output format) and add maintenance burden without catching regressions in project code. The `test_quiet_commit_shows_hook_errors` test (line 626) is closer to useful -- it validates that `--quiet` does not swallow pre-commit hook errors -- but it is still testing git semantics rather than project hooks. Consider either (a) removing these four tests entirely (the SKILL.md instructions are the actual control, not the hooks) or (b) testing the project's commit-point-check.sh with `--quiet` flags applied, which would test the actual integration.

- [NIT] `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md`:52-55 -- The "Bash commands" truncation guidance (`| tail -2`, `set -o pipefail`, show last 10 on error) is reasonable but untested. No hook or CI enforces this convention -- it is purely advisory. This is fine for a first iteration, but note it may be ignored by subagents that do not read CLAUDE.md carefully. Not blocking.

- [NIT] `/Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md`:120 -- "Git commit output is suppressed via `--quiet` flags -- only errors appear inline." This is accurate and helpful for users. No issue.
