## Domain Plan Contribution: devx-minion

### Recommendations

**1. The prerequisites table is scannable enough -- with one structural adjustment.**

The proposed README prerequisites table (Prompt 2, the inline four-row table) is well-designed for scanning. It has the right columns: Tool, Version, Required For, Install. The "Required For" column is the key differentiator -- it lets a developer who only wants to clone and install immediately see that bash 4+ and jq are only needed for commit hooks, not for the core install. This is the right information architecture.

However, the "Install" column tries to cram two platforms into one cell (`brew install jq` (macOS). `sudo apt install jq` (Ubuntu)). At four rows this is tolerable, but it creates visual noise. I recommend keeping the README table exactly as proposed -- it is borderline but acceptable for four rows -- and letting `docs/prerequisites.md` handle the per-platform details. The table works because it answers the scanning question: "Do I need this thing? What version? How do I get it on my platform in one command?"

**2. The "Quick Setup via Claude Code" prompt should live only in `docs/prerequisites.md`, with a one-line link from the README.**

The advisory's approach is correct: the README links to the prompt rather than embedding it. Reasons:

- The prompt is secondary to the happy path. Most developers will `brew install bash jq` and move on. The Claude Code prompt is a power-user convenience, not the primary install path.
- Embedding the prompt in the README adds vertical length to the install section, pushing the "Using on Other Projects" section further down. Every line between "clone" and "start using" is friction.
- The proposed README sentence ("Or paste the quick setup prompt into Claude Code and it will install what is missing.") is exactly the right level of detail for the README. It signals the option exists without requiring the reader to parse a blockquote they may not need.
- The link destination (`docs/prerequisites.md#quick-setup-via-claude-code`) is a clean anchor. Developers who want it will click; developers who do not will skip.

**3. The happy path (macOS with Homebrew) must remain a two-command experience.**

The current README install flow is:

```
git clone ... && cd ... && ./install.sh
```

This is excellent. The proposed changes add a prerequisites table and a platform disclaimer blockquote before the clone command. The risk is that a macOS developer with Homebrew (the 80% case) now has to scroll past warnings and tables to find the two commands they need.

My recommendation for the README "Install" section ordering:

1. The clone + install.sh commands (unchanged, still the first thing a developer sees)
2. The symlink explanation line (unchanged)
3. A "Prerequisites" subsection with the inline table
4. The "Platform Notes" section (moved to near the bottom, before License)

The key insight: the platform disclaimer blockquote proposed for before the clone command should move to after it, or be integrated into the Prerequisites subsection. The reason: a macOS developer reading the README for the first time should see the clone command first, then discover that they might need to `brew install bash jq`. The blockquote ("Tested on macOS and Linux. Windows is not currently supported...") is important but it is not the first thing the happy-path user needs.

Specifically, I recommend changing the proposed blockquote placement. Instead of:

```
## Install
> **Platform support:** Tested on macOS and Linux. Windows is not currently supported...
Requires Claude Code.
git clone ...
```

Use:

```
## Install
Requires Claude Code.
git clone ...
Symlinks 27 agents...

### Prerequisites
The install script needs only git. The commit workflow hooks need additional tools:
[table]
> **Note:** macOS ships bash 3.2. If you use Homebrew, `brew install bash jq` covers everything.
> Windows is not currently supported -- see [Platform Notes](#platform-notes).
```

This puts the happy path first (clone, install) and the caveats second (prerequisites, platform notes). The blockquote becomes a compact note inside the prerequisites subsection rather than a warning gate before the install command.

**4. The warning-heavy document risk is real and mitigable.**

Adding the platform disclaimer blockquote, the prerequisites table, the Platform Notes section, and linking to `docs/prerequisites.md` adds approximately 25-30 lines to the README. The current README is 143 lines. That is an 18-20% increase, and all of it is in the Install section.

The risk is not the total line count -- it is the density of cautionary language in a single section. Three distinct warning surfaces (blockquote disclaimer, prerequisites table with "macOS ships 3.2" notes, Platform Notes with Windows caveats) create a sense that installation is fragile or complicated, when in reality the happy path is `brew install bash jq && git clone ... && ./install.sh`.

Mitigations:

