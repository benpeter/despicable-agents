**Outcome**: After creating a pull request, the workflow remains on the feature branch so developers can continue local testing and iteration without manually switching back. Currently, reverting to main after PR creation breaks the local testing flow and forces unnecessary branch switches.

**Success criteria**:
- After PR creation, the working directory stays on the feature branch
- Developer can immediately run local tests after PR creation without switching branches
- PR creation still works correctly (remote push, PR opened)
- No regressions to the PR creation workflow

**Scope**:
- In: Post-PR-creation branch behavior (the checkout/switch logic after `gh pr create` or equivalent)
- Out: PR template, PR review workflow, CI/CD pipeline, merge behavior
