---
name: browser-testing
description: Adversarial browser testing. Use when testing UI behavior, verifying network requests, checking console errors, filling forms, or handling dialogs. The goal is finding bugs, not confirming happy paths.
---

# Browser Testing

## The Fundamental Rule

Your job is to find bugs, not confirm that things work.

Happy path testing finds zero bugs by definition. The user already knows the happy path works. They demoed it. Adversarial testing finds the bugs that matter: error states that show wrong UI, sequences that corrupt state, inputs that break layout, flows that silently do nothing.

**Before any test session, write down three hypotheses about where bugs might be.** Then go find evidence.

---

## Mandatory Pre-Flight

Always do this before testing anything:

```
1. Navigate to the page
2. browse console                  # MUST be empty of errors/warnings
3. browse network                  # note which requests fired on load
4. browse snapshot                 # baseline accessibility tree
```

If the console has errors on load, file them as bugs before testing anything else. Console errors on load are bugs regardless of whether the feature "works."

---

## Adversarial Test Protocol

For every user action, test in this order:

### 1. Error path first

Before testing "does submit work," test "does submit fail correctly":
- Submit with empty required fields
- Submit with too-short content (1 char when minimum is 10)
- Submit with invalid format (no `{{VAR}}` when the pattern is expected)
- Submit the same thing twice (idempotency)

### 2. Cancellation

- Start the action, then cancel
- Close the modal mid-flow
- Navigate away during an in-flight request
- Press Escape at each step of a multi-step flow

### 3. Second action after first

The first action succeeds. Now:
- Do the same action again (double submit, double save, double approve)
- Do the reverse action (save then unsave)
- Do a conflicting action (open a different modal while one is loading)
- Check that the previous success is still reflected correctly after the second action

### 4. Data edge cases

- Empty string where text is expected
- Single character
- 10,000 characters (will layout break?)
- Unicode, emoji, RTL characters
- `<script>alert(1)</script>` (not for injection since the ORM sanitizes, but to test visual breakage)
- `{{}}`, `{{ }}`, six `{{VAR}}` patterns in a row

### 5. Sequence corruption

- Do action A, then B, then verify A's result is still correct
- Open modal, interact, close, reopen: is state reset?
- Apply filter, perform action, clear filter: did the action persist?
- Search, click result, go back: is search state preserved?

### 6. Race conditions

- Click the same button twice rapidly
- Click submit while a previous request is still in flight
- Open the same modal from two places simultaneously

---

## Console Is the Bug Detector

Every meaningful browser interaction should be followed by:

```
browse console
```

You are looking for:
- `TypeError: Cannot read property X of undefined`: null value where something expected an object
- `Warning: Each child in a list should have a unique "key" prop`: React rendering bug, keys missing
- `Unhandled Promise Rejection`: async operation failed silently, user saw nothing
- Any 4xx/5xx network errors: API failure the UI may or may not have surfaced to the user
- `Warning: Cannot update a component while rendering a different component`: React state update bug

If the console is clean after every interaction, say so explicitly. If it has errors, file them even if the UI looked fine.

---

## Network Is the Ground Truth

The UI can lie. The network cannot.

After any mutation (submit, approve, save, edit), verify:

```
browse network
```

Check:
- Did the expected API call fire?
- What status code came back?
- Is the request body what you expect?
- Did any unexpected calls fire (double submit, duplicate request)?

A button that shows a success toast but sent no API request is a bug. A button that shows an error toast but the API returned 200 is also a bug.

---

## Specific Bug Patterns to Hunt

### Stale state after close and reopen

```
1. Open modal A
2. Interact (change tab, fill field, scroll down)
3. Close modal A
4. Open modal A again
5. Verify: is it reset to initial state?
```

Common bug: tab stays on the last-visited tab, not the default. Form retains previous input.

### Success without effect

```
1. Perform action (approve, save, submit)
2. Verify toast fires
3. Verify the underlying list or count actually updated (browse js to read DOM, not screenshot)
4. Reload the page
5. Verify the change persisted
```

Common bug: toast fires but the list does not re-fetch. Optimistic update shows success but server rejected it.

### Error message swallowing

```
1. Trigger a known error (approve your own submission, submit a duplicate name)
2. Verify: does an error toast appear?
3. Verify: does the error message describe the actual problem?
4. Verify: is the form or modal still accessible after the error?
```

Common bug: error toast says "Failed to decline" with no explanation. Modal closes on error, discarding the user's work.

### Filter state corruption

```
1. Apply a filter (Topic: Communication)
2. Perform an action in the filtered view
3. Clear the filter
4. Verify: the action's result is visible in the unfiltered view
5. Re-apply the filter
6. Verify: the filter still works correctly
```

Common bug: clearing the filter does not re-fetch. Filtered view shows stale data.

### Empty state transition

```
1. Find a list with items
2. Perform action that should reduce the count (decline all, remove all saved)
3. Verify: proper empty state is shown, not an empty container
4. Verify: no layout breaks, no "undefined" text, no skeleton stuck loading
```

### Loading race

```
1. Trigger an action that takes time (filter by topic with latency)
2. While loading, trigger another action
3. When both resolve, verify the correct result is shown
```

Common bug: second response overwrites first, showing wrong data for the current filter.

### Modal focus trap

```
1. Open a modal
2. Press Tab repeatedly through all focusable elements
3. Verify: focus stays inside the modal (does not escape to the page behind)
4. Verify: Escape closes the modal
5. Verify: focus returns to the trigger element after close
```

### Disabled state bypass

