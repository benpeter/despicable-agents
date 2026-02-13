MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final recommendation. This is an ADVISORY-ONLY orchestration --
there is no execution plan to produce. Instead, synthesize the
specialist positions into a clear team recommendation with consensus
analysis.

## Original Task
Should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. Or should that be a separate skill?

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-margo.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-lucy.md

## Key consensus across specialists:

1. devx-minion: Strong preference for `--advisory` flag. Same workflow with different terminal condition = flag, not separate skill. Discoverability, cognitive load, and implementation simplicity all favor flag.

2. ai-modeling-minion: Recommends MODE: ADVISORY as flag. Phases 1-2 identical, Phase 3 diverges to recommendation format, Phases 3.5-8 skipped. ~60-70 lines additions.

3. margo: BLOCK on both options. YAGNI -- natural language already works. One usage, zero friction. Do nothing.

4. lucy: Flag on nefario, not separate skill. No identity drift. Advisory reports to same directory with type: nefario-advisory. Partially agrees with margo on YAGNI but sees value in formalization from proven ad hoc use.

## External Skills Context
No external skills relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve the conflict between margo (do nothing) and the others (build a flag)
3. Synthesize the positions into a clear recommendation with:
   - The team's consensus position (or majority with noted dissent)
   - The strongest arguments for and against each option
   - Conditions under which the dissenting position would become correct
   - A recommended path forward with concrete next steps (IF the team recommends building)
4. This is advisory-only -- produce a recommendation synthesis, not an execution plan
5. Write your complete synthesis to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase3-synthesis.md`
