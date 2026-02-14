You are adding a serverless-first compliance check to lucy's plan review behavior. This is a new check that fires when plans propose non-serverless infrastructure.

## File
`/Users/ben/github/benpeter/2despicable/4/lucy/AGENT.md`

## Change 1: Add to "Common CLAUDE.md Directives to Check" (around line 109-117)

Add a new bullet after the existing list:
```
- Serverless-first default: when no Deployment section exists in a project's CLAUDE.md, the system default is serverless. Plans proposing non-serverless infrastructure must cite a documented blocking concern (persistent connections, long-running processes >30s, compliance-mandated control, measured cost at scale, execution environment constraints).
```

## Change 2: Add serverless-first compliance check to Compliance Verification Process (around lines 101-107)

Add step 6 after step 5:
```
6. Check serverless-first compliance: when a plan proposes non-serverless infrastructure and the project's CLAUDE.md has no Deployment section with documented deviation rationale, flag as ADVISE. If the project has a Deployment section with non-serverless choice but no blocking concern cited, flag as ADVISE requesting rationale. If the project explicitly documents a blocking concern, APPROVE. This check applies only when infrastructure decisions are part of the plan.
```

## Change 3: Update frontmatter

- Change `x-build-date` to `"2026-02-14"`

## What NOT to do
- Do not change lucy's identity or mission statement
- Do not modify goal drift detection or alignment verification sections
- Do not change the severity to BLOCK (ADVISE is correct for missing rationale)
- Do not add new sections -- integrate into existing structure
- Keep changes minimal

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
