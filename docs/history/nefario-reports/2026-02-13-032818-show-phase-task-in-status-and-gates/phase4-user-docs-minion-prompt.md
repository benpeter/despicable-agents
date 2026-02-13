You are updating `docs/using-nefario.md` to reflect that the nefario
status line and approval gates now show the current orchestration phase.
This is a documentation-only task -- the implementation changes are already
done in SKILL.md (Task 1).

## Changes Required

Three targeted edits to `docs/using-nefario.md`. All are small -- roughly
5 changed lines total.

### A. Update "What Happens" introduction

Find the introductory text in the "What Happens" section that says something like:
"Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. Here is what you experience at each phase."

Add one sentence about phase awareness:
"The status line and all approval prompts include the current phase, so you always know where you are in the process."

### B. Update "What It Shows" subsection

In the Status Line section, update the description that says the status bar shows "the task summary" to say it shows "the current phase and task summary" and that it "updates at each phase transition."

Update the example status bar output to include a phase prefix. Change from something like:
```
~/my-project | Claude Opus 4 | Context: 12% | Build MCP server with OAuth...
```
To:
```
~/my-project | Claude Opus 4 | Context: 12% | P4 Execution | Build MCP server...
```

### C. Update "How It Works" subsection

Change text that says nefario "writes a one-line task summary to
`/tmp/nefario-status-<session-id>`" to say it writes "the current
phase and a one-line task summary" and note the file "is updated at each
phase transition" (not just written once at start).

## Writing guidelines

- Document the EXPERIENCE, not the mechanism. Users need to know they
  will always see their current phase -- not the exact header format or
  status file content format.
- Do NOT list specific gate header values (e.g., "P4 Gate") in the
  user guide. That is SKILL.md implementation detail.
- Do NOT document the status file format (`P<N> <Name> | <summary>`)
  in the user guide. Users see the rendered status line, not the raw file.
- Keep changes minimal. One sentence added, two subsections lightly revised.
- Use representative but not overly specific examples so they do not
  become stale if the format evolves.

## Files to modify

- `docs/using-nefario.md` -- single file, three small edits

## What NOT to do

- Do NOT rewrite the Status Line section structure
- Do NOT modify the manual configuration example
- Do NOT modify the despicable-statusline SKILL.md
- Do NOT add per-phase documentation of gate header formats
- Do NOT document the technical status file format

## Verification

After making changes, confirm:
1. The "What Happens" intro mentions phase awareness in one added sentence
2. The "What It Shows" example includes a phase prefix
3. The "How It Works" text mentions phase transitions, not just initial write
4. The manual configuration example is untouched
5. No gate header format details appear in the user guide

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced