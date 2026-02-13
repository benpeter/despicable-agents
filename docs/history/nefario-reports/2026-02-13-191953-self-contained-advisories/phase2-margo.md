## Domain Plan Contribution: margo

### Recommendations

**Core answer: Change the instructions, not the structure.**

The existing format (CHANGE + WHY, 3-line cap per advisory) is the right shape.
The problem is not missing fields -- it is vague content inside the existing
fields. The fix is better authoring instructions for the agents that produce
advisories, not new fields or restructured formats.

Here is why:

1. **The 3-line cap is load-bearing.** Advisories appear in the execution plan
   approval gate. The user scans them to decide "approve / request changes."
   If advisories become multi-paragraph explanations, the gate becomes a wall of
   text and the user either rubber-stamps or abandons the process. The 3-line cap
   directly serves the "quick-scan" purpose stated in the planning question.

2. **The two existing fields already cover the success criteria -- if filled
   correctly.** The success criteria ask for: what artifact is affected (belongs
   in the header line + CHANGE), what is proposed (CHANGE), and why (WHY). No
   new field is needed. The problem is that current instructions allow agents to
   write "Task 3: Update config handling" when they should write
   "Task 3: SKILL.md advisory format -- add artifact naming requirement."

3. **Adding fields (e.g., ARTIFACT, SCOPE, IMPACT) would create accidental
   complexity.** More fields means more parsing rules, more things nefario must
   validate, more cognitive load per advisory. This is the classic over-structuring
   failure: solving a content quality problem with format machinery.

**The minimum change is a set of content constraints added to existing
instructions.** Specifically:

- **Header line** (`[<domain>] Task N: <task title>`): Already contains the task
  title. The task title itself must name the artifact or concept -- not be a
  generic label. This is already enforced by the synthesis format (task titles
  are specific). No change needed to the header format, but the advisory
  instructions should state: "Use the full task title. Do not abbreviate to
  'the approach' or 'step 1'."

- **CHANGE field**: Current instruction says "one sentence describing the
  concrete change to the task." Add a constraint: "Must name the specific file,
  config key, API endpoint, format, or concept being changed. Must not reference
  plan-internal structure ('step 2', 'the first phase', 'the approach')."

- **WHY field**: Current instruction says "one sentence explaining the concern
  that motivated it." Add a constraint: "Must state the risk or rationale using
  facts present in this sentence. Must not reference context only visible in the
  reviewer's session ('as discussed', 'per the analysis', 'given the above')."

- **Verdict format in nefario AGENT.md**: The ADVISE verdict format has a
  `TASK: <task number affected, e.g., "Task 3">` field and a
  `RECOMMENDATION: <suggested change>` field. Apply the same content constraints:
  TASK should include the task title (not just "Task 3"), and RECOMMENDATION
  should name the artifact and proposed change in domain terms.

**Anti-bloat constraints** (these are the guardrails the planning question asks for):

1. **3-line cap stays.** Do not raise it. If an advisory needs more than 3 lines,
   the existing Details link mechanism handles it.
2. **One sentence per field.** CHANGE and WHY each get one sentence. Not a
   paragraph. Not a bulleted list.
3. **No new fields.** The format stays at header + CHANGE + WHY. No ARTIFACT,
   SCOPE, IMPACT, CONTEXT, or other additions.
4. **Self-containment test**: "Could someone reading only this advisory block
   answer: what file/concept, what change, why?" If yes, the advisory passes.
   If no, the CHANGE or WHY field needs rewriting -- not a new field.

### Proposed Tasks

**Task 1: Update advisory authoring instructions in SKILL.md**
- **What**: In the "Advisory principles" section of SKILL.md (around line 1295),
  add content constraints to the CHANGE and WHY field descriptions. Add the
  self-containment test as a validation rule. Keep the 3-line cap. Keep the
  existing format structure unchanged.
- **Deliverables**: Updated SKILL.md with tightened field instructions.
- **Dependencies**: None.

**Task 2: Update ADVISE verdict format instructions in nefario AGENT.md**
- **What**: In the "Verdict Format" section of nefario/AGENT.md (around line 660),
  update the ADVISE verdict template so TASK includes the task title (not just
  number) and RECOMMENDATION names the artifact/concept. Add a one-line
  instruction that the verdict must be readable without access to the plan.
- **Deliverables**: Updated nefario/AGENT.md verdict format section.
- **Dependencies**: None (can run in parallel with Task 1).

**Task 3: Update reviewer prompt templates in SKILL.md**
- **What**: In the Phase 3.5 reviewer prompt template (around line 1090) and
  the Phase 5 code review prompt template (around line 1665), add a one-line
  instruction: "Your verdict must be self-contained. Name specific files,
  formats, or concepts -- do not reference plan step numbers or context not
  present in your output." This is 1-2 lines added to each prompt template.
- **Deliverables**: Updated SKILL.md reviewer prompt templates.
- **Dependencies**: None (can run in parallel with Tasks 1-2, but same file as
  Task 1 -- needs file ownership resolution or sequencing).

**Note on file ownership**: Tasks 1 and 3 both modify SKILL.md. They should
either be sequenced (Task 1 then Task 3) or combined into a single task.
I recommend combining them into one task since both are small, targeted
changes to the same file.

### Risks and Concerns

1. **Risk: Instructions are ignored under token pressure.** Agents operating
   near context limits may drop nuanced formatting instructions. Mitigation:
   keep the added instructions short (1-2 sentences per constraint, not a
   paragraph of explanation). The self-containment test is the anchor --
   it is a single yes/no question agents can apply.

2. **Risk: Over-correction toward verbosity.** If agents interpret
   "self-contained" as "include all context," advisories could balloon.
   Mitigation: the 3-line cap is a hard constraint that physically prevents
   this. The one-sentence-per-field rule further bounds it. These constraints
   already exist; we are not relaxing them.

3. **Risk: Scope creep into verdict routing or phase mechanics.** The planning
   question explicitly scopes out verdict routing and phase sequencing. The
   proposed changes are content instructions only -- they do not change how
   verdicts flow between phases or how nefario processes them.

4. **Concern: Two files modified (SKILL.md and AGENT.md) risks divergence.**
   The advisory format is defined in SKILL.md (for the orchestration skill)
   and the verdict format is defined in AGENT.md (for reviewers). These two
   definitions must stay consistent. The task prompts should reference each
   other's sections to confirm alignment.

### Additional Agents Needed

None. This is a documentation/instruction change to two files (SKILL.md and
nefario/AGENT.md). The changes are small, targeted text edits. No additional
domain expertise is needed beyond what nefario and the implementing agent
bring. Lucy should review for intent alignment as part of the standard Phase 3.5
review, but that happens automatically -- no special inclusion needed.
