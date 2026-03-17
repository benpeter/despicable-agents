# UX Strategy Planning Contribution: Gate Review Transparency (Implementation)

## Scope

This contribution answers five specific implementation questions for the SKILL.md gate format changes recommended by the advisory. The advisory established the *what* (Chosen/Over/Why micro-format at all four gates). This contribution specifies the *exact text* for the implementer.

---

## (a) NOT SELECTED (notable) block density in the Team gate

**Recommendation: Same one-liner format as SELECTED, not Chosen/Over/Why.**

The Team gate's decision is "is this the right team?" The SELECTED block uses one-liners because the user's cognitive task is scanning a roster for surprises, not evaluating trade-offs. The NOT SELECTED (notable) block serves the same cognitive task -- spotting a missing agent -- so it should match the same density.

A Chosen/Over/Why format for exclusions would look like:

```
  NOT SELECTED (notable):
    margo
      Chosen: defer to Phase 3.5
      Over: include in planning team
      Why: mandatory reviewer; planning input not needed for prompt-only changes
```

That is 4 lines per exclusion (12 lines for 3 entries). The one-liner format:

```
  NOT SELECTED (notable):
    margo                Will review in Phase 3.5 (mandatory reviewer)
    security-minion      No new attack surface; gate changes are prompt-only
    test-minion          No executable output; will review in Phase 3.5
```

That is 4 lines total (header + 3 entries). The one-liner is 3x more compact and is *sufficient* because Team exclusion rationales are simple binary signals ("not relevant" or "deferred to review phase"), not multi-factor trade-offs. The user needs to know the exclusion is intentional and roughly why -- not who argued for inclusion.

**Exact text for SKILL.md** (replaces the current `ALSO AVAILABLE (not selected):` block in the Team gate presentation format):

```
  `NOT SELECTED (notable):`
    <agent-name>         <one-line exclusion rationale, max 60 chars>
    <agent-name>         <one-line exclusion rationale, max 60 chars>
    <agent-name>         <one-line exclusion rationale, max 60 chars>

  Also available: <remaining agents, comma-separated>
```

Format rules addition:

```
- NOT SELECTED (notable): up to 3 agents whose exclusion might surprise the
  user (governance agents for governance-adjacent tasks, security-minion for
  security-adjacent tasks, etc.). One line per agent with exclusion rationale,
  same alignment as SELECTED entries. Source from meta-plan exclusion reasoning.
- "Also available" remainder: flat comma list, same as current ALSO AVAILABLE.
  Lowercase "Also" distinguishes it from the labeled blocks.
- If no exclusions are notable (task is clearly single-domain), omit the
  NOT SELECTED (notable) block entirely. Keep only "Also available."
```

**Self-containment test**: A user reading only the gate can now see that margo was excluded intentionally (deferred to review), not overlooked. Previously, margo appeared in a flat comma list indistinguishable from irrelevant agents like sitespeed-minion.

---

## (b) DECISIONS block: max-5 cap and overflow

**Recommendation: Show first 3, link for rest. Do not show a count-only overflow line.**

The advisory says "cap at 5 inline decisions." I recommend capping at 3 inline with a link for the rest, for two reasons:

1. **Three decisions at 3-4 lines each = 9-12 lines.** Five decisions = 15-20 lines. The DECISIONS block is one section within a gate that also has TASKS (variable length), ADVISORIES, RISKS, REVIEW, and orientation. At 5 inline decisions, the DECISIONS block alone approaches the old total gate budget (25-40 lines). This crowds out everything else or pushes the gate well past one screen.

2. **Hick's Law at the decision level.** Three decisions is the sweet spot where the user can hold all trade-offs in working memory simultaneously. At five, the first decision has started to fade by the time the user reaches the fifth. The user's job is to evaluate the *plan*, not audit every synthesis decision.

**However**: if the advisory's 5-entry cap has strong buy-in from the other specialists, I can live with 5. The format handles it. My strong recommendation is that the *overflow format* be a link, not a summary count. "And 2 more in [plan](link)" gives the user an escape hatch. "And 2 more decisions" is a dead end.

**Exact text for SKILL.md** (within the DECISIONS block format definition):

```
`DECISIONS:`
  <Decision title>
    Chosen: <what was selected>
    Over: <what was rejected> (<agent attribution, best-effort>)
    Why: <one sentence of rationale>

  <Decision title>
    Chosen: ...
    Over: ...
    Why: ...

  ... and N more in [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
```

Format rules:

```
- Maximum 5 decisions shown inline. If more than 5 synthesis decisions exist,
  show the 5 with highest user impact (scope changes, security trade-offs,
  architecture choices over implementation details).
- Beyond 5: add overflow line "... and N more in [plan](link)".
  Do not summarize the overflowed decisions -- the link is the escape hatch.
- If 0 decisions exist (no conflicts, no trade-offs), omit the DECISIONS block
  entirely. Do not show an empty block or "No decisions."
- Attribution in "Over" lines is best-effort. Include when the synthesis clearly
  records which agent proposed the rejected alternative. Omit when uncertain.
  Never fabricate attribution.
- One blank line between decision entries for scannability.
```

