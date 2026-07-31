---
name: Terracotta Luxe
colors:
  surface: '#fef8f3'
  surface-dim: '#ded9d4'
  surface-bright: '#fef8f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f3ee'
  surface-container: '#f2ede8'
  surface-container-high: '#ece7e2'
  surface-container-highest: '#e6e2dd'
  on-surface: '#1d1b19'
  on-surface-variant: '#55423f'
  inverse-surface: '#32302d'
  inverse-on-surface: '#f5f0eb'
  outline: '#88726e'
  outline-variant: '#dbc1bb'
  surface-tint: '#994533'
  primary: '#964331'
  on-primary: '#ffffff'
  primary-container: '#b55a47'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb4a4'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#a03b23'
  on-tertiary: '#ffffff'
  tertiary-container: '#c05238'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad3'
  primary-fixed-dim: '#ffb4a4'
  on-primary-fixed: '#3e0500'
  on-primary-fixed-variant: '#7a2e1e'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1b1c1c'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#ffdad2'
  tertiary-fixed-dim: '#ffb4a3'
  on-tertiary-fixed: '#3d0700'
  on-tertiary-fixed-variant: '#832610'
  background: '#fef8f3'
  on-background: '#1d1b19'
  surface-variant: '#e6e2dd'
  surface-card: '#FFFFFF'
  surface-bg: '#F5F0EB'
  text-rich: '#222222'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '400'
    lineHeight: 56px
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 28px
    fontWeight: '400'
    lineHeight: 36px
  headline-md:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '400'
    lineHeight: 32px
  title-lg:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Outfit
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
  unit: 8px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

The design system is engineered for a premium travel assistant, balancing the warmth of a concierge service with the authority of a seasoned explorer. The aesthetic direction is **Modern Minimalism with a Tactile twist**, emphasizing high-quality materials and a sense of "digital paper."

The visual narrative focuses on calmness and preparation. By utilizing generous whitespace and a sophisticated warm palette, the UI aims to reduce the anxiety associated with travel planning. The experience should feel bespoke—as if every recommendation and checklist was hand-crafted for the user.

Key characteristics include:
- **Refined Editorial:** Using high-contrast serif italics for headings to evoke a travel magazine feel.
- **Architectural Depth:** Layered surfaces that feel like stacked stationery.
- **Warm Utility:** A marriage of soft background tones with high-precision UI elements.

## Colors

The palette is anchored by **Coral/Terracotta**, a hue that represents earth and sunrise, providing a warm and energetic primary action color. This is balanced against a **Warm Cream/Beige** background, which offers a softer, more premium alternative to pure white, reducing eye strain and feeling more "organic."

- **Primary (#D4735E):** Used for primary actions, progress indicators, and the signature top-border branding on cards.
- **Background (#F5F0EB):** Applied to the base canvas to establish the brand's warm, approachable character.
- **Text/Neutral (#222222):** A deep charcoal used for body text and icons to ensure high legibility without the harshness of pure black.
- **Surface (#FFFFFF):** Reserved for card elements to create a clear visual "lift" from the background.

## Typography

This design system employs a sophisticated typographic pairing. **Playfair Display (Italic)** is used exclusively for headlines to provide an authoritative, editorial voice. **Outfit** (a contemporary alternative to Poppins with a similar geometric but more refined feel) is used for body copy and UI labels to maintain exceptional clarity and modernism.

- **Headlines:** Always rendered in Italic to emphasize the premium, "concierge" personality.
- **Body & UI:** Set in Outfit for its high x-height and readability in dense lists or data-heavy packing screens.
- **Hierarchy:** Dramatic scale differences between headlines and body text help establish a clear information architecture.

## Layout & Spacing

The layout philosophy follows a **Fixed Grid** approach for desktop to maintain a premium, curated feel, and a **Fluid Fluid** approach for mobile. 

- **Grid:** A 12-column grid on desktop with generous 24px gutters. Content should be centered with a maximum width of 1200px to avoid overly long line lengths.
- **Rhythm:** An 8px base unit drives all padding and margin decisions. 
- **Reflow:** On mobile, margins reduce to 16px, and multi-column card layouts collapse into a single-column vertical stack to prioritize the checklist and itinerary reading experience.

## Elevation & Depth

This design system avoids heavy shadows in favor of **Tonal Layering** and subtle ambient occlusion. Depth is created through the contrast between the warm beige background and the crisp white surfaces.

- **Surface Levels:** The background is the lowest level. Cards sit on the primary level. Modals and floating action buttons sit on the top level.
- **Shadows:** Use extremely soft, tinted shadows (`rgba(212, 115, 94, 0.08)`) to lift cards slightly off the beige background. 
- **The "Signature Accent":** A 4px solid border in the Primary Coral color is applied to the top edge of all primary cards, reinforcing brand identity without cluttering the UI.

## Shapes

The shape language is defined by high-radius curves that feel friendly and approachable. 

- **Cards:** Use a minimum radius of 24px to create a soft, containerized look. 
- **Buttons & Inputs:** Follow the `rounded-lg` (16px) or `rounded-xl` (24px) patterns to match the card aesthetic.
- **Iconography:** Use "Material Symbols Outlined" with a rounded corner styling to ensure icons feel integrated with the typography and shape language.

## Components

### Buttons
- **Primary:** Solid Primary Coral (#D4735E) with white text. 24px corner radius.
- **Secondary:** Outlined in Primary Coral with a subtle 1px stroke.
- **Ghost:** Minimalist text-only buttons for tertiary actions, using the text-rich color.

### Cards
- **Base Style:** Pure white background, 24px corner radius, soft ambient shadow.
- **Signature Variant:** Features a 4px solid top border in Primary Coral. Used for main itinerary items or category headers.

### Input Fields
- **Form Fields:** Soft beige fill (slightly darker than background) or white fill with a subtle border. Focus state uses a 2px Primary Coral outline.

### Chips & Tags
- Used for categories (e.g., "Essentials," "Weather Alert"). Use a light tint of the primary color (10% opacity) with dark coral text.

### Checklist Items
- Custom checkboxes using the Primary Coral color when checked. Items should have a soft hover state that highlights the entire row with a 50% opacity beige background.

### Navigation
- A clean, top-anchored navigation bar with the logo on the left and utility links on the right. On mobile, a bottom-anchored "Tab Bar" provides easy thumb access to the "Pack," "Plan," and "Profile" sections.