# Delegation Plan

**Team name**: advisory-flag
**Description**: Add `--advisory` flag to `/nefario` for advisory-only orchestrations

## Conflict Resolution: MODE: ADVISORY-SYNTHESIS vs ADVISORY: true directive

The two primary architects disagreed on the synthesis mechanism:

- **devx-minion** proposed `MODE: ADVISORY-SYNTHESIS` -- a new mode string in the synthesis prompt, replacing the standard `MODE: SYNTHESIS` entirely when advisory is active.
- **ai-modeling-minion** proposed keeping `MODE: SYNTHESIS` and adding an orthogonal `ADVISORY: true` directive. The argument: MODE is a phase selector, ADVISORY is an output-format selector; conflating them muddies the axis.

**Resolution: ADVISORY: true directive (ai-modeling-minion's approach).**

Rationale:
1. MODE currently maps to phases (META-PLAN, SYNTHESIS, PLAN). Advisory does not change which phase runs -- Phase 3 synthesis still runs. It changes what the synthesis produces. This is a genuine orthogonal axis.
2. `ADVISORY: true` composes cleanly with `MODE: PLAN` (advisory without specialist consultation). `MODE: ADVISORY-SYNTHESIS` would require yet another mode for `MODE: ADVISORY-PLAN`. The orthogonal design avoids combinatorial explosion.
3. The AGENT.md already has three modes. Adding a fourth (or fifth for PLAN+ADVISORY) increases cognitive load for a dimension that is better expressed as a boolean modifier.

**Concession to devx-minion**: The negative constraint ("Do NOT produce task prompts...") must be positioned prominently in the synthesis prompt per ai-modeling-minion's prompt engineering recommendation. devx-minion's detailed insertion points and wrap-up specification are adopted wholesale -- only the MODE mechanism changes.

## Conflict Resolution: Phase 1/2 advisory context

- **devx-minion** recommended adding "Advisory Context" blocks to Phase 1 and Phase 2 prompts, telling agents to prioritize analysis over execution tasks.
- **ai-modeling-minion** argued Phase 1 and Phase 2 do not need changes: "Phase 1's purpose is 'who should weigh in' -- identical for advisory and execution. This very orchestration proves the point."

**Resolution: Minimal advisory context in Phase 2 only. No Phase 1 changes.**

Rationale:
1. ai-modeling-minion's evidence is compelling -- we are in an advisory orchestration right now, and Phase 1 ran identically. The meta-plan ("who should help plan") is the same regardless of output mode.
2. Phase 2 benefits from a lightweight advisory note. The current orchestration works without one, but specialists occasionally propose execution-oriented tasks (e.g., "Task 6: Verify build-index.sh") that are irrelevant in advisory context. A brief note helps specialists calibrate their contribution format.
3. The advisory context for Phase 2 is devx-minion's text, trimmed to 3 lines (not the full 7-line block). Shorter is better for a modifier that changes framing, not substance.

## Task Breakdown

### Task 1: Update AGENT.md with advisory directive and synthesis format
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are modifying the nefario agent specification to support advisory-mode synthesis.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md` with three changes:

    **Change 1: Add Advisory Directive to Invocation Modes section**

    After the existing MODE descriptions (after the paragraph about MODE: PLAN, around line 38-40), add:

    ```markdown
    ## Advisory Directive

    When your prompt includes `ADVISORY: true`, you are producing an advisory
    report instead of an execution plan. This directive is orthogonal to MODE --
    it modifies the output format of SYNTHESIS and PLAN modes.

    - `MODE: SYNTHESIS` + `ADVISORY: true` = produce an advisory report (see below)
    - `MODE: META-PLAN` + `ADVISORY: true` = no effect (meta-plan is unchanged)
    - `MODE: PLAN` + `ADVISORY: true` = produce an advisory report directly
    ```

    **Change 2: Add advisory output format to MODE: SYNTHESIS working pattern**

    In the "MODE: SYNTHESIS" section, after the existing delegation plan format closing
    (after "Relevant file paths and codebase context the agent will need", before
    "## Architecture Review (Phase 3.5)"), add:

    ```markdown
    ### Advisory Output (when ADVISORY: true)

    When the prompt includes `ADVISORY: true`, produce an advisory report instead
    of a delegation plan. Do NOT produce task prompts, agent assignments, execution
    order, approval gates, architecture review agent lists, or cross-cutting
    coverage checklists.

    Output format:

    ## Advisory Report

    **Question**: <the original task/question being evaluated>
    **Confidence**: HIGH | MEDIUM | LOW
    **Recommendation**: <1-2 sentence recommendation>

    ### Executive Summary

    <2-3 paragraphs. Answer the question. State the recommendation. Note the
    confidence level and what drives it.>

    ### Team Consensus

    <Areas where all specialists agreed. Numbered list of consensus points.>

    ### Dissenting Views

    <Where specialists disagreed. For each disagreement:>
    - **<Topic>**: <Agent A> recommends X because [reason]. <Agent B> recommends Y
      because [reason]. Resolution: <how nefario resolved it, or "unresolved --
      presented for user judgment">.

    ### Supporting Evidence

    <Key findings organized by domain. One H4 per specialist domain.>

    #### <Domain 1>
    <Findings relevant to the recommendation>

    ### Risks and Caveats

    <What could invalidate the recommendation. Numbered list.>

    ### Next Steps

    <If the recommendation is adopted, what the implementation path looks like.
    This section naturally feeds into a follow-up `/nefario` execution if the user
    decides to proceed.>

    ### Conflict Resolutions

    <Description of conflicts between specialist recommendations and how they were
    resolved. "None." if no conflicts arose.>
    ```

    **Change 3: Add advisory note to MODE: PLAN section**

    Add after the existing MODE: PLAN text:

    ```markdown
    When `ADVISORY: true` is set, MODE: PLAN produces an advisory report directly
    without specialist consultation. The output format is the same advisory report
    format as MODE: SYNTHESIS + ADVISORY.
    ```

    ## What NOT to Do
    - Do not modify any other sections of AGENT.md (delegation table, cross-cutting
      checklist, approval gates, post-execution phases, etc.)
    - Do not add a new MODE: ADVISORY -- advisory is a directive, not a mode
    - Do not change the existing delegation plan format
    - Do not modify `the-plan.md`

    ## Context
    - The advisory directive is orthogonal to MODE (see Conflict Resolution in synthesis)
    - ai-modeling-minion designed this approach; devx-minion's insertion points are adopted
    - SKILL.md changes (Tasks 2-4) depend on AGENT.md defining the format first
    - Current AGENT.md has ~700 lines. These changes add ~60 lines.
    - The advisory report format is based on the exemplar at
      `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`

    ## Deliverables
    - Modified `nefario/AGENT.md` with three changes
    - No new files created

- **Deliverables**: Modified `nefario/AGENT.md` with advisory directive, advisory output format, and MODE: PLAN note
- **Success criteria**: AGENT.md contains `ADVISORY: true` documentation; the advisory report format is defined; MODE axis is unchanged (still META-PLAN, SYNTHESIS, PLAN)

### Task 2: Add flag parsing and advisory context to SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are adding the `--advisory` flag to the nefario skill's argument parsing
    and adding advisory context to phase prompts.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with these changes:

    **Change 1: Update frontmatter argument-hint** (line 9)

    Change:
    ```yaml
    argument-hint: "#<issue> | <task description>"
    ```
    To:
    ```yaml
    argument-hint: "[--advisory] #<issue> | <task description>"
    ```

    **Change 2: Update Arguments declaration** (line 25)

    Change:
    ```
    Arguments: `#<issue> | <task description>`
    ```
    To:
    ```
    Arguments: `[--advisory] #<issue> | <task description>`
    ```

    **Change 3: Add Flag Extraction subsection** after the Arguments declaration
    (line 25) and before the first bullet (line 27). Insert:

    ```markdown
    ### Flag Extraction

    Before parsing the task input, extract flags from the argument string:

    - **`--advisory`**: If present anywhere in the input, remove it from the
      argument string and set `advisory-mode: true` in session context. The
      remaining string (after flag removal and whitespace trimming) is parsed
      normally as `#<issue>` or free text.

    Flag extraction is position-independent: `/nefario --advisory #87`,
    `/nefario #87 --advisory`, and `/nefario --advisory fix the auth flow`
    are all valid. The flag is consumed before issue/text parsing begins.

    If `--advisory` appears inside a `<github-issue>` tag (fetched issue body),
    it is NOT treated as a flag -- the content boundary rule applies. Only
    flags in the top-level argument string are extracted.
    ```

    **Change 4: Add advisory note to Core Rules** (line 20-21 area)

    After the existing two Core Rules lines, add:

    ```markdown
    When `advisory-mode` is active, the workflow comprises Phases 1-3 and Advisory
    Wrap-up. Phases 3.5-8 are not applicable. This is the only defined exception
    to the "full workflow" rule.
    ```

    **Change 5: Add advisory context to Phase 2 specialist prompt**

    In the Phase 2 specialist prompt template (around line 638, after the
    "Additional Agents Needed" instruction), add a conditional block:

    ```markdown
    When `advisory-mode` is active, also include in each specialist's prompt:

        ## Advisory Context
        This is an advisory-only orchestration. Your contribution will feed
        into a team recommendation, not an execution plan. Focus on analysis,
        trade-offs, and recommendations rather than implementation tasks.
    ```

    **Change 6: Add ADV prefix to status lines**

    For each status line write (Phase 1 around line 367, Phase 2 around line 580,
    Phase 3 around line 654), add a conditional note:

    ```markdown
    When `advisory-mode` is active, prefix the phase label with `ADV `:
    - Phase 1: `echo "⚗︎ ADV P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID`
    - Phase 2: `echo "⚗︎ ADV P2 Planning | $summary" > /tmp/nefario-status-$SID`
    - Phase 3: `echo "⚗︎ ADV P3 Synthesis | $summary" > /tmp/nefario-status-$SID`
    ```

    Implement these as a single note near the first status line write (Phase 1)
    rather than repeating at each location. Reference it from subsequent locations
    with "apply advisory prefix per Phase 1 note".

    ## What NOT to Do
    - Do not modify Phase 3 synthesis prompt (that is Task 3)
    - Do not add advisory termination or wrap-up sections (that is Task 3)
    - Do not modify the report template (that is Task 4)
    - Do not add MODE: ADVISORY -- the flag sets `advisory-mode` in session context;
      AGENT.md uses `ADVISORY: true` in the synthesis prompt (different layer)
    - Do not modify `the-plan.md`

    ## Context
    - devx-minion designed this flag parsing approach
    - Position-independent parsing follows principle of least surprise
    - The `<github-issue>` exemption prevents content injection
    - Phase 1 meta-plan prompt does NOT get advisory context (per ai-modeling-minion:
      "who should weigh in" is the same for advisory and execution)
    - Phase 2 advisory context is a brief 3-line note, not a structural change
    - These changes add ~40-50 lines to SKILL.md

    ## Deliverables
    - Modified `skills/nefario/SKILL.md` with flag parsing, core rules update,
      Phase 2 advisory context, and status line prefix

- **Deliverables**: Modified `skills/nefario/SKILL.md` with flag parsing, core rules exception, Phase 2 advisory context, status line ADV prefix
- **Success criteria**: `--advisory` is parsed from arguments; `advisory-mode` is set in session context; specialists receive advisory framing; status lines show ADV prefix

### Task 3: Add advisory synthesis, termination, and wrap-up to SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: yes
- **Gate reason**: This task defines the advisory divergence behavior -- the core behavioral change. It determines how synthesis output differs, what phases are skipped, how reports are generated, and how the session ends. Multiple downstream behaviors depend on getting this right, and it is the hardest-to-reverse change (behavioral specification that the LLM follows).
- **Prompt**: |
    You are adding the advisory-mode behavioral divergence to the nefario skill.
    This is the core change: where the advisory flow separates from normal execution
    and how it terminates.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with these changes:

    **Change 1: Advisory Synthesis variant** -- add after the normal Phase 3 synthesis
    prompt block (after line ~703, after the synthesis prompt closing ```) and before
    "Nefario will return a structured delegation plan."

    ```markdown
    ### Advisory Synthesis (when `advisory-mode` is active)

    When `advisory-mode` is active, replace the standard synthesis prompt above with:

        Task:
          subagent_type: nefario
          description: "Nefario: advisory synthesis"
          model: opus
          prompt: |
            MODE: SYNTHESIS
            ADVISORY: true

            You are synthesizing specialist planning contributions into a
            team recommendation. This is an advisory-only orchestration --
            no code will be written, no branches created, no PRs opened.

            Do NOT produce task prompts, agent assignments, execution order,
            approval gates, or delegation plan structure. Produce an advisory
            report using the advisory output format defined in your AGENT.md.

            ## Original Task
            <insert the user's task>

            ## Specialist Contributions

            Read the following scratch files for full specialist contributions:
            <list each file path: $SCRATCH_DIR/{slug}/phase2-{agent}.md>

            ## Key consensus across specialists:
            <paste the inline summaries collected during Phase 2>

            ## Instructions
            1. Review all specialist contributions
            2. Resolve any conflicts between recommendations
            3. Identify consensus and dissent -- preserve minority positions
            4. Produce an advisory report with executive summary, team consensus,
               dissenting views, supporting evidence, risks, next steps, and
               conflict resolutions
            5. Write your complete advisory synthesis to
               $SCRATCH_DIR/{slug}/phase3-synthesis.md

    The advisory synthesis output goes to the same scratch file path
    (`phase3-synthesis.md`) as a normal synthesis. The content differs
    (advisory report vs. delegation plan) but the file location is consistent.
    ```

    **Change 2: Advisory Termination** -- add after the Compaction Checkpoint
    section (after line ~725, after "Do NOT re-prompt at subsequent boundaries.")
    and before "Update the status file before entering Phase 3.5:":

    ```markdown
    ### Advisory Termination (when `advisory-mode` is active)

    When `advisory-mode` is active, after Phase 3 synthesis completes:

    1. **Skip the compaction checkpoint** -- there is no Phase 4 to preserve
       context for. The session is about to wrap up.

    2. **Skip Phases 3.5 through 8 entirely** -- no architecture review,
       no execution, no code review, no tests, no deployment, no documentation.

    3. **Proceed directly to Advisory Wrap-up** (below).

    Do NOT present the Execution Plan Approval Gate. There is no execution plan.
    Do NOT present the Reviewer Approval Gate. There is no plan to review.
    Do NOT create a branch, make commits (other than the report), or open a PR.
    ```

    **Change 3: Advisory Wrap-up** -- add immediately after the Advisory
    Termination section:

    ```markdown
    ### Advisory Wrap-up

    When `advisory-mode` is active, replace the standard Phases 3.5-8 and
    wrap-up sequence with the following:

    1. **Capture timestamp** -- record current local time as HHMMSS (same
       convention as standard wrap-up step 2).

    2. **Collect working files** -- copy scratch files to companion directory
       (same logic as standard wrap-up step 5, including sanitization).
       Advisory runs produce fewer files (no Phase 3.5+), so the companion
       directory will be smaller.

    3. **Write advisory report** -- write to
       `<REPORT_DIR>/<YYYY-MM-DD>-<HHMMSS>-<slug>.md` using the report
       template with these frontmatter values:

       ```yaml
       mode: advisory
       task-count: 0
       gate-count: 0
       ```

       Follow the advisory-mode conditional rules in `TEMPLATE.md`:
       - Include: Summary, Original Prompt, Key Design Decisions, Phases
         (1-3 narrative; 3.5-8 as "Skipped (advisory-only orchestration)."),
         Agent Contributions (planning only), Team Recommendation, Working Files
       - Omit: Execution, Decisions, Verification, Test Plan

       The **Team Recommendation** section is the advisory deliverable. Populate
       it from the advisory synthesis output (executive summary, consensus,
       dissenting views, recommendations, conditions to revisit).

    4. **Commit report and companion directory** -- if in a git repo,
       auto-commit with message:
       `docs: add nefario advisory report for <slug>`
       Use `--quiet`. Commit to the CURRENT branch (no feature branch creation).

    5. **Clean up** -- remove scratch directory (`rm -rf "$SCRATCH_DIR"`).
       Remove status file:
       `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID`

    6. **Present to user** -- print:
       ```
       Advisory report: <absolute report path>
       Working files: <absolute companion directory path>
       ```
       No PR URL, no branch name, no checkout hint.

    **What advisory wrap-up does NOT do**:
    - No branch creation (`git checkout -b`)
    - No PR creation (`gh pr create`)
    - No PR gate (no AskUserQuestion for PR)
    - No team shutdown (no TeamCreate was done)
    - No post-execution verification summary
    - No existing-PR detection or update

    **If the user requests execution after advisory**: Respond: "Advisory mode is
    complete. To execute, start a new orchestration: `/nefario <task>`." Do not
    convert an advisory session into an execution session mid-stream.
    ```

    ## What NOT to Do
    - Do not modify the normal (non-advisory) synthesis prompt
    - Do not modify Phase 3.5, 4, 5-8 sections -- advisory skips them, does not alter them
    - Do not create a separate wrap-up section far from the divergence point -- keep
      the advisory flow readable top-to-bottom at the divergence location
    - Do not modify `the-plan.md`

    ## Context
    - devx-minion specified the advisory termination and wrap-up behavior
    - ai-modeling-minion specified the `ADVISORY: true` directive approach (not MODE: ADVISORY)
    - The advisory synthesis prompt uses `MODE: SYNTHESIS` + `ADVISORY: true`
    - The advisory report format is defined in AGENT.md (Task 1)
    - The report template conditional rules are defined in TEMPLATE.md (Task 4)
    - The exemplar advisory report at
      `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`
      demonstrates the expected output shape
    - These changes add ~100-120 lines to SKILL.md (~6% growth)
    - The "do not convert advisory to execution" boundary was flagged as a scope
      creep risk by devx-minion -- the firm boundary prevents mid-session mode switching

    ## Deliverables
    - Modified `skills/nefario/SKILL.md` with advisory synthesis prompt, advisory
      termination, and advisory wrap-up sections

