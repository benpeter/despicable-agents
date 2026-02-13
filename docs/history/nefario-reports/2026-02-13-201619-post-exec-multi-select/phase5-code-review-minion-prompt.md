You are reviewing code produced during an orchestrated execution.

## Changed Files
- `skills/nefario/SKILL.md` (AskUserQuestion block + skip determination logic, ~35 lines changed)
- `nefario/AGENT.md` (lines 775-778, post-exec skip description)
- `docs/orchestration.md` (lines 113-117 and 474-476, approval gate follow-up description)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase3-synthesis.md

## Your Review Focus
Code quality, correctness, bug patterns, cross-agent integration, complexity, DRY,
security implementation (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs).
Focus on whether the prompt specification changes are internally consistent and
whether cross-file references are aligned.

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained. Do not reference other findings by
number, plan steps, or context not present in this finding. The <description>
names the specific issue in domain terms.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase5-code-review-minion.md
