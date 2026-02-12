## Domain Plan Contribution: devx-minion

### Recommendations

**1. Classification: minor vs. substantial adjustments**

Use a simple, deterministic threshold based on the number of agents changed (added + removed). This avoids any ambiguity or need for subjective judgment by nefario:

- **Minor**: 1-2 agents changed (sum of additions and removals)
- **Substantial**: 3+ agents changed

This threshold applies independently at each gate. At the Team Approval Gate, it counts specialist additions and removals. At the Reviewer Approval Gate, it counts discretionary reviewer additions and removals within the 6-member pool.

The threshold should be stated as a literal number in SKILL.md, not abstracted behind a variable or configuration. Hardcoded thresholds are easier to reason about when reading the spec and eliminate a category of "what does substantial mean?" confusion during orchestration.

**2. Path selection with user override**

Each gate's "Adjust" response handling should follow a three-step flow after the user provides their freeform adjustment:

1. **Classify** the adjustment (minor or substantial) based on the count.
2. **Announce the default path** with a brief explanation, and offer an override.
3. **Execute** the chosen path.

The announcement should be a single informational line, not an additional approval gate. For example, after classifying a substantial team adjustment:

```
Adjustment: +2 added, -2 removed (4 changes). Re-running meta-plan for revised team.
To use the lightweight path instead, reply "lightweight".
```

For minor adjustments:

```
Adjustment: +1 added (1 change). Generating questions for new specialist.
To re-run the full meta-plan instead, reply "re-run".
```

This is a one-line status message followed by a one-line override offer -- not a new gate. If the user says nothing (or says anything that is not the override keyword), the default path executes. The override keyword should be a single word ("lightweight" or "re-run") to keep it quick.

**Critical design point**: The override must be offered as a freeform prompt response, NOT as a new AskUserQuestion gate. The spec says "no additional approval gates introduced." The override is part of the existing adjustment round's interaction, embedded in the freeform exchange that already exists.

**3. Re-run mechanics at the Team Approval Gate**

When a substantial adjustment triggers a meta-plan re-run:

