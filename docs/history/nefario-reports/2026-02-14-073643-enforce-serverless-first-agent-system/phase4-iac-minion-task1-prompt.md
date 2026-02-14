You are updating `the-plan.md` to encode serverless-first as the default deployment stance for the agent system. This is an incremental change on branch `nefario/fix-serverless-bias`, building on PR #123 which established topology-neutral framing. The current task deliberately shifts from neutral to serverless-first.

**IMPORTANT**: This file is human-edited per project rules. You are making changes that will be presented for human approval before proceeding.

## Changes to make

### iac-minion spec (starts at line 726)

**Line 740** -- Update "Deployment strategy selection" description:
Change: `Deployment strategy selection (evaluating serverless vs. container vs. self-managed for a given workload)`
To: `Serverless-first deployment strategy selection (default to serverless; evaluate deviation only when blocking concerns exist)`

**Lines 750-755** -- Update research focus:
Replace the segment starting with `serverless deployment patterns` through the end of the research focus with:
`serverless-first deployment patterns, cold start optimization, FaaS cost modeling, blocking concerns for serverless deviation (persistent connections, long-running processes >30s, compliance-mandated infrastructure control, measured cost optimization at scale, execution environment constraints beyond platform limits).`

**Bump spec-version** from `2.0` to `2.1` (line 757).

### margo spec (starts at line 539)

**Line 544** -- Add to remit list (after "Reviewing plans for unnecessary complexity..."):
Add a new bullet: `- Enforcing serverless-first default: when a serverless/managed alternative exists, plans must justify self-managed infrastructure with a documented blocking concern`

**Do NOT bump margo spec-version** -- the margo AGENT.md changes in Task 2 are hand-edits to an already-built agent, not a spec rebuild trigger. Leave spec-version at 1.1.

## File
`/Users/ben/github/benpeter/2despicable/4/the-plan.md`

## What NOT to do
- Do not modify any other agent specs
- Do not modify any sections outside the iac-minion and margo spec blocks
- Do not add new sections to the-plan.md
- Do not modify the spec structure (headers, field names)
- Keep changes surgical -- minimal diff

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
