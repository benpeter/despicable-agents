## Domain Plan Contribution: lucy

### Recommendations

#### 1. The Phase 3.5 ADVISE verdict format in nefario/AGENT.md needs artifact-grounded fields, not task-number references

The current Phase 3.5 ADVISE format uses `TASK: <task number affected, e.g., "Task 3">` and `CHANGE: <what specifically changed in the task prompt or deliverables>`. Both fields reference plan-internal structure. A user reading the advisory in a synthesis, execution report, or task list would need to look up "Task 3" to understand what is being discussed.

**Proposed replacement fields for Phase 3.5 ADVISE:**

```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  SUBJECT: <file, artifact, concept, or component this concerns -- e.g., "SKILL.md Phase 1 prompt", "install.sh symlink logic", "OAuth token refresh flow">
  CHANGE: <what the advisory proposes in domain terms -- e.g., "Add CSRF token validation to the callback handler" not "Added validation step to Task 3's deliverables">
  WHY: <risk or rationale using information present in this advisory -- not "see the synthesis for context">
  TASK: <task number affected>
```

Key changes:
- **SUBJECT** (new field): Names the concrete artifact, file, or concept. This is the primary anchor that makes the advisory readable in isolation. It replaces the need to infer "what is this about" from the task number.
- **CHANGE** (redefined): Must describe the proposed change in domain terms, not by referencing plan-internal numbering. "Add input validation to the `/auth/callback` endpoint" rather than "Modified Task 3 prompt to include validation step."
- **WHY** (new field): Explains rationale self-containedly. This replaces the implicit rationale that reviewers sometimes fold into the description or omit entirely.
- **TASK** (retained, demoted): Kept for nefario's internal routing (it needs to know which task prompt to modify), but moved to last position. It is operational metadata, not the reader-facing identification.

The RECOMMENDATION field from the current format is absorbed into CHANGE. Recommendation and change are functionally identical in practice -- "what should be different" -- and having both creates confusion about which one the reader should focus on.

#### 2. The execution plan gate advisory format in SKILL.md already has the right structure but lacks enforcement

The SKILL.md execution plan approval gate format (lines 1283-1293) uses:
```
[<domain>] Task N: <task title>
  CHANGE: <one sentence describing the concrete change to the task>
  WHY: <one sentence explaining the concern that motivated it>
```

This is close to self-contained. The `Task N: <task title>` gives human-readable identification. The CHANGE and WHY fields exist. But two problems:

**Problem A**: The CHANGE and WHY wording instructions do not explicitly prohibit plan-internal references. A reviewer can write `CHANGE: Added the validation from Step 2 of the security review` and it technically complies. The instructions should state: "CHANGE and WHY must be readable without access to the plan, the review, or the originating conversation."

**Problem B**: The format uses `Task N: <task title>` as the subject line, which ties the advisory to plan structure. If the task title is descriptive (e.g., "Task 2: Update SKILL.md report directory detection"), this works. If the task title is vague or internal (e.g., "Task 2: Core implementation"), it fails. The instructions should require that the task title be a meaningful artifact-level description, or the advisory should include a SUBJECT field that overrides the task title when the title is not self-explanatory.

**Recommended fix**: Add a sentence to the advisory principles block: "CHANGE and WHY must be interpretable by a reader who has not seen the plan, the review verdict, or the originating conversation. Reference files, endpoints, components, or concepts by name -- not by task number or plan step."

#### 3. The Phase 5 code review FINDINGS format is already self-contained

The Phase 5 format uses `<file>:<line-range> -- <description>` with `AGENT:` and `FIX:` fields. This is artifact-grounded by design: the file path and line range are the subject. No changes needed to the Phase 5 verdict format structure.

However, the Phase 5 prompt template in SKILL.md (lines 1664-1671) gives the verdict format as an example but does not explicitly instruct reviewers to write self-contained descriptions. A reviewer could write `[ADVISE] SKILL.md:140 -- Same issue as finding 1` or `[ADVISE] SKILL.md:140 -- Does not match synthesis plan`. The instructions should state: "Each finding must be self-contained. Do not reference other findings by number or reference the synthesis plan by step number."

#### 4. Lucy's own AGENT.md Output Standards need a self-containment directive

Lucy's AGENT.md (lines 206-216) defines output standards but does not explicitly require self-contained advisories. The "Specific citations" directive ("Always cite the exact plan element, CLAUDE.md directive, or requirement being referenced") is good but insufficient -- it says to cite things specifically, not to make citations readable in isolation. A citation like "Plan element: Task 3, step 2a" is specific but not self-contained.

**Proposed addition to lucy/AGENT.md Output Standards:**

Add after "Specific citations":
```
- **Self-contained findings**: Each finding must be readable in isolation. Name the file, artifact, or concept it concerns -- not "Task 3" or "the approach." CHANGE descriptions state what is proposed in domain terms. WHY descriptions explain the rationale using information present in the finding itself.
```

#### 5. The Phase 3.5 reviewer prompt template needs an output format example

The generic reviewer prompt in SKILL.md (lines 1079-1095) says:
```
- ADVISE: <list specific non-blocking warnings>
```

This gives no structure at all. Reviewers invent their own format (as seen in the real outputs -- security-minion uses numbered prose, margo uses numbered prose with sub-points, lucy uses full traceability tables). The prompt should include the structured ADVISE format with SUBJECT/CHANGE/WHY/TASK fields so reviewers produce consistent, parseable output that nefario can reliably transform into the execution plan gate advisory format.

#### 6. The BLOCK verdict format is already self-contained

