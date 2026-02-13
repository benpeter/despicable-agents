MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

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
- Must build on the phase announcement and visual hierarchy system established in #57
- Status file mechanism already exists (`/tmp/nefario-status-$sid`) via despicable-statusline skill -- extend, do not replace

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-devx-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-ux-strategy-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-ux-design-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-user-docs-minion.md`

## Key consensus across specialists:

### devx-minion
Use `P<N> <Header>` format for 8 primary gate headers (e.g., "P1 Team", "P4 Gate"); leave 4 follow-up gates unchanged. Update status file to `P<N>: <summary>` at each phase boundary. Shorten "P3.5 Impasse" to "P3 Impasse".

### ux-strategy-minion
Status file format `P4 Execution | Build MCP server...` with 32-char task summary. Gate headers prefixed with `P<N>`. Status line command unchanged (dumb pipe). No task title in gate headers.

### ux-design-minion
Write status file BEFORE phase announcement marker. Update at mid-execution gates. Dark kitchen phases 5-8 should also update status file. Header format "Phase N -- Label". Recommends 4 tasks.

### user-docs-minion
Three targeted edits to using-nefario.md. No changes to manual config example or despicable-statusline SKILL.md. Document experience, not mechanism.

## Key conflicts to resolve:
1. Header format: devx/ux-strategy recommend `P<N> Label` (compact), ux-design recommends `Phase N -- Label` (explicit). Must pick one given 12-char limit.
2. Status file format: devx recommends `P<N>: <summary>`, ux-strategy recommends `P<N> <Name> | <summary>`, ux-design recommends `Phase N: Name -- <summary>`. Must balance info density vs. space.
3. Dark kitchen status updates: ux-design says yes (infrastructure, not output); issue scope says "Out: changes to post-execution dark kitchen phases". Need to reconcile.
4. Task summary length: ux-strategy recommends 32 chars (down from 48); others keep 48. Need to decide.

## External Skills Context
1 external skill relevant: despicable-statusline (LEAF). No format changes needed to the skill itself -- it reads whatever is in the status file. user-docs-minion confirms no despicable-statusline changes needed.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase3-synthesis.md`
