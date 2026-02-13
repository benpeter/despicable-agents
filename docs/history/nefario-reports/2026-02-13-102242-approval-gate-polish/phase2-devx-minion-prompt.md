You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Polish approval gate presentation in skills/nefario/SKILL.md:
1. Apply backtick card framing to 4 remaining gates (Team, Reviewer, Execution Plan, PR) — matching the pattern already applied to the mid-execution gate
2. Add markdown links to scratch files in all 5 gates (team, reviewer, exec plan, mid-execution, PR)
3. Shorten scratch dir display (slug-only display text, full path as link target)
4. Add prompt+verdict links in advisory sections
5. Make links visually distinct

## Your Planning Question

SKILL.md uses template examples (code blocks with placeholders like `$SCRATCH_DIR/{slug}/`) that the calling session interprets at runtime. When adding MD links to these templates:
(a) What is the cleanest way to express `[display-text](path)` links inside code block templates where the path contains variables?
(b) How should backtick card framing interact with MD links — should link text be backtick-wrapped, or does that create rendering ambiguity?
(c) What consistency rules should apply across all five gates so the link and framing patterns are predictable?

## Context

Read the following files to understand the current templates:
- /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md — the full orchestration skill file

Focus specifically on:
- The existing mid-execution approval gate template (already has card framing — this is the pattern to match)
- The four gates that need card framing (Team Approval Gate, Reviewer Approval Gate, Execution Plan Approval Gate, PR Gate)
- The CONDENSE line format
- The Scratch File Convention section
- The ADVISORIES format in the Execution Plan section
- Issue #85's pattern description: borders with backtick-wrapped dashes, header with backtick-wrapped title, field labels in backticks

## Instructions
1. Read the SKILL.md to understand the current templates
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

### Recommendations
<your expert recommendations for template authoring, link syntax, and consistency>

### Proposed Tasks
<specific tasks that should be in the execution plan>

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

5. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ICWV4u/approval-gate-polish/phase2-devx-minion.md`
