## Code Review: External Harness Integration

**Reviewer**: code-review-minion
**Date**: 2026-03-17

---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] docs/external-harness-integration.md:23 -- Executive Summary table: "Claude Code" is listed under "Feasible now" but the Tool Inventory section only has two other tools (Codex CLI, Aider) in the Feasible-Now tier. Claude Code is the existing native target and including it as a "feasible now" candidate for external harness delegation conflates the baseline with the alternatives. The Problem Statement (line 9) correctly distinguishes Claude Code as the current single harness; the Executive Summary should reflect that same framing (e.g., a "Current / Baseline" row or a footnote clarifying it is the incumbent, not a new candidate).
  AGENT: ai-modeling-minion
  FIX: Add a footnote or row qualifier: "Claude Code -- current native harness (baseline, not a new delegation candidate)" or move Claude Code into a separate "Baseline" row outside the feasibility tiers. This prevents a reader from misreading the table as "Claude Code is a new thing we're adding."

- [ADVISE] docs/external-harness-integration.md:64 -- Tool Inventory, Maturity column for Aider: "49.2% SWE-bench" is a time-sensitive numeric claim presented without a date qualifier. The report uses "Last assessed: 2026-03-17" for tool-level claims elsewhere (e.g., line 198: "as of 2026-03-17") but this specific metric lacks a date. SWE-bench scores change frequently as tools update.
  AGENT: ai-modeling-minion
  FIX: Add "(as of 2026-03-17)" to the maturity cell or footnote the score: "49.2% SWE-bench (as of 2026-03-17)."

- [ADVISE] docs/external-harness-integration.md:75 -- Cline CLI maturity cell: "80.8% SWE-bench" -- same issue as the Aider SWE-bench score. Undated benchmark claim in the table.
  AGENT: ai-modeling-minion
  FIX: Add "(as of 2026-03-17)" to the maturity cell or footnote.

- [ADVISE] docs/external-harness-integration.md:87 -- Not-Yet-Feasible tier, Amp row: "CLI pivot happened Mar 2026" -- this is relative to the assessed date but could read as ambiguous to future readers. The "Last assessed: 2026-03-17" note at the top of the document provides the anchor, but the phrasing "Mar 2026" without day precision is less clear than "as of 2026-03-17" used elsewhere.
  AGENT: ai-modeling-minion
  FIX: Replace "Mar 2026" with "as of 2026-03-17" for consistency with the rest of the document's date framing.

- [ADVISE] docs/external-harness-integration.md:145-146 -- architecture.md cross-link row: The synthesis plan (phase3-synthesis.md line 266) specified the exact row text: "| [External Harness Integration](external-harness-integration.md) | Feasibility study: delegating execution to external LLM coding tools alongside Claude Code subagents |". The actual row in architecture.md reads: "| [External Harness Integration](external-harness-integration.md) | Feasibility study: delegating tasks to external LLM coding tools (Codex CLI, Aider, Gemini CLI, etc.) |". The divergence is minor and the actual text is arguably more descriptive (lists example tools), but noting it for completeness. The row was added in the correct table position.
  AGENT: software-docs-minion
  FIX: No change required. The produced text is more informative than the spec text. Noting as ADVISE only to flag the deviation.

- [NIT] docs/external-harness-integration.md:100-111 -- Instruction Format Translation table: The `memory` (frontmatter) row maps to "No equivalent" across all four external format columns. This is accurate but could note that persistent memory is a Claude Code-specific primitive (not an instruction file concern at all) -- the current framing implies an instruction-format gap when it is actually a runtime-platform gap. Minor clarity issue.
  AGENT: ai-modeling-minion
  FIX: Add a parenthetical: "`memory` (frontmatter) | No equivalent -- Claude Code runtime primitive, not an instruction format concern | N/A | N/A | No equivalent"

- [NIT] docs/external-harness-integration.md:224 -- Recommendations > What Would Need to Change: "A resolution layer between the orchestrator and invocation would need to: translate prompts..." -- this is close to implementation design ("resolution layer," "translate prompts," "write instruction files," "normalize results"). The Out of Scope section explicitly excludes "Implementation of any wrapper, adapter, configuration schema, or abstraction layer." The current phrasing says "would need to" (functional requirement framing) not "here is the design," so it is within scope but near the boundary lucy flagged as DRIFT-2. No change required, but worth flagging.
  AGENT: ai-modeling-minion
  FIX: No change required. The language is directional, not prescriptive, and stays within the "describe what would be needed" framing from the synthesis plan.

---

**Summary**

The report is well-structured, internally consistent, and vendor-neutral. All six success criteria from the synthesis plan are addressed. The gap analysis is a proper structured table (not narrative). The feasibility recommendation uses the correct three-tier verdict. Cross-links resolve accurately. No blocking issues found.

The two ADVISE findings on SWE-bench scores (lines 64 and 75) are the most actionable: undated benchmark claims undermine the "Last assessed" date-discipline the report otherwise maintains well. The Executive Summary Claude Code framing issue (line 23) is a reader-experience concern, not an accuracy error.
