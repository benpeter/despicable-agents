# Phase 5 -- Margo Review: Enforce Serverless-First Across Agent System

VERDICT: ADVISE

The changes are focused and proportional to the task: encoding a serverless-first default across the agent system. No new files were created beyond what was planned. No new dependencies, no new abstractions, no new services. The work is Markdown-only (agent prompts and documentation), which is the lightest possible implementation medium. Task count (7) is reasonable for touching 6 files across 4 agent domains plus a decision log. Overall: well-scoped, minimal diff surface, justified by the original request.

FINDINGS:

- [ADVISE] `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/AGENT.md`:17 -- The identity paragraph packs the full blocking concern list (5 items with parenthetical details) into a single dense sentence. The same list appears again at lines 170-178 (Tier 1 table), lines 180 (prose paragraph), and lines 193-201 (topology cascade). Within AGENT.md alone, the blocking concern list is enumerated 4 times. RESEARCH.md adds 3 more occurrences (lines 493, 497-506, 509). That is 7 repetitions of the same 5-item list across two files. Repetition in agent prompts is not inherently bad (reinforcement helps LLM adherence), but this level risks the opposite: context window waste on a 522-line file where every token matters.
  AGENT: iac-minion (Task 2)
  FIX: In the identity paragraph (line 17), replace the inline blocking concern enumeration with a brief reference: "Blocking concerns are documented in Step 0." This removes one repetition without losing the reinforcement from the Step 0 table and topology cascade. The RESEARCH.md repetitions (3x) can stay as-is since RESEARCH.md is reference material, not deployed.

- [ADVISE] `/Users/ben/github/benpeter/2despicable/4/margo/AGENT.md`:81-90 -- The burden-of-proof paragraph in the Complexity Budget section repeats the full 5-item blocking concern list verbatim. This same list also appears in the serverless-first compliance checklist step (lines 305-310), and in framing rule #3 (lines 332-340 reference "blocking concerns from the approved list"). Three repetitions within a single AGENT.md file. Same concern as above: reinforcement vs. context budget. Margo's AGENT.md is 418 lines -- not at risk of context overflow, but the principle of lean prompts still applies.
  AGENT: margo (Task 3)
  FIX: Acceptable as-is. The repetition serves reinforcement across three distinct behavioral sections (assessment, checklist, framing). If context pressure grows, consolidate the enumeration into the Complexity Budget paragraph and reference it from the other two locations.

- [NIT] `/Users/ben/github/benpeter/2despicable/4/docs/claudemd-template.md`:17 -- The blocking concern list in the "When to omit" section lists only 4 items (persistent connections, long-running processes, compliance-mandated control, proven cost optimization at scale) while all other files consistently list 5 (adding "execution environment constraints"). This is an omission, not a simplification choice.
  AGENT: lucy (Task 4)
  FIX: Add "execution environment constraints" to the blocking concern list on line 17 to match the canonical 5-item list used in iac-minion, margo, lucy, and decisions.md.

- [NIT] `/Users/ben/github/benpeter/2despicable/4/minions/iac-minion/RESEARCH.md`:439-464 -- The "Serverless vs. Container Decision Criteria" section (lines 439-464) retains the topology-neutral framing from the pre-change version. It discusses 8 dimensions (execution duration, state, traffic, cold starts, scale, team expertise, vendor lock-in, debugging) without referencing the blocking concern model. The immediately following section (lines 467-488, "When Serverless Is Inappropriate") also uses the old framing. Only the "Deployment Strategy Selection" section (lines 491-521) was updated to reflect the serverless-first default. The earlier sections are not wrong (they describe real tradeoffs), but they create a mixed-message where some sections say "evaluate neutrally" and others say "default to serverless."
  AGENT: iac-minion (Task 2)
  FIX: No code change needed -- RESEARCH.md is reference material, not a deployed prompt. The inconsistency is cosmetic. If a future rebuild uses RESEARCH.md to regenerate the prompt, the mixed signals could propagate. Flag for awareness, not action.