The BLOCK format uses ISSUE/RISK/SUGGESTION fields, all of which are inherently domain-grounded (the reviewer must explain what is wrong, what happens if not fixed, and how to fix it). No structural changes needed. However, the same self-containment language should apply: "ISSUE, RISK, and SUGGESTION must be readable without access to the plan or other verdicts."

#### 7. Lucy's intent-alignment review process needs one change

Currently, lucy reviews a plan by reading the synthesis and checking it against the original user request. Lucy's output (as seen in the real examples) is thorough and artifact-grounded when given time (the `decouple-self-referential-assumptions` review is exemplary). But the shorter reviews (`replace-skip-post-granular-flags`) default to plan-internal language: "Task 2 'proceed directly to Wrap-up' is functionally equivalent to current 'skip to Wrap-up'."

The fix is in the reviewer prompt, not in lucy's AGENT.md. The prompt should instruct reviewers (including lucy) to ground findings in artifact names and user-visible concepts, and should provide the original user request text (or a pointer to `$SCRATCH_DIR/{slug}/prompt.md`) so the reviewer can reference user intent directly rather than through the plan's restatement of it.

Currently, the Phase 3.5 prompt says: "Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md". It does NOT provide the original user request. Lucy has to infer user intent from the plan's restatement. This is a structural gap: if the plan subtly misrepresents user intent, lucy reviews the misrepresentation rather than the original. The prompt should add: "Original user request: $SCRATCH_DIR/{slug}/prompt.md" so reviewers can independently verify alignment.

### Proposed Tasks

1. **Update Phase 3.5 ADVISE verdict format in nefario/AGENT.md**: Replace TASK/CHANGE/RECOMMENDATION with SUBJECT/CHANGE/WHY/TASK (TASK demoted to routing metadata). Ensure CHANGE describes what is proposed in domain terms. Ensure WHY is self-contained rationale.

2. **Update Phase 3.5 reviewer prompt template in SKILL.md**: (a) Include structured ADVISE output format with SUBJECT/CHANGE/WHY/TASK fields. (b) Add `Original user request: $SCRATCH_DIR/{slug}/prompt.md` to all reviewer prompts so reviewers can verify alignment against the actual request. (c) Add self-containment instruction: "Each finding must be readable by someone who has not seen the plan, the review, or this conversation."

3. **Update execution plan gate advisory format in SKILL.md**: Add self-containment instruction to the advisory principles block. Consider replacing `Task N: <task title>` with a SUBJECT field or requiring task titles to name the artifact/component.

4. **Update Phase 5 code review verdict format instructions in SKILL.md**: Add self-containment instruction to the findings format. Each finding must not reference other findings by number or plan steps by number.

5. **Update lucy/AGENT.md Output Standards**: Add "Self-contained findings" directive requiring each finding to name its subject, describe changes in domain terms, and explain rationale using information present in the finding.

6. **Update BLOCK verdict format instructions in nefario/AGENT.md**: Add self-containment language to ISSUE/RISK/SUGGESTION field definitions.

### Risks and Concerns

1. **Format compliance by downstream reviewers is not guaranteed.** Changing the format definition does not guarantee that reviewer agents will follow it. The structured ADVISE format must appear in the prompt template that reviewers actually receive (SKILL.md reviewer prompt), not only in nefario/AGENT.md. nefario/AGENT.md defines what nefario knows about the format; the reviewer prompt defines what reviewers know. Both must be updated.

2. **Advisory brevity constraint tension.** The current SKILL.md advisory principles say "Maximum 3 lines per advisory." Adding a SUBJECT field increases the minimum to 4 lines (SUBJECT + CHANGE + WHY + TASK). The 3-line limit should be adjusted to 4, or TASK should not count toward the line budget (since it is routing metadata, not reader-facing content). This is a real constraint -- the execution plan gate has a 25-40 line budget, and inflating each advisory by one line reduces the number of advisories that fit.

3. **Risk of over-specifying format for reviewers who already produce good output.** Lucy's long-form reviews (like the `decouple-self-referential-assumptions` output) are already excellent and artifact-grounded. Forcing them into a rigid SUBJECT/CHANGE/WHY/TASK template for every finding might reduce quality. The structured format should be required for the verdict block that nefario consumes, but reviewers should remain free to include additional analysis (traceability tables, compliance checks, etc.) outside the verdict block.

4. **Original user request in reviewer prompts adds token cost.** Including `prompt.md` as a reference in reviewer prompts is minimal (a file path, not the content), but reviewers that read it add a tool call. This is justified for lucy (whose entire purpose is intent alignment) but may be wasted tokens for security-minion or test-minion. Recommendation: include the reference in all reviewer prompts (it is a path, not content), but only lucy's "Your Review Focus" section should explicitly instruct the reviewer to read and verify against it.

5. **TASK field routing dependency.** nefario's plan revision logic depends on parsing the TASK field to know which task prompt to modify with advisory content. If the field is renamed, demoted, or removed, the SKILL.md Phase 3.5 "Process Verdicts" logic and the advisory-to-task-prompt injection logic must be updated. This is a mechanical dependency, not a design concern, but it must not be missed during implementation.

### Additional Agents Needed

- **ai-modeling-minion**: Should review the revised prompt template to ensure the structured output format (SUBJECT/CHANGE/WHY/TASK) is likely to be followed by downstream reviewer agents. Prompt engineering for structured output compliance is their domain. Specifically: will the format example in the reviewer prompt reliably produce parseable output, or do we need few-shot examples or stronger output scaffolding?

No other additional agents needed. The task is primarily a format and instruction change across nefario/AGENT.md, SKILL.md, and lucy/AGENT.md. It does not introduce new architecture, new code, or new dependencies.
