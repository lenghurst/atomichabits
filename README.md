# Atomic Habits Hook App

A Flutter mobile habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

## 🎯 Project Overview

This app helps users build real habits by focusing on identity-based behavior change. Instead of just setting goals, users define who they want to become, then create tiny habits that align with that identity.

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with navigation setup
├── data/
│   ├── app_state.dart          # Central state management (Provider)
│   ├── notification_service.dart # Push notifications with actions
│   ├── ai_suggestion_service.dart # AI-powered habit suggestions
│   └── models/
│       ├── habit.dart          # Habit data model with consistency metrics
│       └── user_profile.dart   # User profile/identity model
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart  # Collects identity & first habit
│   ├── today/
│   │   └── today_screen.dart       # Shows habit, metrics & recovery prompts
│   └── settings/
│       └── settings_screen.dart    # Settings & app info
└── widgets/
    ├── suggestion_dialog.dart      # AI suggestion picker dialog
    ├── pre_habit_ritual_dialog.dart # Pre-habit ritual countdown modal
    └── reward_investment_dialog.dart # Post-completion reward flow
```

## 🏗️ Architecture Explained (In Plain English)

### State Management: Provider

**What it does:** Provider is like a "data warehouse" for your app. It stores information (like your habits and streak) in one central place, and automatically updates the screens when that data changes.

**How it works:**
1. **AppState** (`data/app_state.dart`) is the "warehouse" that holds all your app's data
2. **Provider** wraps the entire app (see `main.dart`) and makes this data available everywhere
3. **Consumer** widgets "subscribe" to changes - when data updates, they automatically rebuild

**Example flow:**
- User completes a habit → `completeHabitForToday()` is called
- AppState updates the streak and calls `notifyListeners()`
- The TodayScreen automatically rebuilds with the new streak number

**Why Provider?** It's beginner-friendly, widely used, and has excellent documentation. No complex setup required!

### Navigation: GoRouter

**What it does:** GoRouter handles moving between different screens in your app using simple paths (like websites).

**How it works:**
- Routes are defined in `main.dart` with paths like `/`, `/today`, `/settings`
- Use `context.go('/today')` to navigate to a screen
- The router knows to start at onboarding (`/`) if not completed, otherwise start at Today screen

**Example:**
```dart
// Navigate to Today screen
context.go('/today');

