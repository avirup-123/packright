<div align="center">
  <img src="https://raw.githubusercontent.com/avirupsarker1999/packright-2.0/main/public/logo.png" alt="PackRight Logo" width="120" style="border-radius: 20px" onerror="this.style.display='none'">
  <h1>PackRight: The AI Travel Packing Assistant</h1>
  <p>Stop forgetting travel essentials. PackRight uses AI to instantly generate a personalized, context-aware packing checklist based on your exact destination, weather, and activities.</p>
  
  [![Website](https://img.shields.io/badge/Website-Live-E06A4E?style=for-the-badge&logo=vercel)](https://packright-20.vercel.app)
</div>

<br/>

## ✈️ What is PackRight?

PackRight is a smart, AI-powered travel packing consultant. Instead of forcing you to use generic, one-size-fits-all checklists, PackRight allows you to describe your upcoming trip in natural language (or via voice). 

By acting as a travel expert with decades of experience, the underlying AI (powered by Google's Gemini 2.5 Flash) reasons about your destination's climate, your accommodation type, planned activities, and baggage constraints to build a **perfectly tailored packing list from scratch.**

---

## ✨ Key Features

- **🧠 Context-Aware AI Generation**: Tell it you are "Backpacking through Japan in March with a budget airline" and it will prioritize thermal layers, Type A plug adapters, and lightweight essentials.
- **🎙️ Voice Input**: Don't want to type? Just hit the microphone button and describe your trip naturally.
- **❓ Smart Clarifications**: If your prompt is too vague, the AI will dynamically ask 2-3 multiple-choice clarifying questions before generating the list.
- **☁️ Cloud Sync & Local Storage**: Use it anonymously (saves to your browser) or sign in with Google (via Supabase) to sync your packing lists across all your devices.
- **📤 Native Sharing**: Easily share your packing list with friends via WhatsApp, Email, or the native Web Share sheet, complete with ✅ and ☐ emojis.
- **➕ Manual Overrides**: AI missed something? Easily add custom items to any category.

---

## 🎨 Brand Elements & Styles

PackRight is designed to feel warm, premium, and stress-free. We bypass rigid corporate designs in favor of a modern, slightly organic aesthetic.

### Typography
- **Outfit**: Used for primary headings and brand text. Warm, geometric, and modern.
- **Inter**: Used for body text and highly readable UI elements.
- **Poppins**: Used for interactive cards and secondary UI elements.

### Color Palette
- 🟠 **Primary (Terracotta)**: `#E06A4E` - Used for primary actions, buttons, and brand accents.
- 🟢 **Success (Sage Green)**: `#5F8567` - Used for progress bars, checked items, and success states.
- ⚪ **Base Canvas (Soft Sand)**: `#FAF6F0` - A warm, off-white background that reduces eye strain.
- ⚫ **Neutral Text**: `#222222` - Softened black for high contrast but comfortable reading.

---

## 🚀 Walkthrough: How to Use It

1. **Describe Your Trip**: On the homepage, type (or speak) your trip details. *Example: "7 days in Bali, staying at a beach resort, lots of snorkeling, flying with only a carry-on."*
2. **Answer Clarifiers (Optional)**: If needed, PackRight will ask a couple of quick multiple-choice questions to dial in the specifics.
3. **Review Your List**: The AI instantly generates your list, grouped by categories (e.g., Clothing, Toiletries, Electronics, Documents).
4. **Read the Context**: Some items include a "context note" (e.g., *Universal Plug Adapter — Bali uses Type C/F plugs*).
5. **Start Packing**: Check off items as you put them in your bag. The progress bar at the top tracks your completion.
6. **Share**: Click the "Share" button to send a text-formatted version of your current progress to a friend.

---

## 🛠️ Tech Stack

PackRight is built to be lightning-fast and lightweight:
- **Frontend**: HTML5, Vanilla JavaScript, Tailwind CSS (via CDN).
- **Backend/Auth**: [Supabase](https://supabase.com/) (PostgreSQL & Google OAuth).
- **AI Engine**: [Google Gemini API](https://ai.google.dev/) (`gemini-2.5-flash`).
- **Hosting**: Vercel.

---

## ⚙️ Local Development Setup

To run PackRight locally, you just need a local web server since it is a pure client-side application.

1. **Clone the repository:**
   \`\`\`bash
   git clone https://github.com/your-username/packright-2.0.git
   cd packright-2.0
   \`\`\`

2. **Serve the directory:**
   You can use any local server, such as Python's HTTP server or Node's `serve`:
   \`\`\`bash
   # Using Python
   python -m http.server 8000
   
   # Using Node (npx)
   npx serve .
   \`\`\`

3. **Configure API Keys:**
   - Open the app in your browser (`http://localhost:8000`).
   - Click the **Gear Icon** (Settings) in the top right.
   - Enter your **Gemini API Key** (required to generate lists).
   - Enter your **Supabase URL and Anon Key** (required if you want to test cloud-sync and Google Auth).
   - Click **Save**.

4. **Start Packing!**

---

## 📄 License

This project is open-source and available for educational and personal use.
