You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3-synthesis.md

## Your Review Focus
Test coverage and validation strategy:
- The plan produces a Markdown specification document, not executable code. Is the cross-cutting coverage note ("Not applicable -- no tests to write or run") appropriate?
- Are there any validation checks that should be added to verify the specification document is well-formed (e.g., all fields from the roadmap are present, field table format is correct)?
- Should the plan include a validation step comparing the produced fields against the roadmap's Issue 1.1 scope?

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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3.5-test-minion.md
