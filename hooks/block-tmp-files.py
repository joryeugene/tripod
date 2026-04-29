#!/usr/bin/env python3
"""Block writes to /tmp and Bash commands that create files there.

/tmp is cleaned up by the OS. Files written there are silently lost.
Write to the project directory or output directly to stdout instead.
"""
import json
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

blocked = False

if tool == "Write":
    path = inp.get("file_path", "")
    if path.startswith("/tmp/") or path.startswith("/tmp"):
        blocked = True

elif tool == "Bash":
    command = inp.get("command", "")
    if "/tmp/" in command or command.strip().startswith("mktemp"):
        blocked = True

if blocked:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "/tmp is banned. Files written there are lost when the OS cleans up. "
                "Write to the project directory or output directly to stdout instead."
            )
        }
    }))
    sys.exit(0)
