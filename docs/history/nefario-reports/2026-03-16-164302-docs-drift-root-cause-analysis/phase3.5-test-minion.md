## Verdict: APPROVE

The synthesis plan correctly excludes test-minion from cross-cutting coverage. All three tasks modify markdown spec files (SKILL.md, TEMPLATE.md, AGENT.md) — there is no executable code, no functions, no logic paths that can be exercised by a test runner. This exclusion is accurate.

**On the verification steps provided (lines 418-424):** The plan substitutes manual read-and-trace verification for automated tests, which is the right call for a prompt-only system. The seven verification steps are specific and checkable. Step 2 (trace all four skip paths) is the most important and is correctly included.

**One gap worth flagging:** The verification steps do not include confirming the Phase 8a scratch file write (`$SCRATCH_DIR/{slug}/phase8-checklist.md`) is present in all skip paths after the restructure. The debt-visibility mechanism depends on this file being written even when Phase 8b is skipped. The implementing agent should add this to the post-task read-check: confirm the checklist write instruction appears outside any skip-conditional block in the restructured Phase 8a section.

**On the "handled inline" evidence requirement (Risk 3):** This is a process constraint on an LLM, not on code. It cannot be tested. The mitigation (auditable file path citations in scratch files) is the strongest available. No test coverage gap here — the right check is in execution report review.

No blocking concerns. The scope is proportional, the exclusions are justified, and the verification steps cover the structurally critical paths.
