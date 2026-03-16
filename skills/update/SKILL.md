---
name: update
description: Install or update tripod and sync the plugin cache. Use when the user says "sync tripod", "update tripod", "install tripod", or "set up tripod".
user-invocable: true
---

# tripod Update

Install tripod from scratch or bring an existing installation up to date. Walk through each step, verifying as you go.

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
if 'tripod@tripod' in data.get('plugins', {}):
    print('installed')
else:
    print('not-installed')
"
```

If `not-installed` and on the user path, tell the user to run:

```
claude plugin marketplace add joryeugene/tripod
claude plugin install tripod
```

Then re-run `/update` after those commands complete.

## Step 2: Update

### Dev path

Run the sync script from the repo directory:

```bash
./sync
```

This copies skills, hooks, and config from the repo into the plugin cache. It also auto-bumps `plugin.json` and `marketplace.json` to match the latest git tag, and migrates the cache path if the version changed.

### User path

Re-fetch the latest version from GitHub:

```bash
claude plugin install tripod
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
    if 'tripod' in data:
        print('  marketplace: registered')
    else:
        print('  marketplace: NOT registered')
        print('    fix: claude plugin marketplace add joryeugene/tripod')
        ok = False
else:
    print('  marketplace: NOT registered')
    print('    fix: claude plugin marketplace add joryeugene/tripod')
    ok = False

if os.path.exists(ip):
    data = json.load(open(ip))
    entry = data.get('plugins', {}).get('tripod@tripod', [])
    if entry:
        path = entry[0]['installPath']
        import glob
        skills = len(os.listdir(os.path.join(path, 'skills'))) if os.path.isdir(os.path.join(path, 'skills')) else 0
        hooks = len(glob.glob(os.path.join(path, 'hooks', '*.py')))
        print(f'  plugin:      installed ({skills} skills, {hooks} hooks)')
        print(f'  path:        {path}')
    else:
        print('  plugin:      NOT installed')
        print('    fix: claude plugin install tripod')
        ok = False
else:
    print('  plugin:      NOT installed')
    print('    fix: claude plugin install tripod')
    ok = False

print()
if ok:
    print('tripod is ready.')
else:
    print('tripod is not fully installed. Run the fix commands above.')
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
