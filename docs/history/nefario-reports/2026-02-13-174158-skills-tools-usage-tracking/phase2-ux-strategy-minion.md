# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. This section is worth the cognitive cost -- but only if it stays cheap

The job-to-be-done for execution reports is **retrospective analysis**: "When I review what nefario did, I want to understand the resources it consumed, so I can identify patterns and optimize future sessions." Skills/tools tracking serves this JTBD directly. The primary reader is the project owner (Ben) doing post-session review and the occasional contributor reviewing PR descriptions.

However, the current template already has 8 visible H2 sections in a typical full-mode report (Summary, Original Prompt, Key Design Decisions, Phases, Execution, Decisions, Verification, Working Files), plus Agent Contributions collapsed. The report is information-dense. Every new section competes for scanning attention. The question is not "is this data useful?" but "is this data useful enough to justify a new section header that every report reader must skip past forever?"

My assessment: **Yes, but only if the implementation is extremely lightweight.** A full H2 section with its own table is disproportionate to the value. The data is reference-grade, not decision-grade -- you never act on it during the report reading flow, you mine it later for patterns.

### 2. Information hierarchy: late, not early

Applying progressive disclosure: skills/tools data is **reference metadata**, not **narrative content**. It belongs in the "appendix" zone of the report, alongside External Skills and Working Files. The reader's primary journey through the report is: Summary (do I care?) -> Key Design Decisions (what was decided?) -> Phases (what happened?) -> Execution (what changed?). Skills/tools usage doesn't fit this narrative arc -- it's orthogonal diagnostic data.

**Recommended position**: After Verification, near External Skills and Working Files. Specifically, between External Skills (if present) and Working Files.

### 3. Collapsible -- without question

This is textbook progressive disclosure. The data:
- Is not needed for the primary reading job (understanding what happened and why)
- Is needed occasionally for a secondary job (retrospective resource analysis)
- Adds scanning cost to every report if always-visible
- Has no decision-urgency -- it never changes what you do next

**Recommendation**: Collapsed `<details>` block, same treatment as Agent Contributions and Working Files. The summary line should give the essential count at a glance: `<summary>Session Resources (N skills, M tool types)</summary>`.

### 4. Merge with External Skills -- do NOT create a separate section

This is the strongest recommendation I have. The existing External Skills section already tracks skills per session. It currently has its own conditional inclusion rule ("include when meta-plan discovered 1+ external skills"). And critically, **it has never appeared in any actual report** -- in 50+ reports, External Skills is always omitted because no external skills have been used.

Creating a second, slightly-different skills section would violate several heuristics:
- **Consistency** (Nielsen #4): Two sections about skills with different scopes is confusing
- **Minimalist design** (Nielsen #8): Irrelevant information diminishes relevant information
- **Cognitive load**: Readers must now distinguish "External Skills" from "Session Resources: Skills" -- what's the difference? Why are there two?

Instead, **evolve the External Skills section into a broader "Session Resources" section** that captures both external skills (when present) and the new skills/tools tracking. This:
- Eliminates the "never-used section" problem -- the section now has data for every report
- Consolidates related information in one place
- Changes the conditional rule from "include when external skills found" to "always include"
- Respects the user's scanning pattern -- one place for resource-related metadata

### 5. Frontmatter vs. section: use both, minimally

The issue mentions frontmatter as an alternative. Here's the split that respects the information hierarchy:

**Frontmatter** (machine-readable, for future build-index or analysis scripts):
- `skills-used: [skill1, skill2]` -- simple array, mirrors `agents-involved` pattern
- No tool counts in frontmatter -- too noisy, not reliably extractable

**Section body** (human-readable, for browsing):
- Collapsed `<details>` with skills list and best-effort tool summary
- Keep it extremely concise -- a small table or compact list, not prose

This dual approach means programmatic analysis can query frontmatter without parsing markdown, while human readers get the collapsible detail view when they need it.

### 6. Tool counts: keep expectations low, format forgiving

The issue says tool counts are "best-effort." From a UX perspective, this is the right call. Incomplete data presented as complete data is worse than no data. The template should:
- Use language that signals approximation: "Approximate tool usage" not "Tool Usage"
- Omit the tool summary entirely if not extractable, rather than showing "unknown"
- Never show zeros -- absence means "not tracked," not "not used"

## Proposed Tasks

### Task 1: Evolve External Skills into Session Resources section

**What to do**: Rename "External Skills" to "Session Resources" in TEMPLATE.md. Restructure it as a collapsed `<details>` block containing two subsections: Skills (external skills table, preserved from current template, shown when present) and a new tools summary (best-effort, shown when extractable). Change the conditional inclusion rule from "include when external skills discovered" to "always include."

**Deliverables**:
- Updated TEMPLATE.md section with new name, structure, and collapsibility
- Updated conditional section rules table
- Updated collapsibility rules table
- Updated report writing checklist step 14

**Dependencies**: None

### Task 2: Add `skills-used` to frontmatter

**What to do**: Add a `skills-used` field to the YAML frontmatter spec. Array of skill names invoked during the session. Follow the `agents-involved` pattern exactly -- same syntax, same position in the frontmatter block (directly after `agents-involved`).

**Deliverables**:
- Updated frontmatter skeleton in TEMPLATE.md
- Updated frontmatter fields documentation table
- Note: conditional (include when 1+ skills used, omit when none) to avoid empty arrays in the majority of reports

**Dependencies**: None

### Task 3: Update SKILL.md generation guidance

**What to do**: Add instructions to the report-generation section of SKILL.md telling nefario to: (a) populate `skills-used` frontmatter from conversation context, (b) always generate the Session Resources section, (c) include external skills table when applicable, (d) include best-effort tool summary when extractable, (e) collapse the entire section.

**Deliverables**:
- Updated SKILL.md report generation instructions
- Updated checklist step referencing Session Resources

**Dependencies**: Tasks 1 and 2 (needs to reference the final template structure)

## Risks and Concerns

### Risk 1: Section proliferation -- the template is already heavy
**Severity**: Medium
**Mitigation**: My core recommendation (merge into External Skills rather than add a new section) directly addresses this. If the team creates a separate section instead, the template grows from 12 to 13 named sections, and the cognitive cost compounds across every future report.

### Risk 2: Tool counts create false precision
**Severity**: Low-Medium
**Mitigation**: Best-effort language in the template, explicit "omit if not extractable" rule. The risk is that nefario generates plausible-looking but inaccurate counts from conversation context. The template should make clear this is approximate metadata, not auditable data.

### Risk 3: Overlap confusion between skills-used (frontmatter) and agents-involved (frontmatter)
**Severity**: Low
**Mitigation**: Skills and agents are distinct concepts in this system (skills are invocable capabilities like despicable-lab; agents are specialist personas like devx-minion). The naming makes this clear. But the TEMPLATE.md documentation should include a one-line clarification of the distinction in the frontmatter fields table.

### Risk 4: The "always include" rule changes existing report validity semantics
**Severity**: Low
**Mitigation**: The issue explicitly says "existing reports remain valid (new section is additive)." Since existing reports never had an External Skills section (it was always omitted per the conditional rule), renaming it and making it always-present doesn't invalidate any existing report -- they simply lack the new section, which is expected for older template versions.

## Additional Agents Needed

**software-docs-minion** -- The template and skill documentation changes are primarily documentation work. software-docs-minion should review the template structure changes for consistency with existing patterns (frontmatter conventions, conditional section rules, collapsibility rules). They were the primary author of the v3 template structure and understand its internal consistency requirements.

No other additional agents needed. devx-minion (likely already planned) handles the SKILL.md instruction changes.
