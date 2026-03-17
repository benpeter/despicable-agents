# Margo Review: Routing Configuration Schema (#139)

## Verdict: ADVISE

The plan is well-scoped to Issue #139 with no scope creep outside the roadmap. Three tasks (loader, tests, docs) are proportional to the problem. The conflict resolutions are reasonable and justified. The "What NOT to Do" sections actively prevent gold-plating. Two items warrant attention before execution.

---

### Findings

- [simplicity]: Hardcoded group-to-agent mapping creates a second source of truth for the agent roster.
  SCOPE: `lib/load-routing-config.sh` (Task 1, validation step 5e/5f)
  CHANGE: For agent name validation (5f), discover agent names dynamically from AGENT.md files in `--agent-dir` rather than hardcoding all 27 names. The group mapping (5e) is a routing concept that legitimately lives in the loader, but the full agent roster is already expressed by the filesystem. One hardcoded list (groups) is justifiable; two (groups + full roster) doubles the staleness surface.
  WHY: The plan's own Risk #3 acknowledges group membership drift. Agent roster drift is the same problem but larger (27 names vs. 9 groups). The `--agent-dir` flag already exists for capability gating (step 5h), so the loader already walks AGENT.md files. Reusing that directory listing for name validation removes one maintenance burden at zero added complexity.
  TASK: Task 1

- [simplicity]: Merge semantics for `groups` and `agents` differ from `model-mapping` without clear justification visible to the user.
  SCOPE: `lib/load-routing-config.sh` (Task 1, merge step 4)
  CHANGE: Document this asymmetry prominently in the example config (Task 1 deliverable `.nefario/routing.example.yml`) and in the spec doc (Task 3). The merge rule is: `groups` and `agents` merge keys (user adds to project), but `model-mapping` replaces entire harness blocks (user replaces project). This is a reasonable design choice but a cognitive trap if not surfaced clearly.
  WHY: Users will assume consistent merge behavior across sections. When their model-mapping override silently drops project-level tiers they did not re-specify, debugging will be confusing. A YAML comment in the example config costs nothing and prevents a predictable support question.
  TASK: Task 1, Task 3
