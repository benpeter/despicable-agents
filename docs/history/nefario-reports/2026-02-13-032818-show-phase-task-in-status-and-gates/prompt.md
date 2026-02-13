**Outcome**: Users always know which phase of nefario orchestration they are in and what task is being worked on, whether they are looking at the status line or responding to an approval gate. This closes the orientation gap where the status line is hidden during AskUserQuestion prompts, ensuring phase and task awareness is never lost regardless of UI state.

**Success criteria**:
- Nefario updates `/tmp/nefario-status-$sid` with the current phase followed by the task title at each phase boundary (e.g., "Phase 3: Synthesis | Restore phase announcements")
- Status line displays both phase and task title during orchestration when visible
- All AskUserQuestion gates include a contextual indicator of the current phase/step within their messaging
- Phase and task context is visible in both the status line AND gate UI, so neither pathway loses orientation
- Existing phase announcement markers (`**--- Phase N: Name ---**`) from #57 continue to work alongside the new mechanisms

**Scope**:
- In: Nefario SKILL.md phase transition logic (write status file with phase + task title), gate message templates (add phase context), despicable-statusline skill (if display format changes needed)
- Out: Changing Claude Code's AskUserQuestion UI behavior, modifying how Claude Code renders the status line during interviews, changes to post-execution dark kitchen phases

**Constraints**:
- Must build on the phase announcement and visual hierarchy system established in #57 (report: `docs/history/nefario-reports/2026-02-13-024849-restore-phase-announcements-improve-visibility`)
- Status file mechanism already exists (`/tmp/nefario-status-$sid`) via despicable-statusline skill -- extend, do not replace
