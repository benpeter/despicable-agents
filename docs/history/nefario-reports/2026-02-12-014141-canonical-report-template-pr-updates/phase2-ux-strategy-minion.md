## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. The Canonical Section Order Serves All Three Audiences -- With One Structural Adjustment

I evaluated the prescribed order against the three audience personas using journey mapping:

**PR Reviewer (quick merge decision)**: Reads Summary, scans Files Changed, maybe checks Decisions. Wants to know "what changed, why, and is it safe." The current order front-loads Summary and Original Prompt correctly. However, the prescribed order puts Files Changed deep in the document (after Phases, Agent Contributions, Execution, Decisions, Conflict Resolutions, and Verification). This forces the reviewer to scroll past process documentation they do not care about. This is a significant cognitive load issue.

**Orchestrating User (verifying accomplishment)**: Reads Summary, checks Execution tasks against expectations, reviews gate outcomes. Their journey maps well to the current v2 template order.

**Future Investigator (tracing a decision)**: Reads Decisions and Conflict Resolutions, follows links to Working Files for primary sources. This audience tolerates depth and is served by any ordering as long as sections are discoverable.

**The key insight**: The PR reviewer persona dominates the initial interaction. The report doubles as the PR body, meaning GitHub's PR view is where most people encounter this document first. On GitHub, the PR description renders in a fixed-width box with no table of contents. Anything below the fold requires deliberate scrolling.

**Recommended section order** (adjusted from the prescribed order):

```
1. Frontmatter (YAML)
2. Summary (2-3 sentences -- the "should I care?" signal)
3. Original Prompt (what was asked -- the "what was the intent?" context)
4. Key Design Decisions (why things were done this way)
5. Files Changed (what concretely changed -- high-value for PR reviewers)
6. Phases (narrative -- how the work unfolded)
7. Agent Contributions (collapsible -- planning + review tables)
8. Execution (per-task with gates -- collapsible)
9. Decisions (gate briefs with rationale/rejected -- collapsible if duplicative with Key Design Decisions)
10. Conflict Resolutions (conditional)
11. Verification (code review, tests)
12. External Skills (conditional)
13. Working Files (collapsed <details>)
14. Test Plan (conditional)
15. Post-Nefario Updates (conditional)
16. Metrics (reference data)
```

The critical change: **move Files Changed up to position 5, before process detail**. A PR reviewer's job-to-be-done is "understand scope and risk of this change." Files Changed is the highest-value signal for that job after Summary and Decisions. Burying it after narrative and agent tables fails the satisficing test -- reviewers take the first reasonable option, and if they can see changed files early, they can decide "this is a docs-only change, safe to merge" without reading further.

The rest of the process sections (Phases, Agent Contributions, Execution) should be collapsed in `<details>` blocks. The PR reviewer never needs them. The orchestrating user will expand if curious. The investigator will expand when tracing.

#### 2. Consolidate Decisions and Key Design Decisions Into One Section

The prescribed order has both "Key Design Decisions" and "Decisions (gate briefs with rationale/rejected)" as separate sections. Looking at actual reports, this creates confusion:

- The `2026-02-11-143008` report uses "Key Design Decisions" with numbered bullets
- The `2026-02-10-205010` report uses "Decisions" with `####` sub-headings and full gate briefs
- The `2026-02-10-155502` report uses "Decisions" mixing gate and non-gate decisions

Recommendation: **Use one "Decisions" section**. Gate decisions and non-gate decisions use slightly different formatting (gate decisions add outcome + confidence fields) but belong together. The user's mental model is "what decisions were made" -- not "which of these were at gates." Section 4 should be called "Decisions" and include all decisions, with gate briefs marked as such.

#### 3. Post-Nefario Updates: Use the Appended Section Pattern

The question asks which UX pattern best serves post-nefario updates. There are three options:

**Option A: Appended section (recommended)**
A distinct "Post-Nefario Updates" section at the end of the report/PR body. Each update is a timestamped sub-entry.

**Option B: Inline annotations**
Modifications scattered throughout existing sections (e.g., adding files to Files Changed, updating Verification).

