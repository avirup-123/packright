import os
import shutil
import re

source = r"C:\Users\Avirup\Pictures\Product\packright-2.0\stitch_packright_ai_travel_assistant\packright_minimalist_boutique_home_4.0_global_alignment\code.html"
target = r"C:\Users\Avirup\Pictures\Product\packright-2.0\index.html"

with open(source, "r", encoding="utf-8") as f:
    html = f.read()

# Add aliases
html = html.replace('"colors": {', '"colors": { "success": "#5F8567", "neutralText": "#1d1b19", "baseCanvas": "#fef8f3",')

# Add PWA, GA4, App scripts to <head>
head_additions = """
    <!-- PWA / App Meta Tags -->
    <link rel="manifest" href="/manifest.json">
    <meta name="theme-color" content="#964331">
    <link rel="apple-touch-icon" href="https://raw.githubusercontent.com/avirupsarker1999/packright-2.0/main/public/logo.png">
    
    <script>
      if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
          navigator.serviceWorker.register('/sw.js').then(registration => {
            console.log('ServiceWorker registration successful');
          }).catch(err => {
            console.log('ServiceWorker registration failed: ', err);
          });
        });
      }
    </script>
    
    <!-- Google Analytics 4 -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-VNWZ3GJHRZ"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-VNWZ3GJHRZ');
    </script>
    
    <!-- App scripts -->
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="https://cdn.jsdelivr.net/npm/fuse.js@7.0.0/dist/fuse.min.js"></script>
    <script src="/affiliate.js"></script>
    <script src="/api.js" defer></script>
    <script src="/app.js" defer></script>
    
    <style>
        /* Voice Button Listening State Pulse Activation */
        #voiceInputBtn.is-listening .animate-ping,
        #voiceInputBtnClarifier.is-listening .animate-ping {
            opacity: 0.4;
        }
    </style>
"""
html = html.replace('</head>', head_additions + '\n</head>')

# Add IDs to the launchpad section
html = re.sub(
    r'<div class="w-full max-w-4xl bg-surface-card rounded-2xl p-8 md:p-12 soft-shadow mb-20">',
    r'<div id="screen-launchpad" class="w-full max-w-4xl bg-surface-card rounded-2xl p-8 md:p-12 soft-shadow mb-20">',
    html, count=1
)
html = re.sub(
    r'<textarea class="w-full border-none bg-transparent p-6 h-48 focus:ring-0 resize-none text-body-lg font-body-lg text-on-surface placeholder:text-secondary/50"',
    r'<textarea id="mainPromptInput" class="w-full border-none bg-transparent p-6 h-48 focus:ring-0 resize-none text-body-lg font-body-lg text-on-surface placeholder:text-secondary/50"',
    html, count=1
)
html = re.sub(
    r'<button class="w-10 h-10 rounded-full bg-brand-terracotta/10 flex items-center justify-center text-brand-terracotta hover:bg-brand-terracotta/20 transition-colors">\s*<span class="material-symbols-outlined text-\[20px\]">mic</span>\s*</button>',
    r'''<button id="voiceInputBtn" class="w-10 h-10 flex items-center justify-center rounded-full bg-brand-terracotta text-white shadow-lg hover:opacity-90 active:scale-95 transition-all group relative">
                <span class="material-symbols-outlined text-[20px]">mic</span>
                <span class="absolute inset-0 rounded-full bg-brand-terracotta animate-ping opacity-0"></span>
            </button>''',
    html, count=1
)
html = re.sub(
    r'<button class="w-full bg-brand-terracotta text-on-primary rounded-lg py-4 text-title-lg font-title-lg hover:bg-brand-terracotta-dark transition-all transform hover:scale-\[1.01\] active:scale-\[0.99\] shadow-lg shadow-brand-terracotta/20">\s*Generate My Packing List\s*</button>',
    r'<button id="launchpadNextBtn" class="w-full bg-brand-terracotta text-on-primary rounded-lg py-4 text-title-lg font-title-lg hover:bg-brand-terracotta-dark transition-all transform hover:scale-[1.01] active:scale-[0.99] shadow-lg shadow-brand-terracotta/20">Generate My Packing List</button>',
    html, count=1
)

