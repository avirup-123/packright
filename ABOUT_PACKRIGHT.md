# PackRight: Project Overview & LLM Context File

## 1. What is PackRight?
PackRight is an intelligent, context-driven Travel Packing Assistant and Luggage Optimization Checklist. Instead of acting as a static checklist app that relies on generic templates, PackRight operates as an interactive AI rule engine. It uses Large Language Models (LLMs) to parse unstructured user input and generate highly specific, context-aware packing lists tailored to exact trip parameters (climate, culture, luggage restrictions, etc.).

**Live URL:** [https://packright-20.vercel.app](https://packright-20.vercel.app)

## 2. What Does it Do? (Core User Journey)
1. **The Launchpad:** The user enters a natural language description of their trip (e.g., *"12 days in Tokyo in chilly March, backpacker hostels, budget airlines"*). Users can type this or use the integrated Web Speech API for voice input.
2. **The Clarifier (AI Interview):** The app queries the AI to instantly generate 2-3 multiple-choice clarifying questions to resolve any ambiguity in the user's prompt (e.g., asking about primary activities or specific accommodation styles).
3. **The Brainstorm (Generation):** The AI synthesizes the initial prompt and clarifying answers into a strict JSON payload. 
4. **The Packing Canvas:** The app renders a fully interactive checklist. Crucially, the AI explains *why* an item is needed (e.g., "Universal Plug Adapter" -> *"Japan operates on Type A/B flat 2-prong plugs"*) and assigns a luggage target (Carry-on vs. Checked).
5. **Real-Time Syncing:** As the user checks off items or adds manual custom items, the state is saved to the local browser and simultaneously synced to a Supabase PostgreSQL database.

## 3. Who is it For?
The application is designed for a target persona internally named **"Priya, the Prepared Planner"**:
- **Demographics:** Frequent global traveler (business and leisure).
- **Pain Point:** She has previously suffered logistical or financial consequences from forgetting critical, high-stakes items (prescription meds, adapters, visas). She despises rigid, slow form-filling.
- **Goal:** She needs a trusted "second brain" that eliminates mental fatigue and anxiety late the night before a flight. The UX is optimized for speed, warmth, and high scannability.

## 4. Technical Architecture & Stack
The application is built deliberately as a lightweight, no-build vanilla web application, making it incredibly fast and easy to maintain.

- **Frontend UI:** Pure HTML5 and Vanilla JavaScript.
- **Styling:** Tailwind CSS (injected via CDN) utilizing a warm, custom "stationery" palette (`#FAF6F0` Sand, `#E06A4E` Terracotta, `#5F8567` Sage Green).
- **AI Engine:** Google Gemini (`gemini-2.5-flash` model). Called directly via REST API endpoints to generate strict JSON schemas.
- **Database & Backend:** Supabase (PostgreSQL).
- **Authentication:** Supabase Auth using Google OAuth providers.
- **Security:** Strict Supabase Row Level Security (RLS) is implemented so authenticated users can only `SELECT`, `INSERT`, `UPDATE`, or `DELETE` trips matching their own `auth.uid()`.
- **Hosting:** Deployed on Vercel.

## 5. Directory & File Structure
- `index.html`: The single-page application structure. Contains all view screens (hidden/shown via utility classes), the Tailwind configuration, and the Google Sign-in UI.
- `app.js`: The core state manager. Handles DOM manipulation, view routing, Supabase initialization, OAuth listener states, Voice API logic, and localStorage/cloud sync routines.
- `api.js`: The AI network layer. Houses the logic for communicating with the Gemini API and structuring the `system_instruction` prompts to ensure the AI responds in pure JSON.
- `supabase_schema.sql`: The database migration file containing table creation instructions and the RLS security policies.
- `robots.txt` / `sitemap.xml`: SEO fundamentals for web crawler indexing.

## 6. Development Context for LLMs
If you are an AI reading this file to establish context for future coding tasks:
- **Do not introduce build tools:** Do not convert this project to React, Next.js, Webpack, or Vite unless explicitly instructed. The architecture relies on vanilla web technologies.
- **Mobile-First CSS:** The styling relies heavily on Tailwind's responsive prefixes (`md:`, `sm:`). Always ensure UI additions account for narrow mobile viewports.
- **State Management:** The single source of truth for the active session is the `appState.activeTrip` object in `app.js`. Any modifications to the checklist must update this object and trigger the `saveTripState()` function to ensure Supabase sync.
