MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
## Problem

AskUserQuestion prompts hide the status line. When the status line is gone, the user loses context about *which orchestration run* they're looking at. This is especially bad when running parallel nefario sessions in different terminals.

The post-exec gate is the worst offender ("Post-execution phases for this task?" — no referent at all), but the issue is broader: none of the gates include the orchestration run title.

## Desired behavior

Every AskUserQuestion gate should include the orchestration run title (the same summary shown on the status line) so the user always knows which run they're deciding on, even without the status line visible.

## Audit of current gates

| Gate | Line | Current `question` | Has run title? |
|------|------|-------------------|----------------|
| P1 Team | 472 | `<1-sentence task summary>` | Partial (task summary, not run title) |
| P3.5 Review | 808 | `<1-sentence plan summary>` | Partial |
| P3 Impasse | 1008 | disagreement description | No |
| P3.5 Plan | 1134 | `<orientation line goal summary>` | Partial |
| P4 Gate | 1286 | `Task N: <task title> -- DECISION` | No (task-level, not run-level) |
| **Post-exec** | **1301** | **"Post-execution phases for this task?"** | **No context at all** |
| P4 Calibrate | 1365 | "5 consecutive approvals..." | No |
| P5 Security | 1474 | finding description | No |
| P5 Issue | 1503 | finding description | No |
| PR | 1691 | "Create PR for nefario/<slug>?" | Partial (slug) |
| Existing PR | 1883 | "PR #N exists..." | No |

## Approach

- The orchestration run title (slug or short summary) is established in Phase 1 and preserved across compaction
- Include it consistently in every gate — either in the `question` field or via a convention in the `header`
- The `header` field is capped at 12 chars, so it likely needs to go in `question`
- Fix post-exec specifically to also include the *task-level* title (it currently has neither run nor task context)
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase1-metaplan.md`
