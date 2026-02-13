Restore phase announcements and improve orchestration message visibility

Outcome: Nefario's orchestration messages (phase transitions, approval gates, status updates) are visually distinct from tool output and easy to follow. Approval gates present clear, meaningful links to relevant artifacts instead of raw scratch directory paths, so the user understands what to review and where to find it without needing to know internal directory structures.

Success criteria:
- Phase transition announcements are restored and visible to the user
- Nefario orchestration messages are visually distinguishable from tool output at a glance
- Approval gate messages use meaningful labels (e.g., "Review specialist contributions (phase2-*.md)") instead of raw scratch directory paths
- Highlighting approach works within Claude Code's actual text rendering capabilities (monospace terminal, CommonMark markdown)
- No regression in useful output suppression rules (raw tool dumps, verbose git output, etc. stay suppressed)

Scope:
- In: SKILL.md communication protocol / output discipline sections, approval gate message formatting, scratch directory reference presentation, phase transition announcements
- Out: Subagent output formatting, tool output suppression rules unrelated to nefario messages, AGENT.md changes, scratch directory structure itself

---
Additional context: consider all approvals given, skip test and security post-exec phases. Include user docs, software docs and product marketing in the roster. Rely on ux-design-minion and ux-strategy-minion to figure the way to highlight.
