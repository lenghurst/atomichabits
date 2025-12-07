# Atomic Habits Hook App

A Flutter mobile habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

## Project Overview

This app helps users build real habits by focusing on identity-based behavior change. Instead of just setting goals, users define who they want to become, then create tiny habits that align with that identity.

## Project Structure

```
lib/
├── main.dart                              # App entry point with navigation setup
├── data/
│   ├── app_state.dart                     # Central state management (Provider + Hive persistence)
│   ├── notification_service.dart          # Push notification service (Android/iOS)
│   ├── ai_suggestion_service.dart         # AI suggestions (remote LLM + local fallback)
│   └── models/
│       ├── habit.dart                     # Habit data model with implementation intentions
│       └── user_profile.dart              # User profile with identity + contact info
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart         # 4-step onboarding with habit creation
│   ├── today/
│   │   └── today_screen.dart              # Today's habit view with completion flow
│   └── settings/
│       └── settings_screen.dart           # Notification settings + preferences
└── widgets/
    ├── reward_investment_dialog.dart      # Confetti celebration + reminder time picker
    ├── pre_habit_ritual_dialog.dart       # Pre-habit ritual countdown timer
    └── suggestion_dialog.dart             # AI suggestion selection UI
```

## Features Implemented

### Onboarding (Identity-Based Habit Creation)
- Collects user's name and desired identity ("I am a person who...")
- Creates first habit with 2-minute rule (tiny version)
- Implementation intentions: When (time) and Where (location)
- **Make it Attractive** options:
  - Temptation bundling (pair habit with enjoyable activity)
  - Pre-habit ritual (mental preparation before action)
- **Make it Obvious** options:
  - Environment cue (visual trigger)
  - Environment distraction removal (friction for bad habits)
- AI-powered suggestions for all fields (with "Get Ideas" buttons)
- Notification permission request at completion

### Today Screen (Hook Model Implementation)
- Personalized greeting with identity reminder
- Today's habit card with:
  - Tiny version display
  - Implementation intention (time + location)
  - Temptation bundle display (if set)
- Streak counter with fire icon
- **Pre-habit ritual flow**: Shows ritual dialog with 30-second countdown before completion
- **Reward flow** (after completion):
  - Confetti animation celebration
  - Streak count display
  - Identity reinforcement ("You've cast a vote for...")
- **Investment flow**: Time picker to set tomorrow's reminder

### Push Notifications (Make it Obvious - Law 1)
- **Android Support**:
  - Permissions: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`
  - Boot receiver for notification persistence after device restart
  - Action buttons: "Mark Done" and "Snooze 30 mins"
- **iOS Support**:
  - Background modes configured
  - Notification categories with action buttons
  - UNUserNotificationCenter delegate setup
- **Features**:
  - Dynamic timezone detection (not hardcoded UTC)
  - Daily scheduled reminders at user-chosen time
  - Snooze functionality (reschedules 30 minutes later)
  - Test notification button in Settings
  - Permission request flow with educational messaging

### Alternative Reminders (Email/SMS) - UI Ready, Backend Pending
- Email address input with validation
- Phone number input with validation
- Enable/disable toggles for each channel
- Preferences persisted locally in Hive
- "Coming Soon" badge (premium feature ready)

### AI Suggestion System
- **Architecture**: Remote LLM (5-second timeout) → Local fallback
- **Suggestion Types**:
  - Temptation bundling ideas
  - Pre-habit ritual suggestions
  - Environment cue recommendations
  - Environment distraction removal tips
- **Local Fallback**: Context-aware heuristics based on:
  - Habit type (reading, exercise, meditation, etc.)
  - Time of day (morning, afternoon, evening, night)
  - Location (bedroom, desk, kitchen, etc.)

### Settings Screen
- **Notification Settings**:
  - Enable/disable daily reminders toggle
  - Permission status with "Grant" button
  - Reminder time picker
  - Test notification button
- **Alternative Reminders**:
  - Email input and toggle
  - SMS input and toggle
- Placeholder sections for future features

### Data Persistence (Hive)
- User profile (name, identity, email, phone)
- Habit data (name, streak, completion dates, all settings)
- Onboarding completion status
- Notification preferences
- Survives app restarts and updates

## Architecture

### State Management: Provider + Hive
- **AppState** (`data/app_state.dart`): Central state with 450+ lines managing:
  - User profile and habits
  - Notification scheduling and preferences
  - Reward/investment flow state
  - AI suggestion fetching
- **Hive**: Local NoSQL database for persistence
- **Provider**: Reactive UI updates via `notifyListeners()`

### Navigation: GoRouter
- Routes: `/` (onboarding), `/today`, `/settings`
- Conditional initial route based on onboarding completion

### Data Models
- **Habit**: 12 fields including implementation intentions, temptation bundle, pre-habit ritual, environment design
- **UserProfile**: Name, identity, email, phone, reminder preferences

## Dependencies

```yaml
dependencies:
  provider: 6.1.5+1              # State management
  go_router: ^14.0.0             # Navigation
  hive: 2.2.3                    # Local database
  hive_flutter: 1.1.0            # Hive Flutter integration
  flutter_local_notifications: ^18.0.1  # Push notifications
  timezone: ^0.9.4               # Timezone support
  confetti: ^0.7.0               # Celebration animations
  http: 1.5.0                    # Remote LLM API calls
