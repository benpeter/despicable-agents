# Phase 3: Synthesis -- Logic-Bearing Markdown Classification

## Delegation Plan

**Team name**: logic-bearing-markdown
**Description**: Fix nefario's misclassification of logic-bearing markdown files (AGENT.md, SKILL.md, RESEARCH.md) as documentation, which causes Phase 5 code review skipping and ai-modeling-minion omission from team assembly.

### Conflict Resolutions

**1. Where should the canonical classification definition live?**

- **ai-modeling-minion** recommends: `nefario/AGENT.md`, in or adjacent to Task Decomposition Principles.
- **software-docs-minion** recommends: `skills/nefario/SKILL.md` only, at the point of use (the Phase 5 conditional).
- **lucy** recommends: whichever file, keep it to a simple enumerated list.

**Resolution**: software-docs-minion's reasoning is stronger. SKILL.md is where the classification is *applied* -- the Phase 5 skip conditional. An AI agent executing Phase 5 reads SKILL.md, not AGENT.md. Placing the definition at the decision point eliminates cross-referencing. AGENT.md gets vocabulary alignment (1-2 sentences) and the delegation table entries, not the full classification definition. This avoids the dual-classification-taxonomy risk that software-docs-minion identified.

**2. How many delegation table rows to add?**

- **ai-modeling-minion** recommends: three rows (prompt design/modification, orchestration rule changes, agent definition changes).
- **lucy** recommends: one row covering agent system prompt / orchestration rule modification.

**Resolution**: Two rows. ai-modeling-minion's three rows have redundancy ("Agent system prompt design/modification" and "Agent definition changes (AGENT.md)" overlap substantially). Consolidate to two distinct rows that cover the gap without redundancy:
- "Agent system prompt modification (AGENT.md)" -- covers creating and editing agent behavioral specs
- "Orchestration rule changes (SKILL.md, CLAUDE.md)" -- covers skill workflows and project instructions

This is enough to trigger ai-modeling-minion inclusion in META-PLAN when these file types appear in a task. Lucy as supporting on both rows is correct -- prompt/rule changes require intent alignment verification.

**3. Scope of documentation updates.**

- **software-docs-minion** proposes 5 deliverables (D1-D5), including updates to docs/orchestration.md, docs/decisions.md, and docs/agent-anatomy.md.
- **lucy** notes that docs/orchestration.md should be updated but flags over-coordination risk.
- **margo** (anticipated YAGNI concern): 5 doc deliverables for a classification boundary is heavy.

**Resolution**: Keep D1 (SKILL.md -- primary), D2 (AGENT.md -- vocabulary alignment), D3 (docs/orchestration.md -- one-line fix), and D4 (docs/decisions.md -- decision record). Drop D5 (docs/agent-anatomy.md cross-reference) -- it is the least essential and the project already has 4 touch points for this concept. If margo still flags scope in Phase 3.5, D4 is the next to drop (the decision log is valuable but not operationally required). The docs changes are trivial (1-2 sentences each) so they can be combined into a single task.

**4. Wrap-up verification summary changes.**

- **ux-strategy-minion** recommends: add parenthetical explanation when phases are auto-skipped (e.g., "Code review: not applicable -- docs-only changes").
- **ux-strategy-minion** also recommends: classification labels must never appear in user-facing output.

**Resolution**: Both accepted. The wrap-up parenthetical is low-cost and directly addresses the accountability gap. The jargon guardrail is a single sentence co-located with the classification definition. Both are incorporated into Task 2.

### Risks and Mitigations

1. **the-plan.md delegation table divergence (MEDIUM)**: Adding delegation table rows to AGENT.md without updating the-plan.md creates a spec divergence. *Mitigation*: Flag in PR description for human owner to reconcile. Do not modify the-plan.md.

2. **Prompt length inflation (LOW)**: Adding classification definition + table + examples to SKILL.md. *Mitigation*: Target compact format -- inline table (4 rows), definition (2 sentences), operational rule (1 sentence). Estimated ~10 lines net addition.

3. **RESEARCH.md classification surprise (LOW)**: Contributors may expect RESEARCH.md to be freely editable docs. *Mitigation*: Classification definition includes brief rationale for why RESEARCH.md is logic-bearing (prompt-research coupling). The cost of unnecessary review is far lower than the cost of missing a behavior-affecting change.

