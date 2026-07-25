import os
import re
import codecs

with codecs.open('packing-list/japan/index.html', 'r', 'utf-8') as f:
    html = f.read()

# 1. Meta Tags
html = re.sub(r'<title>.*?</title>', '<title>Niseko Skiing Packing List: 15 Essentials You\'re Forgetting (2024)</title>', html)
html = re.sub(r'<meta name="description" content="[^"]*">', '<meta name="description" content="Don\'t get caught in the Hokkaido cold. Get a personalized, AI-generated Niseko ski trip checklist. Expert tips on gear, layers, and Hirafu essentials.">', html)
html = re.sub(r'<meta property="og:title" content="[^"]*">', '<meta property="og:title" content="Niseko Skiing Packing List: 15 Essentials You\'re Forgetting (2024)">', html)
html = re.sub(r'<meta property="og:description" content="[^"]*">', '<meta property="og:description" content="Don\'t get caught in the Hokkaido cold. Get a personalized, AI-generated Niseko ski trip checklist. Expert tips on gear, layers, and Hirafu essentials.">', html)
html = re.sub(r'https://packright-20\.vercel\.app/packing-list/japan(?!/niseko)', 'https://packright-20.vercel.app/packing-list/japan/niseko-skiing', html)

# Canonical
html = re.sub(r'<link rel="canonical" href="[^"]*">', '<link rel="canonical" href="https://packright-20.vercel.app/packing-list/japan/niseko-skiing">', html)

# Replace Product Schema with WebApplication Schema
old_product_schema = r'<script type="application/ld\+json">\s*\{\s*"@context": "https://schema\.org",\s*"@type": "Product".*?</script>'
new_app_schema = '''<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebApplication",
  "name": "PackRight AI Packing List Generator - Niseko",
  "applicationCategory": "TravelApplication",
  "operatingSystem": "Any",
  "description": "Interactive AI tool to generate personalized packing lists for Niseko skiing and other destinations.",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  }
}
</script>'''
html = re.sub(old_product_schema, new_app_schema, html, flags=re.DOTALL)

# 2. Breadcrumbs
old_nav = r'<nav class="font-poppins text-xs text-neutralText/50 mb-4 flex items-center gap-1.5" aria-label="Breadcrumb">.*?</nav>'
new_nav = '''<nav class="font-poppins text-xs text-neutralText/50 mb-4 flex items-center gap-1.5" aria-label="Breadcrumb">
            <a href="/" class="hover:text-primary transition-colors">Home</a>
            <span class="text-neutralText/30">&gt;</span>
            <a href="/packing-list/japan" class="hover:text-primary transition-colors">Japan</a>
            <span class="text-neutralText/30">&gt;</span>
            <span class="text-neutralText/80 font-medium">Niseko Skiing</span>
        </nav>'''
html = re.sub(old_nav, new_nav, html, flags=re.DOTALL)

# 3. H1
html = re.sub(r'<h1 class="[^"]*">Your Packing Checklist for Japan 👇</h1>', '<h1 class="font-outfit italic text-primary text-3xl md:text-5xl font-bold leading-tight mb-4">Niseko Skiing Packing List: Your AI-Powered Guide 👇</h1>', html)

# 4. Intro Paragraph -> The Hook Callout Box + Context Block
old_p = r'<p class="font-poppins text-neutralText/70 text-\[15px\] md:text-\[16px\] leading-\[1.6\] max-w-3xl">.*?</p>'
new_intro = '''<div class="bg-primary/5 border border-primary/20 rounded-2xl p-5 mb-6 shadow-sm max-w-3xl">
            <p class="font-poppins text-neutralText/80 text-[15px] md:text-[16px] leading-[1.6]">
                Tired of reading 3,000-word blogs? Skip the fluff. Use our interactive AI tool below to get your personalized Niseko gear list in 4 seconds.
            </p>
        </div>
        <div class="prose prose-neutral max-w-3xl font-poppins text-neutralText/70 text-[15px] md:text-[16px] leading-[1.6] mb-6">
            <p class="mb-4">
                Niseko is world-renowned for its 'Japow'—the legendary dry, light powder snow that falls consistently throughout the winter. However, packing for Niseko is different than packing for the Alps or the Rockies. The Hokkaido climate is biting, and the wind off the Sea of Japan means you need a technical layering system that prioritizes wind-blocking and moisture management.
            </p>
            <p>
                Beyond the slopes, Niseko’s social heart, Hirafu Village, has a unique 'Ski-Chic' but casual vibe. You’ll need footwear that can handle icy, unpaved roads and layers that work for transition from sub-zero temperatures to the humid warmth of a traditional Japanese Onsen. This guide and our AI tool are designed to ensure you have the technical gear for the 'Deep Powder' days and the cultural essentials for a respectful and comfortable stay in Japan.
            </p>
        </div>'''