```

## How to Run

### Web Preview
```bash
flutter run -d chrome
```

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Build APK
```bash
flutter build apk --release
```

---

## Technical Implementation TODOs

### High Priority

#### 1. Remote LLM Endpoint Configuration
**File**: `lib/data/ai_suggestion_service.dart:22`

Currently uses placeholder URL. You need to:
```dart
// Replace this:
static const String _remoteLlmEndpoint = 'https://example.com/api/habit-suggestions';

// With your actual endpoint, e.g.:
static const String _remoteLlmEndpoint = 'https://your-api.com/api/habit-suggestions';
```

**Expected API Contract**:
```json
// Request (POST)
{
  "suggestion_type": "temptation_bundle|pre_habit_ritual|environment_cue|environment_distraction",
  "identity": "I am a person who reads daily",
  "habit_name": "Read every day",
  "two_minute_version": "Read one page",
  "time": "22:00",
  "location": "In bed",
  "existing_temptation_bundle": null,
  "existing_pre_ritual": null,
  "existing_environment_cue": null,
  "existing_environment_distraction": null
}

// Response (200 OK)
{
  "suggestions": [
    "Suggestion 1",
    "Suggestion 2",
    "Suggestion 3"
  ]
}
```

**Backend Options**:
- OpenAI API proxy (with your own API key)
- Claude API proxy
- Self-hosted LLM (Ollama, LMStudio)
- Firebase Cloud Function wrapping any LLM

#### 2. Email/SMS Reminder Backend
**Files**:
- `lib/data/app_state.dart:393` (setEmailRemindersEnabled)
- `lib/data/app_state.dart:408` (setSmsRemindersEnabled)

Currently marked with `// TODO: When backend is implemented...`

**Implementation Options**:

**Option A: Firebase Cloud Functions + Twilio/SendGrid**
```javascript
// Firebase Function example
exports.sendHabitReminder = functions.pubsub
  .schedule('every day 09:00')
  .onRun(async (context) => {
    const users = await admin.firestore().collection('users').get();
    for (const user of users.docs) {
      if (user.data().smsRemindersEnabled) {
        await twilioClient.messages.create({
          body: `Time for your habit: ${user.data().habitName}`,
          to: user.data().phone,
          from: TWILIO_PHONE_NUMBER
        });
      }
    }
  });
```

**Option B: AWS Lambda + SNS/SES**
- Use EventBridge for scheduling
- SNS for SMS, SES for email

