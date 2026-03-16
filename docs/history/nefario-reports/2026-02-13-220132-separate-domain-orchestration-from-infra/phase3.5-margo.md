# Margo Review: Domain Separation Plan

## Verdict: ADVISE

The plan is well-considered and already incorporates my earlier feedback (single file per adapter, no runtime config loader, no validation tooling, no multi-file directory tree). The conflict resolution section correctly adopted the simpler alternatives on four out of five disputed points. The overall complexity budget is proportional to the problem. Two concerns remain, one substantive and one minor.

---

### Finding 1: `disassemble.sh` is YAGNI (MEDIUM)

**What**: Task 3 creates `disassemble.sh` -- a reverse operation that restores template markers from an assembled `nefario/AGENT.md`.

**Why it is accidental complexity**: The stated use case is "when someone edits the assembled AGENT.md and needs to propagate changes back." This is a hypothetical workflow. The disciplined workflow is: edit the template or the DOMAIN.md, then re-assemble. If someone edits the assembled file directly, they are working against the grain of the separation, and a script that encourages that pattern undermines the architectural goal.

No one has this problem today. No one will have it until there are multiple adapters in active use (zero exist). The disassemble operation is also inherently fragile -- inferring marker boundaries from assembled prose is harder than inserting content at markers. This is the kind of tool that looks helpful on paper but creates a false sense of safety.

**Simpler alternative**: Drop `disassemble.sh` from this iteration. Add a one-line note in `assemble.sh` comments: "To modify domain content, edit `domains/<name>/DOMAIN.md` and re-run this script. Do not edit the assembled AGENT.md directly." If disassembly proves needed later, it can be built then.

**Complexity saved**: one fewer script to build, test, and maintain. One fewer concept for adapter authors to learn.

### Finding 2: Task 2 scope is very large for a single delegation (LOW)

**What**: Task 2 asks a single agent to: (a) design the DOMAIN.md format specification, (b) extract all software-dev content into `domains/software-dev/DOMAIN.md`, (c) refactor `nefario/AGENT.md` with assembly markers, and (d) annotate `skills/nefario/SKILL.md` with section markers. That is four significant deliverables touching three files plus creating a new one, gated by an approval checkpoint.

**Why this is a concern**: This is not over-engineering -- the work needs to happen. But concentrating it in one task creates a large blast radius. If the agent gets the format wrong or produces a poor extraction, the approval gate catches it but the rework cost is high. The plan already mitigates this with the approval gate, which is the right call.

**Not blocking**: The gate placement after Task 2 is correct and sufficient. This is an observation, not a recommendation to split. Splitting Task 2 further would add coordination overhead that exceeds the risk reduction.

### What the plan gets right (not flagged)

- Single DOMAIN.md file per adapter instead of six files: correct, avoids navigational overhead.
- Install-time assembly instead of runtime loading: correct, no latency cost, no new runtime dependency.
- No config loader, registry, or plugin lifecycle: correct, these serve zero current users.
- Validation tooling deferred: correct, assembly + manual verification is sufficient for adapter count = 1.
- Section markers (not extraction) for SKILL.md: correct, the 2328-line SKILL.md has tightly interwoven domain/infrastructure content that would not extract cleanly.
- Bash-only assembly script: correct, no new language dependency.
- Approval gate after Task 2: correct, the adapter format is the hardest-to-reverse decision.

### Recommendation

Remove `disassemble.sh` from Task 3 scope. Everything else proceeds as planned.
