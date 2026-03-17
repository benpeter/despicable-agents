MODE: SYNTHESIS
ADVISORY: true

You are synthesizing specialist planning contributions into a
team recommendation. This is an advisory-only orchestration --
no code will be written, no branches created, no PRs opened.

Do NOT produce task prompts, agent assignments, execution order,
approval gates, or delegation plan structure. Produce an advisory
report using the advisory output format defined in your AGENT.md.

## Original Task
Improve gate review transparency in the nefario orchestration system so users see decision rationale at gates instead of checking scratch files.

Currently, the nefario approval gates present task lists, agent names, counts, and brief summaries — but NOT the reasoning, trade-offs, rejected alternatives, or conflict resolutions from the specialist team discussions. The user must navigate to scratch files to understand what the team actually discussed. The gates are oriented toward "here's what we'll do" not "here's what we debated and why."

The WRL evolution log format (decisions.md, process.md) provides a reference for self-contained decision documentation. The goal is to bring that quality of information INTO the gates themselves.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-software-docs-minion.md

## Key consensus across specialists:

### ux-strategy-minion
Add a "Decisions Brief" section (0-4 entries) to the Execution Plan Gate using a compressed self-contained format (Chosen/Over/Why). Triage: conflicts first, then trade-offs. Process narrative stays in scratch/report, not in gate.

### ai-modeling-minion
Chain of additive changes through the data pipeline: inline summary template gets Decisions field (+20-40 tokens), synthesis output gets Key Design Decisions table, gate gets DECISIONS block (max 5 rows), compaction focus strings name decisions explicitly. ~270-590 tokens total budget impact.

### lucy
Not intent drift — it's a consistency gap. Mid-execution gates already have RATIONALE+rejected alternatives. Converge all gates toward the same structural pattern at density proportional to scope. Update SKILL.md "anomaly detection" framing to match actual design intent.

### software-docs-minion
Four artifacts affected (SKILL.md, AGENT.md, TEMPLATE.md, orchestration.md). Root cause: synthesis output lacks structured per-task gate rationale field. TEMPLATE.md Key Design Decisions vs Decisions distinction needs enforcing. Changes should work within existing RATIONALE block, not add new sections.

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Identify consensus and dissent -- preserve minority positions
4. Produce an advisory report with executive summary, team consensus,
   dissenting views, supporting evidence, risks, next steps, and
   conflict resolutions
5. Write your complete advisory synthesis to
   /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase3-synthesis.md
