Improve gate review transparency — surface decision rationale at all gate types (Issue #135)

All four nefario approval gates (Team, Reviewer, Execution Plan, mid-execution) surface decision rationale, trade-offs, and rejected alternatives inline so users can make meaningful approve/reject decisions without opening scratch files.

Success criteria:
- Team gate shows "NOT SELECTED (notable)" block (max 3 entries) with exclusion rationale
- Reviewer gate shows per-member exclusion rationale and "Review focus" per discretionary pick
- Execution Plan gate replaces CONFLICTS RESOLVED with structured DECISIONS section using Chosen/Over/Why format (max 5 entries)
- Mid-execution gate has good/bad RATIONALE examples in SKILL.md and explicit agent prompt instructions for rationale reporting
- AGENT.md synthesis output produces structured conflict resolutions (Chosen/Over/Why/Source) and per-task "Gate rationale" field for gated tasks
- AGENT.md meta-plan output includes excerptable exclusion rationale for Team gate consumption
- Compaction focus strings name "key design decisions" to preserve decision data through context compression
- Every gate passes the self-containment test: decidable without clicking the Details link

Scope:
- In: SKILL.md, AGENT.md, TEMPLATE.md, docs/orchestration.md
- Out: Gate interaction mechanics, post-execution phases, report generation, advisory mode gates, new gate types

Constraints:
- Advisory reports: docs/history/nefario-reports/2026-03-17-101248-improve-gate-review-transparency.md (primary)
- Before/after examples in companion directory phase3-synthesis.md
- ADVISORIES keep CHANGE/WHY format (not Chosen/Over/Why)
- RISKS stays separate from DECISIONS
- Mid-execution gate: add examples and instructions only, do NOT redesign format

---
Additional context: all approvals given and dont stop for compaction, work in the same branch if one exists already