- **Deliverables**: Modified `skills/nefario/SKILL.md` with advisory synthesis, termination, and wrap-up sections
- **Success criteria**: Advisory flow diverges at Phase 3 synthesis with `ADVISORY: true`; Phases 3.5-8 are skipped; advisory wrap-up produces report on current branch; mid-session execution conversion is blocked

### Task 4: Update report template for advisory mode
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none (can run in parallel with Tasks 1-3)
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario report template to support advisory-mode reports.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`
    with these changes:

    **Change 1: Add `advisory` to mode field** (around line 236)

    Change:
    ```
    | `mode` | always | `full` (all phases) or `plan` (planning only) |
    ```
    To:
    ```
    | `mode` | always | `full` (all phases), `plan` (planning only), or `advisory` (recommendation only) |
    ```

    **Change 2: Add Team Recommendation section to skeleton**

    In the skeleton (between Agent Contributions and Execution sections, around
    line 126-127), add:

    ```markdown
    ## Team Recommendation

    **{One-line recommendation.}**

    ### Consensus

    | Position | Agents | Strength |
    |----------|--------|----------|
    | {position} | {agents} | {strength assessment} |

    ### When to Revisit

    {Numbered list of concrete trigger conditions under which the recommendation
    should be re-evaluated.}

    ### Strongest Arguments

    **For {adopted position}** (adopted):

    | Argument | Agent |
    |----------|-------|
    | {argument} | {agent} |

    **For {rejected position}** (not adopted, but preserved):

    | Argument | Agent |
    |----------|-------|
    | {argument} | {agent} |
    ```

    Note: The subsections (When to Revisit, Escalation Path, Strongest Arguments)
    are recommended but optional -- different advisory questions produce different
    recommendation shapes. The Consensus table and one-line recommendation are
    always required.

    **Change 3: Add conditional section rules** to the Conditional Section Rules
    table (around line 244-249):

    Add these rows:

    | Section | INCLUDE WHEN | OMIT WHEN |
    |---------|-------------|-----------|
    | Team Recommendation | `mode` = `advisory` | `mode` != `advisory` |
    | Execution | `mode` != `advisory` | `mode` = `advisory` |
    | Verification | `mode` != `advisory` | `mode` = `advisory` |
    | Test Plan | (existing rule) OR `mode` != `advisory` | (existing rule) OR `mode` = `advisory` |
    | Agent Contributions: Architecture Review subsection | Phase 3.5 ran | `mode` = `advisory` or Phase 3.5 skipped |
    | Agent Contributions: Code Review subsection | Phase 5 ran | `mode` = `advisory` or Phase 5 skipped |

    **Change 4: Add advisory formatting note** to the Formatting Rules section
    (around line 265-282):

    ```markdown
    - **Advisory mode Phases**: Phases 1-3 get full narrative. Phases 3.5-8 each
      get a single line: `Skipped (advisory-only orchestration).`
    - **Team Recommendation**: One-line recommendation in bold, followed by
      Consensus table (always required). When to Revisit, Escalation Path, and
      Strongest Arguments subsections are recommended but optional.
    - **Agent Contributions summary**: Use `({N} planning)` not
      `({N} planning, {N} review)` when no review phases ran.
    ```

    **Change 5: Add advisory steps to Report Writing Checklist** (around line 336-357):

    After step 10 (Write Agent Contributions), add:

    ```markdown
    10a. If `mode` = `advisory`: Write Team Recommendation (bold one-line recommendation,
         Consensus table, optional subsections: When to Revisit, Escalation Path,
         Strongest Arguments)
    10b. If `mode` = `advisory`: Skip steps 11-13, 16 (Execution, Decisions,
         Verification, Test Plan)
    ```

    **Change 6: Add advisory note to Incremental Writing section** (around line 328-332):

    ```markdown
    For advisory-mode orchestrations (`mode: advisory`), the report is written once
    at Advisory Wrap-up, not incrementally. Phase 3 is the final phase.
    ```

    ## What NOT to Do
    - Do not create a separate template file for advisory reports -- single template
      with conditionals, per software-docs-minion's strong recommendation
    - Do not bump template version (this is a minor addition to v3, not a structural change)
    - Do not modify the skeleton sections that are shared between modes (Summary,
      Original Prompt, Key Design Decisions, Working Files, etc.)
    - Do not modify `the-plan.md`

    ## Context
    - software-docs-minion analyzed the template section-by-section against the
      exemplar advisory report and recommended single-template with conditionals
    - The exemplar report is at
      `docs/history/nefario-reports/2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`
    - Existing conditional rules (gate-count, external skills) already demonstrate
      the pattern -- advisory adds 4-6 more rows to the same table
    - The Team Recommendation section structure is derived from the exemplar
    - Template stays at v3 -- advisory support is an extension, not a restructure

    ## Deliverables
    - Modified `docs/history/nefario-reports/TEMPLATE.md` with advisory mode support

- **Deliverables**: Modified `docs/history/nefario-reports/TEMPLATE.md` with `mode: advisory`, Team Recommendation section, conditional rules, formatting notes, and checklist updates
- **Success criteria**: Template supports advisory-mode reports with correct conditional inclusion/omission; Team Recommendation section is defined; exemplar report would be valid under new rules

### Task 5: Update SKILL.md description for advisory capability
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 3
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario skill's description to mention advisory capability.

    ## What to Do

    Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`:

    **Change 1: Update the frontmatter description** (lines 3-8)

    Change:
    ```yaml
    description: >
      Orchestrate a team of specialist agents for complex, multi-domain tasks.
      Uses a nine-phase process: nefario creates a meta-plan, specialists
      contribute domain expertise, nefario synthesizes, cross-cutting agents
      review the plan, you execute, then post-execution phases verify code
      quality, run tests, optionally deploy, and update documentation.
    ```
    To:
    ```yaml
    description: >
      Orchestrate a team of specialist agents for complex, multi-domain tasks.
      Uses a nine-phase process: nefario creates a meta-plan, specialists
      contribute domain expertise, nefario synthesizes, cross-cutting agents
      review the plan, you execute, then post-execution phases verify code
      quality, run tests, optionally deploy, and update documentation.
      Use --advisory for recommendation-only mode (phases 1-3, no code changes).
    ```

    **Change 2: Update Overview** (line 118-131)

    After the existing nine-phase list, add:

    ```markdown
    When `--advisory` is passed, only phases 1-3 run. The synthesis produces a
    team recommendation instead of an execution plan. No code is changed, no
    branch is created, no PR is opened. See Advisory Termination below.
    ```

    ## What NOT to Do
    - Do not modify any behavioral sections (those are in Tasks 2-3)
    - Do not modify `the-plan.md`

    ## Deliverables
    - Modified `skills/nefario/SKILL.md` description and overview

