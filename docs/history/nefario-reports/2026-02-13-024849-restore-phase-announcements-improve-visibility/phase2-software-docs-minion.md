# Domain Plan Contribution: software-docs-minion

## Recommendations

The SKILL.md Communication Protocol changes will ripple into **three documentation files** and **one project config file**. The scope is narrow because the Communication Protocol is primarily defined in SKILL.md itself (the source of truth), and documentation files describe its behavior rather than redefine it. The key risk is not missing a file -- it is introducing inconsistency between SKILL.md's new behavior and how the docs describe the user experience.

### Documentation Impact Map

**Files that MUST be updated:**

1. **`/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md`** -- This is the user-facing guide. It describes the user experience phase-by-phase (lines 98-121). If phase announcements are restored and orchestration messages get visual formatting, this file must reflect what the user will actually see. Specifically:
   - The "What Happens: The Nine Phases" section (lines 98-121) says things like "You wait while this happens" for Phase 2 and "You do not see this unless a problem surfaces" for Phases 5-8. If phase transition announcements are restored, these descriptions become inaccurate.
   - The file does not currently mention CONDENSE lines, heartbeat messages, or the visual formatting of orchestration messages. If the visibility improvements create a noticeably different user experience (e.g., bordered phase headers, emoji markers, or distinct formatting), the user guide should set expectations.

2. **`/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`** -- This is the contributor/architecture reference. It describes the orchestration architecture for people modifying SKILL.md. Key touchpoints:
   - The "Post-Execution Phases (5-8)" section (lines 110-118) explicitly describes the "dark kitchen" pattern and says "they execute silently." If phase announcements are restored for these phases, this description needs revision to distinguish between the user-visible announcement and the dark kitchen execution pattern.
   - The delegation flow sequence diagram (lines 173-304) includes "Note" annotations marking phase transitions. If the actual orchestrator now emits visible phase announcements, the diagram annotations should match the new behavior.
   - The compaction checkpoint description (lines 49-51, 93-94) references the communication protocol indirectly. If CONDENSE lines change format, the compaction checkpoint examples may need updating for consistency.

3. **`/Users/ben/github/benpeter/2despicable/3/docs/compaction-strategy.md`** -- This file references the communication protocol directly:
   - Line 83: "Checkpoints follow the SHOW category in the communication protocol (alongside approval gates, warnings, and the final summary)." If the SHOW/NEVER SHOW/CONDENSE categories are restructured or if phase announcements move from NEVER SHOW to SHOW, this sentence needs updating to remain accurate.
   - The checkpoint presentation example (lines 85-98) uses `---` delimiters and `COMPACT:` labels. If the broader visual formatting changes introduce a different delimiter or heading style for orchestration messages, the compaction checkpoint format should be consistent with the new visual language.

**Files that SHOULD be checked but likely need no changes:**

4. **`/Users/ben/github/benpeter/2despicable/3/CLAUDE.md`** -- The Session Output Discipline section (lines 48-65) references the Communication Protocol by name: "See `skills/nefario/SKILL.md` Communication Protocol for the full orchestration output specification." This cross-reference will remain valid regardless of content changes (it points to the section, not specific rules). However, the CLAUDE.md section itself lists `--quiet` flags and tool output suppression rules. If the SKILL.md changes alter which messages are suppressed vs. shown, verify that CLAUDE.md's local rules do not conflict. **Likely no changes needed** since CLAUDE.md defers to SKILL.md as authoritative.

5. **`/Users/ben/github/benpeter/2despicable/3/docs/architecture.md`** -- References orchestration indirectly (line 102: "Runs a nine-phase process") and links to `using-nefario.md` and `orchestration.md`. No direct references to communication protocol or output formatting. **No changes needed** unless the phase list itself changes (it does not in this task).

6. **`/Users/ben/github/benpeter/2despicable/3/README.md`** -- No references to communication protocol, output formatting, or phase announcements. **No changes needed.**

