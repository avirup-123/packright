# PackRight 2.0 Brand Guidelines

Welcome to the official brand guidelines for **PackRight**. This document establishes the visual identity, UI design tokens, typography rules, component patterns, and voice standards to ensure consistency across the main site and all destination pages (like Europe, Asia, etc.).

---

## 1. Brand Identity & Philosophy

PackRight is a minimalist, modern, AI-powered travel assistant that eliminates packing anxiety. The brand philosophy centers on **effortless preparation, utility, and premium simplicity**.

- **Mission**: To provide travelers with highly personalized, context-aware packing lists that account for climates, duration, luggage size, and local cultural norms.
- **Tone**: Professional, concierge-grade, factual, and efficient. No fluff, no exclamation-heavy marketing speak.

---

## 2. Color Palette (Design Tokens)

The brand uses a curated, warm, organic palette inspired by travel, leather luggage, paper travel diaries, and green check marks of completion.

| Token Name | Hex Code | Purpose / Application | Tailwind Class Equivalent |
| :--- | :--- | :--- | :--- |
| **Primary (Terracotta)** | `#D4735E` | Brand color, main buttons, active indicators, titles | `bg-primary` / `text-primary` |
| **Base Canvas (Sand)** | `#F5F0EB` / `#FAF6F0` | Main website background, light inputs, inactive cards | `bg-baseCanvas` |
| **Success (Sage Green)** | `#5F8567` | Checked checklist items, success screen, progress meters | `bg-success` / `text-success` |
| **Neutral Text (Charcoal)** | `#222222` | Body copy, dark buttons, readable titles | `text-neutralText` |
| **White** | `#FFFFFF` | Category cards, modal boxes, checked circles bg | `bg-white` |

> [!TIP]
> Always use base canvas transparency (e.g. `bg-baseCanvas/50` or `bg-baseCanvas/20`) for soft hover effects and container cards instead of hard borders.

---

## 3. Typography

PackRight relies on three Google Fonts to create a clear visual hierarchy and distinct personality.

```html
<!-- Font Imports -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Outfit:wght@500;600;700;800&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
```

### Typographic System:

1. **Outfit** (Primary Headings & Titles)
   - *Application*: Logos, Page Headers (`h1`, `h2`), card title headers.
   - *Styling*: Frequently italicized for landing headings (`font-outfit italic`) to convey forward movement and travel style.
   - *Example*: `<h1 class="font-outfit italic font-bold">Your Packing Checklist</h1>`

2. **Poppins** (Navigation, Sub-headings, Labels)
   - *Application*: Inline subtitles, category name headers, secondary buttons, FAQ question text.
   - *Styling*: Clear geometric sans-serif that maintains readability at smaller weights.

3. **Inter** (Checklist Items, Paragraph Body text)
   - *Application*: Descriptive notes, checklist item names, textareas, settings inputs.
   - *Styling*: Used for maximum clarity and alignment within high-density lists.

---

## 4. Visual Design Rules & Aesthetics

To maintain the premium feel of the homepage, follow these structural rules:

* **Rounded Corners**: 
  - Standard cards and modals must use `rounded-2xl` (16px).
  - Main checklist outer frame and textarea wrappers use `rounded-3xl` (24px) for a softer, premium card feel.
* **Drop Shadows**:
  - Cards should have a very soft shadow: `shadow-sm` or `shadow-md` (avoid harsh dark borders).
  - Use `border border-neutralText/5` to create subtle structure on white elements.
* **Micro-interactions**:
  - Interactive rows (like checklists and buttons) should use `transition-all duration-200` or `transition-colors`.
  - Scale on active click: `active:scale-[0.98]` or `active:scale-95` on small circles.
  - Hover background highlight: `hover:bg-baseCanvas/20` or `hover:bg-neutralText/5`.

---

## 5. Component Standards

### A. The Category Card (Accordion)
Cards must be collapsible to allow travelers to manage large packing lists.
- **Collapsed state**: Chevron is flat (`rotate-0`), `.items-list` content is hidden (`hidden`).
- **Expanded state**: Chevron rotates 180 degrees (`rotate-180`), items list is visible.

### B. Checklist Items (Interactive Row)
Each item is wrapped in a container that supports tap-anywhere checking.

```html
<div class="item-row flex items-start p-4 border-t border-neutralText/5 gap-3 hover:bg-baseCanvas/20 cursor-pointer select-none">
    <button class="checkbox-btn flex-shrink-0 w-6 h-6 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none">
        <svg class="w-3.5 h-3.5 opacity-0 transition-opacity check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path>
        </svg>
    </button>
    <div class="flex-1 min-w-0 pr-8">
        <div class="font-medium text-sm md:text-base text-neutralText item-name transition-all">Comfortable walking shoes</div>
        <div class="text-[11px] md:text-xs text-neutralText/60 italic">essential for European cobblestones</div>
    </div>
</div>
```

### C. Checked Item State (Completed)
When an item is checked:
- The circular button changes from outline (`border-neutralText/30`) to filled (`bg-success border-success`).
- The checkmark SVG transitions from `opacity-0` to `opacity-100`.
- The text gets `line-through` and faded to `opacity-50`.

---

## 6. Voice & Tone Guidelines

PackRight's AI generates lists that feel curated by a human travel planner. Do not let the AI use machine-like text formats.

- **Checklist Item Names**: Must be short noun phrases.
  - *Correct*: `Universal plug adapter`
  - *Incorrect*: `You should pack a plug adapter so you can charge your devices`
- **Context/Note Fields**: Must describe the *why* factually.
  - *Correct*: `essential — plug types differ between UK (Type G) and mainland Europe`
  - *Incorrect*: `Don't forget this! You'll need it when you land in London!`
- **AI Summary Fields**: Must summarize the trip constraints concisely.
  - *Correct*: `14 days in Europe, carry-on only, hotels, sightseeing and nightlife.`

---

## 7. SEO & Semantic HTML Best Practices

To rank well for destination searches (e.g. *"What to pack for Europe"*):
1. **Semantic Headers**: Exactly one `<h1>` per page (typically the destination title).
2. **Canonical Links**: Every subpage must define a canonical tag pointing to its production URL.
3. **Structured Schema**:
   - Include a `Product` JSON-LD schema representing the generator tool.
   - Include a `FAQPage` JSON-LD schema wrapping the FAQs at the bottom of the page.