- **Deliverables**: Modified `skills/nefario/SKILL.md` description and overview with advisory mention
- **Success criteria**: Users see advisory capability in the skill description and overview

## Cross-Cutting Coverage

- **Testing**: Excluded. This task modifies markdown specification files (SKILL.md, AGENT.md, TEMPLATE.md). There is no executable code to test. The "test" is whether the next advisory orchestration follows the new specification correctly -- which is a manual integration test (run `/nefario --advisory <question>` and verify behavior).
- **Security**: Excluded. No new attack surface, no authentication changes, no user input processing beyond the existing flag parsing pattern. The `<github-issue>` exemption for `--advisory` flags follows the existing content boundary rule.
- **Usability -- Strategy**: Addressed by devx-minion's contribution. The flag parsing design (position-independent, single flag, discoverable via argument-hint) was analyzed for cognitive load, discoverability, and principle of least surprise.
- **Usability -- Design**: Excluded. No UI components produced.
- **Documentation**: Addressed by Task 4 (TEMPLATE.md) and Task 5 (SKILL.md description). software-docs-minion's contribution covers the template changes. No separate user-docs needed -- the argument-hint is the discovery mechanism.
- **Observability**: Excluded. No runtime components. Status line updates (ADV prefix) provide operational visibility during orchestration.

## Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: No -- no UI components produced
  - accessibility-minion: No -- no web-facing HTML/UI
  - sitespeed-minion: No -- no web-facing runtime code
  - observability-minion: No -- no runtime components
  - user-docs-minion: No -- advisory mode is developer-facing tooling; the argument-hint is sufficient discovery; no end-user documentation needed
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

## Conflict Resolutions

1. **MODE: ADVISORY-SYNTHESIS vs ADVISORY: true directive**: Resolved in favor of ai-modeling-minion's orthogonal directive approach. See full resolution above.

2. **Phase 1/2 advisory context**: Resolved with a compromise -- no Phase 1 changes (ai-modeling-minion), lightweight Phase 2 context (trimmed devx-minion). See full resolution above.

3. **Team Recommendation section structure**: No conflict. software-docs-minion's exemplar-derived structure and ai-modeling-minion's seven-section format are compatible. The template uses software-docs-minion's structure (exemplar-proven), while the AGENT.md advisory output format uses ai-modeling-minion's sections (more detailed, suitable for synthesis-time). The template is flexible ("subsections recommended but optional") so both shapes are valid.

## Risks and Mitigations

1. **Core Rules conflict** (MEDIUM) -- The Core Rules say "ALWAYS follow the full workflow." Advisory mode intentionally abbreviates the workflow. **Mitigation**: Task 2 adds an explicit exception to Core Rules: "When `advisory-mode` is active, the workflow comprises Phases 1-3 and Advisory Wrap-up." The exception is narrow and specific.

