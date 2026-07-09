# MASTER ARCHITECT & CODEGEN PROMPT: PACKRIGHT (PURE WEB SPECIFICATION)

## IMPORTANT: STAGE OVERRIDE DIRECTIVE
This tool must be built strictly as a 100% pure, standard client-side website running on HTML5, Tailwind CSS, and Vanilla JavaScript. Do not generate native mobile project structures, Android/iOS directories, Gradle configurations, or mobile app files. The absolute output must be exactly three flat web files openable directly in any web browser: `index.html`, `app.js`, and `api.js`.

---

## PART 1: PRODUCT VISION, MARKET CONTEXT & TARGET PERSONA

### 1. Product Typology & Classification
PackRight is an intelligent, context-driven Travel Packing Assistant and Luggage Optimization Checklist. Instead of serving as a static checklist (like legacy spreadsheets or notes apps), PackRight operates as an interactive rule engine driven by large language model (LLM) text processing to eliminate human cognitive load and anxiety during trip preparation.

### 2. Market Gaps & Competitor Inefficiencies (What PackRight Fixes)
The engineering model must proactively eliminate the structural flaws found in current market incumbents:
1.  **Zero Data Loss (Fixing PackMate/QuickPack flaws):** Eradicates the #1 user complaint across all packing apps by routing all checkbox toggles and input changes instantly to client-side storage (`window.localStorage`). 
2.  **True Contextual Intelligence (Fixing PackPoint flaws):** Bypasses rigid binary checkboxes or drop-downs. It naturally handles complex multi-destination or multi-climate itineraries through freeform text parsing (e.g., understanding that a trip across different regions means varying weather, distinct power grids, or cultural dress expectations).
3.  **Inclusive & Frictionless Entry:** Eliminates forced binary gender fields or rigid city-name validation menus on boarding. 
4.  **Dynamic Context Extraction (`AskUserQuestion`):** Implements an adaptive AI-driven clarification step to clear up ambiguous variables before writing the packing list, ensuring suggestions are never generic templates.

### 3. Detailed Target User Persona: "Priya, the Prepared Planner"
*   **Demographics & Habits:** Age 28–50, frequent global traveler (blending corporate business travel with complex multi-destination leisure itineraries). She values efficiency over all else; if a tool takes longer to set up than manual pen-and-paper tracking, she will instantly abandon it.
*   **Mindset & Motivations:** Priya uses this utility because she has suffered logistical or financial consequences from forgetting critical high-stakes items on past trips—such as prescription medication, unique device charging bricks, specific entry visas, international plug adapters, or event-specific attire. She expects a trusted "second brain" that eliminates mental fatigue.
*   **Emotional State at Point of Use:** Mildly anxious, hurried, and experiencing cognitive overload. She is typically interacting with the checklist interface late the night before departure or during packed transition windows. 
*   **Code Implementation Directive for Persona:** The interface copy, error handling, fallbacks, and design transitions must actively reduce anxiety. The workflow must feel human-centric, warm, fluid, and exceptionally reliable.

---

## PART 2: UI/UX DESIGN TOKENS & SYSTEM AESTHETIC

To match the warm, lively, and comforting stationery feel needed to reduce Priya's packing anxiety, enforce these design parameters:
*   **Color Palette Specification:**
    *   `Base Canvas Background`: Soft Sand / Cream (`#FAF6F0`) — default body background to soften eye strain.
    *   `Primary Branding & Call-To-Action`: Sunset Terracotta / Warm Coral (`#E06A4E`) — used for interactive action states, primary buttons, active pill frames, and visual highlights.
    *   `Success & Progress Indicators`: Calm Sage Green (`#5F8567`) — exclusively used for fully packed progress indicators, active checkboxes, and finalized items.
    *   `Neutral Accents`: Off-Black / Charcoal (`#222222`) for readable body text; muted light-sand tints for structural container backgrounds.
*   **Typography Scale:**
    *   Headings (`<h1>`, `<h2>`, `<h3>`): Outfit or Plus Jakarta Sans via Google Fonts import (Semi-Bold / Approachable Geometric).
    *   Body & Micro-UI elements: Inter or system-sans (Regular / Medium) formatted for rapid scannability.
*   **Component Geometry:** All interactive cards, inputs, buttons, and pill badges must utilize a smooth `rounded-2xl` (16px) corner radius[cite: 2]. Use soft drop-shadow utilities to define clean visual depth[cite: 2].

---

## PART 3: DYNAMIC VIEW SWITCHING MATRIX (THE 4 SCREENS)

The application layout must split into 4 distinct semantic view divisions wrapped inside a centered, mobile-first structural layout container (`max-width: 440px`) globally center-aligned on desktop screens[cite: 2].

