# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### 1. Define the advisory as a structured output schema, not a prose template

The current AGENT.md verdict format (TASK/CHANGE/RECOMMENDATION) and the SKILL.md
execution plan gate format (CHANGE/WHY) are specified as prose templates inside
multi-page instructions. Real reviewer outputs (see actual phase3.5 files from
past orchestrations) consistently ignore the structured format and produce
freeform numbered lists instead. This is a predictable LLM behavior: when a
format spec is buried deep in a long system prompt and competes with the
natural-language instruction "Be concise. Only flag issues within your domain
expertise", the model defaults to what feels concise -- freeform text.

**Recommendation**: Replace the prose template with a field-level specification
that uses explicit XML tags. XML tags are the strongest format-enforcement
mechanism available in Claude prompts (Claude is fine-tuned to attend to them).
The reviewer prompt should include the advisory format inline, not rely on the
reviewer's AGENT.md to define it, because reviewers are spawned as subagents
with their own AGENT.md as system prompt -- they need the output format in the
task-specific prompt where it gets highest attention.

### 2. Use a "name the thing" field instead of task references

The current format uses `TASK: <task number affected>`, which creates the
self-referential problem: "Task 3" is meaningless outside the plan context.
Replace this with two fields that ground the advisory in the codebase and the
plan simultaneously:

- **SUBJECT**: Name the concrete artifact, file, concept, or system boundary
  (e.g., "SKILL.md Phase 4 execution loop", "nefario/AGENT.md verdict format",
  "OAuth token refresh flow in auth.ts"). This is the field that makes the
  advisory readable in isolation.
- **TASK**: Keep the task number as a machine-linkable cross-reference for the
  orchestrator to use when folding advisories into task prompts. This field is
  for routing, not for human comprehension.

The SUBJECT field is the key design decision. It forces the reviewer to name
what they are talking about in domain terms. When injected into an execution
agent's prompt, the execution agent can grep/find the artifact. When read by a
human in a report, it immediately answers "what part of the system does this
affect?"

### 3. Restructure the reviewer prompt to produce self-contained advisories

The current reviewer prompt template (SKILL.md line 1074-1096) gives minimal
output guidance: "ADVISE: <list specific non-blocking warnings>". This is too
open-ended. The reviewer prompt should include:

1. The exact output schema with field names and one-sentence field descriptions
2. One concrete example showing a well-formed advisory (the strongest format
   enforcement mechanism -- the model mirrors examples precisely)
3. An explicit instruction that each advisory must be understandable without
   reading the delegation plan

Proposed reviewer prompt advisory section (to replace the current ADVISE line
in the verdict instructions):

```
Return exactly one verdict:
- APPROVE: No concerns from your domain.
- ADVISE: Return warnings using this exact format for each concern:

  <advisory>
  <subject>Name the specific file, component, or concept affected</subject>
  <task>Task N</task>
  <change>One sentence: what should change in this task's scope or approach</change>
  <why>One sentence: the risk or gap, using only information present in this advisory</why>
  </advisory>

  Example:
  <advisory>
  <subject>skills/nefario/SKILL.md Phase 4 execution loop</subject>
  <task>Task 2</task>
  <change>Add error handling for agent timeout after 5 minutes of no response</change>
  <why>Execution agents can hang on network-dependent operations, leaving the orchestrator blocked indefinitely</why>
  </advisory>

  Each advisory must be understandable without reading the delegation plan.
  The subject field names the artifact, not a plan-internal reference.

- BLOCK: <describe the blocking issue and what must change>
```

### 4. Transform advisory format at the orchestrator level, not the reviewer level

Advisories flow through three surfaces:
1. **Reviewer output** (phase3.5-{reviewer}.md) -- raw verdict
2. **Execution plan approval gate** (user-facing, in chat) -- condensed delta format
3. **Execution agent prompt** (LLM-facing, folded into task prompt) -- actionable instruction

The current system uses a single format (CHANGE/WHY) for surfaces 2 and 3, and
a different format (TASK/CHANGE/RECOMMENDATION) for surface 1. This creates a
translation step that the SKILL.md orchestration logic must perform, but the
translation rules are implicit ("fold into relevant task prompts").

**Recommendation**: Use the XML-tagged format at the reviewer level (surface 1),
then define explicit transformation rules for surfaces 2 and 3:

