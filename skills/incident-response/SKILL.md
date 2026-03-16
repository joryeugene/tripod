---
name: incident-response
description: Use when production is down, an alert fires, or an incident needs triage. Covers severity classification, communication, timeline tracking, and blameless postmortem with 5 whys. Also use after resolution to write the postmortem.
user-invocable: true
---

# Incident Response

Three modes. Invoke with `/incident-response triage`, `/incident-response update`, or `/incident-response postmortem`. If no argument, ask which phase.

---

## Triage

First contact with the incident. Classify, scope, and assign.

### Severity Classification

| Level | Criteria | Response |
|-------|----------|----------|
| SEV1 | Service down, all users affected | Immediate, all hands |
| SEV2 | Major feature degraded, many users affected | Within 15 minutes |
| SEV3 | Minor feature issue, some users affected | Within 1 hour |
| SEV4 | Cosmetic or low-impact issue | Next business day |

### Triage Checklist

1. **What is broken?** Name the specific system, endpoint, or feature.
2. **Who is affected?** All users, a segment, internal only?
3. **When did it start?** Check deploy logs, monitoring, and alerts for the inflection point.
4. **What changed?** Recent deploys, config changes, dependency updates, infrastructure changes.
5. **Assign severity.** Use the table above. When in doubt, go one level higher.
6. **Assign roles.** Incident commander (owns the timeline), communicator (owns status updates), responders (own the fix).

### Output

```markdown
## Incident: [Title]
**Severity:** SEV[1-4] | **Status:** Investigating
**Impact:** [Who/what is affected]
**Started:** [Timestamp or best estimate]
**Commander:** [Name] | **Comms:** [Name]

### What We Know
[Facts only. No speculation.]

### Recent Changes
- [Deploy/config/infra change and timestamp]

### Immediate Actions
1. [First action]
2. [Second action]

### Next Update
[Time of next status update]
```

---

## Update

Status updates during an active incident. Factual, regular cadence.

### Update Protocol

Post updates at a fixed cadence based on severity:

| Severity | Update cadence |
|----------|---------------|
| SEV1 | Every 15 minutes |
| SEV2 | Every 30 minutes |
| SEV3 | Every hour |
| SEV4 | Daily |

### Update Format

```markdown
## Incident Update: [Title]
**Severity:** SEV[X] | **Status:** Investigating | Identified | Monitoring | Resolved
**Last Updated:** [Timestamp]

### Current Status
[What we know now that we did not know at the last update]

### Actions Taken Since Last Update
- [Action and result]

### Next Steps
- [What is happening next and estimated time]

### Timeline
| Time | Event |
|------|-------|
| [HH:MM] | [Event] |
```

### Communication Rules

- State facts. Do not speculate.
- Include what you know, what you have done, and what comes next.
- If you have no new information, say so. "No change since last update. Still investigating X." is a valid update.
- Never say "we're looking into it" without specifying what you are looking into.

---

## Postmortem

After the incident is resolved. Blameless analysis focused on systems and processes.

### 5 Whys

Trace from symptom to root cause. Each "why" goes one layer deeper.

1. Why did [the symptom occur]? Because [cause 1].
2. Why did [cause 1] happen? Because [cause 2].
3. Why did [cause 2] happen? Because [cause 3].
4. Why did [cause 3] happen? Because [cause 4].
5. Why did [cause 4] happen? Because [root cause].

Stop when you reach something that is fixable with a process or system change. If the answer is "human error," go one more level: why did the system allow that error?

### Postmortem Format

```markdown
## Postmortem: [Incident Title]
**Date:** [Date] | **Duration:** [X hours] | **Severity:** SEV[X]
**Authors:** [Names] | **Status:** Draft | Final

### Summary
[2-3 sentence plain-language summary. A non-engineer can read this.]

### Impact
- Users affected: [count or segment]
- Duration of impact: [time]
- Business impact: [revenue, SLA, reputation if quantifiable]

### Timeline
| Time (UTC) | Event |
|------------|-------|
| [HH:MM] | [Trigger event] |
| [HH:MM] | [Alert fired / user report] |
| [HH:MM] | [Triage started] |
| [HH:MM] | [Root cause identified] |
| [HH:MM] | [Fix deployed] |
| [HH:MM] | [Monitoring confirmed resolution] |

### Root Cause
[Detailed technical explanation of what caused the incident]

### 5 Whys
1. Why? [symptom] -> [cause]
2. Why? [cause] -> [deeper cause]
3. Why? [deeper cause] -> [deeper still]
4. Why? [deeper still] -> [systemic issue]
5. Why? [systemic issue] -> [root cause]

### What Went Well
- [Detection was fast because X]
- [Rollback worked because Y]

### What Went Poorly
- [Detection was slow because X]
- [Communication gaps because Y]

### Action Items
| Action | Owner | Priority | Due |
|--------|-------|----------|-----|
| [Specific fix] | [Person] | P0 | [Date] |
| [Prevention measure] | [Person] | P1 | [Date] |
| [Monitoring improvement] | [Person] | P2 | [Date] |

### Lessons Learned
[What systemic changes prevent recurrence]
```

### Blameless Standard

Postmortems examine systems, not people. Replace "X forgot to" with "the system did not prevent" or "the process did not catch." If the fix is "be more careful," the analysis is not done. The fix must be structural: a check, a gate, a test, a monitor.

---

## Artifact

After completing the postmortem, write it to disk:

```
docs/incidents/postmortem-YYYY-MM-DD-<title>.md
```

Where `<title>` is 2-4 words in kebab-case derived from the incident (e.g., `database-connection-exhausted`, `payment-service-timeout`). Derive it from the incident title.

Use the Write tool to create the file with the full postmortem content. Print the path after writing: `Saved: docs/incidents/postmortem-YYYY-MM-DD-<title>.md`

Triage and update outputs are ephemeral (Slack/status page); only the postmortem is saved.

---

## Anti-Patterns

- Speculating in status updates. State facts or say "investigating."
- Skipping the timeline. Reconstructing events from memory after resolution loses critical details. Log timestamps as events happen.
- Assigning blame in postmortems. "Human error" is not a root cause. The system that allowed the error is.
- Stopping the 5 whys at the first comfortable answer. If the root cause does not suggest a structural fix, go deeper.
- Skipping the postmortem because the fix was "obvious." Obvious fixes still need prevention measures documented.

## The Floor

Incidents reveal what systems actually do under stress, not what they were designed to do. The triage phase contains the blast radius. The communication phase keeps stakeholders informed without speculation. The postmortem phase turns the incident into a structural improvement. Each phase serves a different audience and a different timescale. Skipping any one of them trades short-term convenience for long-term fragility.
