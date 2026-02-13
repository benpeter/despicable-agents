# Documentation Impact Checklist

Source: Phase 3.5 architecture review
Plan: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase3-synthesis.md

## Items

- [ ] **[software-docs]** Update `using-nefario.md` Example section titles and content
  Scope: Current README says "Examples" but synthesis task reorders content to "What You Get" + "Examples"; using-nefario.md cross-references may need alignment to match new README structure
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` (lines 1-10)
  Priority: SHOULD

- [ ] **[software-docs]** Verify anchor link stability in README navigation
  Scope: Current README has sections like "Try It" that will be removed/merged; check all cross-references from external docs to README anchors
  Files: `/Users/ben/github/benpeter/2despicable/2/README.md` (all section headers)
  Priority: MUST

- [ ] **[software-docs]** Update `architecture.md` if "vibe-coded" framing reference appears
  Scope: Verify that architecture.md doesn't reference the old "vibe-coded" limitations section (reframed as "AI-assisted prompt authoring" in new README)
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/architecture.md`
  Priority: SHOULD

- [ ] **[software-docs]** Cross-reference governance reviewer count in multiple docs
  Scope: Current README incorrectly says "six mandatory reviewers"; new README corrects to "five mandatory reviewers" (security, testing, docs, intent alignment, simplicity). Verify orchestration.md line 60 already states "five" correctly, update if any other docs claim "six"
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` (line 57-65)
  Priority: MUST

- [ ] **[software-docs]** Ensure using-nefario.md "When to Use" section aligns with new Examples structure
  Scope: New README merges Examples and Try It sections; verify using-nefario.md's decision tree ("When to Use Nefario") still accurately guides users after README rewrite
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` (lines 7-26)
  Priority: SHOULD

- [ ] **[software-docs]** Check external skills doc for "agent count" references
  Scope: External skills doc may reference agent/skill counts; ensure consistency with "27 agents + 2 skills" language (not "29 agents")
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/external-skills.md`
  Priority: SHOULD

- [ ] **[user-docs]** Add example output expectations to `using-nefario.md`
  Scope: New README's Examples section has 3-4 line explanations of what nefario does (plan → review → execute → verify). using-nefario.md may need supplementary output examples to show users what to expect
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` (add after "How to Invoke" section)
  Priority: COULD

- [ ] **[software-docs]** Validate no orphaned internal links after section reorganization
  Scope: New section order: value statement, What You Get, Examples, Install, How It Works, Agents, Documentation, Limitations, Contributing, License. Verify no links within docs/ reference removed README sections by name or order
  Files: `/Users/ben/github/benpeter/2despicable/2/docs/*.md` (all backlinks to README)
  Priority: SHOULD

## Summary

**Total items**: 8
**MUST priority**: 2 (anchor stability, five reviewers count verification)
**SHOULD priority**: 5 (cross-references, consistency checks)
**COULD priority**: 1 (example output supplementation)

### Key Risks Addressed

1. **"Six reviewers" → "five reviewers" fact correction** must propagate through orchestration.md and any other docs that cite the governance count
2. **Section reordering** (Try It merged into Examples, new "What You Get" section added) may create broken anchors if external docs link to old section names
3. **Terminology consistency** ("vibe-coded" badge framing change from limitation to personality signal) — ensure docs don't reinforce old framing
4. **Agent/skill count precision** ("27 agents + 2 skills" not "29 agents") — check external-skills.md for stale references

