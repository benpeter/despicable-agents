## Domain Plan Contribution: user-docs-minion

### Recommendations

**Answer the planning question: level of detail and presentation approach**

The documentation should use **higher-level descriptions with one concrete before/after example**, not exhaustive JSON samples for all four states. Rationale:

1. **Target audience is developers** who already installed the toolkit. They do not need to understand the internal branching logic of the skill -- they need to know what it does, when to run it, and what to expect. The four config states are implementation details; the user experience is "run the skill, it handles your situation."

2. **Present the four states as outcome descriptions, not as a state machine.** Users do not think "I am in State B." They think "I already have a custom statusLine" or "I have never configured this." Frame the behavior from the user's perspective:
   - "If you have no statusLine configured, the skill sets up a complete default."
   - "If you have a standard statusLine, the skill appends the nefario snippet."
   - "If nefario status is already configured, the skill does nothing (safe to re-run)."
   - "If you have a non-standard setup (e.g., a script file), the skill prints manual instructions instead of modifying your config."

3. **One before/after example is sufficient.** Show the most common case (State A -- fresh setup) with a brief JSON snippet showing what gets added. This gives users a concrete mental model without overwhelming them with four variations. The manual setup section already exists in `docs/using-nefario.md` with the full JSON -- link to it rather than duplicating.

4. **Safety properties deserve a brief, scannable callout** -- not a detailed walkthrough. Users want to know "is this safe to run?" The answer is: yes, it validates JSON, creates a backup, and rolls back on failure. That is one short paragraph or a bulleted list, not a section.

5. **Reconcile manual vs. automated setup clearly.** The existing "Status Line" section in `docs/using-nefario.md` (lines 166-198) documents manual setup with a JSON snippet. The skill automates this. The docs should present the skill as the primary path ("run `/despicable-statusline`") and reframe the manual section as a reference/fallback for users who want to understand or customize what the skill does. Do not duplicate the full JSON snippet in both places.

**Documentation placement strategy**

- **Primary home:** Expand the existing "Status Line" section in `docs/using-nefario.md`. This is where users already look for status line information. Restructure it to lead with the automated skill, then provide the manual approach as a fallback/reference.
- **README.md:** Add `/despicable-statusline` to the install.sh output description (line 45) and the Structure section (already present on line 13 -- verify accuracy).
- **`docs/deployment.md`:** Add a brief mention in the Skills section (line 106-110) noting that `/despicable-statusline` is a project-local skill (not installed globally by `install.sh`), distinguishing it from the globally-installed skills.
- **No new standalone page.** The skill does not warrant its own documentation page. It is a setup utility, not a workflow tool like `/nefario` or `/despicable-lab`. Embedding it in the existing status line section keeps documentation lean and discoverable.

### Proposed Tasks

**Task 1: Restructure the Status Line section in `docs/using-nefario.md`**

What to do:
- Rewrite lines 166-198 of `docs/using-nefario.md` to lead with the automated approach
- Structure as:
  1. **Quick setup** -- one-line invocation: `/despicable-statusline`
  2. **What it does** -- plain-language description of the four outcomes (user-perspective framing, not state-machine framing), plus safety properties (backup, validation, rollback) as a brief note
  3. **What it shows** -- keep the existing example output line showing the status bar appearance (line 191)
  4. **How it works** -- keep the existing technical explanation (lines 195-197)
  5. **Manual setup** -- reframe the existing JSON snippet as "Manual configuration (alternative)" for users who prefer manual control or hit State D. Link back to the automated skill as the recommended approach.
- Include the `jq` prerequisite (already mentioned on line 172, keep it)

Deliverables: Updated `docs/using-nefario.md` with restructured Status Line section

Dependencies: None

**Task 2: Update README.md install description**

What to do:
- Line 45 says "Installs 27 agents and 2 skills (`/nefario`, `/despicable-prompter`) to `~/.claude/`." This is accurate -- the statusline skill is project-local, not globally installed. Add a sentence noting that project-local skills (`/despicable-lab`, `/despicable-statusline`) are available when working inside the despicable-agents repository.
- Verify the Structure bullet on line 13 is accurate (it already mentions `/despicable-statusline`)

Deliverables: Updated `README.md` with project-local skill mention

Dependencies: None (can run in parallel with Task 1)

**Task 3: Add project-local skills note to `docs/deployment.md`**

What to do:
- In the Skills section (after line 110), add a brief paragraph distinguishing globally-installed skills (`/nefario`, `/despicable-prompter`) from project-local skills (`/despicable-lab`, `/despicable-statusline`). Note that project-local skills are available only when Claude Code is running inside the despicable-agents repo directory.
- For `/despicable-statusline` specifically, note that it modifies `~/.claude/settings.json` (not project files) and link to the status line section in `docs/using-nefario.md`.

Deliverables: Updated `docs/deployment.md` with project-local skills paragraph

Dependencies: None (can run in parallel with Tasks 1 and 2)

### Risks and Concerns

1. **Duplication risk between manual and automated sections.** The manual JSON snippet in `docs/using-nefario.md` and the SKILL.md both contain the full shell command. If the command changes, both must be updated. Mitigation: the docs should reference the skill as the source of truth and present the manual snippet as "what the skill configures" rather than a standalone recipe. A note like "This is the command that `/despicable-statusline` installs" ties them together.

2. **Project-local skill discoverability.** `/despicable-statusline` is only available inside the despicable-agents repo. Users working in other projects will not see it. The docs should state this clearly and explain that the status line, once configured, works in all projects -- only the setup skill is project-local.

3. **State D user experience.** When the skill cannot auto-modify (State D), it prints manual instructions. The docs should prepare users for this possibility so they are not surprised. A brief mention like "If you have a non-standard status line setup, the skill provides manual instructions instead" is sufficient.

4. **The `install.sh` script does not install `/despicable-statusline` globally.** This is intentional (it is a project-local skill), but users who run `./install.sh` and then switch to another project will not find the skill. The docs should make this clear and suggest running `/despicable-statusline` from the despicable-agents project directory before switching to their working project.

### Additional Agents Needed

None. The documentation changes are straightforward text updates to existing files. No code changes, no design decisions, and no architectural concerns that require other specialists. A software-docs-minion review is unnecessary because the target files are user-facing guides, not architecture documentation.
