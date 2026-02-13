## Delegation Plan

**Team name**: add-despicable-statusline-docs
**Description**: Document the /despicable-statusline skill in existing project docs so users know what it does, what it modifies, and when to use it.

### Task 1: Restructure the Status Line section in docs/using-nefario.md

- **Agent**: user-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the "Status Line" section in `docs/using-nefario.md` (lines 166-198) to document the `/despicable-statusline` skill as the primary setup method, while keeping the existing manual approach as a fallback.

    ## What to do

    Rewrite lines 166-198 of `/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md` (the "Status Line" section through the `---` separator before the final link). Replace the current content with a restructured section that follows this outline:

    ### Status Line

    1. **Opening sentence**: Same as current -- you can add a live status line showing the current nefario task during orchestration.

    2. **Setup (automated)**: Lead with the automated skill. One-liner: run `/despicable-statusline`. Note the `jq` prerequisite (already mentioned, keep it). Note this is a project-local skill -- available when Claude Code is running inside the despicable-agents repository. The effect is global (modifies `~/.claude/settings.json`) so you only need to run it once.

    3. **What the skill handles**: Describe the four scenarios from the user's perspective (NOT as "State A/B/C/D"):
       - If you have no statusLine configured, the skill sets up a complete default.
       - If you have a standard statusLine, the skill appends the nefario snippet.
       - If nefario status is already configured, the skill does nothing (safe to re-run).
       - If you have a non-standard setup (e.g., a script file), the skill prints manual instructions instead of modifying your config.

    4. **Safety**: Brief note (2-3 lines, not a full section). The skill validates JSON before and after writing, creates a backup at `~/.claude/settings.json.backup-statusline`, and rolls back on failure. It is idempotent -- safe to run multiple times.

    5. **What It Shows**: Keep the existing subsection content (the example status bar line). Preserve verbatim.

    6. **How It Works**: Keep the existing subsection content. Preserve verbatim.

    7. **Manual setup (fallback)**: Reframe the existing JSON snippet as an alternative for users who prefer manual control or whose config the skill cannot auto-modify. Use a `<details>` block with summary "Manual configuration (alternative)". Inside, include the JSON snippet that is currently at lines 176-183. Add a note: "If the skill's default command changes in the future, the SKILL.md at `.claude/skills/despicable-statusline/SKILL.md` is the authoritative source."

    ## Constraints

    - Do NOT change the `---` separator or the final link line to orchestration.md (line 200-201).
    - Do NOT change any content outside lines 166-198.
    - Do NOT add emojis.
    - Do NOT inline the full shell command outside the manual fallback details block.
    - Restart instruction: keep "Restart Claude Code or start a new conversation to activate" after both automated and manual paths.

    ## File to modify
    `/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md`

    ## Reference
    Read the current SKILL.md at `/Users/ben/github/benpeter/2despicable/3/.claude/skills/despicable-statusline/SKILL.md` to verify details about the skill's behavior, safety measures, and output messages.

- **Deliverables**: Updated `docs/using-nefario.md` with restructured Status Line section
- **Success criteria**: The Status Line section leads with `/despicable-statusline`, describes the four user-perspective outcomes, mentions safety and idempotency, preserves the "What It Shows" and "How It Works" subsections, and moves the manual JSON to a collapsed fallback block.

