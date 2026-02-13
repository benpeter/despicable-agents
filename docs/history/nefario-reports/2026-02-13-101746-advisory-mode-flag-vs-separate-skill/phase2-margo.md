# Phase 2: Margo -- Simplicity & YAGNI Assessment

## Verdict: BLOCK (on both options as currently framed)

Neither a flag/mode nor a separate skill should be built. The simplest correct
answer is: do nothing. The current system already supports advisory-only
orchestration through natural language, and it worked on its first use (the SDK
evaluation that produced `sdk-evaluation-proposal.local.md`). Formalizing this
pattern is premature.

---

## Analysis

### 1. The YAGNI Case Is Clear-Cut

The planning question asks whether advisory mode should be "formalized." The
YAGNI test requires answering: "When will we need this?"

**Evidence of usage**: One instance. The SDK evaluation. It worked. The user
said "evaluate X, do not make changes" and nefario produced a thorough report
with team consensus. No special mode was needed.

**Evidence of pain**: None presented. The user is not reporting that the
advisory-only pattern failed, was unreliable, or required heroic workarounds.
The question originates from pattern recognition ("we did this once, should we
formalize it?"), not from friction.

**YAGNI verdict**: "Maybe someday we will do more advisory-only runs" is a
textbook "maybe someday" justification. Do not build for it until pain
materializes.

### 2. Complexity Cost of a New Mode/Flag

SKILL.md is already 1,928 lines. The nefario orchestration protocol is one of
the most complex artifacts in this project. Every conditional branch in SKILL.md
is a branch that every future change must reason about.

Adding an advisory mode means:

- **Phase 1**: Conditional logic to detect the mode (argument parsing changes)
- **Phase 4**: Skip execution entirely (branch in the execution phase)
- **Phase 5-8**: Skip all post-execution phases (conditional on mode)
- **Wrap-up**: Different report format (no PR, no commits, different template)
- **Gates**: Different approval gate options (no "execute" option)
- **Communication protocol**: Different CONDENSE lines, different status line
- **Branch/PR handling**: Skip branch creation, skip PR creation

That is at minimum 7 conditional branch points threaded through the entire
skill. Each one is a maintenance liability and a source of subtle bugs when the
"normal" path evolves and someone forgets to update the advisory path.

**Complexity budget**: ~3 points for a new abstraction layer inside an already
complex protocol. The budget is not justified by one use.

### 3. Complexity Cost of a Separate Skill

A separate `/nefario-advisory` skill would:

- Duplicate Phase 1 (meta-plan) and Phase 2 (specialist planning)
- Duplicate Phase 3 (synthesis) with modifications
- Duplicate report generation with a different template
- Require synchronization when the main skill evolves (Phase 1 changes must
  be mirrored, communication protocol changes must be mirrored, etc.)

This is the **fork maintenance problem**. Two skills that share 60-70% of their
logic but diverge on the remaining 30-40% are a maintenance nightmare. When
SKILL.md gets its next change (and it gets changed frequently -- 20+ nefario
reports in the last 4 days), someone must ask "does this also apply to the
advisory skill?" every time.

**Complexity budget**: ~5 points (new entry point + ongoing sync burden). Worse
than the flag option for long-term maintenance.

### 4. What Already Works

The user typed something like:

> `/nefario` evaluate whether we should adopt the Agent SDK. This is advisory
> only -- no code changes. Assemble the team, have them analyze, and produce a
> recommendation report.

Nefario understood. It assembled gru, lucy, ai-modeling-minion, and
ux-strategy-minion. They each wrote detailed analyses. Nefario synthesized them
into `sdk-evaluation-proposal.local.md`. The report is well-structured, has a
clear recommendation, includes a decision matrix, and documents re-evaluation
triggers.

**What mechanism made this work?** Natural language. The same mechanism that
makes "skip phase 8" work as trailing text. The same mechanism that makes "add
security-minion" work mid-flow. The SKILL.md explicitly supports this:

> Line 42: "The trailing text may contain nefario directives (e.g., 'skip
> phase 8') or additional task context -- both are valid."

Advisory-only is just another directive: "do not make changes, produce a report
only." The system already handles it.

### 5. When Would Formalization Be Justified?

Formalization would be justified when:

1. **Reliability fails**: Nefario starts ignoring the "no changes" directive and
   making unwanted modifications. (Not observed.)
2. **Report format needs differ**: Advisory reports need a structurally different
   format that cannot be achieved by natural language instruction. (Not observed
   -- the SDK evaluation report is excellent.)
3. **Frequency justifies it**: Advisory-only runs become a weekly or daily
   occurrence, and the repeated natural language instruction becomes friction.
   (Not observed -- one instance so far.)
4. **Discoverability matters**: New users need to find this capability without
   knowing to ask for it. (Not the current user base -- it is one person.)

None of these conditions are met today.

### 6. The Minimal-Effort Path If Pain Emerges

If advisory-only runs become frequent and the repeated instruction feels
tedious, the absolute minimum intervention is a one-line addition to the
SKILL.md argument parsing section:

```
- **`--advisory`** (trailing flag): Appends "This is advisory only. Do not make
  code changes. Produce a recommendation report." to the task description.
```

That is a string substitution, not a mode. It requires zero conditional logic
elsewhere in the protocol. Nefario handles the rest via natural language
understanding, just as it does today. Total cost: 3 lines added to SKILL.md.

But even this should wait until there is evidence it is needed.

---

## Risks of Building Now

| Risk | Severity | Explanation |
|------|----------|-------------|
| Protocol bloat | High | SKILL.md grows by 100-200 lines for a feature used once |
| Maintenance burden | High | Every SKILL.md change must now consider two code paths |
| Premature abstraction | Medium | Formalizing before the pattern stabilizes risks encoding the wrong abstraction |
| Opportunity cost | Medium | Time spent on advisory mode is time not spent on actual needs |

## Risks of NOT Building

| Risk | Severity | Explanation |
|------|----------|-------------|
| Advisory run fails silently | Low | Not observed; LLMs are reliable at "do not make changes" |
| User forgets the incantation | Low | One user; the phrase is natural English |
| Report format inconsistency | Low | No evidence of inconsistency across one sample |

---

## Recommendation

**Do nothing. The problem is solved. Natural language is the feature.**

The conversational flexibility that makes nefario powerful is exactly the
mechanism that makes advisory mode work without formalization. Building a formal
mode for a one-time use case adds accidental complexity to an already complex
protocol.

If advisory runs become a recurring pattern (3+ uses with consistent friction),
revisit. The minimal path at that point is a `--advisory` string expansion in
the argument parser -- not a mode, not a separate skill.

---

## Dependencies & Cross-Cutting Concerns

- **No other specialists needed**: This is purely a complexity/YAGNI question.
  The domain expertise required (orchestration protocol design) is already
  covered by devx-minion and ux-strategy-minion if they are on the team.
- **No code changes required**: The recommendation is to not build anything.
- **If overridden**: If the team decides to build anyway despite this BLOCK,
  the `--advisory` string expansion approach (3 lines, zero conditional logic)
  is the only option I would not block.
