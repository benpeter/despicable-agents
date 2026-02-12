# Delegation Plan: Canonical Report Template and PR Updates

**Team name**: canonical-report-template
**Description**: Standardize nefario execution reports with an explicit canonical template in SKILL.md, add Post-Nefario Updates mechanism for PR body freshness.

---

## Conflict Resolutions

### Conflict 1: TEMPLATE.md Disposition

**Contested**: devx-minion says keep TEMPLATE.md as the canonical source referenced from SKILL.md. software-docs-minion says delete it and put the template inline in SKILL.md.

**Resolved in favor of**: software-docs-minion's approach -- inline the canonical template in SKILL.md, delete TEMPLATE.md.

**Rationale**: The issue explicitly states "SKILL.md contains an explicit report template with every section defined." The root cause of current inconsistency is that SKILL.md says "report format is defined inline below" but never actually defines it, causing the LLM to infer structure. Two files = two sources of truth = drift. This is exactly what the overlay mechanism taught us (infrastructure for edge cases creates maintenance burden). The git history preserves TEMPLATE.md's content.

**Rejected**: Keeping TEMPLATE.md as external reference. Creates the same dual-source problem the issue is solving. devx-minion's concern about SKILL.md length is valid but manageable -- the template replaces existing vague prose, so net increase is ~60-80 lines. The alternative (drift) is worse than length.

### Conflict 2: Section Ordering

**Contested**: The issue prescribes a specific canonical order. ux-strategy-minion recommends (a) moving Files Changed to position 5 (before process sections), and (b) consolidating Key Design Decisions and gate Decisions into one section.

**Resolved in favor of**: The issue's prescribed order, with one deviation noted below.

**Rationale**: The issue's author specified the section order deliberately. The ordering is a product decision, not a technical one. However, ux-strategy-minion's analysis of the PR reviewer persona is sound -- Files Changed buried after 6 process sections is suboptimal for the primary reader. Rather than reordering (contradicting the issue), we address the PR reviewer's need through collapsibility: process-heavy sections (Agent Contributions, Execution detail) are collapsed, putting Files Changed ~2-3 scrolls away instead of ~8.

On consolidation: the issue explicitly separates "Key Design Decisions" and "Decisions (gate briefs with rationale/rejected)" as distinct sections. Key Design Decisions captures architectural choices (many of which are NOT gates). Gate Decisions captures the formal approval process with confidence/outcome metadata. These serve different purposes and different audiences. Keep them separate per the issue spec.

**Rejected**: Moving Files Changed to position 5. Contradicts the issue's explicit order. The collapsibility strategy mitigates the concern sufficiently. Also rejected: consolidating Key Design Decisions and gate Decisions -- they serve different purposes (architectural reasoning vs. formal gate process).

### Conflict 3: Post-Nefario Updates Mechanism

**Contested**: devx-minion recommends auto-detect + auto-append on re-run. ux-strategy-minion warns auto-append is dangerous (same branch, different purpose) and recommends detection-and-nudge.

**Resolved in favor of**: Hybrid approach -- detect and nudge, with easy one-step append.

**Rationale**: ux-strategy-minion's risk analysis is correct: branch identity is not a reliable proxy for "continuation of the same task." Auto-appending when a second nefario run on the same branch is for a completely different purpose would corrupt the report. However, the nudge must be low-friction (the issue says "low-friction"). The mechanism:

1. On branch setup, detect existing PR: `gh pr list --head $(git branch --show-current) --json number`
2. If PR exists, present a structured choice at wrap-up: "Existing nefario PR found. Append Post-Nefario Updates to existing PR, or create separate report only?"
3. If user chooses append: generate the Post-Nefario Updates section, append to the PR body via `gh pr edit`, and append to the existing report file (below the last section)
4. Either way: always write a new standalone report file for the current run

For manual (non-nefario) commits: document the convention ("add Post-Nefario Updates section manually"). No automation needed -- infrequent case.

**Rejected**: Fully automatic append (risk of cross-purpose corruption). Also rejected: no automation at all (too much friction for the common case of iterating on the same task).

---

