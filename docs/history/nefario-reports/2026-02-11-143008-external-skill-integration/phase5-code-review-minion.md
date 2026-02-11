VERDICT: ADVISE

## Review Summary

The three main files (AGENT.md, SKILL.md, external-skills.md) describe a consistent discovery/classification/precedence/deferral model. Cross-references are accurate. Terminology is consistent across files. The content is well-structured and follows the project's established documentation patterns.

The changes are clean and focused. No contradictions were found between the three authoritative sources. The only findings are minor consistency and precision issues.

## FINDINGS

- [ADVISE] nefario/AGENT.md:212 -- LEAF classification signal `context: fork` is mentioned only in AGENT.md, not in external-skills.md or SKILL.md
  AGENT: ai-modeling-minion (inferred, prompt text author)
  FIX: Either add `context: fork` as a classification signal in external-skills.md section "Heuristic classification" (line 96 area), or remove it from AGENT.md line 212. The AGENT.md Classification section lists `context: fork` as a LEAF signal, but external-skills.md describes LEAF classification purely by negation ("single action with clear input/output") without mentioning this frontmatter field. Since the classification is described as heuristic and content-signal based, and `context: fork` is an actual Claude Code frontmatter field that could serve as a strong signal, the mention is reasonable -- but it should appear in all three places or none.

- [NIT] docs/external-skills.md:13 -- Minor phrasing: "at zero effort" reads awkwardly
  AGENT: software-docs-minion (inferred)
  FIX: Consider "with zero effort" or "without modification" for more natural phrasing. Low priority.

- [NIT] docs/external-skills.md:96 -- Known Limitations mentions "Heuristic classification" but does not mention the `context: fork` signal that AGENT.md uses
  AGENT: software-docs-minion (inferred)
  FIX: If `context: fork` is retained in AGENT.md, mention it here as one of the content signals to make the Known Limitations section complete. Related to the ADVISE finding above.

- [NIT] nefario/AGENT.md:458-459 -- Meta-plan output instruction says to replace External Skill Integration subsection with "No external skills detected in project." but uses slightly different wording than the SKILL.md Phase 1 prompt (line 347-348) which says "Include discovered skills in your meta-plan output" without specifying the no-skills fallback text
  AGENT: ai-modeling-minion (inferred)
  FIX: Not a conflict -- AGENT.md instructs nefario-the-agent on output format, SKILL.md instructs the calling session on what to tell nefario. The fallback text is only needed in the agent's own instructions. No change needed, noting for completeness.

- [NIT] docs/using-nefario.md:142 -- Mentions "CDD skills" as an example. This is a project-specific reference (CDD = Component-Driven Development?) that may not be meaningful to all readers
  AGENT: software-docs-minion (inferred)
  FIX: Either spell out what CDD stands for on first use, use a more generic example, or add a parenthetical. Low priority -- the example communicates intent clearly enough from context.

## Cross-Consistency Matrix

| Concept | AGENT.md | SKILL.md | external-skills.md | Consistent? |
|---------|----------|----------|---------------------|-------------|
| Scanned directories | .claude/skills/, .skills/ (L200) | .claude/skills/, .skills/ (L335) | .claude/skills/, .skills/ (L30-31) | Yes |
| User-global noted | ~/.claude/skills/ (L201) | Not in prompt template | ~/.claude/skills/ (L33) | Yes (SKILL.md prompt focuses on project-local; acceptable) |
| Classification: ORCHESTRATION signals | Multiple phases, step ordering, invokes other skills, conditional branching (L211) | Not detailed (refers to Core Knowledge) | Multi-phase workflows with internal sequencing (L17) | Yes |
| Classification: LEAF signals | Single action, clear I/O, no sequencing, context: fork (L213) | Not detailed | Single-action tools, clear I/O (L18) | Partial -- `context: fork` missing from external-skills.md |
| Precedence tier 1 | CLAUDE.md explicit (L220) | Referred to via "precedence rules" (L458) | CLAUDE.md explicit (L55) | Yes |
| Precedence tier 2 | Project-local > global (L221) | Not detailed | Project-local > global (L56) | Yes |
| Precedence tier 3 | Specificity > generality (L222) | Not detailed | Specificity > generality (L57) | Yes |
| Cross-cutting exception | Internal specialists win for cross-cutting (L222) | Not detailed | Explicit section (L59-61) | Yes |
| Ambiguity handling | Present at approval gate (L224) | Not detailed | Present at approval gate (L65) | Yes |
| Deferral: ORCHESTRATION | Single macro-task, DEFERRED type (L229-236) | DEFERRED macro-task (L477, L488) | Single macro-task, DEFERRED (L71-75) | Yes |
| Deferral: LEAF | Available Skills section (L237) | Available Skills section (L457, L497-499) | Available Skills section (L77) | Yes |
| Content boundaries | `<external-skill>` tags (L203) | `<external-skill>` tags (L99) | `<external-skill>` tags (L39, L85) | Yes |
| Path validation | realpath (L205) | Not in prompt template | realpath (L43) | Yes |
| Name collision handling | Prefix with source directory (L206) | Not in prompt template | Prefix with source directory (L47) | Yes |

## Assessment

The implementation is well-executed. The three-file separation of concerns is appropriate: AGENT.md provides the authoritative specification for nefario-the-agent, SKILL.md provides operational instructions for the calling session, and external-skills.md provides the contributor/skill-author reference. Each file serves a distinct audience and avoids unnecessary duplication while maintaining semantic consistency.

The only substantive finding is the `context: fork` signal appearing only in AGENT.md. This is a real classification signal that could be useful to document consistently, but its absence from external-skills.md does not create a behavioral inconsistency -- the classification is explicitly heuristic and the AGENT.md description is the one nefario actually reads at runtime.
