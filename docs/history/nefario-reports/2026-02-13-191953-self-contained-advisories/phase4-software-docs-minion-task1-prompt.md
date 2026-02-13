You are updating the advisory verdict format definition in nefario's agent
specification. This is the canonical definition that other files will
reference.

## What to Change

File: `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`

### 1. Update the ADVISE verdict format (around line 664-672)

Replace the current ADVISE format block:
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  TASK: <task number affected, e.g., "Task 3">
  CHANGE: <what specifically changed in the task prompt or deliverables>
  RECOMMENDATION: <suggested change>
```

With the new format:
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  SCOPE: <file, component, or concept affected -- e.g., "nefario/AGENT.md verdict format", "OAuth token refresh flow", "install.sh symlink targets">
  CHANGE: <what is proposed, in domain terms -- not by referencing plan-internal numbering>
  WHY: <risk or rationale, using only information present in this advisory>
  TASK: <task number> (routing metadata for orchestrator -- not shown in user-facing output)
```

### 2. Update the explanatory paragraph after the ADVISE format (around line 674-676)

Replace:
```
The TASK and CHANGE fields enable the calling session to populate the execution
plan approval gate with structured advisory data, showing which tasks were
modified and what changed.
```

With:
```
Each advisory is self-contained: a reader seeing only the advisory block can
answer "what part of the system does this affect" (SCOPE), "what is suggested"
(CHANGE), and "why" (WHY) without opening any other document. The TASK field
is routing metadata that enables the orchestrator to inject advisories into the
correct task prompts -- it is not shown in user-facing output.

Content rules for all advisory fields:
- SCOPE names a concrete artifact (file path, config key, endpoint) or concept
  (flow, pattern, format). Not "step 1" or "the approach."
- CHANGE states the proposed modification in domain terms. Not "updated the
  task prompt" or "added to step 2."
- WHY explains the risk or rationale using facts present in this advisory.
  Not "see the synthesis" or "as discussed."
- One sentence per field. If more detail is needed, the Details link mechanism
  provides progressive disclosure.
```

### 3. Add SCOPE to the BLOCK verdict format (around line 688-693)

Replace:
```
Block format:
```
VERDICT: BLOCK
ISSUE: <description of the blocking concern>
RISK: <what happens if this is not addressed>
SUGGESTION: <how the plan could be revised to resolve this>
```
```

With:
```
Block format:
```
VERDICT: BLOCK
SCOPE: <file, component, or concept affected>
ISSUE: <description of the blocking concern>
RISK: <what happens if this is not addressed>
SUGGESTION: <how the plan could be revised to resolve this>
```

SCOPE, ISSUE, RISK, and SUGGESTION must each be self-contained -- readable
without access to the plan, other verdicts, or the originating conversation.
```

### 4. Make AGENT.md reference SKILL.md as the canonical location for reviewer output format

After the updated ADVISE format block and its explanatory paragraph, add a
one-line note:

```
Reviewers receive the advisory output format via the reviewer prompt template
in SKILL.md. The format above defines the schema; the reviewer prompt provides
examples and enforcement instructions.
```

## What NOT to Do

- Do not change anything outside the Verdict Format section (lines ~656-693)
- Do not change the APPROVE verdict -- it has no format body
- Do not change the Resolution process (lines 680-685) or the revision loop mechanics
- Do not modify the ARCHITECTURE.md section that follows
- Do not restructure other sections of AGENT.md

## Deliverables

Updated `nefario/AGENT.md` with:
- ADVISE verdict format using SCOPE/CHANGE/WHY/TASK fields
- Explanatory paragraph documenting self-containment rules
- BLOCK verdict format with SCOPE field added
- Reference note pointing to SKILL.md for reviewer prompt details

## Success Criteria

- The ADVISE format has exactly 4 labeled fields: SCOPE, CHANGE, WHY, TASK
- The BLOCK format has exactly 4 labeled fields: SCOPE, ISSUE, RISK, SUGGESTION
- RECOMMENDATION field is gone (merged into CHANGE)
- Content rules are documented inline
- No other sections of AGENT.md are modified

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