**Selection heuristic for which decisions to show inline** (when overflow applies):

Priority order for inline display:
1. Decisions that changed the plan's external behavior (API contracts, user-facing output)
2. Decisions about security or data handling trade-offs
3. Decisions about scope (what was included/excluded from the plan)
4. Decisions about implementation approach (internal architecture choices)

This ordering matches the user's decision priority: external-facing choices matter most because they are hardest to reverse.

---

## (c) Good/bad RATIONALE examples for mid-execution gates

**Recommendation: Three examples (one good, two bad archetypes) that teach the *pattern* without being copy-targets.**

The risk with examples in prompt text is that agents copy the example's content rather than the example's structure. Two mitigations:

1. **Use a domain deliberately different from common nefario tasks.** The advisory's OAuth example is fine for the "good" case because OAuth is specific enough that agents won't encounter it often. But the "bad" examples should show *archetypes of failure*, not domain-specific mistakes.

2. **Label the failure mode, not just "bad."** "Bad RATIONALE" teaches nothing about *why* it's bad. Naming the failure mode ("restates the DECISION", "appeals to authority") gives the agent a self-check heuristic.

**Exact text for SKILL.md** (new block after the mid-execution gate format template, before the line budget guidance):

```
Good RATIONALE (exposes reasoning and rejected alternatives):
- PKCE chosen for public client security (no client secret storage needed)
- Token refresh uses sliding window -- minimizes re-auth without unbounded sessions
- Rejected: Implicit grant flow -- deprecated in OAuth 2.1, no refresh token support
- Rejected: Client credentials grant -- requires secret storage, unsuitable for CLI

Bad RATIONALE -- restates the decision (no new information):
- Implemented the OAuth flow
- Used best practices for token management
- Followed the task requirements

Bad RATIONALE -- appeals to convention (no task-specific reasoning):
- Used the standard approach for this type of problem
- Followed the pattern from the existing codebase
- Applied the recommended security configuration
```

**Why these specific bad examples work**: The two bad archetypes cover the two most common LLM failure modes for rationale:
- **Restatement**: The agent echoes its DECISION line in slightly different words. This is the most frequent failure because it feels substantive while adding zero information.
- **Appeal to convention**: The agent cites "best practices" or "standard approach" without naming *which* practice or *what* the alternative was. This sounds expert but is unfalsifiable and undecidable.

**What I would NOT include**: A "medium" example. Medium-quality rationale is the hardest to specify and creates ambiguity about the quality bar. Two clearly bad archetypes plus one clearly good example draws a bright line.

**Placement**: Directly after the mid-execution gate format template in SKILL.md Phase 4, section 5 ("At approval gates"). This is where nefario reads the format when constructing the gate. Placing it here means the examples are in the rendering context, not the agent-prompting context. See (d) for the agent-side instruction.

---

## (d) Agent completion message instruction: SKILL.md Phase 4 or synthesis task prompt template?

**Recommendation: Both, with different content. SKILL.md gets the instruction template. The synthesis task prompt gets the task-specific rationale seed.**

The current agent completion message (SKILL.md lines 1579-1583) tells agents to report:
- File paths with change scope and line counts
- 1-2 sentence summary

This lives in SKILL.md Phase 4 section 3 ("Spawn teammates") as a quoted block that nefario appends to every agent prompt. This is the right location for the instruction because:
- It applies to ALL execution agents, not just gated ones
- It is a nefario-internal instruction (nefario appends it), not a plan artifact
- It needs to be in nefario's rendering context at spawn time

**Exact text replacement for SKILL.md** (replaces the current completion message instruction in Phase 4, section 3):

```
   > When you finish your task, mark it completed with TaskUpdate and
   > send a message to the team lead with:
   > - File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
   > - 1-2 sentence summary of what was produced
   > - If this task has an approval gate: the approach you chose, what
   >   alternative(s) you considered but rejected, and a brief reason
   >   for each rejection
   > This information populates the gate's DELIVERABLE and RATIONALE sections.
```

The changes from the current version:
- Added the third bullet (approach + rejected alternatives for gated tasks)
- Updated the trailing line to reference both DELIVERABLE and RATIONALE

**Why NOT put this only in the synthesis task prompt template**: The synthesis produces per-task prompts that get written to scratch files, then passed to agents at spawn time. The completion message instruction is appended by nefario *after* the task prompt. If the rationale instruction were only in the synthesis template, it would be in the body of the prompt (where the agent processes it as task context), not at the end (where the agent processes it as a structural output requirement). The end-of-prompt position is stronger for formatting instructions.

**The synthesis task prompt template's role**: The advisory also recommends a "Gate rationale" field in the synthesis format for gated tasks -- a pre-execution rationale seed that tells the agent *what decision the synthesis expects this task to face*. This is complementary, not redundant. The synthesis provides the *question* ("you will need to choose between X and Y for Z"); the completion message instruction tells the agent to *report its answer*.

**Exact text for the synthesis format** (addition to the per-task entry in the synthesis output, for gated tasks only):

