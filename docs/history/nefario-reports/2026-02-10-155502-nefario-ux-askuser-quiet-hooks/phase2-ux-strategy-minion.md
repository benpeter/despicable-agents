# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### Overall Assessment

The current freeform decision points are a significant friction source. The user must recall exact keywords ("approve", "request changes", "reject", "skip", "approve --skip-post"), remember non-obvious syntax flags, and parse dense text blocks to understand what they are deciding. This violates multiple Nielsen heuristics: recognition over recall (H6), error prevention (H5), and user control (H3). Converting to AskUserQuestion is the right move.

However, AskUserQuestion is not a silver bullet. The quality of the structured prompt depends entirely on how the options are framed. Poorly structured options can increase cognitive load rather than reduce it. The analysis below applies Hick's Law (fewer choices = faster decisions), satisficing behavior (users take the first reasonable option), and progressive disclosure (hide complexity until needed) to each decision point.

### Decision Point 1: Approval Gates (Phase 4)

**Current**: `Reply: approve / request changes / reject / skip`
**Cognitive load**: HIGH. Four options, but with a hidden fifth (`approve --skip-post`) buried in the description above. The user must also absorb a dense decision brief (DECISION, RATIONALE, IMPACT, DELIVERABLE, Confidence) before choosing. This is the highest-frequency decision point -- it fires 3-5 times per session.

**Proposed AskUserQuestion structure**:

```
header: "GATE"
question: "<one-sentence DECISION summary from the brief>"
options:
  - label: "Approve (Recommended)"
    description: "Accept and continue. Code review + tests run after."
  - label: "Request changes"
    description: "Send feedback to the agent for revision (max 2 rounds)."
  - label: "Reject"
    description: "Drop this task and its dependents from the plan."
  - label: "Skip"
    description: "Defer. Re-presented before wrap-up."
multiSelect: false
```

