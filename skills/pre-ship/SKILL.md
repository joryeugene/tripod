---
name: pre-ship
description: Pre-landing diff review for bugs that CI misses. Runs before every ship.
disable-model-invocation: true
---

# Pre-Landing Review

A paranoid check for the bugs that pass CI but explode in production. Runs before every merge.

---

## Step 1: Check branch

```bash
git branch --show-current
```

If on `main` or `master`: output "Nothing to review. You're on main." and stop.

```bash
git fetch origin main --quiet && git diff origin/main --stat
```

If no diff: output "No changes against main." and stop.

---

## Step 2: Read project checklist

Read the project's CLAUDE.md. Look for a section titled `## Review Checklist`.

If found: use those items as the primary checklist. They represent project-specific patterns that matter.

If not found: use the default checklist below.

### Default Checklist

**Pass 1 (CRITICAL):**

- SQL/data safety: raw SQL injection, missing parameterization, destructive operations without confirmation
- Trust boundaries: unsanitized user input flowing into queries, file paths, or shell commands
- Race conditions: concurrent access to shared state, TOCTOU bugs
- Resource leaks: unclosed connections, unjoined tasks, missing cleanup

**Pass 2 (INFORMATIONAL):**

- Dead code introduced by this diff
- Magic numbers or string coupling
- Missing error handling (unwrap/expect in Rust, unhandled promises in JS, bare except in Python)
- Test gaps: new code paths without corresponding tests
- Consistency: does this diff follow the patterns established elsewhere in the codebase?

---

## Step 3: Get the diff

```bash
git fetch origin main --quiet
git diff origin/main
```

Read the FULL diff before commenting. Do not flag issues already addressed in the diff.

---

## Step 4: Two-pass review

Apply the checklist (project-specific or default) against the diff.

**Pass 1:** CRITICAL items only. These block shipping.
**Pass 2:** INFORMATIONAL items. These are worth noting but don't block.

For each finding, report:

- File and line number
- The problem (one sentence)
- The fix (one sentence)
- Severity: CRITICAL or INFORMATIONAL

---

## Step 5: Output findings

**Always output ALL findings.** Both critical and informational.

Summary header: `Pre-Landing Review: N issues (X critical, Y informational)`

**If CRITICAL issues found:** For EACH critical issue, use AskUserQuestion:

- Show the problem and recommended fix
- Options: A) Fix it now (recommended), B) Acknowledge and ship anyway, C) False positive
- If user chooses A: apply the fix

**If only informational issues found:** Output them. No action needed.

**If no issues found:** Output `Pre-Landing Review: No issues found.`

---

## Anti-Patterns

- Reviewing individual lines without reading the full diff first. Context matters. A line that looks wrong is often addressed 50 lines later.
- Flagging informational issues as CRITICAL. Only security, correctness, and data-loss risks are CRITICAL. Everything else is informational.
- Skipping the review because the diff is small. Small changes are where real bugs hide because they get less scrutiny.
- Creating commits during review. Read-only by default. Only modify files if the user explicitly chooses "Fix it now."
- Flagging style preferences. This is a bug review, not a code style review. The project's CLAUDE.md checklist is the authority.

## The Floor

CI catches the tests you wrote. The pre-landing review catches the bugs you didn't think to test: injection paths, race conditions, resource leaks, and consistency violations. Two passes, CRITICAL then INFORMATIONAL, run every time without exception. The discipline is not optional for high-stakes changes and relaxed for small ones. It runs every time because the small changes are where the real bugs hide.
