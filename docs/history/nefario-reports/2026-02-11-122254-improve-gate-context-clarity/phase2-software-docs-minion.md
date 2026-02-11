## Domain Plan Contribution: software-docs-minion

### Recommendations

I have completed a comprehensive audit of every file that defines, references, or documents gate output formatting. The gate format is defined in multiple locations with varying levels of detail, creating a layered documentation architecture where the SKILL.md is the operational source of truth and other files are derived descriptions. The key finding is that the change set is tightly bounded: only 3 files contain the actual gate format templates that the orchestrator follows at runtime, and 3 additional files describe those formats for human readers.

**File Map: Gate Format Locations**

There are two distinct gate types with separate format definitions. Both need updating.

**1. Execution Plan Approval Gate** (post-Phase 3.5, before execution):

| File | Role | What it contains | Lines |
|------|------|------------------|-------|
| `skills/nefario/SKILL.md` | **Operational source of truth** | Full format template with EXECUTION PLAN, TASKS, ADVISORIES, RISKS, REVIEW, FULL PLAN sections. Also AskUserQuestion parameters. | ~596-667 |
| `docs/orchestration.md` | **Architecture description** | Prose summary of the format (key sections listed, line budget, advisory model). References SKILL.md for "complete specification". | ~344-368 |

**2. Mid-Execution Approval Gate** (during Phase 4, at batch boundaries):

| File | Role | What it contains | Lines |
|------|------|------------------|-------|
| `skills/nefario/SKILL.md` | **Operational source of truth** | Full APPROVAL GATE template (title, agent, blocked tasks, DECISION, RATIONALE, IMPACT, DELIVERABLE, Confidence). Also AskUserQuestion parameters + response handling (approve/request changes/reject/skip + post-exec follow-up). | ~781-870 |
| `nefario/AGENT.md` | **Agent knowledge** | Identical Decision Brief Format section (exact same template). Also full Approval Gates section (classification, response handling, anti-fatigue, cascading). | ~225-327 |
| `nefario/AGENT.overrides.md` | **Override layer** | Identical Decision Brief Format and full Approval Gates section (this is what gets merged into AGENT.md). | ~57-166 |
| `docs/orchestration.md` | **Architecture description** | Section 3 "Approval Gates" with full Decision Brief format example, response handling, anti-fatigue rules, cascading gates. | ~334-443 |

**3. Post-Execution Escalation Gates** (Phase 5-8 BLOCK escalation):

| File | Role | What it contains | Lines |
|------|------|------------------|-------|
| `skills/nefario/SKILL.md` | **Operational source of truth** | VERIFICATION ISSUE format (title, phase, agent, finding, producing agent, file, auto-fix attempts). AskUserQuestion for escalation. | ~948-963 |

**4. Supplementary references** (describe gate behavior without defining format):

| File | Role | Relevance |
|------|------|-----------|
| `the-plan.md` (nefario section, ~443-454) | Canonical spec | Mentions "decision brief format" and "approval gates" in 2 sentences. No format template. |
| `docs/decisions.md` (Decision 11, ~133-142) | Design rationale | Documents WHY the gate classification exists. No format template. |
| `docs/commit-workflow.md` (~77-161) | Commit integration | References approval gates as commit trigger points. No format template. |
| `docs/compaction-strategy.md` (~79-122) | Context management | References gate state preservation. No format template. |
| `docs/using-nefario.md` (~98-120) | User guide | Mentions approval gates in phase descriptions. No format template. |
| `docs/history/nefario-reports/TEMPLATE.md` (~121-206) | Report template | Gate decision briefs in reports (outcome + confidence format). Affected if gate output fields change. |

**5. Files that are NOT affected:**

- `the-plan.md` -- 2 sentences, no format detail, no update needed
- `docs/decisions.md` -- documents rationale, not format
- `docs/commit-workflow.md` -- references gate as trigger, not format
- `docs/compaction-strategy.md` -- references gate state, not format
- `docs/using-nefario.md` -- user-facing phase descriptions, no format detail
- Individual minion AGENT.md files -- none contain gate format definitions
- `nefario/AGENT.generated.md` -- generated file that will be rebuilt; the override layer is what matters

### Proposed Tasks

**Task 1: Update SKILL.md gate format templates (PRIMARY)**
- **What**: Modify the two gate format templates in `skills/nefario/SKILL.md`:
  1. Execution Plan Approval Gate (~line 596): Add artifact references (scratch directory path, key file paths) and inline context summaries to the plan presentation format
  2. Mid-Execution Approval Gate (~line 781): Add artifact references (deliverable file paths, scratch file references, relevant changed files) and inline context to the decision brief format
  3. Post-Execution Escalation (~line 948): Add file path context to VERIFICATION ISSUE format
