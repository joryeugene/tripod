#!/usr/bin/env python3
"""Block Co-Authored-By lines from git commits.

The Claude Code system prompt hardcodes instructions to add Co-Authored-By
to every commit. This hook blocks that at the structural level.
"""
import json
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

if tool == "Bash":
    cmd = inp.get("command", "")
    if "co-authored-by" in cmd.lower():
        print(json.dumps({
            "decision": "block",
            "reason": "Co-Authored-By is banned in commits. Remove the Co-Authored-By line and commit without it."
        }), file=sys.stderr)
        sys.exit(2)
