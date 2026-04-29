#!/usr/bin/env python3
"""Block --no-verify in git commands.

--no-verify skips pre-commit and commit-msg hooks. Hooks encode hard constraints
that cannot be deprioritized mid-session. Bypassing them defeats the entire
enforcement layer. Fix the root cause of the hook failure instead.
"""
import json
import sys

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

if tool == "Bash":
    command = inp.get("command", "")
    if "--no-verify" in command:
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": (
                    "--no-verify is banned. Hooks encode hard constraints that exist for a reason. "
                    "Investigate and fix the root cause of the hook failure instead of bypassing it."
                )
            }
        }))
        sys.exit(0)
