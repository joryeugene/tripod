---
name: verification-workflow
description: After every code change, follow this cycle: validate assumptions, make change, prove it works, show evidence.
---

# Verification Workflow

Every code change follows this cycle: validate assumptions, make change, prove it works, show evidence.

## Pre-Change: Validate Assumptions

Before writing any code:

- curl the API endpoint you'll call and get actual field names
- Read the ENTIRE file you'll modify (don't assume structure)
- Verify commands exist (`which`, `--version`) before using them
- Check types match expectations (don't over-engineer from imagination)

## During Change: One at a Time

- Make one change, verify, then make the next change
- Never batch 5 changes and test all at once
- If you can't test incrementally, stop and figure out how

## Post-Change: Prove It Works

For every change, show:

1. **Command run:** the exact command executed
2. **Actual output:** paste the real output (not "should work")
3. **Success indicator:** "All tests passed" or "Build successful"

Encode the verified behavior as a permanent test with `/tdd` so the proof survives future sessions.

## Evidence Standards

- BANNED: "should work", "looks correct", "appears working"
- REQUIRED: "WILL work because [show exact field mapping + data + proof]"
- Every claim needs: API response + code reference + expected output
- If you haven't seen it work, don't claim it works

## When You Can't Verify

Say explicitly: "I cannot verify this works because [reason]. Please verify by running [command]."
Never claim success without proof. Never use checkmarks without testing.

## Anti-Patterns

- **Batch verification:** Making 5 changes then testing all at once. When something breaks, you don't know which change caused it.
- **Defensive imagination:** "The API might return X or Y, so handle both." Check what it actually returns first.
- **Claiming success without testing:** Using checkmarks or "looks correct" without running the code.
- **Complex investigation before simple checks:** Launching a full debugging plan when the issue is a typo in a field name.
- **Repeating failed approaches:** If an approach fails, analyze why before retrying the same thing.

## The Floor

Every code change is either verified or unverified. There is no middle ground. "Looks correct" and "should work" are unverified claims. Verified means a command was run, output was observed, and the output matched expectation. The discipline of showing evidence after every change is not overhead. It is the only way to know whether the work is done.
