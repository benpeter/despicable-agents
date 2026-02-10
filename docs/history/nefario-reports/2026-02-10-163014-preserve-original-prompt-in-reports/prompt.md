Preserve original prompt in PR descriptions and nefario reports

**Outcome**: The full original user prompt (the `/nefario` briefing) is captured in both the git PR description and the nefario execution report, and is also saved as a standalone file in the report directory. This ensures traceability from intent to implementation — reviewers can see exactly what was asked for without digging through conversation history.

**Success criteria**:
- PR description template includes a dedicated section for the original prompt
- Nefario execution report template includes a dedicated section for the original prompt
- Original prompt is written as a separate file (e.g., `prompt.md`) alongside the report in `docs/history/nefario-reports/`
- Existing reports are not retroactively modified

**Scope**:
- In: PR creation flow in nefario skill, report template (`TEMPLATE.md`), nefario orchestration instructions
- Out: Despicable-prompter skill itself, agent AGENT.md files, install.sh, the-plan.md
