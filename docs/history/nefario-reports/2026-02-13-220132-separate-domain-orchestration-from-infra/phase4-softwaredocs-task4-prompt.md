You are writing the documentation that explains how to create a domain adapter for despicable-agents. The audience is someone forking the project for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) who has no deep knowledge of the framework internals.

## What to do

Create `docs/domain-adaptation.md` with the following structure:

### 1. Overview (2-3 paragraphs)
What despicable-agents is, what domain adaptation means, what the adapter controls vs. what the framework handles. Use the "you define WHAT agents you have and HOW they coordinate; the framework handles the mechanics of spawning, messaging, reporting" framing.

### 2. What the Framework Provides (explicit list)
List every infrastructure capability the adapter author gets for free:
- Subagent spawning and lifecycle management
- Scratch directory and file management
- Status line and session tracking
- Compaction checkpoints
- Gate interaction mechanics (presentation, response handling, anti-fatigue)
- Communication protocol (SHOW/NEVER SHOW/CONDENSE)
- External skill discovery and classification
- Report generation
- Branch/PR creation mechanics (when applicable)
- Content boundary markers

### 3. What the Adapter Must Provide (the contract)
For each of the five data structures, explain:
- What it is and why the framework needs it
- The format (reference the DOMAIN.md sections)
- A side-by-side showing the software-dev value and what a hypothetical regulatory compliance adapter might provide (brief, illustrative)

The five data structures:
1. Agent roster and delegation table
2. Phase sequence
3. Cross-cutting checklist
4. Gate classification heuristics
5. Reviewer configuration (mandatory + discretionary)

### 4. How to Create a New Adapter (step-by-step walkthrough)
1. Fork the repository
2. Copy `domains/software-dev/` to `domains/your-domain/`
3. Edit DOMAIN.md -- replace each section
4. Build your agents (create AGENT.md files for your specialist agents)
5. Run `./assemble.sh your-domain` to produce the assembled AGENT.md
6. Run `./install.sh --domain your-domain` to deploy
7. Test with `/nefario --advisory <representative task>` to verify

### 5. What You Do NOT Need to Change
Explicitly list what should NOT be modified: SKILL.md infrastructure sections, the communication protocol, scratch management, report generation template structure. Explain WHY.

**IMPORTANT**: Address the SKILL.md vs AGENT.md asymmetry clearly. AGENT.md is fully assembled from the adapter (adapter authors never edit it directly). SKILL.md has section markers for in-place replacement (adapter authors edit marked sections within SKILL.md). Include a decision tree or table explaining which file to edit for what purpose.

### 6. Governance Constraints
Explain that lucy and margo are always present, what review focus hints are, and how to extend (but not replace) mandatory governance.

### 7. Troubleshooting
Add a troubleshooting section with symptom/cause/solution format for:
- Assembly failures (marker mismatches, missing sections)
- YAML frontmatter errors
- Phase conditions not triggering
- Agent name mismatches between DOMAIN.md and installed agents
- Gate heuristics not matching domain artifacts

### 8. Update README.md
Add a link to docs/domain-adaptation.md in the project README.md, in the docs section or as a new entry pointing adapter authors to the guide.

### 9. Update CLAUDE.md Deployment section
Update the CLAUDE.md deployment section to mention the `--domain` flag for install.sh and the assembly step.

## What to produce

- `docs/domain-adaptation.md`
- Updated `README.md` (add link to domain adaptation guide)
- Updated `CLAUDE.md` (deployment section update)

## What NOT to do

- Do not create a full non-software adapter (out of scope)
- Do not duplicate the DOMAIN.md format spec (reference it)
- Do not explain framework internals beyond what the adapter author needs

## Key files to read

- `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md` (the reference adapter)
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/adapter-format.md` (format specification)
- `/Users/ben/github/benpeter/2despicable/3/docs/architecture.md` (existing architecture docs, for style consistency)
- `/Users/ben/github/benpeter/2despicable/3/README.md`
- `/Users/ben/github/benpeter/2despicable/3/CLAUDE.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
