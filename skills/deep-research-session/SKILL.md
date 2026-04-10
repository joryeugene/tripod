---
name: deep-research-session
description: This skill should be used when the user gives sustained time for research, spec-writing, ideation, or deep planning. Triggers on "we have X hours", "all night", "take your time", "I'm going to sleep, keep working", "don't stop early", "go deep on X", or any indication the user wants full use of a time window. Covers planning, clock discipline, tier structure, depth standards, pivot protocol, and quality bar.
---

# Deep Research Session

Use when a user gives you sustained time (1+ hours) for research, spec-writing, ideation, or
deep planning. The skill is not about one task. It is about using the full time.

## The Contract

The user gave you time. Use all of it. Stopping early is a failure.
A session with 5 hours remaining that produces 3 specs in 20 minutes and then asks "what next?"
is a failure. Produce 20 specs. Go deeper. Find the research. Write the engineering plans.
The user gave you a gift. Honor it.

---

## CLOCK LAW (Non-Negotiable)

```bash
date
```

Run this first. Run it at the start of every iteration. Record the exact output.

An agent will write: "The time is probably around 04:00-05:00 based on session progress."
This is fabrication. Session length is not wall time. The agent has no internal clock.

The rule: run `date`, read the output, use that number. No estimation. No inference. No guessing.
If you did not run `date`, you do not know what time it is.

Without this, agents estimate confidently. They are always wrong.

---

## Activation

When the user indicates a sustained time window:
- "we have X hours"
- "all night"
- "take your time"
- "I'm going to sleep, keep working"
- "don't stop early"
- any combination of these

Do NOT wait for permission. Activate immediately.

---

## Step 1: Check the Clock

```bash
date
```

Record the current time. Calculate the end time. Write it in the tracker. This is not optional.

---

## Step 2: Create the Tracker

Create `docs/plans/YYYY-MM-DD-session-tracker.md` (or update if it exists):

```markdown
# Session Tracker

Start: HH:MM [timezone]
End:   HH:MM [timezone] (X hours)
Remaining: X hours

## Completed
(fill as you go)

## Queue
TIER 1: [highest value, do first -- what the user explicitly asked for]
TIER 2: [what naturally follows from tier 1]
TIER 3: [depth -- more research, more engineering specificity]
TIER 4: [synthesis -- tie everything together, update docs]

## Time Log
| Start | End | Task | Output |
|-------|-----|------|--------|
```

Update the tracker at the start of every work block with the exact `date` output and what is next.

---

## Step 3: Plan Generously

The mistake: planning conservatively because "this will take hours."
The truth: output speed is higher than expected. Plan 4x what seems achievable.

For a 6-hour session, plan 12-20 documents. For a 2-hour session, plan 6-8.
Each document is a spec, an engineering plan, a research synthesis, or a design study.

**Tier structure:**
- TIER 1: What the user explicitly asked for. Do these first.
- TIER 2: The logical next things -- what naturally follows from tier 1.
- TIER 3: Depth -- what needs more research, more engineering specificity.
- TIER 4: Synthesis -- tie everything together, update docs, write the commit message.

If the user gives feedback mid-session, rebuild the queue around what they said.
Their words reveal what matters. Pivot to that. Do not finish the old plan if they show a better one.

---

## Step 4: Execute

Work through tiers in order. For each item:

1. **Read first.** Check what already exists (Glob, Read). Do not duplicate.
2. **Go deep.** Surface-level specs are not acceptable. Every spec should have:
   - The philosophy (why this matters)
   - The design decisions (what was rejected and why)
   - The implementation (file-level changelist or code examples)
   - The test matrix (how to know it works)
3. **Write with conviction.** No hedging. No "might." "Will" because you know.
4. **Update the tracker.** Every completed item gets a time log entry.

Between tiers: run `date`. Adjust.

When a tier completes and time remains: generate the next tier. There is always more.
Go deeper on what was done. Find edge cases. Write the tests. Improve the docs.
Never stop because a list is exhausted. Lists are starting points, not ceilings.

---

## Step 5: The Pivot Protocol

If the user says something mid-session -- even one sentence -- treat it as a priority interrupt.
Their message reveals more about what matters than any plan made in advance.

Common signals:
- **Correction**: they told you something you got wrong. Fix it immediately, then continue.
- **Redirection**: they pointed at something more important. Pivot entirely.
- **Depth request**: "go deeper," "all the way to the core" -- stop breadth work, go deep on this.
- **Story / context**: they shared personal experience. This reveals the real product insight. Extract it.

When the user shares a personal story or shows you something concrete, stop and extract the insight.
Ask one targeted question if needed. Then build from that.

---

## Anti-Patterns

**Estimating the time without running `date`.** Run the command. Read the output. Use that number.

**The premature summary**: "Here's what I've done so far..." before time is up.
Do not summarize. Keep building.

**The conservative plan**: Planning 3 things when you can do 15.

**The abandoned tier**: "I'll come back to TIER 3 if there's time." There is always time.
Plan it. Execute it.

**The early stop**: Finishing TIER 1 and asking "what next?" when TIER 4 still exists.
Look at the tracker. There is always a next thing.

**Surface-level specs**: A spec without philosophy, rejected alternatives, and a test matrix
is a list. Lists are not specs.

---

## Output at Session End

When time is actually up (or the user returns):

1. Update the tracker with final entries
2. List every document produced with one-line descriptions
3. State the implementation priority order (what to build first)
4. Commit if appropriate

Do not ask "should I commit?" if the user told you to work autonomously. Look at the clock.
If time remains, keep working.

---

## The Real Standard

A good session feels like coming back from a long dive.
The researcher went under, found something, came back with it.
Not "I looked around for a while." Found something. Brought it back.

Each spec should feel like a find.
Each engineering plan should feel like a map.
Each design study should feel like a discovery.

If it does not feel like that, go deeper.
