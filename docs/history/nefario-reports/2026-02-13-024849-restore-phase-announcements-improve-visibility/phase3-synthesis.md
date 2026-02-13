## Delegation Plan

**Team name**: restore-visibility
**Description**: Restore phase announcements and improve orchestration message visibility in nefario's SKILL.md and supporting documentation.

### Conflict Resolutions

**1. Tier system: 3-tier vs 4-tier**
- ux-design-minion proposed a 3-tier visual weight system (framed / quoted / inline)
- ux-strategy-minion proposed a 4-tier tier system (ORIENTATION / DECISION / SUPPRESS / CONDENSE)
- **Resolution**: Keep the existing 3 tier names (SHOW / NEVER SHOW / CONDENSE) and add phase announcements to SHOW. Rationale: the existing tier names are already in SKILL.md, CLAUDE.md cross-references, and compaction-strategy.md. Renaming tiers creates documentation churn for no functional gain. The visual weight system (framed / quoted / inline) is an implementation detail within the existing SHOW tier, not a reason to rename tiers. Move "Phase transition announcements" from NEVER SHOW to SHOW. Keep "Post-execution phase transitions" in NEVER SHOW (dark kitchen stays dark).

**2. Phase announcement format: `---` framed vs `--- Phase N: Name ---` inline**
- ux-design-minion: multi-line framed banners with `---` top and bottom borders + bold header
- ux-strategy-minion: single-line `--- Phase N: Name ---` markers
- **Resolution**: Use ux-strategy's single-line format. Rationale: multi-line framed banners would consume 3 lines per phase and compete with approval gates for attention. Phase announcements are orientation signals, not decision points. One line is sufficient. However, use `**` bold on the phase marker to distinguish it from plain text, since `---` on its own line renders as `<hr>` in CommonMark. Format: `**--- Phase N: Name ---**` (bold protects the dashes from hr rendering while keeping it one line).

**3. File reference style: filename-only vs full-path**
- ux-design-minion: show filename only after first mention, use `Details:` label
- ux-strategy-minion: always show full resolved path, use content-descriptive labels
- devx-minion: always show full resolved path, use `Details:` label + parenthetical content hints
- **Resolution**: Always show full resolved path (devx-minion + ux-strategy-minion). Users copy-paste paths; abbreviation breaks that workflow. Use `Details:` as the consistent label (devx-minion) with parenthetical content hints. Rationale: the full path is essential for actionability; the content hint answers "should I read this?"; the consistent label creates a scannable pattern.

**4. Compaction checkpoint visual treatment: blockquote vs current `---` frame**
- ux-design-minion: convert to blockquote (`>`) for softer visual weight
- ux-strategy-minion: reclassify as ORIENTATION tier
- **Resolution**: Keep compaction checkpoints in SHOW (they require user action -- running `/compact` or skipping). Convert from `---` framing to blockquote (`>`) style to visually distinguish from approval gates. Rationale: compaction is advisory/optional; approval gates are mandatory. Different visual treatment prevents confusion. Blockquote renders with left border in Claude Code, creating a softer "aside" feel.

**5. `NEFARIO |` prefix on all gates**
- ux-design-minion: add `NEFARIO |` prefix to all gate headers
- **Resolution**: Do NOT add. The existing ALL-CAPS labels (TEAM:, EXECUTION PLAN:, etc.) already identify nefario orchestration messages. Adding an 11-character prefix to every gate header reduces space for the actual label and adds no information -- there is only one orchestrator speaking. The phase markers use the new format; gates keep their existing labels.

### Task 1: Update SKILL.md Communication Protocol and gate formats

