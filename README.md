# Atomic Habits Hook App

A Flutter mobile habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

## Project Overview

This app helps users build real habits by focusing on identity-based behavior change. Instead of just setting goals, users define who they want to become, then create tiny habits that align with that identity.

**Key Differentiator:** Unlike most habit trackers that are "fancy checklists," this app focuses on understanding *why* you miss habits and provides AI-powered coaching to help you design better systems.

## Project Structure

```
lib/
├── main.dart                         # App entry point with navigation & service init
├── data/
│   ├── app_state.dart                # Central state management (Provider)
│   ├── models/
│   │   ├── habit.dart                # Habit data model with history & analytics
│   │   ├── user_profile.dart         # User profile/identity model
│   │   ├── user_preferences.dart     # User customization settings
│   │   └── completion_record.dart    # Daily completion with mood/obstacles
│   └── services/
│       └── reflection_coach_service.dart  # AI coaching with Gemini
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart    # Collects identity & first habit
│   ├── today/
│   │   └── today_screen.dart         # Shows today's habits & streaks
│   ├── settings/
│   │   └── settings_screen.dart      # Settings, habits list, personalization
│   ├── habits/
│   │   ├── add_habit_screen.dart     # Create new habits
│   │   └── edit_habit_screen.dart    # Edit existing habits
│   └── history/
│       ├── habit_history_screen.dart     # Calendar view with streaks
│       └── completion_detail_sheet.dart  # Reflection UI with AI coaching
└── widgets/
    └── voice_input_button.dart       # Speech-to-text input component
```

## Features

### Multiple Habits Support
- Track unlimited habits with individual streaks
- Each habit has its own implementation intention, temptation bundle, and tiny version
- Quick habit switching from the Today screen
- Manage habits from Settings

### Habit History Calendar
- Visual calendar showing completed (green), missed (red), and unmarked days
- Streak statistics: current streak, longest streak, total completions
- Weekly progress bar
- Milestone celebrations at 7, 14, 21, 30, 50, 66, and 100 days
- Tap any day to view or add reflection details

### "What Got in the Way?" - Obstacle Tracking
This is the core differentiator. When you miss a habit, the app helps you understand why:

- **12 Emoji-based obstacle categories:**
  - 😴 Too tired
  - ⏰ No time
  - 🤯 Overwhelmed
  - 😷 Felt unwell
  - 🏠 Away from home
  - 📱 Got distracted
  - 😔 Low motivation
  - 🌧️ Bad mood
  - 👥 Social situation
  - 🔄 Routine disrupted
  - 🤔 Forgot
  - ❓ Other

- **AI Coaching Tips:** Each obstacle shows contextual advice based on Atomic Habits principles
- **Pattern Detection:** The app tracks obstacle frequency to identify recurring issues

### AI Reflection Coach (Gemini-Powered)
- **Conversational coaching** when you select an obstacle
- Coach understands your habit context (streak, implementation time, tiny version)
- Provides personalized advice based on the Four Laws of Behavior Change
- Focus on systems design, not willpower
- Follow-up conversation capability

### Voice Input
- Speech-to-text for obstacle descriptions and notes
- Animated recording indicator
- Works in reflection sheets and coach conversations

### Mood Tracking with Customizable Emojis
Track how you felt each day with a 1-5 mood scale. Choose from 6 emoji presets:

| Preset | Emojis |
|--------|--------|
| Classic | 😢 😕 😐 🙂 😄 |
| Expressive | 😭 😣 😶 😊 🤩 |
| Thumbs | 👎 👇 ✊ 👆 👍 |
| Energy | 🪫 😮‍💨 😑 ⚡ 🔥 |
| Weather | 🌧️ 🌥️ ☁️ 🌤️ ☀️ |
| Hearts | 💔 🩶 🤍 💙 ❤️ |

### Settings & Personalization
- Add/edit/delete habits
- Choose mood emoji preset
- Toggle AI coaching tips on/off
- View habit history
- Reset all data option

## Configuration

### Gemini API Key (Required for AI Coaching)

The AI coaching feature requires a Google Gemini API key. You can run the app without it, but the "Talk to Coach" feature will show as offline.

