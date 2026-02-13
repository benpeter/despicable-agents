## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. Define a single canonical advisory format with three required fields

All five surfaces should draw from one underlying advisory data structure. The minimal field set that achieves self-containment is:

| Field | Purpose | Example |
|-------|---------|---------|
| **SCOPE** | Names the concrete artifact, file, concept, or system area affected | `nefario/AGENT.md verdict format`, `Phase 4 CLI flag parsing`, `install.sh symlink targets` |
| **CHANGE** | States what is proposed or was changed, in domain terms -- no plan-internal references | `Add SCOPE field to reviewer verdict WARNINGS block so each warning names the artifact it concerns` |
| **WHY** | Explains the risk or rationale using only information present in the advisory itself | `Without explicit artifact names, users reading the execution report cannot evaluate whether a warning applies to their area of concern` |

These three fields satisfy the success criteria directly:
- SCOPE answers "what part of the system does this affect"
- CHANGE answers "what is suggested"
- WHY answers "why"

A reader seeing only these three fields can evaluate the advisory without opening any other document.

**RECOMMENDATION and TASK fields should be eliminated as separate fields.** RECOMMENDATION is redundant with CHANGE (both describe what to do). TASK is a plan-internal reference that violates self-containment. When a surface needs to associate an advisory with a task, the task title (not number) should appear in the SCOPE field or as a surface-specific annotation outside the canonical three fields.

#### 2. Surface-specific rendering, not surface-specific fields

Each surface renders the same three-field advisory differently based on its display constraints:

**Surface 1 -- Phase 3.5 reviewer verdict (nefario/AGENT.md)**:
```
VERDICT: ADVISE
WARNINGS:
- [domain] SCOPE: <artifact or concept>
  CHANGE: <what specifically should change>
  WHY: <risk or rationale>
```
This replaces the current TASK + CHANGE + RECOMMENDATION trio. The `[domain]` tag is already present and stays. TASK is absorbed into SCOPE (the task title can appear there if relevant, e.g., "Task 'Update CLI flags': flag parsing in nefario/AGENT.md"). RECOMMENDATION is replaced by CHANGE.

**Surface 2 -- Execution plan ADVISORIES block (skills/nefario/SKILL.md)**:
```
ADVISORIES:
  [<domain>] SCOPE: <artifact or concept>
    CHANGE: <one sentence>
    WHY: <one sentence>
```
This is almost identical to the current format, but replaces `Task N: <task title>` with `SCOPE: <artifact or concept>`. Task association, if needed, is done by the orchestrator mapping SCOPE values to tasks -- it is not part of the advisory itself.

**Surface 3 -- Inline summary template (skills/nefario/SKILL.md)**:
```
Verdict: {APPROVE | ADVISE -- SCOPE: <artifact>; CHANGE: <what>; WHY: <reason> | BLOCK(details)}
```
The parenthetical `(details)` is replaced with a structured one-liner that carries the three fields. For multiple advisories, semicolons separate them. If too long (> 200 chars), truncate to the first advisory and add `(+N more in scratch file)`.

**Surface 4 -- Execution report (TEMPLATE.md)**:
```
**{agent-name}**: ADVISE. SCOPE: <artifact>. <CHANGE summary>. WHY: <reason>.
```
This replaces the current freeform `{Concern and recommendation.}` with structured fields that can be parsed and understood in isolation. For multi-advisory verdicts, each advisory gets its own line.

**Surface 5 -- Phase 5 code review findings (skills/nefario/SKILL.md)**:
```
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  FIX: <specific fix>
```
Phase 5 findings are already self-contained because `<file>:<line-range>` is a concrete artifact reference (equivalent to SCOPE) and `<description>` states the concern (equivalent to merged CHANGE + WHY). The FIX field serves as the action recommendation. The AGENT field (producing agent) is surface-specific metadata, not part of the advisory's self-containment. No format change needed here. However, document explicitly that Phase 5 findings are a separate format from Phase 3.5 advisories because they reference code artifacts at line-level granularity, which is a fundamentally different abstraction level.

#### 3. Surface-specific fields go outside the canonical block

Surface-specific metadata should be clearly separated from the canonical advisory:

- **Scratch file links** (`Details:` and `Prompt:` lines): These are navigation aids, not advisory content. They appear below the canonical three fields as a separate rendering concern. Only surfaces that link to scratch files (Surface 2 -- execution plan ADVISORIES block) include them.
- **Producing agent** (AGENT field in Phase 5): Surface-specific attribution. Stays in Surface 5 only.
- **Task association**: When the orchestrator needs to inject advisories into task prompts, it maps SCOPE values to tasks internally. The task number/title is an orchestration concern, not an advisory field.

#### 4. Ban plan-internal references in all advisory content

The instructions for every agent that produces advisories (reviewer prompts in Phase 3.5, code review prompts in Phase 5) should include an explicit prohibition:

