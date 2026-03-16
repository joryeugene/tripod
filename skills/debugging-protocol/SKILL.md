---
name: debugging-protocol
description: Systematic protocol for diagnosing broken behavior. Schema mismatch causes 80% of bugs. Use when something isn't showing, isn't working, or is still broken after a fix attempt.
---

# Debugging Protocol

The fastest path from symptom to fix. Schema mismatch causes 80% of bugs.

## Step 1: Schema Alignment Check

Do this first, before any other investigation.

1. Get the actual API response (curl, logs, or network tab).
2. Get the code that reads the data.
3. Compare field names character by character.
4. Identify mismatches: API returns `field_x`, code expects `field_y`.

## Step 2: Data Flow Verification

Trace backwards from the symptom:

1. What field does the component read?
2. What does the API actually return?
3. Where does the chain break?

## Step 3: Proof-Based Fixing

Show BEFORE/AFTER with evidence:

- BEFORE: `agent.display_name` (undefined)
- AFTER: `agent.agent_name` (returns value)
- PROOF: API response contains `agent_name` (show the response)

Once fixed, run `/verification-workflow` to prove the fix holds under the full change cycle.

## Hierarchy of Causes

1. Schema mismatch (80%)
2. Null or missing data (10%)
3. Logic error (5%)
4. Complex state issue (5%)

## Anti-Patterns

- Launching "investigation plans" before checking schema. The data is almost always the problem.
- Saying "working correctly" without verification. Proof is required: show the output.
- Skipping the BEFORE/AFTER structure. Fixes without evidence cannot be confirmed.
- Repeating the same approach after it fails. Stop, get actual data, then try a different path.
- Theorizing about logic errors before verifying field names. Check the data first.

## The Floor

Every debugging session is a hypothesis test, not a narrative. The hierarchy of causes is not decoration: schema mismatch accounts for most failures, and every minute spent theorizing about logic errors before verifying field names is wasted. Get the data first. Compare it against what the code expects. The answer is almost always right there.