- **Agent**: general-purpose (bypassPermissions)
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are editing `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` to restore phase announcements and improve orchestration message visibility. Make ALL of the following changes in a single pass.

    ## Context

    The Communication Protocol (starting at line 132) controls what nefario shows to users. Phase transition announcements are currently in NEVER SHOW, which destroyed user orientation. This task restores them and improves gate formatting.

    ## Changes to make

    ### 1. Restore phase announcements in Communication Protocol (line 132-175)

    In the **SHOW** list (line 136), add a new bullet after the existing items:
    ```
    - Phase transition announcements (one-line markers at phase boundaries)
    ```

    In the **NEVER SHOW** list (line 147), REMOVE this line:
    ```
    - Phase transition announcements ("Starting Phase 2...")
    ```
    Keep "Post-execution phase transitions" in NEVER SHOW -- the dark kitchen stays silent.

    ### 2. Add phase announcement format specification

    After the Heartbeat line (line 173-174), add a new subsection:

    ```
    ### Phase Announcements

    At each phase boundary, print a single-line marker:

    ```
    **--- Phase N: <Name> ---**
    ```

    Phase markers by phase:
    - Phase 1: `**--- Phase 1: Meta-Plan ---**`
    - Phase 2: `**--- Phase 2: Specialist Planning (<N> agents) ---**`
    - Phase 3: `**--- Phase 3: Synthesis ---**`
    - Phase 3.5: `**--- Phase 3.5: Architecture Review (<N> reviewers) ---**`
    - Phase 4: `**--- Phase 4: Execution (<N> tasks, <N> gates) ---**`
    - Phase 5-8: No individual markers. The existing CONDENSE line (`Verifying: ...`) serves as the combined entry marker for post-execution phases. The dark kitchen pattern is preserved.

    Rules:
    - One line maximum. No multi-line frames.
    - Parenthetical context is optional -- include agent/task/gate counts where they set user expectations.
    - Phase markers appear at the START of each phase, before any other phase output.
    - Do not use "Starting..." or "Entering..." verbs. The marker itself implies transition.
    ```

    ### 3. Normalize file reference labels across all gates

    Apply this pattern to ALL file references in gate presentations:
    - Label: `Details:` (universal "read more" reference)
    - Always show full resolved path
    - Add parenthetical content hint (2-6 words describing what the user will find)

    Specific changes:

    a) **Team Approval Gate** (line 405):
    Change: `Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md`
    To: `Details: $SCRATCH_DIR/{slug}/phase1-metaplan.md  (planning questions, cross-cutting checklist)`

    b) **Reviewer Approval Gate** (line 729):
    Change: `Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md`
    To: `Details: $SCRATCH_DIR/{slug}/phase3-synthesis.md  (task prompts, agent assignments, dependencies)`

    c) **Plan Impasse** (line 970):
    Change: `Full context: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md`
    To: `Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md  (reviewer positions, revision history)`

    d) **Execution Plan Gate -- Working dir** (line 1014):
    Keep as-is: `Working dir: $SCRATCH_DIR/{slug}/` -- "Working dir" is already a known developer concept.

    e) **Execution Plan Gate -- Full plan** (line 1085):
    Change: `FULL PLAN: $SCRATCH_DIR/{slug}/phase3-synthesis.md (task prompts, agent assignments, dependencies)`
    To: `Details: $SCRATCH_DIR/{slug}/phase3-synthesis.md  (task prompts, agent assignments, dependencies)`

    f) **Advisory references** (lines 1057-1058):
    Change:
    ```
    Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
    Prompt: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md
    ```
    To:
    ```
    Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md  (reviewer analysis and recommendations)
    Prompt: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md
    ```
    Keep `Prompt:` as a separate label -- it serves a different purpose from `Details:`.

    ### 4. Add universal path display rule to Path Resolution section

    After the existing Path Resolution intro (line 176-179), before the "Scratch Directory" subsection, add:

    ```
    **Path display rule**: All file references shown to the user must use the
    resolved absolute path. Never abbreviate, elide, or use template variables
    in user-facing output. Users copy-paste these paths into `cat`, `less`, or
    their editor -- shortened or templated paths break that workflow.
    ```

    ### 5. Convert compaction checkpoints to blockquote format

    a) **Phase 3 compaction checkpoint** (lines 651-661):
    Change the entire code block from:
    ```
    ---
    COMPACT: Phase 3 complete. Specialist details are now in the synthesis.

    Run: /compact focus="Preserve: ..."

    After compaction, type `continue` to resume at Phase 3.5 (Architecture Review).

    Skipping is fine if context is short. Risk: auto-compaction in later phases may lose orchestration state.
    ---
    ```
    To:
    ```
    > **COMPACT** -- Phase 3 complete. Specialist details are now in the synthesis.
    >
    > Run: `/compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, scratch directory path. Discard: individual specialist contributions from Phase 2."`
    >
    > After compaction, type `continue` to resume at Phase 3.5.
    > Skipping is fine if context is short.
    ```

    b) **Phase 3.5 compaction checkpoint** (lines 987-996):
    Same pattern. Change from `---` framing to blockquote:
    ```
    > **COMPACT** -- Phase 3.5 complete. Review verdicts are folded into the plan.
    >
    > Run: `/compact focus="Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, scratch directory path. Discard: individual review verdicts, Phase 2 specialist contributions, raw synthesis input."`
    >
    > After compaction, type `continue` to resume at Phase 4.
    > Skipping is fine if context is short.
    ```

    ### 6. Add Visual Hierarchy reference to Communication Protocol

    After the phase announcement subsection (added in change 2), add:

    ```
    ### Visual Hierarchy

    Orchestration messages use three visual weights:

    | Weight | Pattern | Use |
    |--------|---------|-----|
    | **Decision** | `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
    | **Orientation** | `**--- Phase N: Name ---**` | Phase transitions -- glance and continue |
    | **Advisory** | `>` blockquote with bold label | Compaction checkpoints -- optional user action |
    | **Inline** | Plain text, no framing | CONDENSE lines, heartbeats, informational notes |

    Decision blocks are the heaviest: multi-line with structured fields. Orientation is a single bold line. Advisory uses blockquote indentation. Inline flows without interruption. This hierarchy maps to attention demands: the heavier the visual signal, the more attention needed.
    ```

    ## What NOT to change

    - Do not rename the tier labels (SHOW / NEVER SHOW / CONDENSE stay as-is)
    - Do not add `NEFARIO |` prefix to gate headers
    - Do not add `---` top/bottom framing to approval gates (they already have ALL-CAPS headers which are sufficient)
    - Do not change the AskUserQuestion parameters or option labels
    - Do not modify post-execution phase internals (dark kitchen pattern is preserved)
    - Do not change the CONDENSE line formats (they already work well)
    - Do not change the Heartbeat specification

    ## Verification

    After making all changes, read back the Communication Protocol section (lines 132-210 approximately) and verify:
    1. "Phase transition announcements" is in SHOW, not in NEVER SHOW
    2. "Post-execution phase transitions" is still in NEVER SHOW
    3. Phase announcement format is specified with the one-line bold marker pattern
    4. Visual Hierarchy subsection exists
    5. Path display rule exists in Path Resolution
    6. All gate file references use `Details:` label with content hints
    7. Both compaction checkpoints use blockquote format
    8. `Working dir:` label is unchanged

