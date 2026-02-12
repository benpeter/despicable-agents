You are reviewing a delegation plan before execution begins.
Your role: identify gaps, risks, or concerns from your domain.

## Delegation Plan
Read the full plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase3-synthesis.md

## Your Review Focus
Security gaps in the delegation plan. Specifically:
- Are there credential exposure risks in agent prompts or scratch file handling?
- Could prompt injection via issue body or agent output affect the gate logic?
- Does the domain signal table introduce any trust boundary issues (nefario analyzing plan content to select reviewers)?
- Are there injection vectors in the checklist handoff between Phase 3.5 and Phase 8?
- Secret sanitization coverage across new prompt templates.

## Instructions
Return exactly one verdict:
- APPROVE: No concerns from your domain.
- ADVISE: <list specific non-blocking warnings>
- BLOCK: <describe the blocking issue and what must change>

Be concise. Only flag issues within your domain expertise.
Write your verdict to: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase3.5-security-minion.md
