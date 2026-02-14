You are adding Decision 31 to the design decisions log. This entry documents the policy shift from topology-neutral (established in PR #123) to serverless-first-default.

## File
`/Users/ben/github/benpeter/2despicable/4/docs/decisions.md`

## Change

Add a new Decision 31 entry at the end of the file, following the existing format. The last decision is currently Decision 30.

```
### Decision 31: Serverless-First Default (Supersedes Topology-Neutral Stance)

| Field | Value |
|-------|-------|
| **Status** | Implemented |
| **Date** | 2026-02-14 |
| **Supersedes** | Topology-neutral stance from PR #123 (2026-02-13 serverless-bias-correction advisory) |
| **Choice** | Encode serverless-first as the system default. Agents default to serverless and require a documented blocking concern to deviate. Blocking concerns: persistent connections, long-running processes (>30s), compliance-mandated infrastructure control, measured cost optimization at scale, execution environment constraints (native binaries, CPU/memory beyond platform limits). |
| **Alternatives rejected** | (1) Keep topology-neutral: rejected because false neutrality led to status-quo bias toward familiar infrastructure (Docker/Terraform) rather than criteria-driven evaluation. (2) Hard-block non-serverless: rejected because legitimate use cases (WebSockets, compliance, batch jobs) require non-serverless topologies. |
| **Rationale** | Rooted in Helix Manifesto principles: "lean and mean" (serverless eliminates infrastructure management overhead) and "ops reliability wins" (managed platform reliability exceeds most self-managed setups). The question shifts from "which topology fits?" (neutral evaluation) to "why NOT serverless?" (justify deviation). This is a strong preference, not a hard block -- the five blocking concerns provide explicit escape hatches. |
| **Consequences** | iac-minion Step 0 starts with serverless default and blocking concern gate. margo's complexity budget actively penalizes self-managed infrastructure when serverless alternative exists. CLAUDE.md template encodes serverless as the omission default. lucy enforces serverless-first compliance in plan reviews. Historical reports and the topology-neutral advisory are preserved as records of the prior stance -- they are not modified. |
```

## What NOT to do
- Do not modify any existing decisions
- Do not modify the file header or section headers
- Follow the exact table format used by existing decisions

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
