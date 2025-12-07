# Atomic Habits App

A Flutter mobile habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

## 🎯 Project Overview

This app helps users build real habits by focusing on identity-based behavior change. Instead of just setting goals, users define who they want to become, then create tiny habits that align with that identity.

**Key Features:**
- AI-powered conversational onboarding (Gemini 2.5 Flash)
- Firebase authentication (Email, Google, Guest)
- Streak tracking with confetti rewards
- Bad habit toolkit with substitution strategies
- Social accountability circles

---

## ⚙️ Setup Guide (Step-by-Step)

This guide assumes you have no technical experience. Follow each step carefully.

### Prerequisites

Before starting, you need:
1. **Flutter SDK** installed ([Install Flutter](https://docs.flutter.dev/get-started/install))
2. **Android Studio** or **VS Code** with Flutter extension
3. A **Google account** for Firebase and Gemini

---

### 🔥 Firebase Setup (Authentication)

Firebase handles user login. This is **required** for the app to work.

#### Step 1: Create a Firebase Project

1. Open your web browser and go to: **https://console.firebase.google.com/**
2. Sign in with your Google account
3. Click the big **"Create a project"** button (or "Add project")
4. Enter a project name: `atomic-habits-app`
5. Click **Continue**
6. Google Analytics: You can disable this (toggle off) - it's optional
7. Click **Create project**
8. Wait for it to finish, then click **Continue**

#### Step 2: Add Your Android App to Firebase

1. On your Firebase project dashboard, look for the Android icon (little robot) and click it
2. Fill in these fields:
   - **Android package name:** `com.example.atomic_habits_hook_app`
   - **App nickname:** `Atomic Habits` (optional)
   - **Debug signing certificate:** Leave blank for now (we'll add this later)
3. Click **Register app**
4. You'll see a button to **Download google-services.json** - click it
5. Save this file somewhere you can find it (like your Downloads folder)
6. **Important:** Copy this file to your project folder:
   ```
   Your project folder/android/app/google-services.json
   ```
   (Replace the existing placeholder file if there is one)
7. Click **Next** through the remaining steps (the code changes are already done)
8. Click **Continue to console**

#### Step 3: Enable Authentication Methods

1. In Firebase Console, look at the left sidebar
2. Click **Build** → **Authentication**
3. Click the **Get started** button
4. You'll see the **Sign-in method** tab - click on it

**Enable Email/Password:**
1. Click on **Email/Password**
2. Toggle the first switch to **Enable**
3. Click **Save**

**Enable Google Sign-In:**
1. Click on **Google**
2. Toggle the switch to **Enable**
3. Enter your email in **Project support email**
4. Click **Save**

**Enable Guest Mode (Anonymous):**
1. Click on **Anonymous**
2. Toggle the switch to **Enable**
3. Click **Save**

#### Step 4: Add SHA-1 Fingerprint (Required for Google Sign-In)

This is a security key that connects your computer to Firebase.

**On Mac/Linux:**
1. Open Terminal
2. Navigate to your project: `cd /path/to/atomichabits`
3. Run: `cd android && ./gradlew signingReport`
4. Look for the line that says `SHA1:` followed by a long code
5. Copy that code (it looks like: `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`)

**On Windows:**
1. Open Command Prompt
2. Navigate to your project: `cd C:\path\to\atomichabits`
3. Run: `cd android && gradlew signingReport`
4. Look for and copy the SHA1 code

**Add it to Firebase:**
1. Go to Firebase Console → click the gear icon ⚙️ → **Project settings**
2. Scroll down to **Your apps** section
3. Find your Android app
4. Click **Add fingerprint**
5. Paste your SHA1 code
6. Click **Save**

---

### 🤖 Gemini AI Setup (Conversational Coach)

The AI coach uses Google's Gemini 2.5 Flash. You need a free API key.

#### Step 1: Get Your API Key

1. Go to: **https://aistudio.google.com/apikey**
2. Sign in with your Google account
3. Click **Create API key**
4. Select your Firebase project (or create a new one)
5. Your API key will appear - it looks like: `AIzaSyABC123...`
6. **Copy this key** and save it somewhere safe (you can't see it again!)

#### Step 2: Add the Key to Your App

1. Open your project in your code editor
2. Find this file: `lib/data/services/gemini_chat_service.dart`
3. Look for this line near the top:
   ```dart
   static const String _defaultApiKey = 'your-api-key-here';
   ```
4. Replace `your-api-key-here` with your actual API key:
   ```dart
   static const String _defaultApiKey = 'AIzaSyABC123yourActualKeyHere';
   ```
5. Save the file

**Security Note:** For a production app, you should use environment variables instead of hardcoding the key. But for personal use/testing, this works fine.

---

### 🔐 Google OAuth Setup (Already Configured)

Google Sign-In works automatically once you've:
1. Added `google-services.json` to `android/app/`
2. Enabled Google Sign-In in Firebase Authentication
3. Added your SHA-1 fingerprint

The Flutter packages (`google_sign_in`, `firebase_auth`) handle everything else.

---

## 🚀 Running the App

### Option 1: Android Device

1. **Enable Developer Mode on your phone:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect your phone** to your computer via USB

3. **Run the app:**
   ```bash
   cd /path/to/atomichabits
   flutter run
   ```

4. The app will install and launch on your phone!

### Option 2: Android Emulator

1. **Open Android Studio**
2. Go to Tools → Device Manager
3. Create a new virtual device (e.g., Pixel 6)
4. Start the emulator
5. Run: `flutter run`

### Option 3: Build APK

```bash
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

Transfer this to your Android phone and install it.

---

## 🧪 Testing the App

1. **Launch the app** - You'll see the login screen
2. **Sign in:**
   - Try **Continue as Guest** for quick testing
   - Or create an account with email/password
   - Or use **Continue with Google**
3. **AI Onboarding:**
   - The AI coach will guide you through creating your first habit
   - It asks about your identity, habit, when/where you'll do it
   - Speak or type your responses
4. **Today Screen:**
   - See your habit and streak
   - Tap "Mark as Complete" to track progress
   - Watch the confetti celebration!
5. **Settings:**
   - Explore Bad Habits, Social, and Creator Mode features

---

## 📁 Project Structure

```
lib/
├── main.dart                         # App entry + routing
├── data/
│   ├── app_state.dart                # Central state management
│   ├── services/
│   │   ├── auth_service.dart         # Firebase authentication
│   │   └── gemini_chat_service.dart  # AI conversational coach
│   └── models/                       # Data models
├── features/
│   ├── auth/
│   │   └── login_screen.dart         # Login/signup page
│   ├── onboarding/
│   │   ├── ai_onboarding_screen.dart # AI-powered onboarding
│   │   └── onboarding_screen.dart    # Form-based fallback
│   ├── today/                        # Main habit tracking
│   ├── settings/                     # Settings & navigation
│   ├── bad_habit/                    # Bad habit toolkit
│   ├── social/                       # Social features
│   └── creator/                      # Creator mode
└── widgets/                          # Reusable UI components
```

---

## 🎨 Features

### Authentication
- Email/Password signup and login
- Google One-Tap Sign-In
- Guest mode (try without account)
- Sign out with data preservation

### AI Conversational Coach
- Natural language onboarding
- Atomic Habits expert guidance
- Challenges vague or ambitious goals
- Voice input support
- 60-day conversation history

### Core Habit Tracking
- Identity-based habits ("I am a person who...")
- 2-minute rule (tiny versions)
- Implementation intentions (when/where)
- Streak tracking with rewards
- Hook Model: Trigger → Action → Reward → Investment

### Bad Habit Toolkit
- Habit substitution mapping
- Cue firewall (block triggers)
- Bright-line rules ("I don't...")
- Progressive friction/guardrails

### Social Features
- Habit circles (group accountability)
- People cues ("When with X, I do Y")
- Norm messaging ("Around here, we...")

### Creator Mode
- Quantity-first tracking
- Session types (Generate vs Refine)
- Weekly rep goals
- Session learnings capture

---

## 🔮 Future Features

- [ ] Habit history calendar view
- [ ] Habit stacking (link habits)
- [ ] Weekly/monthly analytics
- [ ] Cloud backup and sync
- [ ] Push notifications for groups

---

## 🛠️ Technologies

| Technology | Purpose |
|------------|---------|
| Flutter | UI framework |
| Firebase Auth | User authentication |
| Gemini 2.5 Flash | AI conversational coach |
| Hive | Local data storage |
| Provider | State management |
| GoRouter | Navigation |

---

## 🆘 Troubleshooting

**"No Firebase App" error:**
- Make sure `google-services.json` is in `android/app/`
- Run `flutter clean` then `flutter run`

**Google Sign-In not working:**
- Check that SHA-1 fingerprint is added in Firebase Console
- Make sure Google provider is enabled in Authentication

**AI coach says "API key not configured":**
- Add your Gemini API key to `gemini_chat_service.dart`
- Get a key at https://aistudio.google.com/apikey

**App won't build:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📚 Learn More

- [Atomic Habits by James Clear](https://jamesclear.com/atomic-habits)
- [Hooked by Nir Eyal](https://www.nirandfar.com/hooked/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

Built with Flutter | Based on science-backed behavior change principles