## Task 1: Write Canonical Report Template in SKILL.md

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This template is the foundational structure that all future reports and PR descriptions will follow. It is hard to reverse (all future reports inherit it) and has high blast radius (every downstream task depends on it). The user should verify the section order, content guidance, conditional rules, and frontmatter schema before execution continues.
- **Prompt**: |
    You are updating the nefario orchestration skill to include a canonical
    execution report template. This is a documentation task -- you are editing
    SKILL.md only.

    ## Context
    The current SKILL.md at `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`
    has a "Report Generation" section (starting around line 1280) that says
    "The report format is defined inline below" but never actually defines the
    full template structure. A separate TEMPLATE.md exists at
    `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/TEMPLATE.md`
    but is not referenced from SKILL.md, causing LLMs to infer structure
    inconsistently.

    ## What To Do

    Replace the "Report Template" subsection (currently line 1345-1348 -- the
    3-line stub that says "The report format is defined inline below...") with
    a complete canonical report template. The template must be a literal
    markdown skeleton with `{PLACEHOLDER}` tokens -- not prose describing what
    sections should contain. LLMs follow skeletons precisely; they drift on
    prose descriptions.

    ### Canonical Section Order (from the issue spec)

    The template must define these sections in this exact order:

    1. **YAML Frontmatter** (always)
    2. **Title** (always) -- H1 using the `task` frontmatter value
    3. **Summary** (always) -- 2-3 sentences. NOT "Executive Summary".
    4. **Original Prompt** (always) -- blockquote (<20 lines) or collapsible (>=20 lines)
    5. **Key Design Decisions** (always) -- each decision as H4 with Rationale + Alternatives Rejected
       - **Conflict Resolutions** as H3 subsection (always -- "None." if no conflicts)
    6. **Phases** (always) -- narrative style, NOT tables. 1-2 paragraphs per phase covering the arc from meta-plan through execution. Reference example: the Phases section in `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-11-125653-stay-on-feature-branch-after-pr.md` (lines 36-96).
    7. **Agent Contributions** (always, inside `<details>`) -- planning + review groups. Planning: per-agent name, recommendation, adopted items, risks. Review: verdict + proportional detail (APPROVE=1 line, ADVISE=2-3, BLOCK=3-4).
    8. **Execution** (always) -- contains three subsections:
       - Tasks (table: #, Task, Agent, Status)
       - Files Changed (table: File Path, Action, Description -- ALL files in PR)
       - Approval Gates (table: Gate Title, Agent, Confidence, Outcome, Rounds; then per-gate H4 with Decision, Rationale, Rejected)
    9. **Decisions** (conditional: include when gate-count > 0) -- gate briefs with full rationale, rejected alternatives, confidence, outcome
    10. **Conflict Resolutions** -- wait, this is already a subsection of Key Design Decisions per the issue spec. Do NOT create a separate top-level section. It lives under Key Design Decisions as H3.
    11. **Verification** (always) -- table: Phase, Result. Even if all phases skipped, state that.
    12. **External Skills** (conditional: include when external skills were discovered during meta-plan) -- table: Skill, Classification, Recommendation, Tasks Used
    13. **Files Changed** -- wait, this is already a subsection of Execution. The issue lists it there. Do NOT create a separate top-level section.
    14. **Working Files** (always, inside `<details>`) -- companion directory link + relative links to ALL files. "None" if no companion directory.
    15. **Test Plan** (conditional: include when tests were produced or modified)
    16. **Post-Nefario Updates** (conditional: NEVER in initial report. Include only when subsequent commits land on the same branch after initial report.)

    So the actual top-level H2 sections in order are:
    Summary, Original Prompt, Key Design Decisions (with Conflict Resolutions H3),
    Phases, Agent Contributions, Execution (with Tasks, Files Changed, Approval
    Gates subsections), Decisions, Verification, External Skills, Working Files,
    Test Plan, Post-Nefario Updates.

    ### YAML Frontmatter Schema (version 3)

    ```yaml
    ---
    type: nefario-report
    version: 3
    date: "{YYYY-MM-DD}"
    time: "{HH:MM:SS}"
    task: "{one-line task description}"
    source-issue: {N}          # conditional: only when input was a GitHub issue. Omit line entirely if no issue.
    mode: {full | plan}
    agents-involved: [{agent1}, {agent2}, ...]
    task-count: {N}
    gate-count: {N}
    outcome: {completed | partial | aborted}
    ---
    ```

    Changes from v2: added `source-issue` (conditional), bumped version to 3.
    The `source-issue` field was already appearing ad-hoc in recent reports --
    this standardizes it. build-index.sh reads `date`, `task`, `outcome`,
    `agents-involved`, `time` -- it does NOT read `version` or `source-issue`,
    so v3 reports are backward compatible with the index generator.

    ### Conditional Section Rules

    For each conditional section, write explicit inclusion rules using this
    format in the template:

    ```
    <!-- INCLUDE WHEN: {condition} -->
    <!-- OMIT WHEN: {condition} -->
    ```

    Do NOT use the word "optional." Explicit conditions are deterministic;
    "optional" gives the LLM latitude to include/exclude on vibes.

    Conditional sections:
    - **Decisions**: Include when gate-count > 0. Omit when gate-count = 0.
    - **External Skills**: Include when meta-plan discovered 1+ external skills. Omit when none discovered.
    - **Test Plan**: Include when execution produced test files or test strategy decisions were made. Omit when no tests involved.
    - **Post-Nefario Updates**: NEVER in initial report. Include only when appending updates to an existing report.

    ### Collapsibility Strategy

    Always collapsed (`<details>`):
    - Agent Contributions (process detail, not needed for PR review decisions)
    - Working Files (reference material)

    Always visible (not collapsed):
    - Summary, Original Prompt, Key Design Decisions, Phases, Execution,
      Decisions, Verification, External Skills, Files Changed (within Execution),
      Test Plan, Post-Nefario Updates

    Original Prompt: use its own `<details>` only when >=20 lines.

    ### Template Format in SKILL.md

    Write the template as a fenced code block (```markdown ... ```) containing
    the complete skeleton. Each variable uses `{PLACEHOLDER_NAME}` syntax.
    After the skeleton, add a brief "Template Notes" subsection with:
    - Conditional section rules (the INCLUDE WHEN / OMIT WHEN rules)
    - Collapsibility rules
    - Formatting rules (blank lines around `<summary>` tags, proportional
      detail for review verdicts)
    - Relative link format for Working Files (`./companion-dir/filename.md`)
    - PR body generation note: report body minus YAML frontmatter = PR body.
      Relative links in Working Files work in file view but not PR view. This
      is acceptable -- document the tradeoff.

    ### What To Change in SKILL.md

    1. **Replace the "Report Template" subsection** (lines ~1345-1348) with the
       full canonical template skeleton and template notes.

    2. **Update the "Wrap-up Sequence" step 6** to reference the new inline
       template explicitly: "Write execution report following the canonical
       template defined in the Report Template section above."

    3. **Update the "Report Writing Checklist"** reference. The current SKILL.md
       step 6 says "follow the report format defined in this skill" -- this is
       already correct but should reference the template section by name.

    4. **Update the Data Accumulation section** if needed to align field names
       with the v3 frontmatter schema (add `source-issue` tracking).

    ### What NOT To Do

    - Do NOT modify any other sections of SKILL.md (phases, communication
      protocol, path resolution, etc.)
    - Do NOT modify TEMPLATE.md (that is handled by Task 2)
    - Do NOT modify any existing reports (historical immutability)
    - Do NOT add a Metrics section (dropped -- DRY violation with frontmatter)
    - Do NOT add a Process Detail wrapper section (Phases narrative replaces it;
      Verification is now a top-level section)
    - Do NOT reorder sections from the canonical order specified above
    - Do NOT use the name "Executive Summary" -- it is "Summary"

    ### Reference Examples

    Read these for style reference (but do NOT copy their structure -- follow
    the canonical order above):
    - Summary style: `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-10-205010-decouple-self-referential-assumptions.md` (lines 16-18)
    - Phases narrative: `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-11-125653-stay-on-feature-branch-after-pr.md` (lines 36-96)
    - Key Design Decisions: `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-11-143008-external-skill-integration.md` (lines 32-51)
    - Working Files: existing TEMPLATE.md section 8
    - Agent Contributions: `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/2026-02-11-143008-external-skill-integration.md` (lines 52-60)

    ### Deliverable

    Updated `skills/nefario/SKILL.md` with the complete canonical report
    template replacing the stub. When done, report:
    - Exact line range of the new Report Template section
    - Approximate line count added vs. removed
    - Confirmation that the Wrap-up Sequence step 6 reference was updated
    - Confirmation that Data Accumulation was updated for source-issue

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts
    - 1-2 sentence summary of what was produced
- **Deliverables**: Updated `skills/nefario/SKILL.md` with canonical report template, updated wrap-up reference, updated data accumulation
- **Success criteria**: SKILL.md contains a complete markdown skeleton template with all 12+ sections in the canonical order, placeholder tokens, conditional inclusion rules, and collapsibility annotations

### Task 2: Add Post-Nefario Updates Mechanism to SKILL.md

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are adding the Post-Nefario Updates mechanism to the nefario
    orchestration skill. This handles the case where additional commits land
    on a branch that already has a nefario PR, keeping the PR body fresh.

    ## Context

    Task 1 has already added the canonical report template to SKILL.md at
    `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`.
    The template includes a "Post-Nefario Updates" section defined as
    conditional (never in initial report, only when appending updates).

    You need to add the detection-and-nudge mechanism to the SKILL.md
    wrap-up sequence and branch setup.

    ## What To Do

    ### 1. Add PR Detection to Data Accumulation

    In the "Data Accumulation" section, add tracking for existing PR:

    **After Phase 4 (Execution)** -- add this item to the existing list:
    - `existing-pr`: PR number if a PR already exists for the current branch
      (detected via `gh pr list --head <branch> --json number --jq '.[0].number'`).
      `null` if no existing PR.

    ### 2. Add PR Detection to Branch Creation

    In Phase 4 "Branch Creation", after the branch is resolved (step 3/4),
    add a detection step:

    ```
    5. Detect existing PR on current branch:
       existing_pr=$(gh pr list --head "$(git branch --show-current)" --json number --jq '.[0].number' 2>/dev/null)
       If non-empty, retain as `existing-pr` in session context.
    ```

    ### 3. Add Post-Nefario Updates Choice to Wrap-up

    In the Wrap-up section, BEFORE step 8 (PR creation -- currently step 10
    in the file), add a conditional step:

    ```
    N. **Post-Nefario Updates** (conditional) -- If `existing-pr` is set
       (a PR already exists for this branch):

       Present using AskUserQuestion:
       - header: "Existing PR"
       - question: "PR #<existing-pr> exists on this branch. Update its description with this run's changes?"
       - options (3, multiSelect: false):
         1. label: "Append updates", description: "Add Post-Nefario Updates section to PR #<N> body." (recommended)
         2. label: "Separate report only", description: "Write report file but do not touch the existing PR."
         3. label: "Replace PR body", description: "Replace the entire PR description with this run's report."

       If "Append updates":
         a. Generate the Post-Nefario Updates section:
            ```markdown
            ## Post-Nefario Updates

            ### {YYYY-MM-DD} {HH:MM:SS} -- {one-line task summary}

            {2-3 sentences: what changed and why}

            **Commits**: {N} commits since previous report
            **Files changed**:
            | File | Action | Description |
            |------|--------|-------------|
            | {path} | {created/modified/deleted} | {one-line description} |

            **Report**: [{report-slug}](./{report-filename})
            ```
         b. Append this section to the existing PR body:
            - Fetch current body: `gh pr view <N> --json body --jq .body > /tmp/pr-body-$$`
            - Append the update section to the file
            - Update: `gh pr edit <N> --body-file /tmp/pr-body-$$`
            - Clean up: `rm -f /tmp/pr-body-$$`
         c. If the existing PR body already has a "Post-Nefario Updates"
            section, append the new update entry under it (do not create
            a duplicate H2). Detect by checking for `## Post-Nefario Updates`
            in the existing body.
         d. Print one line: "Updated PR #<N> with Post-Nefario Updates."

       If "Separate report only":
         Skip PR body update. The new report is written as usual.
         Print: "Report written. PR #<N> not updated."

       If "Replace PR body":
         Use the new report body (frontmatter-stripped) as the full PR body,
         replacing the existing content entirely. Follow the existing PR body
         generation logic (strip frontmatter, secret scan, body-file write).
         Print: "Replaced PR #<N> body with new report."

       If `existing-pr` is NOT set, skip this step entirely.
    ```

    ### 4. Update PR Creation Step

    The existing PR creation step (currently step 10) should be made
    conditional: skip PR creation if `existing-pr` is set AND user chose
    "Append updates" or "Separate report only" (PR already exists). Only
    offer to create a NEW PR if no existing PR was detected.

    Add this guard at the start of step 10:
    ```
    If `existing-pr` is set, skip this step (PR already exists).
    ```

    ### 5. Document Manual Update Convention

    After the Post-Nefario Updates mechanism, add a brief note:

    ```
    For manual (non-nefario) changes on a nefario branch after PR creation:
    edit the report file directly to add a "Post-Nefario Updates" section,
    then update the PR body with `gh pr edit <N> --body-file <report>`.
    ```

    ## What NOT To Do

    - Do NOT modify the canonical report template (Task 1's deliverable)
    - Do NOT modify TEMPLATE.md
    - Do NOT add git hooks or CI automation
    - Do NOT auto-append without user confirmation (the nudge is the design)
    - Do NOT modify existing reports

    ## Deliverable

    Updated `skills/nefario/SKILL.md` with:
    - PR detection in Branch Creation and Data Accumulation
    - Post-Nefario Updates choice in Wrap-up sequence
    - Conditional guard on PR creation step
    - Manual update convention note

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts
    - 1-2 sentence summary of what was produced
- **Deliverables**: Updated `skills/nefario/SKILL.md` with Post-Nefario Updates mechanism in wrap-up sequence, PR detection in branch setup, conditional PR creation guard
- **Success criteria**: The wrap-up sequence detects existing PRs and offers a structured choice to append/skip/replace. PR creation is skipped when a PR already exists.

### Task 3: Delete TEMPLATE.md and Update Cross-References

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1, Task 2
- **Approval gate**: no
- **Prompt**: |
    You are removing the now-redundant TEMPLATE.md and updating any
    cross-references throughout the project.

    ## Context

    Task 1 moved the canonical report template inline into SKILL.md.
    Task 2 added the Post-Nefario Updates mechanism. TEMPLATE.md at
    `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/TEMPLATE.md`
    is now redundant -- its content has been superseded by the inline
    template in SKILL.md.

    The issue says "Existing reports are NOT modified (historical immutability)."
    TEMPLATE.md is NOT an existing report -- it is infrastructure. It can be
    deleted.

    ## What To Do

    ### 1. Delete TEMPLATE.md

    Delete the file:
    `git rm docs/history/nefario-reports/TEMPLATE.md`

    The git history preserves the full content. No archival copy is needed.

    ### 2. Search and Update Cross-References

    Search the entire project for references to `TEMPLATE.md`:

    Files to check (based on prior search):
    - `skills/nefario/SKILL.md` -- should now reference itself (inline
      template), not TEMPLATE.md. If Task 1 left any references to
      TEMPLATE.md, update them.
    - `CLAUDE.md` -- check if it mentions TEMPLATE.md (unlikely based on
      current content, but verify)
    - `docs/architecture.md` -- check sub-documents table (current content
      does NOT reference TEMPLATE.md, but verify)
    - `docs/orchestration.md` -- check for any references
    - Any other `.md` file in the project

    For each reference found:
    - If it points to TEMPLATE.md as a format reference, update to reference
      "the Report Template section in skills/nefario/SKILL.md"
    - If it's in a historical report or scratch file, leave it (historical
      immutability)

    ### 3. Verify build-index.sh Compatibility

    Read `/Users/ben/github/benpeter/2despicable/3/docs/history/nefario-reports/build-index.sh`
    and verify:
    - It does NOT reference TEMPLATE.md (it shouldn't -- it reads frontmatter
      from report files matching `????-??-??-*-*.md`)
    - It handles the new `source-issue` field gracefully (it should -- it only
      reads `date`, `task`, `outcome`, `agents-involved`, `time`, `sequence`)
    - v3 reports will be indexed correctly alongside v2 and v1 reports

    Report findings but do NOT modify build-index.sh unless it actually
    references TEMPLATE.md.

    ## What NOT To Do

    - Do NOT modify any existing report files
    - Do NOT modify the canonical template in SKILL.md (Task 1's deliverable)
    - Do NOT modify build-index.sh unless it references TEMPLATE.md
    - Do NOT create an archived copy of TEMPLATE.md (git history suffices)

    ## Deliverable

    - TEMPLATE.md deleted via `git rm`
    - All cross-references updated (list each file modified and what changed)
    - build-index.sh compatibility verified (report findings)

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts
    - 1-2 sentence summary of what was produced
- **Deliverables**: TEMPLATE.md deleted, cross-references updated across the project, build-index.sh compatibility confirmed
- **Success criteria**: No file in the project references TEMPLATE.md as a live document (historical references in old reports are acceptable). build-index.sh indexes v3 reports correctly.

---

## Cross-Cutting Coverage

- **Testing** (test-minion): Not included as execution task. No executable code is produced -- all changes are markdown documentation. Phase 3.5 review will verify the template is well-formed. Phase 6 will be skipped (no tests to run).
- **Security** (security-minion): Not included as execution task. No attack surface, auth, user input, or secrets handling. The template's existing secret-scanning instructions are preserved. Phase 3.5 review will verify.
- **Usability -- Strategy** (ux-strategy-minion): Addressed. ux-strategy-minion contributed to planning (Phase 2). Key recommendations adopted: collapsibility strategy for PR reviewer persona, detection-and-nudge for Post-Nefario Updates, proportional detail for review verdicts. Phase 3.5 review covers this.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Not included. No user-facing interfaces are produced -- this is a markdown template.
- **Documentation** (software-docs-minion): Addressed. software-docs-minion is the primary agent for Task 1 and Task 3. The task IS documentation.
- **Observability** (observability-minion, sitespeed-minion): Not included. No runtime components, services, or APIs. Pure documentation change.

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing UI, no web-facing components)

## Risks and Mitigations

1. **SKILL.md length growth**: Adding ~80-120 lines of template to an already 1416-line file. Mitigation: the template replaces existing vague prose (~20 lines), so net growth is ~60-100 lines. The alternative (external file) reintroduces the drift problem this issue exists to solve. Acceptable tradeoff.

2. **LLM adherence to new template may still drift initially**: Even a literal skeleton can be deviated from. Mitigation: the Wrap-up Sequence step 6 will explicitly say "Read the Report Template section and follow it exactly. Do not invent sections or reorder them." The placeholder syntax makes deviation visible during review.

3. **PR body relative links**: Working Files section uses relative links that work in file view but break in GitHub PR descriptions. Mitigation: document the tradeoff explicitly in the template notes. PR reviewers navigate from the Files Changed tab, not embedded links. Acceptable.

4. **build-index.sh v2/v3 compatibility**: Adding `version: 3` and conditional `source-issue` to frontmatter. Mitigation: build-index.sh does NOT read `version` or `source-issue` -- it reads `date`, `task`, `outcome`, `agents-involved`, `time`. Verified by reading the script. No changes needed.

5. **Post-Nefario Updates scope creep**: The append mechanism could evolve into a complex revision history system. Mitigation: keep it simple -- one section, timestamped entries, user-confirmed trigger. No revision tracking, no diff computation, no automatic detection of what changed.

6. **Phases narrative section is hard to template**: It requires prose, which LLMs generate more variably than tables. Mitigation: the template provides a structure (H3 per phase with specific content guidance) and references a concrete example. The narrative style is anchored by the reference report.

7. **Historical reports are NOT modified**: The v3 template changes only affect future reports. v1 and v2 reports remain untouched. build-index.sh handles all versions. This is explicit in the constraints.

## Execution Order

```
Batch 1: Task 1 (canonical template in SKILL.md)
  [APPROVAL GATE after Task 1]
Batch 2: Task 2 (Post-Nefario Updates mechanism) -- depends on Task 1
Batch 3: Task 3 (delete TEMPLATE.md, update references) -- depends on Tasks 1, 2
```

Three sequential batches. One approval gate after Task 1 (the foundational
template that all other work depends on).

Gate budget: 1 gate. Well within the 3-5 budget.

## Verification Steps

After all tasks complete:
1. SKILL.md contains a complete report template skeleton in the canonical section order
2. SKILL.md wrap-up sequence references the inline template explicitly
3. SKILL.md contains Post-Nefario Updates detection and choice mechanism
4. TEMPLATE.md is deleted (git rm)
5. No live references to TEMPLATE.md remain (historical/scratch references acceptable)
6. build-index.sh still works with existing reports (v1, v2) -- no modification needed
7. The template frontmatter schema is version 3 with conditional source-issue
8. All conditional sections have explicit INCLUDE WHEN / OMIT WHEN rules
9. Collapsibility annotations match the strategy (Agent Contributions and Working Files collapsed; everything else visible)
