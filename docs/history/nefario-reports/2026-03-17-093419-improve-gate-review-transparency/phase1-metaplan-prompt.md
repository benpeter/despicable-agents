MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

Look through the documentation format in ../web-resource-ledger/docs/evolution/ and also check the CLAUDE[.local].md files that make that happen.

Currently, this project's gate reviews are opaque - they don't really give the user an idea of what the team has discussed and what the user is supposed to decide, so the user will have to check the scratch dir and find out.

This format comes way closer, even if in how it's used, it's documentation in hindsight.

But I want the team to evaluate how the gates can be improved so that the user has the rationale of the decisions they are supposed to make in front of them and can make a meaningful decision.

## Working Directory
/Users/ben/github/benpeter/despicable-agents

## Reference Material Already Gathered

The calling session has already explored the WRL evolution log format. Key observations:

### WRL Evolution Log Structure
Each evolution entry in `../web-resource-ledger/docs/evolution/NNNN-name/` contains:
- `prompt.md` — the task briefing
- `decisions.md` — structured decisions with Decision/Alternatives/Rationale/Resolution
- `outcome.md` — what was built, files changed, surprises
- `process.md` — narrative of how the agent team worked: specialist arguments, disagreements, resolutions, human interventions

### WRL CLAUDE.md Mandates
The WRL project's CLAUDE.md requires evolution log entries after every nefario orchestration. It also requires `process.md` documenting:
- Which specialists were consulted and why
- What each specialist argued and where they disagreed
- How conflicts were resolved in synthesis
- What the human changed at approval gates and why
- What the human chose NOT to intervene on and why

### Key Quality of WRL decisions.md
Each decision in WRL is self-contained: you can read any single decision and understand what was chosen, what was rejected, and why. The process.md adds the narrative of HOW the team reached that conclusion including minority opinions and rejected alternatives.

### The Gap in Current Nefario Gates
The current nefario gates (Team, Reviewer, Execution Plan, mid-execution) present:
- Task lists, agent names, counts
- But NOT the reasoning, trade-offs, rejected alternatives, or conflict resolutions
- The user must navigate to scratch files to understand what the team actually discussed
- The gate briefs are oriented toward "here's what we'll do" not "here's what we debated and why"

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase1-metaplan.md`
