**Outcome**: When nefario presents the user with a gate, approval request, or question, the user has enough context to make an informed decision without needing to dig through scratch files or reconstruct what happened. This eliminates the current friction where users approve or reject blindly because the relevant information isn't surfaced alongside the decision point.

**Success criteria**:
- Every gate and approval prompt includes references to the artifacts it pertains to (paths to relevant files, scratch directory)
- User can understand what they are approving/rejecting without opening additional files
- Existing gate logic (APPROVE/ADVISE/BLOCK) is preserved
- No change to the number or purpose of gates — only the information presented at each one

**Scope**:
- In: Gate output formatting, approval prompt content, question presentation in nefario orchestration
- Out: Gate logic changes, adding/removing gates, changes to the phase structure, changes to specialist agent behavior
