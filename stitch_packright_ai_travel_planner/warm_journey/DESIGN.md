---
name: Warm Journey
colors:
  surface: '#fdf9f3'
  surface-dim: '#dddad4'
  surface-bright: '#fdf9f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f7f3ed'
  surface-container: '#f1ede7'
  surface-container-high: '#ebe8e2'
  surface-container-highest: '#e6e2dc'
  on-surface: '#1c1c18'
  on-surface-variant: '#57423d'
  inverse-surface: '#31302d'
  inverse-on-surface: '#f4f0ea'
  outline: '#8a716c'
  outline-variant: '#dec0b9'
  surface-tint: '#a33d25'
  primary: '#a03b23'
  on-primary: '#ffffff'
  primary-container: '#c05238'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb4a3'
  secondary: '#42674b'
  on-secondary: '#ffffff'
  secondary-container: '#c3edc9'
  on-secondary-container: '#486d50'
  tertiary: '#675a4d'
  on-tertiary: '#ffffff'
  tertiary-container: '#807264'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad2'
  primary-fixed-dim: '#ffb4a3'
  on-primary-fixed: '#3d0700'
  on-primary-fixed-variant: '#832610'
  secondary-fixed: '#c3edc9'
  secondary-fixed-dim: '#a8d0ae'
  on-secondary-fixed: '#00210d'
  on-secondary-fixed-variant: '#2a4e34'
  tertiary-fixed: '#f2dfcf'
  tertiary-fixed-dim: '#d5c4b4'
  on-tertiary-fixed: '#231a10'
  on-tertiary-fixed-variant: '#504539'
  background: '#fdf9f3'
  on-background: '#1c1c18'
  surface-variant: '#e6e2dc'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: auto
  max-width: 1200px
---

## Brand & Style
The design system is built on the narrative of "Premium Travel Stationery"—blending the tactile reliability of a high-quality physical travel journal with the effortless intelligence of modern AI. The aesthetic is warm, lively, and deeply human-centric, designed to reduce the cognitive load and stress of pre-trip preparation.

The style is **Modern Tactile**, utilizing soft cream backgrounds, organic color transitions, and gentle elevation to create a friendly, approachable environment. It avoids clinical rigidity in favor of soft geometry and rhythmic spacing, ensuring the user feels supported and inspired rather than managed. The interface evokes a sense of "adventure-ready calm."

## Colors
The palette is inspired by natural landscapes and travel artifacts. 

- **Primary (Sunset Terracotta):** Used for primary call-to-actions, active states, and brand-defining moments. It radiates energy and warmth.
- **Secondary (Calm Sage):** Reserved for success states, completed tasks, and progress indicators. It provides a soothing counterpoint to the energetic primary hue.
- **Background (Soft Sand):** The foundation of the system. This off-white cream canvas reduces eye strain and feels more premium and intentional than pure white.
- **Typography:** Deep Charcoal provides high-contrast legibility for headings, while Muted Umber is used for secondary metadata and helper text to maintain the warm tonal consistency.

## Typography
The typographic hierarchy balances personality with utility. 

**Plus Jakarta Sans** is used for headlines and labels to inject a friendly, modern, and slightly rounded geometric character into the interface. For the body copy, **Inter** provides maximum scannability and legibility, especially in data-dense packing lists. 

Headlines should use tight letter spacing and semi-bold weights to appear grounded and confident. Body text maintains generous line heights to ensure the interface feels airy and organized.

## Layout & Spacing
The layout follows a **Fluid Grid** model with a soft 8px baseline rhythm. 

- **Mobile:** A single-column layout with 20px side margins. Elements are stacked vertically to prioritize focus.
- **Tablet/Desktop:** A 12-column grid with a maximum content width of 1200px. Gutters are fixed at 16px to keep content feeling cohesive.

Spacing is used to create "grouping by proximity," where list categories are separated by `lg` spacing, while items within a category use `sm` padding. Large areas of whitespace (Soft Sand background) are encouraged to prevent the "packing anxiety" often associated with list-making apps.

## Elevation & Depth
Depth is expressed through **Warm Ambient Shadows** rather than stark grey offsets. This reinforces the "Travel Stationery" narrative—elements should look like they are gently resting on a soft surface.

- **Low Elevation:** Use for cards and interactive pills. A subtle 4px blur with a 5% opacity Umber (#6B5E51) tint.
- **High Elevation:** Reserved for floating action buttons (FABs) and modals. A 16px blur with a 10% opacity Umber tint, creating a soft "lift" from the canvas.
- **Tonal Layering:** Containers use a slightly lighter or darker shade of the base Sand color to define functional zones without the need for heavy borders.

## Shapes
The shape language is defined by **High Roundedness**. All primary containers, cards, and buttons utilize a 16px (rounded-2xl) corner radius. 

Smaller elements like multi-select pills and checkboxes use 8px (rounded-lg) to maintain a consistent visual weight. This softness removes any "technical" sharpness from the AI-driven experience, making the app feel like a friendly companion.

## Components
- **Buttons:** Primary buttons are Sunset Terracotta with white text, using 16px rounded corners. They feature a soft shadow that disappears on "press" to simulate physical feedback.
- **Multi-select Option Pills:** Used for travel styles (e.g., "Business," "Hiking"). Unselected pills have a Muted Umber outline; selected pills transition to a Sage Green fill with a check icon.
- **Category Accordions:** Large, card-based headers with 16px rounding. Use a subtle Umber chevron. When expanded, the interior content is separated by thin, low-opacity Umber dividers.
- **Progress Bars:** Use a thick (12px) track in a lighter tint of Sand, with the Sage Green fill representing completion. The ends are fully rounded (pill-shaped).
- **Checkboxes:** Larger-than-standard (24px) with highly rounded corners. Toggling a checkbox triggers a subtle color shift of the entire list item row to a very faint Sage Green tint.
- **Input Fields & Textareas:** Background-colored (Soft Sand) with a Muted Umber bottom border or a subtle inset shadow to indicate "writable" space, emphasizing the stationery feel.