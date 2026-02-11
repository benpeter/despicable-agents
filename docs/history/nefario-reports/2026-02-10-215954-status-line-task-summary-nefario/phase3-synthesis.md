## Delegation Plan

**Team name**: nefario-status-line
**Description**: Add task summary display to nefario's status line, sentinel file lifecycle, Task description prefixes, and TaskCreate activeForm integration -- all within SKILL.md.

### Analysis

The devx-minion proposed 4 tasks: sentinel file lifecycle, Task description prefixes, TaskCreate activeForm, and user documentation. All four modify the same file (`skills/nefario/SKILL.md`) or produce documentation that can be included inline. There is no cross-agent file contention, no dependency chain, and no architectural decision requiring a gate.

**Consolidation decision**: Merge all 4 proposed tasks into a single execution task assigned to devx-minion. Rationale:
- All changes target one file (SKILL.md)
- Changes are additive (no structural refactoring)
- No conflicting perspectives between tasks
- Single-agent execution avoids coordination overhead and file contention
- devx-minion has the domain expertise (CLI/DX status patterns) to implement all four aspects

### Task 1: Add task summary status line to nefario SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are implementing a status line feature for the nefario orchestration skill.
    The goal: during nefario execution, the task summary (first line of the /nefario
    prompt) should be visible to the user so they know what nefario is working on.

    ## What to Modify

    One file only: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    ## Changes Required

    Make these five groups of changes to SKILL.md:

    ### 1. Summary extraction and sentinel file (Phase 1)

    In the "Phase 1: Meta-Plan" section, AFTER the existing scratch directory
    creation (`mkdir -p nefario/scratch/{slug}/`) and AFTER the `prompt.md`
    writing step, add instructions to:

    a. Extract the task summary: take the first line of the user's task
       description (the text passed as the argument to /nefario). This is the
       one-line summary.

    b. Truncate: if the summary exceeds 51 characters, truncate to 48 characters
       and append "...". The total sentinel file content (including "Nefario: "
       prefix) should not exceed 60 characters.

    c. Write sentinel file:
       ```
       echo "Nefario: <truncated-summary>" > /tmp/nefario-status-${CLAUDE_SESSION_ID}
       ```
       This follows the exact same `${CLAUDE_SESSION_ID}` pattern already used
       for the commit orchestration marker at line 568.

    d. Retain the summary string in session context as `nefario-summary` for
       use in subsequent Task descriptions and TaskCreate activeForm values.

    ### 2. Task description prefixes (all phases)

    Update every Task tool invocation template in SKILL.md to include the summary
    in the `description` field. The existing descriptions should be modified:

    - Phase 1 meta-plan Task: change `description: "Create meta-plan"` to
      `description: "Nefario: <summary> -- meta-plan"`
    - Phase 2 specialist Tasks: change `description: "<agent> planning input"` to
      `description: "Nefario: <summary> -- <agent> planning"`
    - Phase 3 synthesis Task: change `description: "Synthesize execution plan"` to
      `description: "Nefario: <summary> -- synthesis"`
    - Phase 3.5 review Tasks: change `description: "<agent> architecture review"` to
      `description: "Nefario: <summary> -- <agent> review"`
    - Phase 4 execution Tasks: add `description: "Nefario: <summary> -- <task-title>"`
      to the execution Task template
    - Phase 5 code review Tasks: change `description: "Phase 5 code review"` to
      `description: "Nefario: <summary> -- code review"`

    The `<summary>` placeholder refers to the `nefario-summary` value captured
    in Phase 1. Keep descriptions under 60 characters total where possible;
    truncate the summary portion if needed to fit.

    ### 3. TaskCreate activeForm (Phase 4)

    In the Phase 4 "Setup" section, where TaskCreate is mentioned for creating
    tasks from the plan, add an instruction:

    > Set `activeForm` on each TaskCreate call to include the task summary.
    > Format: "Nefario: <summary> -- <task activeForm>". If this exceeds 80
    > characters, use only the task-specific activeForm. The activeForm should
    > use present continuous tense (e.g., "Implementing auth module").

    ### 4. Sentinel file cleanup (wrap-up)

    In the wrap-up section (step 11, "Return to main"), alongside the existing
    commit marker removal (`rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`),
    add:
    ```
    rm -f /tmp/nefario-status-${CLAUDE_SESSION_ID}
    ```

    Also add cleanup at these early-exit points:
    - Plan rejection at the execution plan approval gate (if user selects "Reject")
    - Any STOP/abort path in Phase 4

    ### 5. Status line integration documentation

    Add a new section at the end of SKILL.md (before any trailing blank lines),
    titled "## Status Line Integration". Content:

    ```markdown
    ## Status Line Integration

    During orchestration, nefario writes a one-line task summary to
    `/tmp/nefario-status-${CLAUDE_SESSION_ID}`. Users with custom status line
    scripts can read this file to show the active nefario task.

    Example integration snippet for a custom `statusline.sh`:

        # Read session_id from the JSON input
        session_id=$(echo "$1" | jq -r '.session_id // empty')
        nefario_status=""
        if [ -n "$session_id" ]; then
          status_file="/tmp/nefario-status-${session_id}"
          if [ -f "$status_file" ]; then
            nefario_status=$(cat "$status_file")
          fi
        fi

    The file is cleaned up automatically when orchestration completes. Stale
    files (from crashed sessions) are harmless and cleared on reboot (`/tmp/`).

    This is a workaround until Claude Code natively supports active skill
    display in the status line (ref: GitHub issue #16078).
    ```

    ## What NOT to Do

    - Do NOT modify any file other than `skills/nefario/SKILL.md`
    - Do NOT create a separate status line script file
    - Do NOT modify any user settings files
    - Do NOT change the structure or ordering of existing SKILL.md sections
    - Do NOT touch the Communication Protocol section (the sentinel file is
      not a chat output -- it is a filesystem signal)
    - Do NOT add any dependencies or imports

    ## Context

    - The existing commit orchestration marker pattern (`/tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`)
      at line 568 and line 967 of SKILL.md is the model for the sentinel file approach.
    - The `description` field in Task tool calls appears as metadata when subagents
      are spawned. It is described as "Short 3-5 word description" but accepts longer strings.
    - The `activeForm` field in TaskCreate appears in the task list spinner (Ctrl+T)
      when a task is `in_progress`.
    - The skill is symlinked from `~/.claude/skills/nefario` to the repo path.

    ## Deliverables

    - Modified `skills/nefario/SKILL.md` with all five groups of changes
    - No other files created or modified

    ## Success Criteria

    - Sentinel file is written in Phase 1 and cleaned up at wrap-up and early-exit points
    - All Task description templates include the "Nefario: <summary>" prefix
    - Phase 4 TaskCreate instructions include activeForm guidance
    - Status line integration section is present and complete
    - Summary truncation handles edge cases (short summaries, exact-length, over-length)

