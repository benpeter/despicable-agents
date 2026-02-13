## Delegation Plan

**Team name**: platform-disclaimers-prerequisites-docs
**Description**: Add platform disclaimers, prerequisites documentation, and Claude Code setup prompt across 4 files (README.md, docs/prerequisites.md, docs/deployment.md, docs/architecture.md). Source: GitHub issue #101.

### Conflict Resolutions

Three divergences between specialists, resolved as follows:

1. **Disclaimer placement (before clone vs. after clone)**:
   Advisory places the blockquote before the clone command. devx-minion recommends moving it after the clone, inside a Prerequisites subsection, so the happy path (clone + install) stays first. **Resolution: devx-minion wins.** The reasoning is sound -- 90%+ of users are on macOS with Homebrew, and the clone command should be the first thing they see. The platform disclaimer moves into the Prerequisites subsection as an inline note. This is consistent with the project's "More code, less blah, blah" philosophy.

2. **README prerequisites detail level (full table vs. 3-line summary)**:
   software-docs-minion wants a 3-line summary linking to docs/prerequisites.md. devx-minion accepts the advisory's full inline table. **Resolution: software-docs-minion wins.** The full 4-row table in the README duplicates content from docs/prerequisites.md and adds ~10 lines to the Install section. A condensed summary with a link keeps the README lean and establishes a single source of truth. The Install section should stay compact -- prerequisites detail belongs in the dedicated page.

3. **Platform Notes visibility (visible vs. collapsed)**:
   devx-minion wants `<details>` collapse to reduce visual weight. software-docs-minion says keep visible since it is only 8 lines. **Resolution: keep visible (software-docs-minion wins).** The section is genuinely concise, and collapsing it risks hiding the Windows WSL instructions from users who arrive via search. The `<details>` pattern is already used for the agent roster -- using it for Platform Notes too creates a pattern of "collapsed means optional reading," but platform compatibility is not optional for Windows users.

### Task 1: Create docs/prerequisites.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Create the file `docs/prerequisites.md` in the despicable-agents repository.

    ## Context

    This is a new documentation page listing CLI tool prerequisites for
    installing and using despicable-agents. The content has been pre-approved
    from an advisory audit. Your job is to write the file using the approved
    content with two specific modifications from specialist review.

    ## Base Content

    Use the content from Prompt 2 in the advisory report at
    `docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`
    (lines 175-259). Copy this content as the starting point for
    `docs/prerequisites.md`.

    ## Modifications to Apply

    Two changes from ai-modeling-minion's review:

    1. **Wording change in the Claude Code prompt**: In the "Quick Setup via
       Claude Code" section, change the prompt text from:
       "Check if these tools are installed and install any that are missing:"
       to:
       "Check if these tools are installed and install or upgrade any that are missing or too old:"

    2. **Format change for the Claude Code prompt**: Change the prompt from a
       blockquote (lines prefixed with `>`) to a fenced code block (triple
       backticks with no language tag). This gives users a copy button on
       GitHub and clean select-copy behavior. The prompt is an instruction to
       paste, not a quote -- a code fence is semantically correct and
       practically better for copy-paste UX.

    The resulting "Quick Setup via Claude Code" section should look like:

    ```
    ## Quick Setup via Claude Code

    Already have Claude Code? Paste the following into a Claude Code session and it
    will detect your platform, check what is missing, and install it:

    ```
    Check if these tools are installed and install or upgrade any that are
    missing or too old:
    - git 2.20+
    - jq 1.6+
    - bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
    - gh CLI (optional, for PR creation)
    Then run ./install.sh in this repo to deploy the agents.
    ```
    ```

    ## Verification

    - File starts with `[< Back to Architecture Overview](architecture.md)` breadcrumb (matching all other docs in the directory)
    - Has Required and Optional tool tables
    - Has Install by Platform sections for macOS, Linux (Debian/Ubuntu), Linux (Fedora/RHEL), Windows
    - Has Quick Setup via Claude Code section with fenced code block (not blockquote)
    - Has Verify Your Setup section with version check commands
    - The prompt text says "install or upgrade any that are missing or too old"

    ## Boundaries

    - Do NOT modify any other files
    - Do NOT add content beyond what is in the advisory Prompt 2 (plus the two modifications above)
    - Do NOT change the tool versions or platform-specific install commands
- **Deliverables**: `docs/prerequisites.md`
- **Success criteria**: File exists with correct breadcrumb, tables, per-platform instructions, fenced-code-block Claude Code prompt with updated wording, and verification commands

