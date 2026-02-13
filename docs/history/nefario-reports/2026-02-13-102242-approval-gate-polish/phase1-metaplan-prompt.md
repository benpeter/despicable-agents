MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

Polish approval gate presentation: backtick card framing + scratch file links

Synthesized from GitHub issues #82 and #85. All requirements from both issues are included.

### From #82: Link to scratch files that produced the decision

**Problem**: When the user is presented with a gate or approval, they have no simple entry point to follow the conversation that led there. The current output mentions scratch file paths as plain text, which is:
1. Not clickable — file paths are not MD links
2. Messy — raw temp paths are noisy and hard to parse
3. Incomplete — advisories reference reviewer verdicts but don't link to the prompt/response pair
4. Not visually distinct — links blend into surrounding text

**Requirements**:
1. Advisory links (prompt + response): Each advisory should include MD links to both the prompt and the reviewer's response
2. Scratch dir reference: Show only the slug portion as display text; full path as link target
3. Visual distinction for links: Links must be visually distinct from surrounding text

**Scope**: All gate types (team P1, reviewer P3.5, execution plan, mid-execution gates). The CONDENSE line already preserves the scratch path.

### From #85: Apply backtick card framing to all approval gates

**Context**: PR #79 added backtick card framing to the mid-execution approval gate template only. The remaining gates need the same treatment.

**Remaining gates needing card framing**:
1. Team Approval Gate — Phase 1 team selection
2. Reviewer Approval Gate — Phase 3.5 discretionary reviewer selection
3. Execution Plan Approval Gate — Phase 3.5 plan presentation
4. PR Gate — Phase 8 PR creation offer

**Pattern**: Top/bottom borders with backtick-wrapped dashes, header line with backtick-wrapped title, field labels wrapped in backticks. Maintains Decision visual weight.

**Scope**: All four gate templates in SKILL.md only. Not phase announcements, compaction checkpoints, or AskUserQuestion prompts.

### Combined scope

Both changes apply to the same gate templates in `skills/nefario/SKILL.md`. The card framing (#85) and scratch file links (#82) should be applied together.

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning)
5. For each specialist, write a specific planning question that draws on their unique expertise
6. Return the meta-plan in the structured format
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ICWV4u/approval-gate-polish/phase1-metaplan.md`
