You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase3-synthesis.md

## Your Review Focus
Convention adherence, CLAUDE.md compliance, intent drift. Specifically:
1. Does the plan stay true to the user's original request (a research report, not a design doc)?
2. Are the scope guards in the task prompts sufficient to prevent drift?
3. Does the plan respect project conventions (English, publishability, vendor-neutral)?
4. Is the task decomposition appropriate (2 tasks, 1 gate)?
5. Are the conflict resolutions sound?
6. Does the plan address all six success criteria from the original issue?

## Original User Request
Read the original user request from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/prompt.md

## Instructions
Return exactly one verdict:

- APPROVE: No concerns from your domain.

- ADVISE: Return warnings using this format for each concern:
  - [governance]: <one-sentence description>
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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase3.5-lucy.md