> Advisory fields must not reference plan-internal structure (task numbers, step numbers, phase names) as the sole identifier. Every SCOPE must name a concrete artifact (file path, configuration key, concept name) or system area that exists independently of the plan.

This is the enforcement mechanism. Without it, agents will naturally default to "Task 3" or "step 1" because those are the labels they see in their input.

### Proposed Tasks

#### Task A: Define canonical advisory format in nefario/AGENT.md

**What**: Replace the current ADVISE verdict format (TASK + CHANGE + RECOMMENDATION) with the canonical three-field format (SCOPE + CHANGE + WHY) in the Verdict Format section of `nefario/AGENT.md`. Add the plan-internal reference prohibition. Document that Phase 5 findings use a separate format and why.

**Deliverables**: Updated `nefario/AGENT.md` Verdict Format section.

**Dependencies**: None (this is the canonical definition that other files reference).

#### Task B: Update SKILL.md advisory surfaces

**What**: Update all advisory-related format definitions in `skills/nefario/SKILL.md`:
1. Execution plan ADVISORIES block format (Surface 2, around line 1283)
2. Inline summary template Verdict field (Surface 3, around line 348)
3. Phase 3.5 reviewer prompt instructions (around line 1089) -- add the plan-internal reference prohibition to the reviewer prompt template
4. Phase 5 code review prompt (around line 1664) -- document the format relationship to Phase 3.5 advisories (no structural change needed)

**Deliverables**: Updated `skills/nefario/SKILL.md` across four sections.

**Dependencies**: Task A (canonical format must be defined first).

#### Task C: Update execution report template

**What**: Update the ADVISE line format in `docs/history/nefario-reports/TEMPLATE.md` (Surface 4) to use the canonical three-field structure instead of freeform text.

**Deliverables**: Updated TEMPLATE.md Architecture Review subsection formatting rules.

**Dependencies**: Task A.

#### Task D: Update reviewer agent prompts (lucy/AGENT.md, margo/AGENT.md)

**What**: Add the canonical advisory format and plan-internal reference prohibition to the output standards of `lucy/AGENT.md` and `margo/AGENT.md`. These agents produce verdicts during Phase 3.5 and Phase 5 and need to know the expected format.

**Deliverables**: Updated output standards sections in both files.

**Dependencies**: Task A.

**Note**: Other reviewers (security-minion, test-minion, ux-strategy-minion, discretionary reviewers) receive the format via the reviewer prompt template in SKILL.md (Task B). Lucy and margo are the only reviewers with persistent AGENT.md files that contain verdict format instructions.

### Risks and Concerns

1. **SCOPE field naming ambiguity**: "SCOPE" could be confused with scope-as-in-project-scope. Considered alternatives: TARGET (too aggressive), ARTIFACT (too narrow -- advisories can concern concepts, not just files), SUBJECT (too generic), AFFECTS (verb, not noun). SCOPE is the clearest term for "what part of the system this concerns" and aligns with how the word is used in documentation contexts. However, if other planners prefer a different name, the three-field structure is what matters, not the label.

2. **Backward compatibility of existing reports**: Past execution reports in `docs/history/nefario-reports/` use the old freeform advisory format. These are historical records and should not be retroactively updated. The TEMPLATE.md change applies only to future reports. This is consistent with the project's existing "deprecate, don't delete" pattern.

3. **Agent compliance risk**: Reviewer agents (especially those running on sonnet) may not consistently produce the three-field format even when instructed. Mitigation: the plan-internal reference prohibition is the critical instruction because it prevents the worst failure mode (opaque "Task 3" references). The three-field structure is a secondary quality improvement. The reviewer prompt template should include a brief example showing correct and incorrect format.

4. **Phase 5 format divergence**: Phase 5 code review findings intentionally use a different format (`<file>:<line-range>` instead of SCOPE) because they operate at line-level granularity. This is correct and should be documented, not "unified" into a single format. The risk is that someone later tries to force Phase 5 into the SCOPE/CHANGE/WHY format, which would lose the precision of file:line references.

5. **Inline summary compression**: The inline summary template (Surface 3) has tight token constraints (~80-120 tokens). Fitting three fields into the Verdict line may require truncation rules. The recommendation to truncate after 200 chars with `(+N more in scratch file)` handles this, but it should be explicitly stated in the format definition.

### Additional Agents Needed

None. The current team covers the relevant concerns:
- ai-modeling-minion can advise on prompt compliance (whether agents will reliably follow the format)
- lucy covers intent alignment (whether the format change serves the stated goal)
- margo covers simplicity (whether three fields is the minimum viable set)
- ux-strategy-minion covers readability (whether the format is scannable across surfaces)

The changes are entirely within nefario orchestration files and reviewer agent definitions -- no infrastructure, frontend, or security agents are needed.