// Go back to previous screen
context.go('/');
```

### Data Models

**Habit** (`data/models/habit.dart`):
- Represents a single habit with name, identity, tiny version, streak, etc.
- Has methods to create copies with updates (`copyWith`)
- Can be saved/loaded from JSON for persistence

**UserProfile** (`data/models/user_profile.dart`):
- Stores the user's desired identity ("I am a person who...")
- Keeps track of name and creation date

## 🎨 Features Implemented

### ✅ Onboarding Screen
- Collects user's name
- Asks "Who do you want to become?" (identity-based)
- Creates first habit with a tiny version (2-minute rule)
- Implementation intentions: time and location
- **Habit Stacking**: Optional anchor event ("After [X], I will [habit]")
- **Make it Attractive**: Temptation bundling and pre-habit rituals
- **Environment Design**: Cues to add and distractions to remove
- Validates all inputs before proceeding

### ✅ Today Screen
- Shows personalized greeting with identity reminder
- Displays today's habit with the tiny version
- **Graceful Consistency Score** (0-100) instead of fragile streaks
- Total "Days Showed Up" counter (never resets)
- Rolling 4-week adherence percentage
- **Never Miss Twice** recovery prompts
- Shows temptation bundle, environment cues, and distraction reminders
- **Pre-habit ritual modal** with 30-second countdown
- Big "Mark as Complete" button (or completed status)
- Quick access to Settings

### ✅ Graceful Consistency Metrics
Based on James Clear's philosophy that "missing once is an accident, missing twice is the start of a new habit":
- **Days Showed Up**: Cumulative total that NEVER resets (key motivator)
- **Graceful Consistency Score**: Rolling 4-week average + recovery bonus
- **Never Miss Twice Wins**: Tracks times user recovered after single miss
- **Minimum Version Count**: Tracks when user did just the 2-minute version
- De-emphasizes streak count (still tracked, but not the focus)

### ✅ AI Suggestion System
Context-aware suggestions powered by async architecture:
- **Remote LLM integration** with 5-second timeout
- **Local heuristic fallback** ensures suggestions always work
- Suggests temptation bundles based on habit type and time of day
- Suggests pre-habit rituals for mental preparation
- Suggests environment cues specific to location
- Suggests distractions to remove based on habit category

### ✅ Settings Screen
- Placeholder sections for future features:
  - Profile editing
  - Habit management
  - History viewing
  - Backup/restore
- App information and about section

## 🚀 How to Run the App

### Option 1: Web Preview (Easiest!)

**Your app is already running!** 🎉

🔗 **Web Preview URL:** https://5060-i7bourjpm740ju7sjx1pf-cc2fbc16.sandbox.novita.ai

Just click the link above and try the app in your browser!

### Option 2: Android Device or Emulator

**Prerequisites:**
- Android device with USB debugging enabled, OR
- Android emulator running on your computer
- Flutter SDK installed on your computer

**Steps:**

1. **Clone this project to your computer:**
   ```bash
   # Copy the flutter_app folder to your local machine
   ```

2. **Connect your Android device** (or start an emulator)

3. **Run the app:**
   ```bash
   cd flutter_app
   flutter run
   ```

4. **The app will install and launch on your device!**

### Option 3: Build APK for Installation

```bash
cd flutter_app
flutter build apk --release
```

The APK will be created at: `build/app/outputs/flutter-apk/app-release.apk`

Transfer this file to your Android phone and install it!

## 🧪 Testing the App

Try this user journey:

1. **Start the app** - you'll see the Onboarding screen
2. **Fill in your details:**
   - Name: "Alex"
   - Identity: "I am a person who reads daily"
   - Habit: "Read every day"
   - Tiny version: "Read one page before bed"
3. **Click "Start Building Habits"** - navigates to Today screen
4. **See your identity reminder** at the top
5. **Notice the streak counter** (starts at 0)
6. **Click "Mark as Complete"** - watch the streak increase to 1!
7. **Notice the button changes** to show completion
8. **Click Settings icon** to see the settings screen

## 📚 Key Concepts Used

### From Atomic Habits:
- **Identity-based habits**: "I am a person who..." vs "I want to do..."
- **2-minute rule**: Make habits so small you can't say no
- **Habit stacking**: "After [anchor event], I will [habit]"
- **Never Miss Twice**: Missing once is accident, missing twice starts new habit
- **Make it Attractive**: Temptation bundling pairs habit with enjoyment
- **Environment Design**: Add cues, remove distractions
- **Graceful Consistency**: Focus on showing up, not perfect streaks

### From Hook Model:
- **Trigger**: Implementation intention + environment cues
- **Action**: Clicking "Mark as Complete" (easy action)
- **Variable Reward**: Graceful consistency score, recovery wins
- **Investment**: Days showed up counter that never resets

### From Fogg Behavior Model:
- **Motivation**: Identity reminder and graceful consistency
- **Ability**: Tiny 2-minute version makes it easy
- **Prompt**: Habit stacking anchor + scheduled notifications

## 🔮 Future Features (Not Yet Implemented)

- [ ] Multiple habits support
- [ ] Habit history and calendar view
- [ ] Weekly/monthly analytics dashboard
- [ ] Social accountability features
- [ ] Habit chains visualization
- [ ] Export data to CSV/JSON
- [ ] Cloud sync and backup

## 🛠️ Technologies Used

- **Flutter 3.35.4** - UI framework
- **Dart 3.9.2** - Programming language
- **Provider 6.1.5+1** - State management
- **GoRouter ^14.0.0** - Navigation
- **Hive** - Local data persistence
- **http** - Remote API calls for AI suggestions
- **confetti_widget** - Celebration animations
- **Material Design 3** - UI design system

## 📖 Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Atomic Habits by James Clear](https://jamesclear.com/atomic-habits)
- [Hooked by Nir Eyal](https://www.nirandfar.com/hooked/)

## 💡 Tips for Non-Technical Users

**What is Flutter?** Flutter is like a toolbox for building mobile apps. You write code once, and it can run on both Android and iPhone.

**What is Provider?** Think of it as a smart messenger that tells your app screens when data changes, so they can update automatically.

**What is a Widget?** Everything you see in Flutter is a "widget" - buttons, text, screens, etc. Widgets are like LEGO blocks you stack together to build your app.

**What is State?** "State" is the data that can change in your app - like your habit streak or whether you completed today's habit.

---

Built with ❤️ using Flutter | Based on science-backed behavior change principles
