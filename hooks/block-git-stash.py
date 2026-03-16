#!/usr/bin/env python3
"""Block git stash in any form.

git stash destroys other agents' working state and causes data loss.
Use git log, git diff, or git worktree to reason about changes instead.
"""
import json
import sys
import re

data = json.load(sys.stdin)
tool = data.get("tool_name", "")
inp = data.get("tool_input", {})

if tool == "Bash":
    command = inp.get("command", "")
    if re.search(r"\bgit\s+stash\b", command):
        print(json.dumps({
            "decision": "block",
            "reason": (
                "git stash is banned. It destroys other agents' working state and causes data loss. "
                "Use git log/diff to inspect changes, or git worktree to isolate work instead."
            )
        }))
        sys.exit(2)
