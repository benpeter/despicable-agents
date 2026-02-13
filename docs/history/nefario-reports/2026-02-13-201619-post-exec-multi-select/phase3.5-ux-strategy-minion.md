ADVISE

- [ux-strategy]: Question text guidance may add unnecessary cognitive load
  SCOPE: SKILL.md AskUserQuestion block, line 71-72
  CHANGE: Consider testing question text without the parenthetical "(confirm with none selected to run all)". Skip framing already implies zero-selection = run all. The phrase "Skip any post-execution phases for Task N?" naturally means "I'm not skipping anything if I select nothing."
  WHY: Every word in a prompt is cognitive load. The parenthetical adds 7 words to make explicit what the skip framing already communicates implicitly. Real-world usage will reveal whether users hesitate without this guidance or find it redundant.
  TASK: Task 1

Note: This is a minor optimization opportunity, not a blocking concern. The proposed design is sound. Skip framing, zero-action default, and risk-gradient ordering all follow UX best practices. The multi-select serves a real user need (granular control over phase combinations) and simplifies the current 4-option single-select. If the parenthetical guidance proves necessary during live usage, it can stay. If users understand the default without it, remove it in a future iteration.
