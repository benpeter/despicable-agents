## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### (a) Link placement: footer section, not inline

**Recommendation: All scratch file links go in a single footer line per gate, positioned as the last content line before the closing card border.**

Rationale grounded in cognitive load theory and the Visual Hierarchy:

1. **Gates are decision points, not research environments.** The Visual Hierarchy table defines Decision weight as the heaviest attention signal. Users at a gate need to: (1) understand what they are approving, (2) spot anomalies, (3) act. Links to source files serve a secondary need -- "I want to dig deeper before deciding" -- which applies to a minority of gate encounters. Per progressive disclosure, secondary information should be available but not competing for attention with the primary decision content.

2. **Inline links fragment scanning.** If advisory links appear inline with each advisory entry (e.g., a `[prompt](path) | [verdict](path)` pair on every advisory line), the user's eye must parse both the advisory content AND the link affordance on every line. This doubles the visual density of the ADVISORIES block, which currently targets 2-3 lines per entry. Inline links turn a decision summary into a reference document.

3. **A footer section creates a clean "decision above, sources below" separation.** The user reads the gate content top-to-bottom, makes their decision at the AskUserQuestion prompt, and only scrolls back to the footer if they need to investigate. This matches the existing pattern: the Team gate already has `Details: $SCRATCH_DIR/...` as its last line, and the Execution Plan gate has `Details: $SCRATCH_DIR/...` as its last line. The proposal simply consolidates and standardizes this pattern.

**One exception for advisories:** For advisories complex enough to already include a `Details:` line (per the existing rule at SKILL.md line 1083-1090), keep the advisory-level `Details:` + `Prompt:` links inline with that specific advisory. These are already progressive disclosure -- they only appear on complex advisories. But do NOT add inline links to simple two-line advisories (CHANGE + WHY). This preserves the existing graduated disclosure: simple advisories are self-contained, complex advisories link out.

#### (b) Display text convention: file-role labels, not filenames

**Recommendation: Use role-based display text like `[plan]`, `[meta-plan]`, `[prompt]`, `[verdict]` rather than filenames or slug paths.**

Rationale:

1. **Filenames are implementation details.** `phase1-metaplan.md` means something to a developer who knows the phase numbering; `[meta-plan]` communicates intent to anyone. Users at a gate are thinking in terms of "What produced this decision?" not "What is the filesystem path?" Display text should match the user's mental model (Nielsen heuristic 2: match between system and real world).

2. **Single-word labels minimize visual noise.** Each link occupies minimal horizontal space. A footer line reading `Details: [meta-plan](full-path)` scans faster than `Details: phase1-metaplan.md` or `Details: [approval-gate-polish/phase1-metaplan.md](full-path)`.