### Task 2: Update README.md with disclaimer, condensed prerequisites, and Platform Notes
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    Update `README.md` in the despicable-agents repository to add platform
    disclaimers, a condensed prerequisites summary, and a Platform Notes section.

    ## Context

    The advisory audit produced ready-to-use copy in
    `docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`.
    The specialist team resolved three structural decisions:
    - The platform disclaimer goes INSIDE a Prerequisites subsection (after
      the clone command), not before the clone command as a standalone blockquote
    - The README gets a condensed 3-line prerequisites summary, not the full
      table -- the full table lives in docs/prerequisites.md
    - Platform Notes stays visible (no `<details>` collapse)

    ## Changes to Make

    **Change 1: Add a Prerequisites subsection after the symlink explanation line.**

    Currently lines 52-61 of README.md read:

    ```markdown
    ## Install

    Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

    ```bash
    git clone https://github.com/benpeter/despicable-agents.git
    cd despicable-agents && ./install.sh
    ```

    Symlinks 27 agents and 2 skills (`/nefario`, `/despicable-prompter`) to `~/.claude/`. Available in every Claude Code session. To remove: `./install.sh uninstall`.
    ```

    After the "Symlinks 27 agents..." line and BEFORE the "### Using on Other
    Projects" subsection, insert:

    ```markdown

    ### Prerequisites

    Tested on macOS and Linux. Windows is not currently supported -- see
    [Platform Notes](#platform-notes).

    The install script needs only `git`. The commit workflow hooks additionally
    need **bash 4+** and **jq** -- see [Prerequisites](docs/prerequisites.md)
    for per-platform install commands, or paste the
    [quick setup prompt](docs/prerequisites.md#quick-setup-via-claude-code) into
    Claude Code.
    ```

    This is 6 lines of content -- concise, links to the full details, and keeps
    the Install section compact. The platform disclaimer is integrated as the
    opening line rather than a separate blockquote.

    **Change 2: Add a Platform Notes section before License.**

    Use the "Platform Notes" content from Prompt 1 of the advisory report
    (lines 153-171 of the advisory). Insert it immediately before the
    "## License" section. The content starts with `## Platform Notes` and
    covers symlink deployment explanation, Windows options (WSL + Git Bash),
    and the bash 4+ / jq hook requirements.

    Copy the Platform Notes section exactly as written in the advisory Prompt 1.

    ## File Structure After Changes

    The README section order should be:
    1. Title + badges
    2. What You Get
    3. Examples
    4. Install (clone + install.sh + symlink explanation)
    5. **Prerequisites** (NEW - condensed summary with links)
    6. Using on Other Projects
    7. How It Works
    8. Agents
    9. Documentation
    10. Current Limitations
    11. Contributing
    12. **Platform Notes** (NEW - full platform details)
    13. License

    ## Boundaries

    - Do NOT add the full prerequisites table to the README (it lives in docs/prerequisites.md)
    - Do NOT add the Claude Code prompt to the README (it lives in docs/prerequisites.md)
    - Do NOT use a `<details>` collapse for Platform Notes
    - Do NOT modify any content outside the Install section and the new Platform Notes section
    - Do NOT change the "Requires Claude Code" line or the clone command
- **Deliverables**: Updated `README.md` with Prerequisites subsection and Platform Notes section
- **Success criteria**: Prerequisites subsection appears after clone/install, before "Using on Other Projects". Platform Notes section appears before License. No full prerequisites table in README. Links to docs/prerequisites.md resolve correctly.