- **Surface 2 (approval gate)**: Strip XML tags, present as:
  ```
  [domain] Task N: <task title> -- <subject>
    CHANGE: <change field value>
    WHY: <why field value>
  ```
  The `-- <subject>` suffix after the task title makes the gate presentation
  self-contained. The task title provides plan context; the subject provides
  domain context.

- **Surface 3 (execution agent prompt)**: Inject as a clearly delimited block:
  ```
  ## Review Advisory
  The following concern was raised during architecture review:
  - Subject: <subject>
  - Change: <change>
  - Why: <why>
  Incorporate this guidance into your work.
  ```
  The `Subject:` field gives the execution agent a grep target. The `Change:`
  field tells it what to do. The `Why:` field gives it enough context to
  generalize if the exact suggestion does not apply perfectly.

### 5. Align the AGENT.md and SKILL.md verdict formats

Currently AGENT.md defines TASK/CHANGE/RECOMMENDATION fields and SKILL.md
defines CHANGE/WHY fields. These are two different schemas for the same
concept, with different field names and different semantics (RECOMMENDATION vs
WHY). This divergence means an LLM reading both files will pick whichever feels
more salient in context, producing inconsistent outputs.

**Recommendation**: Define the verdict format in exactly one place. The AGENT.md
should reference the format but not redefine it. The canonical definition should
live in the reviewer prompt template in SKILL.md (where it is actually consumed).
AGENT.md should say:

```
**ADVISE** -- Non-blocking warnings. Format defined by the reviewer prompt
template in the orchestration skill. Each advisory identifies the affected
artifact (SUBJECT), the target task (TASK), the proposed change (CHANGE),
and the motivation (WHY).
```

This eliminates the dual-definition problem entirely.

### 6. Handle the BLOCK format symmetrically

The BLOCK format (ISSUE/RISK/SUGGESTION) already names its fields but does not
include a SUBJECT field. When a BLOCK is escalated to the user (in the impasse
format or revision loop), it suffers the same readability problem: "the blocking
concern" without naming what it concerns. Apply the same SUBJECT field to BLOCK
verdicts:

```
VERDICT: BLOCK
SUBJECT: <artifact or concept affected>
ISSUE: <description>
RISK: <consequence>
SUGGESTION: <resolution>
```

### 7. Provide a negative example in the reviewer prompt

Negative examples are highly effective at preventing the specific failure mode
this task addresses. Include one example of what NOT to produce:

```
BAD (not self-contained -- references invisible plan context):
<advisory>
<subject>step 1</subject>
<task>Task 3</task>
<change>The approach should also handle edge cases</change>
<why>The current plan does not cover this</why>
</advisory>

GOOD (self-contained -- names artifacts, states specifics):
<advisory>
<subject>nefario/AGENT.md verdict format definition</subject>
<task>Task 3</task>
<change>Add SUBJECT field requiring reviewers to name the affected file or component</change>
<why>Current advisories reference task numbers that are meaningless outside the planning session</why>
</advisory>
```

This costs approximately 120 tokens per reviewer prompt. At Sonnet pricing with
5 reviewers, that is ~$0.002 per orchestration -- negligible. The reliability
improvement is substantial.

## Proposed Tasks

### Task A: Update reviewer prompt template in SKILL.md

**Scope**: Replace the ADVISE line in the generic reviewer prompt template
(SKILL.md ~line 1090-1093) and the ux-strategy-minion prompt (~line 1124-1127)
with the XML-tagged advisory format including one positive example and one
negative example. Also update the BLOCK format to include SUBJECT.

**Files**: `skills/nefario/SKILL.md`

**Considerations**:
- The reviewer prompt is the most important edit because it is what the reviewer
  LLM actually sees. The system prompt (AGENT.md) is background; the task
  prompt is foreground.
- Both the generic reviewer template and the ux-strategy-specific template need
  the same update. Consider extracting the verdict format into a shared block
  that both templates reference (reduces maintenance burden and prevents drift).
- Token budget impact: ~120 tokens added per reviewer prompt. Five reviewers =
  ~600 tokens per orchestration. At Sonnet rates ($3/MTok input), this is
  $0.0018 per orchestration. Well within acceptable overhead.

### Task B: Update verdict format in nefario/AGENT.md

**Scope**: Replace the ADVISE format (TASK/CHANGE/RECOMMENDATION) and BLOCK
format (ISSUE/RISK/SUGGESTION) with the new schema (SUBJECT/TASK/CHANGE/WHY for
ADVISE, SUBJECT/ISSUE/RISK/SUGGESTION for BLOCK). Make AGENT.md reference the
SKILL.md template as the canonical definition rather than redefining the format.

