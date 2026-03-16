#!/usr/bin/env python3
"""Block LLM typographic fingerprints from prose and all files.

Principle: human-typeable characters only. An LLM has no keyboard friction
and reaches for characters a human would never type.

Two passes:
  ALL files: zero-width space (U+200B) -- invisible, used in prompt injection
             and LLM watermarking. Never intentional.
  PROSE files (.md .txt .rst .html .mdx) only, skipping code fences:
    - Spaced double-hyphen ( -- ) as em-dash substitute. word--word is fine.
    - ASCII arrows: -> --> =>
    - Unicode arrows: <- -> => left-right double long
    - Horizontal ellipsis U+2026. Humans type three dots (...).

NOT blocked: smart/curly quotes (U+201C/D U+2018/9). User writes prose
that intentionally uses these. They are not a reliable LLM fingerprint here.

Already covered by block-unicode-dashes.py: U+2012 U+2013 U+2014 U+2015 U+FE58.
"""
import json
import os
import re
import sys

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

PROSE_EXTS = {".md", ".txt", ".rst", ".html", ".mdx"}

# Block in ALL files. These have no legitimate use anywhere.
ALL_PATTERNS = [
    (
        "\u200b",
        "Zero-width space (U+200B) blocked -- invisible character used in "
        "prompt injection and LLM watermarking. Remove it.",
    ),
]

# Block in PROSE files only (after stripping code fences).
# ASCII arrows are legitimate in code (Python return types, shell flags).
PROSE_PATTERNS = [
    (
        r" -- ",
        "Spaced double-hyphen ( -- ) blocked -- use the no-space form "
        "(word--word) or restructure the sentence entirely.",
    ),
    (
        r"->|-->|=>",
        "ASCII arrow in prose blocked (-> --> =>) -- write it out as text.",
    ),
    (
        "\u2190|\u2192|\u21d2|\u27f6|\u21a6",
        "Unicode arrow in prose blocked (\u2190\u2192\u21d2\u27f6\u21a6) -- write it out as text.",
    ),
    (
        "\u2026",
        "Horizontal ellipsis (U+2026 \u2026) blocked -- type three dots (...) instead.",
    ),
]


def strip_code_fences(s: str) -> str:
    return re.sub(r"```[\s\S]*?```|~~~[\s\S]*?~~~", "", s)


def block(reason: str) -> None:
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(2)


# Pass 1: all files
for pattern, reason in ALL_PATTERNS:
    if re.search(pattern, text):
        block(reason)

# Pass 2: prose files only
ext = os.path.splitext(path)[1].lower()
if ext in PROSE_EXTS:
    prose_text = strip_code_fences(text)
    for pattern, reason in PROSE_PATTERNS:
        if re.search(pattern, prose_text):
            block(reason)
