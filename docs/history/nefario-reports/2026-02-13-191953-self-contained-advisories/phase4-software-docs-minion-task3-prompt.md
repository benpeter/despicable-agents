You are updating the output standards in lucy's and margo's agent
specifications to include the self-contained advisory requirement.

These two agents are the only reviewers with persistent AGENT.md files
that contain verdict format instructions. Other reviewers receive the
format exclusively via the reviewer prompt template in SKILL.md.

## What to Change

### File 1: `/Users/ben/github/benpeter/2despicable/2/lucy/AGENT.md`

In the Output Standards section (around line 206-216), after the existing
bullet "Specific citations":
```
- **Specific citations**: Always cite the exact plan element, CLAUDE.md directive, or requirement being referenced. No vague findings.
```

Add a new bullet immediately after it:
```
- **Self-contained findings**: Each finding must be readable in isolation. Name the file, component, or concept it concerns -- not "Task 3" or "the approach." CHANGE descriptions state what is proposed in domain terms. WHY descriptions explain the rationale using information present in the finding itself.
```

### File 2: `/Users/ben/github/benpeter/2despicable/2/margo/AGENT.md`

Find the Output Standards section. Add a similar self-containment bullet.
Read the file first to find the exact location and match the existing style.

The bullet for margo should read:
```
- **Self-contained findings**: Each finding names the specific file, config, or concept it concerns. Proposed changes use domain terms, not plan-internal references. Rationale uses facts present in the finding.
```

## What NOT to Do

- Do not change any other section of either AGENT.md
- Do not restructure the Output Standards sections
- Do not add examples (these agents receive examples via the reviewer prompt)
- Do not change verdict type definitions (APPROVE/ADVISE/BLOCK)

## Deliverables

- Updated `lucy/AGENT.md` Output Standards with self-contained findings bullet
- Updated `margo/AGENT.md` Output Standards with self-contained findings bullet

## Success Criteria

- Both files have a "Self-contained findings" bullet in Output Standards
- The bullets match each agent's voice and existing style
- No other sections modified

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
