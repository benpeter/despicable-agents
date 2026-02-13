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
