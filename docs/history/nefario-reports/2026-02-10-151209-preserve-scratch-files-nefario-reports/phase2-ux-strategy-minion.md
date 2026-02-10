## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. Audience Analysis: Two Distinct Jobs-to-be-Done

Preserved scratch files serve two audiences with fundamentally different jobs:

**Audience A -- The PR Reviewer (primary, high frequency)**
Job: "When I'm reviewing a PR, I want to understand the rationale behind decisions, so I can approve with confidence."
This audience reads the report itself. They need the inverted-pyramid summary, decisions, and agent contributions. They do NOT need to drill into every specialist's raw output. Linking every scratch file inline would actively harm this audience by creating visual noise and false obligation ("should I click all these?").

**Audience B -- The Historian/Debugger (secondary, low frequency)**
Job: "When something went wrong or I'm questioning a past decision, I want to trace the full reasoning chain, so I can understand exactly what each agent said and why."
This audience needs access to everything, but only occasionally and with intent. They are performing a forensic investigation, not a casual read.

The design must serve Audience A by default and provide an escape hatch for Audience B.

#### 2. Do NOT Link Every File Individually in the Report Body

Linking each scratch file inline creates several problems:

- **Cognitive overload**: A typical run produces 8-15 scratch files. Listing them all creates a wall of links that competes with actual content. Nielsen's heuristic #8 (aesthetic and minimalist design) -- every irrelevant link diminishes the relevance of important information.
- **False affordance**: Individual links suggest each file is independently worth reading. In practice, most scratch files are only meaningful in aggregate or to resolve a specific question. The links create an implied obligation to click.
- **Maintenance burden**: If scratch file naming conventions change, every inline reference breaks. A single directory link is resilient.
- **Scanning cost**: Krug's first law -- don't make me think. A list of `phase2-devx-minion.md`, `phase2-software-docs-minion.md`, `phase3-synthesis.md` etc. forces readers to parse file naming conventions to understand what they're looking at.

#### 3. Recommended Pattern: Directory Link with Manifest Summary

Add a single section to the report that provides:

1. **One link to the companion directory** (the entire collection)
2. **A compact manifest** (count of files by phase, inside a collapsible block)

This follows the progressive disclosure pattern already established in the report template -- Agent Contributions and Process Detail are already in `<details>` blocks. The scratch files section should use the same pattern.

Proposed section (placed after Process Detail, before Metrics):

```markdown
## Working Files

<details>
<summary>Working files (14 files in scratch/improve-nefario-reporting-visibility/)</summary>

| Phase | Files | Contents |
|-------|-------|----------|
| Meta-plan | 1 | Initial specialist selection |
| Specialist Planning | 4 | devx-minion, software-docs-minion, iac-minion, ux-strategy-minion |
| Synthesis | 1 | Consolidated execution plan |
| Architecture Review | 2 | software-docs-minion (BLOCK), margo (ADVISE) |
| Code Review | 1 | code-review-minion findings |
| Documentation | 1 | Phase 8 checklist |

Full directory: [scratch/improve-nefario-reporting-visibility/](../../../nefario/scratch/improve-nefario-reporting-visibility/)

</details>
```

Key design choices:
- **Collapsible**: Consistent with Agent Contributions and Process Detail. The default collapsed state respects Audience A's scanning behavior.
- **Phase-grouped manifest**: When Audience B expands it, they get orientation (which phases produced files, which agents contributed) without needing to parse filenames.
- **Only non-trivial entries**: APPROVE-only review phases don't generate scratch files, so they don't appear in the manifest. This keeps the table honest -- it shows what's actually there.
- **"Working Files" heading**: Not "Scratch Files" (too internal/technical) or "Artifacts" (too formal/vague). "Working files" communicates clearly that these are intermediate products, not primary deliverables.

#### 4. Naming: "Working Files" over "Scratch Files"

The term "scratch" is developer jargon with connotations of disposability. For a section that exists specifically to preserve and surface these files, the name should signal "retained intermediate work" rather than "throwaway notes." "Working Files" is clearer to both audiences. The directory itself can remain `scratch/` (internal convention), but the user-facing label should be more descriptive.

