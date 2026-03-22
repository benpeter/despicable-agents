You are reviewing code produced during an orchestrated execution.

## Changed Files
- `margo/AGENT.md` (logic-bearing: agent system prompt)
- `the-plan.md` (logic-bearing: canonical spec)
- `docs/decisions.md` (documentation-only: decision record)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase3-synthesis.md

## Your Review Focus
Convention adherence, CLAUDE.md compliance, intent drift. Specifically:
- Does the AGENT.md change respect the project's versioning system (x-plan-version matches spec-version)?
- Is the Decision 33 entry consistent with the format of existing decisions?
- Does the two-tier language faithfully represent the user's original intent (calibrate YAGNI to distinguish speculative vs. roadmap-planned)?
- Was the-plan.md modified minimally (it's human-edited, single-source-of-truth)?

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-zPJrC8/margo-yagni-calibration/phase5-lucy.md
