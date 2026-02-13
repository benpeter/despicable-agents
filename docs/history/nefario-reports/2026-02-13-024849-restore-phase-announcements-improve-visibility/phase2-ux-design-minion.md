## Domain Plan Contribution: ux-design-minion

### Recommendations

#### 1. Establish a Consistent Visual Frame for All Nefario Orchestration Messages

Claude Code renders CommonMark in a monospace terminal. The available visual primitives are:

- **Horizontal rules** (`---`) -- full-width line, strong visual separator
- **Bold text** (`**...**`) -- heavier weight, moderate emphasis
- **Headers** (`#`, `##`, `###`) -- size increase, strong hierarchy signal
- **Code blocks** (triple backtick) -- indented/boxed region with distinct background in most terminals
- **Blockquotes** (`>`) -- indented with left border in most renderers
- **Lists** (bulleted/numbered) -- indentation and bullets
- **Inline code** (backtick) -- monospace with subtle background highlight
- **Blank lines** -- vertical whitespace for grouping

There is no color, no custom fonts, no HTML rendering, no box-drawing beyond what Unicode provides.

The core problem: nefario orchestration messages (phase transitions, approval gates, status updates, compaction checkpoints) currently use an ad-hoc mix of ALL-CAPS labels (`TEAM:`, `EXECUTION PLAN:`, `COMPACT:`, `APPROVAL GATE:`) but without a consistent framing pattern. They visually blend with tool output, agent responses, and system messages. There is no "nefario is speaking" signal.

**Recommended framing pattern -- the "banner" approach:**

Use horizontal rules as top/bottom borders to create a visually distinct block for every nefario orchestration message. Combined with a consistent ALL-CAPS label prefix, this creates a recognizable "frame" that the user learns to spot instantly.

```
---

**NEFARIO | PHASE 2** -- Specialist Planning

Consulting: devx-minion, security-minion, ux-design-minion
Skills: 2 discovered | Scratch: /tmp/nefario-scratch-a3F9xK/my-slug/

---
```

Key design decisions in this pattern:
- **Top and bottom `---`**: Creates a visual "card" that separates nefario messages from surrounding tool output. This is the single strongest separator available in CommonMark.
- **`NEFARIO |` prefix**: Consistent attribution. The user always knows who is speaking.
- **`PHASE N` label**: Phase number provides orientation (where am I in the workflow?).
- **`--` separator with phase name**: Human-readable name after the structured label.
- **Bold on the header line**: Maximum emphasis on the identification line.

#### 2. Phase Transition Announcements -- Restore with Minimal Weight

The current SKILL.md explicitly suppresses phase transitions ("Starting Phase 2...") in the NEVER SHOW list. The intent was to reduce noise. But the result is that users lose orientation -- they cannot tell where they are in the 9-phase workflow.

**Recommended approach: one-line phase banners, not prose announcements.**

The problem with "Starting Phase 2..." is that it reads as narration -- it sounds like the system talking to itself. A structured one-liner reads as a status indicator:

```
---
**NEFARIO | PHASE 3** -- Synthesis
---
```

This is 3 lines of visual output (rule, label, rule). It costs almost nothing in screen real estate but provides strong orientation. It is NOT narration -- it is a status beacon.

**Rule**: Phase banners appear at the START of each phase (1, 2, 3, 3.5, 4, 5-8 combined). They are silent for sub-steps within a phase. Post-execution phases (5-8) get a single combined banner ("Verifying...") as they already do via the CONDENSE line, not individual banners.

Phase banners should be in the SHOW tier, not CONDENSE. They are not condensable -- they are already one line. They serve a different function than content summaries: they provide spatial orientation.

#### 3. Approval Gate Visual Hierarchy

Approval gates are the highest-stakes messages in the workflow. They demand user attention and decision-making. They should be visually heavier than phase banners and status lines.

**Current gate labels** (from the SKILL.md):
- `TEAM: <summary>`
- `REVIEWERS: <summary>`
- `EXECUTION PLAN: <summary>`
- `APPROVAL GATE: <task title>`
- `PLAN IMPASSE: <description>`

**Recommended: upgrade to framed blocks with consistent structure:**

```
---

**NEFARIO | TEAM APPROVAL**
<1-sentence task summary>

Specialists: N selected | N considered, not selected

  SELECTED:
    devx-minion          Workflow integration, SKILL.md structure
    ux-strategy-minion   Approval gate interaction design

  ALSO AVAILABLE (not selected):
    ai-modeling-minion, margo, software-docs-minion, ...

Full meta-plan: phase1-metaplan.md (in scratch)

---
```

