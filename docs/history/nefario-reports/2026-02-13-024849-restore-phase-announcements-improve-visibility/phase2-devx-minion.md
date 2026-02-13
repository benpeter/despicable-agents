## Domain Plan Contribution: devx-minion

### Recommendations

**1. Use content-descriptive labels, not filenames**

Raw paths like `$SCRATCH_DIR/{slug}/phase3-synthesis.md` mean nothing to the user
until they mentally decode the naming convention. The label should describe
what the user will find, not what the file is called.

Current patterns in SKILL.md and what they should become:

| Current | Recommended |
|---------|-------------|
| `Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md` | `Details: <path>  (team rationale, planning questions, exclusions)` |
| `Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md` | `Details: <path>  (task prompts, agent assignments, dependencies)` |
| `Full context: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md` | `Details: <path>  (reviewer positions, revision history)` |
| `Working dir: $SCRATCH_DIR/{slug}/` | `Working dir: <path>` (this one is fine -- "working dir" is already a known concept) |
| `FULL PLAN: $SCRATCH_DIR/{slug}/phase3-synthesis.md (task prompts, agent assignments, dependencies)` | Already has a parenthetical description -- good. Normalize the label to `Details:` for consistency. |

The pattern: **`Label: <path>  (content hint)`** where:
- **Label** is a consistent keyword (`Details`, `Working dir`, `Prompt`)
- **Path** is the resolved absolute path (always shown -- essential for `cat`/`open` commands)
- **Content hint** is a parenthetical describing what the user will find (2-6 words)

The content hint is critical. It answers: "Should I bother reading this file?"
without requiring the user to open it.

**2. Always show full resolved paths**

Full paths must always be shown, never abbreviated or elided. Reasons:
- Users copy-paste them into `cat`, `less`, `open`, or editor commands
- The random `mktemp` suffix makes paths unpredictable -- users cannot reconstruct them
- Relative paths are meaningless in a temp directory context
- IDE integrations and terminal emulators can make full paths clickable