### Screen 1: The Launchpad (Home Interface)
*   **Header Module:** Minimalist typographic logotype `PackRight` aligned left[cite: 2]. A functional settings gear icon (`⚙️`) aligned right[cite: 2]. Tapping the gear surfaces an elegant modal overlay layer harboring a secure text field input labeled "Enter Gemini API Key"[cite: 2]. Input values must immediately bind to `localStorage.setItem('packright_gemini_key')`[cite: 2].
*   **Main Prompt Input Canvas:** A large, multi-line structural `<textarea>` with explicit padding[cite: 2]. It features an illustrative placeholder: *"e.g., 12 days in Tokyo and Osaka in chilly March, staying in backpacker hostels, flying budget airlines with tight bags, lots of daily walking, but one formal dinner planned..."*[cite: 2].
*   **Action Row:** A high-contrast full-width action button styled in Sunset Terracotta (`#E06A4E`) labeled **"Next"**[cite: 2]. Clicking this button executes the first API call transaction and advances the UI state[cite: 2].

### Screen 1.5: The Clarifier (The AI Interview Layer)
*   **UX Execution Pattern:** Implements the custom context interview layer[cite: 2]. It extracts missing parameters by generating 2 to 3 contextual multiple-choice question elements derived from the user's raw input to eliminate template ambiguity[cite: 2].
*   **Visual Layout:** Displays a warm title card reading *"Just a few quick details to perfect your list:"* followed by a loop container generating isolated question cards[cite: 2]. Each question card prints a clear text label and displays a series of horizontal option pills[cite: 2].
*   **Pill Interaction State:** Tapping an option pill triggers an immediate look change[cite: 2]. Active selections swap from light sand frames into a vibrant Terracotta tint[cite: 2].
*   **Action Row:** A sticky full-width trigger button labeled **"Build My Packing List"** that combines all data metrics and routes to the execution phase[cite: 2].

### Screen 2: The Brainstorm (Smart Loading Buffer)
*   **UX Execution Pattern:** Keeps user engagement stable while masking backend API response latency[cite: 2].
*   **Visual Layout:** A completely uncluttered view featuring a pulsing, infinitely looping micro-animation graphic of a packing suitcase or compass icon[cite: 2].
*   **Dynamic Sub-text Tracker:** A localized text container that updates its copy programmatically every 1.5 seconds to directly echo parameters typed by the user to maintain high comfort[cite: 2]:
    *   *Interval 1:* `"Analyzing your destination's climate profile..."`[cite: 2]
    *   *Interval 2:* `"Calibrating airline baggage size boundaries..."`[cite: 2]
    *   *Interval 3:* `"Assembling smart packing item rows..."`[cite: 2]

### Screen 3: The Packing Canvas (The Main Workspace)
*   **Persistent Sticky Summary Header:** Locked immutably to the upper edge of the viewport[cite: 2]. Displays the bold AI-generated trip title name alongside a live alphanumeric progress metric string (e.g., `14 / 42 Items Packed`) resting above a clean Sage Green progress bar[cite: 2].
*   **Category Accordions:** Vertically stacked card groupings organized exclusively by **Item Category** (e.g., `👕 Clothing`, `🔌 Electronics`, `🧳 Toiletries`, `📄 Documents`)[cite: 2]. Tapping a header expands or collapses that card view cleanly using a chevron indicator icon[cite: 2].
*   **The Smart Checklist Row:** Within each subcategory card, individual checklist items populate line-by-line using alternating background striping[cite: 2]:
    *   *Left Element:* A large, touch-padded circular checkbox element[cite: 2].
    *   *Center Element:* The bold item title name stacked directly above an italicized, muted micro-context note card explaining *exactly why* the AI added the item (e.g., **Universal Plug Adapter** ➔ *"Japan utilizes flat 2-prong Type A/B electrical sockets"*)[cite: 2].
    *   *Right Element:* A color-coded, rounded priority capsule badge marking luggage target allocation (`🎒 Carry-on` in soft blue or `🧳 Checked` in soft green)[cite: 2].
*   **Inline Append Control:** Positioned permanently at the base of *every single active category block*[cite: 2]. It features a minimalist input field marked with a `+` icon[cite: 2]. Typing a string and pressing Enter must immediately insert a new custom user item directly into that specific category list array view[cite: 2].
*   **Checking Interaction Mechanics:** Tapping a checkbox instantly mutates the row's design: the checkbox fills with Sage Green, the item text transitions to 50% opacity with a clean `line-through` strikeout style, the luggage badge changes to a neutral grey, the upper progress meter increments live, and the state change flushes directly to the local storage schema[cite: 2].