The visual hierarchy within an approval gate block:
1. **Top rule** -- "attention, here comes something important"
2. **Bold nefario attribution + gate type** -- identification
3. **Summary line** -- what this is about (plain text, not bold)
4. **Structured content** -- indented details
5. **File reference** -- meaningful label (see point 5 below)
6. **Bottom rule** -- "this block is complete"

This creates three tiers of visual weight:
- **Heavy** (approval gates): `---` top + `---` bottom + bold header + structured content
- **Medium** (phase banners): `---` top + `---` bottom + bold header only (1 line between rules)
- **Light** (CONDENSE lines): plain text, no framing, inline with flow

#### 4. Compaction Checkpoints -- Distinguish from Approval Gates

Compaction checkpoints are currently formatted similarly to gates but serve a different purpose (optional pause vs. required decision). They should be visually distinct to prevent the user from confusing "I must decide something" with "I can optionally compact."

**Recommended: use blockquote style for advisory/optional messages:**

```
> **COMPACT** -- Phase 3 complete. Specialist details are now in the synthesis.
>
> Run: `/compact focus="Preserve: current phase..."`
>
> After compaction, type `continue` to resume at Phase 3.5.
> Skipping is fine if context is short.
```

The blockquote (`>`) renders with a left border in Claude Code, creating a visually softer, "aside" feel. This signals: "this is information, not a gate." It is visually distinct from the `---`-framed approval gates.

#### 5. Scratch Directory References -- Meaningful Labels Instead of Raw Paths

Raw paths like `$SCRATCH_DIR/{slug}/phase3-synthesis.md` are opaque to users. They serve as deep-dive references but currently look like implementation details rather than useful links.

**Recommended approach: use semantic labels with the filename, not the full path.**

Current:
```
Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md
```

Proposed:
```
Full meta-plan: phase1-metaplan.md (in scratch)
```

Or for the first reference in a session, include the scratch path once as context:
```
Scratch: /tmp/nefario-scratch-a3F9xK/my-slug/
Full meta-plan: phase1-metaplan.md
Full plan: phase3-synthesis.md
```

After the scratch directory is established in the first CONDENSE line (which already includes the resolved path), subsequent references can use just the filename. The user already knows where scratch is. Repeating the full path adds noise without information.

**For approval gate file references specifically**, use a two-part format:

```
Details: phase3-synthesis.md
         phase3.5-lucy.md, phase3.5-margo.md
```

Group related files on one line. Use the `Details:` label consistently across all gates. The label communicates "here is where you go for more" without repeating the path prefix.

#### 6. Escalation Messages -- Highest Visual Weight

`PLAN IMPASSE`, `SECURITY FINDING`, and `VERIFICATION ISSUE` are escalation messages requiring urgent attention. They should be visually heavier than approval gates.

**Recommended: double horizontal rule framing + warning prefix:**

```
---

**NEFARIO | SECURITY FINDING**
Severity: CRITICAL | File: src/auth.ts:42-58

Finding: Hardcoded API key in authentication middleware.
Proposed fix: Move to environment variable with .env.example template.
Risk if unfixed: Key exposure in public repository.

---
```

The content here is already well-structured. The key addition is the consistent `NEFARIO |` prefix and `---` framing. The severity and file reference on the second line provide immediate scanability.

For PLAN IMPASSE, the existing format with POSITIONS block is good. Just wrap it in the standard frame:

```
---

**NEFARIO | PLAN IMPASSE**
<one-sentence description>
Revision rounds: 2 of 2 exhausted

POSITIONS:
  [lucy] BLOCK: ...
  [margo] BLOCK: ...

CONFLICT ANALYSIS: ...

Details: phase3.5-lucy.md, phase3.5-margo.md

---
```

#### 7. Complete Visual Vocabulary Summary

| Message Type | Visual Pattern | Weight |
|---|---|---|
| Phase banner | `---` + bold header + `---` | Medium |
| Approval gate (TEAM, REVIEWERS, PLAN, mid-execution GATE) | `---` + bold header + structured content + `---` | Heavy |
| CONDENSE line | Plain text, no framing | Light |
| Compaction checkpoint | Blockquote (`>`) with bold label | Soft/advisory |
| Escalation (IMPASSE, SECURITY, VERIFICATION) | `---` + bold header + structured content + `---` | Heavy (same frame as gates, content conveys urgency) |
| Heartbeat | Plain text, no framing | Light |
| Informational (commit line, skip note) | Plain text, no framing | Light |

The system has exactly three visual weights:
1. **Framed** (`---` borders): gates, phase banners, escalations -- things requiring attention
2. **Quoted** (`>`): advisory/optional pauses -- compaction checkpoints
3. **Inline**: status lines, heartbeats, informational notes -- flow without interruption