7. **`/Users/ben/github/benpeter/2despicable/3/docs/external-skills.md`** -- No references to communication protocol. **No changes needed.**

8. **`/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`** -- No references to communication protocol. **No changes needed.**

### Consistency Principle

The single source of truth for the Communication Protocol is SKILL.md. The documentation files describe the *user experience* and *architectural rationale* of that protocol. When updating docs, describe the observable behavior ("you will see a phase header when nefario transitions between phases"), not the implementation details ("the SHOW list includes phase transition announcements"). Implementation details belong in SKILL.md; docs explain what it means for the user or contributor.

## Proposed Tasks

1. **Update `docs/using-nefario.md` -- "What Happens" section** (Priority: MUST)
   - Revise the phase-by-phase descriptions (lines 98-121) to reflect restored phase announcements
   - If Phases 5-8 now show a transition announcement before going "dark kitchen," describe the new behavior: user sees a brief phase header, then silence unless something goes wrong
   - Keep descriptions user-oriented: what they see, not how SKILL.md categorizes it
   - Deliverable: Updated section in `using-nefario.md`
   - Dependencies: SKILL.md changes must be finalized first (this task reads the new SKILL.md to write accurate descriptions)

2. **Update `docs/orchestration.md` -- Post-execution and dark kitchen descriptions** (Priority: MUST)
   - Revise "Post-Execution Phases (5-8)" section (lines 110-118) to reconcile dark kitchen pattern with restored phase announcements
   - Verify sequence diagram annotations (lines 173-304) match new phase announcement behavior
   - Deliverable: Updated sections in `orchestration.md`
   - Dependencies: Same as task 1

3. **Update `docs/compaction-strategy.md` -- Communication protocol reference** (Priority: SHOULD)
   - Update line 83's reference to the SHOW category if the category structure changes
   - Verify compaction checkpoint visual format is consistent with the new orchestration message formatting
   - Deliverable: Updated reference(s) in `compaction-strategy.md`
   - Dependencies: Same as task 1

4. **Verify `CLAUDE.md` cross-reference remains valid** (Priority: COULD)
   - Read the updated SKILL.md Communication Protocol section
   - Confirm lines 48-65 of CLAUDE.md do not conflict with the new behavior
   - Deliverable: Either no-op confirmation or a minor edit to CLAUDE.md
   - Dependencies: Same as task 1

## Risks and Concerns

1. **Stale user expectations in `using-nefario.md`.** This is the highest risk. The file explicitly tells users "You wait while this happens" and "You do not see this unless a problem surfaces." If phase announcements are restored, users who read the guide will have wrong expectations. The guide is the front door for new users (`architecture.md` line 5 links to it first).

2. **Dark kitchen terminology mismatch.** Both `orchestration.md` and `compaction-strategy.md` describe post-execution phases as "silent." If phase announcements are restored for those phases (even just a one-line header), the word "silently" becomes inaccurate. The fix is simple (qualify the silence: "execute silently after a brief phase header"), but it must be done in both files consistently.

3. **Over-documenting formatting details.** If the visibility improvements use specific visual formatting (borders, emoji, uppercased headers), resist the urge to document the exact formatting in `using-nefario.md` or `orchestration.md`. Document the observable behavior ("phase transitions are announced with a header line"), not the implementation ("headers use === borders"). SKILL.md is the single source of truth for formatting specifics.

4. **Compaction checkpoint format drift.** If the new visual language for orchestration messages introduces a distinct style (e.g., boxed sections), the compaction checkpoint format in both SKILL.md and `compaction-strategy.md` should either adopt the same style or explicitly justify being different. Inconsistent visual treatment across orchestration messages creates confusion about which messages are "from nefario" vs. other output.

## Additional Agents Needed

None. The documentation updates are straightforward revisions to existing content, well within software-docs-minion's scope. If user-facing messaging (tooltip text, help output) were involved, user-docs-minion would be needed, but this task scope is limited to SKILL.md and its supporting architecture/contributor documentation.
