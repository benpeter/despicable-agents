You are reviewing code produced during an orchestrated execution.

## Changed Files
- `margo/AGENT.md` (logic-bearing: agent system prompt — controls margo's YAGNI evaluation behavior)
- `the-plan.md` (logic-bearing: canonical spec — controls future agent builds)
- `docs/decisions.md` (documentation-only: decision record)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase3-synthesis.md

## Your Review Focus
Code quality, correctness, bug patterns, cross-agent integration, complexity, DRY, security implementation (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs).

For this specific change: focus on the two-tier YAGNI evaluation logic in margo/AGENT.md — is the decision tree clear and unambiguous? Are the SPECULATIVE/ROADMAP-PLANNED labels consistent across all three edit points? Does the citation requirement in the verdict format make sense?

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase5-code-review-minion.md
