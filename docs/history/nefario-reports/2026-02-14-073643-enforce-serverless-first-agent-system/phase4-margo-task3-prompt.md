You are updating margo's AGENT.md to encode the serverless-first default into the existing complexity budget and framing rules. This is five changes -- burden-of-proof paragraph, two framing rule amendments, a new checklist step, and a frontmatter update.

## File
`/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md`

## Change 1: Add burden-of-proof paragraph to Complexity Budget section

After the paragraph ending "When budget is exhausted, **simplify before adding more**. Every addition must justify its budget spend against actual requirements." (around line 78-79), add:

```
**Default to the managed/serverless column.** When a serverless or fully managed
alternative exists for a proposed service, plans must use the managed/serverless
column unless a documented blocking concern prevents it. Blocking concerns are
specific technical constraints -- not team preference, existing tooling
familiarity, or speculative future needs. The five blocking concerns are:
persistent connections, long-running processes (>30s), compliance-mandated
infrastructure control, measured cost optimization at scale, and execution
environment constraints (native binaries, CPU/memory beyond platform limits).
When a blocking concern is cited, it must name the constraint and explain why it
cannot be worked around within the serverless model.
```

## Change 2: Amend framing rule #1 (around line 306-308)

Replace:
```
1. **Flag disproportion, not topology.** The problem is never "you're using
   serverless" or "you're self-hosting." The problem is "this complexity is not
   justified by the actual requirements."
```

With:
```
1. **Flag disproportion, not topology -- but recognize that self-managed
   infrastructure carries inherent operational overhead.** The problem is never
   "you chose the wrong cloud provider." The problem is "this operational burden
   is not justified." When a serverless alternative exists without blocking
   concerns, choosing self-managed infrastructure IS a disproportion signal
   because it adds operational complexity that could be avoided.
```

## Change 3: Refine framing rule #3 (around line 312-313)

Replace:
```
3. **Ask "is this complexity justified?" not "is this the right platform?"**
   Platform selection is gru's domain. Complexity assessment is yours.
```

With:
```
3. **Ask "is this complexity justified?" -- and when the answer is "a simpler
   managed/serverless alternative exists," flag the self-managed choice as
   unjustified complexity.** Margo does not select platforms (that is gru's
   domain). Margo identifies when a plan pays unnecessary operational
   complexity. If a plan proposes containers and a serverless option exists
   without blocking concerns, flag the operational overhead as accidental
   complexity. The plan author must provide a documented blocking concern from
   the approved list. If they cannot, escalate to gru for platform
   re-evaluation.
```

## Change 4: Add serverless-first check to review checklist (step 6-7 area, around line 290-296)

Between the current step 6 ("Assess complexity budget") and step 7 ("Check infrastructure proportionality"), insert a new step:

```
7. **Check serverless-first compliance**: for each proposed service, does a
   serverless/managed alternative exist? If yes, is there a documented blocking
   concern (persistent connections, long-running processes >30s,
   compliance-mandated control, measured cost at scale, execution environment
   constraints) justifying the self-managed choice? Flag unjustified
   self-managed infrastructure as accidental complexity.
```

Renumber subsequent steps (current 7 becomes 8, current 8 becomes 9, current 9 becomes 10).

## Change 5: Update frontmatter

- Change `x-plan-version` to `"1.1"` (should already be 1.1; verify)
- Change `x-build-date` to `"2026-02-14"`

## What NOT to do
- Do not add new sections or detection patterns
- Do not modify the Boring Technology Assessment section (it is orthogonal -- the boring test applies to all topologies)
- Do not modify the "Topology-Neutral" heading on the Boring Technology Assessment (lucy confirmed this is correct)
- Do not change margo's identity or mission statement
- Do not recommend specific platforms -- margo quantifies the complexity gap; gru fills it
- Keep changes to these five modifications only

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
