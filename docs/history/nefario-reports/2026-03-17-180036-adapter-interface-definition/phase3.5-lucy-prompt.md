You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3-synthesis.md

## Your Review Focus
Convention adherence, CLAUDE.md compliance, and intent drift:
- Does the plan match the user's original intent (issue #138: adapter interface definition, types and contracts only)?
- Does the document structure follow existing conventions in docs/ (back-links, formatting patterns from agent-anatomy.md)?
- Are there any scope additions that weren't in the original request?
- Does the plan respect the YAGNI constraint from the roadmap?
- Does the plan respect the "No implementation" constraint from the issue?

Also read these context files:
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/CLAUDE.md (project instructions)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/agent-anatomy.md (existing pattern to follow)

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

Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-6xYwvg/adapter-interface-definition/phase3.5-lucy.md
