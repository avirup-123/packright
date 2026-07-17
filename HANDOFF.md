# PackRight — Session Handoff Document
**Date of last session:** 2026-07-17  
**Live URL:** https://packright-20.vercel.app  
**GitHub repo:** https://github.com/avirup-123/packright  
**Local project path:** `C:\Users\Avirup\Pictures\Product\packright-2.0`

---

## What PackRight Is

PackRight is a **free AI-powered travel packing checklist tool** built with:
- **Frontend:** Vanilla HTML + CSS (Tailwind via CDN) + Vanilla JavaScript
- **Backend:** A single Vercel serverless function (`/api/generate.js`) that calls the Gemini API
- **Hosting:** Vercel (auto-deploys from GitHub `main` branch)
- **Database:** No server database — everything saves to the user's browser localStorage
- **Auth:** Supabase Google OAuth (optional, for saving trips across devices)

### Core User Flow
1. User lands on homepage → sees a blank textarea
2. Types a trip description (e.g. "14 days in Paris, hotels, sightseeing")
3. Clicks **Next** → a clarifier screen asks 2–3 follow-up questions
4. Clicks **Build My Packing List** → app calls `/api/generate` → Gemini returns JSON
5. JSON is rendered as an interactive checklist with collapsible categories, checkboxes, progress bar
6. User checks items off — checked items get strikethrough, stay visible (do not disappear)
7. Everything auto-saves to localStorage

### Gemini JSON Response Format
```json
{
  "trip_summary": "14 days in Europe",
  "assumptions": ["Mild weather assumed"],
  "categories": [
    {
      "name": "Clothing",
      "items": [
        { "name": "T-shirts", "quantity": 5, "reason": "For warm days" },
        { "name": "Packing cubes", "quantity": 2, "reason": "For organisation" }
      ]
    }
  ]
}
```

---

## Key Files You Need to Know

| File | What it does |
|---|---|
| `index.html` | Homepage — all UI screens inside one file (launchpad, clarifier, loading, checklist, success) |
| `app.js` | All client-side logic — renders checklist, handles checkboxes, progress bar, localStorage |
| `api.js` | Connects frontend to `/api/generate` serverless function |
| `api/generate.js` | Vercel serverless function — calls Gemini API, returns packing list JSON |
| `affiliate.js` | Affiliate marketing system (matcher + geo-detector + button builder + disclosure) |
| `data/affiliates.json` | 20-product affiliate database with regional Amazon links |
| `sw.js` | Service Worker for PWA caching (currently cache version v2) |
| `vercel.json` | Vercel routing config ensuring `/data/` folder is served as static files |
| `packing-list/europe/index.html` | Europe destination landing page — same app widget + Europe-specific content |

---

## What Was Built This Session

### 1. Europe Destination Page (`/packing-list/europe`)
- Full Europe-specific landing page at `packing-list/europe/index.html`
- Same AI widget as homepage (same `app.js` and `api.js`)
- Below the widget: a **white canvas card** with:
  - Generic Europe trip description at the top
  - 4 collapsible category accordions (Clothing, Documents & Money, Toiletries, Electronics)
  - Each item has clickable circle checkbox — checking it turns green with strikethrough
- Below sample list: Europe-specific FAQ accordion section
- **"Plan Another Trip"** success screen button links to `/` (homepage) and clears localStorage
- Textarea starts **blank** with Europe-specific placeholder text
- Script at top clears any non-Europe cached trip on load

### 2. App Always Loads to Input Screen
- Modified `loadTripFromLocal()` and `loadTripFromSupabase()` in `app.js`
- Now **always shows the launchpad (input) screen** on page load
- localStorage is cleared on load — user always sees blank input widget
- Fixed bug: visitors were seeing old "Tokyo & Osaka Backpacking" checklist instead of input area

### 3. Header Subtitle Removed
- Removed `: Your Ultimate Travel Packing Checklist` from the logo on both pages
- Logo now shows just: **PackRight**

### 4. Brand Guidelines Document
- Created `brand_guidelines.md` in project root
- Covers: color palette, typography, component specs, voice & tone, SEO rules

### 5. Affiliate Marketing System (Main Feature)

**`data/affiliates.json`** — 20-product database:
- Each product: `id`, `name`, `label` (button text), `keywords[]`, `links{}` (regional URLs)
- Regional links: `IN` (amazon.in), `AE` (amazon.ae), `GB` (amazon.co.uk), `default` (amazon.com)
- 2 non-Amazon: Travel Insurance → worldnomads.com, eSIM → airalo.com
- All Amazon tags are **PLACEHOLDERS** — must be replaced with real tags before going live

**`affiliate.js`** — core logic module:
- Fetches `/data/affiliates.json` on page load
- Calls `https://ipapi.co/json/` with 3-second timeout to detect user's country
- Uses **Fuse.js** (CDN) with threshold 0.35 for fuzzy matching of item names to keywords
- Builds styled coral `<a>` buttons for matching items — opens in new tab
- Exposes everything via `window.PackRightAffiliates` object