4. **Over-classification false positives (LOW)**: Edge case -- CHANGELOG.md inside an agent directory would be classified as logic-bearing by directory heuristic. *Mitigation*: Acceptable false positive. Code reviewer can APPROVE instantly. The frequency is too low to warrant content heuristics.

5. **Classification divergence between SKILL.md and reference docs (LOW)**: *Mitigation*: Reference docs use vocabulary only, not the full definition. Vocabulary-only references are low-drift.

---

### Task 1: Add delegation table entries and file-domain awareness principle to AGENT.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are modifying `nefario/AGENT.md` to fix a team assembly gap: when tasks involve modifying agent system prompts (AGENT.md files) or orchestration rules (SKILL.md, CLAUDE.md), ai-modeling-minion is not included in Phase 1 team assembly because the delegation table has no matching entry.

    ## What to do

    ### 1. Add two rows to the delegation table

    In `nefario/AGENT.md`, find the delegation table under `## Delegation Table`. In the **Intelligence** section (after the existing "LLM cost optimization" row and before "Technology radar assessment"), add these two rows:

    ```
    | Agent system prompt modification (AGENT.md) | ai-modeling-minion | lucy |
    | Orchestration rule changes (SKILL.md, CLAUDE.md) | ai-modeling-minion | ux-strategy-minion |
    ```

    These entries ensure that when a task involves editing agent behavioral specs or orchestration workflows, ai-modeling-minion is routed as primary during META-PLAN.

    ### 2. Add a File-Domain Awareness principle to Task Decomposition Principles

    In the same file, find the `## Task Decomposition Principles` section. After the existing principles ("The 100% Rule", "Decomposition Approach", "File Ownership", "Dependency Types"), add a new principle:

    ```markdown
    **File-Domain Awareness**: When analyzing which domains a task involves, consider the semantic nature of the files being modified, not just their extension. Agent definition files (AGENT.md), orchestration rules (SKILL.md), domain research (RESEARCH.md), and project instructions (CLAUDE.md) are prompt engineering and multi-agent architecture artifacts. Changes to these files should route through ai-modeling-minion. Documentation files (README.md, docs/*.md, changelogs) route through software-docs-minion or user-docs-minion.
    ```

    ### 3. Update the Phase 5 summary in Post-Execution Phases section

    In the `## Post-Execution Phases (5-8)` section, update the Phase 5 bullet from:
    ```
    - **Phase 5: Code Review** -- Runs when Phase 4 produced code.
    ```
    to:
    ```
    - **Phase 5: Code Review** -- Runs when Phase 4 produced code or logic-bearing markdown (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md).
    ```

    ## What NOT to do

    - Do NOT add the full classification definition to AGENT.md. The canonical definition lives in SKILL.md (a separate task handles that). AGENT.md gets vocabulary alignment only.
    - Do NOT modify the-plan.md. It is a protected file.
    - Do NOT add more than two delegation table rows. The existing "LLM prompt design" and "Multi-agent architecture" rows already cover new-from-scratch prompt work. These two new rows cover *modification* of existing agent/orchestration files.
    - Do NOT add content heuristics or elaborate classification logic. Keep it to named files and a brief principle.

    ## File to modify

    `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`

    ## Context

    The delegation table is at lines 106-197. Task Decomposition Principles section follows later in the file. Post-Execution Phases section is around line 757.

    The same delegation table exists in `the-plan.md` but must not be modified. The PR description will note the divergence for the human owner.
- **Deliverables**: Updated `nefario/AGENT.md` with two new delegation table rows, one new Task Decomposition principle, and updated Phase 5 summary line.
- **Success criteria**: The delegation table contains entries that would cause nefario to route "modify AGENT.md system prompt" or "update SKILL.md orchestration rules" tasks to ai-modeling-minion during META-PLAN. The File-Domain Awareness principle is present and concise (under 80 words).