This is already specified in the CONDENSE line definition ("The scratch path must be
the ACTUAL resolved path"), but should be stated as a universal rule, not just a
CONDENSE-specific one.

**3. Use a consistent labeling vocabulary across all gates**

Every gate and reference point in the SKILL.md uses slightly different labels for
the same concept (linking to a file for more details):

- `Full meta-plan:` (Team Gate)
- `Full plan:` (Reviewer Gate)
- `FULL PLAN:` (Execution Plan Gate)
- `Full context:` (Impasse Brief)
- `Details:` + `Prompt:` (Advisory references)

This inconsistency forces the user to reparse the meaning of each label. Standardize to:

| Label | When to use |
|-------|-------------|
| `Details:` | Primary "read more" reference for any gate or brief |
| `Prompt:` | Agent input prompt (shown alongside `Details:` only) |
| `Working dir:` | The scratch directory root |

Three labels. No ambiguity. `Details` is the universal "go deeper" signal.

**4. How CLI tools handle working file references -- precedents**

Several CLI tools face the same problem of referencing intermediate/working files:

- **Terraform** (`plan`): Shows a path to the saved plan file with a purpose label:
  `Saved the plan to: /path/to/plan.tfplan`. Label = purpose, not filename convention.
  Also: `To perform exactly these actions, run: terraform apply "/path/to/plan.tfplan"`
  -- gives the user the next command, not just the path.

- **pytest**: Shows full paths to test files on failure, with a content description:
  `FAILED tests/test_auth.py::test_login - AssertionError: expected 200, got 401`.
  The path is always absolute when run from the root. The description is the error, not
  the filename decoded.

- **Git**: `git stash list` shows `stash@{0}: WIP on main: abc1234 commit message`.
  The label (`WIP on main`) describes content. The reference (`stash@{0}`) is the
  identifier. Users never need to know the internal ref path.

- **Docker**: `docker build` outputs `writing image sha256:abc123...` then
  `naming to docker.io/library/myapp:latest`. Label first, reference second.

- **Cargo**: `Compiling myproject v0.1.0 (/path/to/project)` -- parenthetical path
  for context, descriptive text as the primary content.

The pattern across all: **describe the content or purpose first, path second**.
Paths are reference identifiers, not labels. Nefario's gates should follow the same
convention.

**5. Gate references should hint at actionability**

When a gate shows a file reference, the user's mental question is: "Do I need to
read this?" The current `Full meta-plan:` label doesn't answer that. Better labels
create a decision:

- `Details: <path>  (team rationale, planning questions, exclusions)` -- user
  knows this is for deep-dive review of WHY these agents were chosen
- `Details: <path>  (task prompts and dependencies)` -- user knows this is the
  full execution detail if the summary above seems wrong

The parenthetical content hints serve as "table of contents" for the linked file.
They should be present on every `Details:` reference in a gate presentation.

**6. Scratch path in CONDENSE should use the same label vocabulary**

The CONDENSE line currently uses `Scratch:` as its label:
```
Planning: consulting ... | Skills: N discovered | Scratch: /tmp/nefario-scratch-abc/my-slug/
```

This is fine as-is. `Scratch:` maps to `Working dir:` in gate presentations.
Both are established terms in the developer lexicon. No change needed here,
but document the mapping explicitly so the two labels are understood as synonymous.


### Proposed Tasks

1. **Normalize file reference labels in gate presentation formats**
   - Replace `Full meta-plan:`, `Full plan:`, `FULL PLAN:`, `Full context:` with
     the consistent `Details:` label
   - Add parenthetical content hints to every `Details:` reference
   - Ensure every gate format block in SKILL.md uses the standardized vocabulary
   - Deliverable: Updated gate format blocks in SKILL.md
   - Dependencies: None

2. **Add universal path display rule to the Path Resolution section**
   - State once, clearly: "All file references shown to the user must use the
     resolved absolute path. Never abbreviate, elide, or use template variables
     in user-facing output."
   - This already exists implicitly in the CONDENSE spec but should be a universal
     rule in Path Resolution
   - Deliverable: One paragraph added to Path Resolution section
   - Dependencies: None

3. **Standardize advisory file references**
   - The advisory format already uses `Details:` and `Prompt:` -- confirm these
     align with the normalized vocabulary
   - Ensure the advisory format spec uses the same parenthetical content hint
     pattern
   - Deliverable: Minor wording alignment in advisory format spec
   - Dependencies: Task 1 (for consistent vocabulary)


### Risks and Concerns

1. **Label-path visual weight imbalance**: The resolved paths are long
   (`/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-abc123/my-slug/phase3-synthesis.md`).
   On macOS with `$TMPDIR`, paths can be 100+ characters. This can dominate
   the gate presentation visually, making the actual decision content harder to
   scan. Mitigation: place file references on their own line at the bottom of
   each gate block (already the pattern in most cases). Do not attempt to
   shorten paths -- that breaks copy-paste.

2. **Content hint staleness**: If the scratch file structure changes (new files,
   renamed files), the parenthetical content hints in gate formats become stale.
   Mitigation: keep hints generic enough to survive minor structural changes
   (e.g., "team rationale and planning questions" rather than "lines 1-40 of
   metaplan output"). Review hints when scratch structure changes.

3. **Overloading `Details:`**: Using the same label everywhere could reduce its
   signal value -- if everything says `Details:`, users may start ignoring all
   of them. Mitigation: the parenthetical content hints differentiate each
   instance. The label is the pattern; the hint is the information. This is
   the same pattern as HTML `<a>` tags -- the tag is generic, the text is specific.


### Additional Agents Needed

None. The labeling conventions are a developer experience concern within the
SKILL.md communication protocol. No additional domain expertise is required
beyond what is already in the planning team.
