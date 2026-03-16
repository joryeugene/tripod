---
name: impeccable-design
description: Audit any application's visual identity and generate a distinctive design direction that passes the AI slop test.
---

# Impeccable Design

Derives a distinctive visual direction from the semantic identity of any application, then produces concrete design tokens, palette, typography, and spatial choices that pass the AI slop test.

Inspired by [Impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (Apache 2.0).

## The AI Slop Test

The critical quality gate. If someone looks at the interface and immediately thinks "AI made this," the design has failed. The 2024-2025 fingerprints that trigger this reaction:

- Purple-to-blue gradients (#7c3aed, #6366f1, violet-600 family)
- Inter or system-ui as the only typographic choice
- Cards nested inside cards inside cards
- Gray text on colored backgrounds (washed out, dead contrast)
- Pure black (#000) and pure white (#fff) everywhere
- Glassmorphism, sparklines as decoration, generic drop shadows
- Bounce/elastic easing on everything
- Centered text with uniform sizing (nothing is more important than anything else)
- Hero metrics with gradient backgrounds
- Thick-bordered cards with massive border-radius
- Layout templates repeated identically across every section
- Massive icons used as section decoration

These patterns are not inherently bad. They became slop through overuse in AI-generated output. The test is about distinctiveness, not individual choices.

## How This Skill Works

### Phase 1: Semantic Identity Audit

Before touching any color or font, understand what the app IS. Read the codebase to answer:

1. **Name etymology:** What does the app name mean? What does it evoke? ("ClearBuzz" = clarity + bee/honey/warmth. "Stripe" = clean lines. "Linear" = direct paths.)
2. **Domain:** What world does this app live in? (Health, finance, creativity, productivity, social, developer tools)
3. **Emotional register:** What should users feel? (Calm confidence, urgent energy, playful discovery, professional trust, warm encouragement)
4. **Audience:** Who uses this? (Developers want density and keyboard shortcuts. Consumers want simplicity. Enterprise wants trust signals.)
5. **Competitive landscape:** What do competing apps look like? The goal is to look nothing like them.

This phase produces a **Design Brief** (2-3 sentences) that anchors every subsequent decision.
Example: "ClearBuzz is a cannabis cessation app. The 'buzz' in the name evokes bees and honey.
The emotional register is warm encouragement, not clinical authority. Competing apps use medical
blue/green palettes. Our direction: amber/honey warmth that feels grounded and optimistic."

### Phase 2: Color System

1. **Derive the primary color from the Design Brief.** Not from a trend. Not from a template. From the semantic identity. If the app is about nature, look at actual nature colors. If it is about finance, look at what finance apps do NOT use (that is your opportunity).
2. **Use OKLCH color space** for perceptually uniform palette generation.
3. **Tint your neutrals.** Add a tiny hint (chroma 0.01) of your primary hue to all grays. This creates subconscious cohesion.
4. **Never use pure black or pure white.** Real surfaces always have a color cast. `#000` and `#fff` are tells of default-driven design.
5. **Follow the 60-30-10 rule** for visual weight distribution.
6. **Build light AND dark palettes.** Dark mode requires different decisions, not just inverted values.

Output a complete token set:

```
PRIMARY:       light value, dark value
NEUTRALS:      background, surface, text (9-11 shade scale, tinted)
SEMANTIC:      success, error, warning, info (2-3 shades each)
ACTIVE STATES: selected bg, hover bg, focus ring
```

### Phase 3: Typography

1. **Pick a distinctive display font** if the platform supports custom fonts. Avoid: Inter, Roboto, Open Sans, Lato, Montserrat (overused defaults). Consider: Instrument Sans, Plus Jakarta Sans, Outfit, Onest, Figtree, DM Sans, Fraunces, Newsreader. System font stacks are acceptable for native apps where platform consistency matters more than brand differentiation.
2. **Establish a modular scale.** Five sizes handle most interfaces: xs, sm, base, lg, xl. Use a ratio (1.25 major third, 1.333 perfect fourth) rather than arbitrary values.
3. **Set measure constraints.** Body text maxes out at 65ch. This is non-negotiable for readability.
4. **Fluid sizing** via `clamp()` for web, or responsive scaling for native.

### Phase 4: Spatial Design

1. **Choose a base unit** (4px recommended for granularity).
2. **Create visual rhythm** through varied spacing. Tight groupings for related elements, generous separation between sections. Uniform spacing reads as machine-generated.
3. **The squint test:** Blur your vision. Can you still distinguish primary, secondary, and grouped elements? If everything blends together, hierarchy has failed.
4. **Avoid cards-in-cards.** Spacing and typography create grouping. Recursive containers are a sign of complected structure.

### Phase 5: Motion and Interaction

Quick rules:

- 100/300/500 rule for durations (feedback / state change / layout shift)
- Exponential easing, never bounce/elastic
- Only animate transform and opacity
- Eight interactive states per element (default, hover, focus, active, disabled, loading, error, success)
- Undo over confirmation dialogs
- `prefers-reduced-motion` is non-negotiable

### Phase 6: UX Writing

Quick rules:

- Verb + object for button labels ("Save changes" not "OK")
- Error messages answer: what happened, why, how to fix
- Empty states are onboarding moments
- Pick one term and stick with it (Delete vs Remove vs Trash: choose one)

### Phase 7: Implementation

After all decisions are made, produce a concrete implementation plan:

1. **Token file** with every color, font, spacing, and timing value
2. **File-by-file changelist** mapping tokens to specific hardcoded values
3. **Verification checklist** to confirm no old values remain

## Applying to Different Application Types

### Web Apps (React, Vue, Svelte, etc.)

- CSS custom properties for tokens
- OKLCH in CSS (wide browser support since 2023)
- Container queries for component-level responsiveness
- `font-display: swap` for custom font loading

### React Native / Expo

- Theme object with light/dark variants
- Hex colors (OKLCH not supported in RN stylesheets)
- Convert OKLCH values to hex during design, use hex in code
- System font stack via `fontFamily: "System"` or platform-specific

### CLI Tools

- ANSI color mapping
- Unicode block characters for gauges and sparklines
- Terminal width awareness for responsive layout

### Dashboards

- Information density over whitespace
- F1 cockpit principle: all information needed, nothing more
- Semantic color for state communication (green=healthy, red=critical)

## The Audit Report

When auditing an existing app, produce this structured report:

```
## Design Brief
[2-3 sentence identity anchor derived from name + domain + audience]

## AI Slop Score
[0-10, where 0 = completely generic, 10 = unmistakably distinctive]
[List which anti-patterns were found]

## Proposed Direction
[The aesthetic commitment: what this app should feel like]

## Token Set
[Complete color, typography, spacing values]

## Migration Plan
[File-by-file changelist with old value -> new value]
```

## The Floor

Visual identity is not decoration. It is the first signal a user reads, and it communicates before a single word does. An interface that looks like every other AI-generated output signals that no one made a deliberate choice. The semantic identity audit forces that choice: derive the visual language from what the application IS, not from what was easy to reach for. Every token in the final set should be traceable back to the Design Brief.
