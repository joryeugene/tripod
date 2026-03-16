---
name: hooks-guide
description: Write your own Claude Code enforcement hooks. Use when you want to make a rule structurally impossible rather than merely described.
---

# Hooks Guide

A rule in CLAUDE.md is a suggestion. A hook is a hard constraint. This guide teaches you to write hooks that make the wrong thing structurally absent.

## Why Hooks Are Antifragile

A description can be forgotten. A hook cannot be bypassed without being explicitly disabled.

- **Zero context overhead.** Hooks run outside the conversation. They don't consume tokens.
- **Deterministic.** Same trigger, same action, every time. No probabilistic behavior.
- **Structural.** The wrong pattern becomes impossible, not just discouraged.

## Hook Types

```
PreToolUse          Fires BEFORE a tool call (can block)
PostToolUse         Fires AFTER a tool call
UserPromptSubmit    Fires when user sends a message
SessionStart        Fires when a session begins
SessionEnd          Fires when a session ends
```

## Hook Configuration

Register hooks in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/block-unicode-dashes.py"
          }
        ]
      }
    ]
  }
}
```

**matcher** matches on tool name. Use `|` to match multiple tools. Use `*` for all tools.

## How to Block a Tool Call

Read JSON from stdin. Exit 2 to block. Print the reason to stderr.

```python
#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

if tool in ("Write", "Edit", "MultiEdit"):
    content = inp.get("content", "") or inp.get("new_content", "")
    if "\u2014" in content:  # em-dash
        print(json.dumps({
            "decision": "block",
            "reason": "Em-dash found. Restructure the sentence."
        }), file=sys.stderr)
        sys.exit(2)

sys.exit(0)
```

Exit 0 to allow the tool call. Exit 2 to block it. The `reason` appears to Claude as an error message explaining what to do instead.

## The Complete Example

`hooks/block-unicode-dashes.py` in this repo is the canonical reference. Read it. It handles all three hook-eligible tools (Write, Edit, Bash), checks for multiple banned characters (em-dash, en-dash, HTML entities, double-hyphen), and provides a clear reason on block.

## The Three-Layer System

```
CLAUDE.md           hooks/              skills/
(philosophy)        (enforcement)       (workflow)
always loaded       always fires        on demand
describes rules     enforces rules      guides execution
```

A rule belongs in a hook when it must never be violated. If you catch yourself repeatedly reminding Claude not to do X, that pattern belongs in a hook.

## Anti-Patterns

- Don't put complex logic in hooks. They run on every tool call. Keep them fast.
- Don't silently fail. If a hook encounters an unexpected error, log it or block with a clear message.
- Don't duplicate what CLAUDE.md says. If you write a hook, remove the matching prose rule. The hook is the rule now.
- Don't write hooks that warn but allow. A warning that doesn't block is noise. Block or don't hook.

## The Floor

A rule described in prose is a rule that can be forgotten. A rule encoded as a hook is a constraint the system must satisfy before any tool call completes. Every project accumulates patterns that matter too much to leave as suggestions. Those patterns belong in hooks. The list grows with every failure. Growth is the feature.
