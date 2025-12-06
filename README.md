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
│   ├── ai_suggestion_service.dart  # AI suggestions (remote LLM + local fallback)
│   ├── notification_service.dart   # Daily habit reminders
│   └── models/
│       ├── habit.dart           # Habit data model (good & bad habits)
│       ├── user_profile.dart    # User profile/identity model
│       ├── habit_circle.dart    # Social layer: habit circles & members
│       ├── creator_session.dart # Creator mode: sessions & summaries
│       ├── chat_message.dart    # Chat message model for AI conversations
│       └── chat_conversation.dart # Conversation history & persistence
│   └── services/
│       └── gemini_chat_service.dart  # Conversational AI (Gemini 2.5 Flash)
├── features/
│   ├── onboarding/
│   │   ├── onboarding_screen.dart    # Form-based onboarding
│   │   ├── ai_onboarding_screen.dart # AI conversational onboarding
│   │   └── widgets/
│   │       ├── chat_bubble.dart      # Chat message UI
│   │       └── voice_input_button.dart # Speech-to-text input
│   ├── today/
│   │   └── today_screen.dart       # Shows today's habit & streak
│   ├── settings/
│   │   └── settings_screen.dart    # Settings & feature navigation
│   ├── bad_habit/
│   │   └── bad_habit_screen.dart   # Change/Reduce Habit Toolkit
│   ├── social/
│   │   └── social_screen.dart      # Social & Norms Layer
│   └── creator/
│       └── creator_mode_screen.dart # Creator Mode (quantity-first)
└── widgets/
    ├── suggestion_dialog.dart       # AI suggestion picker
    ├── reward_investment_dialog.dart # Hook Model reward flow
    └── pre_habit_ritual_dialog.dart  # Pre-habit ritual with timer
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

### ✅ Core Habit Tracking
- **Identity-based onboarding** - Define who you want to become
- **2-minute rule** - Create tiny versions of habits
- **Implementation intentions** - When/where you'll do the habit
- **Streak tracking** - Visual progress with fire icons
- **Hook Model reward flow** - Confetti celebration + investment phase

### ✅ Make It Attractive
- **Temptation bundling** - Pair habits with enjoyable activities
- **Pre-habit rituals** - 30-second mental preparation with timer
- **AI suggestions** - Context-aware recommendations (remote LLM + local fallback)

### ✅ Environment Design
- **Environment cues** - Visual triggers for habits
- **Distraction removal** - Friction for competing behaviors
- **AI-powered suggestions** - Based on time, location, and habit type

### ✅ Change / Reduce Habit Toolkit (Bad Habits)
- **Habit substitution** - Map needs to healthier alternatives
- **Cue firewall** - Block triggers by time, place, people, emotion
- **Bright-line rules** - "I don't..." rules with 4 intensity levels (gentle → absolute)
- **Progressive extremism** - Rules that tighten over time
- **Friction/guardrails** - Add steps between cue and bad behavior
- **Avoided tracking** - Track successful resistance

### ✅ Social & Norms Layer
- **People cues** - "When I'm with X, I do Y" connections
- **Habit circles** - Small groups with shared habits
- **Champion/guide support** - Local leaders (Mozambique model)
- **Norm messaging** - "Around here, we..." social proof
- **Group check-ins** - Weekly/daily accountability

### ✅ Creator Mode
- **Quantity-first tracking** - Reps over quality (photo class story)
- **Session types** - Generate (create) vs Refine (deliberate practice)
- **Weekly rep goals** - Progress tracking with goal percentage
- **Minimal workspace** - WordStar-style focus support
- **Session learnings** - Track insights from each creative session
- **Weekly summaries** - Volume + learnings, not "was it good?"

### ✅ Conversational AI Coach (Gemini 2.5 Flash)
- **AI-powered onboarding** - Natural conversation to create habits
- **Atomic Habits expert** - Trained on identity, 2-minute rule, implementation intentions
- **Constructive critique** - Challenges vague or too-ambitious goals
- **Streaming responses** - Real-time typing effect for natural feel
- **Voice input** - Speech-to-text for hands-free interaction
- **Conversation persistence** - 60-day history for continuity
- **Context-aware** - References user's existing habits and progress

### ✅ Notifications & Reminders
- **Daily habit reminders** - At your scheduled time
- **Action buttons** - Mark Done or Snooze from notification
- **Temptation bundle included** - Reminder shows your paired reward

## ⚙️ Configuration

### Gemini AI Setup (for Conversational AI Coach)

To enable the AI-powered conversational onboarding, you need a Gemini API key:

1. **Get a free API key** at [Google AI Studio](https://makersuite.google.com/app/apikey)

2. **Add your key** to `lib/data/services/gemini_chat_service.dart`:
   ```dart
   static const String _defaultApiKey = 'YOUR_GEMINI_API_KEY';
   ```

3. **For production**, use environment variables or secure storage instead of hardcoding.

> **Note:** The app works without an API key, but the AI coach will show a configuration message. All other features remain fully functional.

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

- [ ] Habit history and calendar view
- [ ] Habit stacking (link habits together)
- [ ] 4 Laws of Behavior Change framework UI
- [ ] Weekly/monthly analytics dashboard
- [ ] Backup and restore functionality
- [ ] Social habit circle real-time sync
- [ ] Push notifications for group check-ins

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
