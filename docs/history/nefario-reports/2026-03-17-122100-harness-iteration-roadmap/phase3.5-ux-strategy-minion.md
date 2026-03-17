---
reviewer: ux-strategy-minion
verdict: APPROVE
---

# UX Strategy Review: Journey Coherence

## Verdict: APPROVE

Both deliverables serve their readers' jobs well. The plan is coherent. One advisory note on the roadmap's "How to Use" section.

---

## Deliverable 1: Report Iteration

**Reader job**: A developer reads this report to understand whether external harness integration is feasible and how it would work. They are evaluating whether to invest engineering effort.

**Journey assessment**: The five changes address a genuine gap in the current document. The existing report explains *what* each tool does and *whether* it is feasible — but leaves the reader without a mental model of *how they would actually use it*. The routing and configuration section (Change 1) directly fills that gap.

The YAML example approach is the right call. A 2-3 line minimal config followed by a power-user config gives developers a concrete mental model without demanding they read a schema. This is recognition over recall — users can see what a config looks like before they decide whether to engage with the full schema in the roadmap.

The resolution of open questions 2, 3, and 5 reduces the document's cognitive load appropriately. Open questions are interruptions — they force the reader to hold uncertainty while continuing to read. Replacing them with definitive positions keeps the reader moving forward. The two remaining open questions (instruction isolation, AGENTS.md stability) are genuinely unresolved, so keeping them is honest.

The 340-line cap is correctly applied. The routing section contributing ~40-60 lines against a net reduction of three open questions means the document does not grow significantly — a good signal.

**One note on the routing section framing**: The prompt correctly instructs that the config location is "a recommendation, not a commitment." Ensure the written prose reflects this — a developer reading a feasibility study should understand that `.nefario/routing.yml` is a proposed convention, not a finalized path. Phrasing like "proposed location" or "following the dotfile convention used by `.github/` and `.vscode/`" preserves the tentative status without undermining the example's utility.

---

## Deliverable 2: Implementation Roadmap

**Reader job**: A developer uses this document to create GitHub issues. They need to copy-paste each issue body, verify the scope and dependencies make sense, and submit. The document is an input to a tool, not something they read end-to-end.

**Journey assessment**: The milestone/issue structure maps directly to GitHub's model. This is the most important job-to-be-done and the plan serves it well. Each issue has the right fields: goal, scope, depends on, acceptance criteria. No story points or assignees — correctly omitted.

The dependency graph is explicit and correct. A developer creating issues will immediately see the sequencing. Issue 1.1 (no dependencies) can be created first; Issue 2.1 lists three prerequisites and a developer creating it will know what to link. This matches the mental model of someone working through the document top-to-bottom in GitHub.

The "Future Milestones" section correctly uses headline-level content only. A developer encountering Milestone 5 (Gemini CLI) at 2-3 sentences understands it is not ready for issue creation — the format itself signals this. No action required, no cognitive load consumed.

**Advisory: "How to Use This Document" section**

The planned content for this section includes the instruction "Once issues are created, track progress in the GitHub milestone -- this document becomes the historical record of initial planning." This is the right position, but the framing risks being too passive.

The developer creating GitHub issues has one specific concern: "Do I still need to keep this document in sync after I create the issues?" The answer is no, and the document should say so directly in the opening sentence, not bury it in the middle of a paragraph.

Suggested framing for the section lead:

> This document is a one-time starting point for GitHub issue creation. Once issues exist in GitHub, track progress there — this document does not need to stay in sync with GitHub state.

If this framing is too brief for the section, the rest of the planned content (milestone = GitHub milestone, issue = GitHub issue, dependencies become issue references) can follow. But the lead sentence should resolve the reader's primary uncertainty immediately.

This is advisory, not a blocking concern. The document will still be usable without this change.

---

## Journey Coherence Between the Two Deliverables

The gate between Task 1 and Task 2 is correctly placed. The routing configuration design established in the report (Change 1) is directly referenced in Issue 1.2 (routing schema) and Issue 1.1 (adapter interface). If the report's positions were wrong, the roadmap's issue scope would be wrong too. The gate prevents that cascade.

The forward reference from report to roadmap ("For implementation sequencing, see External Harness Roadmap") and the back-link from roadmap to report complete the navigation loop. A developer who reads the report and wants to act will find the path to the roadmap. A developer who lands on the roadmap directly will find the path back to the rationale. Both directions work.

---

## Summary

The plan is coherent. Deliverable 1 correctly fills the configuration DX gap the user identified. Deliverable 2 correctly formats for the GitHub issue creation workflow. The gate placement is justified and the dependency between the two deliverables is real. The advisory on the "How to Use" section lead is a small UX improvement but does not block execution.
