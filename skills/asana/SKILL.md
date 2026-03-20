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

### Critical: curl flags

**Always use `-d` for POST bodies, never `--data-raw`.**
`--data-raw` causes silent 401 errors on POST /stories even when auth is valid.

**Always check HTTP status, not response body:**
```bash
curl -s -o /dev/null -w "%{http_code}" -X POST ...
```

**Never pipe curl directly to jq without checking for empty output:**
```bash
# BAD - fails silently when response is empty or an error
curl -s ... | jq '.data[] | {gid, name}'

# GOOD - capture first, then parse
RESP=$(curl -s ...)
echo "$RESP" | grep -o '"gid":"[0-9]*"' | head -1
```

**Run each curl call on its own line.** For loops across multiple curl calls fail in the eval context.

### Find the GID for anything

Asana URLs use this format: `app.asana.com/1/WORKSPACE_GID/project/PROJECT_GID/task/TASK_GID`

The long numeric IDs are the GIDs. Extract them directly from URLs.

### List sections (columns) in a project
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/projects/PROJECT_GID/sections" \
  2>&1
```

### Move task to a section (kanban column move)
```bash
curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data": {"task": "TASK_GID"}}' \
  "https://app.asana.com/api/1.0/sections/SECTION_GID/addTask"
# Expect 200
```

### Add a comment to a task
```bash
curl -s -o /dev/null -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data": {"text": "Your comment here"}}' \
  "https://app.asana.com/api/1.0/tasks/TASK_GID/stories"
# Expect 201. Note: GET /stories returns 401 on some projects even when POST works.
```

### Get full task detail
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/tasks/TASK_GID?opt_fields=gid,name,completed,assignee,due_on,memberships.section.name" \
  2>&1
```

### Create a task via REST API
```bash
curl -s -X POST \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"data": {"name": "Task name", "notes": "Description", "projects": ["PROJECT_GID"], "assignee": "USER_GID"}}' \
  "https://app.asana.com/api/1.0/tasks" \
  2>&1 | grep -o '"gid":"[0-9]*"' | head -1
```

### Search tasks in a workspace
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/workspaces/WORKSPACE_GID/tasks/search?text=keyword&opt_fields=gid,name,completed" \
  2>&1
```

### Get workspace GID
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/workspaces" \
  2>&1
```

### Get current user GID
```bash
curl -s \
  -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
  "https://app.asana.com/api/1.0/users/me" \
  2>&1 | grep -o '"gid":"[^"]*"' | head -1
```

---

## GID Lookup Pattern

Asana URL format: `app.asana.com/1/WORKSPACE_GID/project/PROJECT_GID/task/TASK_GID`

Extract GIDs from any Asana URL before making API calls. Never guess numeric IDs.