3. **Slug-only display text for directory references.** When referencing the working directory itself (as in the Execution Plan gate's `Working dir:` line), use the slug as display text with the full path as the link target: `[approval-gate-polish/](full-path)`. The slug IS meaningful here -- it identifies the session. But for individual files, role labels are better than filenames.

4. **Visual distinction via backtick wrapping.** Links should be backtick-wrapped to distinguish them from surrounding prose: `` `[meta-plan](path)` ``. This creates a consistent "links look like code" affordance across all gates, matching the backtick card framing pattern where field labels are already backtick-wrapped. The backtick wrapping signals "this is actionable/interactive" vs plain text which is "read only."

**Proposed display text vocabulary** (exhaustive for all gates):

| Role label | Maps to scratch file | Used in gate(s) |
|------------|---------------------|------------------|
| `meta-plan` | `phase1-metaplan.md` | Team |
| `contributions` | `phase2-*.md` (directory) | Reviewer, Exec Plan |
| `plan` | `phase3-synthesis.md` | Reviewer, Exec Plan, Mid-execution |
| `prompt` | `phase3.5-{reviewer}-prompt.md` | Advisories (complex only) |
| `verdict` | `phase3.5-{reviewer}.md` | Advisories (complex only) |
| `task-prompt` | `phase4-{agent}-prompt.md` | Mid-execution |
| `diff` | git diff or deliverable | PR |

#### (c) Minimum viable link set per gate

The principle: **each gate gets exactly one "Details" footer link to the single most relevant scratch file, plus the working directory reference if it is already present.** Additional links are added only when the gate's content type demands them.

**Team Approval Gate** (simplest, 8-12 lines):
- Footer: `Details: [meta-plan](full-path-to-phase1-metaplan.md)`
- Rationale: The meta-plan contains the planning questions, cross-cutting checklist, and exclusion rationale. This is the ONLY artifact that exists at this point. One link, one file.
- This replaces the existing `Details: $SCRATCH_DIR/{slug}/phase1-metaplan.md` line with a shorter display but full path in link.

**Reviewer Approval Gate** (6-10 lines):
- Footer: `Details: [plan](full-path-to-phase3-synthesis.md)`
- Rationale: At this gate, the user is approving who will review the plan. The plan itself is the relevant context. Specialist contributions (phase2 files) are inputs to the plan, not the plan itself -- linking them would be a second layer of indirection that doesn't help the "who should review" decision.
- This replaces the existing `Details: $SCRATCH_DIR/{slug}/phase3-synthesis.md` line.

**Execution Plan Approval Gate** (25-40 lines):
- Working dir line: `Working dir: [<slug>/](full-path-to-scratch-dir-slug/)`
- Footer: `Details: [plan](full-path-to-phase3-synthesis.md)`
- Complex advisories (existing rule, lines 1083-1090): Keep inline `Details:` and `Prompt:` links with role-label display text: `Details: [verdict](full-path)` and `Prompt: [prompt](full-path)`
- Rationale: This is the richest gate and the one where advisory links matter most. But even here, the footer stays minimal. The advisory-level links only appear on complex advisories per the existing progressive disclosure rule.

**Mid-execution Approval Gate** (12-18 lines, already has card framing):
- Footer (new): `Details: [task-prompt](full-path-to-phase4-agent-prompt.md)`
- Rationale: The user is approving a deliverable. The task prompt provides "what was asked" context. The deliverable files are already listed in the DELIVERABLE section -- no need to link them again.

**PR Gate** (5-8 lines, simplest decision):
- No scratch file links.
- Rationale: The PR gate shows git diff stats. The relevant artifacts are the branch and the diff, not scratch files. The scratch directory is being cleaned up at this point. Adding scratch links to a gate whose purpose is "push or don't push" creates false affordance -- the links may be dead by the time the user clicks them if cleanup runs.
- The `git diff --stat` output IS the reference material for this gate.

**Summary: Link count per gate**

| Gate | Links in footer | Inline advisory links | Total links |
|------|-----------------|----------------------|-------------|
| Team | 1 | 0 | 1 |
| Reviewer | 1 | 0 | 1 |
| Execution Plan | 1 (footer) | 0-2 per complex advisory | 1-3 typical |
| Mid-execution | 1 | 0 | 1 |
| PR | 0 | 0 | 0 |

This is minimal. No gate exceeds 3 links in normal operation. The cognitive cost is near-zero for the footer link (peripheral, not in the decision path) and proportional to advisory complexity for inline links (which are already gated by the "complex advisory" threshold).

#### Path Display Rule Reconciliation

The existing path display rule (SKILL.md line 224-227) says "never abbreviate." The slug-only display text approach does NOT violate this rule when implemented as markdown links: the full absolute path is preserved as the link target. The display text is a label, not an abbreviation -- it tells the user what the file IS, while the link target preserves the full path for copy-paste. The path display rule should be amended to explicitly permit markdown links where the display text describes the file's role and the href contains the full resolved path.

### Proposed Tasks

1. **Amend the path display rule** (line 224-227) to allow markdown links with role-label display text and full-path href. Add one sentence: "Markdown links with role-label display text (e.g., `[meta-plan](full-path)`) are permitted; the full resolved path must be the link target."

2. **Apply backtick card framing to Team Approval Gate template** (lines 441-453). Add `────` borders, backtick-wrap field labels (`TEAM:`, `SELECTED:`, `ALSO AVAILABLE:`, `Details:`). Replace the existing `Details:` plain path with a `[meta-plan](path)` link.

3. **Apply backtick card framing to Reviewer Approval Gate template** (lines 782-793). Add borders, backtick-wrap labels. Replace `Details:` path with `[plan](path)` link.

4. **Apply backtick card framing to Execution Plan Approval Gate template** (lines 1038-1113). Add borders, backtick-wrap labels. Replace `Working dir:` path with slug-only link. Replace footer `Details:` with `[plan](path)` link. Update advisory `Details:` and `Prompt:` lines (1085-1086) to use `[verdict](path)` and `[prompt](path)` display text.

5. **Add footer link to Mid-execution Approval Gate** (lines 1249-1269, already framed). Add `Details: [task-prompt](path)` as the last content line before the closing border.

6. **PR Gate: apply card framing, no links** (lines 1676-1683). Add borders and backtick-wrap labels only. No scratch file links for the reasons stated above.

7. **Update the Visual Hierarchy table** (lines 207-212) if the Decision pattern description needs updating to reflect the link convention.

### Risks and Concerns

1. **Over-linking risk (PRIMARY).** The biggest UX risk in this task is adding links that nobody clicks but everybody sees. Every link in a gate is a visual element that competes for attention with the decision content. The minimum-viable-link-set above mitigates this, but during execution, there may be pressure to "add more links while we're at it." Resist this. Each additional link has a marginal cost (visual noise) that exceeds its marginal benefit (rare deep-dive) past the first one or two per gate.

2. **Path display rule contradiction.** If the path display rule (line 224-227) is not updated in the same change, the new link convention will contradict the existing "never abbreviate" instruction. This creates ambiguity for the calling session: which rule wins? The amendment must be done in the same commit as the gate changes.

3. **Dead link at PR gate.** If scratch file links were added to the PR gate, they could point to deleted files (the scratch directory is cleaned up at step 11, which follows step 10 PR creation). However, cleanup happens AFTER PR creation, so links would be alive at decision time. The risk is that users bookmark or revisit the PR gate output after cleanup, finding dead links. Since the PR gate output appears in terminal history (not a persisted document), this risk is low. Nonetheless, I recommend no links at the PR gate for this reason and because the decision ("push or don't push") doesn't benefit from scratch file context.

4. **Markdown link rendering in terminal.** Claude Code's terminal output may or may not render markdown links as clickable hyperlinks depending on the terminal emulator. In terminals that don't render links, the user will see `[label](long-path)` as raw text, which is WORSE than the current plain path display (longer, harder to copy-paste). This is a critical consideration. If the links are inside backtick code spans or code blocks, they definitely will NOT render as hyperlinks -- they'll be literal text. The implementation must account for this: links should be placed where they render as markdown, not inside code blocks that display literally. This is primarily a devx-minion concern (template authoring), but the UX impact is significant.

5. **Backtick wrapping and link interaction.** Wrapping a markdown link in backticks (`` `[label](path)` ``) may prevent the link from rendering as a link in some contexts. If the card framing uses a code block (triple backtick), then NOTHING inside it will render as a link. The card framing pattern needs to use inline backticks for field labels (as the mid-execution gate already does) while keeping link text OUTSIDE backtick spans. The exact rendering behavior depends on Claude Code's output handling -- devx-minion should verify this.

### Additional Agents Needed

None. The current team of ux-strategy-minion (cognitive load, link placement) and devx-minion (template authoring, rendering behavior) covers the problem space. The rendering concern in Risk 4-5 falls squarely in devx-minion's domain. Mandatory Phase 3.5 reviewers (security, test, ux-strategy, lucy, margo) will catch any governance or consistency issues in the synthesized plan.