#### 5. Interaction with Existing Collapsible Sections

The report template currently has two `<details>` blocks:
- Agent Contributions (planning + review summaries)
- Process Detail (phases, verification, timing, outstanding items)

Adding a third collapsible for Working Files fits naturally. The information hierarchy remains:

1. Summary (always visible, most important)
2. Task (always visible, context)
3. Decisions (always visible, key choices)
4. Agent Contributions (collapsed, supporting detail)
5. Execution (always visible, what changed)
6. Process Detail (collapsed, process metadata)
7. **Working Files (collapsed, raw trail)** -- NEW
8. Metrics (always visible, reference data)

This placement puts the working files after all synthesized content, which is correct -- you should only need the raw files after you've exhausted the curated summaries. It follows the inverted pyramid principle already governing the template.

#### 6. Companion Directory Must Be Committed (Not Gitignored)

Currently, `nefario/scratch/*` is gitignored. If the goal is to preserve scratch files alongside reports, the companion directory must be committed to git. There are two options:

- **Option A**: Copy scratch files into the report directory at wrap-up (e.g., `docs/history/nefario-reports/2026-02-10-143322-slug/`). This keeps everything in one place and avoids gitignore conflicts.
- **Option B**: Move scratch files out of the gitignored path into a new committed location.

Option A is strongly preferred from a UX perspective: the working files live next to the report they belong to. One path leads to everything about that run. This is the principle of spatial proximity -- related things should be near each other.

### Proposed Tasks

#### Task 1: Update Report Template with Working Files Section
- **What**: Add the "Working Files" section to `docs/history/nefario-reports/TEMPLATE.md` between Process Detail and Metrics
- **Deliverable**: Updated TEMPLATE.md with the collapsible working files section, including the manifest table format
- **Dependencies**: None (template-only change)

#### Task 2: Add Companion Directory Creation to SKILL.md Wrap-up
- **What**: In the wrap-up sequence of `skills/nefario/SKILL.md`, add a step that copies scratch files from `nefario/scratch/{slug}/` into the companion directory alongside the report (e.g., `docs/history/nefario-reports/{timestamp}-{slug}/`)
- **Deliverable**: Updated SKILL.md with copy step and manifest generation logic
- **Dependencies**: Task 1 (needs the template format to know what manifest to generate)

#### Task 3: Update Report Writing Checklist
- **What**: Add "Generate working files manifest and companion directory" to the report writing checklist in TEMPLATE.md
- **Deliverable**: Updated checklist in TEMPLATE.md
- **Dependencies**: Task 1

### Risks and Concerns

1. **Repository bloat**: Scratch files are currently gitignored for a reason -- they can be large and numerous. Committing them for every run will grow the repository. Mitigation: keep the convention that scratch files are text/markdown only (no binaries), and consider documenting a maximum retention policy (e.g., scratch dirs for the last N runs, or older than 6 months can be pruned).

2. **Relative link fragility**: The link from the report to its companion directory uses a relative path. If reports or companion directories are moved, links break. Mitigation: the naming convention (report and directory share the same stem) makes this self-documenting, and `build-index.sh` could validate links.

3. **False completeness signal**: A manifest listing all files might suggest the working files are a complete record of the run. In practice, APPROVE-only reviewers don't generate scratch files, and compaction may have affected what was written. The manifest should only list files that actually exist, not files that "should" exist.

4. **Over-engineering the manifest**: The manifest table is a convenience, not a necessity. If generating it adds significant complexity to the SKILL.md logic, a simpler alternative (just the directory link with a file count) would serve 90% of the need. Apply YAGNI -- start with the simplest version that provides orientation.

### Additional Agents Needed

None. The current team is sufficient. The devx-minion and software-docs-minion are well-positioned to handle the SKILL.md and TEMPLATE.md changes respectively. If the `build-index.sh` script needs updating to handle companion directories, the devx-minion or iac-minion can cover that.
