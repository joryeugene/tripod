---
name: agent-orchestration
description: Spawn and coordinate parallel Claude Code agents for independent work streams. Use when a plan has multiple tasks that can run concurrently without touching shared files.
---

# Agent Orchestration

Parallel agents finish independent work faster. The constraint is file ownership: two agents editing the same file cause conflicts. Split by file, not by feature.

## When to Use Agents

Use parallel agents when:
- The technical plan has two or more independent work streams
- Each stream touches different files
- The streams do not need to communicate during execution

Use sequential work when:
- Streams share files or depend on each other's output
- The task is small enough that coordination overhead exceeds the gain
- You need to review output before the next step begins

## Two Tools

### Task tool (fire-and-forget)

Spawns a subagent that runs once and returns a result. Use for isolated, bounded tasks.

```
Task {
  subagent_type: "general-purpose",
  prompt: "Full context here. Subagents start fresh with no conversation history."
}
```

The subagent sees nothing from your session. Give it everything it needs: the goal, the relevant files, the constraints, the expected output format.

Skills do not transfer to subagents. Pass the skill content explicitly in the prompt if the subagent needs it, or reference the skill by name and instruct it to invoke `/skill-name`.

### TeamCreate + Task (persistent teammates)

Use when agents need a shared task list, dependency tracking, or coordination across multiple tasks.

Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` set in your environment. Add it to `~/.claude/settings.json` under the `env` key (see `settings.json.example`). Without this flag, `TeamCreate` and `TaskCreate` are not available.

```
# 1. Create the team
TeamCreate { team_name: "feature-x", description: "What we are building" }

# 2. Create tasks with dependencies
TaskCreate { subject: "Build API endpoint", description: "..." }
TaskCreate { subject: "Write tests", description: "...", addBlockedBy: ["1"] }

# 3. Spawn teammates
Task { subagent_type: "general-purpose", team_name: "feature-x", name: "api-dev",
       prompt: "Full context. Claim tasks from the shared list." }
Task { subagent_type: "general-purpose", team_name: "feature-x", name: "test-writer",
       prompt: "Full context. Wait for api-dev to complete task 1 before starting task 2." }

# 4. Shut down when done
SendMessage { type: "shutdown_request", recipient: "api-dev", content: "Work complete." }
TeamDelete {}
```

## File Ownership Rule

Assign each file to exactly one agent. State this explicitly in each spawn prompt.

```
You own: src/api/endpoints.py, src/api/models.py
Do not touch: src/tests/ (owned by test-writer)
```

Without this, two agents will edit the same file and produce conflicts that require manual resolution.

## Spawn Prompt Quality

Subagents start with no conversation history. A sparse prompt produces a confused agent.

Every spawn prompt must include:
- The specific goal (not "help with the feature", but "implement the POST /orders endpoint")
- The files to read before starting
- The files to write (owned by this agent only)
- The output format or acceptance criteria
- Any constraints from CLAUDE.md or project conventions

## Two-Stage Review

After each agent completes a task, review the output in two passes before marking it done.

**Stage 1: Spec compliance.** Does the output match the task description and acceptance criteria? Check every requirement.

**Stage 2: Code quality.** Correctness, edge cases, consistency with existing patterns.

Use a fresh subagent for each review stage. The implementing agent's context biases self-review. A fresh reviewer catches what familiarity hides.

If either stage fails: fix the issue and re-review. Do not skip re-review after a fix.

## Anti-Patterns

- Same-file edits: two agents touching one file always produces conflicts. Split by file ownership.
- Broadcast messages: `SendMessage { type: "broadcast" }` sends N messages. Use direct messages instead.
- Lead doing implementation work: the orchestrating agent creates tasks and monitors progress. It does not write code.
- Sparse spawn prompts: subagents start fresh. If the prompt omits context, the agent will guess and guess wrong.
- Forgetting shutdown: always send `shutdown_request` to each teammate, then call `TeamDelete`. Orphaned agents consume resources.
- Skipping `TeamDelete` after `shutdown_request`: the shutdown and the cleanup are two separate steps.

## The Floor

Parallel agents do not multiply output without cost. The cost is coordination: file conflicts, context duplication, and orphaned processes. The file ownership rule and the shutdown protocol are not ceremony. They are what prevent parallel work from producing more cleanup than the parallelism saved. Apply them every time, without exception.
