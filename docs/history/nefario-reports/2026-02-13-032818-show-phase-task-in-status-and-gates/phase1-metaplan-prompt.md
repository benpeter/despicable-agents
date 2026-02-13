MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
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
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase1-metaplan.md`