This three-tier system is learnable. After 1-2 orchestrations, users will recognize each pattern instantly.

### Proposed Tasks

**Task 1: Restore phase banners in the Communication Protocol**
- Move "Phase transition announcements" from NEVER SHOW to SHOW
- Define the exact one-line banner format: `---` / `**NEFARIO | PHASE N** -- <Phase Name>` / `---`
- Specify which phases get banners (1, 2, 3, 3.5, 4; post-execution uses existing CONDENSE)
- Deliverable: Updated Communication Protocol section in SKILL.md
- Dependencies: None

**Task 2: Apply consistent `---` framing to all approval gate formats**
- Update Team Approval Gate presentation format (lines ~393-406)
- Update Reviewer Approval Gate presentation format (lines ~718-730)
- Update Execution Plan Approval Gate format (lines ~1009-1086)
- Update Phase 4 mid-execution approval gate format (lines ~1219-1243)
- Update PLAN IMPASSE format (lines ~957-971)
- Update SECURITY FINDING format (lines ~1420-1426)
- Update VERIFICATION ISSUE format (lines ~1438-1451)
- Add `NEFARIO |` prefix to all gate/escalation header lines
- Deliverable: Updated gate format sections in SKILL.md
- Dependencies: Task 1 (for consistent vocabulary)

**Task 3: Convert compaction checkpoints to blockquote format**
- Update Phase 3 compaction checkpoint (lines ~649-661)
- Update Phase 3.5 compaction checkpoint (lines ~986-996)
- Use `>` blockquote instead of `---` framing
- Bold the `COMPACT` label, remove the `---` wrapping
- Deliverable: Updated compaction sections in SKILL.md
- Dependencies: Task 2 (to ensure differentiation from gates)

**Task 4: Implement semantic file reference labels**
- Define the convention: full scratch path appears once (in the initial CONDENSE line), subsequent references use filename only
- Update all gate formats to use `Details:` label with filenames instead of full `$SCRATCH_DIR/{slug}/` paths
- Group related files on single lines where they serve a common purpose
- Keep the full path in CONDENSE lines (first mention establishes context)
- Deliverable: Updated file reference patterns across all gate formats in SKILL.md
- Dependencies: Task 2 (changes the same sections)

### Risks and Concerns

1. **Horizontal rule overuse**: If every phase banner and every gate uses `---`, there could be too many horizontal rules in a long orchestration. Mitigation: phase banners are sparse (at most 6 per orchestration), and gates are budgeted at 3-5. The total `---` count stays reasonable. However, if a revision loop adds multiple re-presentations of the same gate, visual fatigue could set in. Monitor in practice.

2. **Claude Code markdown rendering variations**: Different terminal emulators and Claude Code versions may render `---`, `**`, and `>` differently. The patterns recommended here use the most universally supported CommonMark features. However, testing in the actual Claude Code terminal is essential -- what renders as a clean horizontal rule in a markdown preview might look different in a terminal.

3. **Blockquote rendering for compaction**: If Claude Code does not render blockquotes with a left border (some terminals just indent), the visual distinction from plain text is weaker. Fallback: use a different signal like `[OPTIONAL]` prefix label and plain indentation instead of blockquotes.

4. **Screen real estate**: Adding `---` top and bottom to gates adds 2 lines per gate. For a compact gate (8-12 lines as specified for TEAM), this grows to 10-14 lines. The additional space is worth the scannability, but it does push against the line budget. The budget guidelines in SKILL.md should be updated to account for the frame lines.

5. **Filename-only references lose context after compaction**: If the CONDENSE line containing the full scratch path gets compacted out of context, filename-only references become ambiguous. Mitigation: compaction directives already include "preserve scratch directory path." The scratch path should survive compaction. Additionally, the Phase 1 CONDENSE line is early enough that it is unlikely to be compacted before later gates reference it.

6. **`NEFARIO |` prefix length**: Adding `NEFARIO | ` (11 characters) to every gate header reduces the remaining space for the gate type label. In a monospace terminal at 80 columns, this is fine -- the longest gate type (`EXECUTION PLAN`) is 14 chars, totaling 25 chars before the content. Not a concern in practice.

### Additional Agents Needed

- **devx-minion**: Should review the proposed formatting changes from a developer experience perspective -- specifically whether the `---` framing pattern interferes with how developers interact with Claude Code (e.g., does copying gate output for reference become harder?). Also relevant for validating that the CONDENSE line changes do not break existing workflows.

No other additional agents needed. The task is scoped to SKILL.md formatting, which is squarely in the UI/UX design domain (visual hierarchy, information architecture, scannability). The actual implementation is editing markdown in SKILL.md -- no code, no frontend components, no accessibility compliance testing needed.
