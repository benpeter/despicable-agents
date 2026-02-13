## Domain Plan Contribution: software-docs-minion

### Recommendations

**Documentation placement: augment existing pages, no new page.**

The `/despicable-statusline` skill does not warrant its own documentation page. It is a small, single-purpose utility (configure one JSON key in one file). Creating a standalone page would violate the project's KISS principle and add navigation overhead for marginal content. Instead, the skill should be documented through targeted additions to three existing locations:

1. **`docs/using-nefario.md` -- "Status Line" section (lines 166-198)**: This is where users currently look for status line information. The existing manual instructions should be replaced with a reference to the automated skill, while preserving the "What It Shows" and "How It Works" explanations. The manual JSON snippet becomes a fallback for State D (custom configurations the skill cannot auto-modify).

2. **`docs/deployment.md` -- "Skills" section (lines 106-110)**: Add `/despicable-statusline` alongside the existing `/nefario` and `/despicable-prompter` entries, noting its project-local nature and that it is NOT deployed by `install.sh`.

3. **Root `README.md`**: No change needed. The README currently says "2 skills (`/nefario`, `/despicable-prompter`)" referring to globally installed skills. `/despicable-statusline` is project-local and should not be listed there -- it would mislead users about what `install.sh` deploys. The distinction between globally installed skills and project-local skills is an important one to keep clean.

**Reconciling manual vs. automated instructions.**

The existing manual "Status Line" section in `using-nefario.md` (lines 166-198) and the automated skill serve the same user goal. The reconciliation strategy is:

- Lead with the automated path: "Run `/despicable-statusline` to configure this automatically."
- Keep the "What It Shows" and "How It Works" subsections unchanged (they explain behavior, not setup).
- Move the manual JSON snippet into a collapsed details block or a brief note, framed as the fallback for users with custom status line configurations (State D). This preserves the information for users who need it without cluttering the primary flow.
- Mention idempotency and safety (backup to `~/.claude/settings.json.backup-statusline`, JSON validation, rollback on failure) since these affect user trust in running the skill.

**What to document about the four config states.**

Users do not need a detailed breakdown of all four states (A, B, C, D). That is implementation detail. What users need to know:

- The skill handles fresh setups (no existing statusLine) and existing configurations automatically.
- If they have a custom/non-standard statusLine, the skill tells them what to do manually (State D).
- It is idempotent -- running it twice is safe.
- It creates a backup before modifying settings.

Frame this as behavior, not as "State A/B/C/D."

### Proposed Tasks

**Task 1: Rewrite the "Status Line" section in `docs/using-nefario.md`**

- What: Replace the current "Status Line" section (lines 166-198) with a revised version that leads with `/despicable-statusline`, keeps the behavioral explanations ("What It Shows", "How It Works"), and moves the manual JSON to a "Manual Setup" fallback note.
- Deliverable: Updated `docs/using-nefario.md` with revised "Status Line" section.
- Dependencies: None.
- Key content to include:
  - One-line invocation: `/despicable-statusline`
  - Prerequisite: `jq` (already mentioned, keep it)
  - What the skill modifies: `~/.claude/settings.json` (only the `statusLine` key)
  - Safety: backup created at `~/.claude/settings.json.backup-statusline`, JSON validation before and after, rollback on failure
  - Idempotency: safe to run multiple times, detects existing nefario snippet and skips
  - Manual fallback for custom configurations (collapsed or brief)
  - Existing "What It Shows" and "How It Works" subsections preserved

**Task 2: Add `/despicable-statusline` to the "Skills" section in `docs/deployment.md`**

- What: Add a paragraph or entry to the Skills section (lines 106-110) that documents `/despicable-statusline` as a project-local skill, distinct from the globally installed skills.
- Deliverable: Updated `docs/deployment.md` with expanded Skills section.
- Dependencies: None.
- Key content to include:
  - Location: `.claude/skills/despicable-statusline/`
  - Not deployed by `install.sh` -- it is project-local and available only when working inside the despicable-agents repository
  - Purpose: one-line description of what it does
  - Cross-reference to `using-nefario.md` "Status Line" section for usage details

### Risks and Concerns

1. **Stale manual instructions**: The biggest risk is the manual JSON snippet in `using-nefario.md` drifting from the actual command the skill writes. If the skill's default command changes, the manual instructions become wrong. Mitigation: frame the manual snippet as "see the SKILL.md for the current command" rather than inlining the full JSON. Or accept the duplication and note that SKILL.md is authoritative.

2. **Project-local vs. global confusion**: Users may try to invoke `/despicable-statusline` from other projects and find it unavailable (since it is project-local, not globally installed). The documentation should be clear that this skill is available only inside the despicable-agents repository. Users who want status line setup for other projects should run it once from the despicable-agents directory (since it modifies `~/.claude/settings.json`, the effect is global even though the skill is project-local).

3. **Architecture.md sub-documents table**: The architecture.md Sub-Documents table does not need updating since no new page is being created. If a new page were created, the table would need a new row. This risk is avoided by the "augment existing pages" strategy.

### Additional Agents Needed

None. The documentation changes are straightforward text edits to two existing files. No API design, security review, or other specialist input is required. The software-docs-minion can handle both tasks independently.
