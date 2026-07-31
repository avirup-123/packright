// app.js
document.addEventListener('DOMContentLoaded', () => {
    // --- State ---
    let appState = {
        activeTrip: null,
        rawPrompt: '',
        clarifierAnswers: []
    };
    let currentUser = null;
    let supabase = null;

    // --- DOM Elements ---
    const screens = {
        launchpad: document.getElementById('screen-launchpad'),
        clarifier: document.getElementById('screen-clarifier'),
        brainstorm: document.getElementById('screen-brainstorm'),
        packing: document.getElementById('screen-packing'),
        feedback: document.getElementById('screen-feedback')
    };

    const settingsModal = document.getElementById('settingsModal');
    const saveSettingsBtn = document.getElementById('saveSettingsBtn');
    const closeSettingsBtn = document.getElementById('closeSettingsBtn');
    const openSettingsBtn = document.getElementById('openSettingsBtn');

    // --- Initialization ---
    const savedSupabaseUrl = localStorage.getItem('packright_supabase_url') || 'https://tttbzsjewgiidplnwfyu.supabase.co';
    const savedSupabaseKey = localStorage.getItem('packright_supabase_key') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0dGJ6c2pld2dpaWRwbG53Znl1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3NjUwMjksImV4cCI6MjA5NzM0MTAyOX0.KdinQYm4QyKeSbmkauVPB15z6wUJBKlJPaWztDtWK5U';
    const supabaseUrlInput = document.getElementById('supabaseUrlInput');
    const supabaseKeyInput = document.getElementById('supabaseKeyInput');
    if (savedSupabaseUrl) supabaseUrlInput.value = savedSupabaseUrl;
    if (savedSupabaseKey) supabaseKeyInput.value = savedSupabaseKey;

    const loginBtn = document.getElementById('loginBtn');
    const logoutBtn = document.getElementById('logoutBtn');
    const userProfile = document.getElementById('userProfile');
    const userAvatar = document.getElementById('userAvatar');

    async function initApp() {
        if (savedSupabaseUrl && savedSupabaseKey && window.supabase) {
            supabase = window.supabase.createClient(savedSupabaseUrl, savedSupabaseKey);
            
            // Listen to auth changes
            supabase.auth.onAuthStateChange((event, session) => {
                if (session) {
                    currentUser = session.user;
                    if (loginBtn) loginBtn.classList.add('hidden');
                    if (userProfile) {
                        userProfile.classList.remove('hidden');
                        userProfile.classList.add('flex');
                    }
                    if (userAvatar && currentUser.user_metadata?.avatar_url) {
                        userAvatar.src = currentUser.user_metadata.avatar_url;
                    }
                    loadTripFromSupabase();
                } else {
                    currentUser = null;
                    if (loginBtn) loginBtn.classList.remove('hidden');
                    if (userProfile) {
                        userProfile.classList.add('hidden');
                        userProfile.classList.remove('flex');
                    }
                    loadTripFromLocal();
                }
            });

            // Initial session check
            const { data: { session } } = await supabase.auth.getSession();
            if (!session) {
                loadTripFromLocal();
            }
        } else {
            loadTripFromLocal();
        }
        
        handleUrlQueryParams();
    }

    function handleUrlQueryParams() {
        const urlParams = new URLSearchParams(window.location.search);
        const promptParam = urlParams.get('prompt');
        const focusParam = urlParams.get('focus');
        const mainPromptInput = document.getElementById('mainPromptInput');

        if (mainPromptInput) {
            if (promptParam) {
                mainPromptInput.value = decodeURIComponent(promptParam);
                window.scrollTo({ top: 0, behavior: 'smooth' });
                setTimeout(() => {
                    mainPromptInput.focus();
                }, 500);
            } else if (focusParam === 'true') {
                window.scrollTo({ top: 0, behavior: 'smooth' });
                setTimeout(() => {
                    mainPromptInput.focus();
                }, 500);
            }
        }
    }

    async function loadTripFromSupabase() {
        showScreen('launchpad');
    }

    function loadTripFromLocal() {
        localStorage.removeItem('packright_active_trip');
        showScreen('launchpad');
    }

    if (loginBtn) {
        loginBtn.addEventListener('click', async () => {
            if (!supabase) {
                alert('Please configure Supabase settings first (Gear icon).');
                return;
            }
            await supabase.auth.signInWithOAuth({ provider: 'google' });
        });
    }

    if (logoutBtn) {
        logoutBtn.addEventListener('click', async () => {
            if (supabase) await supabase.auth.signOut();
        });
    }

    initApp();

    // --- Settings Modal ---
    openSettingsBtn.addEventListener('click', () => {
        settingsModal.classList.remove('hidden');
        settingsModal.classList.add('flex');
    });

    const openSettingsBtn2 = document.getElementById('openSettingsBtn2');
    if (openSettingsBtn2) {
        openSettingsBtn2.addEventListener('click', () => {
            settingsModal.classList.remove('hidden');
            settingsModal.classList.add('flex');
        });
    }

    closeSettingsBtn.addEventListener('click', () => {
        settingsModal.classList.add('hidden');
        settingsModal.classList.remove('flex');
    });

    saveSettingsBtn.addEventListener('click', () => {
        const supabaseUrlInput = document.getElementById('supabaseUrlInput');
        const supabaseKeyInput = document.getElementById('supabaseKeyInput');
        if (supabaseUrlInput && supabaseKeyInput) {
            const newUrl = supabaseUrlInput.value.trim();
            const newKey = supabaseKeyInput.value.trim();
            localStorage.setItem('packright_supabase_url', newUrl);
            localStorage.setItem('packright_supabase_key', newKey);
            
            if (newUrl && newKey && window.supabase && !supabase) {
                window.location.reload(); // Reload to init Supabase
            }
        }

        settingsModal.classList.add('hidden');
        settingsModal.classList.remove('flex');
    });

    // --- Reset / New Trip ---
    const newTripBtn = document.getElementById('newTripBtn');
    if (newTripBtn) {
        newTripBtn.addEventListener('click', () => {
            if (confirm("Are you sure you want to delete this trip and start a new packing list?")) {
                localStorage.removeItem('packright_active_trip');
                appState.activeTrip = null;
                appState.rawPrompt = '';
                appState.clarifierAnswers = [];
                if (mainPromptInput) mainPromptInput.value = '';
                showScreen('launchpad');
            }
        });
    }

    // --- Screen Management ---
    function showScreen(screenId) {
        Object.values(screens).forEach(s => {
            s.classList.remove('block', 'flex');
            s.classList.add('hidden');
        });
        
        if (screens[screenId]) {
            screens[screenId].classList.remove('hidden');
            if (screenId === 'launchpad' || screenId === 'clarifier' || screenId === 'packing' || screenId === 'brainstorm' || screenId === 'feedback') {
                screens[screenId].classList.add('flex');
            } else {
                screens[screenId].classList.add('block');
            }
        }
    }

    // --- Loading Texts ---
    const loadingTexts = [
        "Analyzing your destination's climate profile...",
        "Calibrating airline baggage size boundaries...",
        "Assembling smart packing item rows...",
        "Cross-referencing power grid requirements..."
    ];
    let loadingInterval;

    function startLoading() {
        showScreen('brainstorm');
        const textEl = document.getElementById('loadingText');
        let i = 0;
        textEl.textContent = loadingTexts[0];
        loadingInterval = setInterval(() => {
            i = (i + 1) % loadingTexts.length;
            textEl.style.opacity = '0';
            setTimeout(() => {
                textEl.textContent = loadingTexts[i];
                textEl.style.opacity = '1';
            }, 300);
        }, 1500);
    }

    function stopLoading() {
        clearInterval(loadingInterval);
    }

    // --- Launchpad ---
    const mainPromptInput = document.getElementById('mainPromptInput');
    const launchpadNextBtn = document.getElementById('launchpadNextBtn');

    launchpadNextBtn.addEventListener('click', async () => {
        const prompt = mainPromptInput.value.trim();
        if (!prompt) return;
        
        appState.rawPrompt = prompt;
        startLoading();

        try {
            const data = await API.getClarifierQuestions(prompt);
            stopLoading();
            renderClarifierQuestions(data.questions);
            showScreen('clarifier');
        } catch (err) {
            stopLoading();
            console.error(err);
            alert("Error: " + err.message);
            showScreen('launchpad');
        }
    });

    // --- Voice Input Feature ---
    function setupVoiceInput(btnId, inputId) {
        const btn = document.getElementById(btnId);
        const input = document.getElementById(inputId);
        const voiceToast = document.getElementById('voiceToast');

        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (SpeechRecognition && btn && input) {
            const recognition = new SpeechRecognition();
            recognition.continuous = false;
            recognition.interimResults = false;
            recognition.lang = 'en-US';

            let isListening = false;

            recognition.onstart = () => {
                isListening = true;
                btn.classList.add('is-listening');
                if (voiceToast) {
                    voiceToast.classList.remove('opacity-0');
                    voiceToast.classList.add('opacity-100');
                }
            };

            recognition.onresult = (event) => {
                const transcript = event.results[0][0].transcript;
                const currentValue = input.value.trim();
                if (currentValue) {
                    input.value = currentValue + ' ' + transcript;
                } else {
                    input.value = transcript;
                }
                input.dispatchEvent(new Event('input'));
            };

            recognition.onerror = (event) => {
                console.error('Speech recognition error:', event.error);
                cleanupListening();
            };

            recognition.onend = () => {
                cleanupListening();
            };

            function cleanupListening() {
                isListening = false;
                btn.classList.remove('is-listening');
                if (voiceToast) {
                    voiceToast.classList.remove('opacity-100');
                    voiceToast.classList.add('opacity-0');
                }
            }

            btn.addEventListener('click', () => {
                if (isListening) {
                    recognition.stop();
                } else {
                    recognition.start();
                }
            });
        } else if (btn) {
            btn.addEventListener('click', () => {
                alert('Speech Recognition is not supported in this browser. Try Chrome or Safari!');
            });
        }
    }

    setupVoiceInput('voiceInputBtn', 'mainPromptInput');
    setupVoiceInput('voiceInputBtnClarifier', 'clarifierContextInput');

    // --- Clarifier ---
    const clarifierQuestionsContainer = document.getElementById('clarifierQuestionsContainer');
    const buildListBtn = document.getElementById('buildListBtn');
    const qTemplate = document.getElementById('questionTemplate');

    function renderClarifierQuestions(questions) {
        clarifierQuestionsContainer.innerHTML = '';
        appState.clarifierAnswers = [];

        questions.forEach(q => {
            const clone = qTemplate.content.cloneNode(true);
            clone.querySelector('h3').textContent = q.question_text;
            const optionsContainer = clone.querySelector('.options-container');

            q.options.forEach(opt => {
                const btn = document.createElement('button');
                btn.className = 'px-4 py-2 rounded-full border border-neutralText/20 bg-white font-medium text-sm transition-colors hover:border-primary';
                btn.textContent = opt;
                btn.dataset.qid = q.id;
                
                btn.addEventListener('click', () => {
                    // clear others in group
                    const siblings = optionsContainer.querySelectorAll('button');
                    siblings.forEach(s => {
                        s.classList.remove('bg-primary', 'text-white', 'border-primary');
                        s.classList.add('bg-white', 'border-neutralText/20');
                    });
                    // select this
                    btn.classList.add('bg-primary', 'text-white', 'border-primary');
                    btn.classList.remove('bg-white', 'border-neutralText/20');
                    
                    // Update state
                    const existing = appState.clarifierAnswers.find(a => a.id === q.id);
                    if (existing) {
                        existing.answer = opt;
                    } else {
                        appState.clarifierAnswers.push({ id: q.id, question: q.question_text, answer: opt });
                    }
                });
                optionsContainer.appendChild(btn);
            });

            clarifierQuestionsContainer.appendChild(clone);
        });
    }

    buildListBtn.addEventListener('click', async () => {
        let finalPrompt = appState.rawPrompt;
        const extraContextInput = document.getElementById('clarifierContextInput');
        if (extraContextInput) {
            const extraCtx = extraContextInput.value.trim();
            if (extraCtx) {
                finalPrompt += "\n\nAdditional Context: " + extraCtx;
            }
        }

        startLoading();
        try {
            const data = await API.getPackingChecklist(finalPrompt, appState.clarifierAnswers);
            stopLoading();
            
            // Translate the new schema into the app's expected schema
            const mappedCategories = (data.categories || []).map(cat => {
                return {
                    category_name: cat.name,
                    items: (cat.items || []).map(item => {
                        return {
                            id: 'item_' + Date.now() + Math.random().toString(36).substr(2, 9),
                            name: item.quantity && item.quantity !== 1 ? `${item.quantity}x ${item.name}` : item.name,
                            context_note: item.reason,
                            luggage_target: "General",
                            packed: false
                        };
                    })
                };
            });

            appState.activeTrip = {
                trip_name: data.trip_summary || "My Packing List",
                categories: mappedCategories,
                saved_items_state: {},
                custom_added_items: []
            };

            mappedCategories.forEach(cat => {
                cat.items.forEach(item => {
                    appState.activeTrip.saved_items_state[item.id] = false;
                });
            });

            saveTripState();
            renderPackingList();
            showScreen('packing');
        } catch (err) {
            stopLoading();
            console.error(err);
            alert("Error: " + err.message);
            showScreen('clarifier');
        }
    });

    // --- Packing Canvas ---
    const packingListContainer = document.getElementById('packingListContainer');
    const tripTitleDisplay = document.getElementById('tripTitleDisplay');
    const progressText = document.getElementById('progressText');
    const progressBar = document.getElementById('progressBar');
    const cTemplate = document.getElementById('categoryTemplate');
    const iTemplate = document.getElementById('itemTemplate');

    async function saveTripState() {
        localStorage.setItem('packright_active_trip', JSON.stringify(appState.activeTrip));
        
        if (supabase && currentUser && appState.activeTrip) {
            try {
                const tripPayload = {
                    user_id: currentUser.id,
                    trip_name: appState.activeTrip.trip_name,
                    categories: appState.activeTrip.categories,
                    saved_items_state: appState.activeTrip.saved_items_state,
                    custom_added_items: appState.activeTrip.custom_added_items
                };
                
                if (appState.activeTrip.id) {
                    await supabase.from('trips').update(tripPayload).eq('id', appState.activeTrip.id);
                } else {
                    const { data, error } = await supabase.from('trips').insert([tripPayload]).select();
                    if (!error && data && data.length > 0) {
                        appState.activeTrip.id = data[0].id;
                        localStorage.setItem('packright_active_trip', JSON.stringify(appState.activeTrip));
                    }
                }
            } catch (e) {
                console.error('Error saving to Supabase', e);
            }
        }
    }

    function updateProgress() {
        let total = 0;
        let packed = 0;

        if (!appState.activeTrip) return;

        appState.activeTrip.categories.forEach(cat => {
            cat.items.forEach(item => {
                total++;
                if (appState.activeTrip.saved_items_state[item.id]) packed++;
            });
        });

        appState.activeTrip.custom_added_items.forEach(item => {
            total++;
            if (appState.activeTrip.saved_items_state[item.id]) packed++;
        });

        const percent = total === 0 ? 0 : Math.round((packed / total) * 100);
        
        progressText.textContent = `${packed} / ${total} Items Packed`;
        progressBar.style.width = `${percent}%`;

        // Auto transition at 100%
        if (percent === 100 && total > 0) {
            feedbackTotalItems = total;
            feedbackTripDest = "your trip";
            feedbackTripDays = "?";
            
            const summary = appState.activeTrip.trip_name || "";
            const match = summary.match(/(\d+)\s+days?\s+in\s+(.+)/i);
            if (match) {
                feedbackTripDays = match[1];
                feedbackTripDest = match[2];
            } else if (summary) {
                feedbackTripDest = summary;
            }

            document.getElementById('feedbackHeading').textContent = `You're all packed for ${feedbackTripDest}`;
            document.getElementById('feedbackSubtext').textContent = `${total} items · ${feedbackTripDays} days`;

            setTimeout(() => {
                showScreen('feedback');
                if (typeof confetti !== 'undefined') {
                    confetti({
                        particleCount: 50,
                        spread: 60,
                        origin: { y: 0.6 },
                        colors: ['#E3745A', '#22c55e', '#3b82f6', '#facc15'],
                        shapes: ['square'],
                        ticks: 200,
                        gravity: 0.8,
                        scalar: 1.2
                    });
                }
            }, 600);
        }
    }

    function renderItem(item, container) {
        const clone = iTemplate.content.cloneNode(true);
        const row = clone.querySelector('.item-row');
        const nameEl = clone.querySelector('.item-name');
        const contextEl = clone.querySelector('.item-context');
        const badgeEl = clone.querySelector('.luggage-badge');
        const checkboxBtn = clone.querySelector('.checkbox-btn');
        const checkIcon = clone.querySelector('.check-icon');

        nameEl.textContent = item.name;

        // ── Affiliate Button Injection ───────────────────────────────────────────
        // Ask the affiliate system if this item has a matching product.
        // window.PackRightAffiliates is defined in affiliate.js.
        // If it's not loaded (e.g. the script failed), we skip gracefully.
        // The button is inserted RIGHT AFTER the item name, before the context note.
        try {
            if (window.PackRightAffiliates && window.PackRightAffiliates.isReady()) {
                const affiliateBtn = window.PackRightAffiliates.buildAffiliateButton(item.name);
                if (affiliateBtn) {
                    // The name wrapper needs to allow clicks on the affiliate link
                    // We remove pointer-events-none from the flex-1 container and
                    // re-apply it only to nameEl and contextEl so check-on-click still works
                    const nameWrapper = nameEl.closest('.flex-1');
                    if (nameWrapper) {
                        nameWrapper.classList.remove('pointer-events-none');
                        nameEl.style.pointerEvents = 'none';
                        contextEl.style.pointerEvents = 'none';
                        // Insert affiliate button between item name and context note
                        nameEl.parentNode.insertBefore(affiliateBtn, contextEl);
                    }
                }
            }
        } catch (affiliateErr) {
            // Affiliate button injection failed silently — item renders as normal
            console.warn('[PackRight Affiliates] Button injection failed for:', item.name, affiliateErr.message);
        }
        
        if (item.context_note) {
            contextEl.textContent = item.context_note;
        } else {
            contextEl.classList.add('hidden');
        }

        badgeEl.textContent = item.luggage_target || 'General';
        
        function applyState() {
            if (appState.activeTrip.saved_items_state[item.id]) {
                checkboxBtn.classList.add('bg-success', 'border-success');
                checkboxBtn.classList.remove('border-neutralText/30');
                checkIcon.classList.remove('opacity-0');
                
                nameEl.classList.add('line-through', 'opacity-50');
                badgeEl.classList.add('bg-neutralText/10', 'text-neutralText/50');
                badgeEl.classList.remove('bg-blue-100', 'text-blue-700', 'bg-green-100', 'text-green-700', 'bg-orange-100', 'text-orange-700');
            } else {
                checkboxBtn.classList.remove('bg-success', 'border-success');
                checkboxBtn.classList.add('border-neutralText/30');
                checkIcon.classList.add('opacity-0');
                
                nameEl.classList.remove('line-through', 'opacity-50');
                badgeEl.classList.remove('bg-neutralText/10', 'text-neutralText/50');
                
                const lowerTarget = (item.luggage_target || '').toLowerCase();
                if (lowerTarget.includes('carry')) {
                    badgeEl.classList.add('bg-blue-100', 'text-blue-700');
                } else if (lowerTarget.includes('check')) {
                    badgeEl.classList.add('bg-green-100', 'text-green-700');
                } else {
                    badgeEl.classList.add('bg-orange-100', 'text-orange-700');
                }
            }
        }

        applyState();

        row.addEventListener('click', (e) => {
            appState.activeTrip.saved_items_state[item.id] = !appState.activeTrip.saved_items_state[item.id];
            applyState();
            saveTripState();
            updateProgress();
        });

        container.appendChild(clone);
    }

    function renderPackingList() {
        tripTitleDisplay.textContent = appState.activeTrip.trip_name || 'Your Trip';
        packingListContainer.innerHTML = '';

        appState.activeTrip.categories.forEach(cat => {
            const cClone = cTemplate.content.cloneNode(true);
            cClone.querySelector('.category-title').textContent = cat.category_name;
            
            const headerBtn = cClone.querySelector('.category-header');
            const contentDiv = cClone.querySelector('.category-content');
            const chevron = cClone.querySelector('.chevron');
            const itemsList = cClone.querySelector('.items-list');
            
            headerBtn.addEventListener('click', () => {
                const isHidden = contentDiv.classList.contains('hidden');
                if (isHidden) {
                    contentDiv.classList.remove('hidden');
                    chevron.classList.add('rotate-180');
                } else {
                    contentDiv.classList.add('hidden');
                    chevron.classList.remove('rotate-180');
                }
            });
            // Initial state: open
            chevron.classList.add('rotate-180');

            cat.items.forEach(item => {
                renderItem(item, itemsList);
            });

            // Append custom items for this category
            if (appState.activeTrip.custom_added_items) {
                appState.activeTrip.custom_added_items.filter(i => i.category === cat.category_name).forEach(item => {
                    renderItem(item, itemsList);
                });
            } else {
                appState.activeTrip.custom_added_items = [];
            }

            // Handle inline add
            const addInput = cClone.querySelector('.add-item-input');
            const addBtn = cClone.querySelector('.add-item-btn');

            const handleAdd = () => {
                const val = addInput.value.trim();
                if (!val) return;
                
                const newItem = {
                    id: 'custom_' + Date.now() + Math.floor(Math.random() * 1000),
                    category: cat.category_name,
                    name: val,
                    luggage_target: 'Personal',
                    packed: false
                };
                
                appState.activeTrip.custom_added_items.push(newItem);
                appState.activeTrip.saved_items_state[newItem.id] = false;
                
                saveTripState();
                renderItem(newItem, itemsList);
                updateProgress();
                
                addInput.value = '';
            };

            addBtn.addEventListener('click', handleAdd);
            addInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') handleAdd();
            });

            packingListContainer.appendChild(cClone);
        });

        updateProgress();

        // ── Disclosure Line ─────────────────────────────────────────────────────
        // Amazon Associates ToS requires this disclosure whenever affiliate links
        // are displayed. Always shown, unconditionally, on every generated list.
        // We remove any existing one first to prevent duplication on re-renders.
        try {
            const existingDisclosure = packingListContainer.querySelector('#affiliate-disclosure');
            if (existingDisclosure) existingDisclosure.remove();

            if (window.PackRightAffiliates) {
                packingListContainer.appendChild(window.PackRightAffiliates.buildDisclosureElement());
            }
        } catch (disclosureErr) {
            console.warn('[PackRight Affiliates] Disclosure injection failed:', disclosureErr.message);
        }
    }

    // --- Share Trip Logic ---
    function generateShareText() {
        if (!appState.activeTrip) return "";
        let text = `My Packing List for: ${appState.activeTrip.trip_name}\n\n`;

        appState.activeTrip.categories.forEach(cat => {
            text += `--- ${cat.category_name} ---\n`;
            cat.items.forEach(item => {
                const checked = appState.activeTrip.saved_items_state[item.id] ? "✅" : "☐";
                text += `${checked} ${item.name}\n`;
            });
            
            // Custom items
            const customItems = (appState.activeTrip.custom_added_items || []).filter(i => i.category === cat.category_name);
            customItems.forEach(item => {
                const checked = appState.activeTrip.saved_items_state[item.id] ? "✅" : "☐";
                text += `${checked} ${item.name}\n`;
            });
            text += `\n`;
        });
        
        text += `Generated with PackRight: https://packright-20.vercel.app`;
        return text;
    }

    const shareTripBtn = document.getElementById('shareTripBtn');
    const shareModal = document.getElementById('shareModal');
    const closeShareModalBtn = document.getElementById('closeShareModalBtn');
    const shareWhatsappBtn = document.getElementById('shareWhatsappBtn');
    const shareEmailBtn = document.getElementById('shareEmailBtn');
    const shareCopyBtn = document.getElementById('shareCopyBtn');

    if (shareTripBtn) {
        shareTripBtn.addEventListener('click', async () => {
            const textToShare = generateShareText();
            
            if (navigator.share) {
                try {
                    await navigator.share({
                        title: 'My Packing List',
                        text: textToShare,
                    });
                    return;
                } catch (err) {
                    console.log("Share failed or was cancelled:", err);
                    if (err.name !== 'AbortError') {
                        showShareModal(textToShare);
                    }
                }
            } else {
                showShareModal(textToShare);
            }
        });
    }

    function showShareModal(textToShare) {
        if (!shareModal) return;
        shareModal.classList.remove('hidden');
        shareModal.classList.add('flex');
        
        if (shareWhatsappBtn) {
            shareWhatsappBtn.href = `https://wa.me/?text=${encodeURIComponent(textToShare)}`;
        }
        if (shareEmailBtn) {
            shareEmailBtn.href = `mailto:?subject=${encodeURIComponent('My Packing List')}&body=${encodeURIComponent(textToShare)}`;
        }
    }

    if (closeShareModalBtn) {
        closeShareModalBtn.addEventListener('click', () => {
            shareModal.classList.add('hidden');
            shareModal.classList.remove('flex');
        });
    }

    if (shareCopyBtn) {
        shareCopyBtn.addEventListener('click', async () => {
            const textToShare = generateShareText();
            try {
                await navigator.clipboard.writeText(textToShare);
                const originalContent = shareCopyBtn.innerHTML;
                shareCopyBtn.innerHTML = "✅ Copied!";
                setTimeout(() => {
                    shareCopyBtn.innerHTML = originalContent;
                }, 2000);
            } catch (e) {
                alert("Failed to copy. Please try again.");
            }
        });
    }

    
    
    // --- Feedback Screen ---
    let currentRating = 0;
    let feedbackTotalItems = 0;
    let feedbackTripDest = "your trip";
    let feedbackTripDays = "?";
    let selectedReasonTags = new Set();
    
    const chipOptions = {
        bad: { // 1 or 2 stars
            label: "What went wrong?",
            chips: ["Items were too generic", "Missing items for my destination", "Irrelevant items on my list", "List was too long", "List was too short", "Something else"]
        },
        neutral: { // 3 stars
            label: "What could be better?",
            chips: ["Missing items for my destination", "Some items felt irrelevant", "List was too long", "List was too short", "Hard to navigate", "Something else"]
        },
        good: { // 4 or 5 stars
            label: "What worked well?",
            chips: ["Spot on for my destination", "Covered things I wouldn't have thought of", "Right length, nothing extra", "Easy to use", "Good product suggestions", "Something else"]
        }
    };

    function renderChips(rating) {
        const wrapper = document.getElementById('feedbackChipsWrapper');
        const container = document.getElementById('feedbackChipsContainer');
        const label = document.getElementById('feedbackChipsLabel');
        
        let config;
        if (rating <= 2) config = chipOptions.bad;
        else if (rating === 3) config = chipOptions.neutral;
        else config = chipOptions.good;

        label.textContent = config.label;
        container.innerHTML = '';
        selectedReasonTags.clear();

        config.chips.forEach(chipText => {
            const btn = document.createElement('button');
            btn.className = "px-4 py-2 rounded-full border border-outline-variant bg-surface-container-low text-on-surface font-body-sm transition-colors duration-200 chip-btn";
            btn.textContent = chipText;
            btn.addEventListener('click', () => {
                if (selectedReasonTags.has(chipText)) {
                    selectedReasonTags.delete(chipText);
                    btn.classList.remove('bg-[#D85A30]', 'text-white', 'border-[#D85A30]');
                    btn.classList.add('bg-surface-container-low', 'text-on-surface', 'border-outline-variant');
                } else {
                    selectedReasonTags.add(chipText);
                    btn.classList.add('bg-[#D85A30]', 'text-white', 'border-[#D85A30]');
                    btn.classList.remove('bg-surface-container-low', 'text-on-surface', 'border-outline-variant');
                }
            });
            container.appendChild(btn);
        });

        wrapper.classList.remove('hidden');
        // slight delay to allow display block to apply before opacity transition
        setTimeout(() => {
            wrapper.classList.remove('opacity-0');
        }, 10);
    }

    const starBtns = document.querySelectorAll('.star-btn');
    starBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            currentRating = parseInt(e.target.dataset.val);
            starBtns.forEach(sb => {
                const val = parseInt(sb.dataset.val);
                if (val <= currentRating) {
                    sb.style.fontVariationSettings = "'FILL' 1";
                    sb.classList.add('text-[#D85A30]');
                    sb.classList.remove('text-outline-variant');
                } else {
                    sb.style.fontVariationSettings = "'FILL' 0";
                    sb.classList.remove('text-[#D85A30]');
                    sb.classList.add('text-outline-variant');
                }
            });
            renderChips(currentRating);
        });
    });

    function detectTripType(prompt) {
        if (!prompt) return "general";
        const p = prompt.toLowerCase();
        if (p.includes("beach") || p.includes("resort") || p.includes("ocean") || p.includes("sea")) return "beach";
        if (p.includes("business") || p.includes("work") || p.includes("conference") || p.includes("meeting")) return "business";
        if (p.includes("adventure") || p.includes("hike") || p.includes("camping") || p.includes("trek") || p.includes("safari")) return "adventure";
        if (p.includes("family") || p.includes("kids") || p.includes("baby") || p.includes("children")) return "family";
        if (p.includes("city") || p.includes("urban")) return "city break";
        if (p.includes("ski") || p.includes("snow") || p.includes("winter")) return "winter sports";
        return "general";
    }

    const sendFeedbackBtn = document.getElementById('sendFeedbackBtn');
    if (sendFeedbackBtn) {
        sendFeedbackBtn.addEventListener('click', async () => {
            if (currentRating === 0) {
                alert("Please select a star rating first.");
                return;
            }

            const msg = document.getElementById('feedbackMessage').value.trim();
            const fname = document.getElementById('feedbackName').value.trim();
            const femail = document.getElementById('feedbackEmail').value.trim();
            const tags = Array.from(selectedReasonTags);
            const generatedList = appState.activeTrip ? appState.activeTrip.categories : [];
            const tType = detectTripType(appState.rawPrompt || (appState.activeTrip && appState.activeTrip.trip_name) || "");

            const payload = {
                destination: feedbackTripDest,
                trip_duration: feedbackTripDays,
                trip_type: tType,
                star_rating: currentRating,
                reason_tags: tags,
                message: msg,
                name: fname,
                email: femail,
                items_checked: feedbackTotalItems,
                total_items: feedbackTotalItems,
                generated_list: generatedList
            };

            // Always show thanks to user immediately to hide latency/errors
            document.getElementById('feedbackFormContainer').classList.add('hidden');
            document.getElementById('feedbackThanksContainer').classList.remove('hidden');

            if (supabase) {
                try {
                    // 1. Insert into feedback
                    const { data, error } = await supabase.from('feedback').insert([payload]).select();
                    
                    if (!error && data && data.length > 0) {
                        const feedbackId = data[0].id;

                        const examplePayload = {
                            destination: feedbackTripDest,
                            trip_duration: feedbackTripDays,
                            trip_type: tType,
                            generated_list: generatedList,
                            star_rating: currentRating,
                            reason_tags: tags,
                            user_message: msg,
                            name: fname,
                            email: femail,
                            feedback_id: feedbackId
                        };

                        // 2. Insert into good_examples or bad_examples based on rating
                        if (currentRating >= 4) {
                            await supabase.from('good_examples').insert([examplePayload]);
                        } else if (currentRating <= 2) {
                            await supabase.from('bad_examples').insert([examplePayload]);
                        }
                    }
                } catch(e) {
                    console.error("Feedback error", e);
                }
            }
        });
    }

    function resetToHome() {
        localStorage.removeItem('packright_active_trip');
        appState.activeTrip = null;
        appState.rawPrompt = '';
        appState.clarifierAnswers = [];
        const mainInput = document.getElementById('mainPromptInput');
        if (mainInput) mainInput.value = '';
        const extraContext = document.getElementById('clarifierContextInput');
        if (extraContext) extraContext.value = '';

        // reset feedback UI for next time
        document.getElementById('feedbackFormContainer').classList.remove('hidden');
        document.getElementById('feedbackThanksContainer').classList.add('hidden');
        document.getElementById('feedbackMessage').value = '';
        document.getElementById('feedbackName').value = '';
        document.getElementById('feedbackEmail').value = '';
        
        const wrapper = document.getElementById('feedbackChipsWrapper');
        wrapper.classList.add('hidden', 'opacity-0');
        selectedReasonTags.clear();

        currentRating = 0;
        starBtns.forEach(sb => {
            sb.style.fontVariationSettings = "'FILL' 0";
            sb.classList.remove('text-[#D85A30]');
            sb.classList.add('text-outline-variant');
        });

        showScreen('launchpad');
    }

    const skipFeedbackBtn = document.getElementById('skipFeedbackBtn');
    if (skipFeedbackBtn) skipFeedbackBtn.addEventListener('click', resetToHome);

    const feedbackNewTripBtn = document.getElementById('feedbackNewTripBtn');
    if (feedbackNewTripBtn) feedbackNewTripBtn.addEventListener('click', resetToHome);

    // --- Homepage Sections Logic ---



    // 1. FAQ Accordion
    const faqBtns = document.querySelectorAll('.faq-btn');
    faqBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const content = btn.nextElementSibling;
            const chevron = btn.querySelector('.faq-chevron');
            const isOpen = !content.classList.contains('max-h-0');

            // Close all
            document.querySelectorAll('.faq-content').forEach(c => c.classList.add('max-h-0', 'invisible'));
            document.querySelectorAll('.faq-chevron').forEach(c => c.classList.remove('rotate-180'));

            if (!isOpen) {
                // Open this one (setting a large max-height to allow content to expand)
                content.classList.remove('max-h-0', 'invisible');
                content.style.maxHeight = content.scrollHeight + 'px';
                chevron.classList.add('rotate-180');
            } else {
                content.style.maxHeight = null;
            }
        });
    });

    // 2. Social Proof Counter
    const counterSection = document.getElementById('counter-section');
    const socialCounter = document.getElementById('social-counter');
    if (counterSection && socialCounter) {
        let count = 12400;
        let counterInterval;

        const observer = new IntersectionObserver((entries) => {
            if (entries[0].isIntersecting) {
                if (!counterInterval) {
                    counterInterval = setInterval(() => {
                        count++;
                        socialCounter.textContent = count.toLocaleString() + '+';
                    }, 4000); // every 4 seconds
                }
            } else {
                clearInterval(counterInterval);
                counterInterval = null;
            }
        }, { threshold: 0.5 });

        observer.observe(counterSection);
    }

    // 3. Popular Destinations
    const destCards = document.querySelectorAll('.dest-card');
    if (destCards.length > 0 && mainPromptInput) {
        destCards.forEach(card => {
            card.addEventListener('click', () => {
                const prompt = card.getAttribute('data-prompt');
                if (prompt) {
                    mainPromptInput.value = prompt;
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                    setTimeout(() => {
                        mainPromptInput.focus();
                    }, 500); // focus after scroll
                }
            });
        });
    }
});


window.switchToLaunchpad = function() {
    // Hide all sections in main except screens and how-it-works
    document.querySelectorAll('main > section, main > div').forEach(el => {
        if(!el.id.startsWith('screen-') && el.id !== 'how-it-works-section') {
            el.classList.add('hidden');
        }
    });
    
    // Hide specific screens
    const screens = ['clarifier', 'loading', 'packing', 'feedback'];
    screens.forEach(s => {
        const el = document.getElementById('screen-' + s);
        if (el) el.classList.add('hidden');
    });

    // Show launchpad
    const launchpad = document.getElementById('screen-launchpad');
    if (launchpad) launchpad.classList.remove('hidden');
    
    // Remove border-t-4 from launchpad to look clean
    if(launchpad) launchpad.classList.remove('border-t-4', 'border-primary');

    // Show How It Works
    const hiw = document.getElementById('how-it-works-section');
    if (hiw) hiw.classList.remove('hidden');

    // Scroll and focus
    window.scrollTo({ top: 0, behavior: 'smooth' });
    setTimeout(() => {
        const input = document.getElementById('mainPromptInput');
        if (input) {
            input.value = ''; // clear text
            input.focus();
        }
    }, 100);
};