2. **Scope creep: advisory-to-execution conversion** (MEDIUM) -- Users may want to "continue to execution" after seeing the advisory. **Mitigation**: Task 3 adds a firm boundary: "To execute, start a new orchestration." No mid-session mode switching.

3. **SKILL.md growth** (~8%, ~150-170 lines added) (LOW) -- **Mitigation**: Advisory sections are self-contained and do not interleave with existing logic. They read top-to-bottom at the divergence point.

4. **Advisory report format iteration** (LOW) -- Only two exemplars exist. The format may need refinement after 3-5 more uses. **Mitigation**: The Team Recommendation subsections are documented as "recommended but optional" in the template, providing flexibility without rigidity.

5. **PLAN + ADVISORY interaction** (LOW) -- `MODE: PLAN` + `ADVISORY: true` is documented in AGENT.md but not wired in SKILL.md (no `--plan --advisory` flag combination). **Mitigation**: Document in AGENT.md only. If someone tries natural language "plan mode advisory," nefario will interpret it. Wire the SKILL.md path only when there is demonstrated need.

## Execution Order

```
Batch 1 (parallel):
  Task 1: AGENT.md advisory directive          [devx-minion, sonnet]
  Task 4: TEMPLATE.md advisory mode support    [software-docs-minion, sonnet]

Batch 2 (sequential after Task 1):
  Task 2: SKILL.md flag parsing + context      [devx-minion, sonnet]

Batch 3 (sequential after Task 2):
  Task 3: SKILL.md synthesis + termination + wrap-up  [devx-minion, sonnet]  <<< GATE

Batch 4 (sequential after Task 3):
  Task 5: SKILL.md description update          [devx-minion, sonnet]
```

