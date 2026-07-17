/**
 * affiliate.js — PackRight Affiliate Feature
 *
 * What this file does (plain English):
 * ─────────────────────────────────────
 * 1. LOADS the affiliate product database (the 20 products in data/affiliates.json)
 * 2. DETECTS the user's country silently using a free IP lookup API
 * 3. MATCHES packing list items to affiliate products using fuzzy search (Fuse.js)
 * 4. PROVIDES a function that app.js calls when building each checklist item row
 * 5. PROVIDES the disclosure text that goes at the bottom of every checklist
 *
 * Golden rule: if ANY part of this file breaks, the rest of PackRight must still
 * work perfectly. Every risky operation is wrapped in try/catch.
 */

// ─────────────────────────────────────────────────────────────────────────────
// MODULE STATE
// These are module-level variables — they live in this file's scope so every
// function below can access them without calling the API more than once.
// "Module-level" just means "stored at the top of the file, shared by all functions."
// ─────────────────────────────────────────────────────────────────────────────

/** @type {Array|null} The loaded list of affiliate products */
let affiliateProducts = null;

/** @type {Fuse|null} The Fuse.js fuzzy search engine instance */
let fuseInstance = null;

/**
 * The user's country code, e.g. "IN", "AE", "GB", or "default"
 * Starts as "default" so links always work even before geo-detection finishes.
 */
let userCountryCode = 'default';

/** Whether the affiliate system has fully loaded */
let affiliateReady = false;


// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 OF AFFILIATE SETUP: Load the product database
//
// What is fetch()? — It's a browser built-in function that downloads a file
// from a URL. Here we use it to read our affiliates.json file.
//
// What is async/await? — Our app needs to wait for the file to download before
// using it. async/await is how we say "wait here, but don't freeze the page."
// ─────────────────────────────────────────────────────────────────────────────

