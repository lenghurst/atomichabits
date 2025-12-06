# Atomic Habits - Identity-Based Habit Tracker

A Flutter mobile app that helps you build lasting habits through identity-based behavior change, powered by principles from James Clear's *Atomic Habits*, Nir Eyal's *Hook Model*, and B.J. Fogg's *Behavior Model*.

## 🎯 What Makes This Different

Instead of just tracking habits, this app helps you **become the person** you want to be:

- **Identity-First**: Define who you want to become, not just what you want to do
- **AI-Powered Suggestions**: Get personalized recommendations for making habits attractive and easy
- **2-Minute Rule**: Start with tiny versions that are impossible to fail
- **Implementation Intentions**: Precise plans for when and where you'll do your habit
- **Environment Design**: Visual cues to trigger habits and remove distractions
- **Hook Model Integration**: Built-in rewards and investment mechanisms to create habit loops

## ✨ Features

### Core Habit Building
- ✅ **Identity-based onboarding** - "I am a person who..."
- ✅ **Tiny habit versions** - Apply the 2-minute rule
- ✅ **Implementation intentions** - Specific time and location planning
- ✅ **Daily streak tracking** - Visual progress with fire icons
- ✅ **Habit completion with confetti** - Celebrate small wins
- ✅ **Investment mechanism** - Reinforce commitment after each completion

### Make Habits Attractive (2nd Law of Behavior Change)
- ✅ **Temptation bundling** - Pair habits with things you enjoy
- ✅ **Pre-habit rituals** - Mental preparation with guided 30-second countdown
- ✅ **AI-powered suggestions** - Get contextual ideas for each element

### Make Habits Easy (3rd Law of Behavior Change)
- ✅ **Environment cues** - Visual triggers to start your habit
- ✅ **Distraction removal** - Friction-adding guardrails
- ✅ **Optimization tips** - Get 8 suggestions to improve your habit system

### Technical Features
- ✅ **Local data persistence** - Hive database stores all your data
- ✅ **Daily notifications** - Reminders at your implementation time
- ✅ **Offline AI suggestions** - Local heuristics with optional remote LLM integration
- ✅ **Progressive Web App** - Works on mobile, desktop, and web

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point & navigation
├── data/
│   ├── app_state.dart                 # State management (Provider)
│   ├── ai_suggestion_service.dart     # AI suggestions (local + remote)
│   ├── notification_service.dart      # Daily habit reminders
│   └── models/
│       ├── habit.dart                 # Habit data model (8 fields)
│       └── user_profile.dart          # User identity profile
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # Identity + habit creation
│   ├── today/
│   │   └── today_screen.dart         # Daily habit view & completion
│   └── settings/
│       └── settings_screen.dart      # App settings
└── widgets/
    ├── pre_habit_ritual_dialog.dart   # 30-second ritual modal
    ├── ai_suggestion_dialog.dart      # "Ideas" button suggestions
    └── optimization_tips_dialog.dart  # 8-tip improvement dialog
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** 3.35.4 or later ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart** 3.9.2 or later (comes with Flutter)
- **Android device/emulator** or **iOS device/simulator**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/lenghurst/atomichabits.git
   cd atomichabits
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Run on connected device/emulator
   flutter run

   # Run on specific device
   flutter devices  # List available devices
   flutter run -d <device-id>

   # Run in Chrome (web)
   flutter run -d chrome
   ```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (requires macOS with Xcode):**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
# Output: build/web/
```

## 🧪 Testing

