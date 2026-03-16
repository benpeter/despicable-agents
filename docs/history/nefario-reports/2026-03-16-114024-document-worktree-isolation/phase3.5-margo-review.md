VERDICT: APPROVE

FINDINGS:

- [NIT] orchestration.md:651 -- Disambiguation note for EnterWorktree/ExitWorktree adds cognitive load for a distinction most readers will not need.
  FIX: Remove the Note block (lines 651). Users who encounter subagent worktree isolation will find it in its own docs. Preemptively disambiguating two unrelated mechanisms in a section about one of them is YAGNI for documentation.

- [NIT] orchestration.md:616 -- Opening paragraph has a slight "selling" tone ("No framework-level coordination is needed -- the infrastructure layer handles isolation transparently"). The fact that no custom framework is needed is the entire point of documenting this feature; stating it does not add information.
  FIX: Simplify to: "Multiple nefario orchestrations can run simultaneously in separate git worktrees. Each session operates independently with its own branch, scratch files, and reports."

REASONING:

Proportionality check -- Section 6 is approximately 55 lines documenting a feature that is genuinely just "use git worktrees, each session is independent." The content is proportional: when-to-use guidance, a CLI example, merge-back steps, and honest limitations. No new abstractions, no new dependencies, no new configuration. The documentation describes existing git and Claude Code capabilities rather than inventing custom machinery.

Scope check -- Four files changed, all documentation, all directly related to worktree isolation. The architecture.md table cell update and commit-workflow.md forward-reference are minimal cross-references (one clause each). The using-nefario.md tip is a single paragraph in the existing tips section. No scope creep detected.

YAGNI check -- The section does not introduce speculative features (no "future: shared planning across worktrees" or "planned: automatic conflict detection"). The Limitations subsection is honest about what this does NOT do, which is the correct approach. The anti-pattern callout (shared files) is practical guidance, not over-engineering.

Complexity budget -- Zero. No new services, technologies, abstractions, or dependencies. Pure documentation of existing capabilities.