html = re.sub(old_p, new_intro, html, flags=re.DOTALL)

# 5. Pre-filled Prompt & Clarifier Questions
html = re.sub(
    r'<textarea id="mainPromptInput"([^>]*)>.*?</textarea>',
    r'<textarea id="mainPromptInput"\1>7 days skiing in Niseko in February. Staying in Hirafu. Mix of resort and off-piste. Need a list for technical gear, base layers, and après-ski.</textarea>',
    html, flags=re.DOTALL
)

# For the Clarifier questions, we can inject them into the clarifierQuestionsContainer for visual SEO and demo purposes.
clarifier_container = r'<div id="clarifierQuestionsContainer" class="flex-1 flex flex-col gap-4 md:gap-6 overflow-y-auto pb-4">\s*<!-- Dynamically injected questions will go here -->\s*</div>'
clarifier_html = '''<div id="clarifierQuestionsContainer" class="flex-1 flex flex-col gap-4 md:gap-6 overflow-y-auto pb-4">
                    <div class="question-card bg-white rounded-2xl p-5 border border-neutralText/5 shadow-sm">
                        <h3 class="font-medium text-lg mb-3">Beyond skiing, what non-skiing activities are you planning?</h3>
                        <div class="options-container flex flex-wrap gap-2">
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Onsens</button>
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Fine Dining</button>
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Sightseeing</button>
                        </div>
                    </div>
                    <div class="question-card bg-white rounded-2xl p-5 border border-neutralText/5 shadow-sm">
                        <h3 class="font-medium text-lg mb-3">Bringing your own gear or renting?</h3>
                        <div class="options-container flex flex-wrap gap-2">
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Full Gear</button>
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Small Gear Only</button>
                            <button class="px-4 py-2 rounded-xl border border-neutralText/20 text-sm font-medium hover:border-primary transition-colors">Renting Everything</button>
                        </div>
                    </div>
                </div>'''
html = re.sub(clarifier_container, clarifier_html, html, flags=re.DOTALL)

# 6. Expert Tip
old_tip = r'<div class="w-full max-w-5xl mx-auto px-4 md:px-0 mb-8">\s*<div class="bg-primary/5 border border-primary/20 rounded-2xl p-5 flex items-start gap-4 shadow-sm">.*?</div>\s*</div>'
new_tip = '''<div class="w-full max-w-5xl mx-auto px-4 md:px-0 mb-8">
        <div class="bg-primary/5 border border-primary/20 rounded-2xl p-5 flex items-start gap-4 shadow-sm">
            <span class="material-symbols-outlined text-primary text-[28px] shrink-0 mt-0.5" style="font-variation-settings: \'FILL\' 1;">lightbulb</span>
            <div>
                <h3 class="font-outfit italic font-bold text-neutralText text-base md:text-lg mb-1">PackRight Insider Tip</h3>
                <p class="font-poppins text-neutralText/70 text-sm leading-relaxed">
                    Pack a high-quality zinc-based sunblock and a neck gaiter. The Hokkaido sun reflecting off the snow is intense even on cloudy days!
                </p>
            </div>
        </div>
    </div>'''
html = re.sub(old_tip, new_tip, html, flags=re.DOTALL)

# 7. FAQ Schema
old_schema = r'<script type="application/ld\+json">\s*\{\s*"@context": "https://schema\.org",\s*"@type": "FAQPage".*?</script>'
new_schema = '''<script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "What kind of ski goggles are best for Niseko?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Low-Light or Rose-tinted lenses for flat-light powder days."
          }
        },
        {
          "@type": "Question",
          "name": "Do I need formal clothes for Hirafu Village?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "No, the vibe is 'Ski-Chic' and casual. Focus on warm boots and nice layers."
          }
        },
        {
          "@type": "Question",
          "name": "Should I pack my own skis or rent?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Renting is popular to avoid dragging bags on the Shinkansen; shops like Rhythm Japan carry top powder gear."
          }
        },
        {
          "@type": "Question",
          "name": "How do I handle luggage from the airport?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Use Yamato Transport (Takkyubin) to ship bags directly from New Chitose to your resort."
          }
        },
        {
          "@type": "Question",
          "name": "Will my electronics work?",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "Yes, Type A/B plugs. Pack a cold-resistant power bank as batteries die fast in the Hokkaido cold."
          }
        }
      ]
    }
    </script>'''
