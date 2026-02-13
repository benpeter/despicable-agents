## Meta-Plan

### Task Summary

Polish all approval gate templates in `skills/nefario/SKILL.md` by: (1) applying
backtick card framing to the four gates that lack it (Team, Reviewer, Execution Plan,
PR), matching the mid-execution gate pattern from PR #79; and (2) adding MD links
to scratch files that produced each decision (advisory prompt/verdict links, slug-only
display text for directory references, visually distinct link formatting).

Single-file change to `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`.

### Planning Consultations

#### Consultation 1: Gate interaction design and link affordance
- **Agent**: ux-strategy-minion
- **Planning question**: Given that approval gates are the highest-attention UI element
  in the orchestration workflow (Decision weight in the Visual Hierarchy table), how
  should scratch file links be integrated without diluting the decision-making focus?
  Specifically: (a) Where in the gate template should links appear -- inline with
  advisories, in a footer section, or both? (b) What display text convention makes
  links scannable without adding visual noise (e.g., `[prompt](path) . [verdict](path)`
  vs a consolidated "Sources:" section)? (c) For the four simpler gates (Team, Reviewer,
  Execution Plan, PR) that have fewer scratch file references than mid-execution gates,
  what is the minimum viable link set? Consider cognitive load: gates are interruptions
  where users need to decide, not explore.
- **Context to provide**: The five gate templates from SKILL.md (lines 439-568 Team,
  773-869 Reviewer, 1029-1147 Execution Plan, 1249-1269 Mid-execution, 1676-1686 PR).
  The Visual Hierarchy table (lines 205-212). The existing mid-execution gate card
  framing pattern. Issue #82's three requirements (advisory links, slug display text,
  visual distinction).
- **Why this agent**: UX strategy owns cognitive load assessment and simplification audits.
  The risk here is over-linking: adding so many references that the gate becomes
  harder to parse instead of easier. ux-strategy-minion can assess whether each
  proposed link genuinely serves the user's decision-making need at that moment.

#### Consultation 2: Template authoring and internal consistency
- **Agent**: devx-minion
- **Planning question**: The SKILL.md file uses template examples (code blocks with
  placeholders like `$SCRATCH_DIR/{slug}/`) that the calling session interprets at
  runtime. When adding MD links to these templates: (a) What is the cleanest way to
  express `[display-text](path)` links inside code block templates where the path
  contains variables? (b) How should the backtick card framing interact with MD links
  -- should link text be backtick-wrapped (`` [`prompt`](path) ``), or does that
  create rendering ambiguity? (c) Are there consistency rules to apply across all
  five gates so the link and framing patterns are predictable? Review the existing
  mid-execution gate framing (lines 1249-1269) as the reference implementation.
- **Context to provide**: All five gate template blocks in SKILL.md. The CONDENSE
  line format (lines 158-162) which already includes scratch paths. The Scratch File
  Convention section (lines 260-338) defining the file naming pattern. Issue #85's
  pattern description (borders, header, field labels in backticks).
- **Why this agent**: devx-minion owns SKILL.md structure, template design, and
  developer experience for configuration files. The challenge is expressing links
  inside instructional templates without ambiguity -- a template authoring problem.

### Cross-Cutting Checklist

- **Testing**: Not included for planning. The deliverable is a documentation/template
  change to SKILL.md only -- no executable code is produced. Testing would verify
  gate rendering, but that requires running a full orchestration session (integration
  test), which is out of scope for this task. Verification will be done by visual
  inspection of the template changes.
- **Security**: Not included for planning. No attack surface, authentication, user
  input handling, secrets, or dependency changes. The change modifies instructional
  templates only.
- **Usability -- Strategy**: INCLUDED as Consultation 1 (ux-strategy-minion). Planning
  question covers cognitive load assessment for link placement and density in gate
  templates.
- **Usability -- Design**: Not included for planning. No user-facing UI components
  are produced -- the change is to an internal orchestration skill template. The
  "UI" here is terminal text output, which is covered by ux-strategy-minion's
  cognitive load assessment.
- **Documentation**: Not included for planning as a separate consultation. The
  deliverable IS documentation (SKILL.md template changes). There are no API
  surface changes, no architecture changes, and no user-facing documentation
  impact. The SKILL.md changes are self-documenting.
- **Observability**: Not included for planning. No runtime components, APIs,
  services, or background processes are affected.

### Anticipated Approval Gates

None. This is a single-file template change to SKILL.md with low blast radius
(no downstream task dependencies) and easy reversibility (text formatting changes).
Per the gate classification matrix: low blast radius + easy to reverse = NO GATE.

The execution plan approval gate (Phase 3.5) will still occur as part of the
standard workflow, but no mid-execution gates should be needed within the plan itself.

### Rationale

Two specialists are consulted:

1. **ux-strategy-minion** (mandatory cross-cutting): The core risk in this task is
   over-engineering the link presentation -- adding references that create visual
   noise without improving decision quality. UX strategy's cognitive load lens
   directly addresses this. They also bring journey coherence: ensuring link
   patterns are consistent across all five gates.

2. **devx-minion**: The implementation challenge is template authoring -- expressing
   MD links with variable paths inside code block examples in a SKILL.md file.
   This is a developer experience problem: the template must be unambiguous to the
   calling session (which interpolates variables at runtime) while also being
   readable to human maintainers.

Not selected for planning:
- **software-docs-minion**: SKILL.md is an internal orchestration file, not API
  documentation or architecture documentation. The change is to presentation
  templates, not technical content.
- **frontend-minion**: No web UI involved. Terminal output formatting.
- **lucy / margo**: Governance reviewers triggered in Phase 3.5 (mandatory),
  not needed for planning consultation.
- All other specialists: No overlap with the task domain (terminal text templates).

### Scope

**In scope**:
- Apply backtick card framing to 4 gate templates: Team Approval Gate, Reviewer
  Approval Gate, Execution Plan Approval Gate, PR Gate
- Add MD links to scratch files in all 5 gate templates (including mid-execution
  which already has card framing)
- Use slug-only display text for directory references
- Add advisory prompt + verdict links in the ADVISORIES section of the Execution
  Plan Approval Gate
- Ensure visual distinction for links (backtick-wrapped or equivalent)
- Maintain consistency across all gates

**Out of scope**:
- Phase announcements (`**--- Phase N ---**`)
- Compaction checkpoints (blockquote format)
- AskUserQuestion prompts (separate mechanism)
- CONDENSE line format (already has scratch paths)
- Non-SKILL.md files (AGENT.md, the-plan.md, docs/)
- The Plan Impasse block (lines 991-1004) -- this is an escalation, not a standard gate

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding | Not relevant -- task does not modify agent specs |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- task does not affect status line |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain
(approval gate template formatting in SKILL.md).