### Task 2: Define classification boundary and fix Phase 5 skip conditional in SKILL.md

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: The classification boundary is the core deliverable. It defines which files get code review and which are skipped. This is a hard-to-reverse architectural decision with 3+ downstream dependents (Task 3 vocabulary alignment, all future Phase 5 skip decisions, all future team assembly decisions). Multiple valid approaches exist (filename-only vs filename+directory, conservative vs liberal default). MUST gate per classification rules.
- **Prompt**: |
    You are modifying `skills/nefario/SKILL.md` to fix the Phase 5 code review skip conditional. Currently, nefario skips Phase 5 for changes to AGENT.md, SKILL.md, and RESEARCH.md because they are classified as "docs" based on their .md extension. This is wrong -- these files contain system prompts, orchestration rules, and domain knowledge that directly governs agent behavior.

    ## What to do

    ### 1. Replace the Phase 5 skip conditional (line 1670) with classification boundary

    Find this line in the Phase 5 section:
    ```
    Skip if Phase 4 produced no code files (only docs/config). Note the skip.
    ```

    Replace it with the following three-part structure (definition, classification table, operational rule):

    ```markdown
    **File classification for phase-skipping**: Logic-bearing markdown files
    are treated as code, not documentation. A file is logic-bearing if changing
    it alters the runtime behavior of an LLM agent or orchestration workflow.

    | File Pattern | Classification | Rationale |
    |-------------|---------------|-----------|
    | `AGENT.md` in agent/skill directories | Logic-bearing | System prompt -- controls agent behavior |
    | `SKILL.md` in skill directories | Logic-bearing | Orchestration workflow -- controls phase logic |
    | `RESEARCH.md` in agent directories | Logic-bearing | Domain knowledge backing system prompts |
    | `CLAUDE.md` (any location) | Logic-bearing | Project instructions -- controls all agent behavior |
    | `README.md`, `docs/*.md`, changelogs | Documentation-only | Informs humans; does not affect agent runtime |

    Skip Phase 5 only if ALL files produced by Phase 4 are documentation-only.
    If any file is logic-bearing or traditional code, run Phase 5. When
    ambiguous, default to running review (false positive cost is one subagent
    call; false negative cost is a deployed defect in agent behavior).

    Classification labels (logic-bearing, documentation-only) are internal
    vocabulary. User-facing output uses outcome language: "docs-only changes"
    or "changes requiring review."
    ```

    ### 2. Update the matching conditional at lines 1647-1649

    Find this text in the post-execution phase determination section:
    ```
    - Phase 5 (Code Review): Skip if user selected "Skip review" or typed
      --skip-review or --skip-post. Also skip if Phase 4 produced no code
      files (existing conditional, unchanged).
    ```

    Replace the last line with:
    ```
    - Phase 5 (Code Review): Skip if user selected "Skip review" or typed
      --skip-review or --skip-post. Also skip if Phase 4 produced only
      documentation-only files (see Phase 5 file classification table).
    ```

    ### 3. Update the wrap-up verification summary format

    Find the verification summary format examples at two locations in SKILL.md:

    Location 1 (~line 1907-1908):
    ```
    The "Skipped:" suffix tracks user-requested skips only. Phases skipped
    by existing conditionals (e.g., "no code files") are not listed.
    ```

    Replace with:
    ```
    The "Skipped:" suffix tracks user-requested skips only. Phases skipped
    by existing conditionals are not listed in the suffix, but a parenthetical
    explanation is appended: e.g., "Verification: tests passed. (Code review:
    not applicable -- docs-only changes)."
    ```

    Location 2 (~line 2108-2109): Apply the same replacement.

    ## What NOT to do

    - Do NOT add content-analysis heuristics (scanning for YAML frontmatter, prompt-like patterns). The classification is filename-primary, not content-based.
    - Do NOT create a separate file or section for the classification. It lives inline at the Phase 5 skip conditional -- the exact point where the decision is made.
    - Do NOT add a "File Classification" preamble section earlier in SKILL.md. Keep the definition at the point of application.
    - Do NOT use classification labels in user-facing output examples. Use outcome language ("docs-only changes", "changes requiring review").

    ## File to modify

    `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    ## Context

    - Phase 5 skip conditional: line 1670
    - Post-execution phase determination: lines 1645-1655
    - Wrap-up verification summary: lines 1901-1908 and lines 2101-2109
    - The classification table has 5 rows covering the known file types in this project. It is illustrative, not exhaustive -- the definition sentence ("changing it alters runtime behavior") governs edge cases.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with inline classification boundary definition (table + definition + operational rule), updated skip conditionals at both locations, updated wrap-up verification summary format at both locations.
- **Success criteria**: (1) The Phase 5 skip conditional would NOT skip review for changes to AGENT.md, SKILL.md, RESEARCH.md, or CLAUDE.md. (2) The Phase 5 skip conditional WOULD skip review for changes to only README.md or docs/*.md files. (3) Both verification summary locations include the parenthetical explanation format for auto-skipped phases. (4) No classification jargon appears in user-facing output examples.

### Task 3: Align vocabulary in docs/orchestration.md, docs/decisions.md, and docs/agent-anatomy.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    You are updating three documentation files to reflect a new classification boundary for logic-bearing markdown files. The canonical definition is now in `skills/nefario/SKILL.md` at the Phase 5 skip conditional. Your job is vocabulary alignment and a decision record -- NOT duplicating the full definition.

    ## What to do

    ### 1. Update docs/orchestration.md Phase 5 description

    File: `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md`

    Find line 121:
    ```
    Runs when Phase 4 produced or modified code files. Skipped if Phase 4 produced only documentation or configuration.
    ```

    Replace with:
    ```
    Runs when Phase 4 produced or modified code or logic-bearing markdown files (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md). Skipped if Phase 4 produced only documentation-only files (README, docs/, changelogs).
    ```

    ### 2. Add decision entry to docs/decisions.md

    File: `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md`

    Add Decision 30 after the last existing entry (Decision 29). Follow the existing format:

    ```markdown
    ### Decision 30: Logic-Bearing Markdown Classification

    | Field | Value |
    |-------|-------|
    | **Status** | Implemented |
    | **Date** | 2026-02-13 |
    | **Choice** | Classify markdown files as logic-bearing or documentation-only based on filename conventions. AGENT.md, SKILL.md, RESEARCH.md, and CLAUDE.md are logic-bearing. README.md, docs/*.md, and changelogs are documentation-only. Logic-bearing files are treated as code for Phase 5 review and team assembly purposes. |
    | **Alternatives rejected** | (1) Extension-based classification (.md = documentation). Rejected because system prompts and orchestration rules use .md extension but are functionally code. (2) Content-analysis heuristics (scan for YAML frontmatter, prompt patterns). Rejected because it is fragile, adds prompt complexity, and produces inconsistent results across sessions. |
    | **Rationale** | In an LLM agent system, system prompts ARE the code. AGENT.md files control agent behavior, SKILL.md files control orchestration workflow, RESEARCH.md informs prompt content. Extension-based classification caused Phase 5 code review to be skipped for these files and ai-modeling-minion to be excluded from team assembly. Filename-based classification is deterministic, compact, and matches the project's existing naming conventions. |
    | **Consequences** | Phase 5 code review now runs for changes to logic-bearing markdown. ai-modeling-minion is included in team assembly for agent/orchestration file modifications. Classification boundary is documented at the Phase 5 skip conditional in SKILL.md. The delegation table in nefario/AGENT.md diverges from the-plan.md (flagged for human owner reconciliation). |
    ```

    ### 3. Add cross-reference in docs/agent-anatomy.md

    File: `/Users/ben/github/benpeter/2despicable/3/docs/agent-anatomy.md`

    Find the opening paragraph (line 5):
    ```
    Each agent in despicable-agents consists of two primary files: a deployable agent file (`AGENT.md`) and a research backing file (`RESEARCH.md`).
    ```

    Append one sentence:
    ```
    Each agent in despicable-agents consists of two primary files: a deployable agent file (`AGENT.md`) and a research backing file (`RESEARCH.md`). Both are classified as logic-bearing markdown for orchestration purposes -- changes to these files trigger code review, not documentation-only processing.
    ```

    ## What NOT to do

    - Do NOT duplicate the full classification table from SKILL.md. Reference docs get vocabulary alignment only.
    - Do NOT modify the-plan.md. It is a protected file. The divergence is noted in Decision 30's Consequences.
    - Do NOT modify SKILL.md or AGENT.md -- those are handled by other tasks.
    - Do NOT create new documentation files. All changes go into existing files.

    ## Files to modify

    - `/Users/ben/github/benpeter/2despicable/3/docs/orchestration.md` (line 121)
    - `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md` (after Decision 29)
    - `/Users/ben/github/benpeter/2despicable/3/docs/agent-anatomy.md` (line 5)
- **Deliverables**: Updated `docs/orchestration.md` with consistent Phase 5 vocabulary, new Decision 30 entry in `docs/decisions.md`, one-sentence cross-reference in `docs/agent-anatomy.md`.
- **Success criteria**: (1) docs/orchestration.md Phase 5 description mentions logic-bearing markdown explicitly. (2) Decision 30 exists with correct format, captures the rejected alternatives, and notes the the-plan.md divergence. (3) docs/agent-anatomy.md notes the logic-bearing classification of AGENT.md and RESEARCH.md.

---

### Cross-Cutting Coverage

- **Testing**: Not applicable. No executable code is produced -- all changes are to system prompt instructions and documentation. Phase 6 will find no new tests to run and will skip via its existing conditional.
- **Security**: Not applicable. No attack surface created, no auth/secrets/user input handling. The classification boundary itself is not a security-sensitive decision.
- **Usability -- Strategy**: Covered. ux-strategy-minion contributed to planning and their recommendations are incorporated into Task 2 (wrap-up parenthetical, jargon guardrail). ALWAYS include requirement satisfied.
- **Usability -- Design**: Not applicable. No user-facing interfaces produced.
- **Documentation**: Covered by Task 3 (docs/orchestration.md, docs/decisions.md, docs/agent-anatomy.md). software-docs-minion contributed to planning and their recommendations shape all three tasks. ALWAYS include requirement satisfied.
- **Observability**: Not applicable. No runtime components, APIs, or background processes produced.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - None selected. All discretionary reviewers have domain signals that do not match this plan:
- **Not selected**: ux-design-minion (no UI components), accessibility-minion (no web-facing HTML/UI), sitespeed-minion (no web-facing runtime code), observability-minion (no runtime components), user-docs-minion (no changes to what end users see/do/learn -- this is internal orchestrator behavior)

### Execution Order

```
Batch 1 (parallel):
  Task 1: AGENT.md delegation table + file-domain awareness principle
  Task 2: SKILL.md classification boundary + Phase 5 conditional fix  [APPROVAL GATE]

--- Gate: Task 2 approval ---

Batch 2:
  Task 3: Documentation vocabulary alignment (docs/orchestration.md, docs/decisions.md, docs/agent-anatomy.md)
```

Tasks 1 and 2 are independent (different files, no content dependency). Task 2 has an approval gate because the classification boundary is the core architectural decision. Task 3 depends on Task 2 because it must use the vocabulary established in the approved classification boundary.

### External Skills

No external skills detected relevant to this task.

### Verification Steps

After all tasks complete:

1. **Phase 5 skip test (mental walkthrough)**: Given a task that produces changes only to `minions/ai-modeling-minion/AGENT.md`, would the new Phase 5 conditional skip or run review? Expected: RUN (AGENT.md is logic-bearing).

2. **Docs-only skip test**: Given a task that produces changes only to `README.md` and `docs/architecture.md`, would the new Phase 5 conditional skip or run review? Expected: SKIP (both are documentation-only).

3. **Team assembly test**: Given a task described as "update the security-minion system prompt to add OWASP Top 10 coverage," would nefario's delegation table route this to ai-modeling-minion? Expected: YES (matches "Agent system prompt modification (AGENT.md)" row).

4. **Vocabulary consistency**: Grep all modified files for "no code files" -- the old phrasing should not appear in any of the modified files.

5. **Jargon guardrail**: Grep SKILL.md user-facing output examples (CONDENSE lines, verification summaries) for "logic-bearing" -- should not appear in any user-facing text. Should only appear in internal classification definition.

6. **the-plan.md untouched**: Verify the-plan.md has no modifications.

### Recommendations for Human Owner

- Update `the-plan.md` delegation table (lines ~293-389) to add the two new rows matching what was added to `nefario/AGENT.md`.
- Update `the-plan.md` Phase 5 description (lines ~189-191) to use the logic-bearing/documentation-only vocabulary.