- **Deliverables**: Updated SKILL.md with all six change categories applied
- **Success criteria**: All seven verification items pass. No changes to tier names, gate interaction parameters, dark kitchen pattern, or CONDENSE formats.

### Task 2: Update supporting documentation

- **Agent**: general-purpose (bypassPermissions)
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating three documentation files in `/Users/ben/github/benpeter/2despicable/3/docs/` to reflect changes made to the SKILL.md Communication Protocol. The SKILL.md has already been updated (Task 1 is complete).

    Read the updated SKILL.md Communication Protocol section first:
    `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md` (lines 132-220 approximately)

    Then make these changes:

    ## 1. Update `docs/using-nefario.md` -- "What Happens" section (lines 98-120)

    The phase descriptions need minor wording updates to reflect that phase transitions are now visible:

    a) **Phase 2** (line 104): The phrase "This runs in the background" is now slightly misleading since users will see a phase transition marker. Change to describe that the user sees a brief status line when the phase starts, then waits while specialists work. Keep it concise -- one sentence change, not a rewrite.

    b) **Phases 5-8** (lines 112-118): These currently say "You do not see this unless a problem surfaces." This is still mostly accurate (dark kitchen pattern), but now the entry into post-execution is marked by a CONDENSE status line. No change needed here -- the existing text already covers this implicitly ("After all tasks finish, post-execution verification begins" in Phase 4 description). The dark kitchen behavior is unchanged.

    c) Do NOT add example output snippets or a "What to Expect" section. The user guide describes behavior in prose; example output belongs in SKILL.md (the source of truth for formatting). Adding examples creates a maintenance coupling.

    ## 2. Update `docs/orchestration.md` -- Post-execution description (lines 110-118)

    The current text says "they execute silently." This is still accurate -- post-execution phases ARE silent (dark kitchen). The CONDENSE line at the start is already documented. No change needed unless you find text that contradicts the updated SKILL.md. Read carefully and only change what is actually inaccurate.

    ## 3. Update `docs/compaction-strategy.md` -- Checkpoint presentation (lines 81-98)

    a) Line 83 references "the SHOW category in the communication protocol." This is still accurate -- compaction checkpoints are still in the SHOW tier. No rename happened. However, the checkpoint format changed from `---` delimiters to blockquote (`>`) format. Update the example (lines 85-98) to match the new blockquote format from SKILL.md.

    b) Update the design rationale text (line 100 onward) if it references `---` delimiters specifically. The rationale should describe blockquote formatting instead.

    ## What NOT to change

    - Do not add new sections to any file
    - Do not restructure any file
    - Do not add example output to using-nefario.md
    - Do not change architecture.md, README.md, or CLAUDE.md
    - Keep changes minimal -- only update text that is factually inaccurate given the SKILL.md changes

    ## Verification

    After making changes, read back the modified sections and verify:
    1. using-nefario.md Phase 2 description no longer says "runs in the background" without qualification
    2. compaction-strategy.md example matches the new blockquote format
    3. orchestration.md is consistent with the dark kitchen pattern (no false claims about silence)
    4. No new sections were added to any file

