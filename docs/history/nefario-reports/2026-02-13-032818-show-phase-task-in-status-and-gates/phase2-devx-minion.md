# Domain Plan Contribution: devx-minion

## Recommendations

### (a) Use `header` for phase context, not `question`

The `header` field is the right place for phase context. Rationale:

1. **The header is the first thing scanned.** It functions as a tab or breadcrumb -- the user's eye hits it before reading the question. Embedding phase context here gives instant orientation without requiring the user to parse sentence text.

2. **The question field should remain a decision prompt.** Questions are for "what do I need to decide?" Headers are for "where am I?" Mixing orientation into the question text dilutes both signals.

3. **The 12-character limit is tight but workable.** The key insight: we do not need to encode the full phase number AND the existing header. We need a compact phase prefix that maps unambiguously to the orchestration phase. A single-character or short numeric prefix before the existing header achieves this.

### (b) Format: `P<N>:<Header>` -- compact phase prefix

Recommended format: `P<N> <Header>` where `<N>` is the phase number.

Examples across all 12 gate types:

| Current Header | Phase | Proposed Header | Chars |
|---|---|---|---|
| Team | 1 | `P1 Team` | 7 |
| Review | 3.5 | `P3.5 Review` | 12 |
| Impasse | 3.5 | `P3.5 Impasse` | 13 (over!) |
| Plan | 3.5 | `P3.5 Plan` | 10 |
| Gate | 4 | `P4 Gate` | 7 |
| Post-exec | 4 | `P4 Post-exec` | 13 (over!) |
| Confirm | 4 | `P4 Confirm` | 10 |
| Calibrate | 4 | `P4 Calibrate` | 12 |
| Security | 5 | `P5 Security` | 11 |
| Issue | 5 | `P5 Issue` | 8 |
| PR | wrap-up | `PR` | 2 |
| Existing PR | wrap-up | `Existing PR` | 11 |

**Problem**: Two headers exceed 12 chars (`P3.5 Impasse` = 13, `P4 Post-exec` = 13).

**Solutions** (pick one):

- **Option A -- Abbreviate overflows**: `P3.5 Impasse` -> `P3 Impasse` (drop the `.5` since context makes it unambiguous within the gate), `P4 Post-exec` -> `P4 Post-ex` or just keep `Post-exec` without prefix since it always immediately follows a `P4 Gate` approval. This is the pragmatic choice.

- **Option B -- Use question text for overflow cases only**: For the two overflows, put phase context as the first token in the `question` field instead: `[Phase 3.5] <question text>`. This creates inconsistency but respects the hard limit.

- **Option C -- Drop the `P` prefix entirely, use just the number**: `3.5 Review`, `4 Gate`. Saves one char but is less scannable -- bare numbers at the start of a header look like data, not navigation.

**My recommendation: Option A.** Specifically:
- Use `P3 Impasse` (the `.5` is unnecessary since "Impasse" only occurs in Phase 3.5)
- Keep `Post-exec` without a phase prefix (it is always a follow-up to the immediately preceding `P4 Gate`, so the user has phase context from 2 seconds ago)
- `Confirm` also needs no prefix for the same reason (it follows a `P4 Gate` rejection)

Revised table with Option A:

| Current Header | Proposed Header | Chars |
|---|---|---|
| Team | `P1 Team` | 7 |
| Review | `P3.5 Review` | 12 |
| Impasse | `P3 Impasse` | 11 |
| Plan | `P3.5 Plan` | 10 |
| Gate | `P4 Gate` | 7 |
| Post-exec | `Post-exec` | 9 (unchanged) |
| Confirm | `Confirm` | 7 (unchanged) |
| Calibrate | `P4 Calibrate` | 12 |
| Security | `P5 Security` | 11 |
| Issue | `P5 Issue` | 8 |
| PR | `PR` | 2 (unchanged) |
| Existing PR | `Existing PR` | 11 (unchanged) |

All within 12 chars. No information lost.

### (c) Which gates get phase context: all primary gates, skip follow-ups

**Primary gates** (8 of 12) get the `P<N>` prefix: Team, Review, Impasse, Plan, Gate, Calibrate, Security, Issue.

**Follow-up gates** (4 of 12) do NOT get a prefix: Post-exec, Confirm, Existing PR, PR.

Rationale:
- Follow-up gates are always presented immediately after a primary gate in the same interaction turn. The user just saw the phase context 2-5 seconds ago. Adding a prefix is redundant.
- PR and Existing PR are post-execution wrap-up. They are not numbered phases. Adding a phase number would be misleading -- there is no "Phase 9" in the user's mental model.
- Keeping follow-ups clean preserves the existing brevity.

### Status file: add phase prefix

The `/tmp/nefario-status-$SID` file should be updated at each phase boundary to include the phase prefix. Currently it contains just the task summary (e.g., `Restore phase announcements...`). Change it to:

```
P1: Restore phase announcements...
```

Update pattern at each phase boundary:
```sh
echo "P$N: $summary" > /tmp/nefario-status-$SID
```

This means the status line displays: `dir | model | Context: 45% | P4: Restore phase announcements...`

The phase prefix in the status file serves a different purpose from the gate headers: it provides ambient awareness when the status line IS visible (between gates). Together, the two mechanisms cover both UI states:
- Status line visible -> phase shown in status bar via file
- Status line hidden (during AskUserQuestion) -> phase shown in gate header

