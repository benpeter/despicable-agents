You are reviewing code produced during an orchestrated execution.

## Changed Files
- `margo/AGENT.md` (logic-bearing: agent system prompt)
- `the-plan.md` (logic-bearing: canonical spec)
- `docs/decisions.md` (documentation-only: decision record)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase3-synthesis.md

## Your Review Focus
Over-engineering, YAGNI, dependency bloat. Specifically:
- Is the two-tier evaluation itself over-engineered? Could the same outcome be achieved with simpler language?
- Does the Decision 33 entry contain unnecessary verbosity?
- Are there any redundant maintenance points across the three edit locations in AGENT.md?

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase5-margo.md