- **Deliverables**: Updated `docs/using-nefario.md`, `docs/compaction-strategy.md`, and potentially `docs/orchestration.md`
- **Success criteria**: All documentation accurately reflects the updated SKILL.md Communication Protocol. No new sections added, no example output added, minimal changes.

### Cross-Cutting Coverage

- **Testing**: Not applicable. All changes are to markdown documentation files. No executable code produced.
- **Security**: Not applicable. No attack surface, authentication, user input processing, or infrastructure changes.
- **Usability -- Strategy**: Addressed. ux-strategy-minion contributed the tier analysis and phase announcement design principles. Their core recommendation (restore phase announcements as one-line orientation markers) is the foundation of Task 1.
- **Usability -- Design**: Addressed. ux-design-minion contributed the visual hierarchy system (framed/quoted/inline weights) and the semantic file reference pattern. Both are incorporated in Task 1.
- **Documentation**: Addressed. software-docs-minion identified the three files needing updates, user-docs-minion scoped the using-nefario.md changes. Task 2 covers all documentation updates.
- **Observability**: Not applicable. No runtime components, services, or APIs affected.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**:
  - ux-strategy-minion: Plan changes user-facing orchestration messaging and phase visibility -- journey coherence review needed (Tasks 1, 2)
  - devx-minion: Plan changes file reference conventions that developers interact with in every gate -- developer workflow validation needed (Task 1)
- **Not selected**: ux-design-minion (visual patterns already incorporated into Task 1 prompt), accessibility-minion (no HTML/UI), sitespeed-minion (no web-facing code), observability-minion (no runtime components), user-docs-minion (documentation scope is captured in Task 2 prompt)

### Risks and Mitigations

1. **`---` rendering as horizontal rule**: The `--- Phase N: Name ---` pattern on its own line would render as `<hr>` in CommonMark. Mitigation: wrapping in `**bold**` prevents hr rendering (`**--- Phase N: Name ---**` is not a valid hr). Verified against CommonMark spec.

2. **Blockquote rendering variance**: If Claude Code does not render `>` with a left border, compaction checkpoints lose visual distinction from plain text. Mitigation: the bold `**COMPACT**` label and the `>` prefix together provide two signals. Even without border rendering, the indentation and bold label create sufficient differentiation.

3. **Content hint staleness**: Parenthetical content hints in gate references could become stale if scratch file contents change. Mitigation: hints are deliberately generic (e.g., "planning questions, cross-cutting checklist" rather than "lines 1-40"). They describe categories, not specific content.

4. **Documentation maintenance coupling**: Documentation updates in Task 2 create ongoing maintenance when SKILL.md changes. Mitigation: Task 2 changes are minimal (wording adjustments, not structural). The using-nefario.md changes avoid adding example output (the main coupling risk identified by user-docs-minion).

5. **Over-restoration**: Risk of phase announcements growing beyond one line in practice. Mitigation: the one-line maximum is stated as a hard rule in the specification. The parenthetical context is marked as optional.

### Execution Order

```
Batch 1: Task 1 (SKILL.md changes)
Batch 2: Task 2 (documentation updates, depends on Task 1)
```

No approval gates during execution. Two sequential tasks. Total: 2 tasks, 0 gates.

### Verification Steps

After all tasks complete:
1. Read SKILL.md Communication Protocol -- confirm phase announcements are in SHOW, not NEVER SHOW
2. Read SKILL.md phase announcement format -- confirm one-line bold marker pattern
3. Read all gate format blocks -- confirm `Details:` label with content hints
4. Read both compaction checkpoints -- confirm blockquote format
5. Read docs/using-nefario.md Phase 2 description -- confirm updated wording
6. Read docs/compaction-strategy.md example -- confirm matches new blockquote format
7. Read docs/orchestration.md -- confirm consistency with dark kitchen pattern
