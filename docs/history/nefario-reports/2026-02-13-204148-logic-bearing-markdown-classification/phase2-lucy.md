## Domain Plan Contribution: lucy

### Recommendations

#### 1. Success Criteria Audit: Gap Analysis

The issue states four success criteria. I reviewed each against the two affected files.

**Criterion: "Phase 5 code review runs for AGENT.md, SKILL.md, RESEARCH.md changes"**

The current skip condition appears in three locations with consistent but underspecified language:

- `skills/nefario/SKILL.md` line 1649: "Also skip if Phase 4 produced no code files (existing conditional, unchanged)."
- `skills/nefario/SKILL.md` line 1670: "Skip if Phase 4 produced no code files (only docs/config). Note the skip."
- `docs/orchestration.md` line 121: "Skipped if Phase 4 produced only documentation or configuration."

All three use "code files" without defining what counts as code. The fix must update the first two locations (both in SKILL.md). The third location (`docs/orchestration.md` line 121) is documentation that mirrors the SKILL.md language -- it will also need updating or it becomes stale. This is **not mentioned in the issue's scope** (which says "skills/nefario/SKILL.md and nefario/AGENT.md only"), creating a documentation consistency risk. I flag this but do not recommend expanding scope -- the fix should note `docs/orchestration.md` as a follow-up item, or include it if the cost is trivial (one-line edit).

**Criterion: "ai-modeling-minion is included in Phase 1 team assembly when the task involves modifying agent system prompts or orchestration rules in .md files"**

The delegation table in `nefario/AGENT.md` (lines 108-197) has no entry for "modifying agent system prompts" or "modifying orchestration rules." The closest existing entries are:

- "LLM prompt design | ai-modeling-minion | mcp-minion" (line 134)
- "Multi-agent architecture | ai-modeling-minion | mcp-minion" (line 135)

Neither covers the case of modifying existing AGENT.md/SKILL.md content. The fix needs a new delegation table entry. This is a delegation table addition in `nefario/AGENT.md`, which is within scope.

The same delegation table also exists in `the-plan.md` (lines 293-389). Since `the-plan.md` is the canonical source of truth and is protected ("Do NOT modify"), the delegation table in `nefario/AGENT.md` would diverge from the canonical source. This is an inherent tension, not a blocker. The `the-plan.md` delegation table is described as what "is embedded in Nefario's system prompt" (line 295), so if `nefario/AGENT.md` adds a row, there is a factual divergence. **This is acceptable if the human owner later updates `the-plan.md` to match, but the fix should document this divergence explicitly in the PR description.**

**Criterion: "More broadly: specialist selection in Phase 1 considers the semantic content of files, not just their extension"**

This criterion is broader than the specific ai-modeling-minion fix. The delegation table fix addresses one instance (agent prompt work routes to ai-modeling-minion), but Phase 1 team assembly is driven by nefario's judgment applied against the delegation table -- it is not a mechanistic lookup. The delegation table entry is the primary lever: if "agent system prompt modification" appears as a task type routed to ai-modeling-minion, nefario will match it during META-PLAN.

However, the broader criterion implies nefario should not classify all `.md` files as "documentation" during its initial task analysis (step 1 of META-PLAN: "Read relevant files to understand the codebase context"). This is a **cognitive pattern in nefario's reasoning**, not just a delegation table entry. The delegation table addition is necessary but may not be sufficient alone -- nefario also needs guidance that certain `.md` files are functionally code/prompts, not documentation.

**My assessment**: The delegation table entry satisfies the concrete requirement (ai-modeling-minion gets included). The broader criterion ("considers semantic content") is aspirational and needs a lightweight classification hint in the Task Decomposition section or a note in the delegation table header. A single sentence is sufficient -- no elaborate heuristic needed.

**Criterion: "The classification boundary is documented for future contributors"**

This requires documentation of the boundary somewhere persistent. The natural home is either `nefario/AGENT.md` (inline near the Phase 5 skip logic or delegation table), or `docs/orchestration.md`. Given the scope constraint (changes to SKILL.md and AGENT.md only), documentation in AGENT.md is sufficient for the primary deliverable, but `docs/orchestration.md` should be updated as a secondary task.

#### 2. Protected File Constraint Analysis

**Confirmed: `the-plan.md` does not need modification for this fix.**

The proposed scope (SKILL.md + AGENT.md) does not require `the-plan.md` changes because:

