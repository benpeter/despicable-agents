You are reviewing code produced during an orchestrated execution.

## Changed Files
- the-plan.md (iac-minion spec: serverless-first identity, Step 0 restructure, research focus; margo spec: new remit bullet)
- minions/iac-minion/AGENT.md (identity line, Step 0 rewrite, frontmatter update)
- minions/iac-minion/RESEARCH.md (deployment strategy section: neutrality -> serverless-first)
- margo/AGENT.md (burden-of-proof paragraph, framing rules #1/#3 amended, new checklist step 7, frontmatter)
- lucy/AGENT.md (serverless-first compliance check step 6, CLAUDE.md directives bullet, frontmatter)
- docs/claudemd-template.md (serverless-default framing: omission = serverless, examples regrouped)
- docs/decisions.md (Decision 31: serverless-first default, supersedes topology-neutral)

## Execution Context
Read scratch files for context: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase3-synthesis.md

## Your Review Focus
Code quality, correctness, bug patterns, cross-agent integration, complexity, DRY, security implementation (hardcoded secrets, injection vectors, auth/authz, crypto, CVEs). Focus on: consistency of blocking concern lists across files, correct framing (strong default not hard block), no contradictions between agents.

## Instructions
Review the actual code files listed above. Return verdict:

VERDICT: APPROVE | ADVISE | BLOCK
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>

Each finding must be self-contained.

Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-O24uAb/enforce-serverless-first-agent-system/phase5-code-review-minion.md
