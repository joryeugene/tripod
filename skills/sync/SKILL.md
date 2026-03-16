---
name: sync
description: Install or update claude-stack and sync the plugin cache. Use when the user says "sync claude-stack", "update claude-stack", "install claude-stack", or "set up claude-stack".
user-invocable: true
---

# claude-stack Sync

Install claude-stack from scratch or bring an existing installation up to date. Walk through each step, verifying as you go.

## Step 1: Detect install type

Determine whether the user is a developer (has the repo cloned) or an end user (installed via marketplace).

Check if a file named `sync` exists in the current working directory alongside `.claude-plugin/plugin.json`:

```bash
test -f ./sync && test -f ./.claude-plugin/plugin.json && echo "dev" || echo "user"
```

If the result is `dev`, use the **dev path** for Step 2.
If the result is `user`, use the **user path** for Step 2.

Also check whether the plugin is already installed:

```bash
python3 -c "
import json, sys, os
f = os.path.expanduser('~/.claude/plugins/installed_plugins.json')
if not os.path.exists(f):
    print('not-installed')
    sys.exit(0)
data = json.load(open(f))
if 'claude-stack@claude-stack' in data.get('plugins', {}):
    print('installed')
else:
    print('not-installed')
"
```

If `not-installed` and on the user path, tell the user to run:

```
claude plugin marketplace add joryeugene/claude-stack
claude plugin install claude-stack
```

Then re-run `/sync` after those commands complete.

## Step 2: Update

### Dev path

Run the sync script from the repo directory:

```bash
./sync
```

This copies skills, hooks, and config from the repo into the plugin cache at `~/.claude/plugins/cache/claude-stack/claude-stack/1.0.0/`.

### User path

Re-fetch the latest version from GitHub:

```bash
claude plugin install claude-stack
```

This command is silent on both success and failure. Step 3 confirms it worked.

## Step 3: Verify

Run the verify script if on the dev path:

```bash
./verify
```

If on the user path (no verify script available), run the checks inline:

```bash
python3 -c "
import json, os, sys
mp = os.path.expanduser('~/.claude/plugins/known_marketplaces.json')
ip = os.path.expanduser('~/.claude/plugins/installed_plugins.json')
ok = True

if os.path.exists(mp):
    data = json.load(open(mp))
    if 'claude-stack' in data:
        print('  marketplace: registered')
    else:
        print('  marketplace: NOT registered')
        print('    fix: claude plugin marketplace add joryeugene/claude-stack')
        ok = False
else:
    print('  marketplace: NOT registered')
    print('    fix: claude plugin marketplace add joryeugene/claude-stack')
    ok = False

if os.path.exists(ip):
    data = json.load(open(ip))
    entry = data.get('plugins', {}).get('claude-stack@claude-stack', [])
    if entry:
        path = entry[0]['installPath']
        import glob
        skills = len(os.listdir(os.path.join(path, 'skills'))) if os.path.isdir(os.path.join(path, 'skills')) else 0
        hooks = len(glob.glob(os.path.join(path, 'hooks', '*.py')))
        print(f'  plugin:      installed ({skills} skills, {hooks} hooks)')
        print(f'  path:        {path}')
    else:
        print('  plugin:      NOT installed')
        print('    fix: claude plugin install claude-stack')
        ok = False
else:
    print('  plugin:      NOT installed')
    print('    fix: claude plugin install claude-stack')
    ok = False

print()
if ok:
    print('claude-stack is ready.')
else:
    print('claude-stack is not fully installed. Run the fix commands above.')
    sys.exit(1)
"
```

If verification fails, print the fix commands and stop. Do not proceed to Step 4.

## Step 4: Optional extras (dev path only)

If on the dev path, ask the user:

> The `./setup` script installs optional extras: statusline, mcp-use CLI, and MCP presets. Run it?

Only proceed if the user says yes:

```bash
./setup
```

Skip this step entirely on the user path.

## Step 5: Summary

Print what was done:

- Update method (dev sync or marketplace reinstall)
- Skill and hook counts from the verify output
- Install path
- Remind: "Start a new session to pick up changes."