**`app.js` modifications:**
- `renderItem()` calls `window.PackRightAffiliates.buildAffiliateButton(item.name)` and injects button between item name and context note
- `renderPackingList()` appends legal disclosure line at bottom of every generated list

**Disclosure text (always shown — Amazon Associates legal requirement):**
> "Some items link to Amazon and other retailers. PackRight earns a small commission at no extra cost to you."

**Affiliate button style:** coral (#D4735E), 0.72rem, no background, underline on hover, new tab

**Error handling:** if any part of the affiliate system fails, the main checklist is completely unaffected

---

## Placeholder Affiliate Tags — NOT Live Yet

All tags in `data/affiliates.json` are placeholders. Replace these before going live:

| Region | Placeholder | Replace with |
|---|---|---|
| India | `PACKRIGHT-IN-21` | Real amazon.in Associates tag |
| UAE | `PACKRIGHT-AE-21` | Real amazon.ae Associates tag |
| UK | `PACKRIGHT-GB-21` | Real amazon.co.uk Associates tag |
| US/Default | `PACKRIGHT-21` | Real amazon.com Associates tag |
| Travel Insurance | `https://www.worldnomads.com` | Real WorldNomads affiliate URL |
| eSIM | `https://www.airalo.com` | Real Airalo affiliate URL |

---

## What's Planned Next — Continue From Here

### 1. Replace Placeholder Affiliate Tags
Owner will supply real Amazon Associates tags. Edit `data/affiliates.json` and replace all placeholder tags.

### 2. Add Flipkart Affiliate Links (India)
Owner wants Flipkart as an option for Indian users.

**Decision needed from owner:** When user is in India, show:
- Option A: Only Flipkart (replace Amazon India entirely)
- Option B: Both Amazon India AND Flipkart side by side

**How to implement:**
- Add `FK` key to each product's `links{}` object in `affiliates.json`
- Flipkart search URL format: `https://www.flipkart.com/search?q=packing+cubes&affid=YOUR_AFFILIATE_ID`
- Modify `getAffiliateLink()` in `affiliate.js` to return Flipkart URL for `IN` country
- Or modify `buildAffiliateButton()` to return two buttons for Indian users

### 3. More Destination Pages
Build pages following the same pattern as the Europe page:
- `/packing-list/japan`
- `/packing-list/thailand`
- `/packing-list/dubai`
- `/packing-list/bali`
- `/packing-list/goa`

Each page: same app widget + destination-specific hero text + sample list + FAQ accordion

### 4. SEO Improvements
- Add each new destination page to `sitemap.xml`
- Add more long-form destination-specific content below the FAQ
- Consider blog-style articles for long-tail search traffic

### 5. Expand Affiliate Product Database
Currently 20 products. Consider adding:
- Walking shoes / hiking boots
- Rain jacket / waterproof jacket
- Travel laptop bag
- Noise-cancelling headphones
- Portable WiFi router
- Voltage converter
- Waterproof phone case

---

## How to Deploy Changes

```bash
git add .
git commit -m "description of change"
git push origin main
npx vercel --prod --yes
```

---

## Design System Quick Reference

| Token | Value | Tailwind class |
|---|---|---|
| Primary (Terracotta) | `#E06A4E` | `text-primary` / `bg-primary` |
| Base Canvas (Sand) | `#FAF6F0` | `bg-baseCanvas` |
| Success (Sage Green) | `#5F8567` | `bg-success` / `text-success` |
| Neutral Text | `#222222` | `text-neutralText` |
| Affiliate Coral | `#D4735E` | Inline style only |

**Fonts:** Outfit (headings), Poppins (labels), Inter (body/list items)  
**Cards:** `rounded-2xl shadow-sm border border-neutralText/5`  
**Outer containers:** `rounded-3xl shadow-xl`

---

## Notes for Next Session Agent

- Project is **vanilla HTML/JS/CSS** — NOT Next.js
- Tailwind loaded via CDN with custom config in a `<script>` tag in each HTML file
- All pages share `app.js` and `api.js` via absolute paths (`/app.js`, `/api.js`)
- `affiliate.js` is loaded WITHOUT `defer` so it initialises before `app.js` runs
- Service Worker cache is at version `v2` — bump to `v3` in `sw.js` if making significant JS changes
- Always test `https://packright-20.vercel.app/data/affiliates.json` directly after deploy to confirm static file routing works
- To verify affiliate system is working: open browser console on live site and look for `[PackRight Affiliates] Ready.`
- To test matcher in console: `window.PackRightAffiliates.findAffiliateMatch("packing cubes")`
- To check detected country: `window.PackRightAffiliates.getCountry()`
