#!/usr/bin/env python3
"""Block non-keyboard dash characters from any tool output.

Covers: en-dash (U+2013), em-dash (U+2014), horizontal bar (U+2015),
figure dash (U+2012), hyphen (U+2010), non-breaking hyphen (U+2011),
minus sign (U+2212), small em-dash (U+FE58), small hyphen (U+FE63),
fullwidth hyphen (U+FF0D).
"""
import json
import sys

BANNED = "\u2010\u2011\u2012\u2013\u2014\u2015\u2212\ufe58\ufe63\uff0d"

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

text = ""
if tool in ("Write", "Edit", "MultiEdit"):
    text = inp.get("new_text", "") or inp.get("content", "") or ""
    if isinstance(inp.get("edits"), list):
        text = " ".join(e.get("new_text", "") for e in inp["edits"])
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
        "decision": "block",
        "reason": f"Non-keyboard dash blocked ({label}). Use keyboard hyphen-minus (-) only."
    }))
    sys.exit(2)
