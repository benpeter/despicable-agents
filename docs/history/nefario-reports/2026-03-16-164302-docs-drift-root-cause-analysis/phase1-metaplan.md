## Meta-Plan

### Task Analysis

This is a self-reflexive root cause analysis of the nefario orchestration framework's
documentation drift prevention failures. Across 6 orchestrated PRs on the
web-resource-ledger project, Phase 8 (Documentation) failed to prevent significant
documentation drift, which was later caught by a dedicated audit (evolution/0022).

The five root cause patterns observed in the nefario reports are:

1. **User-directed full skip**: "Skipped per user directive (skip all post-exec)" --
   Phase 8 never ran. No guardrail prevented this from accumulating debt across
   multiple PRs. (key-versioning PR #54)

2. **"Handled inline" self-assessment**: "Code review and documentation handled inline
   during execution" -- the orchestrator declared Phase 8 unnecessary based on its
   own judgment that execution tasks covered documentation. This is a subjective
   assessment with no verification. (staging-and-tos PR #55, CORS/HSTS/ratelimit
   PR #57, staged-fallback-timeout)

3. **"Covered by Task N" delegation**: "Documentation covered by Task 3" -- a
   documentation task existed in Phase 4 but covered only a subset of documentation
   needs (the lost-ID cleanup) while OpenAPI spec and README drift went unaddressed.
   Phase 8 was skipped based on the existence of a docs task, not its completeness.
   (auth-identity + list-captures PR #51)

4. **Scope misjudgment**: "Skipped (internal logging change, no user-facing docs
   needed)" -- the orchestrator classified a change as internal-only when it actually
   created a new secret (IP_HASH_SEED) that needed documentation. (hashed-ip-logging
   PR #56)

5. **Cross-PR accumulation**: Even when individual skip decisions seemed locally
   reasonable, drift accumulated multiplicatively across the 6-PR series, resulting in
   a documentation state far more divergent than any single PR would suggest.

### Planning Consultations

#### Consultation 1: Phase 8 mechanism design analysis
- **Agent**: ai-modeling-minion
- **Planning question**: Analyze the nefario SKILL.md Phase 8 specification and
  identify structural weaknesses that allow the five failure patterns above. Focus on:
  (a) What prevents the orchestrator from self-assessing "handled inline" when it
  wasn't? (b) Is the outcome-action table sufficient to catch all drift types, or are
  there categories of documentation impact it misses (e.g., secrets, error responses,
  response headers)? (c) How should the checklist generation interact with user-directed
  skips -- should Phase 8 checklist generation be mandatory even when execution of
  Phase 8 is skipped, to make the debt visible? (d) What prompt engineering changes to
  the Phase 8 specification would make the checklist generation more rigorous and less
  susceptible to the orchestrator's subjective "not needed" assessment?
- **Context to provide**: SKILL.md Phase 8 spec (lines 1935-2030), the five failure
  patterns above, the nefario AGENT.md post-execution phases section, the WRL nefario
  reports showing the skip decisions
- **Why this agent**: Prompt engineering and multi-agent architecture expertise.
  Phase 8 is ultimately a prompt-driven process -- the checklist generation and skip
  decisions are made by an LLM following instructions. The fix must be at the prompt
  engineering level.

#### Consultation 2: Governance gap analysis
- **Agent**: lucy
- **Planning question**: From a governance and intent alignment perspective, how did
  the framework's existing safeguards fail to prevent documentation drift? Specifically:
  (a) The cross-cutting checklist says Documentation is "ALWAYS include" -- but this
  applies to planning phases (1-4), not Phase 8 execution. Is there a governance gap
  between "documentation agent participates in planning" and "documentation is actually
  produced and verified"? (b) Phase 5 code review includes lucy checking for "intent
  drift" -- why didn't Phase 5 catch the documentation gaps? Is it because Phase 5
  was also skipped (skip-all-post-exec)? (c) What repo convention enforcement
  mechanisms could detect documentation debt accumulating across multiple PRs?
  (d) Should there be a CLAUDE.md-level rule that documentation verification cannot
  be self-assessed by the orchestrator?
- **Context to provide**: Cross-cutting checklist spec, Phase 5 code review spec,
  Phase 8 conditional triggers, WRL nefario reports showing skip patterns, the drift
  audit outcome
- **Why this agent**: Lucy's domain is exactly this -- enforcing that human intent
  (documentation stays current) is not silently lost through process shortcuts. The
  "handled inline" pattern is textbook intent drift.

#### Consultation 3: Simplicity vs. completeness trade-off
- **Agent**: margo
- **Planning question**: The documentation drift failure occurred partly because the
  framework optimized for simplicity (skip what seems unnecessary) over completeness
  (always verify). Analyze the tension between: (a) YAGNI/KISS principle -- don't run
  unnecessary phases, reduce approval fatigue, trust the orchestrator's judgment about
  what's internal-only. (b) Documentation completeness -- always verify, never trust
  self-assessment, treat docs as a first-class deliverable. Where is the right balance?
  Specifically: Is a mandatory Phase 8 checklist generation (even when Phase 8
  execution is skipped) over-engineering, or is it the minimum viable safeguard? Would
  a "docs debt tracker" across PRs add necessary accountability or unnecessary
  complexity? Are there simpler mechanisms than additional phases that could catch drift
  (e.g., a pre-PR docs diff check)?
- **Context to provide**: SKILL.md Phase 8 spec, the skip patterns from WRL reports,
  Helix Manifesto principles, the actual drift found (13 OpenAPI discrepancies, 17
  README items)
- **Why this agent**: Margo prevents over-engineering. Any fix to Phase 8 must avoid
  adding heavyweight processes that create new approval fatigue. Margo ensures proposed
  fixes are proportional to the problem.

#### Consultation 4: Documentation agent effectiveness
- **Agent**: software-docs-minion
- **Planning question**: When Phase 8 did run in the WRL project (e.g., the scaffold
  PR where phase8-checklist.md was generated), was the outcome-action table sufficient
  to catch the types of drift that later accumulated? Specifically: (a) The table
  covers "New API endpoints" and "Config changed" but not "New secrets" or "New
  response headers" or "Changed error responses" -- are these gaps in the outcome-action
  taxonomy? (b) When documentation IS produced in Phase 4 execution (as part of an
  execution task), what verification would confirm it's complete? The "Documentation
  covered by Task 3" assessment was wrong because Task 3 covered only a subset. (c) How
  should the OpenAPI spec be treated in the documentation framework -- is it a doc
  artifact that Phase 8 should verify against code, or a code artifact that Phase 6
  should validate? (d) Propose additions or modifications to the outcome-action table
  that would catch the specific drift items found in the WRL audit.
- **Context to provide**: Current outcome-action table from SKILL.md, the 13 OpenAPI
  discrepancies and 17 README drift items from the audit, Phase 8 checklist from the
  scaffold PR
- **Why this agent**: Domain expert on documentation architecture. Can identify
  taxonomy gaps and propose concrete additions to the outcome-action table.

#### Consultation 5: UX of the skip mechanism
- **Agent**: ux-strategy-minion
- **Planning question**: The post-execution skip mechanism (Run all / Skip docs only /
  Skip all post-exec) contributes to documentation drift by making it too easy to
  accumulate doc debt without visibility. Analyze: (a) The current skip UX presents
  Phase 8 as a low-consequence choice -- "Skip docs" sounds harmless. How should the
  UX change to make the cost of skipping visible? (b) When a user skips Phase 8
  multiple times across PRs, there's no accumulated debt signal. What would a
  progressive disclosure approach to doc debt look like? (c) The "handled inline"
  assessment has no user-facing verification -- the orchestrator decides internally.
  Should the user see what Phase 8 WOULD have done even when it's skipped? (d) How
  should the cognitive load of documentation verification balance against the existing
  approval gate fatigue problem?
- **Context to provide**: SKILL.md post-execution skip mechanism (lines 1752-1773),
  the approval gate anti-fatigue rules, the five failure patterns, the drift audit
  scope
- **Why this agent**: UX strategy for orchestration interfaces. The skip mechanism is
  a UX decision that has downstream quality implications. The fix must not create new
  fatigue.

### Cross-Cutting Checklist

- **Testing**: Not included for planning. This task produces framework specification
  changes (SKILL.md, AGENT.md, the-plan.md), not executable code. Phase 6 will
  validate any test-related impacts during execution.
- **Security**: Not included for planning. Documentation drift is a quality/usability
  concern, not a security concern. The dangerously false key rotation warning is a
  symptom of doc drift, not a security design issue. Security-minion participated in
  the original PRs and did not flag documentation gaps (which is outside their scope).
- **Usability -- Strategy**: ALWAYS include -- Consultation 5 (ux-strategy-minion)
  covers the skip mechanism UX and the cognitive load trade-offs of documentation
  verification.
- **Usability -- Design**: Not included for planning. No user-facing interfaces are
  being designed. The changes are to orchestration workflow specifications.
- **Documentation**: ALWAYS include -- Consultation 4 (software-docs-minion) covers
  the documentation agent effectiveness and outcome-action table gaps. user-docs-minion
  is not needed for planning because the issue is the framework mechanism, not the
  content of user documentation.
- **Observability**: Not included for planning. No runtime components are being
  created. The "observability" of documentation debt is addressed by ux-strategy-minion
  (Consultation 5) in terms of user-facing signals rather than runtime metrics.

### Anticipated Approval Gates

1. **Root cause analysis and proposed mechanism changes** (MUST gate): The analysis
   produces framework specification changes that affect how all future orchestrations
   handle documentation. Multiple valid approaches exist (mandatory checklist generation,
   debt tracking, inline verification, skip cost visibility). The user needs to approve
   the direction before spec changes are written. Hard to reverse (framework spec changes
   propagate to all future orchestrations), high blast radius (affects SKILL.md,
   AGENT.md, the-plan.md).

2. **Spec file changes** (OPTIONAL gate): The actual modifications to SKILL.md,
   AGENT.md, and/or the-plan.md. Could be gated or non-gated depending on the
   scope of changes approved in Gate 1.

### Rationale

Five specialists were selected because this task spans five distinct domains that each
contributed to the failure:

- **ai-modeling-minion**: The Phase 8 mechanism is a prompt-driven pipeline. The fix
  requires prompt engineering to make checklist generation more rigorous and resistant
  to self-assessment shortcuts.
- **lucy**: The failure is fundamentally a governance gap -- intent (documentation
  stays current) was lost through process shortcuts. Lucy detects exactly this class
  of drift.
- **margo**: Any fix risks over-engineering. The WRL project ran 6 PRs in rapid
  succession -- adding heavyweight verification to each PR may create unsustainable
  overhead. Margo ensures proportionality.
- **software-docs-minion**: The outcome-action table has taxonomy gaps. A documentation
  architecture expert can identify what's missing and propose concrete additions.
- **ux-strategy-minion**: The skip mechanism's UX makes it too easy to accumulate debt
  invisibly. The fix must balance visibility with cognitive load.

Agents NOT included for planning:
- **test-minion**: No executable code produced; testing concerns handled by Phase 6
- **security-minion**: Documentation drift is not a security design concern
- **observability-minion**: No runtime components
- **ux-design-minion**: No UI interfaces
- **code-review-minion**: Changes are to specifications, not code
- All other agents: Not relevant to framework self-analysis

### Scope

**In scope**:
- Root cause analysis of why Phase 8 failed across WRL Act 1 PRs
- Identification of structural weaknesses in the Phase 8 specification (SKILL.md)
- Identification of governance gaps in the cross-cutting checklist and skip mechanism
- Proposed changes to SKILL.md, AGENT.md, and/or the-plan.md to prevent recurrence
- Assessment of the outcome-action table taxonomy for completeness
- UX analysis of the post-execution skip mechanism

**Out of scope**:
- Fixing any remaining WRL documentation drift (already handled by evolution/0022)
- Changes to individual agent AGENT.md files (other than nefario)
- New tooling or CI pipelines for documentation drift detection (may be recommended but not implemented)
- Retroactive analysis of non-WRL projects
- Changes to Phases 1-4 or Phase 3.5 (unless the analysis reveals they are implicated)

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding | Not relevant to this task (no agents being rebuilt) |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant to this task |
| despicable-prompter | .claude/skills/despicable-prompter/ (symlink) | LEAF | Briefing coaching | Not relevant to this task |

#### Precedence Decisions

No precedence conflicts. None of the discovered external skills overlap with the
specialist agents selected for this task.
