---
name: visual-verify
description: Verify UI changes at element level before declaring any frontend work done. Full-page screenshots are forbidden for component verification.
---

# Visual Verification

Element-level proof for every UI change. Full-page screenshots miss the bugs that matter.

## The Core Problem

Full-page screenshots are 1400px wide. A 1px border clip, overflow cut, or color error is invisible at that resolution. ICLR 2025 research confirms MLLMs drop 11-24 percentage points of accuracy on small visual details. The fix: crop to the region of interest before evaluating.

## Required Procedure

For every UI component change, follow this sequence:

### Step 1: Get element refs from the page

```
browser_snapshot
```

Find the ref for the changed component in the a11y tree output. Refs look like `ref="s1e2"` or similar short strings.

### Step 2: Element-level screenshot (primary path)

```
browser_take_screenshot(element="description of element", ref="<ref from snapshot>")
```

This auto-crops to exactly the element bounds. Read the result carefully:

- Are all borders fully visible (top, bottom, left, right arcs)?
- Is the background color correct?
- Is text not truncated or overflowing?
- Is spacing correct above and below?

### Step 3: Declare done only after element screenshot confirms correct rendering

If the element screenshot shows the bug is fixed, proceed.
If no ref is available (element not in a11y tree), use the ImageMagick fallback below.

## ImageMagick Fallback

When the element is not in the a11y tree:

```bash
# Get bounding box via JS
browser_evaluate: document.querySelector('.your-selector').getBoundingClientRect()

# Capture full page
browser_take_screenshot(fullPage=false)

# Crop and zoom 3x with ImageMagick
magick screenshot.png -crop WxH+X+Y +repage -resize 300% zoomed.png

# Read the cropped result
Read zoomed.png
```

Replace W/H with element width/height and X/Y with top-left position from getBoundingClientRect.

## Anti-Patterns

- Taking a full-page screenshot and saying "looks good." A 1px clipping, 1px border cut, or overflow issue is invisible at 1400px width.
- Declaring a component fixed without a screenshot at element resolution.
- Using only text-based assertions for visual correctness. The element screenshot is the evidence.
- Skipping the fallback when the element is not in the a11y tree. The ImageMagick path exists for this reason.

## The Floor

Every UI fix is either visually confirmed or assumed. The ViCrop principle eliminates that assumption: crop to the element before evaluating. Full-page screenshots are documentation of the surface, not evidence of correctness. The element-level screenshot is the minimum proof that a visual change produced the intended result.
