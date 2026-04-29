#!/usr/bin/env python3
"""Block curly/smart quotes inside HTML tags in .html files.

Curly quotes in prose content are correct typography.
Curly quotes inside HTML attributes break the DOM:
  <dt id=\u201cdispensationalism\u201d>  -- broken
  <dt id="dispensationalism">            -- correct

Checks: U+201C (left double), U+201D (right double),
        U+2018 (left single), U+2019 (right single).
"""
import json
import re
import sys

CURLY = "\u201c\u201d\u2018\u2019"

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

if tool == "Write":
    text = inp.get("content", "")
    path = inp.get("file_path", "")
elif tool == "Edit":
    text = inp.get("new_string", "")
    path = inp.get("file_path", "")
elif tool == "MultiEdit":
    text = " ".join(e.get("new_string", "") for e in inp.get("edits", []))
    path = inp.get("file_path", "")
else:
    sys.exit(0)

if not path.endswith(".html"):
    sys.exit(0)

for m in re.finditer(r"<[^>]+>", text):
    tag = m.group()
    found = [ch for ch in CURLY if ch in tag]
    if found:
        names = {
            "\u201c": "\u201c left-dbl",
            "\u201d": "\u201d right-dbl",
            "\u2018": "\u2018 left-sgl",
            "\u2019": "\u2019 right-sgl",
        }
        label = ", ".join(names.get(ch, ch) for ch in found)
        # Truncate tag for readability
        snippet = tag[:80] + ("..." if len(tag) > 80 else "")
        print(
            json.dumps(
                {
                    "hookSpecificOutput": {
                        "hookEventName": "PreToolUse",
                        "permissionDecision": "deny",
                        "permissionDecisionReason": (
                            f"Curly quote inside HTML tag ({label}). "
                            f"Use straight quotes in attributes. Tag: {snippet}"
                        ),
                    }
                }
            )
        )
        sys.exit(0)
