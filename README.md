# The Pact (formerly Atomic Habits Hook)

> **"Don't rely on willpower. Rely on your friends."**

A social habit-tracking app that turns personal goals into socially binding contracts.  
Built on **Flutter** (Mobile) and **React** (Web Anchor).

**Live URL:** [thepact.co](https://thepact.co)

---

## 📊 Status

| Component | Status | URL |
|-----------|--------|-----|
| **Mobile App** | 🟡 Release Candidate | _Pending Store Approval_ |
| **Landing Page** | 🟢 Live | [thepact.co](https://thepact.co) |
| **Backend** | 🟢 Live | Supabase |

> **Last Updated:** December 17, 2025 (Commit: c4b0a34)  
> **Last Verified:** Phase 24 Complete, Phase 25 Active

---

## 🤖 AI Agent Quick Start

### The "Big Three" Documentation Files

| File | Purpose | When to Update |
|------|---------|----------------|
| **README.md** | Project overview, architecture, user-facing docs | On major features |
| **AI_CONTEXT.md** | Current state checkpoint for AI agents | Every session end |
| **ROADMAP.md** | Priorities, sprint tracking, technical debt | Every session end |

### Project Structure

```
atomichabits/
├── android/              # Native Android (Package: co.thepact.app)
├── ios/                  # Native iOS (Bundle: co.thepact.app)
├── lib/                  # === FLUTTER MOBILE APP ===
│   ├── config/deep_link_config.dart  # URL schemes (thepact://)
│   ├── data/services/ai/             # DeepSeek & Claude integration
│   └── features/witness/             # Social Contract Logic
├── landing_page/         # === REACT WEB ANCHOR (The Trojan Horse) ===
│   ├── src/components/InviteRedirector.tsx  # Smart Deep Link Handler
│   ├── netlify.toml                         # Deployment Config
│   └── .env                                 # VITE_APP_NAME="The Pact"
└── ...
```

---

## 🎯 The Core Philosophy

Traditional habit apps fail because they rely on **you**.  
**The Pact** relies on **us**.

1. **The Contract:** You don't just "set a goal." You sign a **Pact** with a friend (Witness).
2. **The Wax Seal:** A haptic-heavy, ceremonial UI that makes commitment feel weighty.
3. **The Witness:** Your friend gets notified when you succeed (or fail).
4. **Graceful Consistency:** We measure rolling consistency, not fragile streaks.

---

## 🏗️ Architecture: "The Unified Front"

We use a **Hybrid Viral Architecture** to ensure invite links work everywhere.

1. **The Signal (Mobile App):**
   - Generates a link: `https://thepact.co/join/XYZ`

2. **The Anchor (React Web):**
   - Hosted on Netlify.
   - Detects OS (Android/iOS/Desktop).
   - **Mobile:** Redirects to App Store / Play Store with `referrer` params.
   - **Desktop:** Shows a high-fidelity landing page to capture emails.

3. **The Receiver (Mobile App):**
   - Uses `PlayInstallReferrer` API on Android to auto-accept invites after install.
   - Bypasses onboarding for invited users ("The Red Carpet").

---

## 🛠️ Tech Stack

| Component | Technology | Role |
|-----------|------------|------|
| **Mobile** | Flutter 3.35.4 | The Core Experience |
| **Web** | React + Vite + Tailwind | The Landing Page / Redirector |
| **Backend** | Supabase | Auth, Database, Realtime |
| **AI (Tier 1)** | DeepSeek-V3 | Reasoning & Logic |
| **AI (Tier 2)** | Claude 3.5 Sonnet | Coaching & Empathy |
| **Hosting** | Netlify | Web Deployment |

---

## 🚀 How to Run

### Mobile App (Flutter)

```bash
flutter pub get
flutter run
```

### Landing Page (React)

```bash
cd landing_page
npm install
npm run dev
```

---

## 📖 Documentation

- **[AI_CONTEXT.md](./AI_CONTEXT.md)** - Full feature matrix, architecture deep-dive
- **[ROADMAP.md](./ROADMAP.md)** - Sprint history, current priorities, technical debt
- **[SPRINT_24_E_SPEC.md](./SPRINT_24_E_SPEC.md)** - Phase 24 "Trojan Horse" implementation

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Key Test Files

- `test/services/ai/deep_seek_service_test.dart` - AI model integration tests
- `test/services/ai/ai_service_manager_test.dart` - Tier selection logic tests

---

## 🚢 Deployment

### Mobile (Flutter)

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ipa --release
```

### Web (React)

Auto-deployed via Netlify on push to `main` branch.

**Manual deploy:**
```bash
cd landing_page
npm run build
# Upload dist/ to Netlify
```

---

## 🔑 Environment Variables

### Mobile App

Create `lib/config/ai_model_config.dart`:

```dart
class AiModelConfig {
  static const String deepSeekApiKey = 'YOUR_DEEPSEEK_KEY';
  static const String claudeApiKey = 'YOUR_CLAUDE_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_KEY';
}
```

### Landing Page

Create `landing_page/.env`:

```
VITE_APP_NAME="The Pact"
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Built with inspiration from James Clear's *Atomic Habits* and the philosophy of social accountability.
