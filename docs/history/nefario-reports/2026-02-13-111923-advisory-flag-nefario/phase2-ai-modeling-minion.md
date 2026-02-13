## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (a) What MODE does nefario receive for advisory synthesis?

**Recommendation: Use the existing `MODE: SYNTHESIS` with an `ADVISORY: true` directive, not a new `MODE: ADVISORY`.**

The prior analysis (Feb 13 advisory report) proposed `MODE: ADVISORY` as a new nefario invocation mode. After re-reading AGENT.md, I recommend against adding a fourth mode. Here is why:

The existing modes in AGENT.md (META-PLAN, SYNTHESIS, PLAN) each describe a distinct *phase* of orchestration. MODE is a phase selector, not an output-format selector. Advisory mode does not change which phase runs -- Phase 3 synthesis still runs. What changes is the *output format* of synthesis. Adding `MODE: ADVISORY` conflates two orthogonal axes: "which phase am I in" (META-PLAN, SYNTHESIS, PLAN) and "what kind of output should I produce" (execution plan vs. advisory report).

Instead, the SKILL.md Phase 3 synthesis prompt should pass `ADVISORY: true` as a directive alongside `MODE: SYNTHESIS`. Nefario's AGENT.md needs a conditional in the SYNTHESIS working pattern: "If ADVISORY is set, produce an advisory report instead of a delegation plan." This keeps the mode axis clean and the advisory flag orthogonal.

The Phase 1 meta-plan prompt does NOT need an ADVISORY directive. Phase 1's job is "which specialists should contribute" -- this is identical for advisory and execution orchestrations. The meta-plan output format does not change. The SKILL.md simply does not pass advisory state to the Phase 1 subagent.

**Concrete mechanism in SKILL.md**:
- Parse `--advisory` from arguments (per devx-minion's interface design)
- Store as boolean `advisory-mode` in session context
- Phase 1: no change to nefario prompt
- Phase 2: no change to specialist prompts (the prompt template already works for advisory -- we are in one right now)
- Phase 3: add `ADVISORY: true` to the nefario synthesis prompt
- After Phase 3: if `advisory-mode`, branch to advisory wrap-up; skip Phases 3.5-8

#### (b) Exact output format for advisory synthesis

The nefario AGENT.md SYNTHESIS section needs a conditional output format. When `ADVISORY: true` is present in the synthesis prompt, nefario produces this instead of the delegation plan:

```markdown
## Advisory Report

**Question**: <the original task/question being evaluated>
**Confidence**: HIGH | MEDIUM | LOW
**Recommendation**: <1-2 sentence recommendation>

### Executive Summary

<2-3 paragraphs. Answer the question. State the recommendation. Note the
confidence level and what drives it.>

### Team Consensus

<Areas where all specialists agreed. Numbered list of consensus points.>

### Dissenting Views

<Where specialists disagreed. For each disagreement:>
- **<Topic>**: <Agent A> recommends X because [reason]. <Agent B> recommends Y because [reason]. Resolution: <how nefario resolved it, or "unresolved -- presented for user judgment">.

### Supporting Evidence

<Key findings organized by domain. One H4 per specialist domain.>

#### <Domain 1>
<Findings relevant to the recommendation>

#### <Domain 2>
<Findings>

### Risks and Caveats

<What could invalidate the recommendation. Numbered list.>
1. <risk>: <condition under which the recommendation fails>

### Next Steps

<If the recommendation is adopted, what the implementation path looks like.
This section naturally feeds into a follow-up `/nefario` execution if the user
decides to proceed.>

### Conflict Resolutions

<Description of conflicts between specialist recommendations and how they were
resolved. "None." if no conflicts arose.>
```

**Why this format and not the delegation plan format:**

1. **No tasks, no agents, no gates.** Advisory output has no execution dimension. Including Task/Agent/Gate fields would be misleading or empty.
2. **Deliberation is the deliverable.** The user wants to see the reasoning, not just the conclusion. Consensus/Dissent/Evidence sections preserve the full deliberation arc.
3. **Confidence is explicit.** Unlike execution plans where confidence is per-gate, advisory confidence is a single assessment of the recommendation's strength.
4. **Next Steps bridges to execution.** If the user likes the recommendation, they can `/nefario` the implementation. This section makes that handoff explicit.
5. **Conflict Resolutions is retained.** Same as in the execution report template -- it tracks when specialists disagreed and how nefario resolved it.

**Key constraint for the synthesis prompt:** The prompt must explicitly instruct nefario: "Do NOT produce task prompts, agent assignments, execution order, or approval gates. This is an advisory synthesis, not an execution plan."

#### (c) What AGENT.md changes are needed

Three changes to `nefario/AGENT.md`:

**Change 1: Add ADVISORY directive to Invocation Modes section (after the MODE descriptions)**

Add a new subsection:

```markdown
## Advisory Directive

When your prompt includes `ADVISORY: true`, you are producing an advisory
report instead of an execution plan. This directive is orthogonal to MODE --
it modifies the output format of SYNTHESIS mode.

- `MODE: SYNTHESIS` + `ADVISORY: true` = produce an advisory report
- `MODE: META-PLAN` + `ADVISORY: true` = no effect (meta-plan is unchanged)
- `MODE: PLAN` + `ADVISORY: true` = produce an advisory report directly (skip specialist consultation)
```

**Change 2: Add advisory output format to MODE: SYNTHESIS working pattern**

In the "MODE: SYNTHESIS" section, after the existing delegation plan format, add a conditional:

```markdown
### Advisory Output (when ADVISORY: true)

When the prompt includes `ADVISORY: true`, produce an advisory report instead
of a delegation plan. Use the advisory report format (see above).

Do NOT produce:
- Task prompts or agent assignments
- Execution order or batch boundaries
- Approval gates
- Architecture review agent lists
- Cross-cutting coverage checklist (the advisory report covers cross-cutting
  concerns through the Supporting Evidence section)

DO produce:
- Executive summary answering the question
- Team consensus and dissenting views
- Recommendation with confidence level
- Risks and caveats
- Next steps for implementation (if recommendation is adopted)
- Conflict resolutions
```

**Change 3: Document advisory synthesis in MODE: PLAN**

Add a note to MODE: PLAN:

```markdown
When `ADVISORY: true` is set, MODE: PLAN produces an advisory report directly
without specialist consultation. The output format is the same advisory report
format as MODE: SYNTHESIS + ADVISORY.
```

**No other AGENT.md changes needed.** The delegation table, cross-cutting checklist, task decomposition principles, and approval gate logic are all execution-phase concepts that advisory mode skips entirely. They do not need modification.

#### (d) How does Phase 1 meta-plan prompt differ for advisory?

**It does not.**

Phase 1's purpose is: "Analyze the task and determine which specialists should be consulted for planning." This is identical for advisory and execution orchestrations. The meta-plan answers "who should weigh in" -- the same specialists are relevant regardless of whether the outcome is code changes or a recommendation.

The SKILL.md meta-plan prompt template (the `MODE: META-PLAN` spawn) does not need any advisory-specific content. The meta-plan output format is unchanged. The cross-cutting checklist is unchanged (it governs agent inclusion in planning, not execution -- and advisory planning is still planning).

Evidence: the current orchestration we are in right now is an advisory-mode session. Phase 1 ran identically. Phase 2 (this contribution) ran identically. The specialists are providing the same kind of domain expertise they would for an execution orchestration. The divergence happens in Phase 3, not Phase 1.

One subtlety: the Phase 1 meta-plan currently says "Anticipated Approval Gates" as a subsection. For advisory orchestrations, this subsection would be empty or "None (advisory mode)". However, this is not a prompt change -- nefario will naturally produce "None" here when the task is advisory because there are no execution gates. No special handling is needed.

### Proposed Tasks

#### Task 1: Update nefario AGENT.md with advisory directive and synthesis format
- **What**: Add the three AGENT.md changes described in section (c) above. Add the Advisory Directive subsection to Invocation Modes. Add the advisory output format to MODE: SYNTHESIS. Add advisory note to MODE: PLAN.
- **Deliverables**: Modified `nefario/AGENT.md`
- **Dependencies**: None (can run in parallel with SKILL.md changes if file ownership is clear)
- **Agent**: ai-modeling-minion (prompt engineering for the synthesis directive) or devx-minion (AGENT.md structure)

#### Task 2: Add advisory synthesis prompt to SKILL.md Phase 3
- **What**: Modify the Phase 3 synthesis prompt template in SKILL.md to include `ADVISORY: true` when `advisory-mode` is set. Add the negative constraint ("Do NOT produce task prompts...").
- **Deliverables**: Modified section of `skills/nefario/SKILL.md` Phase 3
- **Dependencies**: Task 1 (AGENT.md must define the format before SKILL.md references it)

#### Task 3: Add advisory branch after Phase 3 in SKILL.md
- **What**: After Phase 3 synthesis returns, add a conditional: "If advisory-mode, skip to advisory wrap-up." The advisory wrap-up is a simplified version of the existing wrap-up: write report, commit, present path to user. No branch creation, no PR, no Phases 3.5-8.
- **Deliverables**: Modified section of `skills/nefario/SKILL.md` (post-Phase 3 and advisory wrap-up)
- **Dependencies**: Task 2

#### Task 4: Add `mode: advisory` to report template
- **What**: Extend the `mode` field in TEMPLATE.md from `{full | plan}` to `{full | plan | advisory}`. Add conditional section rules for advisory reports: include Summary, Original Prompt, Key Findings (renamed from Key Design Decisions), Phases (1-3 only), Agent Contributions (planning only), Working Files. Omit Execution, Verification, Test Plan, Decisions, External Skills.
- **Deliverables**: Modified `docs/history/nefario-reports/TEMPLATE.md`
- **Dependencies**: None (can run in parallel with Tasks 1-3)

### Risks and Concerns

1. **PLAN + ADVISORY interaction complexity.** Supporting `MODE: PLAN` + `ADVISORY: true` (advisory without specialist consultation) adds a code path that may not be tested. This combination is conceptually valid but low-priority. Recommendation: document it in AGENT.md as specified above, but do not add SKILL.md support for `--plan --advisory` in the initial implementation. If someone tries it, nefario will interpret it via natural language, which is margo's "step 0" from the prior synthesis.

2. **Synthesis prompt token overhead.** Adding the advisory output format to AGENT.md adds approximately 200-250 tokens to the system prompt. This is within the cacheable system prompt, so the cost is a one-time cache write penalty. Given that nefario already runs on opus with a large system prompt, this is negligible.

3. **Advisory report format may need iteration.** The format proposed here is based on one precedent (the overlay removal advisory) and one in-progress use (this session). Two data points is enough to define a reasonable starting format, but the format should be treated as v1 with expectation of refinement after 3-5 more uses.

4. **Negative constraint reliability.** The instruction "Do NOT produce task prompts" in the synthesis prompt is critical -- without it, nefario's training on the delegation plan format may cause it to produce hybrid output. This is a prompt engineering concern I can address directly: the negative constraint should be positioned immediately after the `ADVISORY: true` directive, before any other synthesis instructions, and should be in an imperative voice ("Do NOT produce...") rather than a descriptive voice ("Advisory reports do not include..."). Imperative framing is more reliably followed by Claude models in constrained-output scenarios.

5. **Report directory conventions.** Advisory reports go to `docs/history/nefario-reports/` with the same naming convention as execution reports. This is correct and consistent. The `mode: advisory` frontmatter enables `build-index.sh` to differentiate them if filtering is ever needed.

### Additional Agents Needed

None. The current planning team covers the necessary dimensions:
- devx-minion for argument parsing and SKILL.md interface design
- ai-modeling-minion (this contribution) for prompt engineering and synthesis behavior
- lucy and margo for governance review of the proposed changes

The changes are internal to the orchestration system. No security surface, no user-facing UI, no infrastructure, no testing framework changes.