- The Phase 5 skip logic is defined in SKILL.md, not `the-plan.md`. The `the-plan.md` description of Phase 5 (line 189-191) says "Skipped if Phase 4 produced only documentation or configuration with no code" but this is descriptive text, not the executable specification.
- The delegation table addition is a runtime enhancement to `nefario/AGENT.md`. While it creates a divergence from `the-plan.md`'s delegation table, this is the same pattern used by the AGENT.overrides.md mechanism documented in `docs/decisions.md` -- AGENT.md can evolve ahead of the spec.

**However**: If this fix lands, the human owner should be informed that `the-plan.md` delegation table (lines 293-389) does not include the new "agent system prompt modification" task type. The PR description should note this for eventual reconciliation.

**No conflict with other protected files.** The fix does not need to modify `install.sh`, `.claude/` configurations, or any other protected artifact.

#### 3. Proportionality Assessment (Helix Manifesto Compliance)

The classification boundary should be **a simple, enumerated filename list** -- not a content-analysis heuristic.

**Rationale**:

The actual failure mode is narrow and well-defined: nefario treats AGENT.md, SKILL.md, and RESEARCH.md as "documentation" because they have `.md` extensions. The set of logic-bearing markdown files in this project is finite and known:

- `AGENT.md` -- contains system prompts (executable instructions for LLMs)
- `SKILL.md` -- contains orchestration workflows (executable instructions for LLMs)
- `RESEARCH.md` -- contains domain knowledge backing system prompts (semi-logic-bearing: changes here affect agent behavior indirectly)
- `CLAUDE.md` -- contains project instructions (executable instructions for LLMs)

A content-analysis heuristic (e.g., "scan for YAML frontmatter," "check for prompt-like patterns") would be:

- **Over-engineered** for the problem: The set of file types is known and stable.
- **Fragile**: Content heuristics create false positives/negatives.
- **Violates KISS**: If you have to explain the heuristic, it is too complicated.
- **Violates YAGNI**: There is no evidence of a need to classify arbitrary `.md` files dynamically.

The proportional solution is:

1. Define a short list of filenames that are "logic-bearing markdown" (AGENT.md, SKILL.md, CLAUDE.md, and optionally RESEARCH.md).
2. The Phase 5 skip check tests against this list: "if all changed files are docs/config AND none are logic-bearing markdown, skip Phase 5."
3. The delegation table gets one new row for "agent system prompt / orchestration rule modification."

This is 3-5 lines of new text in each affected file. Anything more is gold-plating.

**Where the line falls**: A filename list is correct. A path-pattern list (e.g., `*/AGENT.md`, `*/SKILL.md`) would be marginally better but not required. A content-analysis heuristic crosses the over-engineering line.

#### 4. Terminology Alignment: "Logic-Bearing Markdown"

I searched the entire project tree for existing terminology covering this distinction. **There is no existing term.** The project currently uses only:

- "code files" vs. "docs/config" (SKILL.md lines 1649, 1670; orchestration.md line 121)
- "deployable agent file" (agent-anatomy.md line 5, referring to AGENT.md)
- "system prompt" (used throughout for the content of AGENT.md)
- "orchestration workflow" (used for SKILL.md content)

The term "logic-bearing markdown" is new vocabulary. It is descriptive and self-explanatory, which aligns with the project's "Intuitive, Simple & Consistent" priority order. However, introducing a new term creates a naming decision that affects future contributors.

**Assessment**: The term is acceptable if it is defined once and used consistently. The alternatives I considered:

- "Executable markdown" -- misleading; these files are not executed in a traditional sense.
- "Prompt-bearing markdown" -- too narrow; SKILL.md contains orchestration rules, not just prompts.
- "Behavioral markdown" -- used in project history reports (see grep results) but informally, never as a defined term.
- "Functional markdown" -- ambiguous.

"Logic-bearing markdown" is the best option. It should be defined in a single location (the classification boundary documentation) and referenced from the Phase 5 skip logic and the delegation table note.

**Risk**: If the term appears only in SKILL.md and AGENT.md but not in `docs/orchestration.md` or `docs/agent-anatomy.md`, future contributors may not encounter it. The documentation task should cross-reference the term to at least one docs/ file. This can be a follow-up if out of scope.

### Proposed Tasks

**Task 1: Define and document the classification boundary**