### Question text: add task title for mid-execution gates

For Phase 4 `Gate` type specifically, the `question` field currently contains "the DECISION line from the brief." This is about the specific gate decision, not the task. To maintain task orientation during long execution phases with multiple gates, prepend the task title:

```
Task N: <task title> -- <DECISION line>
```

This mirrors what the user sees in the execution plan and provides task-level orientation (which task am I approving?) alongside the phase-level orientation (which phase am I in?) from the header.

Do NOT apply this to other gate types -- their questions are already self-contextualizing.

## Proposed Tasks

### Task 1: Update AskUserQuestion headers in SKILL.md with phase prefixes

**What**: Modify all 8 primary gate definitions in SKILL.md to use `P<N> <Header>` format. Leave 4 follow-up gates unchanged.

**Deliverables**: Updated `skills/nefario/SKILL.md` with revised `header:` values for Team, Review, Impasse, Plan, Gate, Calibrate, Security, Issue gates.

**Dependencies**: None. This is a documentation/spec change.

### Task 2: Add phase boundary status file updates to SKILL.md

**What**: Add instructions in SKILL.md for nefario to update `/tmp/nefario-status-$SID` at each phase boundary (Phases 1-4, and post-execution start) with the format `P<N>: <summary>`. The initial write at orchestration start already exists; this adds phase-specific updates at boundaries.

**Deliverables**: Updated `skills/nefario/SKILL.md` Phase Announcements section with status file update rule.

**Dependencies**: None, but should be in the same task as Task 1 for coherence.

### Task 3: Add task title to Phase 4 Gate question format

**What**: Modify the Gate AskUserQuestion `question` field specification to prepend `Task N: <title> -- ` before the DECISION line.

**Deliverables**: Updated `skills/nefario/SKILL.md` gate question format.

**Dependencies**: Should be part of Task 1 for coherence.

**Recommendation**: Tasks 1-3 are all SKILL.md edits and should be consolidated into a single execution task. They are separated here for planning clarity only.

### Task 4: Update despicable-statusline documentation (if needed)

**What**: If the status file format changes from `<summary>` to `P<N>: <summary>`, verify that the statusline command in `despicable-statusline/SKILL.md` still works correctly. The statusline reads the file content verbatim, so no code change is needed -- but the documentation examples and character budget math should be updated.

**Deliverables**: Reviewed `despicable-statusline/SKILL.md`. Update character budget comment if needed (the `P4: ` prefix adds 4 chars, changing 48 to 44 for the summary, or expand total budget from 60 to 64).

**Dependencies**: Task 2 (status file format change).

## Risks and Concerns

### Risk 1: Header character limit is a hard constraint

The 12-character limit on AskUserQuestion `header` is enforced by Claude Code's UI. If any header exceeds this, it will be truncated or error. The proposed format has been validated against all 12 gates with no overflows, but future gate types must maintain discipline. **Mitigation**: Add a comment in SKILL.md noting the 12-char max and the naming convention.

### Risk 2: Status file character budget squeeze

Adding `P<N>: ` (4-6 chars for phases 1-4, 5 chars for `P3.5:`) to the status file reduces the available space for the task summary. The current budget is 48 chars for summary + 9 chars for "Nefario: " prefix + 3 chars for "..." = 60 chars max. With the phase prefix, the total grows to 64-66 chars or the summary shrinks to 42-44 chars. **Mitigation**: Accept the slightly longer total (the statusline has no hard char limit -- it wraps or truncates at terminal width) or shrink the summary budget by 5 chars.

### Risk 3: Phase 3.5 numbering is unusual

`P3.5` as a prefix works but is unconventional. Users unfamiliar with the orchestration phases might find it odd. **Mitigation**: This is acceptable because the phase announcements (`**--- Phase 3.5: Architecture Review ---**`) already use this numbering. Users will have seen the announcement before encountering the gate.

### Risk 4: Cognitive load during rapid gate sequences

In Phase 4, a user might see `P4 Gate` -> `Post-exec` -> `P4 Gate` -> `Post-exec` repeatedly. The alternation between prefixed and unprefixed headers is intentional (follow-ups are contextually obvious) but could feel inconsistent. **Mitigation**: The follow-up gates are always in the same interaction turn as their parent gate, so the visual pattern is `P4 Gate` (decide) -> `Post-exec` (configure) -> next task. This is a natural pair.

### Risk 5: Interaction with existing phase announcements

The `**--- Phase N: Name ---**` markers from #57 will continue to appear in the chat output. The new `P<N>` prefixes in gate headers use a compatible but shorter notation. Users see both, and they must map consistently. **Mitigation**: Both use the same phase numbers. The full text in phase announcements and the abbreviated `P<N>` in headers form a natural long-form/short-form pair, similar to how CLI tools use `--verbose` / `-v`.

## Additional Agents Needed

**ux-design-minion**: Should validate the `P<N> Header` format against the existing Visual Hierarchy system (Decision weight). The header is part of the Decision-weight pattern and changes to it should be reviewed for visual coherence. They were already included in the meta-plan.

**ux-strategy-minion**: Should validate that the dual-channel approach (status file for ambient awareness, header for gate awareness) creates a coherent user journey without information overload. They were already included in the meta-plan.

No additional agents beyond those already planned are needed.