- **Deliverables**: Modified `skills/nefario/SKILL.md`
- **Success criteria**: All five change groups applied correctly; sentinel file lifecycle is complete (write + cleanup at all exit points); Task descriptions updated; activeForm instructions added; documentation section present.

### Cross-Cutting Coverage

- **Testing**: Not applicable. This is a markdown skill definition file, not executable code. There is no test infrastructure for SKILL.md content. The success criteria are verifiable by reading the file.
- **Security**: Not applicable. The sentinel file contains only a task summary string (user-provided task description, first line). No secrets, credentials, or sensitive data. The file is in /tmp/ with standard permissions. The ${CLAUDE_SESSION_ID} pattern is already established and accepted in the codebase.
- **Usability -- Strategy**: The entire task IS a usability improvement. The devx-minion's analysis serves as the UX strategy input: three-channel approach (sentinel file for persistent status, Task descriptions for subagent context, activeForm for team spinners) provides coverage across all phases. No additional ux-strategy-minion review needed beyond what devx-minion already provided.
- **Usability -- Design**: Not applicable. No user-facing UI is produced. The status line is a text-based terminal indicator, and the integration is opt-in via user-owned scripts.
- **Documentation**: Covered by change group 5 in the task (inline status line integration docs in SKILL.md). No external documentation files needed -- this is an internal skill enhancement.
- **Observability**: Not applicable. No runtime services, APIs, or background processes are created.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing UI, no web-facing output)

### Conflict Resolutions

None. Single specialist contribution with no disagreements.

### Risks and Mitigations

1. **Session ID availability**: The `${CLAUDE_SESSION_ID}` environment variable is already used in SKILL.md for the commit marker. The status line script receives `session_id` via JSON stdin, which maps to the same value. Mitigation: document both access patterns in the integration snippet.

2. **Status line script is user-owned**: We cannot modify the user's statusline script. Mitigation: document the integration as an opt-in snippet, not an automatic install.

3. **Stale sentinel files on crash**: If nefario crashes, the file persists in /tmp/. Mitigation: /tmp/ is cleaned on reboot. Files are small and harmless. The documentation notes this.

4. **Task description length**: The "Short 3-5 word description" guidance for Task tool descriptions may be enforced as a limit in future Claude Code versions. Mitigation: keep descriptions concise; the "Nefario: <summary> -- <phase>" format is typically under 60 characters.

### Execution Order

Single task, no batching needed:
1. Task 1 (devx-minion modifies SKILL.md)

No approval gates. The changes are additive, easily reversible, and self-contained.

### Verification Steps

After execution:
1. Read `skills/nefario/SKILL.md` and verify:
   - Sentinel file write exists after scratch directory creation in Phase 1
   - Sentinel file cleanup exists alongside commit marker removal in step 11
   - Sentinel file cleanup exists at plan rejection path
   - All 6 Task description templates include "Nefario:" prefix
   - Phase 4 Setup includes activeForm instructions
   - "Status Line Integration" section exists at end of file
2. Verify no other files were created or modified
3. Verify the sentinel file path matches the commit marker pattern (`/tmp/nefario-status-${CLAUDE_SESSION_ID}`)
