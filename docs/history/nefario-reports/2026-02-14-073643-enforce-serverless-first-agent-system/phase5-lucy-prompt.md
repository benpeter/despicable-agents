You are reviewing code produced during an orchestrated execution.

## Changed Files
- the-plan.md (iac-minion spec + margo spec)
- minions/iac-minion/AGENT.md + RESEARCH.md
- margo/AGENT.md
- lucy/AGENT.md
- docs/claudemd-template.md
- docs/decisions.md

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase3-synthesis.md

## Your Review Focus
Convention adherence, CLAUDE.md compliance, intent drift. Check that changes align with the user's intent: serverless-first as a strong default (not hard block), agents remain usable for non-serverless work, Helix Manifesto alignment, proper Decision 31 supersession documentation.

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase5-lucy.md
