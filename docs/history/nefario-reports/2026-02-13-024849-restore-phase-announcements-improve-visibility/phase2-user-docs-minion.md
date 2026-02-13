## Domain Plan Contribution: user-docs-minion

### Recommendations

**1. Yes, `docs/using-nefario.md` needs updates -- but they are modest, not a rewrite.**

The current user guide (`/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md`) already documents the nine phases and what users experience at each one. The relevant section is "What Happens: The Nine Phases" (lines 98-120). It currently says things like "You wait while this happens" and "You do not see this unless a problem surfaces." These descriptions need to be updated to reflect the new reality where phase transitions are visible rather than suppressed.

Specific passages that need revision:

- Line 104: "This runs in the background" for Phase 2 -- if phase announcements are restored, users will see a transition marker, so "in the background" becomes misleading.
- Lines 110-120: Multiple phases say "You do not see this unless a problem surfaces." If phase transition announcements are restored, users will at least see the phase begin, even if the details remain quiet. The wording should shift to something like "Runs automatically. You see a status line when it starts and a summary when it finishes."
- Line 120: "Git commit output is suppressed via --quiet flags -- only errors appear inline." This is unaffected by the phase announcement change and should stay.

**2. A "What to Expect" section with example output would significantly improve comprehension -- but keep it short.**

Users benefit from seeing a concrete example of what a nefario session looks like in practice. Currently, the guide describes each phase abstractly ("nefario reads your codebase and figures out which specialists to consult"). Adding an annotated example of actual orchestration output -- showing the phase announcements, condensed status lines, approval gates, and wrap-up summary -- would let users pattern-match against what they see in their terminal.

This is a strong candidate for progressive disclosure: show a compact 15-20 line example inline, then link to a full annotated walkthrough in a `<details>` block or separate page. Users who just want to know "is this normal?" get their answer from the compact example. Users who want to understand every line can expand the details.

However, the example must be maintained whenever the output format changes. This creates a maintenance coupling between SKILL.md's Communication Protocol and the user guide. Recommendation: keep the example short (one condensed session, not every possible branch) and annotate it with comments rather than prose paragraphs. Shorter examples are cheaper to maintain and faster to scan.

**3. Approval gate labels should be documented from the user's perspective.**

The current guide mentions approval gates at Phase 1 (team approval), Phase 3 (plan approval), and Phase 4 (execution gates) but does not show what the gate prompts actually look like. If the task improves gate formatting -- replacing raw scratch directory paths with meaningful labels -- the user guide should reflect the improved presentation. Users will recognize the gates more easily if the guide shows them what to expect.

This does not need screenshots (the terminal output is text-based), but a short example of each gate type (team gate, plan gate, execution gate) with the new formatting would help. These can go inside the existing phase descriptions rather than requiring a new section.

**4. The scratch directory path presentation change does NOT require user guide updates.**

Scratch directories are implementation details. The user guide currently mentions the scratch path only in passing (the CONDENSE line includes it). If the SKILL.md changes how scratch paths are presented in gates (e.g., showing a human-readable label instead of the raw `/tmp/nefario-scratch-XYZ/slug/` path), the user guide does not need to explain this. Users do not need to understand scratch directories. The only place scratch directories appear in user-facing context is the "Full plan: ..." link at the bottom of gate presentations, and that is self-explanatory.

### Proposed Tasks

**Task 1: Update "What Happens: The Nine Phases" section in `docs/using-nefario.md`**

Update the per-phase descriptions to accurately reflect restored phase announcements. Replace "You do not see this" and "runs in the background" language with descriptions that match the new visibility level. Keep the same structure and length -- this is a wording pass, not a restructure.

Deliverables:
- Updated Phase 2 description (remove "runs in the background" if transition is now visible)
- Updated Phase 5-8 descriptions (replace "You do not see this unless a problem surfaces" with accurate visibility description)
- No structural changes to the section

Dependencies: Depends on the SKILL.md changes being finalized first, so the docs accurately describe the new behavior.

**Task 2: Add compact "What to Expect" example to `docs/using-nefario.md`**

Add a short annotated example after the "What Happens: The Nine Phases" section showing what a typical nefario session looks like in the terminal. Use a fenced code block with inline comments.

Deliverables:
- 15-25 line example showing: meta-plan CONDENSE line, team gate, planning status, synthesis CONDENSE, review CONDENSE, plan approval gate (abbreviated), execution status, verification summary, and wrap-up
- Annotations as inline comments (not separate paragraphs)
- Placed after "What Happens" and before "Working Directory"
- A `<details>` block is optional -- if the example is under 25 lines, inline is fine

Dependencies: Depends on Task 1 (the example must match the updated phase descriptions) and on the SKILL.md formatting changes being final.

**Task 3: Add gate example snippets to phase descriptions (optional, lower priority)**

Within the Phase 1 and Phase 4 descriptions, add 3-5 line snippets showing what the improved gate prompt looks like. This is lower priority than Tasks 1 and 2 because the gates are already described in words. Only pursue if the gate formatting changes are substantial enough that the current text descriptions no longer give users an accurate mental model.

Deliverables:
- 3-5 line gate snippet in Phase 1 description (team gate)
- 3-5 line gate snippet in Phase 4 description (execution gate)
- Updated if gate labels change from raw paths to meaningful text

Dependencies: Depends on SKILL.md gate formatting being finalized.

### Risks and Concerns

**Risk 1: Maintenance coupling between SKILL.md and user guide examples.**
If the "What to Expect" example shows specific output formatting, any future change to the Communication Protocol in SKILL.md requires a corresponding update to `using-nefario.md`. Mitigation: keep examples short and generic (show the structure, not exact wording). Use "[...]" for variable content rather than fabricating realistic-looking output that will drift.

**Risk 2: Over-documenting implementation details.**
The user guide should describe what users experience, not how nefario internally works. Phase announcements and gate formatting are user-facing, so they belong. Scratch directory structure, CONDENSE line internals, and subagent spawning details do not. The current guide already gets this right -- the update should maintain that boundary.

**Risk 3: Example output becoming the de facto specification.**
If the user guide example is too precise, users may report "bugs" when the actual output differs slightly from the example. Mitigation: include a note like "Actual output varies based on your task. This example shows the general shape of an orchestration session." Frame it as illustrative, not normative.

**Risk 4: Timing -- docs must trail the SKILL.md changes.**
If docs are written before SKILL.md changes are finalized and the format shifts during implementation, the docs need rework. Recommendation: execute user-docs task after the SKILL.md changes are merged and verified.

### Additional Agents Needed

None. The documentation changes are straightforward text updates to an existing file within user-docs-minion's scope. No UX design, architecture docs, or marketing review is needed for these changes. If the "What to Expect" example ends up being a standalone page rather than a section, software-docs-minion might need to update `docs/architecture.md`'s sub-document table, but that is unlikely given the recommendation to keep it inline.