```
Gate rationale: <1-2 sentences describing the key decision this task will face
and the alternatives the synthesis considered. This seeds the agent's RATIONALE
reporting. Omit for non-gated tasks.>
```

This goes in the AGENT.md synthesis output format (the per-task schema), not in SKILL.md. It is upstream data that feeds the gate rendering.

---

## Decision Transparency Preamble

**Recommendation: Place it in SKILL.md as a new subsection immediately before the Team Approval Gate section. Do NOT place it in AGENT.md.**

### Why SKILL.md, not AGENT.md

AGENT.md already has a "Decision Brief Format" section (lines 338-382) that defines the philosophy for mid-execution gates. The advisory recommends establishing in AGENT.md that all gate types follow this pattern. That is correct -- AGENT.md should state the *principle*. But the preamble is *operational guidance* for nefario when rendering gates. It belongs where nefario reads it: SKILL.md, immediately before the first gate it will render.

### Why before the Team gate, not at the top of SKILL.md

The preamble is gate-specific guidance. Placing it at the top of SKILL.md (among the Communication Protocol or Phase Overview) would dilute it -- nefario would read it hundreds of lines before encountering any gate. Placing it immediately before the Team Approval Gate means it enters nefario's working context right when gate rendering begins.

### What it says

The preamble should do three things:
1. State the quality bar (the self-containment test)
2. Name the micro-format (Chosen/Over/Why)
3. Specify the density principle (proportional to decision scope)

It should NOT:
- Repeat the full Chosen/Over/Why format definition (that lives in the per-gate sections)
- Explain the philosophy at length (that lives in AGENT.md)
- List all four gate types and their budgets (that creates a maintenance burden -- each gate section already has its budget)

**Exact text for SKILL.md** (new subsection, placed immediately before `### Team Approval Gate`):

```
### Decision Transparency at Gates

Every gate must pass the self-containment test: a user who reads ONLY the gate
output -- never clicks Details -- can make a well-informed approve/adjust/reject
decision.

To achieve this, gates surface decision rationale using a consistent
micro-format. For synthesis decisions and mid-execution approaches:

    <Decision title>
      Chosen: <what was selected>
      Over: <what was rejected>
      Why: <rationale>

For team and reviewer exclusions, a one-liner suffices:

    <agent-name>         <exclusion rationale>

Density scales with decision scope: the Team gate is lighter than the Execution
Plan gate. Each gate section below defines its own format and line budget.
Attribution in "Over" lines is best-effort -- include when the synthesis clearly
records the source; omit when uncertain; never fabricate.
```

**Line count**: 16 lines including blanks. Compact enough to stay in working context alongside the Team gate section. The two inline format snippets serve as quick-reference anchors -- nefario can pattern-match against them without scrolling back to a distant format definition.

### Corresponding AGENT.md addition

The advisory recommends a brief note in AGENT.md establishing that all gate types follow the progressive-disclosure decision brief pattern. This belongs in the existing "Decision Brief Format" section (AGENT.md line 338). Exact text addition, after the current "Target 12-18 lines" line:

```
All four gate types (Team, Reviewer, Execution Plan, Mid-execution) follow this
progressive-disclosure pattern, at density proportional to each gate's decision
scope. SKILL.md defines per-gate formats. The principle is consistent: every gate
surfaces what was decided, what was rejected, and why.
```

This is 4 lines. It anchors the philosophy without duplicating SKILL.md's operational format definitions.

---

## Summary of Recommendations

| Question | Recommendation | Key Rationale |
|----------|---------------|---------------|
| (a) NOT SELECTED density | Same one-liner as SELECTED | Roster scanning, not trade-off evaluation; 3x more compact than C/O/W |
| (b) DECISIONS overflow | Max 5 inline, overflow as link line | Hick's Law; link > dead-end count; external-facing decisions prioritized |
| (c) Good/bad RATIONALE examples | 1 good + 2 labeled bad archetypes (restatement, convention-appeal) | Named failure modes > unlabeled "bad"; different domain prevents copying |
| (d) Completion message location | SKILL.md Phase 4 (instruction) + AGENT.md synthesis format (rationale seed) | End-of-prompt for output formatting; synthesis for decision context |
| Preamble | SKILL.md, immediately before Team gate section | Operational guidance at point of use; 16 lines; states test + format + density principle |

### Risks

1. **The max-5 cap may be too high for single-screen display.** If the first production session with 5 inline decisions pushes the gate past one terminal screen, reduce to 3 inline with the same overflow format. The overflow mechanism works identically at either cap.

2. **Named bad-RATIONALE archetypes may not cover all failure modes.** A third archetype -- "lists implementation steps instead of decisions" -- could emerge. Monitor the first few mid-execution gates and add a third bad example if a new archetype appears.

3. **The preamble adds 16 lines to SKILL.md before the Team gate.** This is context window cost. If SKILL.md is already tight on token budget, the preamble could be trimmed to 10 lines by removing the inline format snippets (which are repeated in the per-gate sections anyway). But the snippets serve as quick-reference anchors, so keep them unless token pressure forces removal.
