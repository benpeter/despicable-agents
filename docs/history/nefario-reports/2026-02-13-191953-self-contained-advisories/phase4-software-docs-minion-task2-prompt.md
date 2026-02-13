You are updating all advisory-related format definitions and instructions
in the nefario orchestration skill. Task 1 defined the canonical format in
nefario/AGENT.md. This task aligns all SKILL.md surfaces with that definition.

File: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

Read Task 1's deliverable first:
`/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` (Verdict Format
section, around line 666-720) to see the canonical format.

## Changes to Make

### A. Update the generic reviewer prompt template (around line 1089-1096)

Replace the current verdict instructions:
```
## Instructions
Return exactly one verdict:
- APPROVE: No concerns from your domain.
- ADVISE: <list specific non-blocking warnings>
- BLOCK: <describe the blocking issue and what must change>

Be concise. Only flag issues within your domain expertise.
```

With:
```
## Original User Request
Read the original user request from: $SCRATCH_DIR/{slug}/prompt.md

## Instructions
Return exactly one verdict:

- APPROVE: No concerns from your domain.

- ADVISE: Return warnings using this format for each concern:
  - [your-domain]: <one-sentence description>
    SCOPE: <file, component, or concept affected>
    CHANGE: <what should change, in domain terms>
    WHY: <risk or rationale, self-contained>
    TASK: <task number affected>

  Example (good -- self-contained):
  - [security]: Open redirect risk in callback handler
    SCOPE: OAuth callback endpoint in auth/callback.ts
    CHANGE: Validate redirect_uri against allowlist before issuing redirect
    WHY: Unvalidated redirect_uri allows attackers to redirect users to malicious sites after authentication
    TASK: Task 3

  Example (bad -- references invisible context):
  - [security]: Issue with the approach
    SCOPE: The callback handler
    CHANGE: Add the validation we discussed
    WHY: See the security analysis above
    TASK: Task 3

  Example (good -- BLOCK, self-contained):
  - SCOPE: JWT token validation in middleware/auth.ts
    ISSUE: Token signature verification uses HS256 with a hardcoded secret
    RISK: Any attacker who discovers the secret can forge valid tokens for any user
    SUGGESTION: Use RS256 with rotating key pairs from a secrets manager

  Each advisory must be understandable by a reader who has not seen the plan
  or this review session. SCOPE names the artifact, not a plan step number.
  CHANGE and WHY use domain terms, not plan-internal references.

- BLOCK: Return using this format:
  SCOPE: <file, component, or concept affected>
  ISSUE: <description of the blocking concern>
  RISK: <what happens if this is not addressed>
  SUGGESTION: <how the plan could be revised>

Be concise. Only flag issues within your domain expertise.

Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-{your-name}.md
```

### B. Update the ux-strategy-minion prompt (around line 1123-1131)

Replace the Instructions section of the ux-strategy-minion prompt with the
same verdict format as above (section A), but keep the existing
ux-strategy-specific "Your Review Focus" section unchanged. Also add the
"Original User Request" line before Instructions, same as in the generic prompt.

IMPORTANT: Preserve the existing "Write your verdict to:" output path line
that is already in the ux-strategy-minion prompt. Do not remove it.

### C. Update the execution plan gate ADVISORIES format (around line 1283-1309)

Replace the current advisory format:
```
Format:
```
`ADVISORIES:`
  [<domain>] Task N: <task title>
    CHANGE: <one sentence describing the concrete change to the task>
    WHY: <one sentence explaining the concern that motivated it>

  [<domain>] Task M: <task title>
    CHANGE: ...
    WHY: ...
```
```

With:
```
Format:
```
`ADVISORIES:`
  [<domain>] <artifact or concept> (Task N)
    CHANGE: <one sentence, in domain terms>
    WHY: <one sentence, self-contained rationale>

  [<domain>] <artifact or concept> (Task M)
    CHANGE: ...
    WHY: ...
```
```

The header line now leads with the SCOPE value (artifact or concept) and puts
the task reference in parentheses as secondary context. This makes the
advisory scannable by what it concerns, not by plan-internal task numbering.

Replace the advisory principles paragraph:
```
Advisory principles:
- Two-field format (CHANGE, WHY) makes each advisory self-contained
```

With:
```
Advisory principles:
- Self-containment test: a reader seeing only this advisory block can answer
  "what part of the system does this affect, what is suggested, and why"
- CHANGE and WHY must use domain terms -- no plan-internal references ("step 2",
  "the approach", "as discussed in the review")
```

Keep the rest of the advisory principles (3-line max, Details link mechanism,
5-advisory cap, 7-advisory rework threshold, informational note format)
exactly as they are.

### D. Update the inline summary template (around line 348)

DO NOT expand the inline summary verdict field to full SCOPE/CHANGE/WHY structure.
The inline summary is a compressed one-liner status indicator (~80-120 tokens).
Keep the existing simple format:

```
Verdict: {APPROVE | ADVISE(details) | BLOCK(details)} (Phase 3.5 reviewers only)
```

This means: DO NOT CHANGE section D. Leave it as-is.

### E. Add self-containment rule to Phase 5 code review instructions (around line 1665-1671)

After the existing findings format block:
```
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>
```

Add:
```
Each finding must be self-contained. Do not reference other findings by
number, plan steps, or context not present in this finding. The <description>
names the specific issue in domain terms.
```

Phase 5 findings are already artifact-grounded via the <file>:<line-range>
anchor. This addition prevents the description field from referencing
invisible context. Do NOT restructure the Phase 5 format itself -- it is a
different abstraction level (line-level vs. component-level) and its current
structure is correct.

## What NOT to Do

- Do not change verdict routing mechanics (Process Verdicts section, revision loop)
- Do not change phase sequencing or execution flow
- Do not change the Phase 4 execution logic
- Do not add XML tags to the format
- Do not change the 3-line cap for gate advisories
- Do not modify the Phase 5 findings format structure (only add the self-containment instruction)
- Do not modify report template (TEMPLATE.md) -- that is a separate task
- Do not change the inline summary template (section D) -- leave it as-is

## Deliverables

Updated `skills/nefario/SKILL.md` with:
- Reviewer prompt template with structured ADVISE/BLOCK format and examples
- ux-strategy-minion prompt with matching verdict instructions
- Original user request path added to reviewer prompts
- Execution plan gate ADVISORIES format using SCOPE-first header
- Updated advisory principles with self-containment test
- Phase 5 self-containment instruction
- Inline summary template left unchanged (per margo advisory)

## Success Criteria

- Generic reviewer prompt includes structured ADVISE format with good/bad examples
- Generic reviewer prompt includes a BLOCK example
- ux-strategy-minion prompt has matching verdict instructions
- ux-strategy-minion prompt preserves "Write your verdict to:" line
- Both reviewer prompts include original user request path
- Gate ADVISORIES format leads with artifact/concept, task number in parentheses
- Advisory principles include self-containment test
- Phase 5 findings have self-containment instruction
- Inline summary template is unchanged
- 3-line cap preserved for gate advisories
- No changes to verdict routing, phase sequencing, or execution flow

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
