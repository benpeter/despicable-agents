# Phase 3: Synthesis -- Alembic Symbol Prefix for Nefario

## Delegation Plan

**Team name**: alembic-nefario-status-prefix
**Description**: Add the alembic symbol as a visual identity prefix to nefario's status line and user-facing orchestration messages.

### Conflict Resolutions

No conflicts between specialists. All three contributions are complementary:

- **devx-minion** provided encoding guidance (text variant for monospace, emoji variant for markdown, literal UTF-8 in bash)
- **ux-strategy-minion** provided placement guidance (Orientation and Decision weight only, not Inline/Advisory)
- **software-docs-minion** provided documentation scope (only `docs/using-nefario.md` line 191 needs updating beyond primary targets)

One clarification was needed: ux-strategy-minion recommended prefixing AskUserQuestion `header` values, but also flagged the 12-character limit as a risk. Given that headers like "P4 Calibrate" are already at 12 characters, adding even a single character would exceed the limit. **Resolution**: Do NOT prefix AskUserQuestion `header` values. The alembic appears on phase markers, gate brief labels, and the status line -- these are sufficient for visual identity without risking header truncation. This aligns with devx-minion's finding that AGENT.md has no output patterns to change (the prefixing is entirely a SKILL.md concern).

Additionally, ux-strategy-minion recommended prefixing gate brief ALL-CAPS labels (TEAM:, EXECUTION PLAN:, APPROVAL GATE:, SECURITY FINDING:, VERIFICATION ISSUE:). **Resolution**: Accept this recommendation. These are Decision-weight outputs and the alembic prefix on the label line reinforces orchestrator identity at the moments that matter most. The prefix is applied to the label line only, not sub-fields.