- **Lead with the happy path.** Clone and install.sh come first. Prerequisites come after.
- **Use a single compact note instead of the proposed blockquote.** The blockquote format (bold "Platform support:") visually reads as a warning banner. A smaller inline note inside the Prerequisites subsection is less alarming.
- **Keep Platform Notes collapsed.** The Platform Notes section has Windows-specific detail that 90%+ of users do not need. Wrap it in a `<details>` tag with a descriptive summary so it does not add visual weight to the page.
- **Tone matters.** "macOS ships bash 3.2 -- run `brew install bash`" is factual and actionable. "Windows is not currently supported" is factual but negative. Reframe as "Tested on macOS and Linux. Windows users: see WSL instructions below." This is a small wording change but it shifts from "you cannot" to "here is how."

### Proposed Tasks

**Task 1: Restructure the README Install section**

What: Reorder the proposed additions so the happy path (clone + install.sh) stays above all prerequisites and platform notes. Move the platform disclaimer from a standalone blockquote before the clone command to an inline note inside the Prerequisites subsection.

Deliverables:
- README.md with Install section in this order: (1) clone + install, (2) symlink explanation, (3) Prerequisites subsection with inline table and compact note, (4) "Using on Other Projects" subsection (unchanged)
- Platform Notes section near the bottom of README, wrapped in `<details>` to reduce visual weight

Dependencies: None. This is a structural decision that shapes all other README edits.

**Task 2: Create `docs/prerequisites.md` with the proposed content**

What: Create the file as specified in the advisory's Prompt 2. The content is well-structured and ready to use. The "Quick Setup via Claude Code" section is the correct home for the paste-able prompt.

Deliverables:
- `docs/prerequisites.md` with Required/Optional tables, per-platform install commands, Claude Code prompt, and verification commands

Dependencies: None (can run in parallel with Task 1).

**Task 3: Add prerequisites row to `docs/architecture.md` sub-documents table**

What: Add the prerequisites row to the User-Facing table as proposed. This is a one-line change.

Deliverables:
- One new row in the User-Facing table in `docs/architecture.md`

Dependencies: Task 2 (the file must exist for the link to be valid, though the edit itself is independent).

**Task 4: Add platform support context to `docs/deployment.md`**

What: Add a brief platform support note to `docs/deployment.md`, near the existing Prerequisites subsection (lines 99-102). The deployment doc already mentions `jq` as a prerequisite. Expand this to include bash 4+ and link to the full prerequisites page.

Deliverables:
- Updated Prerequisites subsection in `docs/deployment.md` with platform context and link to `docs/prerequisites.md`

Dependencies: Task 2.

### Risks and Concerns

1. **The blockquote placement determines first impression.** If the platform disclaimer blockquote appears before the clone command (as proposed in Prompt 1), the first thing a new developer reads in the Install section is a warning about platform limitations. This sets a "caution" tone when the actual experience for 90%+ of users is straightforward. The placement I recommend (inside Prerequisites, after the clone command) preserves an inviting first impression while still being honest about requirements.

2. **The prerequisites table may over-emphasize commit hooks.** Three of four rows in the table (bash, jq, gh) are for commit hooks, not for the core install + agent usage. A developer who just wants to use the agents does not need any of these. The table needs a clear signal that "git" is the only hard requirement and the rest are optional-but-recommended for the full workflow. The proposed "Required For" column handles this, but consider adding a one-line sentence above the table: "The install script needs only `git`. The commit workflow hooks need additional tools:" (this is already in the Prompt 2 copy, which is good).

3. **Platform Notes in `<details>` might be too hidden.** If we collapse the Platform Notes section, Windows users arriving from a search engine may not find the WSL instructions. Mitigation: use a descriptive `<summary>` like "Platform Notes (Windows, stock macOS bash)" so the content is discoverable even when collapsed.

4. **The "Quick Setup via Claude Code" prompt is a novel pattern.** It is genuinely clever -- Claude Code can detect the platform and install missing tools. But it is an unusual onboarding pattern that some developers may find circular ("I need Claude Code to set up the prerequisites for a Claude Code extension"). The framing in `docs/prerequisites.md` should make clear this is a convenience shortcut, not the primary path.

### Additional Agents Needed

None. The current team (software-docs-minion for cross-reference structure, devx-minion for developer journey) covers the needed expertise. The content is ready-to-use from the advisory; this is an integration task, not a content creation task.