See [QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md) for a 5-minute test walkthrough, or [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing scenarios.

### Quick Test Journey

1. **Clear browser data** (F12 > Application > IndexedDB > Delete all)
2. **Complete onboarding** with sample habit:
   - Identity: `reads every day`
   - Habit: `Read one page`
   - Time: `22:00`, Location: `In bed`
3. **Try "Ideas" buttons** - Get AI suggestions for:
   - Temptation bundling (herbal tea, candles)
   - Pre-habit ritual (breathing exercises)
   - Environment cues (book on pillow)
   - Distraction removal (charge phone elsewhere)
4. **Test Today screen**:
   - View your complete habit plan
   - Click "Start ritual" for 30-second countdown
   - Mark habit as complete (confetti!)
   - Answer investment question
5. **Get optimization tips** - 8 contextual suggestions

## 🏗️ Architecture

### State Management: Provider

**AppState** (`lib/data/app_state.dart`) is the central data store:
- Holds user profile and habit data
- Manages habit completion and streak logic
- Calls `notifyListeners()` to trigger UI updates
- Persists data to Hive database

**Why Provider?** Simple, performant, and officially recommended by Flutter team.

### Data Persistence: Hive

All data is stored locally using Hive (NoSQL database):
- **Box: `userProfile`** - Name and identity
- **Box: `habit`** - Complete habit model
- **Box: `appState`** - Onboarding completion status

Data survives app restarts and is stored in IndexedDB (web) or local files (mobile).

### AI Suggestion System

**Async Remote + Local Fallback Architecture:**
1. Attempts to fetch suggestions from remote LLM endpoint (5s timeout)
2. Falls back to local heuristics if remote fails/unavailable
3. Local heuristics use keyword matching and time-of-day logic
4. Returns 3 contextual suggestions per category

**Configuration:** Edit `lib/data/ai_suggestion_service.dart` to add your LLM endpoint.

### Navigation: GoRouter

Path-based routing with automatic onboarding redirect:
- `/` - Onboarding (if not completed)
- `/today` - Daily habit view (default if onboarded)
- `/settings` - App settings

## 🎨 Design Principles

### From *Atomic Habits* (James Clear)

**The 4 Laws of Behavior Change:**
1. ✅ **Make it Obvious** - Implementation intentions (time + location)
2. ✅ **Make it Attractive** - Temptation bundling + pre-habit rituals
3. ✅ **Make it Easy** - 2-minute rule + environment design
4. ⏳ **Make it Satisfying** - Habit tracking coming soon

**Identity-Based Habits:**
- Focus on who you wish to become, not what you want to achieve
- Every habit completion is a "vote" for your new identity
- App reinforces identity in notifications and UI messaging

### From *Hook Model* (Nir Eyal)

**Trigger → Action → Variable Reward → Investment:**
- **Trigger**: Daily notification + identity reminder
- **Action**: Simple "Mark as Complete" button (2-minute version)
- **Variable Reward**: Confetti animation, streak increase, completion status
- **Investment**: Answer reflection question to deepen commitment

### From *Fogg Behavior Model*

**B = MAP (Behavior = Motivation × Ability × Prompt):**
- **Motivation**: Identity alignment + visible streak
- **Ability**: 2-minute tiny version ensures high ability
- **Prompt**: Daily notification at implementation time

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.5+1           # State management
  go_router: ^14.0.0           # Navigation
  hive: ^2.2.3                 # Local database
  hive_flutter: ^1.1.0         # Hive for Flutter
  confetti: ^0.7.0             # Celebration animations
  flutter_local_notifications: ^18.0.1  # Daily reminders
  http: ^1.2.2                 # Remote LLM calls

dev_dependencies:
  hive_generator: ^2.0.1       # Generate Hive adapters
  build_runner: ^2.4.14        # Code generation
```

## 🔐 Security & Privacy

### API Key Management

**Current status:** ✅ **No API keys required** - local AI suggestions work offline

**Optional LLM Integration:**
1. Create `.env` file in project root:
   ```
   LLM_ENDPOINT=https://your-llm-proxy.com/api
   LLM_API_KEY=your-secret-key-here
   ```

2. Add `.env` to `.gitignore` (already included)

3. Use `flutter_dotenv` package to load environment variables

**⚠️ NEVER commit API keys to version control!**

### Data Privacy

- ✅ All data stored **locally** on user's device
- ✅ No analytics or tracking
- ✅ No cloud sync (user owns their data)
- ✅ Optional remote LLM calls (disabled by default)

## 🐛 Known Issues

### Non-Critical Warnings

From `flutter analyze`:
- **INFO**: Unnecessary import of `flutter/foundation.dart` in `today_screen.dart`
- **INFO**: `BuildContext` used across async gap (safely guarded with `if (mounted)`)

### Platform Limitations

**Web:**
- Local notifications show permission request but don't display (browser limitation)
- Use Android/iOS for full notification testing

**iOS:**
- Requires notification permission dialog (handled automatically)
- Background notification delivery depends on system settings

## 📚 Documentation

- [QUICK_TEST_GUIDE.md](QUICK_TEST_GUIDE.md) - 5-minute test walkthrough
- [TESTING_GUIDE.md](TESTING_GUIDE.md) - Comprehensive testing scenarios
- [AI_SUGGESTIONS_GUIDE.md](AI_SUGGESTIONS_GUIDE.md) - AI feature documentation
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Technical implementation details
- [ASYNC_SUGGESTIONS_UPGRADE.md](ASYNC_SUGGESTIONS_UPGRADE.md) - Remote LLM integration guide

## 🔮 Roadmap

- [ ] Multiple habits support
- [ ] Habit history calendar view
- [ ] Weekly/monthly analytics
- [ ] Habit stacking (link habits together)
- [ ] Make it Satisfying (4th Law) - immediate rewards
- [ ] Cloud sync (optional)
- [ ] Social accountability features
- [ ] Export habit data (CSV, JSON)

## 🛠️ Development

### Run Tests
```bash
flutter test
```

### Code Generation (for Hive models)
```bash
flutter pub run build_runner build
```

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **James Clear** - *Atomic Habits* framework
- **Nir Eyal** - *Hook Model* principles
- **B.J. Fogg** - *Behavior Model* insights
- **Flutter Community** - Amazing framework and packages

## 📧 Contact

**Repository:** [github.com/lenghurst/atomichabits](https://github.com/lenghurst/atomichabits)

**Issues:** [Report bugs or request features](https://github.com/lenghurst/atomichabits/issues)

---

**Built with ❤️ using Flutter** | **Based on science-backed behavior change principles**

*"You do not rise to the level of your goals. You fall to the level of your systems."* - James Clear