```
1. Find a disabled button
2. browse js "document.querySelector('[disabled]').removeAttribute('disabled')"
3. Click the now-enabled button
4. Verify: the server rejects the request via authorization, not just the UI guard
```

---

## The Evidence Standard

A test is complete only when you have all three:

1. **DOM evidence:** `browse js "document.querySelector('.toast').textContent"` (not a screenshot)
2. **Network evidence:** `browse network` shows the expected API call with the correct status
3. **Persistence evidence:** reload the page and verify the change is still there

A screenshot alone is not evidence. A toast firing is not evidence. Evidence means the server accepted the mutation and the client reflects it correctly after a fresh load.

---

## Tool Selection

| Situation | Tool |
|-----------|------|
| Logged-in session from real Chrome | Chrome DevTools MCP with `--autoConnect` |
| Fresh session, form filling, E2E flows | Playwright MCP |
| Fast iteration, many checks, element refs | browse CLI |

**browse CLI** is preferred for adversarial testing:
- 100ms per call vs seconds for MCP round-trips
- `browse snapshot -D` shows exactly what changed (diff mode)
- Element refs fail fast on stale DOM instead of hanging
- `browse console` gives clean output

**Setup:**
```bash
# browse CLI (persistent daemon)
cd ${CLAUDE_PLUGIN_ROOT}/browse && ./setup
# Binary: ${CLAUDE_PLUGIN_ROOT}/browse/dist/browse
```

For Chrome DevTools MCP with an authenticated session:
1. Enable `chrome://inspect/#remote-debugging` in Chrome
2. Add `--autoConnect` to the chrome-devtools entry in `.mcp.json`
3. Restart the Claude Code session

---

## Browse CLI Reference

**Navigation:** `goto`, `back`, `forward`, `reload`, `url`

**Reading:** `text`, `html`, `links`, `forms`, `snapshot`, `snapshot -D` (diff), `snapshot -s <selector>` (scoped)

**Interaction:** `click [selector|@ref]`, `fill <selector|@ref> <text>`, `type <text>`, `press <key>`, `select <selector|@ref> <value>`, `hover`, `scroll [direction] [amount]`

**Debugging:** `console`, `network`, `js <expr>`, `dialog`, `cookies`, `storage`, `css <selector>`, `attrs <selector>`

**Visual:** `screenshot`, `screenshot --clip <selector>`, `responsive`

---

## Playwright MCP Reference

**Navigation:** `browser_navigate`, `browser_go_back`, `browser_go_forward`, `browser_wait`

**Reading:** `browser_snapshot`, `browser_take_screenshot`, `browser_get_text`

**Interaction:** `browser_click`, `browser_type`, `browser_select_option`, `browser_hover`, `browser_press_key`, `browser_drag`

**Tabs:** `browser_tab_list`, `browser_tab_new`, `browser_tab_select`, `browser_tab_close`

Always re-snapshot after page mutations. Stale refs from a previous snapshot target the wrong element and fail silently.

---

## Keyboard Testing

`press_key` fires real DOM events. `type_text` injects the final value, bypassing event listeners. For keyboard shortcut testing, always `press_key`. Otherwise the handler never runs and you cannot catch the bug.

Chrome DevTools `press_key` does not synthesize shift modifiers. Use `evaluate_script` to dispatch synthetic events when modifier keys matter:

```javascript
document.dispatchEvent(new KeyboardEvent('keydown', {
  key: 'L', code: 'KeyL', shiftKey: true, bubbles: true, cancelable: true
}));
```

---

## Verifying Async State

After mutations, wait before asserting. The DOM may not update synchronously:

```javascript
// browse js:
new Promise(resolve => setTimeout(() => {
  resolve(document.querySelector('.stat-card .count')?.textContent)
}, 500))
```

Checking the DOM directly is more reliable than reading JS state variables, which may not reflect what the DOM shows.

---

## Binary/Bundle Staleness

When an app bundles its frontend (Python serving inline JS, Electron, packaged CLI), the running binary may NOT match the source. A bug visible in the browser may already be fixed in source. The binary is a snapshot from the last build.

Before concluding a bug is unfixed: rebuild the binary and retest.

```bash
# Python CLI example
uv tool install --force --reinstall .
# Then restart the server and retest
```

If the bug disappears after rebuild without any source changes, the bug was in the stale binary, not the source. The fix was the rebuild.

---

## Bugs That Only Surface Through Real Interaction

These patterns are invisible to unit tests and only appear via browser testing:

**Broken promise chain:** `fetchData()` called without `return` in a `.then()` chain. The next `.then()` fires before the fetch resolves. The UI appears to work (no error) but shows stale data. Fix: always `return fetchData()`.

**Off-by-one index:** An operation always targets index 0 instead of the item the user navigated to. Passes in demos where index 0 is always selected, fails in real use when any other item is focused.

**Double-remove on detached DOM nodes:** Two code paths can remove the same element. The second call throws `NotFoundError`. Guard with `if (inp.parentNode) inp.remove()`. This is idempotent: attached nodes remove, detached nodes do nothing.

---

## What NOT to Do

- Do not screenshot and call it verified. Screenshots are evidence only for layout bugs.
- Do not test the happy path first. Test errors first.
- Do not declare a bug "not reproducible" without checking console, checking network, and trying the exact sequence that triggered it.
- Do not trust that a toast equals success. Check the network call.
- Do not skip mobile viewport. Many layout bugs only appear at 375px.
- Do not mark a test done after one pass. Do the sequence twice.
- Do not assume the second user has the same permissions. Test every protected action with a lower-privilege account.
