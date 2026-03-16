---
name: accessibility-review
description: Use when auditing a page or component for WCAG 2.1 AA compliance. Covers color contrast, keyboard navigation, screen reader behavior, touch targets, and semantic HTML. Run before shipping any user-facing UI.
user-invocable: true
---

# Accessibility Review

Audit a design or live page against WCAG 2.1 AA. Covers perceivable, operable, understandable, and robust.

---

## WCAG 2.1 AA Checklist

### Perceivable

| Criterion | Requirement | How to check |
|-----------|-------------|--------------|
| 1.1.1 Non-text content | All images have meaningful alt text (or empty alt for decorative) | Inspect every `<img>`, `<svg>`, `role="img"` element |
| 1.3.1 Info and relationships | Structure conveyed semantically, not just visually | Check heading hierarchy (h1-h6), landmark roles, table markup |
| 1.4.3 Contrast (normal text) | Ratio >= 4.5:1 | Measure foreground vs background color |
| 1.4.3 Contrast (large text) | Ratio >= 3:1 (18px+ or 14px+ bold) | Same measurement, different threshold |
| 1.4.11 Non-text contrast | UI components and graphics >= 3:1 against adjacent colors | Check borders, icons, focus rings, form controls |

### Operable

| Criterion | Requirement | How to check |
|-----------|-------------|--------------|
| 2.1.1 Keyboard | All functionality available via keyboard | Tab through every interactive element |
| 2.4.3 Focus order | Logical tab sequence matches visual layout | Tab through and verify order |
| 2.4.7 Focus visible | Clear visible focus indicator on all interactive elements | Tab and verify each element shows focus |
| 2.5.5 Target size | Touch targets >= 44x44 CSS pixels | Measure interactive element dimensions |

### Understandable

| Criterion | Requirement | How to check |
|-----------|-------------|--------------|
| 3.2.1 On focus | No unexpected context changes on focus | Tab to every element, verify no surprise navigation |
| 3.3.1 Error identification | Errors described in text, not just color | Trigger form validation, check error messages |
| 3.3.2 Labels | All inputs have visible labels or instructions | Check every form field for associated label |

### Robust

| Criterion | Requirement | How to check |
|-----------|-------------|--------------|
| 4.1.2 Name, role, value | All custom UI components have accessible name and role | Inspect ARIA attributes on custom widgets |

---

## Testing Protocol

Run these in order. Each layer catches what the previous one misses.

### 1. Automated scan (catches ~30% of issues)

Run the browser's accessibility audit or axe-core:

```javascript
// In browser console (via gstack js command)
// Check for axe-core or lighthouse accessibility audit
```

Automated tools catch: missing alt text, contrast failures, missing form labels, duplicate IDs, missing landmarks.

Automated tools miss: logical focus order, meaningful alt text quality, keyboard trap detection, screen reader announcement accuracy.

### 2. Keyboard navigation

Tab through every interactive element on the page:

- Can you reach every link, button, input, and control?
- Can you activate each one with Enter or Space?
- Can you escape modals and dropdowns with Escape?
- Does focus order match the visual layout?
- Are there any keyboard traps (focus enters but cannot leave)?
- Is focus visible on every element?

### 3. Screen reader check

If the browser is available, test with VoiceOver (macOS) or narrator:

- Do headings create a navigable outline?
- Are buttons and links announced with their purpose?
- Do images announce meaningful descriptions?
- Are form fields associated with their labels?
- Do status messages announce without stealing focus?
- Do custom components announce their role and state?

### 4. Visual verification

- Zoom to 200%. Does the layout still work? No horizontal scrolling?
- Does the page work without color? (Turn on high contrast mode or grayscale.)
- Are interactive states (hover, focus, active, disabled) visually distinct?
- Do error states use text and icon, not just color?

---

## Common Issues

These appear in nearly every audit. Check them first.

1. **Insufficient color contrast.** Gray text on white backgrounds. Light placeholder text. Disabled states that are too faint.
2. **Missing form labels.** Placeholder text is not a label. Labels must persist after the user types.
3. **No keyboard access.** Click handlers on divs without keyboard event handlers or button role.
4. **Missing alt text.** Decorative images need `alt=""`. Meaningful images need descriptions.
5. **Focus traps in modals.** Focus enters the modal but cannot leave, or leaves the modal into the background.
6. **Missing ARIA landmarks.** No `main`, `nav`, `header`, `footer` landmarks for screen reader navigation.
7. **Auto-playing media.** Video or audio that plays without user action and has no pause control.

---

## Output Format

```markdown
## Accessibility Audit: [Page/Component Name]
**Standard:** WCAG 2.1 AA | **Date:** [Date]

### Summary
Issues found: [X] | Critical: [X] | Major: [X] | Minor: [X]

### Critical Issues (must fix before ship)

| # | Criterion | Issue | Location | Fix |
|---|-----------|-------|----------|-----|
| 1 | [1.4.3] | [Description] | [Element/selector] | [Specific fix] |

### Major Issues (fix before next release)

| # | Criterion | Issue | Location | Fix |
|---|-----------|-------|----------|-----|
| 1 | [2.1.1] | [Description] | [Element/selector] | [Specific fix] |

### Minor Issues (improve when touching this area)

| # | Criterion | Issue | Location | Fix |
|---|-----------|-------|----------|-----|
| 1 | [3.3.2] | [Description] | [Element/selector] | [Specific fix] |

### Contrast Check
| Element | Foreground | Background | Ratio | Required | Pass |
|---------|-----------|------------|-------|----------|------|
| Body text | #333333 | #FFFFFF | 12.6:1 | 4.5:1 | Yes |

### Keyboard Navigation
| Element | Reachable | Activatable | Focus visible | Order correct |
|---------|-----------|-------------|---------------|---------------|
| [Element] | Yes/No | Yes/No | Yes/No | Yes/No |
```

---

## Anti-Patterns

- Relying only on automated scans. They catch 30% of issues. The other 70% require manual testing.
- Treating accessibility as a post-launch polish task. Retrofitting is 10x more expensive than building it in.
- Using ARIA as a bandaid for bad HTML. A `<button>` is better than `<div role="button" tabindex="0" aria-label="...">`. Use semantic HTML first.
- Testing with mouse only. If you never press Tab, you never find keyboard issues.
- Color as the only indicator. Red border for error, green for success. Add text and icons.

## The Floor

Accessibility is not a feature. It is a quality dimension of every feature. A button that cannot be reached by keyboard is a broken button. A form that announces no errors to screen readers is a broken form. The audit protocol here catches the failures that sighted mouse users never encounter. Run it before every UI ship, not as a separate initiative.
