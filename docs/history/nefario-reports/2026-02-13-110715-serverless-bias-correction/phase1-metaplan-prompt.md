MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

Advisory-only request -- no execution, no post-processing. Create a meaningful advisory report with specialist consultations on the following question:

When starting greenfield projects, the system (particularly margo as YAGNI/KISS enforcer, and the general philosophy in CLAUDE.md) thinks serverless is complicated and flags it as overengineering / YAGNI / anti-KISS. But this is a wrong bias -- serverless is actually super simple (no servers to manage, no scaling config, no Docker, no Terraform for basic deployments). The question has multiple dimensions:

1. **Bias correction**: Where does the anti-serverless bias live in the system? Is it in margo's heuristics? In CLAUDE.md project instructions? In the iac-minion's framing? How should it be corrected?
2. **Entry point**: What's the right place to encode "serverless is simple, not complex" -- CLAUDE.md? Lucy's conventions? Margo's complexity budget? A combination?
3. **Agent roster**: Should there be a dedicated serverless agent in the roster? Or should serverless knowledge be distributed across existing agents (iac-minion, edge-minion)?
4. **Greenfield defaults**: When starting a new project with no infrastructure yet, what should the default recommendation be? Serverless-first? It depends?

This is a consultation -- specialists should analyze the question from their domain perspective and make recommendations. No code will be written.

## Working Directory
/Users/ben/github/benpeter/despicable-agents

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
   (not execution -- planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h3BN8s/serverless-bias-correction/phase1-metaplan.md