**Rationale**:
- "Approve" is recommended because gates are designed to be approved most of the time -- nefario has already synthesized expert input and passed architecture review. The decision brief exists for the ~20% of cases where the user should push back, not for the ~80% where they confirm.
- `approve --skip-post` is deliberately NOT surfaced as a top-level option. It is an expert escape hatch. Users who need it will type it via the implicit "Other" freeform input. Exposing it as a visible option would split the default path (Hick's Law: more choices = slower decisions) and tempt users to skip verification they should not skip. This is a textbook progressive disclosure case.
- The decision brief (RATIONALE, IMPACT, DELIVERABLE, Confidence) should be printed ABOVE the AskUserQuestion call, not stuffed into option descriptions. The question itself is the one-line DECISION summary. This separates information consumption (reading the brief) from action selection (choosing an option), reducing cognitive load at the moment of decision.
- Four options is at the upper limit of what AskUserQuestion should present. But these four are genuinely distinct actions with meaningfully different consequences, so consolidation would lose important functionality.

**Risk**: The "Reject" option has irreversible consequences (drops dependent tasks). The description warns about this, but the current SKILL.md also requires a confirmation step after reject. That confirmation should ALSO use AskUserQuestion (a second prompt: "Confirm: reject X? This will also drop Y, Z.").

### Decision Point 2: Verification Escalation (Phase 5)

**Current**: `Options: fix manually / accept as-is / skip remaining verification`
**Cognitive load**: MEDIUM. Three options, but the context is stressful -- something went wrong (auto-fix failed twice). Users in error-recovery mode have elevated cognitive load. Clarity matters more here than brevity.

**Proposed AskUserQuestion structure**:

```
header: "ISSUE"
question: "<one-sentence finding description from the escalation brief>"
options:
  - label: "Accept as-is (Recommended)"
    description: "Proceed with the current code. Log finding for later."
  - label: "Fix manually"
    description: "Pause orchestration. You fix the code, then resume."
  - label: "Skip verification"
    description: "Skip all remaining code review and test checks."
multiSelect: false
```

**Rationale**:
- "Accept as-is" is recommended, not "fix manually". This is counter-intuitive but grounded in two observations: (a) if the auto-fix failed after 2 rounds, the issue is likely nuanced or low-severity, and (b) "fix manually" breaks orchestration flow, requiring the user to context-switch into code editing mode and then figure out how to resume. Most users will accept and address later. Recommending "fix manually" would push users toward a disruptive action that most will not actually take (satisficing: they want to finish the orchestration, not debug a finding).
- Option order changed from the current SKILL.md. The current order (`fix manually / accept as-is / skip remaining`) puts the most disruptive option first. The recommended order puts the least disruptive option first, followed by increasing disruption. This matches satisficing -- users scanning from top to bottom will hit the reasonable default first.
- "Skip remaining verification" is the nuclear option and should be last. Its description makes the blast radius clear.

### Decision Point 3: Calibration Check (Phase 4)

**Current**: "You have approved the last 5 gates without changes. Are the gates well-calibrated, or should future plans gate fewer decisions?"
**Cognitive load**: LOW in terms of options, but HIGH in terms of meta-cognition. This asks the user to reflect on the process itself, not make a task decision. It interrupts the execution flow with a meta-question. Most users will just want to continue.

**Proposed AskUserQuestion structure**:

```
header: "CALIBRATE"
question: "5 consecutive approvals without changes. Gates well-calibrated?"
options:
  - label: "Gates are fine (Recommended)"
    description: "Continue with current gating level."
  - label: "Fewer gates next time"
    description: "Note for future plans: consolidate more aggressively."
multiSelect: false
```

**Rationale**:
- Only 2 options. This is a binary meta-decision that should not consume significant attention. Hick's Law strongly favors 2 options over 3+ for a question this simple.
- "Gates are fine" is recommended because the absence of requested changes does NOT necessarily mean gates are poorly calibrated. It could mean the plan was well-designed. Defaulting to "fewer gates" would create a ratchet effect where gates gradually disappear across sessions. The user should actively choose fewer gates, not drift into it.
- The current freeform phrasing invites lengthy reflection ("well-calibrated" is a loaded term). The structured prompt converts this into a quick yes/no and moves on. The "Other" freeform escape covers users who want to provide detailed calibration feedback.
- This is the decision point most improved by AskUserQuestion. The current open-ended question is guaranteed to produce either a wall of text or an awkward "uh, fine I guess" -- neither is useful. A binary choice captures the signal efficiently.

### Decision Point 4: PR Creation (Wrap-up)

**Current**: `Create PR for nefario/<slug>? (Y/n)`
**Cognitive load**: VERY LOW. Binary yes/no. This is the simplest decision in the entire flow.

**Proposed AskUserQuestion structure**:

```
header: "PR"
question: "Create PR for nefario/<slug>?"
options:
  - label: "Create PR (Recommended)"
    description: "Push branch and open pull request on GitHub."
  - label: "Skip PR"
    description: "Keep branch local. You can push later."
multiSelect: false
```

**Rationale**:
- Two options. The descriptions add value here because they clarify what each choice does mechanically (push + PR vs. local only). Without AskUserQuestion, users understand `Y/n` but may not realize "n" means the branch stays local and they can push later.
- "Create PR" is recommended because the entire orchestration flow is designed to produce a PR-ready result. If the user ran nefario, they almost certainly want a PR. The 5-10% who do not can select "Skip PR" or use "Other" to customize (e.g., "push but don't create PR").
- This decision point benefits least from AskUserQuestion (it was already simple), but converting it maintains consistency across all decision points. Consistency (Nielsen H4) outweighs the marginal cost of converting a simple Y/n.

### Decision Point 5: Compaction Checkpoint (Phase 3/3.5)

**Current**: Asks user to run `/compact` command, then type "continue".
**Should remain freeform**: YES.

**Rationale for exclusion**:
- This is NOT a decision point in the same sense as the others. It is an action instruction. The user is not choosing between options -- they are being told to perform a specific IDE command (`/compact`) that exists outside the conversation flow. AskUserQuestion cannot invoke `/compact` for the user, so wrapping this in structured options would be misleading (implying the tool can do something it cannot).
- The "decision" component (skip vs. compact) is secondary to the action component (running the command). Structuring the decision while the action remains manual creates a split interaction that is worse than the current unified prompt.

**UX inconsistency concern**: The meta-plan specifically asks whether excluding compaction creates inconsistency. My assessment: minimal inconsistency risk, for three reasons:

1. **Different interaction modality**: The other four decision points are choices within the conversation. Compaction is a command to the IDE. Users intuitively understand the difference between "pick an option" and "run this command." Forcing compaction into the AskUserQuestion mold would create artificial consistency at the expense of functional clarity.

2. **Low frequency**: Compaction checkpoints appear at most twice per session (after Phase 3, after Phase 3.5). The four structured decision points collectively appear 5-10+ times. The compaction prompt is a minority interaction that users will not pattern-match against the structured prompts.

3. **Progressive disclosure of the skip path**: The current compaction prompt already handles the skip case well ("Skipping is fine if context is short"). Adding AskUserQuestion with "Run /compact" and "Skip" options would add a decision layer on top of an action, increasing rather than decreasing friction.

**One recommendation**: If the compaction prompt text feels inconsistent after the other four are converted, consider a minor formatting adjustment -- a visual separator or a shorter, more confident instruction. But do NOT convert it to AskUserQuestion.

### Cross-Cutting Observations

**multiSelect applicability**: None of the five decision points benefit from multiSelect. Each requires a single, mutually exclusive choice. multiSelect is for "check all that apply" scenarios (e.g., "which reviewers should re-review?"), which do not appear in the current decision flow.

**Header field usage**: The `header` chip/tag should function as a category label, not a title. Proposed headers -- "GATE", "ISSUE", "CALIBRATE", "PR" -- are terse and scannable. They help users instantly recognize what type of decision they are facing without reading the question. This is especially valuable for approval gates, which appear multiple times and should be immediately recognizable.

**The "Other" escape hatch**: AskUserQuestion always provides an implicit "Other" option for freeform input. This is essential for expert users who want to do something the structured options do not cover (e.g., `approve --skip-post`, custom calibration feedback, "push but no PR"). The recommendations above deliberately keep the structured options simple and push edge cases to "Other". This is the correct progressive disclosure trade-off: optimize the common path, accommodate the uncommon path, and never block the expert path.

**Decision brief placement**: For approval gates, the SKILL.md currently combines the decision brief and the response options in a single block. After converting to AskUserQuestion, these should be separated: print the decision brief as normal conversation output, then call AskUserQuestion with just the question and options. This reduces the cognitive load at the moment of selection -- the user has already absorbed the brief and now just needs to pick.

## Proposed Tasks

### Task 1: Design AskUserQuestion specifications for four decision points

**What to do**: Define the exact AskUserQuestion parameters (header, question template, options with labels and descriptions, multiSelect flag) for: approval gates, verification escalation, calibration check, and PR creation. Follow the structures proposed above.

**Deliverables**: A specification document with the four AskUserQuestion call structures, including the dynamic fields (e.g., `<slug>` in PR question, `<decision summary>` in gate question).

**Dependencies**: None. This task defines the design that all SKILL.md edits depend on.

### Task 2: Update SKILL.md decision points to reference AskUserQuestion structures

**What to do**: Replace the four freeform prompt blocks in SKILL.md with instructions that direct the executing session to use AskUserQuestion with the specified parameters. Preserve the surrounding context (decision brief format for gates, escalation brief format for verification). Ensure the "approve --skip-post" pathway remains documented as an "Other" input.

**Deliverables**: Updated SKILL.md with four modified decision point sections.

**Dependencies**: Task 1 (the design specification).

### Task 3: Add reject confirmation as a secondary AskUserQuestion

**What to do**: After the user selects "Reject" at an approval gate, the SKILL.md currently says "Confirm with the user -- show which dependent tasks will also be dropped." This confirmation should also use AskUserQuestion (2 options: "Confirm reject" / "Cancel"). Define the structure and add it to SKILL.md.

**Deliverables**: AskUserQuestion specification for reject confirmation; updated SKILL.md section.

**Dependencies**: Task 2.

### Task 4: Validate compaction checkpoint phrasing for consistency

**What to do**: After the other four decision points are converted, review the compaction checkpoint text to ensure it does not feel jarring in context. Minor phrasing adjustments only -- do NOT convert to AskUserQuestion. Consider whether a visual separator or more concise instruction improves the flow.

**Deliverables**: Minor compaction checkpoint text update (if needed) or explicit "no change needed" finding.

**Dependencies**: Task 2 (need to see the converted decision points in context).

## Risks and Concerns

### Risk 1: AskUserQuestion rendering variability
The AskUserQuestion tool is rendered by Claude Code's UI, not by us. If Claude Code changes how options are displayed (e.g., numbering, layout, "Other" placement), our carefully designed option structures may not present as intended. Mitigation: keep option labels and descriptions self-contained so they work regardless of rendering details.

### Risk 2: "Approve" as recommended may encourage rubber-stamping
Marking "Approve" as "(Recommended)" could accelerate the very approval fatigue the calibration check is designed to detect. Mitigation: the decision brief (RATIONALE, rejected alternatives, confidence) is the primary brake on rubber-stamping, not the option labels. The brief should be printed before AskUserQuestion fires, forcing the user to scroll past substantive content before they can click "Approve". The calibration check remains the secondary brake.

### Risk 3: Expert users may find structured prompts slower
Users who have internalized the freeform keywords (typing "approve" instantly) may find AskUserQuestion slower because it requires visual parsing and selection rather than muscle-memory typing. Mitigation: the "Other" escape hatch means expert users can still type "approve" as freeform text. But this should be validated -- if the AskUserQuestion UI requires a mouse click to select "Other" before typing, the friction increase for experts is real. The ai-modeling-minion should confirm how "Other" input works mechanically.

### Risk 4: Four options at approval gates approaches Hick's Law limits
Four options is not problematic in isolation, but combined with the dense decision brief, the total cognitive load at each gate is high. If user testing reveals decision fatigue at gates, consider collapsing "reject" and "skip" into a single "defer" option (with a follow-up to distinguish). But this is a speculative concern -- start with four options and observe.

### Risk 5: Compaction inconsistency perception
While I assess the inconsistency risk as low (see analysis above), there is a chance that users perceive the compaction prompt as "broken" or "old-style" after experiencing the structured prompts elsewhere. Monitoring for this feedback would be prudent. If it materializes, the simplest fix is a formatting change to the compaction block (e.g., a distinctive visual treatment) rather than converting it to AskUserQuestion.

## Additional Agents Needed

None. The current team of ux-strategy-minion, ai-modeling-minion, and devx-minion covers the necessary domains. The ai-modeling-minion is particularly critical for confirming the AskUserQuestion tool's exact behavior (how "Other" works, whether labels support "(Recommended)" syntax natively or if it is just a convention, character limits on descriptions). My recommendations assume certain tool behaviors that the ai-modeling-minion should validate.