**Required Changes**:
1. Add user registration endpoint (send profile to backend)
2. Store user timezone on backend
3. Create scheduled jobs per user's reminder time
4. Add authentication (Firebase Auth, Supabase, etc.)

**Cost Estimates**:
- Twilio SMS: ~$0.0075/message (US)
- SendGrid Email: Free tier up to 100/day
- Firebase Functions: Free tier covers ~2M invocations/month

### Medium Priority

#### 3. Multiple Habits Support
**Current State**: Single habit stored in `_currentHabit`
**Required Changes**:
- Change `_currentHabit` to `List<Habit> _habits`
- Update Hive storage to use list
- Create habit selection UI
- Update Today screen to show multiple habits
- Add habit creation/deletion in Settings

#### 4. Habit History & Calendar View
**Required Changes**:
- Add `List<DateTime> completionHistory` to Habit model
- Create calendar widget showing completion days
- Add history screen with streak statistics
- Implement "Don't break the chain" visualization

#### 5. Analytics Dashboard
**Suggested Metrics**:
- Completion rate (daily/weekly/monthly)
- Streak statistics (current, longest, average)
- Best day of week for completions
- Time-to-complete trends

### Low Priority

#### 6. Testing
Currently no tests. Add:
```bash
test/
├── unit/
│   ├── habit_model_test.dart
│   ├── user_profile_test.dart
│   └── ai_suggestion_service_test.dart
├── widget/
│   ├── today_screen_test.dart
│   └── onboarding_screen_test.dart
└── integration/
    └── full_flow_test.dart
```

#### 7. App Store Preparation
- [ ] Add app icon (currently default Flutter icon)
- [ ] Add splash screen
- [ ] Create screenshots for store listing
- [ ] Write privacy policy (required for notifications)
- [ ] Configure iOS capabilities in Xcode
- [ ] Test on physical devices

#### 8. Premium Features (Monetization)
- Email/SMS reminders (backend ready)
- Advanced analytics
- Multiple habits (free: 1, premium: unlimited)
- Custom themes
- Data export

---

## Key Concepts Used

### From Atomic Habits (James Clear)
- **Identity-based habits**: "I am a person who..." vs "I want to do..."
- **2-minute rule**: Make habits so small you can't say no
- **Implementation intentions**: "I will [HABIT] at [TIME] in [LOCATION]"
- **Temptation bundling**: Pair habits with things you enjoy
- **Environment design**: Make cues obvious, distractions invisible
- **Make it Satisfying**: Streak tracking + celebration

### From Hook Model (Nir Eyal)
- **Trigger**: Push notifications + visual cues
- **Action**: One-tap habit completion
- **Variable Reward**: Confetti + streak celebration
- **Investment**: Setting tomorrow's reminder time

### From Behavior Model (B.J. Fogg)
- **Motivation**: Identity reinforcement
- **Ability**: Tiny 2-minute version
- **Prompt**: Notifications + environment cues

---

## File Reference

| File | Lines | Purpose |
|------|-------|---------|
| `lib/data/app_state.dart` | ~520 | Central state, persistence, notifications |
| `lib/data/notification_service.dart` | ~400 | Push notification implementation |
| `lib/data/ai_suggestion_service.dart` | ~720 | AI suggestions with LLM + fallback |
| `lib/features/onboarding/onboarding_screen.dart` | ~800 | 4-step onboarding flow |
| `lib/features/today/today_screen.dart` | ~700 | Today view + completion flow |
| `lib/features/settings/settings_screen.dart` | ~720 | Settings + notification preferences |
| `lib/widgets/reward_investment_dialog.dart` | ~310 | Confetti celebration + time picker |
| `lib/widgets/pre_habit_ritual_dialog.dart` | ~215 | Pre-habit ritual countdown |

---

Built with Flutter | Based on science-backed behavior change principles
