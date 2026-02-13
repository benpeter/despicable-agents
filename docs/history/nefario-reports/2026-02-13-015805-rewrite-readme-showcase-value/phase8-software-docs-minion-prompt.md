You are updating documentation files to align with a rewritten README.md.

## Context
The README.md for the despicable-agents project has been rewritten. Key changes:
- "Six mandatory reviewers" corrected to "five mandatory reviewers" everywhere
- "Try It" section removed (merged into Examples)
- New "What You Get" section added
- "mostly vibe-coded" limitation reframed as "AI-assisted prompt authoring"
- "This project explores" removed, replaced with "Built on"
- Agent count now consistently "27 agents + 2 skills" (not "29 agents")

## Work Order
Read the documentation impact checklist at:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase3.5-docs-checklist.md

Focus on the items tagged [software-docs] with MUST priority:
1. Verify anchor link stability -- check docs/ files for references to removed README sections
2. Cross-reference governance reviewer count -- check all docs/ files for "six mandatory reviewers" or similar claims that need correcting to "five"

Also check SHOULD items:
3. Check using-nefario.md for references to old README structure
4. Check architecture.md for "vibe-coded" references
5. Check external-skills.md for stale agent count references
6. Check all docs/ for orphaned README section links

## Files to check
- /Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md
- /Users/ben/github/benpeter/2despicable/2/docs/orchestration.md
- /Users/ben/github/benpeter/2despicable/2/docs/architecture.md
- /Users/ben/github/benpeter/2despicable/2/docs/external-skills.md
- /Users/ben/github/benpeter/2despicable/2/docs/agent-catalog.md
- /Users/ben/github/benpeter/2despicable/2/docs/decisions.md

## IMPORTANT: Scope limitation
This task is OUT OF SCOPE for editing docs/ files. The user explicitly de-scoped docs/ changes from this request.

Your job: AUDIT ONLY. Report what needs changing and where. Do NOT edit any files. Write your findings to:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase8-software-docs.md

Format findings as:
## Documentation Audit Findings

### MUST Fix
- **File**: path — **Issue**: description — **Line(s)**: N-M

### SHOULD Fix
- **File**: path — **Issue**: description — **Line(s)**: N-M

### No Issues Found
- **File**: path — checked for: description