**Option 1: Pass at runtime**
```bash
flutter run --dart-define=GEMINI_API_KEY=your_api_key_here
```

**Option 2: Build with key**
```bash
flutter build apk --dart-define=GEMINI_API_KEY=your_api_key_here
```

**Get a Gemini API Key:**
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click "Create API Key"
3. Copy the key and use it as shown above

**Note:** The AI coaching will gracefully fall back to static tips when:
- No API key is provided
- Device is offline
- API request fails

## How to Run

### Prerequisites
- Flutter SDK 3.9.2 or later
- Dart 3.9.2 or later

### Running the App

```bash
# Get dependencies
flutter pub get

# Run without AI coaching
flutter run

# Run with AI coaching enabled
flutter run --dart-define=GEMINI_API_KEY=your_key
```

### Building for Release

```bash
# Android APK
flutter build apk --release --dart-define=GEMINI_API_KEY=your_key

# Android App Bundle
flutter build appbundle --release --dart-define=GEMINI_API_KEY=your_key

# iOS
flutter build ios --release --dart-define=GEMINI_API_KEY=your_key
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| provider | 6.1.5+1 | State management |
| go_router | ^14.0.0 | Navigation |
| hive_flutter | 1.1.0 | Local data persistence |
| shared_preferences | 2.5.3 | Simple key-value storage |
| table_calendar | ^3.1.2 | Calendar widget for history |
| google_generative_ai | ^0.4.6 | Gemini AI for coaching |
| speech_to_text | ^7.0.0 | Voice input |
| connectivity_plus | ^6.1.4 | Online/offline detection |
| confetti | ^0.7.0 | Celebration animations |
| flutter_local_notifications | ^18.0.1 | Reminders |
| http | 1.5.0 | HTTP client |

## Architecture

### State Management: Provider
- `AppState` is the central data store
- Manages habits, user profile, preferences, and completion records
- Persists data to Hive local storage
- Notifies UI of changes automatically

### Navigation: GoRouter
- Declarative routing with paths like `/today`, `/history/:habitId`
- Conditional initial route based on onboarding status

### AI Service: ReflectionCoachService
- Singleton service initialized at app startup
- Uses Gemini 1.5 Flash for fast responses
- System prompt based on Atomic Habits methodology
- Maintains chat session for follow-up questions
- Automatic fallback to static tips when offline

## Key Concepts

### From Atomic Habits:
- **Identity-based habits**: "I am a person who..." vs "I want to do..."
- **2-minute rule**: Make habits so small you can't say no
- **4 Laws of Behavior Change**: Make it obvious, attractive, easy, satisfying
- **Environment > Willpower**: Design your environment for success
- **Never miss twice**: The goal is getting back on track, not perfection

### From Hook Model:
- **Trigger**: Identity reminder, streak display, notifications
- **Action**: One-tap completion, voice input
- **Variable Reward**: Streak growth, milestone celebrations, AI insights
- **Investment**: Building streak, reflecting on obstacles

### From Fogg Behavior Model:
- **Motivation**: Identity alignment, visible progress
- **Ability**: Tiny versions, voice input, simple UI
- **Prompt**: Daily reminders, implementation intentions

## Future Features

- [ ] Notifications and reminders
- [ ] Habit stacking (link habits together)
- [ ] Environment design suggestions
- [ ] Weekly/monthly AI-powered reviews
- [ ] Backup and restore to cloud
- [ ] Dark mode
- [ ] Widget for home screen

## Troubleshooting

### AI Coach shows "offline"
- Check that you provided GEMINI_API_KEY
- Verify internet connection
- Check API key is valid at [Google AI Studio](https://aistudio.google.com/)

### Voice input not working
- Grant microphone permission when prompted
- Some devices/emulators don't support speech recognition
- Check that speech_to_text package is properly installed

### Data not persisting
- Ensure Hive is initialized before app runs
- Check for storage permission on Android

## Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [Atomic Habits by James Clear](https://jamesclear.com/atomic-habits)
- [Hooked by Nir Eyal](https://www.nirandfar.com/hooked/)
- [Google Gemini API](https://ai.google.dev/docs)

---

Built with Flutter | Based on science-backed behavior change principles