Gate position: After Task 3, before Task 5. Task 3 is the core behavioral specification. If it needs revision, Task 5 (a minor description update) should not run yet.

## Verification Steps

1. **Structural verification**: After all tasks complete, verify that:
   - AGENT.md contains `ADVISORY: true` documentation and advisory report format
   - SKILL.md contains `--advisory` in argument-hint and Arguments declaration
   - SKILL.md contains Flag Extraction, Advisory Synthesis, Advisory Termination, and Advisory Wrap-up sections
   - SKILL.md Core Rules has the advisory exception
   - TEMPLATE.md has `advisory` in mode field and Team Recommendation section

2. **Consistency verification**: Verify that:
   - AGENT.md advisory report format sections match TEMPLATE.md Team Recommendation fields
   - SKILL.md advisory synthesis prompt references `ADVISORY: true` (not `MODE: ADVISORY`)
   - SKILL.md advisory wrap-up references `mode: advisory` in frontmatter
   - Report naming convention is identical for advisory and execution reports

3. **Integration test** (manual, post-merge): Run `/nefario --advisory <question>` and verify:
   - Flag is parsed and removed from input
   - Phases 1-2 run normally with ADV prefix in status
   - Phase 3 produces advisory report (not delegation plan)
   - Phases 3.5-8 are skipped
   - Report is written to `docs/history/nefario-reports/` with `mode: advisory`
   - No branch creation, no PR
