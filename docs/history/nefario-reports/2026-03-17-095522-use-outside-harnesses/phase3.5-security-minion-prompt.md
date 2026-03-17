You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase3-synthesis.md

## Your Review Focus
Security gaps in the plan. Consider: Does the plan adequately handle publishability (no secrets, no proprietary info in the report)? Are there risks in the research approach itself (e.g., fetching external tool docs, running external commands)? Does the scope guard prevent injection of sensitive content? Note: the research report has an explicit "Out of Scope" section for security threat modeling of external tool execution -- the plan intentionally defers deep security analysis. Your review should focus on the plan's own security posture, not the research topic's security implications.

## Original User Request
Read the original user request from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/prompt.md

## Instructions
Return exactly one verdict:

- APPROVE: No concerns from your domain.

- ADVISE: Return warnings using this format for each concern:
  - [security]: <one-sentence description>
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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase3.5-security-minion.md
