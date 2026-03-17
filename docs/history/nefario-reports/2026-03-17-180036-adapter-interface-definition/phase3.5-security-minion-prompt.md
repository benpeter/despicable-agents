You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3-synthesis.md

## Your Review Focus
Security gaps in the adapter interface specification:
- Does the behavioral contract adequately prevent injection vectors (e.g., path traversal in working_directory, command injection via task_prompt)?
- Is the exclusion of the `environment` field sufficient to prevent API key leakage, or should the contract explicitly address how adapters handle secrets?
- Does the cleanup requirement (trap on failure) adequately address temporary file security?
- Are there any security implications of the `success` boolean vs. richer status representation that could mask security-relevant failures?

## Original User Request
Read the original user request from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/prompt.md

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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3.5-security-minion.md
