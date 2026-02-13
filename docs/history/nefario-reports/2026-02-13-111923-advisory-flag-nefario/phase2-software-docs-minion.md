## Domain Plan Contribution: software-docs-minion

### Recommendations

#### (a) Section-by-section analysis: apply, modify, or omit

I compared the existing TEMPLATE.md (v3) against the exemplar advisory report
(`2026-02-13-101746-advisory-mode-flag-vs-separate-skill.md`) section by section.

| Template Section | Advisory Mode | Rationale |
|-----------------|---------------|-----------|
| **Frontmatter** | MODIFY | `mode: advisory` (new value). `task-count: 0`, `gate-count: 0` are natural since no execution occurs. All other fields unchanged. |
| **Summary** | APPLY as-is | Advisory reports need summaries. |
| **Original Prompt** | APPLY as-is | Same collapsibility rules. |
| **Key Design Decisions** | APPLY as-is | Advisory orchestrations produce design decisions -- this is their primary output. Conflict Resolutions subsection also applies. |
| **Phases** | MODIFY | Phases 1-3 get full narrative. Phases 3.5-8 get a single collapsed line: "Skipped (advisory-only orchestration)." The exemplar already demonstrates this pattern. |
| **Agent Contributions** | MODIFY | Only "Planning" subsection applies. "Architecture Review" and "Code Review" subsections are omitted (no reviews occur). The collapsed summary changes from `({N} planning, {N} review)` to `({N} planning)`. |
| **Team Recommendation** | NEW SECTION | This is the core deliverable of advisory mode. See (b) below. |
| **Execution** | OMIT | No tasks, no files changed, no approval gates. |
| **Decisions** | OMIT | No gates, so `gate-count: 0` triggers existing conditional omission rule. |
| **Verification** | OMIT | No post-execution phases ran. |
| **External Skills** | CONDITIONAL (existing rule) | Same rule: include if meta-plan discovered skills; omit otherwise. Advisory runs can discover external skills just as well as full runs. |
| **Working Files** | APPLY as-is | Advisory runs produce scratch files (phase1, phase2-*, phase3). Same companion directory structure. |
| **Test Plan** | OMIT | No tests produced. |
| **Post-Nefario Updates** | OMIT | Same existing rule: never in initial report. Additionally, advisory reports are unlikely to receive updates since no branch/PR exists. |

#### (b) New section needed: Team Recommendation

The exemplar demonstrates a well-structured "Team Recommendation" section that
is the primary deliverable of advisory mode. It replaces the Execution section
as the report's action output. Structure from the exemplar:

```markdown
## Team Recommendation

**{One-line recommendation.}** {Optional qualifying sentence.}

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| {position} | {agents} | {strength assessment} |

### When to Revisit

{Conditions under which the recommendation should be re-evaluated.}
Numbered list of concrete trigger conditions.

### Escalation Path (when trigger fires)

{Graduated steps for implementation if/when triggers fire.}

### Strongest Arguments

**For {adopted position}** (adopted):

| Argument | Agent |
|----------|-------|
| {argument} | {agent} |

**For {rejected position}** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| {argument} | {agent} |
```

The subsections should be treated as guidelines, not rigid requirements.
Different advisory questions will produce different recommendation shapes.
The Consensus table and one-line recommendation are always required.
When to Revisit, Escalation Path, and Strongest Arguments are recommended
but can be omitted if not applicable to the question.

#### (c) How `mode: advisory` interacts with conditional section rules

The existing conditional rules in the TEMPLATE.md Conditional Section Rules
table are already mode-independent -- they trigger on data presence
(`gate-count > 0`, "meta-plan discovered skills", etc.). Advisory mode
naturally produces the right data values for existing rules to fire correctly:

- `gate-count: 0` already omits the Decisions section
- `task-count: 0` means the Execution section has nothing to show
- External Skills rule is data-driven, works for both modes

The only additions needed to the conditional rules table are:

| Section | INCLUDE WHEN | OMIT WHEN |
|---------|-------------|-----------|
| Team Recommendation | `mode` = `advisory` | `mode` != `advisory` |
| Execution | `mode` != `advisory` | `mode` = `advisory` |
| Verification | `mode` != `advisory` | `mode` = `advisory` |
| Agent Contributions: Architecture Review | Phase 3.5 ran | `mode` = `advisory` or Phase 3.5 skipped |
| Agent Contributions: Code Review | Phase 5 ran | `mode` = `advisory` or Phase 5 skipped |

This approach is clean: existing data-driven conditionals handle most cases
naturally, and only 3 explicit mode-driven rules are needed (Team Recommendation,
Execution, Verification).

#### (d) Single template with conditionals vs. separate template file

**Strong recommendation: single template with conditionals.** Reasons:

