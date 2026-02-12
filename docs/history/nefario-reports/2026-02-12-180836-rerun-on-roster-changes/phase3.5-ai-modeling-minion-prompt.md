You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase3-synthesis.md

Also read for context:
- /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md (lines 291-375 Phase 1, lines 379-457 Team Gate)
- /Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md (lines 1-50 META-PLAN mode)

## Your Review Focus
Prompt engineering and multi-agent architecture. Specifically:
- Is the META-PLAN re-run prompt design in Task 2 sound? Will providing the original meta-plan as context help or hurt the re-run quality?
- Is the constraint directive appropriate (too restrictive = shallow output, too loose = scope drift)?
- Is the reviewer gate re-evaluation logic (in-session, no subagent) the right call vs. spawning nefario?
- Are there prompt engineering risks (e.g., nefario ignoring the constraint directive, context window bloat from carrying the original meta-plan)?

## Instructions
Return exactly one verdict:
- APPROVE: No concerns from your domain.
- ADVISE: list specific non-blocking warnings
- BLOCK: describe the blocking issue and what must change

Be concise. Only flag issues within your domain expertise.
Write findings to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase3.5-ai-modeling-minion.md