**Option C: Separate document**
A follow-up report linked from the original.

**Analysis against all three audiences:**

| Pattern | PR Reviewer | Orchestrating User | Investigator |
|---------|------------|-------------------|-------------|
| Appended section | Sees a clear "what changed since the original report" delta. Can focus attention there. | Knows the main report reflects the nefario run, addendum reflects manual work. Clean separation of automated vs. human work. | Chronological trail is clear. Can distinguish original decisions from follow-up adjustments. |
| Inline annotations | Cannot distinguish original from amended content. The main report's narrative integrity is undermined -- "was this in the original plan or added later?" | Confusing. Cannot tell what nefario produced vs. what was added afterward. | Terrible. Historical record is corrupted. Decisions that happened post-execution look like they were part of the original plan. |
| Separate document | Must find and read a second document. Fragmentation increases friction. | Workable but adds a lookup step. | Must reconstruct timeline from two documents. |

**The appended section pattern is clearly superior** for several reasons:

1. **Preserves narrative integrity**: The main report tells one coherent story -- the nefario orchestration. Post-nefario work is a different story told in sequence, not an edit to the first story.

2. **Respects the "historical immutability" constraint**: The issue explicitly states existing reports should not be modified. An appended section extends without modifying.

3. **Supports the delta mental model**: A PR reviewer coming to a PR with post-nefario updates has a clear question: "I already reviewed the original PR -- what changed?" The appended section answers exactly this question. This matches how GitHub's own "Files changed since last review" feature works -- delta-first.

4. **Cognitive load is minimal**: One scroll target, one section to read, clear temporal boundary.

**Format recommendation for Post-Nefario Updates:**

```markdown
## Post-Nefario Updates

### Update 1 -- 2026-02-12 14:30

**Context**: Manual fixes after CI failure on branch nefario/foo.

**Changes**:
| File | Change | Reason |
|------|--------|--------|
| src/auth.ts | Fix import path | CI build failure |
| tests/auth.test.ts | Update snapshot | Aligned with fix |

**Summary**: Fixed broken import introduced by Task 2 agent. CI now passes.

---

### Update 2 -- 2026-02-12 16:00

**Context**: Second nefario run addressing review feedback.

...
```

Each update entry follows a consistent micro-template: Context (why), Changes (what), Summary (outcome). The `---` separator provides visual rhythm. Timestamps create chronological ordering.

#### 4. The Update Mechanism Should Be Low-Friction Nudge, Not Automatic

The issue mentions two options: nefario auto-appends on subsequent runs, or a simple command nudges the user. Both have tradeoffs:

- **Auto-append risks**: Nefario may run on the same branch for a completely different purpose. Auto-appending to the original report when the second run addresses a different issue would corrupt the report. Branch identity is not a reliable proxy for "continuation of the same task."

- **Nudge approach**: When nefario detects an existing report on the current branch, it should present a structured choice:
  - "Existing nefario report found on this branch. Append updates to the existing report, or create a separate report?"
  - This respects user agency. The user knows whether this run is a continuation or a separate task.

If the user chooses "append," nefario generates the Post-Nefario Updates section and appends it. If they choose "separate," a new report is created as usual.

For manual (non-nefario) commits, the mechanism should be documentation in the skill file: "If you make manual changes on a nefario branch after the PR is created, add a Post-Nefario Updates section to the report." No automation is needed for the manual case -- it is infrequent enough that a documented convention suffices.

#### 5. Section Naming: "Summary" Not "Executive Summary"

The issue prescribes this and I strongly endorse it. Looking at actual reports:
- v1 reports use "Executive Summary" (`2026-02-09-001`, `2026-02-09-005`)
- v2 reports use "Summary" (`2026-02-10-205010`, `2026-02-10-163605`)
- The `2026-02-11-143008` report uses "Executive Summary" despite being recent
- The `2026-02-11-122254` report uses "Executive Summary"

"Executive Summary" is corporate formalism. "Summary" is direct. In a markdown document read by developers on GitHub, every unnecessary word adds friction. "Summary" passes the "Don't Make Me Think" test.

