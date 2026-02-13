You are updating the "Status Line" section in `docs/using-nefario.md` (lines 166-198) to document the `/despicable-statusline` skill as the primary setup method, while keeping the existing manual approach as a fallback.

## What to do

Rewrite lines 166-198 of `/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md` (the "Status Line" section through the `---` separator before the final link). Replace the current content with a restructured section that follows this outline:

### Status Line

1. **Opening sentence**: Same as current -- you can add a live status line showing the current nefario task during orchestration.

2. **Setup (automated)**: Lead with the automated skill. One-liner: run `/despicable-statusline`. Note the `jq` prerequisite (already mentioned, keep it). Note this is a project-local skill -- available when Claude Code is running inside the despicable-agents repository. The effect is global (modifies `~/.claude/settings.json`) so you only need to run it once.

3. **What the skill handles**: Describe the four scenarios from the user's perspective (NOT as "State A/B/C/D"):
   - If you have no statusLine configured, the skill sets up a complete default.
   - If you have a standard statusLine, the skill appends the nefario snippet.
   - If nefario status is already configured, the skill does nothing (safe to re-run).
   - If you have a non-standard setup (e.g., a script file), the skill prints manual instructions instead of modifying your config.

4. **Safety**: Brief note (2-3 lines, not a full section). The skill validates JSON before and after writing, creates a backup at `~/.claude/settings.json.backup-statusline`, and rolls back on failure. It is idempotent -- safe to run multiple times.

5. **What It Shows**: Keep the existing subsection content (the example status bar line). Preserve verbatim.

6. **How It Works**: Keep the existing subsection content. Preserve verbatim.

7. **Manual setup (fallback)**: Reframe the existing JSON snippet as an alternative for users who prefer manual control or whose config the skill cannot auto-modify. Use a `<details>` block with summary "Manual configuration (alternative)". Inside, include the JSON snippet that is currently at lines 176-183. Add a note: "If the skill's default command changes in the future, the SKILL.md at `.claude/skills/despicable-statusline/SKILL.md` is the authoritative source."

## Constraints

- Do NOT change the `---` separator or the final link line to orchestration.md (line 200-201).
- Do NOT change any content outside lines 166-198.
- Do NOT add emojis.
- Do NOT inline the full shell command outside the manual fallback details block.
- Restart instruction: keep "Restart Claude Code or start a new conversation to activate" after both automated and manual paths.

## File to modify
`/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md`

## Reference
Read the current SKILL.md at `/Users/ben/github/benpeter/2despicable/3/.claude/skills/despicable-statusline/SKILL.md` to verify details about the skill's behavior, safety measures, and output messages.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
