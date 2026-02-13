## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### The core problem is a recognition-vs-recall failure

The current advisory format violates Nielsen's heuristic #6 (recognition rather than recall). When a user reads `TASK: Task 3` and `CHANGE: Added input validation requirement`, they must recall what Task 3 is, what its prompt said, and what the plan context was. This is a textbook recall demand -- the user holds invisible context in working memory or reaches for another document to reconstruct meaning.

Self-contained advisories fix this by making every advisory a recognition task: the user reads the advisory and recognizes what it describes without opening anything else.

#### Replace task numbers with artifact identifiers

Task numbers are session-internal ordinals. They carry zero semantic meaning outside the session. The anchor should be the concrete thing the advisory concerns:

- **A file or file pattern**: `nefario/AGENT.md`, `skills/nefario/SKILL.md`, `src/auth/*.ts`
- **A concept or component**: "OAuth redirect flow", "CLI help output format", "Phase 3.5 reviewer prompt"
- **A deliverable**: "OpenAPI spec for /users endpoint", "migration script for v2 schema"

The replacement is not a 1:1 swap of "Task 3" for some other label. It is a shift from internal indexing to domain-language anchoring. The advisory names what it is about in terms the affected system would use.

Proposed anchor field: `SCOPE:` -- names the artifact, file, component, or concept the advisory affects. This replaces `TASK:`.

#### Restructure CHANGE to be self-describing

Currently: `CHANGE: Added input validation on redirect_uri` -- this is already close to self-contained in good cases. The problem is when it reads like `CHANGE: Expanded the prompt to include error handling` -- expanded which prompt? For which agent? The fix is a format rule, not a structural change:

**CHANGE must state what it proposes using domain terms that a reader unfamiliar with the plan's internal numbering can understand.** It should read as a complete sentence fragment that answers "what is being suggested?" without referencing plan-internal structure.

Good: `CHANGE: Add redirect_uri validation to the OAuth callback handler`
Bad: `CHANGE: Added validation requirement to the task prompt`

#### Keep WHY grounded in the advisory itself

WHY already works well when it explains the risk in domain terms: "Open redirect vulnerability" is fully self-contained. The failure mode is when WHY says something like "Conflicts with the approach in Task 1" -- that is a recall demand.

**Rule: WHY must explain the risk or rationale using only information present in the advisory block itself.** No references to other tasks, plan steps, or external context.

#### Where is the line between "self-contained" and "bloated"?

This is the critical design tension. Apply the Krug test: can a user scanning the advisory answer three questions without thinking?

1. **What part of the system does this affect?** (SCOPE)
2. **What is being suggested?** (CHANGE)
3. **Why does it matter?** (WHY)

If the answer is yes, the advisory is self-contained enough. Everything beyond these three answers is progressive disclosure territory -- it belongs in the linked scratch file, not the advisory block.

**Concrete constraints to prevent bloat:**
- SCOPE: one line, max 80 characters. Name the artifact or concept; do not explain it.
- CHANGE: one sentence. State the proposed change in domain language.
- WHY: one sentence. State the risk or rationale.
- Total: 3 lines per advisory (unchanged from current maximum), plus optional Details/Prompt links.

The current 3-line budget per advisory is correct. The problem is not space -- it is what fills that space. Replacing task-number references with domain-language anchors costs zero additional characters.

#### Unified format across all 5 surfaces

The advisory format currently varies subtly across its 5 surfaces. Unifying the structure reduces cognitive load (consistency heuristic) and makes advisories portable -- the same block can appear in an execution plan gate, an execution report, or a Phase 5 code review without translation.

**Proposed unified advisory structure:**

For Phase 3.5 reviewer verdicts (the producing surface):
```
VERDICT: ADVISE
WARNINGS:
- [domain]: <description of concern>
  SCOPE: <file, component, or concept affected>
  CHANGE: <what is proposed, in domain terms>
  WHY: <risk or rationale, self-contained>
```

For the Execution Plan Approval Gate (the consumption surface):
```
ADVISORIES:
  [<domain>] <artifact or concept>
    CHANGE: <one sentence, domain terms>
    WHY: <one sentence, self-contained rationale>
```

For Phase 5 code review findings (already mostly self-contained):
```
FINDINGS:
- [BLOCK|ADVISE|NIT] <file>:<line-range> -- <description>
  AGENT: <producing-agent>
  FIX: <specific fix>
```

Phase 5 findings are already anchored to files and line ranges -- they are naturally self-contained. No structural change needed there, only ensure the `<description>` field follows the same "no plan-internal references" rule.

For inline summaries:
```
Verdict: ADVISE(<artifact or concept>: <one-line summary>)
```

For execution reports (TEMPLATE.md):
The Phase 3.5 narrative and Agent Contributions sections should use the same SCOPE + CHANGE + WHY structure when describing advisories. No separate format needed.

#### The TASK field should be preserved as optional metadata, not the anchor

Task numbers are useful for the calling session to mechanically apply advisories to the right task prompts. Do not eliminate TASK entirely -- demote it to optional routing metadata that the orchestration machinery uses, but that is never the primary identifier in user-facing output.

