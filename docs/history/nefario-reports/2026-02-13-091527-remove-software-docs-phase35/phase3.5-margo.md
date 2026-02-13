# Margo Review: Remove software-docs-minion from Phase 3.5

## Verdict: ADVISE

The plan is fundamentally sound -- it is a targeted configuration change across 4 documentation files with a well-scoped diff. No new abstractions, no new dependencies, no new technology. The simplification of Phase 8 from a merge-based checklist (steps 1a/1b/1c) to single-source derivation is a net complexity reduction. Good.

### Non-blocking concerns

1. **Task 2, Change I: The "derivative documentation" row is scope creep.**
   The plan adds a new outcome-action table row ("Spec/config files modified -> scan for derivative docs") to the SKILL.md Phase 8 table. The user's task is to remove software-docs-minion from Phase 3.5 and replace with ux-strategy-minion. Adding a new row to the outcome-action table is adjacent work justified by "closing the gap from removing Phase 3.5 pre-analysis." The existing table and Phase 8 agent judgment already handle this -- software-docs-minion will still run in Phase 8 and can identify derivative doc needs through its own specialist knowledge. This row is YAGNI: it solves a hypothetical gap that has not been demonstrated in practice. Recommendation: omit the derivative-docs row from the SKILL.md update. If Phase 8 doc coverage proves insufficient after the change, add it then with evidence.

2. **4 tasks for what is essentially a find-and-replace operation.** The plan uses 4 separate opus-model agent spawns for text substitutions across 4 files. This is proportional to the file count and the approval gate on `the-plan.md` justifies the sequencing, so it is not blocking. But note the cost: 4 opus invocations for what a single agent could do in one pass after the gate clears. If nefario has a mechanism for single-agent multi-file edits, that would be simpler.

3. **Agent assignment irony.** All 4 tasks are assigned to software-docs-minion, the agent being removed from mandatory review. This is fine operationally (it is a capable text editor), but worth noting in case there is a policy preference for who edits `the-plan.md`.

### What is done well

- The Phase 8 simplification (removing the merge logic with steps 1a/1b/1c) is a genuine complexity reduction. Single-source derivation is simpler and eliminates the divergence-detection mechanism that adds cognitive load without demonstrated value.
- The approval gate on `the-plan.md` is appropriate given CLAUDE.md constraints.
- Verification steps are specific and grep-able.
- The plan correctly avoids modifying agent specs, keeping scope tight.