- **Deliverables**: Updated `skills/nefario/SKILL.md`
- **Dependencies**: None. This is the source of truth; all other files derive from it.
- **Note**: The SKILL.md already includes DELIVERABLE and FULL PLAN fields. The issue is that the *existing* fields are insufficient -- the user needs more inline context to understand what they are approving without opening files. The enhancement should add context summaries, not just file paths.

**Task 2: Update AGENT.md gate format (MUST sync with SKILL.md)**
- **What**: Update the Decision Brief Format and Approval Gates sections in `nefario/AGENT.overrides.md` to match the enhanced format from SKILL.md. Since AGENT.overrides.md is the authoritative source that gets merged into AGENT.md, this is the file to edit -- not AGENT.md directly.
- **Deliverables**: Updated `nefario/AGENT.overrides.md`
- **Dependencies**: Task 1 (SKILL.md must be updated first to establish the canonical format)
- **Critical detail**: After updating overrides, AGENT.md must be regenerated or manually updated to match. The AGENT.md Decision Brief Format must remain identical to SKILL.md's mid-execution gate format.

**Task 3: Update docs/orchestration.md gate documentation**
- **What**: Update Section 3 "Approval Gates" to reflect the enhanced format. This includes:
  - Section 3.1 (Execution Plan Approval Gate): Update format description to mention new context fields
  - Section 3.2 (Decision Brief Format): Update the CLI format example to include the new fields
  - Keep cross-references to SKILL.md intact
- **Deliverables**: Updated `docs/orchestration.md`
- **Dependencies**: Task 1 (must match SKILL.md)

**Task 4: Update report template gate brief format (if applicable)**
- **What**: If the gate output format changes add new fields (beyond what is already in the report template's gate brief format), update `docs/history/nefario-reports/TEMPLATE.md` Section 6 (Execution / Approval Gates) to capture any new context fields in reports.
- **Deliverables**: Updated TEMPLATE.md (or confirmation that no changes are needed)
- **Dependencies**: Task 1 (depends on what new fields are added)
- **Scope note**: This task may be a no-op. The report template's gate brief format is a summarized version. If the gate enhancement adds context fields that are ephemeral (useful at decision time but not for historical record), the template does not need updating.

### Correct Update Order

1. **SKILL.md first** -- this is the operational source of truth that the orchestrator actually executes. All other files are descriptions of what SKILL.md defines.
2. **AGENT.overrides.md second** -- nefario needs to know the gate format to produce correct plans. The overrides file is the edit target; AGENT.md is a build output.
3. **AGENT.md third** -- rebuild from generated + overrides, or manually sync the Decision Brief Format section.
4. **docs/orchestration.md fourth** -- architecture documentation tracks the specification.
5. **TEMPLATE.md last (if needed)** -- only if new fields are added that should persist in reports.

### Risks and Concerns

1. **AGENT.md / AGENT.overrides.md sync risk**: The gate format exists in three files for nefario (SKILL.md, AGENT.overrides.md, AGENT.md). If any one is updated without the others, the orchestrator and the planning agent will disagree on format. The overrides -> AGENT.md build step is not automated in CI -- it requires running `/despicable-lab`. Include a verification step that confirms all three files agree on the gate format template.

2. **Line budget creep**: The current Execution Plan Approval Gate targets 25-40 lines. Adding artifact references and inline context summaries will increase this. The SKILL.md already says "soft guidance, not a hard ceiling -- clarity wins over brevity" but if the enhanced format regularly exceeds 60 lines, it risks creating the same fatigue the budget was designed to prevent. Recommend keeping inline context to 1-2 sentences per gate, not full artifact summaries.

3. **Scope creep into gate logic**: The issue explicitly says "No change to the number or purpose of gates -- only the information presented at each one." Any implementation must be careful not to add new decision points, change response options, or alter the AskUserQuestion parameters. The change is purely additive to the text content shown before the structured prompt.

4. **Report template backward compatibility**: If new fields are added to the gate brief format, older reports will not have those fields. The report template should note that new fields are optional for backward compatibility.

5. **Post-execution escalation format is sparse**: The VERIFICATION ISSUE format already includes file paths, but the current specification does not include scratch directory context. This is a lower-priority enhancement since post-execution escalations are rare.

### Additional Agents Needed

**devx-minion** -- The gate output is fundamentally a developer experience question. devx-minion should review the enhanced format for cognitive load, scannability, and information hierarchy. The current format uses progressive disclosure (Layer 1/2/3); the enhancement must preserve that pattern while adding context. devx-minion is well-positioned to evaluate whether the added information helps or hinders quick decision-making.

No other additional agents are needed beyond what is already in scope. The existing mandatory reviewers (lucy for intent alignment, margo for YAGNI) will catch over-engineering in the format changes.
