You are reviewing code produced during an orchestrated execution.

## Changed Files
- `docs/history/nefario-reports/TEMPLATE.md` (replaced External Skills with Session Resources section, +47/-3 lines)
- `skills/nefario/SKILL.md` (added skills-invoked/orchestrator-tools tracking, +25/-3 lines)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase3-synthesis.md

## Your Review Focus
Code quality, correctness, cross-agent integration, DRY. Focus on:
- Consistency between TEMPLATE.md structure and SKILL.md references
- Conditional inclusion rules coherence (do they contradict?)
- Markdown table alignment and syntax
- Placeholder consistency ({N}, {M}, {skill-name} patterns)
- No security concerns (no auth, APIs, user input -- these are documentation files)

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-yOkLIr/skills-tools-usage-tracking/phase5-code-review-minion.md
