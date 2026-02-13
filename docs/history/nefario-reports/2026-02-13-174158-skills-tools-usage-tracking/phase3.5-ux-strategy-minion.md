# UX Strategy Review -- Delegation Plan

## Verdict: ADVISE

The plan is well-structured and adopts my core Phase 2 recommendations (merge into External Skills, collapse by default, late placement in hierarchy, frontmatter conditional inclusion). The two-task decomposition is clean and the dependency chain is correct. No blocking concerns.

### Non-blocking warnings

**1. The `<summary>` line is too generic.**
The plan specifies `<summary>Session resources</summary>` (Task 1, line 109 of the skeleton). This violates progressive disclosure best practice: the collapsed summary should give the reader enough information to decide whether to expand. A generic label forces expansion to determine relevance. My Phase 2 recommendation was `<summary>Session Resources (N skills, M tool types)</summary>` with inline counts. The plan dropped this. Impact is low (this is reference-grade data in an appendix zone), but a count-bearing summary line is strictly better and costs nothing.

**2. "Tool Usage" subsection title lacks the best-effort signal.**
My Phase 2 recommendation was to use language signaling approximation ("Approximate tool usage") rather than the definitive-sounding "Tool Usage." The plan uses "Tool Usage" as the subsection header and relies on the disclaimer paragraph below the table. This is acceptable but not ideal -- the disclaimer is hidden inside a collapsed section, meaning users who scan subsection headers after expanding will see "Tool Usage" and may assume precision. Consider "Tool Usage (approximate)" or keep the disclaimer but make the subsection heading hint at its nature.

**3. Three subsections within a collapsed section may be over-structured.**
The plan creates three subsections (External Skills, Skills Invoked, Tool Usage) inside a collapsed `<details>` block. In practice, External Skills will almost never appear (it has not appeared in 50+ reports). This means the typical expanded view shows two subsections. The hierarchical depth (H2 > details > H3 > H3 > H3) is borderline over-structured for what is essentially two short lists. This is not blocking -- the structure is forward-compatible and handles the edge case where external skills do appear. But monitor whether it feels heavy in practice and consider flattening if External Skills continues to never appear.

**4. Session Resources "always structurally present" rule may generate noise in advisory-mode reports.**
The conditional section rules say "Never omitted entirely" for Session Resources. In advisory mode, where Tool Usage is also omitted, the section would contain only "Skills Invoked: /nefario" inside a collapsed block. This is a collapsed section with one bullet point. It is not harmful (it is hidden), but it is the definition of information with zero signal. The structural consistency argument is valid, so this is not blocking, but be aware this is a trade-off: structural consistency vs. minimum-viable-content.

### What the plan gets right (confirming alignment)

- Merging into External Skills rather than creating a new section eliminates section proliferation.
- Collapsed by default respects the primary reading journey (Summary > Decisions > Phases > Execution).
- Conditional frontmatter field (`skills-used` only when additional skills beyond `/nefario`) minimizes noise.
- Best-effort framing for tool counts with graceful degradation ("not available") prevents false precision.
- Session-total granularity (not per-phase/per-agent) is the right simplification.
- Approval gate on Task 1 is correct -- the structural decision propagates to all future reports.