In the reviewer verdict (producing surface), TASK can remain as a routing hint:
```
WARNINGS:
- [domain]: <description>
  SCOPE: <artifact>
  CHANGE: <proposal>
  WHY: <rationale>
  TASK: Task 3  (routing hint for orchestrator; not shown in user-facing output)
```

In user-facing surfaces (execution plan gate, reports), TASK is omitted. The SCOPE field provides the anchor.

### Proposed Tasks

#### Task 1: Update the ADVISE verdict format in nefario/AGENT.md
- **What**: Replace the current ADVISE verdict format with the new SCOPE-anchored format. Add the format rule that CHANGE and WHY must use domain terms only, no plan-internal references. Preserve TASK as optional routing metadata.
- **Deliverables**: Updated verdict format block in nefario/AGENT.md (Architecture Review section)
- **Dependencies**: None
- **Files**: `/Users/ben/github/benpeter/2despicable/2/nefario/AGENT.md`

#### Task 2: Update the ADVISORIES block format in skills/nefario/SKILL.md
- **What**: Update the Execution Plan Approval Gate's ADVISORIES block to use SCOPE instead of "Task N: <task title>" as the anchor. Update advisory principles text. Update the Phase 3.5 reviewer prompt to instruct reviewers to produce the new format.
- **Deliverables**: Updated ADVISORIES format, updated reviewer spawn prompt, updated advisory principles
- **Dependencies**: Task 1 (format definition must be canonical first)
- **Files**: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

#### Task 3: Update Phase 5 code review finding format (minor)
- **What**: Add a format rule to the Phase 5 code review finding instructions that descriptions must not reference plan-internal numbering. The structural format (file:line-range) is already self-contained.
- **Deliverables**: Updated instruction text in SKILL.md Phase 5 section
- **Dependencies**: None (can run in parallel with Task 1)
- **Files**: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

#### Task 4: Update the inline summary template
- **What**: Update the Verdict line in the inline summary template to use the SCOPE-based format rather than task-number references.
- **Deliverables**: Updated inline summary template in SKILL.md
- **Dependencies**: Task 1
- **Files**: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

#### Task 5: Update TEMPLATE.md advisory rendering guidance
- **What**: Add a note to TEMPLATE.md that advisories in the Agent Contributions section should use SCOPE + CHANGE + WHY structure, never task-number-only references.
- **Deliverables**: Updated formatting guidance in TEMPLATE.md
- **Dependencies**: Task 1
- **Files**: `/Users/ben/github/benpeter/2despicable/2/docs/history/nefario-reports/TEMPLATE.md`

**Note on consolidation**: Tasks 2, 3, and 4 all modify the same file (SKILL.md). In execution, they should be combined into a single task to respect file ownership rules. I list them separately here for clarity of scope.

### Risks and Concerns

#### Risk 1: SCOPE names may be ambiguous or too generic
When reviewers write advisories, they may default to vague SCOPE values like "the authentication flow" when a specific file path would be more useful. **Mitigation**: Include 2-3 examples of good vs. bad SCOPE values in the format guidance, similar to how the Reviewer Approval Gate already has "good rationale" vs "bad rationale" examples.

#### Risk 2: Backward compatibility of advisory parsing
If the calling session currently uses regex or pattern matching to extract `TASK: Task N` from reviewer output and route advisories, changing the format requires updating the consuming logic in SKILL.md simultaneously. **Mitigation**: This is a documentation-only project (prompt text, not code), so the "parsing" is LLM interpretation of structured text. The risk is low, but the SKILL.md's verdict-processing instructions must be updated in the same change.

#### Risk 3: Reviewers may still produce plan-internal references
The format change is instructional -- it tells agents what format to use. Agents may still occasionally produce "as noted in Task 2" or similar phrasing. **Mitigation**: Add an explicit negative instruction: "Do not reference task numbers, plan steps, or session-internal identifiers in SCOPE, CHANGE, or WHY fields. Name the artifact or concept directly." Negative instructions are more reliable for preventing specific behaviors.

#### Risk 4: Over-indexing on file paths as SCOPE
Not everything that an advisory concerns is a file. Conceptual advisories ("the onboarding flow assumes users have CLI installed") may not map to a single file. **Mitigation**: The SCOPE field should explicitly allow both file paths and concept names. The format guidance should include examples of both.

#### Risk 5: Execution report Phase 3.5 narrative already paraphrases advisories
The TEMPLATE.md Phase 3.5 section uses prose narrative, not structured advisory blocks. If we require structured SCOPE/CHANGE/WHY in the template, it may conflict with the "narrative, not tables" rule for the Phases section. **Mitigation**: The structured format applies only in the Agent Contributions detail section (already structured). The Phases narrative can paraphrase using the same domain-language-only rule without the structured block.

### Additional Agents Needed

**devx-minion** should review the proposed format from a developer-experience perspective. The advisory format is consumed by both human users and the LLM-based orchestration loop. devx-minion can assess whether the format is easy for the calling session to mechanically process (routing advisories to the right task prompts) while remaining human-readable. This is a dual-audience design problem.

No other additional agents needed. The current team (with whatever agents nefario selected) should be sufficient.
