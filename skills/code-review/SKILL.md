---
name: code-review
description: Use when receiving PR feedback or when requesting a code review before merge. Covers both directions: responding to reviewer comments and dispatching a review subagent.
user-invocable: true
---

# Code Review

Two modes. Invoke with `/code-review receiving` or `/code-review requesting`. If no argument, ask which mode.

---

## Receiving Reviews

When a reviewer (human or AI) provides feedback on your code.

### Read Everything First

Read all comments before responding to any of them. Understand the full picture before acting on a single item.

### Forbidden Responses

These phrases are performative, not productive. They signal compliance without comprehension.

| Banned | Why |
|--------|-----|
| "You're absolutely right!" | Flattery, not understanding. |
| "Great catch!" | Same. |
| "Good point, I'll fix that." | Skips the comprehension step. |
| "Thanks for the thorough review!" | Filler. |

Instead: restate the feedback in your own words. "The reviewer identified that X causes Y because Z. The fix is to change A to B." If you cannot restate it, you do not understand it.

### YAGNI Check

Before implementing any reviewer suggestion that adds new functionality:

1. Grep the codebase for actual usage of the pattern being suggested.
2. If no current caller exists, the suggestion is speculative. Push back with evidence: "Grepped for X, found 0 callers. Adding this would be speculative."
3. If callers exist, proceed.

### Implementation Protocol

1. Implement one review item at a time.
2. Run tests after each item.
3. If a suggestion conflicts with project conventions (CLAUDE.md, existing patterns), push back with the specific convention and file path.
4. Technical disagreement is not insubordination. State the tradeoff, cite the evidence, and let the reviewer decide.

### When to Push Back

Push back when:
- The suggestion adds complexity without a current caller (YAGNI).
- The suggestion conflicts with documented project conventions.
- The suggestion introduces a pattern inconsistent with the existing codebase.
- You have evidence (benchmark, test, trace) that the suggestion degrades behavior.

Push back by stating the evidence, not by arguing. "This conflicts with the pattern in src/utils.py:42 where we chose X because Y" is pushback. "I disagree" is not.

---

## Requesting Reviews

When you want your code reviewed before merge.

### Dispatch a Review Subagent

Spawn a fresh subagent with no shared context. The reviewer must form its own understanding.

```
Task {
  subagent_type: "general-purpose",
  prompt: "You are a code reviewer. Review the changes between <base_sha> and <head_sha>.

  Run: git diff <base_sha>...<head_sha>

  Review for:
  1. Correctness: does the code do what it claims?
  2. Contracts: are function promises maintained?
  3. Edge cases: what inputs break this?
  4. Consistency: does this match existing patterns in the codebase?

  Read CLAUDE.md for project conventions. Flag any violations.

  Output format:
  - CRITICAL: must fix before merge
  - WARNING: should fix, not blocking
  - NOTE: style or preference, non-blocking

  If everything looks clean, say so. Do not manufacture issues."
}
```

### When to Request Review

- After completing a major feature or significant refactor.
- Before merging to main.
- After fixing a bug where the root cause was subtle.

### Two-Stage Review

For critical changes, run two review passes:

1. **Spec compliance**: does the implementation match the spec or requirements? Check every acceptance criterion.
2. **Code quality**: correctness, edge cases, patterns, conventions.

A fresh subagent for each stage prevents the first review's framing from biasing the second.

---

## Anti-Patterns

- Performative agreement with reviewer feedback. Restate in your own words or you have not understood it.
- Implementing all suggestions without evaluating each one. Reviews contain both essential fixes and speculative improvements. Distinguish them.
- Skipping the YAGNI check. "The reviewer said to add it" is not evidence that callers exist.
- Reviewing your own code in the same context window. A fresh subagent catches what familiarity hides.
- Manufacturing review issues to appear thorough. If the code is clean, say so.

## The Floor

Code review is a verification step, not a performance. The reviewer's job is to find what the author missed. The author's job is to understand the feedback, not to agree with it. Performative responses waste both sides' time. Restate, evaluate, implement or push back. That is the entire protocol.