#### 6. Collapsibility Strategy for PR Body

Given that the report IS the PR body, the collapsibility strategy is critical for the PR reviewer experience. Recommendation:

**Always visible (not collapsible)**:
- Summary
- Original Prompt (short version; long prompts use their own `<details>`)
- Decisions
- Files Changed
- Verification (short summary)
- Post-Nefario Updates

**Always collapsed (`<details>`)**:
- Agent Contributions
- Execution (per-task detail)
- Phases (narrative)
- Working Files
- Metrics
- Test Plan

This creates a "scannable surface" of approximately 30-50 lines visible without expanding anything. A PR reviewer can make a merge decision from this surface alone. Process detail is one click away for the curious.

### Proposed Tasks

**Task 1: Define canonical section order and collapsibility rules in SKILL.md**
- What: Write the explicit report template in SKILL.md with section names, order, content guidance, conditional inclusion rules, and collapsibility (`<details>` vs always-visible)
- Deliverables: Updated SKILL.md Report Generation and Wrap-up Sequence sections
- Dependencies: None (foundational task, others depend on this)

**Task 2: Define Post-Nefario Updates section template and append mechanism**
- What: Add the Post-Nefario Updates micro-template to SKILL.md. Define the detection-and-nudge mechanism for when nefario encounters an existing report on the current branch. Document the structured choice (append vs. separate report).
- Deliverables: Post-Nefario Updates template in SKILL.md, branch-report detection logic in wrap-up sequence
- Dependencies: Task 1 (needs to know where in the section order this lives)

**Task 3: Update TEMPLATE.md to match the canonical template**
- What: Align TEMPLATE.md with the canonical template defined in Task 1. TEMPLATE.md serves as reference documentation; SKILL.md is the source of truth.
- Deliverables: Updated TEMPLATE.md
- Dependencies: Task 1

**Task 4: Update PR body generation to use report-as-PR-body pattern**
- What: Ensure the wrap-up sequence's PR creation step uses the full report body (stripped of YAML frontmatter) as the PR description. Verify that `<details>` blocks render correctly on GitHub. Ensure the "Resolves #N" line placement works with the new section order.
- Deliverables: Updated wrap-up sequence in SKILL.md
- Dependencies: Task 1

### Risks and Concerns

1. **Over-prescription risk**: The canonical template has 15+ sections. Even with collapsibility, this is a large document structure for nefario to generate consistently. Every section is a potential point of deviation. The template must be extremely clear about which sections are conditional and what the "empty state" looks like for each. Risk mitigation: provide explicit conditional inclusion rules ("include only if X; otherwise omit entirely").

2. **Post-Nefario Updates scope creep**: The append mechanism could evolve into a complex "report amendment" system. Keep it simple: one section, timestamped entries, manual trigger. Do not build a revision history system.

3. **PR body length on GitHub**: GitHub truncates very long PR descriptions with a "Show more" expander. If the report-as-PR-body is too long, the reviewer sees a truncated view. Test with real report lengths to confirm GitHub's rendering behavior. All `<details>` blocks should render correctly in GitHub's markdown renderer (they do, but blank lines around `<summary>` tags are required).

4. **Collapsibility creates "out of sight, out of mind" risk**: Collapsed sections may never be read. This is acceptable for Agent Contributions and Phases (process detail), but dangerous for Verification (the reviewer should see this). Keep Verification visible, not collapsed.

5. **Inconsistency between v1 and v2 reports is permanent**: The issue states historical reports are not modified. This means searching across reports will always encounter structural variation. The canonical template cannot fix the past -- it can only stabilize the future. Users doing cross-report analysis will need to tolerate structural inconsistency in older reports.

### Additional Agents Needed

None. The current team is sufficient. The primary deliverable is a template definition in SKILL.md -- this is a content structure and UX concern, not a code implementation concern. devx-minion handles the SKILL.md editing, software-docs-minion handles TEMPLATE.md alignment, and the UX guidance provided here informs both.
