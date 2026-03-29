You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3-synthesis.md

## Your Review Focus
Over-engineering, YAGNI violations, unnecessary complexity:
- Does the plan add unnecessary fields, sections, or complexity beyond what is needed for Codex and Aider?
- Is the "Fields Considered and Excluded" section appropriate (documenting what was excluded helps prevent re-proposals) or is it over-documentation?
- Is the behavioral contract section proportionate to the task (types and contracts only), or does it creep into implementation guidance?
- Are there any premature abstractions (designing for future tools that don't exist yet)?
- Could the plan be simplified while still meeting the acceptance criteria?

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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3.5-margo.md
