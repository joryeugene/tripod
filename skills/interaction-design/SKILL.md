---
name: interaction-design
description: Use when designing how a UI feels to use, not how it looks. Covers discoverability, mode communication, feedback timing, keyboard-first UX, empty states, and information density. Companion to visual-design.
---

# Interaction Design

Interaction design answers "what does it feel like to use?" Visual design answers the color and typography question. This skill answers the behavioral question: can users find what they need, understand where they are, recover from mistakes, and move faster over time?

## The Discoverability Test

Three rules that function as a quality gate before any UI ships:

- **10s rule**: A new user should know what to do within 10 seconds of landing on any screen. If they cannot, the affordances are wrong or buried.
- **Mode escape rule**: Users must always know how to leave the current mode. A trapped user is a frustrated user.
- **100ms feedback rule**: Every action must produce a visible response within 100ms. A silent UI feels broken even when it is not.

Anti-patterns that fail this test:

- Disabled buttons with no explanation (user cannot tell why or how to enable)
- Modal confirmation dialogs for reversible actions (undo is better)
- Hidden modes with no indicator (user lost, no escape)
- Trapped focus without an escape affordance
- Uniform empty states that teach nothing

## Progressive Disclosure

Show what is needed now. Surface more as the user demonstrates readiness.

Three layers:

1. **First-run**: Guided affordances, visible hints, reduced noise. Everything labeled.
2. **Regular user**: Hints fade after N interactions. Power features emerge. Keyboard shortcuts appear on hover.
3. **Power user**: Dense mode. Hints gone. Muscle memory owns the interaction.

Implementation pattern: track feature usage counts in local state. Degrade hints after threshold. Never remove hints permanently. A returning user who forgot is not a power user.

## Mode Communication

Every mode change requires a visible indicator. Users must never guess where they are.

Patterns that work:

- Mode bar with active mode label and available actions as contextual pills
- Breadcrumb trail for nested modes
- Color shift at the border or background level (subtle, not alarming)
- ESC always exits to the previous mode (never to a different mode)

A persistent mode bar (bottom or top) shows the current mode label and available actions as contextual pills. Pills change with context. The mode name is always visible, never inferred.

Anti-patterns:

- Color as the only mode indicator (fails accessibility)
- Mode changes triggered by keyboard shortcuts without visual confirmation
- Nested modes with no breadcrumb

## Keyboard-First UX

The keyboard is the power interface. Design for it from the start, not as an afterthought.

Vim grammar: operator + motion. `d w` = delete word. Composable actions beat modal menus.

Discoverability ladder:

1. Hover tooltips show the shortcut on first encounter
2. Shortcut shown in the button or action label
3. Command palette as the escape hatch for everything else (Linear/Raycast model)
4. `?` always shows the shortcut map

Hesitation detection: if a user hovers for more than 800ms without acting, show the shortcut. They are looking for the keyboard path.

## Feedback Timing

Three timing tiers that map to user perception:

| Window | What it means | Pattern |
|--------|--------------|---------|
| 0-100ms | Instant, user feels immediate | Optimistic UI, visual state change before confirmation |
| 100-300ms | Fast, user feels responsive | Show spinner or skeleton |
| 300-1000ms | Noticeable, user notices delay | Progress indicator with estimated completion |
| 1000ms+ | Slow, user questions if it worked | Toast with cancel option |

Undo over confirm: never ask "Are you sure?" for reversible actions. Do it and offer undo. Confirmation dialogs interrupt flow. Undo restores trust.

Toast patterns: bottom-right, 3-second auto-dismiss, action available (undo, view, dismiss). Never stack more than 3.

## Spatial Memory

Users build mental maps of where things live. Violate the map and they lose trust.

Rules:

- Primary actions stay in the same position across all states (loaded, empty, error)
- Animation direction must be consistent: drill-in goes right or down, back goes left or up
- Panels that appear always animate from the edge they logically come from
- Never shift content unexpectedly to accommodate a new element. Insert in place.

