# Meta-Plan: Stay on Feature Branch After PR Creation

## Task Analysis

After PR creation in nefario orchestration, the workflow currently checks out the default branch (`main`) and pulls latest. This breaks the developer's local testing flow -- they must switch back to the feature branch to continue iterating. The fix: remove the "return to default branch" behavior so the working directory stays on the feature branch after PR creation.

### Files Affected

The "return to default branch" behavior is specified in three places:

1. **`skills/nefario/SKILL.md`** (lines 1129-1138) -- Step 11 in wrap-up: `git checkout --quiet <default-branch> && git pull --quiet --rebase`. This is the executable instruction that agents follow.
2. **`docs/commit-workflow.md`** (line 52) -- Documents "Return to main: `git checkout main && git pull --rebase`" as post-PR behavior. Also in Section 3 (Trigger Points, line 153) and Section 10 Summary table (line 418).
3. **`docs/orchestration.md`** (line 98, 279, 547) -- References the wrap-up returning to main. Step 9 in wrap-up sequence (line 1279) also documents the checkout.

Additionally, the mermaid diagram in `docs/commit-workflow.md` (lines 59-97) shows the `git checkout main` step.

### Scope

- **In**: Post-PR-creation branch behavior (the checkout/switch logic after `gh pr create`), documentation updates reflecting the new behavior, any "return to default branch" references.
- **Out**: PR template, PR review workflow, CI/CD pipeline, merge behavior, branch creation logic, the stop hook's PR suggestion (it doesn't do the checkout itself).

### Nature of the Change

This is a small, well-bounded behavioral change to the orchestration skill and its documentation. No new features, no architectural decisions, no API changes. The change removes behavior (the checkout) rather than adding it.

---

## Planning Consultations

### Consultation 1: Developer Experience Impact

- **Agent**: devx-minion
- **Planning question**: The nefario skill currently returns to the default branch after PR creation (step 11 in wrap-up). We want to stay on the feature branch instead. From a developer experience perspective: (1) Are there any workflows or downstream tools that depend on being back on main after PR creation? (2) Should the final summary message change to reflect that the user is still on the feature branch? (3) Is there any value in making this configurable (stay vs. return) or should we simply remove the checkout?
- **Context to provide**: `skills/nefario/SKILL.md` (wrap-up steps 10-11, lines 1098-1138), `docs/commit-workflow.md` (PR Creation at Wrap-Up section), `.claude/hooks/commit-point-check.sh`
- **Why this agent**: devx-minion specializes in CLI design and developer workflows. They can assess whether removing the branch switch has unintended consequences for the developer's working flow and whether the UX of the final summary needs adjustment.

### Consultation 2: Documentation Consistency

- **Agent**: software-docs-minion
- **Planning question**: The "return to default branch after PR" behavior is documented in three places: `skills/nefario/SKILL.md` (step 11), `docs/commit-workflow.md` (Sections 1, 3, 10, and the mermaid diagram), and `docs/orchestration.md` (Section 5). What is the complete set of references that need updating to ensure documentation consistency? Are there any other docs that reference this post-PR branch behavior?
- **Context to provide**: All three files listed above, plus `docs/using-nefario.md`
- **Why this agent**: software-docs-minion ensures documentation consistency across the project. With three separate files documenting the same behavior, they can identify all references and ensure nothing is missed.

---

## Cross-Cutting Checklist

- **Testing**: Include test-minion for planning? **No -- justification**: The change modifies SKILL.md instructions and documentation only. There are no executable code changes (the shell scripts are unmodified). The existing test suite (`tests/`) covers install portability, hardcoded paths, and commit hooks -- none of which test the "return to main" behavior since that's an agent instruction, not a script. Phase 6 will still run existing tests.
- **Security**: Include security-minion for planning? **No -- justification**: This change removes a `git checkout` + `git pull` operation. No new attack surface, no auth changes, no user input handling changes. The remaining PR creation flow (push, `gh pr create`) is unchanged.
- **Usability -- Strategy**: ALWAYS include -- **Included as devx-minion consultation above**. The planning question covers workflow coherence, cognitive load (does the user need to think about which branch they're on?), and whether the change aligns with developer expectations. ux-strategy-minion is not separately needed because this is a CLI/developer workflow, not a user-facing interface. devx-minion covers the relevant UX domain here.
- **Usability -- Design**: Include ux-design-minion / accessibility-minion for planning? **No -- justification**: No user-facing interfaces are produced or modified. This is a CLI workflow change affecting branch state.
- **Documentation**: ALWAYS include -- **Included as software-docs-minion consultation above**. The planning question specifically targets documentation consistency across all affected files.
- **Observability**: Include observability-minion / sitespeed-minion for planning? **No -- justification**: No runtime components, services, APIs, or web-facing elements are affected.

---

## Anticipated Approval Gates

**None anticipated.** This change is:
- Easy to reverse (adding back a `git checkout` line)
- Low blast radius (no downstream tasks depend on this decision)
- Clear best practice (staying on the branch you just pushed is standard git workflow)

Per the gate classification matrix: easy to reverse + low blast radius = NO GATE.

The execution plan approval gate (standard, always present) will be the only gate.

---

## Rationale

Only two specialists are needed for planning because this task is narrow and well-understood:

1. **devx-minion** covers the core question: is removing the checkout the right DX decision, or are there hidden workflow dependencies? They also cover the UX strategy dimension for CLI workflows.
2. **software-docs-minion** ensures we find every documentation reference to update. With three files documenting the same behavior, completeness matters.

No other specialists are needed because:
- No code is being written (only SKILL.md instructions and markdown docs change)
- No security surface changes
- No architecture decisions
- No user-facing interfaces
- No runtime components

---

## Scope

**In scope**:
- Remove "return to default branch" step from `skills/nefario/SKILL.md` wrap-up
- Remove orchestrated-session marker and status sentinel cleanup (these should still happen, just without the branch switch)
- Update `docs/commit-workflow.md` to reflect new post-PR behavior
- Update `docs/orchestration.md` to reflect new post-PR behavior
- Update mermaid diagrams that show the `git checkout main` step
- Update final summary messaging to reflect staying on feature branch

**Out of scope**:
- PR template or PR body content
- PR review workflow or CI/CD
- Branch creation logic (Phase 4 start)
- The stop hook's PR suggestion flow
- Making this behavior configurable (unless devx-minion identifies a strong reason)
- Merge behavior