# App Screens and Templates
app_screens_html = """
        <!-- SCREEN 1.5: Clarifier -->
        <div id="screen-clarifier" class="w-full max-w-4xl bg-surface-card rounded-2xl p-8 md:p-12 soft-shadow mb-20 hidden flex-col">
            <h2 class="font-headline-lg text-headline-lg md:text-[32px] text-center mb-10 text-on-surface">Just a few quick details to perfect your list:</h2>
            <div id="clarifierQuestionsContainer" class="flex-1 flex flex-col gap-6 overflow-y-auto pb-4">
                <!-- Dynamically injected questions -->
            </div>
            <div class="mt-4 mb-2">
                <h3 class="font-title-lg text-base md:text-lg mb-2 text-on-surface">Anything else to add? <span class="text-on-surface-variant font-normal">(Optional)</span></h3>
                <div class="relative mb-8 bg-surface-container-lowest border border-outline-variant/30 rounded-xl overflow-hidden">
                    <textarea id="clarifierContextInput" class="w-full border-none bg-transparent p-4 h-32 focus:ring-0 resize-none text-body-md font-body-md text-on-surface placeholder:text-secondary/50" placeholder="e.g., Oh, I'll also need to pack for a day trip to the mountains..."></textarea>
                    <div class="absolute bottom-4 right-4 flex items-center gap-2">
                        <button id="voiceInputBtnClarifier" class="w-10 h-10 flex items-center justify-center rounded-full bg-brand-terracotta text-white shadow hover:opacity-90 active:scale-95 transition-all group relative">
                            <span class="material-symbols-outlined text-[20px]">mic</span>
                            <span class="absolute inset-0 rounded-full bg-brand-terracotta animate-ping opacity-0"></span>
                        </button>
                    </div>
                </div>
            </div>
            <button id="buildListBtn" class="w-full bg-brand-terracotta text-on-primary rounded-lg py-4 text-title-lg font-title-lg hover:bg-brand-terracotta-dark transition-all transform hover:scale-[1.01] active:scale-[0.99] shadow-lg shadow-brand-terracotta/20">Build My Packing List</button>
        </div>

        <!-- SCREEN 2: Brainstorm (Loading) -->
        <div id="screen-brainstorm" class="w-full max-w-4xl bg-surface-card rounded-2xl p-8 md:p-12 soft-shadow mb-20 hidden flex-col justify-center items-center">
            <div class="relative w-32 h-32 mb-8 mt-10">
                <div class="absolute inset-0 bg-brand-terracotta/20 rounded-full animate-ping"></div>
                <div class="absolute inset-2 bg-brand-terracotta/30 rounded-full animate-pulse"></div>
                <div class="absolute inset-0 flex items-center justify-center text-brand-terracotta">
                    <svg class="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M20.25 10.5h-16.5c-.828 0-1.5.672-1.5 1.5v7.5c0 .828.672 1.5 1.5 1.5h16.5c.828 0 1.5-.672 1.5-1.5v-7.5c0-.828-.672-1.5-1.5-1.5z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8.25 10.5V6c0-.828.672-1.5 1.5-1.5h4.5c.828 0 1.5.672 1.5 1.5v4.5"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M12 14.5v3"></path></svg>
                </div>
            </div>
            <h2 id="loadingText" class="font-headline-md text-2xl font-medium text-center transition-opacity duration-300 text-on-surface mb-10">Analyzing your destination's climate profile...</h2>
        </div>

        <!-- SCREEN 3: Packing Canvas -->
        <div id="screen-packing" class="w-full max-w-4xl bg-surface-card rounded-2xl p-0 soft-shadow mb-20 hidden flex-col relative overflow-hidden border-t-4 border-brand-terracotta">
            <div class="sticky top-0 z-10 bg-white/95 backdrop-blur-md px-6 py-4 shadow-sm border-b border-outline-variant/10">
                <div class="flex justify-between items-center mb-4">
                    <h2 id="tripTitleDisplay" class="font-headline-md text-2xl font-bold truncate pr-4 text-brand-terracotta">Your Trip</h2>
                    <div class="flex items-center gap-2">
                        <button id="shareTripBtn" class="text-sm px-4 py-2 rounded-xl bg-brand-terracotta/10 hover:bg-brand-terracotta/20 text-brand-terracotta font-semibold transition-all flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[18px]">share</span>
                            <span class="hidden sm:inline">Share</span>
                        </button>
                        <button id="newTripBtn" class="text-sm px-4 py-2 rounded-xl bg-outline-variant/20 hover:bg-outline-variant/30 text-on-surface font-semibold transition-all flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[18px]">add_circle</span>
                            <span class="hidden sm:inline">New</span>
                        </button>
                    </div>
                </div>
                <div class="flex justify-between items-end mb-2">
                    <span id="progressText" class="text-label-md font-semibold text-on-surface-variant">0 / 0 Items Packed</span>
                </div>
                <div class="w-full bg-surface-variant rounded-full h-2.5 overflow-hidden">
                    <div id="progressBar" class="bg-brand-terracotta h-2.5 rounded-full transition-all duration-500 ease-out" style="width: 0%"></div>
                </div>
            </div>
            
            <div id="packingListContainer" class="flex-1 overflow-y-auto p-4 md:p-8 flex flex-col gap-6 pb-32">
                <!-- Dynamically injected category cards -->
            </div>

            <div class="px-6 py-4 bg-white/95 backdrop-blur-md border-t border-outline-variant/10 z-10 sticky bottom-0">
                <button id="donePackingBtn" class="w-full bg-brand-terracotta text-on-primary font-title-lg text-lg py-4 rounded-xl shadow-lg hover:shadow-xl hover:bg-brand-terracotta-dark transition-colors duration-300 transform active:scale-[0.98]">I'm Done, Thanks!</button>
            </div>
        </div>

        <!-- SCREEN 4: Success -->
        <div id="screen-success" class="w-full max-w-4xl bg-surface-card rounded-2xl p-8 md:p-12 soft-shadow mb-20 hidden flex-col justify-center items-center">
            <div class="w-24 h-24 bg-[#5F8567] text-white rounded-full flex items-center justify-center mb-6 shadow-xl animate-bounce mt-10">
                <span class="material-symbols-outlined text-[48px]">flight_takeoff</span>
            </div>
            <h1 class="font-headline-lg text-4xl font-bold text-[#5F8567] mb-4">You're All Set!</h1>
            <p class="font-body-md text-lg text-on-surface-variant mb-10 text-center">Your bags are perfectly packed and you are ready for your adventure. Have a Great Trip!</p>
            <button id="successNewTripBtn" class="px-8 py-4 bg-white text-[#5F8567] border-2 border-[#5F8567] font-title-lg font-semibold text-lg rounded-xl shadow hover:bg-[#5F8567]/5 transition-all mb-10">Plan Another Trip</button>
        </div>

        <!-- Voice Input Toast -->
        <div id="voiceToast" class="fixed bottom-24 left-1/2 -translate-x-1/2 z-50 pointer-events-none opacity-0 transition-opacity duration-300">
            <div class="bg-inverse-surface text-inverse-on-surface px-6 py-3 rounded-full flex items-center gap-2 shadow-lg">
                <span class="w-2.5 h-2.5 rounded-full bg-brand-terracotta animate-pulse"></span>
                <span class="font-medium text-sm">Listening...</span>
            </div>
        </div>
        
        <!-- Settings Modal -->
        <div id="settingsModal" class="fixed inset-0 bg-inverse-surface/50 z-50 hidden items-center justify-center backdrop-blur-sm p-4">
            <div class="bg-surface-card rounded-2xl p-6 w-full max-w-md shadow-xl border border-outline-variant/10">
                <h2 class="font-headline-md text-xl font-semibold mb-4 text-on-surface">Settings</h2>
                <div class="mb-4">
                    <label class="block text-sm font-medium mb-2 text-on-surface-variant" for="supabaseUrlInput">Supabase URL</label>
                    <input type="text" id="supabaseUrlInput" class="w-full rounded-xl border border-outline-variant/30 px-4 py-3 bg-surface-container-low focus:outline-none focus:ring-2 focus:ring-brand-terracotta shadow-sm font-body-md text-on-surface">
                </div>
                <div class="mb-6">
                    <label class="block text-sm font-medium mb-2 text-on-surface-variant" for="supabaseKeyInput">Supabase Anon Key</label>
                    <input type="password" id="supabaseKeyInput" class="w-full rounded-xl border border-outline-variant/30 px-4 py-3 bg-surface-container-low focus:outline-none focus:ring-2 focus:ring-brand-terracotta shadow-sm font-body-md text-on-surface">
                </div>
                <div class="flex justify-end gap-2">
                    <button id="closeSettingsBtn" class="px-5 py-2.5 rounded-xl font-medium text-on-surface bg-surface-variant hover:bg-outline-variant/30 transition-colors">Cancel</button>
                    <button id="saveSettingsBtn" class="px-5 py-2.5 rounded-xl font-medium text-white bg-brand-terracotta hover:bg-brand-terracotta-dark transition-colors shadow-md">Save</button>
                </div>
            </div>
        </div>
        
        <!-- Share Modal -->
        <div id="shareModal" class="fixed inset-0 bg-inverse-surface/50 z-50 hidden items-center justify-center backdrop-blur-sm p-4">
            <div class="bg-surface-card rounded-2xl p-6 w-full max-w-sm shadow-xl relative border border-outline-variant/10">
                <h2 class="font-headline-md text-xl font-semibold mb-4 text-center text-on-surface">Share your Packing List</h2>
                <div class="flex flex-col gap-3">
                    <a id="shareWhatsappBtn" target="_blank" class="flex items-center justify-center gap-2 px-4 py-3 bg-[#25D366] text-white rounded-xl font-medium transition hover:opacity-90">WhatsApp</a>
                    <a id="shareEmailBtn" target="_blank" class="flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 text-white rounded-xl font-medium transition hover:bg-blue-700">Email</a>
                    <button id="shareCopyBtn" class="flex items-center justify-center gap-2 px-4 py-3 bg-white text-on-surface border border-outline-variant/30 rounded-xl font-medium transition hover:bg-surface-variant/30">Copy to Clipboard</button>
                </div>
                <button id="closeShareModalBtn" class="absolute top-4 right-4 p-2 rounded-full hover:bg-surface-variant/50 text-on-surface-variant transition-colors">
                    <span class="material-symbols-outlined text-[20px]">close</span>
                </button>
            </div>
        </div>
"""
html = html.replace('<!-- How It Works Section -->', app_screens_html + '\n<!-- How It Works Section -->')

