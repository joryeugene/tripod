---
name: code-hygiene
description: Review your codebase for drift introduced by isolated AI sessions: dead exports, duplicate logic, and orphaned types.
---

# Code Hygiene

AI sessions are stateless. Each one writes code without knowledge of what the last one wrote.

## The Core Problem

Every AI session starts fresh. Without deliberate effort, each one will:

- Write a new `formatDate` utility that already exists in three other files.
- Leave exports that nothing imports.
- Create types for APIs that no longer exist.
- Swallow errors in empty catch blocks.
- Introduce config drift: env vars documented but unused, or used but undocumented.

## Prevention During Work

Before writing new code:

1. Search the codebase for existing implementations.
2. Search project notes and CLAUDE.md for prior decisions.
3. If something similar exists, extend it rather than duplicate it.

After finishing work:

- Remove dead code you introduced.
- Handle or log all exceptions (never empty catch blocks).
- Remove unused imports.

## The Weekly Sweep

Combine automated tools with manual review:

1. Run unused-code detection (ruff, knip, depcheck, or equivalent for your language).
2. Search for duplicate function signatures across the codebase.
3. Audit recent AI-generated changes for consolidation opportunities.
4. Check env var drift: compare documented vars against actual usage.
5. Update dependencies.

## During AI Sessions

Each AI response is an opportunity to introduce drift. Manage it actively:

- When the user gives multiple requests, log each as a TODO before starting work.
- Verify each change individually before moving to the next.
- Record architecture decisions as they happen.
- At session end: check for orphaned imports, dead code, and uncovered changes.

## Anti-Patterns

- Writing a new utility without searching for an existing one first. Three similar lines of code are better than a premature abstraction, but five separate implementations are a maintenance problem.
- Empty catch blocks. If an exception is swallowed silently, every failure becomes invisible.
- Skipping the weekly sweep. Drift compounds. Each isolated session adds a little. The sweep is what keeps it bounded.
- Leaving dead exports because removing them seems risky. If nothing imports it, remove it.

## The Floor

AI-assisted codebases accumulate debt differently than human-only codebases. The mechanism is session isolation: each agent writes confidently without knowing what already exists. The hygiene practices here are the antidote. They are not about aesthetics or preferences. They are about keeping a codebase comprehensible to the next session, which starts without any memory of this one.
