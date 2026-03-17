# Margo Code Review -- External Harness Integration

## VERDICT: ADVISE

The report is well-scoped as a feasibility study. It stays on the research side of the research/design boundary, uses tables over narrative, and covers the six success criteria without ballooning into implementation specification. The cross-links are minimal and appropriate. Two advisory items below.

## FINDINGS

- [ADVISE] docs/external-harness-integration.md:94-158 -- Protocol Landscape section is the longest section and contains material that drifts toward architecture design rather than research assessment. The three-layer model (L1/L2/L3), the 6-column protocol comparison table, and the detailed MCP/A2A analysis exceed what a feasibility study needs. The core feasibility question ("can we delegate?") is answered by the Tool Inventory and Gap Analysis sections; the protocol section adds complexity without changing the recommendation. Consider trimming to a single paragraph noting that CLI subprocess is the pragmatic choice, MCP is wrong for delegation but useful for context sharing, and A2A has zero adoption -- then move on. The comparison table could be cut entirely or collapsed to 3-4 rows.
  AGENT: ai-modeling-minion
  FIX: Trim Protocol Landscape to ~10 lines: one paragraph with the three-layer framing, one sentence each on MCP/A2A/CLI-subprocess verdicts. Remove the 6-column comparison table or replace with a 3-row summary (CLI subprocess = pragmatic, MCP = wrong layer, A2A = zero adoption). The full protocol analysis is valuable reference material but belongs in a future design document, not a feasibility study.

- [NIT] docs/external-harness-integration.md:239-249 -- "Convergence Patterns Worth Watching" and "ACP Protocol" subsections under Recommendations are forward-looking analysis that reads as technology radar content rather than feasibility recommendation. They are not wrong but they expand the report's surface area beyond the research question. The report already covers these tools in the inventory; restating convergence trends here is redundant.
  AGENT: ai-modeling-minion
  FIX: No change required. If trimming for conciseness, these two subsections (lines 239-249) are the lowest-value content to cut.