- Nefario is re-spawned with `MODE: META-PLAN` using the same original task description but with an instruction to target the revised specialist list (the user's adjusted team as the starting constraint).
- The re-run writes its output to the same scratch file (`phase1-metaplan.md`), overwriting the original. This avoids stale artifacts.
- The re-run produces planning questions for ALL specialists in the revised team, not just the newly added ones. This is the whole point: substantial changes mean the planning questions should be re-evaluated as a set, because removing agent X or adding agent Y may change what question agent Z should answer.
- After the re-run completes, the Team Approval Gate is re-presented with the new team and updated meta-plan link. This is NOT a new gate; it is the same gate re-presented (same as the current "re-present the gate" step 4 in the existing flow).

**4. Re-run mechanics at the Reviewer Approval Gate**

When a substantial adjustment triggers reviewer re-identification:

- Nefario re-evaluates all 6 discretionary pool members against the delegation plan, producing fresh rationales for the revised set. This is a nefario-internal operation (not a subagent spawn) -- it is the same evaluation logic described in the "Identify Reviewers" section (lines 609-633), just re-executed with the user's adjustments as constraints.
- The re-identification writes updated rationales to the same scratch location.
- The Reviewer Approval Gate is re-presented with the updated discretionary picks.
- The mandatory reviewer set is never affected by adjustments (it is explicitly not user-adjustable per line 611).

**5. Adjustment cap interaction**

A re-run should count as the same adjustment round that triggered it, NOT as a separate round. The user said "adjust" once; the system chose to re-run internally as part of processing that adjustment. The 2-round cap counts user-initiated adjustment requests, not internal processing steps.

Concretely:
- Round 1: User selects "Adjust team" -> provides changes -> system classifies as substantial -> re-runs meta-plan -> re-presents gate. This is round 1.
- Round 2: User selects "Adjust team" again -> provides more changes -> processed (lightweight or re-run) -> re-presents gate. This is round 2.
- Round 3 attempt: Cap reached. Approve/Reject only.

This is consistent with the user's mental model: they asked to adjust twice, so they used two rounds. The fact that the system did more work internally is an implementation detail.

**6. Error messaging for the override path**

When the user invokes an override, confirm it clearly:

```
Override accepted: using lightweight path for 4-agent change.
```

Or:

```
Override accepted: re-running full meta-plan for 1-agent change.
```

One line. No justification or warnings. The user made a deliberate choice; respect it.

**7. Output parity for re-runs**

The success criteria state "re-runs produce output with the same depth as the original phase." This means:

- A meta-plan re-run at the Team gate must produce the same structured format as the original Phase 1 output (planning questions, cross-cutting checklist, exclusion rationale).
- A reviewer re-identification at the Reviewer gate must produce the same per-reviewer rationale format as the original Phase 3.5 identification.

The SKILL.md changes should not need to redefine these output formats -- they already exist. The re-run instructions should reference the existing format requirements, not duplicate them.

### Proposed Tasks

**Task 1: Restructure "Adjust team" response handling in SKILL.md (lines 428-445)**

Replace the current step 3 ("For added agents, nefario generates planning questions (lightweight inference from task context, not a full re-plan)") with a branching flow:

- Step 3a: Count total changes (additions + removals).
- Step 3b: If minor (1-2 changes): use lightweight path (current behavior -- generate questions for added agents only). Announce path and offer "re-run" override.
- Step 3c: If substantial (3+ changes): re-run meta-plan with `MODE: META-PLAN` targeting the revised team. Announce path and offer "lightweight" override.
- Step 3d: On override keyword, switch to the other path.
- Step 4 remains: re-present the gate with the updated team.

Deliverable: Updated "Adjust team" response handling section in SKILL.md.

Dependencies: None. This is a spec change to SKILL.md only.

**Task 2: Restructure "Adjust reviewers" response handling in SKILL.md (lines 693-697)**

Expand the current terse handling into a parallel branching flow:

- Step 1: Parse adjustment against the 6-member discretionary pool (existing behavior).
- Step 2: Count total changes (additions + removals within the pool).
- Step 3a: If minor (1-2 changes): apply changes directly, keep existing rationales for unchanged reviewers. Announce path and offer "re-run" override.
- Step 3b: If substantial (3+ changes): re-run reviewer identification (re-evaluate all 6 pool members against the delegation plan with fresh rationales). Announce path and offer "lightweight" override.
- Step 3c: On override keyword, switch to the other path.
- Step 4: Re-present the Reviewer Approval Gate with updated discretionary picks.
- Preserve the 2-round cap and apply the same "re-run counts as same round" rule.

Deliverable: Updated "Adjust reviewers" response handling section in SKILL.md.

Dependencies: None. This is a spec change to SKILL.md only.

**Task 3: Add adjustment classification rule as a shared definition**

Both gates use the same threshold logic. To avoid duplication and keep the spec DRY, add a shared definition near the top of the approval gate conventions (or as a sidebar definition referenced by both gates):

```
**Adjustment classification**: Count total agent changes (additions + removals).
Minor: 1-2 changes (lightweight path). Substantial: 3+ changes (re-run path).
User can override the default path with "lightweight" or "re-run" keyword.
A re-run counts as the same adjustment round, not an additional round.
```

Deliverable: Shared definition block in SKILL.md, referenced by both gate sections.

Dependencies: Should be written before Tasks 1 and 2 so they can reference it.

### Risks and Concerns

**Risk 1: Re-run latency at the Team Approval Gate.** A meta-plan re-run spawns nefario as a subagent on the opus model. This adds meaningful wall-clock time (likely 30-60 seconds). The user already waited for the original meta-plan and is now in an interactive adjustment flow. The latency could feel disproportionate. Mitigation: The announcement line ("Re-running meta-plan for revised team...") sets expectations. No spinner or progress bar is needed since the Task tool already shows activity. If this proves too slow in practice, the threshold could be raised to 4+ in a future iteration, but 3+ is a reasonable starting point.

**Risk 2: Override keyword collision.** If the user's freeform adjustment text happens to contain the word "lightweight" or "re-run" as part of their agent description, nefario might misinterpret it as an override. Mitigation: The override is offered AFTER the adjustment is classified and announced, in a separate prompt turn. The user's original freeform input (step 1-2) is already processed before the override opportunity appears. The override keyword is only listened for in the response to the announcement, not in the initial freeform input.

**Risk 3: Stale context after meta-plan re-run.** When the meta-plan is re-run at the Team gate, the new meta-plan replaces the old one. But the orchestrator's in-memory context still contains the original meta-plan text from the Phase 1 subagent response. The re-run output is written to the scratch file, but SKILL.md should make clear that the re-presented gate must reference the re-run output, not the original in-context meta-plan. Mitigation: The SKILL.md instructions should explicitly state "read the updated phase1-metaplan.md to populate the re-presented gate."

**Risk 4: Edge case -- removing all specialists.** If the user removes agents such that fewer than 1 specialist remains, the orchestration has no one to consult in Phase 2. The existing flow does not guard against this. This is not new to this change, but a re-run path makes it more likely someone experiments with radical changes. Mitigation: Out of scope for this task (it is an existing gap), but worth noting.

### Additional Agents Needed

None. The current planning team (devx-minion, ux-strategy-minion, ai-modeling-minion, lucy) covers the relevant domains: developer interaction flow design, approval gate UX, nefario prompt engineering, and governance alignment. No additional specialists are needed for this planning phase.