1. **The exemplar proves 80%+ structural overlap.** Frontmatter, Summary,
   Original Prompt, Key Design Decisions, Phases, Agent Contributions, Working
   Files -- all shared. Only 3 sections differ (Team Recommendation replaces
   Execution + Verification).

2. **Fork maintenance is the exact same argument that killed the separate-skill
   option.** The prior advisory report unanimously rejected a separate skill
   because of fork maintenance. A separate template file creates the same
   problem at smaller scale: every template update requires mirroring.

3. **The conditional rules mechanism already exists.** TEMPLATE.md already has
   a Conditional Section Rules table. Advisory mode adds 3-5 entries to that
   table. This is the minimum-complexity path.

4. **Single source of truth.** One template means one place to check frontmatter
   schema, formatting rules, collapsibility rules, and section ordering. The
   Report Writing Checklist at the bottom can add advisory-specific steps
   inline.

5. **Template version stays at v3.** Adding `advisory` to the `mode` enum and
   a few conditional rules is a minor change, not a structural overhaul.
   However, if the team prefers, bumping to v4 to mark the mode expansion is
   defensible.

### Proposed Tasks

#### Task 1: Extend TEMPLATE.md with advisory mode support

**What**: Modify `docs/history/nefario-reports/TEMPLATE.md` to support `mode: advisory`.

**Deliverables**:
- Add `advisory` to the `mode` field description in Frontmatter Fields table
- Add the Team Recommendation section to the skeleton (positioned between
  Agent Contributions and Execution, with a conditional comment)
- Add 5 new rows to the Conditional Section Rules table (Team Recommendation,
  Execution, Verification, Agent Contributions subsections)
- Add advisory-specific notes to the Formatting Rules section (Team
  Recommendation formatting guidance)
- Add advisory steps to the Report Writing Checklist
- Update the Phases section skeleton to show the advisory pattern (Phases
  3.5-8 collapsed as "Skipped")

**Dependencies**: None (this is the first task).

#### Task 2: Update SKILL.md report generation instructions

**What**: Modify the Report Generation section of `skills/nefario/SKILL.md`
to reference the advisory template rules.

**Deliverables**:
- Update Data Accumulation to note that advisory mode stops tracking after
  Phase 3 (no Phase 3.5-8 data points)
- Update Wrap-up Sequence for advisory mode: no branch, no PR, no
  verification summary, but report + companion directory are still produced
- Add advisory-specific report writing guidance referencing the TEMPLATE.md
  conditional rules

**Dependencies**: Task 1 (template must be finalized first so SKILL.md can
reference it accurately).

#### Task 3: Validate against exemplar

**What**: Verify the modified TEMPLATE.md produces output matching the
exemplar advisory report structure.

**Deliverables**:
- Walk through the modified template section by section and confirm the
  exemplar would be valid under the new rules
- Identify any exemplar patterns not captured by the template (edge cases)
- Document any discrepancies and resolve them

**Dependencies**: Task 1.

### Risks and Concerns

1. **Team Recommendation section is under-specified for diverse use cases.**
   The exemplar is a binary decision question ("flag vs. separate skill").
   Advisory runs may also evaluate technology choices, architecture tradeoffs,
   or process improvements. The template guidance should be flexible enough
   for varied recommendation shapes without being so loose that reports
   become inconsistent. Mitigated by making subsections (When to Revisit,
   Escalation Path, Strongest Arguments) recommended but optional.

2. **Template complexity creep.** TEMPLATE.md is already 327 lines. Adding
   advisory conditionals increases cognitive load for report generation.
   Mitigated by keeping the conditional rules table-driven (declarative, not
   procedural) and using clear mode-based guards.

3. **`build-index.sh` compatibility.** The index builder reads YAML frontmatter
   from all reports. Adding `mode: advisory` must not break the index script.
   The script should already handle any `mode` string value, but this needs
   verification.

4. **Incremental writing guidance mismatch.** The template says "write a
   partial report after Phase 3." For advisory mode, Phase 3 IS the final
   phase. The incremental writing section should clarify that advisory
   reports are written once at wrap-up, not incrementally.

### Additional Agents Needed

**devx-minion** should review the template changes for consistency with the
argument parsing and mode detection logic they are designing. The template's
`mode: advisory` conditional rules must align with how nefario determines
and propagates the advisory flag through the orchestration phases. Since
devx-minion is likely already part of this planning round, this is a
coordination note rather than a new agent request.

Beyond that: None. The template modifications are squarely in the
documentation domain. The SKILL.md updates are a downstream dependency
that the nefario orchestrator itself (or ai-modeling-minion) will handle
for the behavioral logic; software-docs-minion's contribution is ensuring
the template and report structure are correct.
