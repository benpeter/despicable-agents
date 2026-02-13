## Domain Plan Contribution: product-marketing-minion

### Recommendations

**Tier Classification: Tier 3 (Document Only)**

This change is an internal quality improvement to nefario's SKILL.md communication protocol. Applying the tier decision criteria in order:

1. **Does this change what the project can do?** No. No new capability is introduced. Users could already run orchestrations with phase transitions, approval gates, and scratch directories. The change makes existing orchestration messages easier to read.

2. **Would a user notice during normal usage?** Borderline. A user running `/nefario` would see better-formatted phase transitions and clearer approval gate labels. However, this is a polish improvement to the orchestrator's output formatting, not a change in what information is presented or how the workflow functions. The information content is unchanged; the visual presentation improves.

3. **Does it strengthen a core differentiator?** "Phased orchestration" and "User approval gates at every phase transition" are listed as core differentiators in the README. Better visibility of these elements could marginally strengthen the differentiator perception. However, the README's claims ("nine structured phases," "approval gates at every phase transition") remain accurate regardless of this change. The differentiator exists at the capability level, not the formatting level.

4. **Does it change the user's mental model?** No. The nine-phase workflow, approval gates, and scratch directory pattern are all unchanged. The user's understanding of how nefario works does not shift.

5. **Is it a breaking change?** No.

**Verdict: Tier 3.** The change improves output readability within SKILL.md's communication protocol. No README or positioning updates are warranted.

**Specific reasoning for no README change:**

The README currently says:
- "nine structured phases from meta-planning through parallel execution to post-execution verification"
- "User approval gates at every phase transition so you stay in control"

Both statements remain accurate before and after this change. The README does not describe the visual formatting of phase announcements or approval gate labels. It describes capabilities, not output formatting. Updating the README for an internal formatting improvement would over-index on implementation details that belong in `docs/using-nefario.md` or the SKILL.md itself.

**Documentation coverage check:**

The change scope (SKILL.md communication protocol, approval gate message formatting, scratch directory reference presentation, phase transition announcements) is entirely internal to the SKILL.md file. The existing documentation references in `docs/using-nefario.md` and `docs/orchestration.md` describe the orchestration workflow at a level of abstraction above output formatting. They do not need updates unless the change alters the workflow itself (it does not).

If the implementation adds or changes any user-facing workflow behavior (e.g., new approval gate options, different phase sequencing), that would elevate this to Tier 2 and trigger documentation updates. Based on the stated scope ("visual distinction, meaningful labels instead of raw paths"), this stays at Tier 3.

### Proposed Tasks

None from product-marketing-minion. This is a Tier 3 change requiring no positioning, README, or messaging work.

If a changelog or release notes entry is desired for completeness:
- Category: **Changed**
- Entry: "Improved orchestration message visibility: phase transition announcements are visually distinct, approval gates show meaningful labels instead of raw scratch directory paths."
- This is a changelog-only item, not a release announcement item.

### Risks and Concerns

1. **Scope creep to Tier 2**: If the implementation goes beyond formatting (e.g., adding new phase announcement content, changing what information approval gates display, altering the approval gate interaction flow), the tier classification should be revisited. The line between "better formatting" (Tier 3) and "better UX that changes how users interact with gates" (Tier 2) is narrow.

2. **Documentation drift risk is low**: The SKILL.md is the single source of truth for nefario's communication protocol. Changes to SKILL.md are self-documenting. No downstream documentation references the specific formatting of phase announcements or approval gate labels.

### Additional Agents Needed

None. This is a SKILL.md-internal change. The agents already involved in the plan (likely devx-minion and/or ux-strategy-minion for the interaction design aspects) are sufficient.
