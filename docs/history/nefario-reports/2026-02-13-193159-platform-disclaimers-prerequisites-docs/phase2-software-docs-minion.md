## Domain Plan Contribution: software-docs-minion

### Recommendations

**1. README structure: the proposed hierarchy is good, with one adjustment.**

The proposed placement order -- disclaimer blockquote after "Install" heading, prerequisites table after install code block, Platform Notes section before License -- creates a correct progressive disclosure flow. A developer scanning top-to-bottom sees: what it does, how to install, what platform you need, how it works, then platform details at the bottom for those who need them.

However, the current "Install" section is elegantly compact (4 lines of content). Adding a blockquote disclaimer, a prerequisites table (7 rows with headers), and a prose link to the Claude Code prompt would roughly quadruple the section's visual weight. This risks burying the "Using on Other Projects" and "How It Works" sections -- which are arguably more important to a new user than a jq version table.

**Recommendation**: Keep the disclaimer blockquote directly after the "Install" heading (good -- it's the first thing someone reads before attempting install). But move the prerequisites table into a `<details>` element or reduce it to a two-line summary with a link. The full table belongs in `docs/prerequisites.md`, not duplicated in the README. The README version should be:

```markdown
### Prerequisites

The install script needs `git`. Commit workflow hooks additionally need **bash 4+** and **jq** -- see [Prerequisites](docs/prerequisites.md) for per-platform install commands, or paste the [quick setup prompt](docs/prerequisites.md#quick-setup-via-claude-code) into Claude Code.
```

This is 3 lines instead of 10, avoids table duplication between README and `docs/prerequisites.md`, and directs readers to the single source of truth. The advisory's full table is excellent content -- it should live in `docs/prerequisites.md` only.

The "Platform Notes" section before License is well-placed. It does not interrupt the main flow (Install -> How It Works -> Agents -> Documentation -> Contributing) but is findable via the anchor link in the disclaimer blockquote.

**2. `docs/prerequisites.md` belongs in the "User-Facing" sub-documents table.**

The sub-documents tables in `docs/architecture.md` serve two audiences:
- **User-Facing**: documents that help people *use* the agents (Using Nefario, Agent Catalog)
- **Contributor / Architecture**: documents that help people *understand or modify* the system internals (Orchestration, Agent Anatomy, Build Pipeline, Deployment, etc.)

Prerequisites is a user-facing concern. A developer installing despicable-agents to use in their project needs to know what tools to install. They do not need to understand the agent build pipeline or symlink deployment model. `docs/deployment.md` is contributor-facing because it explains *how* the deployment mechanism works; `docs/prerequisites.md` is user-facing because it tells you *what to install before you start*.

Place it as the first row in the User-Facing table -- prerequisites logically come before "Using Nefario" and "Agent Catalog" in a reader's journey.

**3. Relating new platform content to existing `deployment.md` prerequisites.**

The existing `deployment.md` has a "Prerequisites" subsection (lines 99-103) under "Hook Deployment" that mentions `chmod +x` and `jq`. The advisory proposes adding a platform support table to `deployment.md` as well. This creates a duplication risk.

**Recommendation**: Refactor `deployment.md` as follows:
- Replace the existing "Prerequisites" subsection (lines 99-103) with a single line that links to the new `docs/prerequisites.md`:
  ```markdown
  ### Prerequisites

  See [Prerequisites](prerequisites.md) for required tools and per-platform install commands. Hook scripts require bash 4+ and jq.
  ```
- Add the platform support table from the advisory at the top of `deployment.md`, after the opening paragraph (line 5), as a "Platform Support" section. This is deployment-specific context (symlink behavior per platform) that belongs here, not in `prerequisites.md`.
- Keep `prerequisites.md` focused on *what to install and how*. Keep `deployment.md` focused on *how deployment works and where*.

This avoids three places listing jq as a dependency (README, deployment.md, prerequisites.md) and instead creates one authoritative source (prerequisites.md) with short cross-references from the others.

**4. Cross-reference links that need updating.**

Beyond the links listed in the advisory (README -> prerequisites.md, README -> Platform Notes anchor, architecture.md sub-documents table), the following also need attention:

- **`docs/deployment.md` line 1**: Already has a `[< Back to Architecture Overview](architecture.md)` breadcrumb. No change needed.
- **`docs/prerequisites.md`**: Needs the same `[< Back to Architecture Overview](architecture.md)` breadcrumb that all other docs use (the advisory copy already includes this -- good).
- **README "Current Limitations" section (line 132)**: The first bullet says "Claude Code dependency. Agents are AGENT.md files consumed by Claude Code's agent loading." This is adjacent to platform concerns. Consider adding a bullet about platform support here, but I recommend against it -- the disclaimer blockquote in the Install section already covers this, and duplicating it in Current Limitations would be redundant. Leave Current Limitations focused on architectural constraints (no subagent nesting, context window), not platform constraints.
- **No other docs reference deployment prerequisites directly.** The `docs/commit-workflow.md` and `docs/commit-workflow-security.md` discuss hooks in detail but do not list prerequisites -- they assume the reader has already set up the environment. This is correct; adding prerequisites to those docs would be duplication.

No cross-references are broken by the proposed changes. The new links are purely additive.

### Proposed Tasks

**Task 1: Create `docs/prerequisites.md`**
- **What**: Create the new file using the advisory's Prompt 2 content as the starting point. This is the single source of truth for all tool requirements.
- **Deliverable**: `docs/prerequisites.md` with required tools table, per-platform install commands, Claude Code quick setup prompt, and verification commands.
- **Dependencies**: None. Can proceed immediately. The Claude Code prompt content is being reviewed by ai-modeling-minion -- if that review produces changes, they can be applied as a follow-up edit to the "Quick Setup via Claude Code" section only.

**Task 2: Update `README.md` with disclaimer, condensed prerequisites, and Platform Notes**
- **What**: Add the disclaimer blockquote after the "Install" heading (Prompt 1 copy). Add a condensed 3-line prerequisites summary (NOT the full table) after the install code block, linking to `docs/prerequisites.md`. Add the "Platform Notes" section before "License" (Prompt 1 copy).
- **Deliverable**: Updated `README.md` with three additions.
- **Dependencies**: Task 1 (the link to `docs/prerequisites.md` must resolve).

**Task 3: Refactor `docs/deployment.md` prerequisites and add platform support context**
- **What**: Replace the existing "Prerequisites" subsection (lines 99-103) with a cross-reference to `docs/prerequisites.md`. Add a brief "Platform Support" note near the top explaining that symlink deployment requires macOS or Linux.
- **Deliverable**: Updated `docs/deployment.md` with no duplicated prerequisites.
- **Dependencies**: Task 1 (cross-reference target must exist).

**Task 4: Update `docs/architecture.md` sub-documents table**
- **What**: Add a row for `docs/prerequisites.md` in the "User-Facing" sub-documents table, positioned as the first row (before "Using Nefario").
- **Deliverable**: Updated `docs/architecture.md`.
- **Dependencies**: Task 1 (the linked file must exist).

### Risks and Concerns

1. **Table duplication between README and prerequisites.md.** The advisory's Prompt 2 proposes a full prerequisites table in the README. If adopted as-is, the same information will exist in two places and inevitably drift. My recommendation is to condense the README version to a summary with a link. If the team prefers the full table in the README, accept the maintenance cost and add a comment in both files noting the duplication.

2. **"Quick Setup via Claude Code" prompt content is under review by ai-modeling-minion.** The prerequisites.md file should be written with a placeholder or the current draft text, with the understanding that ai-modeling-minion's review may produce changes. The section is self-contained (clearly delimited), so swapping the prompt text later is low-risk.

3. **Platform Notes section length in README.** The proposed Platform Notes section includes Windows workaround details (Developer Mode, `MSYS=winsymlinks:nativestrict`). This is useful but niche -- most readers will not need it. Since the project's stance is "Windows is not supported," consider whether this level of detail belongs in the README or only in `docs/prerequisites.md`. I recommend keeping it in the README as proposed -- it is concise (8 lines) and prevents Windows users from opening issues that are already answered.

4. **Breadcrumb consistency.** All existing docs use `[< Back to Architecture Overview](architecture.md)` as their first line. The advisory's `docs/prerequisites.md` draft already includes this. Verify this is preserved in the final version.

### Additional Agents Needed

None. The current team is sufficient:
- **software-docs-minion** (this contribution): document structure, hierarchy, cross-references, duplication avoidance
- **ai-modeling-minion**: reviewing the Claude Code prompt quality (already assigned)
- No other specialists are needed for documentation-only changes to 4 Markdown files
