---
name: pr-review
description: Use when reviewing a PR or responding to review comments on your own PR. Detects authorship automatically and runs the correct mode. Never makes code changes when reviewing someone else's work.
user-invocable: true
---

# Code Review

Two modes determined by identity. The skill detects which mode applies automatically.

Invoke with `/pr-review <pr-url-or-number>`. If no argument, ask for the PR.

---

## Step 0: Detect Identity

Before anything else, determine who you are and who authored the PR.

```bash
gh api user -q .login
gh pr view <number> --json author -q .author.login
```

If your username matches the PR author: you are the **author**. Run **Responding to Reviews**.

If your username does not match: you are a **reviewer**. Run **Reviewing a PR**.

This determines everything. Reviewers do not make code changes. Authors do not submit reviews on their own PR.

---

## Reviewing a PR (you are NOT the author)

Your job is to review the code, submit a GitHub review, and leave inline comments. You do not touch the code. You do not make changes. You submit feedback.

### 1. Read the full diff

```bash
gh pr diff <number>
```

Read the entire diff before writing any comments. Understand the full scope of changes.

### 2. Read project conventions

Read CLAUDE.md and any relevant project docs. Flag violations of documented conventions, not personal preferences.

### 3. Evaluate

Review for:
- **Correctness**: does the code do what it claims?
- **Contracts**: are function promises maintained? Do return types match?
- **Edge cases**: what inputs or states could break this?
- **Consistency**: does this follow existing patterns in the codebase?
- **Security**: does this introduce any OWASP top 10 vulnerabilities?

For each finding, classify:

| Level | Meaning | Blocking? |
|-------|---------|-----------|
| **CRITICAL** | Bug, security issue, data loss risk | Yes |
| **WARNING** | Correctness concern, missing edge case | Author's judgment |
| **NOTE** | Style, naming, minor improvement | No |

If the code is clean, say so. Do not manufacture issues to appear thorough.

### 4. Submit the review on GitHub

If there are inline comments (preferred when findings are code-specific):

```bash
# Start a review with inline comments
gh api repos/{owner}/{repo}/pulls/{number}/reviews -X POST -f body="Review summary" -f event="<EVENT>" -f comments='[{"path":"src/file.py","line":42,"body":"Comment text"}]'
```

If there are no line-specific findings, submit a plain review:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews -X POST -f body="Review summary" -f event="<EVENT>"
```

Where `<EVENT>` is one of:
- `APPROVE` when all findings are NOTE-level or no findings at all
- `REQUEST_CHANGES` when any CRITICAL finding exists
- `COMMENT` when findings exist but none are blocking

Inline comments are preferred over a single summary comment whenever findings reference specific lines. Reviewers reading the PR see inline comments in context.

### 5. Dispatch a review subagent (optional, for large PRs)

Spawn a fresh subagent with no shared context. The reviewer must form its own understanding independently.

```
Agent {
  subagent_type: "general-purpose",
  prompt: "You are a code reviewer. Review PR #{number} in {owner}/{repo}.

  Run: gh pr diff {number} --repo {owner}/{repo}
  Read: gh pr view {number} --repo {owner}/{repo} --json body,title,files

  For each finding, report:
  - File path and line number
  - Severity: CRITICAL / WARNING / NOTE
  - What is wrong and why

  Read CLAUDE.md for project conventions. Flag violations.
  If everything looks clean, say so."
}
```

After the subagent returns findings, post them as inline review comments using the GraphQL pattern in step 4. Do not relay findings as a text summary to the user.

### What you do NOT do as a reviewer

- Do not check out the branch.
- Do not edit any files.
- Do not push commits.
- Do not resolve your own comments.
- You read, you evaluate, you submit feedback. That is the scope.

---

## Responding to Reviews (you ARE the author)

Someone reviewed your PR. Your job is to understand the feedback, then either fix the code or push back with evidence.

### 1. Read all comments first

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews
gh api repos/{owner}/{repo}/pulls/{number}/comments
```

Read every comment before responding to any of them. Understand the full picture before acting.

### 2. Restate each comment

For each piece of feedback, restate it in your own words before implementing anything. "The reviewer identified that X causes Y because Z. The fix is to change A to B."

If you cannot restate it, you do not understand it. Ask for clarification.

### Forbidden Responses

These phrases are performative, not productive. They signal compliance without comprehension.

