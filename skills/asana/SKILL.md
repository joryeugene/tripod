---
name: asana
description: Manage Asana tasks and projects from the terminal. Use the timwehrle/asana CLI for common operations and direct REST API calls for section/kanban moves. Invoke with /asana.
---

# Asana

CLI + REST API for most operations. MCP mode available for conversational access (see below).

## Prerequisites

Install the CLI once:
```bash
brew tap timwehrle/asana && brew install --formula asana
```

Authenticate (stores PAT in system keyring, never plain text on disk):
```bash
asana auth
```

REST API calls use `$ASANA_ACCESS_TOKEN` (personal access token from
Asana Settings > Apps > Personal Access Tokens).

---

## Optional: MCP Mode

For conversational Asana access without writing CLI commands:

```bash
mcp-use asana
```

Restart Claude Code. The session will have direct Asana tool access.
Requires `ASANA_ACCESS_TOKEN` in your environment or the `.mcp.json` env block.

---

## CLI: Common Operations

```bash
# List your tasks
asana tasks list

# List tasks in a project (needs project GID)
asana tasks list --project PROJECT_GID

# View full task detail interactively
asana tasks view TASK_GID

# Create a task in a project
asana tasks create --name "Fix the thing" --project PROJECT_GID

# Update a task interactively (assignee, due date, etc.)
asana tasks update TASK_GID

# Mark a task complete
asana tasks complete TASK_GID

# List projects in your workspace
asana projects list
```

---

## REST API: Kanban and Section Operations

The CLI does not expose sections. Use the Asana REST API directly for kanban column moves.

Base URL: `https://app.asana.com/api/1.0`
Auth header: `-H "Authorization: Bearer $ASANA_ACCESS_TOKEN"`

### Find the GID for anything

Every Asana URL contains the GID. From `app.asana.com/0/PROJECT_GID/TASK_GID`,
the long numeric IDs are the GIDs.

### List sections (columns) in a project
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/projects/PROJECT_GID/sections" \
  | jq '.data[] | {gid, name}'
```

### Move task to a section (kanban column move)
```bash
curl -s -X POST \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data": {"task": "TASK_GID"}}' \
  "https://app.asana.com/api/1.0/sections/SECTION_GID/addTask"
```

### Add a comment to a task
```bash
curl -s -X POST \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data": {"text": "Your comment here"}}' \
  "https://app.asana.com/api/1.0/tasks/TASK_GID/stories"
```

### Get full task detail
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/tasks/TASK_GID" \
  | jq '.data | {gid, name, completed, assignee, due_on, memberships}'
```

### Search tasks in a workspace
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/workspaces/WORKSPACE_GID/tasks/search?text=keyword&opt_fields=gid,name,completed" \
  | jq '.data[] | {gid, name, completed}'
```

### Get workspace GID
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/workspaces" \
  | jq '.data[] | {gid, name}'
```

---

## GID Lookup Pattern

When you have a task URL like `app.asana.com/0/1234567890123456/9876543210987654`:
- Project GID: `1234567890123456`
- Task GID: `9876543210987654`

Extract GIDs from any Asana URL before making API calls. Never guess numeric IDs.