templates = """
    <template id="questionTemplate">
        <div class="bg-surface-container-low rounded-xl p-6 border border-outline-variant/20">
            <h3 class="font-title-lg text-lg mb-4 text-on-surface"></h3>
            <div class="options-container flex flex-wrap gap-2"></div>
        </div>
    </template>

    <template id="categoryTemplate">
        <div class="bg-white rounded-2xl shadow-sm border border-outline-variant/20 overflow-hidden mb-4">
            <button class="category-header w-full px-6 py-4 flex justify-between items-center bg-white hover:bg-surface-variant/30 transition-colors focus:outline-none border-b border-outline-variant/10">
                <div class="flex items-center gap-2.5">
                    <span class="category-title font-title-lg font-semibold text-lg text-on-surface"></span>
                </div>
                <span class="material-symbols-outlined chevron transition-transform duration-200 text-on-surface-variant">expand_more</span>
            </button>
            <div class="category-content p-4 md:p-6 bg-surface-container-lowest">
                <div class="items-list flex flex-col divide-y divide-outline-variant/10"></div>
                <div class="mt-4 relative flex items-center">
                    <input type="text" class="add-item-input w-full pl-4 pr-12 py-3 bg-surface-container-low border border-outline-variant/30 rounded-xl focus:border-brand-terracotta focus:ring-1 focus:ring-brand-terracotta font-body-md text-on-surface placeholder:text-secondary/50 shadow-sm" placeholder="Add custom item...">
                    <button class="add-item-btn absolute right-2 text-brand-terracotta p-2 rounded-full hover:bg-brand-terracotta/10 transition-colors">
                        <span class="material-symbols-outlined">add</span>
                    </button>
                </div>
            </div>
        </div>
    </template>

    <template id="itemTemplate">
        <label class="item-row p-3 flex items-start gap-3 hover:bg-surface-container-low transition-colors cursor-pointer select-none rounded-lg">
            <div class="checkbox-btn mt-0.5 flex-shrink-0 w-6 h-6 rounded border-2 border-outline/40 flex items-center justify-center text-white transition-colors focus:outline-none">
                <span class="material-symbols-outlined check-icon text-[16px] text-white opacity-0 transition-opacity">check</span>
            </div>
            <div class="flex-1 flex flex-col pointer-events-none">
                <div class="flex flex-wrap items-center gap-2">
                    <span class="item-name font-medium text-base text-on-surface transition-all"></span>
                    <span class="luggage-badge text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider bg-outline-variant/20 text-on-surface-variant"></span>
                </div>
                <span class="item-context text-[12px] text-on-surface-variant/70 italic mt-0.5"></span>
            </div>
        </label>
    </template>
"""
html = html.replace('</body>', templates + '\n</body>')