### Task 1: Update SKILL.md status file writes and phase announcements

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` to add the alembic symbol as a visual identity prefix to nefario's orchestration outputs.

    ## What to Change

    There are four categories of changes, all in SKILL.md:

    ### Category 1: Status file echo commands (text variant)

    Add `⚗︎ ` (U+2697 U+FE0E + space) prefix to all status file writes. Use literal UTF-8 characters in the echo strings -- do NOT use printf or escape sequences.

    Before the first echo command (line 367), add a comment explaining the encoding:
    ```sh
    # Status prefix: ⚗︎ = U+2697 U+FE0E (text variant for monospace alignment)
    ```

    Lines to update (7 echo commands):
    - Line 367: `echo "P1 Meta-Plan | $summary"` -> `echo "⚗︎ P1 Meta-Plan | $summary"`
    - Line 580: `echo "P2 Planning | $summary"` -> `echo "⚗︎ P2 Planning | $summary"`
    - Line 654: `echo "P3 Synthesis | $summary"` -> `echo "⚗︎ P3 Synthesis | $summary"`
    - Line 730: `echo "P3.5 Review | $summary"` -> `echo "⚗︎ P3.5 Review | $summary"`
    - Line 1184: `echo "P4 Execution | $summary"` -> `echo "⚗︎ P4 Execution | $summary"`
    - Line 1314: `echo "P4 Gate | $task_title"` -> `echo "⚗︎ P4 Gate | $task_title"`
    - Line 1331: `echo "P4 Execution | $summary"` -> `echo "⚗︎ P4 Execution | $summary"`

    ### Category 2: Phase announcement markers (emoji variant)

    Update the phase announcement template and all phase marker examples to prepend the alembic emoji. These are markdown-rendered rich text, so use U+2697 U+FE0F (emoji presentation).

    The generic template (line 181):
    - `**--- Phase N: Name ---**` -> `**--- ⚗️ Phase N: Name ---**`

    The specific phase markers (lines 185-189):
    - `**--- Phase 1: Meta-Plan ---**` -> `**--- ⚗️ Phase 1: Meta-Plan ---**`
    - `**--- Phase 2: Specialist Planning (N agents) ---**` -> `**--- ⚗️ Phase 2: Specialist Planning (N agents) ---**`
    - `**--- Phase 3: Synthesis ---**` -> `**--- ⚗️ Phase 3: Synthesis ---**`
    - `**--- Phase 3.5: Architecture Review (N reviewers) ---**` -> `**--- ⚗️ Phase 3.5: Architecture Review (N reviewers) ---**`
    - `**--- Phase 4: Execution (N tasks, N gates) ---**` -> `**--- ⚗️ Phase 4: Execution (N tasks, N gates) ---**`

    Also update the Visual Hierarchy table row (line 210) that shows the Orientation pattern:
    - `**--- Phase N: Name ---**` -> `**--- ⚗️ Phase N: Name ---**`

    ### Category 3: Gate brief ALL-CAPS labels (emoji variant)

    Prepend the alembic emoji to the top-level label of each gate brief format. These are Decision-weight markdown outputs. Apply the prefix to the label line ONLY, not to sub-fields (DECISION, DELIVERABLE, RATIONALE, IMPACT, etc.).

    Gate brief labels to update (5 patterns):
    - Line ~442: `TEAM:` -> `⚗️ TEAM:`
    - Line ~1071: `EXECUTION PLAN:` -> `⚗️ EXECUTION PLAN:`
    - Line ~1286: `APPROVAL GATE:` -> `⚗️ APPROVAL GATE:`
    - Line ~1499: `SECURITY FINDING:` -> `⚗️ SECURITY FINDING:`
    - Line ~1516: `VERIFICATION ISSUE:` -> `⚗️ VERIFICATION ISSUE:`

    ### Category 4: Length budget comment

    Update the length budget note near line 363-364. Current text says `prefix ~16 chars + " | " 3 chars + 40 + 3 = ~62 chars max`. With the alembic prefix (⚗︎ + space = 2 visible columns), update to reflect `~18 prefix + 3 pipe + 40 summary + 3 ellipsis = ~64 chars max`.

    ## What NOT to Change

    - Do NOT modify AskUserQuestion `header` values (P1 Team, P3.5 Review, P3.5 Plan, P4 Gate, P4 Calibrate, P5 Security, P5 Issue, PR, Post-exec, Existing PR, Confirm). They have a 12-character limit and some are already at the boundary.
    - Do NOT add the alembic to CONDENSE lines, heartbeat lines, compaction checkpoints, or informational one-liners. These are Inline/Advisory weight and should remain unprefixed.
    - Do NOT modify the `despicable-statusline` SKILL.md. It reads status file content as-is.
    - Do NOT modify any historical reports or `the-plan.md`.
    - Do NOT change the `chmod 600` line or `SID=...` line.

    ## Encoding Reference

    - **Text variant** (for status file / monospace): `⚗︎` = U+2697 followed by U+FE0E. This is 6 bytes in UTF-8 (e2 9a 97 ef b8 8e). Renders as 1 terminal cell wide.
    - **Emoji variant** (for markdown / rich text): `⚗️` = U+2697 followed by U+FE0F. This is 6 bytes in UTF-8 (e2 9a 97 ef b8 8f). Renders as full-color emoji glyph.
    - Use literal UTF-8 characters throughout. Do NOT use escape sequences or printf.

    ## Risk Mitigation

    The text variant selector U+FE0E is an invisible character that could be stripped during editing. The comment you add before the first echo command documents the encoding so future editors know it is intentional.

    ## Verification

    After making all changes, verify:
    1. All 7 echo commands have the text-variant prefix
    2. All 5 phase marker examples have the emoji-variant prefix
    3. All 5 gate brief labels have the emoji-variant prefix
    4. The length budget comment is updated
    5. No AskUserQuestion headers were modified
    6. No CONDENSE/heartbeat/compaction patterns were modified

- **Deliverables**: Updated `skills/nefario/SKILL.md` with alembic prefix on status writes, phase markers, and gate labels
- **Success criteria**: All 7 echo commands prefixed with text variant; all 5 phase markers prefixed with emoji variant; all 5 gate labels prefixed with emoji variant; length budget updated; no AskUserQuestion headers modified

### Task 2: Update documentation example

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Update the status line example in `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` at line 191 to include the alembic text-variant prefix.

    Current (line 191):
    ```
    `~/my-project | Claude Opus 4 | Context: 12% | P2 Planning | Build MCP server with OAuth...`
    ```

    Updated:
    ```
    `~/my-project | Claude Opus 4 | Context: 12% | ⚗︎ P2 Planning | Build MCP server with OAuth...`
    ```

    The prefix uses the text variant (U+2697 U+FE0E) because this example shows the monospace status line context.

    ## What NOT to Change

    - Do not modify any other content in this file
    - Do not modify any other documentation files

- **Deliverables**: Updated `docs/using-nefario.md` with alembic-prefixed status line example
- **Success criteria**: Line 191 shows the alembic text variant before `P2 Planning`

### Cross-Cutting Coverage

- **Testing**: Not included. This task modifies documentation/configuration files only (SKILL.md instructions and a docs example). There is no executable code to test. The success criteria are verified by visual inspection of the edited files. Terminal rendering verification is explicitly out of scope per the task constraints.
- **Security**: Not included. No attack surface, auth, user input, secrets, or dependencies are introduced. The change is purely visual/cosmetic.
- **Usability -- Strategy**: Covered by Phase 2 consultation with ux-strategy-minion. Their placement recommendations (Orientation and Decision weight only) are fully incorporated into Task 1's prompt.
- **Usability -- Design**: Not included. No UI components, visual layouts, or interaction patterns are produced. The change modifies text prefixes in terminal output and markdown.
- **Documentation**: Covered by Phase 2 consultation with software-docs-minion. Their audit identified `docs/using-nefario.md` as the only additional file needing update, which is Task 2.
- **Observability**: Not included. No runtime components, services, or APIs are created or modified.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none
  - ux-strategy-minion: NOT selected -- already contributed planning guidance in Phase 2; no user-facing workflow changes beyond text prefixing
  - ux-design-minion: NOT selected -- no UI components or visual layouts produced
  - accessibility-minion: NOT selected -- no web-facing HTML/UI produced
  - sitespeed-minion: NOT selected -- no web-facing runtime code produced
  - observability-minion: NOT selected -- no runtime components produced
  - user-docs-minion: NOT selected -- no end-user-facing documentation changes; using-nefario.md is developer-facing
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| U+FE0E variant selector stripped during editing | Medium | Medium -- bare glyph may render as 2-cell width | Inline comment in SKILL.md documents the encoding; literal UTF-8 in echo is the most resilient approach |
| Terminal renders bare U+2697 as 2-cell width (if selector lost) | Low | Low -- minor status line misalignment | Text variant selector explicitly requests 1-cell; all three target terminals support it |
| Claude Code markdown renderer ignores U+FE0F in bold text | Low | Low -- symbol still visible, just monochrome | Acceptable degradation; identity signal preserved |
| AskUserQuestion header limit exceeded | N/A | N/A | Resolved: headers are not prefixed |
| Future symbol creep (other agents wanting symbols) | Low | Low -- precedent set | Task scope explicitly excludes other agents; nefario is the only agent with persistent user-facing output |

### Execution Order

```
Batch 1 (parallel):
  Task 1: Update SKILL.md (devx-minion, sonnet)
  Task 2: Update docs/using-nefario.md (devx-minion, sonnet)

No gates. Both tasks are additive text changes that are easy to reverse.
```

### Verification Steps

After both tasks complete:
1. Verify all 7 status file echo commands in SKILL.md contain the text-variant alembic prefix (⚗︎)
2. Verify all 5 phase marker examples in SKILL.md contain the emoji-variant alembic prefix (⚗️)
3. Verify all 5 gate brief labels in SKILL.md contain the emoji-variant alembic prefix (⚗️)
4. Verify the length budget comment reflects ~64 chars max
5. Verify no AskUserQuestion headers were modified
6. Verify docs/using-nefario.md line 191 shows the text-variant prefix
7. Verify no other files were modified (especially `the-plan.md`, historical reports, despicable-statusline SKILL.md)
