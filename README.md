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
│   ├── models/
│   │   ├── habit.dart          # Habit data model
│   │   └── user_profile.dart   # User profile/identity model
│   └── repositories/           # (Future: data persistence layer)
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart  # Collects identity & first habit
│   ├── today/
│   │   └── today_screen.dart       # Shows today's habit & streak
│   └── settings/
│       └── settings_screen.dart    # Settings & app info
└── widgets/
    └── common/                 # (Future: reusable UI components)
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
- Validates all inputs before proceeding

### ✅ Today Screen
- Shows personalized greeting with identity reminder
- Displays today's habit with the tiny version
- Shows current streak with fire icon
- Big "Mark as Complete" button (or completed status)
- Quick access to Settings

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
- **Habit stacking**: (Future feature) Link new habits to existing ones
- **Visual cues**: Streak counter provides visible progress

### From Hook Model:
- **Trigger**: Seeing your identity reminder and streak
- **Action**: Clicking "Mark as Complete" (easy action)
- **Variable Reward**: Watching streak increase, seeing completion status
- **Investment**: Building streak makes you more committed

### From Fogg Behavior Model:
- **Motivation**: Identity and visible streak
- **Ability**: Tiny 2-minute version makes it easy
- **Prompt**: Daily reminder when you open the app

## 🔮 Future Features (Not Yet Implemented)

- [ ] Multiple habits support
- [ ] Habit history and calendar view
- [ ] Reminders and notifications
- [ ] Habit stacking (link habits together)
- [ ] Data persistence (save to local storage)
- [ ] Environment design suggestions
- [ ] 4 Laws of Behavior Change framework
- [ ] Weekly/monthly analytics
- [ ] Backup and restore functionality

## 🛠️ Technologies Used

- **Flutter 3.35.4** - UI framework
- **Dart 3.9.2** - Programming language
- **Provider 6.1.5+1** - State management
- **GoRouter ^14.0.0** - Navigation
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
