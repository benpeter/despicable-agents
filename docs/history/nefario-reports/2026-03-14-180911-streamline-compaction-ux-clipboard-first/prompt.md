**Outcome**: The compaction flow no longer asks for permission before generating the compaction prompt. Instead, it always generates the prompt, copies it to the clipboard, and tells the user to paste it back to compact or type "continue" to skip. This eliminates a redundant confirmation step and makes the flow self-service. Additionally, the post-compaction continuation instruction is clarified: the user queues "continue" immediately (it executes once compaction finishes), rather than the misleading "type continue once you are ready."

**Success criteria**:
- Compaction prompt is always generated and copied to clipboard without asking first
- User message clearly says: paste to compact, or type "continue" to skip
- Post-compaction instruction tells user to queue "continue" (not "type once ready")
- No behavioral regression in the orchestration phases that follow compaction

**Scope**:
- In: Compaction flow logic and user-facing messages in the nefario skill
- Out: Compaction prompt content/quality, other nefario phases, Claude Code clipboard internals