### Task 2: Add project-local skills to the Skills section in docs/deployment.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the "Skills" section in `docs/deployment.md` to document project-local skills alongside the existing globally-installed skills.

    ## What to do

    Expand the Skills section at lines 106-110 of `/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`. The current section documents only the globally-installed skills (`/nefario`, `/despicable-prompter`). Add a "Project-Local Skills" subsection after the existing content.

    Structure the addition as:

    ### Project-Local Skills

    A brief paragraph explaining:
    - Two project-local skills exist: `/despicable-lab` and `/despicable-statusline`
    - They live in `.claude/skills/` within the repository
    - They are NOT deployed by `install.sh` -- they are available only when Claude Code is running inside the despicable-agents repository
    - Despite being project-local, their effects may be global (e.g., `/despicable-statusline` modifies `~/.claude/settings.json`)

    Then a small table or brief entries for each:

    | Skill | Purpose | Location |
    |-------|---------|----------|
    | `/despicable-lab` | Check and rebuild agents when spec versions diverge | `.claude/skills/despicable-lab/` |
    | `/despicable-statusline` | Configure Claude Code status line for nefario orchestration status | `.claude/skills/despicable-statusline/` |

    For `/despicable-statusline`, add a cross-reference: "See the [Status Line](using-nefario.md#status-line) section in Using Nefario for usage details."

    ## Constraints

    - Do NOT modify the existing paragraph about globally-installed skills (lines 108-110). Add below it.
    - Do NOT change the link to orchestration.md on line 110. Move it after the new subsection if needed so it remains the final line.
    - Do NOT add emojis.
    - Keep the addition concise -- this is a reference entry, not a tutorial.

    ## File to modify
    `/Users/ben/github/benpeter/2despicable/3/docs/deployment.md`

- **Deliverables**: Updated `docs/deployment.md` with project-local skills subsection
- **Success criteria**: The Skills section distinguishes between globally-installed and project-local skills, lists both project-local skills with purpose and location, and cross-references using-nefario.md for statusline usage details.

### Cross-Cutting Coverage

- **Testing**: Not applicable. This task produces only documentation text changes -- no executable code, configuration, or infrastructure.
- **Security**: Not applicable. No attack surface, authentication, user input handling, or dependency changes.
- **Usability -- Strategy**: Not applicable for a separate planning consultation. The user-docs-minion's contribution already incorporated user-perspective framing (outcomes over state machine, scannable safety callout, progressive disclosure via collapsed manual section). The task scope is documenting an existing skill, not designing a new user journey.
- **Usability -- Design**: Not applicable. No UI components or visual interfaces are produced.
- **Documentation**: This IS the documentation task. Both tasks produce documentation directly. software-docs-minion handles the deployment reference; user-docs-minion handles the user-facing guide.
- **Observability**: Not applicable. No runtime components, services, or APIs are created.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none -- this plan produces only text edits to two existing documentation files. No user-facing interfaces, no runtime code, no web-facing output, no multi-service coordination, no user journey changes.
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**README change (user-docs-minion) vs. no README change (software-docs-minion):**

Resolved in favor of software-docs-minion: no README change. The README already lists `/despicable-statusline` in the Structure section (line 13). The install line (line 45) accurately describes what `install.sh` deploys -- globally installed skills only. Adding a sentence about project-local skills to the README would duplicate what deployment.md covers and blur the README's role as a concise introduction. The project-local vs. global distinction belongs in `docs/deployment.md`, which is where Task 2 puts it.

### Risks and Mitigations

1. **Stale manual JSON snippet**: The manual JSON in using-nefario.md could drift from what the skill actually writes. Mitigated by: (a) framing SKILL.md as the authoritative source in the manual fallback section, and (b) collapsing the manual section so it is not the primary path users follow.

2. **Project-local skill discoverability**: Users may try `/despicable-statusline` from other projects and not find it. Mitigated by: both Task 1 and Task 2 explicitly state the skill is project-local and that the effect (status line config) is global -- run it once from the despicable-agents directory.

3. **State D surprise**: Users with non-standard status line configs get manual instructions instead of auto-setup. Mitigated by: Task 1 includes this scenario in the four-outcome description so users know what to expect before running the skill.

### Execution Order

```
Batch 1 (parallel):
  Task 1: Restructure Status Line section (user-docs-minion)
  Task 2: Add project-local skills to deployment.md (software-docs-minion)
```

No gates, no dependencies. Both tasks modify different files and can run simultaneously.

### Verification Steps

1. Read the updated `docs/using-nefario.md` Status Line section and verify it leads with the automated skill, describes all four outcomes, mentions safety/idempotency, preserves "What It Shows" and "How It Works", and has the manual fallback in a collapsed block.
2. Read the updated `docs/deployment.md` Skills section and verify it distinguishes global from project-local skills, lists both project-local skills, and cross-references using-nefario.md.
3. Verify no other files were modified (README, SKILL.md, etc. should be unchanged).
4. Verify the docs render correctly (no broken markdown, no broken links).