| Banned | Why |
|--------|-----|
| "You're absolutely right!" | Flattery, not understanding. |
| "Great catch!" | Same. |
| "Good point, I'll fix that." | Skips the comprehension step. |
| "Thanks for the thorough review!" | Filler. |

### 3. YAGNI check

Before implementing any suggestion that adds new functionality:

1. Grep the codebase for actual usage of the pattern being suggested.
2. If no current caller exists, the suggestion is speculative. Push back with evidence: "Grepped for X, found 0 callers. Adding this would be speculative."
3. If callers exist, proceed.

### 4. Implement or push back

For each comment, do one of:

**Implement:** Fix the code. One comment at a time. Run tests after each fix.

**Push back:** State the evidence, not an opinion.
- "This conflicts with the pattern in src/utils.py:42 where we chose X because Y."
- "Grepped for callers, found 0. This would be speculative."
- "Benchmark shows the suggested approach is 3x slower: [output]."

Technical disagreement is not insubordination. State the tradeoff, cite the evidence, and let the reviewer decide.

### 5. Reply inline to comment threads

Always reply in the specific thread, not as a standalone PR comment.

**Get the thread IDs first:**

```bash
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      reviewThreads(last: 20) {
        nodes {
          id
          isResolved
          comments(first: 1) {
            nodes { id databaseId body author { login } }
          }
        }
      }
    }
  }
}'
```

**Reply inline to a thread** (use the `id` field starting with `PRRT_`):

```bash
gh api graphql -f query='mutation {
  addPullRequestReviewThreadReply(input: {
    pullRequestReviewThreadId: "PRRT_xxx",
    body: "Your reply here."
  }) {
    comment { id }
  }
}'
```

This posts the reply directly in the inline comment thread. The REST endpoint `pulls/comments/{id}/replies` returns 404 for review thread comments - always use GraphQL for inline replies.

**Reply style:** One or two sentences. State the fact and the fix.

Good: "Fixed. Radix dropdown adds overflow:hidden to body, removing the scrollbar. `modal={false}` disables this."

Bad: "Yes, great observation! You're right that this is important. I've looked into this and the reason we added `modal={false}` is because Radix UI DropdownMenu by default sets `modal={true}` which causes the body element to have overflow:hidden applied..." (verbose, performative)

### 6. Dismiss bot reviews after addressing

When a bot (claude[bot], copilot) requests changes and you have addressed them, dismiss the review so it does not block merge.

```bash
# Find the review ID
gh api graphql -f query='{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: PR_NUMBER) {
      reviews(last: 10) {
        nodes { id author { login } state }
      }
    }
  }
}'

# Dismiss the CHANGES_REQUESTED review
gh api graphql -f query='mutation {
  dismissPullRequestReview(input: {
    pullRequestReviewId: "PRR_xxx",
    message: "All issues addressed in follow-up commit."
  }) {
    pullRequestReview { state }
  }
}'
```

### 7. Re-request reviews after pushing fixes

```bash
gh pr edit {PR_NUMBER} --add-reviewer {username}
```

### When to push back

- The suggestion adds complexity without a current caller (YAGNI).
- The suggestion conflicts with documented project conventions.
- The suggestion introduces a pattern inconsistent with the existing codebase.
- You have evidence (benchmark, test, trace) that the suggestion degrades behavior.

---

## Two-Stage Review (for critical changes)

When reviewing a large or high-risk PR, run two separate passes:

1. **Spec compliance**: does the implementation match the spec or requirements? Check every acceptance criterion.
2. **Code quality**: correctness, edge cases, patterns, conventions.

A fresh subagent for each stage prevents the first review's framing from biasing the second.

---

## Anti-Patterns

- Making code changes when you are the reviewer. Reviewers submit feedback. Authors make changes.
- Performative agreement with reviewer feedback. Restate in your own words or you have not understood it.
- Implementing all suggestions without evaluating each one. Reviews contain both essential fixes and speculative improvements. Distinguish them.
- Skipping the YAGNI check. "The reviewer said to add it" is not evidence that callers exist.
- Posting a single summary comment when inline comments would place feedback in context.
- Manufacturing review issues to appear thorough. If the code is clean, say so.
- Reviewing your own code in the same context window. A fresh subagent catches what familiarity hides.

## The Floor

Identity determines behavior. Reviewers read, evaluate, and submit feedback on GitHub. Authors read feedback, understand it, and either fix the code or push back with evidence. The skill detects which role applies and enforces the boundary. A reviewer who makes code changes has overstepped. An author who submits a review on their own PR has confused the roles.
