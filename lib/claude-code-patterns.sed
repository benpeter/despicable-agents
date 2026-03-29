# claude-code-patterns.sed -- Curated sed patterns for stripping Claude Code-specific content
# from AGENT.md files during translation to tool-native instruction formats.
#
# These patterns remove references to Claude Code's agent runtime: platform-specific
# tool primitives, skill invocation syntax, subagent terminology, scratch directory
# conventions, and build system markers that have no meaning in external harnesses.
#
# Applied as stage 2 after awk section-level removal (stage 1 strips ## Main Agent Mode).
#
# Usage: sed -f claude-code-patterns.sed <input>
#
# Compatibility: patterns use POSIX BRE/ERE-compatible syntax only.
# No \b word boundaries (not portable across BSD sed and GNU sed).

# ---------------------------------------------------------------------------
# Build system markers: @domain HTML comments
# Remove <!-- @domain:... --> BEGIN/END markers left by the overlay build system.
# These are structural markers that annotate content sections for the build
# pipeline; they are not documentation and have no meaning in external tools.
# The pattern matches anything up to the first '>': safe because @domain
# comments are always single-line and never contain nested HTML.
# ---------------------------------------------------------------------------
s/<!--[[:space:]]*@domain:[^>]*-->//g

# ---------------------------------------------------------------------------
# Tool primitive tokens: PascalCase Claude Code agent team tools
# These tokens appear in parenthetical references like "(use TaskUpdate to ...)"
# or in comma-separated lists of tool names. They are Claude Code-specific
# APIs unavailable in Codex CLI and Aider.
#
# Each token is handled with three patterns:
#   1. ", Token" -- trailing comma case (token is not first in list)
#   2. "Token, " -- leading comma case (token is first in list)
#   3. "Token"   -- bare token (sentence-level or after other stripping)
#
# Order matters: comma patterns must run before bare token stripping so we
# do not leave dangling commas. The tokens are unique enough that bare
# stripping without word boundaries is safe (they do not appear as substrings
# of valid prose words in agent content).
# ---------------------------------------------------------------------------

# TaskUpdate
s/,[[:space:]]*TaskUpdate//g
s/TaskUpdate,[[:space:]]*//g
s/TaskUpdate//g

# TaskList
s/,[[:space:]]*TaskList//g
s/TaskList,[[:space:]]*//g
s/TaskList//g

# TaskCreate
s/,[[:space:]]*TaskCreate//g
s/TaskCreate,[[:space:]]*//g
s/TaskCreate//g

# SendMessage
s/,[[:space:]]*SendMessage//g
s/SendMessage,[[:space:]]*//g
s/SendMessage//g

# TeamCreate
s/,[[:space:]]*TeamCreate//g
s/TeamCreate,[[:space:]]*//g
s/TeamCreate//g

# TeamUpdate
s/,[[:space:]]*TeamUpdate//g
s/TeamUpdate,[[:space:]]*//g
s/TeamUpdate//g

# AskUserQuestion
s/,[[:space:]]*AskUserQuestion//g
s/AskUserQuestion,[[:space:]]*//g
s/AskUserQuestion//g

# ---------------------------------------------------------------------------
# Phrase removals: Claude Code invocation and runtime phrases
# These phrases reference Claude Code's agent model directly and have no
# equivalent in external harnesses.
# ---------------------------------------------------------------------------

# "via the Task tool" -- references Claude Code's Task tool for subagent spawning
s/ via the Task tool//g

# "via the /nefario skill" -- references Claude Code's skill invocation syntax
# Matches with and without backtick quoting of the skill name
s/ via the `\/nefario` skill//g
s/ via the \/nefario skill//g

# "running as main agent via `claude --agent ...`" and variants
# Parenthetical form: (running as main agent via `claude --agent foo`)
s/ (running as main agent via `[^`]*`)//g
# Standalone phrase without parens
s/ running as main agent via `[^`]*`//g

# "(not a spawned subagent)" and related subagent qualifier phrases
s/ (not a spawned subagent)//g
s/ -- not a spawned subagent//g
s/, not a spawned subagent//g
s/ (spawned subagent[^)]*)//g
s/ as a spawned subagent//g

# ---------------------------------------------------------------------------
# Scratch directory references
# nefario-scratch-XXXX patterns are Claude Code session temp directory names.
# "scratch directory conventions" is a Claude Code-specific operational note.
# We strip the compound phrases, not the word "scratch" in isolation.
# ---------------------------------------------------------------------------

# nefario-scratch-XXXXXXXX session temp dir names
s/nefario-scratch-[A-Za-z0-9]*//g

# "scratch directory conventions" phrase (the spec-mandated phrase)
s/ scratch directory conventions//g
s/scratch directory conventions //g
s/scratch directory conventions//g

# ---------------------------------------------------------------------------
# Context cleanup: artifacts left by the above removals
# Run these last to clean up dangling punctuation and whitespace created
# by stripping tokens from lists and sentences.
# ---------------------------------------------------------------------------

# Empty parentheses (with or without internal spaces) left after token removal
s/([[:space:]]*)//g

# Dangling commas: ", ," -> ","
s/,[[:space:]]*,/,/g

# Leading comma inside parens after token was stripped: "(, foo)" -> "(foo)"
s/([[:space:]]*,[[:space:]]*/(/g

# Trailing comma before closing paren: "(foo, bar,)" -> "(foo, bar)"
s/,[[:space:]]*)/)/g

# Space before comma (artifact of empty paren/token removal): "teams , spawn" -> "teams, spawn"
s/ ,/,/g

# Two or more consecutive spaces -> single space, preserving leading indentation.
# Matches a non-space character followed by two or more spaces, collapses to one.
# Running twice handles cases like "a   b   c" -> "a  b  c" -> "a b c".
s/\([^[:space:]]\)  */\1 /g
s/\([^[:space:]]\)  */\1 /g
