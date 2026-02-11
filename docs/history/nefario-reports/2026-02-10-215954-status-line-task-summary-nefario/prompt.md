Show task summary in status line during nefario execution

**Outcome**: While nefario is running, the Claude Code status line displays the task summary (first line of the /nefario prompt) so that users can see what nefario is working on without scrolling back through output.

**Success criteria**:
- Status line shows the one-line task summary from the /nefario invocation during execution
- Summary is visible throughout all phases (meta-plan, specialist planning, synthesis, execution)
- Long summaries are truncated gracefully (no overflow or wrapping)

**Scope**:
- In: Nefario skill status line behavior during execution
- Out: Subagent individual status lines, post-execution summary, other skills' status lines
