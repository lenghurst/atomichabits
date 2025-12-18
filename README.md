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

> **Last Updated:** December 18, 2025 (Commit: TBD)  
> **Last Verified:** Phase 25 In Progress (Gemini 3 Pivot + The Lab + Wallet + Lexicon)

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
├── landing_page/         # === REACT WEB ANCHOR (The Trojan Horse) ===
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
| **AI (Tier 2)** | Gemini 3 Flash | Native Voice/Vision |
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

## 🎨 Customization & Branding

### Updating the App Icon

We use `flutter_launcher_icons` to automate icon generation.

1. **Replace Source Image:**
   Overwrite `assets/branding/app_icon.png` with your new 1024x1024 icon.

2. **Run Generation Script:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **Verify:**
   Check `android/app/src/main/res/mipmap-*` and `ios/Runner/Assets.xcassets/AppIcon.appiconset`.

See **[APP_ICON_UPDATE_GUIDE.md](./APP_ICON_UPDATE_GUIDE.md)** for full details.

---

## 📖 Documentation

- **[AI_CONTEXT.md](./AI_CONTEXT.md)** - Full feature matrix, architecture deep-dive
- **[ROADMAP.md](./ROADMAP.md)** - Sprint history, current priorities, technical debt
- **[APP_ICON_UPDATE_GUIDE.md](./APP_ICON_UPDATE_GUIDE.md)** - Branding update instructions

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
