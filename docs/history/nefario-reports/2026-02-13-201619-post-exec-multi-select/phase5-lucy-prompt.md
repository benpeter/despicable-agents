You are reviewing code produced during an orchestrated execution.

## Changed Files
- `skills/nefario/SKILL.md` (AskUserQuestion block + skip determination logic, ~35 lines changed)
- `nefario/AGENT.md` (lines 775-778, post-exec skip description)
- `docs/orchestration.md` (lines 113-117 and 474-476, approval gate follow-up description)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase3-synthesis.md

## Your Review Focus
Convention adherence, CLAUDE.md compliance, intent drift. Verify the changes align
with the user's original request (#107: make post-exec skip interview multi-select),
follow the project's established conventions (see CLAUDE.md in the repo root),
and do not drift from the stated goal. Check that the changes are consistent
with existing patterns in the codebase.

## Original User Request
Read the original user request from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/prompt.md

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

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase5-lucy.md
