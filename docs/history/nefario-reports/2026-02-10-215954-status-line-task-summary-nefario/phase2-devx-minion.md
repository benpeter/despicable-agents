# Domain Plan Contribution: devx-minion

## Recommendations

### Available Status Propagation Channels

Based on thorough research, there are exactly **three visible channels** during nefario execution where the task summary can appear:

1. **Task tool `description` field** (subagent spawning) -- The `description` parameter in Task tool calls is described as a "Short 3-5 word description of the task." This is visible in the main session's output when a subagent is spawned, but it is NOT persistently displayed. It appears as metadata in the tool call, not as a running status indicator. Current values in SKILL.md: `"Create meta-plan"`, `"<agent> planning input"`, `"Synthesize execution plan"`, `"<agent> architecture review"`, `"Phase 5 code review"`.

2. **TaskCreate `activeForm` field** (team task spinner) -- This text appears **in the spinner** when a task is `in_progress`. It renders in the task list view (toggled with Ctrl+T) with a spinner animation. This is the most persistently visible element during team execution (Phase 4). Current SKILL.md says to use TaskCreate for each task in the plan but does not specify `activeForm` values.

3. **Custom status line** (`~/.claude/settings.json` statusLine command) -- This is the bottom bar of the terminal. It receives JSON via stdin with fields including `agent.name` (when running with `--agent` flag). However, there is **no `active_skill` field** (that is the open feature request in GitHub issue #16078). The status line has no native awareness of which skill is running.

### Key Constraint: No Native Skill Status Line

GitHub issue #16078 (open, labeled `area:tui, enhancement`) confirms there is **no built-in mechanism** to show the active skill in the status line. The JSON input to statusline scripts includes `agent.name` (for `--agent` flag sessions) but no skill metadata. This means the status line approach requires a workaround.

### Recommended Strategy: File-Based Signal + Status Line Script

Since there is no native `active_skill` field in the status line JSON, the most reliable pattern is:

1. **Write a sentinel file at orchestration start** (Phase 1, alongside the scratch directory creation). Write the one-line task summary to a well-known path: `/tmp/nefario-status-${CLAUDE_SESSION_ID}` (reuses the existing session ID pattern from the commit marker).

2. **Enhance the status line script** to check for this file and display its contents when present. This integrates with the user's existing custom status line script.

3. **Clean up the sentinel file at orchestration end** (wrap-up step, alongside removing the commit marker).

4. **Prefix all Task tool `description` fields** with `"Nefario: "` to make subagent activity identifiable in tool output.

5. **Set `activeForm` on all TaskCreate calls** with the task summary prefix to make the spinner meaningful during Phase 4.

### Summary Format Recommendations

**Prefix pattern**: Use `"Nefario: <summary>"` as the prefix format. Rationale:
- "Nefario:" immediately identifies the orchestrator (vs. other skills or manual work)
- The colon-space separator is conventional and scannable
- The prefix is 9 characters, leaving ample room for the summary

**Truncation length**: Target **60 characters total** (including "Nefario: " prefix, so 51 characters for the summary itself). Rationale:
- Terminal status lines are typically 80-120 characters wide
- The status line shares its row with other information (model, context %, notifications)
- 60 characters is roughly half a standard terminal width, leaving room for other status elements
- Truncation indicator: append `...` when truncating (so effective limit is 57 chars + `...`)

**Consistency across phases**: The summary text should be **identical** across all phases. Rationale:
- Changing the text per phase would be confusing -- the user asked "what is nefario doing?" not "what phase is nefario on?"
- Phase information is internal orchestration detail that belongs in the communication protocol (heartbeat lines, CONDENSE lines), not the persistent status
- One consistent label reinforces that this is a single coherent orchestration run

**activeForm values in Phase 4**: For TaskCreate `activeForm`, combine the summary with the task-specific action: `"Nefario: <summary> -- <task activeForm>"`. If this exceeds 80 characters, show only the task-specific part. Rationale:
- During Phase 4, multiple tasks run in parallel, each with their own spinner
- The spinner should identify both the orchestration AND the specific task
- The task list (Ctrl+T) can show the full detail

### What NOT to Do

- **Do NOT try to modify the statusline JSON schema** -- that requires Claude Code platform changes (issue #16078). Work with what exists.
- **Do NOT write a new status line script that replaces the user's existing one** -- instead, document how users can integrate nefario status into their own scripts, and optionally provide a composable snippet.
- **Do NOT vary the summary text between phases** -- consistency is more important than granularity for a persistent status indicator.

## Proposed Tasks

### Task 1: Add sentinel file lifecycle to SKILL.md

**What to do**: Modify SKILL.md to write and clean up a nefario status sentinel file.

**Deliverables**:
- In Phase 1 (Meta-Plan), after creating the scratch directory, add: `echo "<task-summary>" > /tmp/nefario-status-${CLAUDE_SESSION_ID}`
- Truncate the summary to 51 characters (plus `...` if truncated) before writing
- In Wrap-up (step 11, alongside removing the commit marker), add: `rm -f /tmp/nefario-status-${CLAUDE_SESSION_ID}`
- Also remove on early termination / rejection at the plan approval gate

**Dependencies**: None (this is the foundational mechanism)

### Task 2: Prefix Task tool `description` fields with "Nefario:"

**What to do**: Update all Task tool invocation templates in SKILL.md to include the task summary in the `description` field.

**Deliverables**:
- Phase 1 meta-plan Task: `description: "Nefario: <summary> -- meta-plan"`
- Phase 2 specialist Task: `description: "Nefario: <summary> -- <agent> planning"`
- Phase 3 synthesis Task: `description: "Nefario: <summary> -- synthesis"`
- Phase 3.5 review Task: `description: "Nefario: <summary> -- <agent> review"`
- Phase 4 execution Task: `description: "Nefario: <summary> -- <task-title>"`
- Phase 5 code review Task: `description: "Nefario: <summary> -- code review"`

**Dependencies**: None

### Task 3: Add `activeForm` to TaskCreate instructions

**What to do**: Update the Phase 4 TaskCreate instructions in SKILL.md to include `activeForm` with the task summary.

**Deliverables**:
- Add instruction: "Set `activeForm` on each TaskCreate to `Nefario: <task-summary-truncated>` (present continuous form, e.g., 'Nefario: Adding status line -- Implementing auth module')."
- Document the 80-character limit for activeForm text
- Include the truncation rule: if summary + task exceeds 80 chars, show only the task-specific part

**Dependencies**: None

### Task 4: Document status line integration for users

**What to do**: Add a section to `docs/using-nefario.md` (or create a brief note in the skill) explaining how users can show the nefario task summary in their custom status line.

**Deliverables**:
- A composable bash snippet that reads `/tmp/nefario-status-${CLAUDE_SESSION_ID}` and outputs it if present
- Example showing how to integrate this into an existing statusline.sh
- Note that this is a workaround until Claude Code implements active_skill in the status line JSON (reference issue #16078)

**Dependencies**: Task 1

## Risks and Concerns

### Risk 1: Session ID availability

The sentinel file path uses `${CLAUDE_SESSION_ID}`. This environment variable is available in the main Claude Code session (it is already used for the commit marker: `touch /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`). However, the **status line script** runs as a separate process and receives JSON via stdin -- the JSON includes `session_id` as a field. The statusline script must read from `session_id` in the JSON, not from the environment variable. This means the file path convention must be predictable from the status line script's perspective.

**Mitigation**: Use exactly the same pattern as the existing commit marker. The statusline script reads `session_id` from the JSON input and checks for `/tmp/nefario-status-<session_id>`.

### Risk 2: Status line script is user-owned

Users have their own custom statusline scripts. We cannot modify them directly. Any status line integration must be opt-in or documented as a user-composable snippet. The sentinel file approach is non-invasive: it just writes a file that a status line script *can* read if configured to.

**Mitigation**: Document the integration pattern. Do not auto-modify user settings. Consider adding the integration snippet to the project's `.claude/settings.json` as a project-level status line (if one does not already exist).

### Risk 3: File cleanup on abnormal termination

If nefario orchestration crashes or the user force-quits, the sentinel file will remain in `/tmp/`. This is not harmful (it is a small file in a temporary directory that gets cleaned on reboot) but could show stale status.

**Mitigation**: The sentinel file is in `/tmp/` which is cleaned by the OS. The statusline script could additionally check the file's age and ignore files older than a threshold (e.g., 2 hours). This is a minor concern.

### Risk 4: `activeForm` and Task `description` are not the same as a persistent status bar

The `activeForm` spinner and `description` field are only visible during specific tool operations, not as a persistent always-visible indicator. The user will see these during Phase 4 team execution but not during Phases 1-3 (which use the Task subagent tool, not TaskCreate). The sentinel file + status line integration is the only truly persistent approach.

**Mitigation**: Use all three channels in combination: sentinel file for persistent status, Task `description` for subagent context, TaskCreate `activeForm` for team execution spinner. Together they provide reasonable coverage.

### Risk 5: Scope creep into other skills

The success criteria say "Out: other skills' status lines." The sentinel file pattern is nefario-specific (uses `nefario-status-` prefix). Other skills should not adopt the same pattern without coordination.

**Mitigation**: Name the file explicitly with `nefario-` prefix. Do not generalize the pattern.

## Additional Agents Needed

None. The current team is sufficient for this task. The changes are confined to SKILL.md modifications and optional documentation. No infrastructure, security, or complex design work is involved.
