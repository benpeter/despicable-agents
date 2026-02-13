VERDICT: ADVISE
FINDINGS:

- [ADVISE] skills/nefario/SKILL.md:1128-1133 -- Good/bad ADVISE examples in the generic reviewer prompt use [security] as the domain tag, which is appropriate for the security-minion but misleading for other reviewers (test-minion, ux-strategy-minion, lucy, margo) who receive the same template. The prompt says "[your-domain]" in the format spec but the concrete examples always show [security].
  AGENT: software-docs-minion (Task 2)
  FIX: Add a second good example using a non-security domain (e.g., [testing] or [usability]) to demonstrate that the domain tag varies by reviewer. Alternatively, add a parenthetical note: "Replace [security] with your domain -- e.g., [testing], [usability], [governance]."

- [ADVISE] skills/nefario/SKILL.md:1142-1146 -- The BLOCK example is embedded inside the ADVISE instructions section without a clear boundary. A reviewer could interpret the "Example (good -- BLOCK, self-contained)" block as showing a BLOCK variant of ADVISE rather than as an illustration of the separate BLOCK format. This is present identically in both the generic reviewer prompt (line 1142) and the ux-strategy-minion prompt (line 1217).
  AGENT: software-docs-minion (Task 2)
  FIX: Move the BLOCK example out of the ADVISE section and place it after the BLOCK format definition, or add a separator comment such as "The BLOCK format (shown separately below) also requires self-contained fields:" before the example.

- [ADVISE] skills/nefario/SKILL.md:1401 -- The gate ADVISORIES format uses `<artifact or concept> (Task N)` as the first line of each advisory. The SCOPE field from the canonical ADVISE format in nefario/AGENT.md:669 is effectively inlined into this position but is not labeled as SCOPE. This is intentional (the gate format is a compressed user-facing rendition), but the implicit mapping between the canonical SCOPE field and the gate's artifact-or-concept position is undocumented.
  AGENT: software-docs-minion (Task 2)
  FIX: NIT-level. No action strictly required. For clarity, consider adding a one-line comment in the ADVISORIES format documentation: "The artifact-or-concept position corresponds to the SCOPE field from the reviewer's advisory output."

- [NIT] nefario/AGENT.md:672 -- The TASK field description says "(routing metadata for orchestrator -- not shown in user-facing output)" but the gate ADVISORIES format in skills/nefario/SKILL.md:1401 does show "(Task N)" to the user. The TASK information IS shown in user-facing output -- just in a different form (parenthetical task reference rather than the structured TASK field).
  AGENT: software-docs-minion (Task 1)
  FIX: Clarify the AGENT.md description to: "(routing metadata -- shown as parenthetical task reference in user-facing gate output, not as the raw TASK field)".

- [NIT] skills/nefario/SKILL.md:1787-1789 -- The Phase 5 code review prompt uses a different finding format (file:line-range + AGENT + FIX fields) than the Phase 3.5 review format (SCOPE + CHANGE + WHY + TASK fields). This is correct by design -- Phase 5 reviews code, not plans -- but worth noting that the self-containment instruction added at line 1791-1793 nicely bridges the two formats.
  AGENT: software-docs-minion (Task 2)
  FIX: No fix needed. Observation only: the two formats are appropriately different for their contexts (code review vs. plan review).

- [NIT] nefario/AGENT.md:706 -- The BLOCK format now includes SCOPE but the format block shows "VERDICT: BLOCK" on line 706, then "SCOPE:" on line 707. The canonical ADVISE format shows "VERDICT: ADVISE" then "WARNINGS:" as a container, then individual items with SCOPE. For BLOCK, there is no container keyword -- SCOPE is a direct sibling of VERDICT. This asymmetry is fine structurally but means a multi-issue BLOCK would need multiple VERDICT:BLOCK/SCOPE/ISSUE/RISK/SUGGESTION blocks rather than one VERDICT with multiple items.
  AGENT: software-docs-minion (Task 1)
  FIX: No fix needed for current usage. BLOCK verdicts typically have a single blocking concern. If multi-issue BLOCK becomes necessary, the resolution loop already collects all BLOCK verdicts across reviewers (nefario/AGENT.md:698-700), so the one-issue-per-BLOCK pattern is correct.