async function loadAffiliateDatabase() {
    try {
        // Fetch the JSON database file. '/data/affiliates.json' is the path from
        // the root of the website — Vercel serves this as a static file.
        const response = await fetch('/data/affiliates.json');

        // Check the response was OK (HTTP 200). If the file was missing it would
        // be a 404 error and we handle that gracefully.
        if (!response.ok) {
            console.warn('[PackRight Affiliates] Could not load affiliates.json — status:', response.status);
            return false;
        }

        const data = await response.json();

        // The products are in data.products — make sure it's actually an array
        if (!data || !Array.isArray(data.products)) {
            console.warn('[PackRight Affiliates] affiliates.json has unexpected format.');
            return false;
        }

        affiliateProducts = data.products;

        // ─── Build Fuse.js index ───────────────────────────────────────────────
        // Fuse.js works by creating an "index" — a pre-processed lookup table
        // that makes fuzzy searching fast. Think of it like a book index that
        // lets you find a word without reading every page.
        //
        // We tell Fuse.js to search inside the 'keywords' array of each product.
        // 'threshold: 0.35' controls how strict the matching is:
        //   - 0.0 = exact match only (very strict)
        //   - 1.0 = matches almost anything (very loose)
        //   - 0.35 = catches typos and minor variations without too many false positives
        // ─────────────────────────────────────────────────────────────────────────
        fuseInstance = new Fuse(affiliateProducts, {
            keys: ['keywords'],
            threshold: 0.35,
            includeScore: true,
            // isCaseSensitive: false is the default, but being explicit is clearer
            isCaseSensitive: false,
            // We search against array items inside keywords, not the array itself
            useExtendedSearch: false,
            // Minimum number of characters before matching kicks in
            minMatchCharLength: 3
        });

        console.log('[PackRight Affiliates] Database loaded:', affiliateProducts.length, 'products.');
        return true;

    } catch (err) {
        // If anything goes wrong (network failure, JSON parse error, etc.),
        // log it quietly and return false. The app will carry on without affiliates.
        console.warn('[PackRight Affiliates] Failed to load database:', err.message);
        return false;
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 OF AFFILIATE SETUP: Detect the user's country
//
// We call a free API called ipapi.co. It looks at the user's IP address
// (the number that identifies their internet connection) and tells us their country.
//
// We set a 3-second timeout: if the API doesn't respond in time, we give up and
// use 'default'. This prevents a slow API from making PackRight feel laggy.
//
// An AbortController is a browser tool that lets us cancel a fetch() request.
// ─────────────────────────────────────────────────────────────────────────────

async function detectUserCountry() {
    try {
        // Create a controller that can cancel our fetch if it takes too long
        const controller = new AbortController();

        // Set a 3-second timer. When it fires, it tells the controller to cancel.
        const timeoutId = setTimeout(() => {
            controller.abort();
        }, 3000);

        const response = await fetch('https://ipapi.co/json/', {
            signal: controller.signal  // link our abort controller to the request
        });

        // Cancel the timeout timer since we got a response in time
        clearTimeout(timeoutId);

        if (!response.ok) {
            console.warn('[PackRight Affiliates] Country detection failed — HTTP', response.status);
            return; // keep userCountryCode as 'default'
        }

        const geoData = await response.json();

        // ipapi.co returns { "country_code": "IN", "country_name": "India", ... }
        // We only need country_code.
        if (geoData && typeof geoData.country_code === 'string' && geoData.country_code.length === 2) {
            userCountryCode = geoData.country_code.toUpperCase();
            console.log('[PackRight Affiliates] Country detected:', userCountryCode);
        } else {
            console.warn('[PackRight Affiliates] Unexpected geo response format.');
        }

    } catch (err) {
        // AbortError means we timed out — totally expected, handle silently
        if (err.name === 'AbortError') {
            console.warn('[PackRight Affiliates] Country detection timed out — using default links.');
        } else {
            // Any other error (network down, ad blocker, etc.) — also silent
            console.warn('[PackRight Affiliates] Country detection error:', err.message);
        }
        // userCountryCode stays as 'default' — everything still works
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// INITIALISER — runs both setup tasks in parallel when the page loads
//
// "In parallel" means both tasks start at the same time instead of one
// waiting for the other. This is faster — like two people each making a
// sandwich instead of one person making both.
//
// Promise.all() is how we run multiple async tasks at the same time.
// ─────────────────────────────────────────────────────────────────────────────

async function initAffiliates() {
    try {
        // Run country detection and database loading at the same time
        const [dbLoaded] = await Promise.all([
            loadAffiliateDatabase(),
            detectUserCountry()
        ]);

        affiliateReady = dbLoaded;

        if (affiliateReady) {
            console.log('[PackRight Affiliates] Ready. Country:', userCountryCode);
        }
    } catch (err) {
        // Should never reach here due to inner try/catches, but just in case
        console.warn('[PackRight Affiliates] Initialisation error:', err.message);
        affiliateReady = false;
    }
}

// Start affiliate setup as soon as this script loads (before DOMContentLoaded)
// Using a self-calling async function pattern (IIFE = Immediately Invoked Function Expression)
(async () => {
    await initAffiliates();
})();


// ─────────────────────────────────────────────────────────────────────────────
// THE MATCHER — called by app.js for each item Gemini returns
//
// This is the "utility function" — a reusable tool that does one job cleanly.
// It takes an item name, searches our database, and returns a match or null.
//
// "null" means "nothing found" — it's a special value in JavaScript for
// "there is no result here."
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Find an affiliate product matching an item name using fuzzy search.
 *
 * @param {string} itemName - The item name from the Gemini response (e.g. "Packing cubes")
 * @returns {Object|null} The matching product object, or null if no match found
 */
function findAffiliateMatch(itemName) {
    // Guard: if the system isn't ready, return null gracefully
    if (!affiliateReady || !fuseInstance || typeof itemName !== 'string') {
        return null;
    }

    try {
        // Normalisation: convert to lowercase so "Packing Cubes" matches "packing cubes"
        // Normalisation means making data consistent so comparisons work reliably.
        const normalised = itemName.toLowerCase().trim();

        if (normalised.length < 2) return null;

        // Run the fuzzy search
        // Fuse.js returns an array of results sorted by relevance (best match first)
        // Each result looks like: { item: { ...productData }, score: 0.12 }
        // A lower score means a better match (0 = perfect, 1 = totally different)
        const results = fuseInstance.search(normalised);

        if (results.length === 0) return null;

        // Take the best match (index 0)
        const bestMatch = results[0];

        // Double-check the score is within our acceptable threshold
        // fuseInstance already filters by threshold, but this is an extra safety check
        if (bestMatch.score > 0.35) return null;

        return bestMatch.item;

    } catch (err) {
        console.warn('[PackRight Affiliates] Matcher error for item:', itemName, err.message);
        return null;
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// LINK RESOLVER — picks the right regional Amazon link for the user's country
//
// Think of it like a postman who looks at the country on the envelope and
// delivers to the right address. If there's no specific address for that country,
// they use the default one.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Get the best affiliate link for the detected country.
 *
 * @param {Object} product - A product object from affiliates.json
 * @returns {string|null} The URL to use, or null if no valid URL exists
 */
function getAffiliateLink(product) {
    if (!product || !product.links) return null;

    try {
        // Try the user's specific country first, then fall back to 'default'
        const url = product.links[userCountryCode] || product.links['default'];

        // Validate that the URL is actually a proper URL before returning it
        // This protects against malformed entries in the JSON file
        if (!url || typeof url !== 'string') return null;

        // new URL() throws an error if the string is not a valid URL
        new URL(url); // validation — if this doesn't throw, the URL is valid

        return url;

    } catch (err) {
        console.warn('[PackRight Affiliates] Invalid URL for product:', product.id, err.message);
        return null;
    }
}


// ─────────────────────────────────────────────────────────────────────────────
// HTML BUTTON BUILDER — called by app.js to get the affiliate button HTML
//
// Instead of building complex HTML inside app.js, we keep that logic here.
// This is called "separation of concerns" — keeping related code together.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Build an affiliate button element for a given item name.
 * Returns null if no match found or if the system is not ready.
 *
 * @param {string} itemName - The packing item name to look up
 * @returns {HTMLElement|null} A styled anchor element, or null if no match
 */
function buildAffiliateButton(itemName) {
    // Step 1: find matching product
    const product = findAffiliateMatch(itemName);
    if (!product) return null;

    // Step 2: resolve the correct regional link
    const url = getAffiliateLink(product);
    if (!url) return null;

    // Step 3: build the button element
    // We create an <a> tag (a hyperlink) programmatically using JavaScript
    const btn = document.createElement('a');
    btn.href = url;
    btn.textContent = product.label || 'Find on Amazon →';

    // Opens in a NEW TAB — essential so users never leave their packing list
    // rel="noopener noreferrer" is a security best practice when opening external links
    btn.target = '_blank';
    btn.rel = 'noopener noreferrer';

    // Inline styles — we use these instead of classes because this button is
    // injected into DOM structure that uses Tailwind, and these precise values
    // need to be exact regardless of Tailwind's purging.
    btn.style.cssText = `
        color: #D4735E;
        font-size: 0.72rem;
        font-family: 'Poppins', sans-serif;
        font-weight: 500;
        text-decoration: none;
        white-space: nowrap;
        flex-shrink: 0;
        padding: 1px 6px;
        border-radius: 4px;
        transition: opacity 0.15s ease;
        letter-spacing: 0.01em;
    `;

    // Hover effect — underline appears on hover so it feels interactive
    btn.addEventListener('mouseenter', () => {
        btn.style.textDecoration = 'underline';
        btn.style.opacity = '0.8';
    });
    btn.addEventListener('mouseleave', () => {
        btn.style.textDecoration = 'none';
        btn.style.opacity = '1';
    });

    return btn;
}


// ─────────────────────────────────────────────────────────────────────────────
// DISCLOSURE LINE — always shown at the bottom of every generated checklist
//
// This is a legal requirement from Amazon Associates Terms of Service.
// It must ALWAYS appear when affiliate links are displayed.
// We make it unconditional — it shows even if no links matched,
// because future checklist items might match.
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Build the legal disclosure element to place at the bottom of the checklist.
 *
 * @returns {HTMLElement} A paragraph element with the disclosure text
 */
function buildDisclosureElement() {
    const p = document.createElement('p');
    p.id = 'affiliate-disclosure';
    p.textContent = 'Some items link to Amazon and other retailers. PackRight earns a small commission at no extra cost to you.';
    p.style.cssText = `
        font-size: 11px;
        color: #999999;
        text-align: center;
        margin-top: 16px;
        margin-bottom: 8px;
        font-family: 'Inter', sans-serif;
        line-height: 1.5;
        padding: 0 16px;
    `;
    return p;
}


// ─────────────────────────────────────────────────────────────────────────────
// EXPORTS — make our functions available to app.js
//
// Since this is a plain JS file (not a module), we attach functions to the
// window object. The window object is the global container for everything
// in a browser tab — attaching to it makes functions available everywhere.
// ─────────────────────────────────────────────────────────────────────────────

window.PackRightAffiliates = {
    buildAffiliateButton,
    buildDisclosureElement,
    findAffiliateMatch,
    getAffiliateLink,
    isReady: () => affiliateReady,
    getCountry: () => userCountryCode
};
