You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase3-synthesis.md

## Your Review Focus
Governance alignment and repo convention enforcement:
- Do the planned changes faithfully address the three gaps identified in issue #91 without scope drift?
- Are spec-version bumps consistent across the plan?
- Does the delegation table update follow existing table conventions?
- Does the CLAUDE.md template placement (docs/claudemd-template.md) follow docs/ conventions?
- Is the nefario regeneration properly scoped (data-staleness rebuild, not spec change)?
- Are there any CLAUDE.md rules being violated by the plan?
- Do the "Does NOT do" section additions follow existing boundary patterns?

## Original User Request
Read the original user request from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/prompt.md

## Instructions
Return exactly one verdict:

- APPROVE: No concerns from your domain.

- ADVISE: Return warnings using this format for each concern:
  - [your-domain]: <one-sentence description>
    SCOPE: <file, component, or concept affected>
    CHANGE: <what should change, in domain terms>
    WHY: <risk or rationale, self-contained>
    TASK: <task number affected>

- BLOCK: Return using this format:
  SCOPE: <file, component, or concept affected>
  ISSUE: <description of the blocking concern>
  RISK: <what happens if this is not addressed>
  SUGGESTION: <how the plan could be revised>

Be concise. Only flag issues within your domain expertise.

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-pK8eRN/opus-model-ai-modeling-roster/phase3.5-lucy.md
