# software-docs-minion Review

## Verdict: ADVISE

### Non-blocking warnings

1. **Scratch directory convention not updated for new file**.
   The SKILL.md Scratch Directory Structure section (lines ~227-252) lists all
   expected files in `$SCRATCH_DIR/{slug}/`. The new file
   `phase3.5-docs-checklist.md` is not listed there. None of Tasks 1-3 update
   this section. Task 2 adds the prompt that produces the file, but the
   directory structure reference (which serves as a developer-facing manifest)
   will be stale. Recommend: Task 2 prompt should include adding
   `phase3.5-docs-checklist.md` to the scratch directory structure listing
   between `phase3.5-{reviewer-name}.md` and `phase4-{agent-name}-prompt.md`,
   with the annotation `# produced by software-docs-minion (Phase 3.5)`.

2. **orchestration.md Phase 8 section (Task 4B) omits checklist merge details**.
   Task 4 instructs software-docs-minion to update the Phase 8 paragraph to
   mention the checklist handoff, but it provides a single-paragraph replacement.
   The SKILL.md Phase 8 (Task 3) defines a detailed 3-step merge process
   (read checklist, supplement with outcomes, flag divergence). The orchestration.md
   update (which is architecture documentation, not operational spec) does not need
   to replicate the merge steps, but it should at minimum mention divergence flagging
   and the fallback behavior when Phase 3.5 was skipped. The provided replacement
   paragraph does mention the fallback ("if Phase 3.5 was skipped, the checklist is
   generated entirely from execution outcomes") which is good. The divergence flagging
   is absent but acceptable for an architecture overview document.

3. **Cross-cutting clarification sentence (Task 1C) is correct in scope but could
   be clearer about software-docs-minion specifically**.
   The sentence says "an agent can be ALWAYS in the checklist but discretionary in
   Phase 3.5 review." This correctly describes the general principle (ux-strategy-minion
   moves from ALWAYS to discretionary in Phase 3.5 while remaining ALWAYS in the
   cross-cutting checklist). However, the inverse case also exists:
   software-docs-minion is ALWAYS in both the checklist and Phase 3.5, but its
   Phase 3.5 role is narrowed (documentation impact checklist, not full review).
   The sentence handles the inclusion/exclusion split but not the role-narrowing case.
   This is minor -- the verdict exception note (Task 1D) covers
   software-docs-minion's narrowed role directly.

4. **Documentation impact checklist format is well-defined for Phase 8 consumption**.
   The format (Task 2C) includes owner tags ([software-docs] / [user-docs]),
   scope, file paths, and priority -- all of which Phase 8 merge logic (Task 3)
   explicitly references. The 10-item cap with overflow guidance is pragmatic.
   The "Not Applicable" section provides useful negative signal. No gaps here.

5. **Three-file consistency is strong**. AGENT.md (Task 1) defines the roster and
   triggering rules. SKILL.md (Tasks 2-3) operationalizes them with concrete
   prompts and merge logic. orchestration.md (Task 4) documents the architecture.
   The roster lists are identical across all three targets (5 mandatory, 6
   discretionary). The plan's verification steps (lines 714-721) explicitly check
   roster consistency. No documentation gaps between the three files.

### Summary

One actionable warning (scratch directory structure listing, item 1). The remaining
items are observations confirming coverage is adequate. The plan's internal
consistency across AGENT.md, SKILL.md, and orchestration.md is well-maintained
through explicit verification steps.
