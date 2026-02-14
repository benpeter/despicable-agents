You are reviewing code produced during an orchestrated execution.

## Changed Files

- the-plan.md (spec changes: iac-minion, margo, edge-minion sections + delegation table)
- docs/claudemd-template.md (new file: CLAUDE.md deployment template)
- docs/agent-catalog.md (staleness fixes)
- docs/architecture.md (added template link)
- minions/iac-minion/AGENT.md (rebuilt v2.0)
- minions/iac-minion/RESEARCH.md (expanded with serverless research)
- margo/AGENT.md (rebuilt v1.1)
- margo/RESEARCH.md (expanded with operational complexity research)
- minions/edge-minion/AGENT.md (rebuilt v1.1)
- minions/edge-minion/RESEARCH.md (expanded with boundary clarification)
- nefario/AGENT.md (delegation table rows added)

## Execution Context

Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase3-synthesis.md

## Your Review Focus

Code quality, correctness, bug patterns, cross-agent integration, complexity, DRY. Specifically:
- Are the spec changes in the-plan.md correct and consistent?
- Do the AGENT.md files correctly implement the spec changes?
- Are the delegation table entries consistent between the-plan.md and nefario/AGENT.md?
- Are the boundary clarifications between iac-minion and edge-minion symmetric and unambiguous?
- Is the CLAUDE.md template well-structured and non-biased?
- Security: no hardcoded secrets, injection vectors, or PII in any file.

## Instructions

Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase5-code-review-minion.md
