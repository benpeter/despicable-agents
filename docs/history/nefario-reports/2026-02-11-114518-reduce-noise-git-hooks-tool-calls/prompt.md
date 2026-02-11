**Outcome**: The main orchestration session stays clean and focused by suppressing or summarizing verbose output from git commit hooks and read/write tool calls, so that the operator can follow the session flow without wading through irrelevant tool output.

**Success criteria**:
- Git commit hook output does not appear inline in the main session unless an error occurs
- Read, Write, and Bash tool call output is reduced to the last 2 lines in the main session
- Existing hook and tool functionality is unchanged

**Scope**:
- In: Git commit hook output handling, Read/Write tool call verbosity in the main session
- Out: Hook logic changes, new hooks, tool behavior outside the main session, other tool types