# Handle Auth Container exactly as it was requested
auth_html = """
    <div id="authContainer" class="flex items-center space-x-6">
        <button id="loginBtn" class="px-5 py-2.5 bg-brand-terracotta text-white rounded-xl hover:bg-brand-terracotta-dark transition-colors font-medium text-sm flex items-center gap-2 shadow-sm">
            Sign in
        </button>
        <div id="userProfile" class="hidden items-center space-x-4">
            <div class="flex items-center space-x-2">
                <img id="userAvatar" alt="User" class="w-8 h-8 rounded-full border border-outline-variant" src="">
                <button id="logoutBtn" class="text-on-surface-variant hover:text-brand-terracotta transition-colors text-label-md font-label-md">Sign out</button>
            </div>
            <button id="openSettingsBtn" class="text-on-surface-variant hover:text-brand-terracotta transition-colors">
                <span class="material-symbols-outlined text-[20px]">settings</span>
            </button>
        </div>
    </div>
"""
# Find the auth block in nav and replace it
html = re.sub(
    r'<div class="hidden md:flex items-center space-x-6">.*?</div>\s*</div>\s*</nav>',
    f'{auth_html}\n</div>\n</nav>',
    html, flags=re.DOTALL
)

# Apply logo fixes from earlier
logo_img_tag_nav = '<a href="/"><img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXbMettLeFWSDDTGuV5qCwTBUOt-C4o-Sp5NKRkDyPyQawx0k_Or0-CAZ_joRK7e79mHWr9G-1HBwXCZp1CawHYQwrGjZw-IC-OcNLPSf8cWNV2r_5Edv7LU1Rus_W7nwwm9IkA18ZGMnIF35xlemEH6voDiPF2iqobpDfDR-d_ChhzXBVYJpKgia8YNoTyZojchdRbrr5L-f5Y30b6ebzMzHchu3D_2CVzBrLYfb6XOS9H39a9rDUGSBj5SCnDShR" alt="PackRight Logo" class="h-10 w-auto object-contain"></a>'
logo_img_tag_footer = '<a href="/"><img src="https://lh3.googleusercontent.com/aida-public/AB6AXuCXbMettLeFWSDDTGuV5qCwTBUOt-C4o-Sp5NKRkDyPyQawx0k_Or0-CAZ_joRK7e79mHWr9G-1HBwXCZp1CawHYQwrGjZw-IC-OcNLPSf8cWNV2r_5Edv7LU1Rus_W7nwwm9IkA18ZGMnIF35xlemEH6voDiPF2iqobpDfDR-d_ChhzXBVYJpKgia8YNoTyZojchdRbrr5L-f5Y30b6ebzMzHchu3D_2CVzBrLYfb6XOS9H39a9rDUGSBj5SCnDShR" alt="PackRight Logo" class="h-16 w-auto object-contain mb-2"></a>'

html = html.replace('<div class="text-headline-md font-headline-md font-bold text-brand-terracotta">PackRight</div>', logo_img_tag_nav)
html = html.replace('<div class="text-headline-md font-headline-md font-bold text-brand-terracotta mb-2">PackRight</div>', logo_img_tag_footer)

html = html.replace('<a class="text-on-surface-variant hover:text-brand-terracotta transition-colors text-label-md" href="#">Europe</a>', '<a class="text-on-surface-variant hover:text-brand-terracotta transition-colors text-label-md" href="/packing-list/europe">Europe</a>')
html = html.replace('<a class="text-on-surface-variant hover:text-brand-terracotta transition-colors text-label-md" href="#">Asia</a>', '<a class="text-on-surface-variant hover:text-brand-terracotta transition-colors text-label-md" href="/packing-list/japan">Japan</a>')

# Save
with open(target, "w", encoding="utf-8") as f:
    f.write(html)
