# user-docs-minion Review Verdict

## ADVISE

### Documentation Adequacy Assessment

Task 4 is scoped correctly and should produce adequate documentation for domain adapter authors. The structure covers essential elements (overview, contract, walkthrough, boundaries, governance). However, there are three gaps that would leave adapter authors stuck:

**1. Missing troubleshooting guidance**

The task structure includes "What You Do NOT Need to Change" but no troubleshooting section for common failures. Adapter authors will encounter predictable issues:
- Assembly markers in DOMAIN.md not matching AGENT.md markers (mismatched section identifiers)
- YAML frontmatter syntax errors breaking assembly
- Phase condition mapping to primitive vocabulary (Task 4 mentions this but provides no examples)
- Agent roster names not matching delegation table references

**Recommendation**: Add a "Troubleshooting" section to the Task 4 structure (between steps 6 and 7). Include symptoms, causes, and solutions for the four issues above. This aligns with troubleshooting-guide best practices (organize by symptom, provide decision trees).

**2. Adapter contract examples are too abstract**

Task 4 instructs: "A side-by-side showing the software-dev value and what a hypothetical regulatory compliance adapter might provide (brief, illustrative)." This is good, but the phrase "brief, illustrative" may result in toy examples that skip complexity. The five data structures have different levels of difficulty for adapter authors:
- Agent roster: straightforward (list your agents)
- Phase sequence: moderate (requires understanding phase types and conditions)
- Cross-cutting checklist: straightforward (list your dimensions)
- Gate classification heuristics: HIGH complexity (requires mapping domain-specific "hard to reverse" judgments to framework primitives)
- Reviewer configuration: moderate (requires understanding mandatory vs. discretionary)

**Recommendation**: In Task 4 prompt, replace "brief, illustrative" with "sufficiently detailed to show one complex case." Specifically, the gate classification heuristics side-by-side should show a non-trivial software-dev example (code architecture change requiring approval) and the regulatory equivalent (changing audit scope requiring approval) with the heuristic pattern clearly visible in both.

**3. Documentation discoverability is underspecified**

Task 4 produces `docs/domain-adaptation.md` but does not specify where this is referenced for discoverability. Adapter authors must find it. The task does not mention updating:
- Main project README to link to the adaptation guide
- `domains/software-dev/DOMAIN.md` header comment pointing to the guide
- `assemble.sh` usage output suggesting `--help` or pointing to docs

**Recommendation**: Add to Task 4 deliverables: "Update README.md to add a 'Domain Adaptation' section linking to docs/domain-adaptation.md." This is a 2-3 line change ensuring the guide is discoverable from the project entry point.

### What Works Well

- Task 4 correctly delegates to software-docs-minion (this is user-facing documentation, not developer internals)
- The six-part structure follows task-oriented documentation principles (what you get, what you provide, how to do it)
- The "What You Do NOT Need to Change" section prevents common mistakes (editing infrastructure when you should edit adapter)
- The step-by-step walkthrough (section 4) follows imperative mood and includes verification (step 7: test with `/nefario --advisory`)
- The format spec reference approach avoids duplication between Task 2 (format spec) and Task 4 (user guide)

### Scope Boundary Check

Task 4 is correctly scoped as a how-to guide for adapter authors, not:
- API reference documentation (that would be the adapter format spec from Task 2)
- Developer contribution guide (that would be devx-minion territory)
- Architectural rationale (that is in the plan itself)

The task appropriately uses software-docs-minion, not user-docs-minion, because the adapter author is a developer forking a codebase. This is developer-facing technical documentation, not end-user help text.

### Impact if Not Addressed

- **Missing troubleshooting**: Adapter authors will create GitHub issues or abandon the fork when assembly fails. Support burden increases. (Medium impact, high likelihood)
- **Abstract examples**: Adapter authors will misjudge the complexity of gate classification heuristics, producing adapters that misfire on approval gates. (High impact, medium likelihood)
- **Discoverability gap**: Adapter authors will not find the guide unless they happen to explore `docs/`. The guide exists but is not used. (Medium impact, low likelihood if README is well-structured)

### Recommended Changes to Task 4 Prompt

1. After "### 4. How to Create a New Adapter", add:
   ```
   ### 5. Troubleshooting Common Issues
   - Symptom: "Assembly failed: missing section @roster"
     Cause: Section identifier mismatch between AGENT.md markers and DOMAIN.md headings
     Solution: Verify all `<!-- @domain:X BEGIN -->` markers have matching `## @X` sections
   - Symptom: "YAML parse error on line N"
     Cause: YAML frontmatter syntax error (indentation, unquoted strings with colons)
     Solution: Validate YAML with yamllint or a parser before assembly
   - Symptom: "Phase X never triggers"
     Cause: Phase condition not mapped to framework primitives correctly
     Solution: Review condition vocabulary in format spec, test with --advisory mode
   - Symptom: "Agent Y not found during delegation"
     Cause: Agent roster name does not match delegation table reference
     Solution: Ensure exact string match between roster names and delegation table agent column
   ```

2. In section 3 instruction, replace:
   "A side-by-side showing the software-dev value and what a hypothetical regulatory compliance adapter might provide (brief, illustrative)"

   with:
   "A side-by-side showing the software-dev value and a hypothetical regulatory compliance equivalent, with sufficient detail to illustrate complexity. For gate classification heuristics, show a non-trivial example: a software-dev architectural change requiring approval (with the heuristic pattern: scope-expanding + cross-team impact) and the regulatory equivalent (audit scope change requiring approval, with the parallel heuristic: scope-expanding + regulatory risk)."

3. Add to deliverables list:
   "- Updated README.md with link to docs/domain-adaptation.md in a 'Domain Adaptation' section"

### Summary

Task 4 is fundamentally sound and well-scoped. The three gaps (troubleshooting, example depth, discoverability) are addressable with the additions above. Without them, the documentation will exist but will not fully enable independent adapter creation. With them, an adapter author unfamiliar with framework internals can succeed.
