#!/usr/bin/env python3
"""Block em-dash class characters from prose and tool output.

Covers the dash characters that should never appear in prose:
  en-dash (U+2013), em-dash (U+2014), horizontal bar (U+2015),
  figure dash (U+2012), small em-dash (U+FE58).

Does NOT block U+2010 (hyphen), U+2011 (non-breaking hyphen),
U+2212 (minus sign), U+FE63 (small hyphen), U+FF0D (fullwidth hyphen)
since these appear legitimately in code and math contexts.
"""
import json
import sys

BANNED = "\u2012\u2013\u2014\u2015\ufe58"

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

text = ""
if tool == "Write":
    text = inp.get("content", "")
elif tool == "Edit":
    text = inp.get("new_string", "")
elif tool == "MultiEdit":
    text = " ".join(e.get("new_string", "") for e in inp.get("edits", []))
elif tool == "Bash":
    text = inp.get("command", "")

found = [ch for ch in BANNED if ch in text]
if found:
    names = {
        "\u2010": "hyphen", "\u2011": "non-breaking hyphen",
        "\u2012": "figure dash", "\u2013": "en-dash", "\u2014": "em-dash",
        "\u2015": "horizontal bar", "\u2212": "minus sign",
        "\ufe58": "small em-dash", "\ufe63": "small hyphen", "\uff0d": "fullwidth hyphen"
    }
    label = ", ".join(names.get(ch, ch) for ch in found)
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": f"Non-keyboard dash blocked ({label}). Use keyboard hyphen-minus (-) only."
        }
    }))
    sys.exit(0)