---

## PART 4: STRUCTURED AI DATA SCHEMAS (STRICT JSON MODE)

Your network logic module inside `api.js` must construct its payload configurations to strictly enforce JSON schemas for all Gemini completions using strict JSON mode configurations[cite: 2].

### Call 1 Output Schema (Launchpad Text ➔ Clarifier Question Generation)
```json
{
  "questions": [
    {
      "id": "q1",
      "question_text": "What type of accommodation are you staying in?",
      "options": ["Hotel / Airbnb", "Backpacker Hostel", "Camping / Outdoors"]
    },
    {
      "id": "q2",
      "question_text": "What is your primary activity profile?",
      "options": ["Business Meetings", "Hiking & Trekking", "Casual Tourism / Sightseeing"]
    }
  ]
}
Call 2 Output Schema (Consolidated Options ➔ Complete Custom Checklist Layout)
JSON
{
  "trip_name": "Tokyo & Osaka Backpacking",
  "duration_days": 12,
  "categories": [
    {
      "category_name": "Electronics",
      "items": [
        {
          "id": "elec_01",
          "name": "Universal Plug Adapter",
          "context_note": "Japan operates on Type A/B flat 2-prong plugs",
          "luggage_target": "Carry-on",
          "packed": false
        }
      ]
    }
  ]
}
PART 5: NATIVE LOCAL STORAGE STATE MANAGEMENT SCHEMA
The application state must be consolidated into a singular, serialized string key named packright_active_trip saved on the client's hard drive[cite: 2]. It must follow this exact tracking shape to prevent data virtualization errors[cite: 2]:

JSON
{
  "packright_active_trip": {
    "trip_name": "Tokyo & Osaka Backpacking",
    "saved_items_state": {
      "elec_01": true,
      "elec_02": false
    },
    "custom_added_items": [
      {
        "id": "custom_17128912",
        "category": "Toiletries",
        "name": "Prescription Contact Lenses",
        "luggage_target": "Carry-on",
        "packed": false
      }
    ]
  }
}
PART 6: GRANULAR FILE IMPLEMENTATION GUIDELINES
STEP 1: Implement index.html
Incorporate links for Google Fonts (Outfit and Inter) and load Tailwind CSS via CDN[cite: 2].

Code a clean, hidden modal container layout representing the settings gear key config wrapper[cite: 2].

Incorporate the 4 UI screen views as standalone semantic structural <div> container compartments[cite: 2]. Ensure only Screen 1 is visible by default (block), while screens 1.5, 2, and 3 are set to hidden[cite: 2].

Verify that every clickable action component, text input canvas, item accordion card wrapper, and inline addition field possesses explicit, discoverable id attributes or target semantic selector hooks[cite: 2].

STEP 2: Implement app.js
Construct a centralized application state controller class or operational state management object[cite: 2].

Implement clean routing methods that smoothly toggle between the 4 screen layers by adding or removing Tailwind's visibility classes[cite: 2].

Write initialization code that reads localStorage immediately upon DOM load[cite: 2]. If an existing packright_active_trip key exists, bypass the onboarding screens and render Screen 3 directly to preserve user workflow[cite: 2].

Write event tracking modules to calculate overall packing completion math[cite: 2]. On every checkbox change, recalculate the percentage index and animate the top Sage Green progress bar tracker cleanly[cite: 2].

Incorporate an array handling routine to intercept enter key events on the inline append rows, pushing custom items safely into the state model and local cache instantly[cite: 2].

STEP 3: Implement api.js
Construct an elegant network integration class to interact with the Google Gemini API endpoint[cite: 2].

Read the user key credentials directly out of localStorage.getItem('packright_gemini_key')[cite: 2]. If the string returns null or empty, intercept the code flow, gracefully halt execution, and prompt the user to open the settings gear modal layout[cite: 2].

Format the system instruction strings passed to gemini-2.5-flash to mandate absolute alignment with the Strict JSON Output specifications outlined in Section 4[cite: 2]. Ensure no markdown formatting ticks (such as ```json) wrap the raw response text before parsing the string[cite: 2].

Incorporate a 3-second fallback mock animation timer switch inside the loading loop method to bridge transitions gracefully in case of unexpected network drops or connection dropouts[cite: 2].

PART 7: EXECUTION DIRECTIVE
Begin implementation immediately[cite: 2]. Step through each file sequentially, starting with the baseline DOM frame of index.html, scaling into the state handling architectures of app.js, and concluding with the endpoint configurations of api.js[cite: 2]. Ensure every variable hook maps beautifully across all files for an immediate, flawless browser launch[cite: 2]!