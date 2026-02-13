You are updating the "Skills" section in `docs/deployment.md` to document project-local skills alongside the existing globally-installed skills.

## What to do

Expand the Skills section at lines 106-110 of `/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`. The current section documents only the globally-installed skills (`/nefario`, `/despicable-prompter`). Add a "Project-Local Skills" subsection after the existing content.

Structure the addition as:

### Project-Local Skills

A brief paragraph explaining:
- Two project-local skills exist: `/despicable-lab` and `/despicable-statusline`
- They live in `.claude/skills/` within the repository
- They are NOT deployed by `install.sh` -- they are available only when Claude Code is running inside the despicable-agents repository
- Despite being project-local, their effects may be global (e.g., `/despicable-statusline` modifies `~/.claude/settings.json`)

Then a small table or brief entries for each:

| Skill | Purpose | Location |
|-------|---------|----------|
| `/despicable-lab` | Check and rebuild agents when spec versions diverge | `.claude/skills/despicable-lab/` |
| `/despicable-statusline` | Configure Claude Code status line for nefario orchestration status | `.claude/skills/despicable-statusline/` |

For `/despicable-statusline`, add a cross-reference: "See the [Status Line](using-nefario.md#status-line) section in Using Nefario for usage details."

## Constraints

- Do NOT modify the existing paragraph about globally-installed skills (lines 108-110). Add below it.
- Do NOT change the link to orchestration.md on line 110. Move it after the new subsection if needed so it remains the final line.
- Do NOT add emojis.
- Keep the addition concise -- this is a reference entry, not a tutorial.

## File to modify
`/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