**Files**: `nefario/AGENT.md`

### Task C: Update advisory presentation in execution plan approval gate

**Scope**: Update the advisory presentation format in the "Execution Plan
Approval Gate" section of SKILL.md to include the SUBJECT field. Change from:
```
[<domain>] Task N: <task title>
  CHANGE: ...
  WHY: ...
```
to:
```
[<domain>] Task N: <task title> -- <subject>
  CHANGE: ...
  WHY: ...
```

Also update the advisory folding instructions for execution agent prompts to
use the structured injection format (Subject/Change/Why block).

**Files**: `skills/nefario/SKILL.md`

### Task D: Update code review verdict format (Phase 5)

**Scope**: The Phase 5 code review prompt (SKILL.md ~line 1665) uses a similar
verdict format. Apply the same SUBJECT treatment: each finding should name the
file and line range (which it already does via `<file>:<line-range>`) but should
also work when the advisory is read outside the review context. Verify the Phase
5 format is already self-contained or update it to match.

**Files**: `skills/nefario/SKILL.md`

## Risks and Concerns

### Risk 1: Token overhead from examples in reviewer prompts

Adding a positive example, a negative example, and explicit field descriptions
to each reviewer prompt adds ~120-150 tokens. With 5-10 reviewers per
orchestration, this is 600-1500 tokens of additional input. At Sonnet pricing,
the cost is under $0.005 per orchestration.

**Mitigation**: The examples can be placed in the system prompt (reviewer
AGENT.md) rather than the task prompt, which would make them cacheable. However,
I recommend placing them in the task prompt for higher format compliance -- the
task prompt is the "foreground" the model pays most attention to. The cost is
negligible.

### Risk 2: XML tags may be over-engineered for this use case

XML tags add parsing overhead for the orchestrator (SKILL.md logic must extract
fields from XML). Plain-text field labels (SUBJECT: / TASK: / CHANGE: / WHY:)
are simpler to parse and equally effective for format enforcement when combined
with examples.

**Mitigation**: Evaluate both during implementation. XML tags are strongest for
format enforcement but plain-text labels with a clear example may be sufficient.
The key design requirement is the SUBJECT field, not the tag syntax. The
implementer should choose whichever is simpler to parse in the SKILL.md
orchestration logic. If the orchestrator is an LLM (which it is -- nefario
running as a subagent), XML and plain-text labels are equally parseable.

**Recommendation**: Start with plain-text field labels (SUBJECT/TASK/CHANGE/WHY)
given the project's preference for KISS. XML tags can be introduced later if
plain-text labels prove insufficient for format compliance.

### Risk 3: Existing reviewer agents may not comply with the new format

Reviewer agents (security-minion, test-minion, lucy, margo, etc.) each have
their own AGENT.md with behavioral instructions. If the reviewer's AGENT.md
encourages freeform output (e.g., "Be concise"), it may conflict with the
structured format requirement in the task prompt.

**Mitigation**: The task prompt overrides AGENT.md when there is a conflict --
this is standard LLM behavior (most recent instruction wins). The key is that
the reviewer prompt must include the format spec with examples, not just
reference it. The reviewer AGENT.md does not need to change for the format to
work, but it should not actively contradict it.

### Risk 4: Backward compatibility with existing report template

The report template (TEMPLATE.md) includes advisory presentation rules
("ADVISE = 2-3 lines: verdict + concern + recommendation"). If the advisory
format changes, the report template needs corresponding updates.

**Mitigation**: Include TEMPLATE.md in scope. The change is small (update the
formatting rule to reference SUBJECT field). Check if any report generation
logic in SKILL.md needs updating.

## Additional Agents Needed

**lucy** should review this plan because the advisory format change touches
governance surfaces (verdict format, approval gate presentation) and could
drift from user intent if the format becomes more complex than the problem
warrants.

**margo** should review this plan because the XML-vs-plain-text decision and
the number of advisory fields (SUBJECT/TASK/CHANGE/WHY = 4 fields) need a
YAGNI/KISS check. Four fields may be one more than necessary if SUBJECT can
be folded into CHANGE.

**software-docs-minion** should review because the report template
(TEMPLATE.md) and orchestration documentation (docs/orchestration.md) may need
updates to reflect the new advisory format.