- **What**: Add a short definition of "logic-bearing markdown" files to `nefario/AGENT.md`, near the Task Decomposition Principles section or as a new subsection. The definition should list the specific filenames (AGENT.md, SKILL.md, CLAUDE.md) and explain why they are not "documentation" for classification purposes. RESEARCH.md is borderline -- it does not contain executable instructions but changes to it signal that agent behavior will change. Recommend classifying it as logic-bearing for Phase 5 purposes (conservative: review it rather than skip it).
- **Deliverables**: Updated section in `nefario/AGENT.md` with the classification boundary definition.
- **Dependencies**: None. This task can run first.

**Task 2: Fix the Phase 5 skip conditional in SKILL.md**

- **What**: Modify the Phase 5 skip condition at SKILL.md lines 1649 and 1670 to exclude logic-bearing markdown files from the "docs/config" category. The condition should change from "skip if Phase 4 produced no code files (only docs/config)" to "skip if Phase 4 produced only documentation or configuration files, excluding logic-bearing markdown (AGENT.md, SKILL.md, CLAUDE.md, RESEARCH.md)." Also update the overview at line 149 if its parenthetical "(conditional: code produced)" is misleading.
- **Deliverables**: Updated skip conditions in `skills/nefario/SKILL.md`.
- **Dependencies**: Task 1 (the definition must exist before referencing it).

**Task 3: Fix the delegation table in AGENT.md**

- **What**: Add a new row to the delegation table in `nefario/AGENT.md` under the Intelligence section: "Agent system prompt / orchestration rule modification | ai-modeling-minion | lucy". This routes tasks involving AGENT.md/SKILL.md content changes to ai-modeling-minion as primary. Lucy as supporting is appropriate because prompt/rule changes require intent alignment verification.
- **Deliverables**: Updated delegation table in `nefario/AGENT.md`.
- **Dependencies**: None. Can run in parallel with Task 1.

**Task 4: Update docs/orchestration.md to match**

- **What**: Update the Phase 5 description at `docs/orchestration.md` line 121 to reflect the new classification boundary. One-line change: "Skipped if Phase 4 produced only documentation or configuration" becomes "Skipped if Phase 4 produced only documentation or configuration (logic-bearing markdown such as AGENT.md and SKILL.md counts as code, not documentation)."
- **Deliverables**: Updated `docs/orchestration.md`.
- **Dependencies**: Task 2 (reflects the same language).

### Risks and Concerns

**Risk 1: the-plan.md delegation table divergence (MEDIUM)**

Adding a delegation table row to `nefario/AGENT.md` without a corresponding row in `the-plan.md` creates a divergence between the canonical spec and the deployed agent. This is not a blocker (the pattern exists with AGENT.overrides.md), but should be noted in the PR description for the human owner to reconcile later.

**Risk 2: docs/orchestration.md staleness (LOW)**

If Task 4 is dropped as "out of scope," the orchestration architecture doc will describe stale Phase 5 skip behavior. This is a documentation consistency issue, not a functional one. Recommend including Task 4 since it is a one-line edit.

**Risk 3: RESEARCH.md classification ambiguity (LOW)**

RESEARCH.md is not directly executable -- it is reference material. Classifying it as "logic-bearing" is conservative (errs on the side of review). Classifying it as "documentation" risks skipping review when RESEARCH.md changes signal impending agent behavior changes. The conservative choice is correct for this project's quality bar.

**Risk 4: Over-specification of the boundary (LOW)**

The boundary definition could grow to cover edge cases (what about `CLAUDE.local.md`? `.claude/rules/*.md`?). YAGNI applies: define the boundary for the known failure cases (AGENT.md, SKILL.md, CLAUDE.md, RESEARCH.md). If new cases emerge, the list can be extended. Do not preemptively cover hypothetical files.

**Risk 5: Scope creep into nefario's reasoning patterns (MEDIUM)**

The broader criterion ("considers semantic content of files, not just their extension") could be interpreted as requiring changes to nefario's META-PLAN reasoning logic beyond the delegation table. This is the most likely source of scope creep. The delegation table entry is the minimal fix. If nefario still misclassifies tasks after the delegation table addition, that is a separate issue. Do not solve anticipated future failures now.

### Additional Agents Needed

None. The current team (ai-modeling-minion for technical classification criteria, lucy for alignment) is sufficient. The fix is small and well-bounded -- adding more specialists would be disproportionate.

One caveat: if the execution plan includes Task 4 (docs/orchestration.md update), software-docs-minion is technically the owner of architecture documentation. For a one-line edit, involving software-docs-minion would be over-coordination. The executing agent can handle it directly.