The squint test for spatial memory: blur your vision. Can you still find the primary action from memory alone? If yes, the spatial design is stable.

## Empty States

Every empty state is an onboarding moment. It has one job: teach the next action.

Pattern:

- Name what is missing ("No tasks yet")
- Explain why it matters ("Tasks track what needs doing")
- Show how to create one (button, shortcut, or gesture)
- Make the hint contextual (the hint changes based on where in the app the empty state appears)

Anti-patterns:

- Generic "Nothing here yet" with no action
- Empty states that show only an illustration (decoration, not direction)
- Identical empty state copy across different contexts

## Information Density

Default to density. Let users zoom.

The F1 cockpit principle: all information the user needs, nothing more. Every element earns its space or is removed.

Three levels:

1. **Dense default**: all data visible, compact rows, no wasted whitespace
2. **Focused view**: single item expanded, peripheral data faded
3. **Progressive detail**: click to reveal more depth on demand

Anti-patterns:

- Padding-heavy layouts that hide data count ("only 3 items visible when 20 fit")
- Card grids that waste horizontal space on whitespace
- Infinite scroll without a count ("how many total?")

## Contextual Actions

Show what is possible. Hide what is impossible. Change both with mode.

Implementation:

- Action set changes based on selection state (nothing selected vs one selected vs many selected)
- Destructive actions require confirmation only when irreversible and bulk
- Disabled states always explain why (tooltip with unmet condition)

Pattern: the action bar is always present, but its contents are context-driven. An empty selection shows "select items to act." A single selection shows item-specific actions. A multi-selection shows bulk actions only.

## Shared Environment Agency

When AI agents work in the same interface as humans, the interaction model must treat them as residents, not visitors.

Principles:

- **Traces that outlast sessions**: agents leave visible artifacts (notes, labels, state changes) that humans can read and act on
- **Co-authored identity**: work done by an agent is attributed but not hidden ("Claude organized these" as a visible label, not a background event)
- **Symmetric affordances**: if a human can move a card, the agent can move a card. The same actions, the same constraints.
- **No invisible mutations**: agents never change state without a visible trace in the UI

This section applies when building interfaces where Claude Code agents and humans share a workspace.

## The Cutting Edge

Interfaces worth studying for each principle:

| Principle | Reference |
|-----------|-----------|
| Spatial interfaces | Bret Victor, Explorable Explanations |
| Local-first state | Ink & Switch, Local-First Software |
| Composable keyboard grammar | Helix editor, operator + motion model |
| Command palette as escape hatch | Linear, Raycast (`Cmd+K` for everything) |
| Progressive materialization | Ghost card pattern, element appears at destination before full data loads |
| Mode-aware empty states | Column-contextual hints that teach the system model |

## The Audit Report

When invoked as an audit, produce this output:

```markdown
## Interaction Audit: [Page/Feature Name]
**Date:** [Date]

### Discoverability Score
- 10s rule: Pass / Fail -- [what a new user sees in 10 seconds]
- Mode escape: Pass / Fail -- [how to exit current state]
- 100ms feedback: Pass / Fail -- [what happens immediately after action]

### Critical Issues (fix before ship)
| # | Principle | Issue | Location | Fix |
|---|-----------|-------|----------|-----|
| 1 | [Discoverability] | [Description] | [Component] | [Specific fix] |

### Improvements (fix before next release)
| # | Principle | Issue | Location | Fix |
|---|-----------|-------|----------|-----|

### Keyboard Coverage
| Action | Shortcut | Discoverable | In palette |
|--------|---------|--------------|------------|

### Empty State Audit
| State | Teaches next action | Contextual | Pass |
|-------|---------------------|------------|------|
```

## The Floor

The visual layer answers what an interface looks like. Interaction design answers what it feels like to use. Both questions must be resolved before any UI ships. A visually polished interface with trapped focus and silent feedback is a broken interface. An interaction model without visual coherence is a confusing one. Run `/visual-design` for the first question. Run `/interaction-design` for the second. Neither replaces the other.
