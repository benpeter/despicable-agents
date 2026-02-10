# Phase 8 Marketing Lens Specification

## 1. Replacement Text for SKILL.md Phase 8 Step 4 (Sub-step 8b)

Replace the current lines 682-683:

```
4. **Sub-step 8b** (sequential, after 8a): if checklist includes README or
   user-facing docs, spawn product-marketing-minion to review. Otherwise skip.
```

With:

```
4. **Sub-step 8b -- Marketing lens** (sequential, after 8a): if checklist
   includes README or user-facing docs, spawn product-marketing-minion with
   the following inputs and instructions. Otherwise skip.

   **Inputs to product-marketing-minion**:
   - The Phase 8 checklist (`nefario/scratch/{slug}/phase8-checklist.md`)
   - The execution summary (what changed and why)
   - Current `README.md`

   **Instructions**: Classify each user-visible change into one of three tiers
   using the decision criteria below. Return a tier classification for each
   change and the corresponding recommendation.

   **Tier definitions**:

   | Tier | Name | Criteria | Action |
   |------|------|----------|--------|
   | 1 | Headline Feature | New capability (user can do something new) AND strengthens a core differentiator (orchestration, governance, specialist depth, install-once) OR changes the user's mental model | Recommend specific README changes with proposed copy. Flag if core positioning needs update. |
   | 2 | Notable Enhancement | Improves existing capability in a user-visible way, OR removes a friction point in getting-started or daily-use, OR is a breaking change | Recommend where to mention in existing docs. Include in release notes. For breaking changes: flag migration guide need. |
   | 3 | Document Only | Internal improvement, bug fix, refactor, or maintenance. User experience unchanged. | Confirm documentation coverage is sufficient. No README or positioning changes. |

   **Decision criteria** (evaluate in order, stop at first match):
   1. Does this change what the project can do? (new capability = Tier 1 candidate)
   2. Would a user notice during normal usage? (yes = Tier 2 minimum; no = Tier 3)
   3. Does it strengthen a core differentiator? (if yes, promote one tier)
   4. Does it change the user's mental model? (if yes = Tier 1)
   5. Is it a breaking change? (always Tier 2 minimum)

   **Output format**: For each change, return:
   - Change description (one line)
   - Tier classification (1, 2, or 3) with rationale (one sentence)
   - Recommendation per the action column above

   Write output to: `nefario/scratch/{slug}/phase8-marketing-review.md`

   **Example triage** (reference test case):
   - Change: "Added accessibility-minion as conditional Phase 3.5 reviewer"
   - Tier: 2 (Notable Enhancement). Improves governance coverage for web UI
     tasks -- user-visible when working on web projects -- but does not
     introduce a new capability or change the mental model.
   - Recommendation: Mention in docs/orchestration.md reviewer table. Include
     in release notes. No README change needed.
```

---

## 2. Rationale for Tier Definitions

### Tier 1: Headline Feature

**Why this definition**: The positioning strategy identifies four core differentiators:
orchestration, governance, specialist depth, and install-once model. A change deserves
prominent README placement only when it both introduces genuinely new capability AND
reinforces one of these differentiators. The "mental model" criterion (from ux-strategy-minion)
catches changes that require the user to think about the system differently -- these
always need documentation updates regardless of whether they are "features" in the
traditional sense.

The AND/OR structure prevents inflation: a minor feature that happens to touch
orchestration is not automatically Tier 1. It must introduce something the user could
not do before. This addresses margo's concern about false positives on minor changes
(Phase 3.5 review item 3).

### Tier 2: Notable Enhancement

**Why this definition**: This tier captures the middle ground -- changes a user would
notice but that do not shift the project's positioning. The three criteria cover distinct
scenarios: user-visible improvements (better error messages, faster phases), friction
removal (simpler install, better onboarding), and breaking changes (always need
documentation regardless of impact magnitude).

Breaking changes are always Tier 2 minimum (never Tier 3) because they require explicit
migration guidance. Even a "minor" breaking change demands that documentation acknowledges
what changed and what the user needs to do.

### Tier 3: Document Only

**Why this definition**: This is the fast path. Internal improvements should not trigger
README or positioning review. The product-marketing-minion confirms documentation coverage
is sufficient (changelog, technical docs) and moves on. This keeps the marketing lens
lightweight for the majority of changes, which are internal.

The ux-strategy-minion's "silent" bucket (Phase 2, criterion 5) and the product-marketing-minion's
"Document-only" tier are equivalent here. Both agree: if the user's experience is
unchanged, no promotional treatment is warranted.

### Decision Criteria Ordering

The five criteria are ordered by discriminating power. "Does this change what the project
can do?" is the strongest signal and is evaluated first. "Is it a breaking change?" is
evaluated last as a safety net -- it ensures breaking changes never fall to Tier 3
regardless of how the earlier criteria classify them.

The "promote one tier" rule for differentiator strength (criterion 3) handles edge cases
where a change is technically Tier 2 (user-visible improvement) but disproportionately
strengthens a differentiator, making it worth headline treatment.

### Example Triage Rationale

The example (adding accessibility-minion as conditional reviewer) was chosen because it
is a realistic recent change that tests the boundary between Tier 1 and Tier 2. It is
user-visible (affects governance behavior on web UI tasks) and strengthens a differentiator
(governance), but does not introduce a new capability -- the user could already get
governance review. This makes it Tier 2, not Tier 1. The example demonstrates that
criterion 3 ("promote one tier") is a consideration, not an automatic promotion.

This addresses test-minion's Phase 3.5 advisory (item 6): include an example triage
scenario as a reference test case.
