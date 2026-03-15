You are reviewing code produced during an orchestrated execution.

## Changed Files

- the-plan.md (spec changes: iac-minion, margo, edge-minion sections + delegation table)
- docs/claudemd-template.md (new file: CLAUDE.md deployment template)
- docs/agent-catalog.md (staleness fixes)
- docs/architecture.md (added template link)
- minions/iac-minion/AGENT.md (rebuilt v2.0)
- margo/AGENT.md (rebuilt v1.1)
- minions/edge-minion/AGENT.md (rebuilt v1.1)
- nefario/AGENT.md (delegation table rows added)

## Your Review Focus

Convention adherence, CLAUDE.md compliance, intent drift. Specifically:
- Do the spec changes follow the-plan.md conventions (versioning, format, boundaries)?
- Do the AGENT.md frontmatter values match their specs?
- Does the docs/claudemd-template.md follow docs/ conventions?
- Is there any intent drift from issue #91's three gaps?
- Are the "Does NOT do" sections consistent across specs and AGENT.md files?

## Instructions

Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase5-lucy.md