### Task 3: Update docs/deployment.md prerequisites
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    Update the Prerequisites subsection in `docs/deployment.md` to
    cross-reference the new `docs/prerequisites.md` page.

    ## Context

    The current "Prerequisites" subsection under "Hook Deployment" (lines 99-103)
    reads:

    ```markdown
    ### Prerequisites

    - Hook scripts must have execute permissions: `chmod +x .claude/hooks/*.sh`
    - `jq` must be installed for JSON parsing in hooks
    ```

    A new `docs/prerequisites.md` page has been created as the single source
    of truth for all tool requirements. The deployment.md prerequisites should
    cross-reference it instead of maintaining a separate incomplete list.

    ## Change to Make

    Replace lines 99-103 with:

    ```markdown
    ### Prerequisites

    - Hook scripts must have execute permissions: `chmod +x .claude/hooks/*.sh`
    - Hook scripts require **bash 4+** and **jq** -- see [Prerequisites](prerequisites.md) for per-platform install commands
    - Symlink deployment requires macOS or Linux. See the project README [Platform Notes](../README.md#platform-notes) for Windows workarounds.
    ```

    This preserves the chmod instruction (deployment-specific), adds the bash 4+
    requirement that was previously missing, and links to prerequisites.md for
    install commands. The platform note is a single line pointing to the README
    for full details.

    ## Boundaries

    - Do NOT add a platform support table to deployment.md (that was considered
      and rejected to avoid duplication)
    - Do NOT modify any other sections of deployment.md
    - Do NOT move or restructure the Prerequisites subsection -- it stays under
      Hook Deployment
- **Deliverables**: Updated `docs/deployment.md` with cross-references to prerequisites.md
- **Success criteria**: Prerequisites subsection mentions bash 4+, links to prerequisites.md, includes platform note. No duplicated tool tables.

### Task 4: Update docs/architecture.md sub-documents table
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    Add a row for `docs/prerequisites.md` to the User-Facing sub-documents
    table in `docs/architecture.md`.

    ## Context

    The sub-documents table in `docs/architecture.md` (lines 124-129) currently
    has two User-Facing rows:

    ```markdown
    ### User-Facing

    | Document | Covers |
    |----------|--------|
    | [Using Nefario](using-nefario.md) | Orchestration workflow, phases, when to use `/nefario` vs `@agent`, tips for success |
    | [Agent Catalog](agent-catalog.md) | Per-agent capabilities, model tiers, example invocations, boundaries |
    ```

    ## Change to Make

    Add a new row as the FIRST row in the User-Facing table (before "Using
    Nefario"), since prerequisites logically come first in a reader's journey:

    ```markdown
    | [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
    ```

    The table should become:

    ```markdown
    ### User-Facing

    | Document | Covers |
    |----------|--------|
    | [Prerequisites](prerequisites.md) | Required CLI tools, per-platform installation, setup verification |
    | [Using Nefario](using-nefario.md) | Orchestration workflow, phases, when to use `/nefario` vs `@agent`, tips for success |
    | [Agent Catalog](agent-catalog.md) | Per-agent capabilities, model tiers, example invocations, boundaries |
    ```

    ## Boundaries

    - Do NOT modify the Contributor / Architecture table
    - Do NOT modify any other content in architecture.md
    - This is a single-line addition
- **Deliverables**: Updated `docs/architecture.md` with prerequisites row in User-Facing table
- **Success criteria**: Prerequisites row is first in the User-Facing table. Link path is `prerequisites.md` (relative, matching other links in the table).

### Cross-Cutting Coverage

- **Testing**: Not applicable. All changes are documentation-only (4 Markdown files). No executable code, no configuration changes. Phase 6 will find no tests to run.
- **Security**: Not applicable. No attack surface created, no auth changes, no user input processing, no new dependencies. The Claude Code prompt tells users to install standard CLI tools -- no security concern.
- **Usability -- Strategy**: Covered by devx-minion's planning contribution. The key UX decisions (happy path first, condensed README, link-to-detail pattern) are already incorporated into the task prompts.
- **Usability -- Design**: Not applicable. No user-facing UI components. These are Markdown documentation files rendered by GitHub.
- **Documentation**: This IS the documentation task. software-docs-minion is the executing agent.
- **Observability**: Not applicable. No runtime components, no services, no APIs.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none. All tasks produce Markdown documentation only -- no UI components (ux-design-minion, accessibility-minion not needed), no web-facing runtime code (sitespeed-minion not needed), no runtime components (observability-minion not needed), no user-facing behavior changes (user-docs-minion: the task itself IS documentation, reviewed by software-docs-minion).
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Table duplication drift** (from software-docs-minion): The condensed README summary avoids duplicating the full prerequisites table. Single source of truth is docs/prerequisites.md. Low risk since the README contains no version-specific data to maintain.

2. **Claude Code prompt drift** (from ai-modeling-minion): If tool version requirements change, the prompt in docs/prerequisites.md must be updated alongside the tool tables. Both live on the same page, so proximity makes drift unlikely. Low risk.

3. **Cross-reference link correctness** (from software-docs-minion): Tasks 2-4 create links to docs/prerequisites.md and README anchors. Task 1 must complete first so link targets exist. Sequential dependency handles this.

4. **Circular onboarding perception** (from devx-minion): The Claude Code setup prompt may seem circular ("use Claude Code to set up prerequisites for Claude Code extensions"). The prerequisites.md framing positions it as a convenience shortcut, not the primary path. The manual install commands come first. Low risk.

### Execution Order

```
Batch 1:  Task 1 (create docs/prerequisites.md)
Batch 2:  Task 2, Task 3, Task 4 (all depend on Task 1, can run in parallel)
```

No approval gates. All tasks are documentation, easy to reverse, and based on pre-approved advisory content.

### Verification Steps

After all tasks complete:
1. Verify `docs/prerequisites.md` exists with correct breadcrumb, tables, fenced code block prompt, and verification commands
2. Verify README.md has Prerequisites subsection after clone/install and Platform Notes before License
3. Verify `docs/deployment.md` prerequisites subsection links to prerequisites.md and mentions bash 4+
4. Verify `docs/architecture.md` User-Facing table has prerequisites as first row
5. Verify all cross-reference links resolve: README -> docs/prerequisites.md, README -> #platform-notes anchor, deployment.md -> prerequisites.md, architecture.md -> prerequisites.md
6. Verify no full prerequisites table appears in README (condensed summary only)
