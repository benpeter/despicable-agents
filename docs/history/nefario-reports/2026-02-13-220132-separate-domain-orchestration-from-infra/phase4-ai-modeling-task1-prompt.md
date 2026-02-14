You are auditing the nefario orchestration files to classify every section as INFRASTRUCTURE (domain-independent) or DOMAIN-SPECIFIC (would change for a non-software domain). This classification drives a refactoring that will extract domain-specific content into a replaceable adapter file.

## What to do

Read these two files completely:
1. `skills/nefario/SKILL.md` (~2328 lines) -- the orchestration workflow
2. `nefario/AGENT.md` (~869 lines) -- the orchestrator's system prompt

For each major section (H2, H3, or logical block), classify it:
- **INFRASTRUCTURE**: Domain-independent mechanics that work the same regardless of domain (subagent spawning, scratch file management, status line, compaction, report generation, gate interaction mechanics, communication protocol, AskUserQuestion flows, content boundary markers, external skill discovery)
- **DOMAIN-SPECIFIC**: Content that a non-software domain would replace (agent roster, delegation table, cross-cutting dimensions, mandatory/discretionary reviewers, phase-specific agent names, artifact classification, model selection rules mentioning specific agents, gate classification examples, commit/branch/PR conventions, secret sanitization patterns, post-execution phase definitions naming specific agents)
- **MIXED**: Infrastructure mechanism with embedded domain-specific parameters. For these, identify the exact seam: what is the mechanism (infrastructure) and what are the parameters (domain-specific).

Pay special attention to:
- Phase announcements in SKILL.md that name specific phases (the numbering is domain-specific)
- Reviewer prompt templates that reference software concepts
- Conditional logic tied to "code" vs "docs" file classification
- The dark-kitchen pattern (infrastructure) vs. which phases use it (domain-specific)
- Gate interaction mechanics (infrastructure) vs. gate classification examples (domain-specific)
- Secret sanitization: the mechanism is infrastructure, the regex patterns are domain-specific

## What to produce

Write a classification document to the working directory at `audit-classification.md` with this structure:

```
# Domain/Infrastructure Classification

## SKILL.md

### Section: <name> (lines N-M)
Classification: INFRASTRUCTURE | DOMAIN-SPECIFIC | MIXED
Rationale: <why>
[If MIXED] Infrastructure part: <what>
[If MIXED] Domain-specific part: <what>
[If MIXED] Extraction approach: <how to separate>

## AGENT.md

### Section: <name> (lines N-M)
...

## Summary

Total domain-specific sections: N
Total infrastructure sections: N
Total mixed sections: N
Estimated domain-specific content volume: ~N lines
```

Also write the classification to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/audit-classification.md

## What NOT to do

- Do not modify any source files. This is a read-only audit.
- Do not propose solutions or schemas. That is Task 2's job.
- Do not assess whether the separation is a good idea. That decision is made.
- Do not skip the SKILL.md analysis -- it is the larger and more complex file.

## Context

The goal is to enable a user forking despicable-agents for a non-software domain (e.g., regulatory compliance, corpus linguistics) to replace only domain-specific parts. The audit identifies what those parts are. The current system has 26 software-development specialist agents, a 9-phase workflow, and software-specific post-execution verification (code review, test execution, deployment, documentation).

Key files to read:
- /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md
- /Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