html = re.sub(old_schema, new_schema, html, flags=re.DOTALL)

# 8. Sample List and Contextual Links and FAQ HTML replacement
start_marker = r'<!-- Static Preview Section / Sample Packing List for Japan -->'
end_marker = r'<!-- Return CTA Section -->'

pattern = start_marker + r'.*?' + end_marker

replacement = '''<!-- Static Preview Section / Sample List for Niseko -->
    <div class="w-full max-w-5xl mx-auto px-4 md:px-0 mb-8">
        <div class="bg-white rounded-3xl shadow-xl border border-neutralText/5 overflow-hidden flex flex-col mb-8">
            <div class="p-6 md:p-8 bg-white border-b border-neutralText/5">
                <div class="flex flex-col gap-2">
                    <h2 class="font-outfit italic text-primary text-2xl md:text-3xl">Sample List: 15 Niseko Ski Essentials</h2>
                    <p class="font-poppins text-neutralText/80 text-sm md:text-base leading-relaxed bg-baseCanvas/40 p-4 rounded-2xl border border-neutralText/5 mt-2">
                        <strong>Trip Details:</strong> 7 days skiing in Niseko in February. Staying in Hirafu. Mix of resort and off-piste. Need a list for technical gear, base layers, and après-ski.
                    </p>
                </div>
            </div>
            
            <div class="p-4 md:p-6 bg-baseCanvas/10">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Category: Technical Gear -->
                    <div class="bg-white rounded-2xl shadow-sm border border-neutralText/5 overflow-hidden transition-all hover:shadow-md h-fit">
                        <button class="w-full px-5 py-4 flex justify-between items-center bg-white hover:bg-neutralText/5 transition-colors sample-category-header focus:outline-none border-b border-neutralText/5">
                            <div class="flex items-center gap-2.5">
                                <span class="font-outfit font-semibold text-base md:text-lg text-neutralText">Technical Gear & Layers</span>
                                <span class="text-xs font-semibold text-primary px-2.5 py-1 bg-primary/10 rounded-full">5 Items</span>
                            </div>
                            <svg class="w-5 h-5 text-neutralText/50 transform transition-transform duration-200 sample-chevron rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                        </button>
                        <div class="flex flex-col divide-y divide-neutralText/5 sample-category-content">
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">Merino Base Layers <a href="#" class="text-primary text-xs ml-1 hover:underline">Find on Amazon →</a></div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">crucial for temperature regulation and odor control</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">GORE-TEX Shell <a href="#" class="text-primary text-xs ml-1 hover:underline">Find on Amazon →</a></div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">wind and waterproof to keep out the dry Hokkaido powder</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">Ski Goggles (Low Light Lens) <a href="#" class="text-primary text-xs ml-1 hover:underline">Find on Amazon →</a></div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">Niseko is often cloudy and snowy, yellow or rose lenses are best</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div><div class="font-medium text-sm text-neutralText sample-item-name transition-all font-normal">Waterproof Ski Gloves, Mid-layer Fleece</div></div>
                            </div>
                        </div>
                    </div>

                    <!-- Category: Electronics & Apres-Ski -->
                    <div class="bg-white rounded-2xl shadow-sm border border-neutralText/5 overflow-hidden transition-all hover:shadow-md h-fit">
                        <button class="w-full px-5 py-4 flex justify-between items-center bg-white hover:bg-neutralText/5 transition-colors sample-category-header focus:outline-none border-b border-neutralText/5">
                            <div class="flex items-center gap-2.5">
                                <span class="font-outfit font-semibold text-base md:text-lg text-neutralText">Electronics & Après-Ski</span>
                                <span class="text-xs font-semibold text-primary px-2.5 py-1 bg-primary/10 rounded-full">10 Items</span>
                            </div>
                            <svg class="w-5 h-5 text-neutralText/50 transform transition-transform duration-200 sample-chevron rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                        </button>
                        <div class="flex flex-col divide-y divide-neutralText/5 sample-category-content">
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">Universal Adapter (Type A/B) <a href="#" class="text-primary text-xs ml-1 hover:underline">Find on Amazon →</a></div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">Japan uses 100V Type A/B flat two-prong outlets</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">Portable Power Bank (Cold-resistant) <a href="#" class="text-primary text-xs ml-1 hover:underline">Find on Amazon →</a></div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">batteries drain significantly faster in freezing temperatures</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div>
                                    <div class="font-medium text-sm text-neutralText sample-item-name transition-all">Hand Warmers (Kairo)</div>
                                    <div class="text-[11px] text-neutralText/60 italic mt-0.5">can also buy in Japanese convenience stores</div>
                                </div>
                            </div>
                            <div class="sample-item-row p-4 flex items-start gap-3 hover:bg-baseCanvas/20 transition-colors cursor-pointer select-none">
                                <button class="sample-checkbox-btn mt-0.5 flex-shrink-0 w-5 h-5 rounded-full border-2 border-neutralText/30 flex items-center justify-center text-white transition-colors focus:outline-none"><svg class="w-3 h-3 opacity-0 transition-opacity sample-check-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"></path></svg></button>
                                <div><div class="font-medium text-sm text-neutralText sample-item-name transition-all font-normal">Warm Winter Boots, Casual Jeans/Trousers, Sweaters ×2, Thermal Socks ×3, Lip Balm, Sunblock, Tenugui (for Onsen)</div></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Contextual Activity Links -->
    <div class="w-full max-w-5xl mx-auto px-6 md:px-0 text-center py-6 mb-8 bg-white rounded-2xl border border-neutralText/5 shadow-sm">
        <h3 class="font-outfit italic font-bold text-lg mb-4">Explore More Japan Lists</h3>
        <div class="flex flex-wrap justify-center gap-3">
            <a href="/packing-list/japan" class="px-5 py-2.5 bg-neutralText/5 hover:bg-neutralText/10 rounded-full font-poppins text-sm font-medium transition-colors text-neutralText">Back to Japan Overview</a>
            <a href="/?prompt=Koyasan%20Temple%20Stay" class="px-5 py-2.5 bg-neutralText/5 hover:bg-neutralText/10 rounded-full font-poppins text-sm font-medium transition-colors text-neutralText">Koyasan Temple Stay</a>
            <a href="/?prompt=Hiking%20Mt.%20Fuji" class="px-5 py-2.5 bg-neutralText/5 hover:bg-neutralText/10 rounded-full font-poppins text-sm font-medium transition-colors text-neutralText">Mt. Fuji Hiking</a>
            <a href="/?prompt=Tokyo%20Business%20Trip" class="px-5 py-2.5 bg-neutralText/5 hover:bg-neutralText/10 rounded-full font-poppins text-sm font-medium transition-colors text-neutralText">Tokyo Business Trip</a>
        </div>
    </div>

    <!-- FAQ Accordion Section -->
    <div class="w-full max-w-5xl mx-auto py-12 px-4 md:px-0">
        <h2 class="font-outfit italic text-primary text-2xl md:text-3xl mb-6">Frequently Asked Questions — Niseko Skiing</h2>
        
        <div class="bg-white rounded-2xl shadow-sm border-t-[3px] border-primary w-full transition-shadow hover:shadow-md">
            <div class="faq-item border-b border-neutralText/5 last:border-b-0">
                <button class="faq-btn w-full px-6 md:px-8 py-5 md:py-6 flex justify-between items-center bg-transparent focus:outline-none hover:bg-neutralText/5 transition-colors rounded-t-2xl">
                    <span class="font-poppins font-semibold text-neutralText text-base md:text-lg text-left pr-4">What kind of ski goggles are best for Niseko?</span>
                    <svg class="w-5 h-5 text-primary transform transition-transform duration-300 faq-chevron shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </button>
                <div class="faq-content overflow-hidden max-h-0 transition-all duration-300 ease-in-out">
                    <div class="px-6 md:px-8 pb-5 md:pb-6 font-poppins text-neutralText/60 text-[15px] md:text-base leading-relaxed">
                        Low-Light or Rose-tinted lenses for flat-light powder days.
                    </div>
                </div>
            </div>
            <div class="faq-item border-b border-neutralText/5 last:border-b-0">
                <button class="faq-btn w-full px-6 md:px-8 py-5 md:py-6 flex justify-between items-center bg-transparent focus:outline-none hover:bg-neutralText/5 transition-colors">
                    <span class="font-poppins font-semibold text-neutralText text-base md:text-lg text-left pr-4">Do I need formal clothes for Hirafu Village?</span>
                    <svg class="w-5 h-5 text-primary transform transition-transform duration-300 faq-chevron shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </button>
                <div class="faq-content overflow-hidden max-h-0 transition-all duration-300 ease-in-out">
                    <div class="px-6 md:px-8 pb-5 md:pb-6 font-poppins text-neutralText/60 text-[15px] md:text-base leading-relaxed">
                        No, the vibe is 'Ski-Chic' and casual. Focus on warm boots and nice layers.
                    </div>
                </div>
            </div>
            <div class="faq-item border-b border-neutralText/5 last:border-b-0">
                <button class="faq-btn w-full px-6 md:px-8 py-5 md:py-6 flex justify-between items-center bg-transparent focus:outline-none hover:bg-neutralText/5 transition-colors">
                    <span class="font-poppins font-semibold text-neutralText text-base md:text-lg text-left pr-4">Should I pack my own skis or rent?</span>
                    <svg class="w-5 h-5 text-primary transform transition-transform duration-300 faq-chevron shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </button>
                <div class="faq-content overflow-hidden max-h-0 transition-all duration-300 ease-in-out">
                    <div class="px-6 md:px-8 pb-5 md:pb-6 font-poppins text-neutralText/60 text-[15px] md:text-base leading-relaxed">
                        Renting is popular to avoid dragging bags on the Shinkansen; shops like Rhythm Japan carry top powder gear.
                    </div>
                </div>
            </div>
            <div class="faq-item border-b border-neutralText/5 last:border-b-0">
                <button class="faq-btn w-full px-6 md:px-8 py-5 md:py-6 flex justify-between items-center bg-transparent focus:outline-none hover:bg-neutralText/5 transition-colors">
                    <span class="font-poppins font-semibold text-neutralText text-base md:text-lg text-left pr-4">How do I handle luggage from the airport?</span>
                    <svg class="w-5 h-5 text-primary transform transition-transform duration-300 faq-chevron shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </button>
                <div class="faq-content overflow-hidden max-h-0 transition-all duration-300 ease-in-out">
                    <div class="px-6 md:px-8 pb-5 md:pb-6 font-poppins text-neutralText/60 text-[15px] md:text-base leading-relaxed">
                        Use Yamato Transport (Takkyubin) to ship bags directly from New Chitose to your resort.
                    </div>
                </div>
            </div>
            <div class="faq-item border-b border-neutralText/5 last:border-b-0 rounded-b-2xl">
                <button class="faq-btn w-full px-6 md:px-8 py-5 md:py-6 flex justify-between items-center bg-transparent focus:outline-none hover:bg-neutralText/5 transition-colors rounded-b-2xl">
                    <span class="font-poppins font-semibold text-neutralText text-base md:text-lg text-left pr-4">Will my electronics work?</span>
                    <svg class="w-5 h-5 text-primary transform transition-transform duration-300 faq-chevron shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                </button>
                <div class="faq-content overflow-hidden max-h-0 transition-all duration-300 ease-in-out">
                    <div class="px-6 md:px-8 pb-5 md:pb-6 font-poppins text-neutralText/60 text-[15px] md:text-base leading-relaxed">
                        Yes, Type A/B plugs. Pack a cold-resistant power bank as batteries die fast in the Hokkaido cold.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Return CTA Section -->'''
html = re.sub(pattern, replacement, html, flags=re.DOTALL)

# 9. Return CTA Text update (already updated in previous version, but just in case we are running on base japan again)
old_return = r'<h2 class="font-outfit italic text-primary text-\[24px\] md:text-\[28px\] mb-2">Not going to Japan\?</h2>\s*<p class="font-poppins font-normal text-\[15px\] md:text-\[16px\] text-neutralText/60 mb-6">PackRight works for any destination\. Just describe your plans\.</p>'
new_return = '''<h2 class="font-outfit italic text-primary text-[24px] md:text-[28px] mb-2">Not hitting the slopes?</h2>
        <p class="font-poppins font-normal text-[15px] md:text-[16px] text-neutralText/60 mb-6">PackRight works for any trip. <a href="/" class="text-primary hover:underline">Create a New List →</a></p>'''
if re.search(old_return, html):
    html = re.sub(old_return, new_return, html, flags=re.DOTALL)

os.makedirs('packing-list/japan/niseko-skiing', exist_ok=True)
with codecs.open('packing-list/japan/niseko-skiing/index.html', 'w', 'utf-8') as f:
    f.write(html)

print("Done generating niseko-skiing page v2.")
