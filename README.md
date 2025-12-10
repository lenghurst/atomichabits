# Atomic Habits App

A Flutter mobile habit-tracking app built on the science of behavior change, implementing principles from:

- **James Clear's Atomic Habits** - Identity-based habits, 4 Laws of Behavior Change, Graceful Consistency
- **Nir Eyal's Hook Model** - Trigger, Action, Variable Reward, Investment
- **B.J. Fogg's Behavior Model** - Behavior = Motivation x Ability x Prompt

## Philosophy: Why This App Is Different

Most habit apps focus on **streaks** - fragile numbers that reset to zero when you miss a day. This creates anxiety and all-or-nothing thinking that actually undermines long-term habit formation.

This app implements **Graceful Consistency** based on James Clear's core insight:

> "Missing once is an accident. Missing twice is the start of a new habit."

Instead of punishing you for imperfection, this app:
- Tracks **"Days You Showed Up"** - a number that NEVER resets
- Celebrates **"Never Miss Twice" recoveries** - bouncing back after a miss
- Shows **rolling 4-week consistency** instead of fragile streaks
- Supports **2-minute versions** - showing up matters more than perfection
- Provides **Failure Playbooks** - pre-planned responses to obstacles

## Core Concepts

### Identity-Based Habits
"I am a person who reads daily" vs "I want to read more"

Every action is a vote for the type of person you want to become. The app constantly reinforces your chosen identity.

### The 4 Laws of Behavior Change

| Law | Implementation |
|-----|----------------|
| **Make it Obvious** | Implementation intentions, environment cues, habit stacking |
| **Make it Attractive** | Temptation bundling, pre-habit rituals |
| **Make it Easy** | 2-minute rule (tiny version), minimum viable habit |
| **Make it Satisfying** | Graceful consistency score, visual progress, celebration |

### The Hook Model

```
TRIGGER: Notification + Environment Cue + Habit Stacking
    |
    v
ACTION: One-tap completion (Make it Easy)
    |
    v
VARIABLE REWARD: Consistency score, insights, never-miss-twice wins
    |
    v
INVESTMENT: Days showed up (never resets), weekly review, identity reinforcement
```

## Features

### Tier 1: Essential (Implemented)

- **Identity-Based Onboarding** - Define who you want to become
- **2-Minute Rule** - Every habit has a tiny version
- **Implementation Intentions** - "I will [BEHAVIOR] at [TIME] in [LOCATION]"
- **Graceful Consistency Metrics** - Days showed up, rolling 4-week average
- **Never Miss Twice Recovery** - Gentle prompts after missing a day
- **Calendar View** - Visual history of completions
- **Push Notifications** - Contextual reminders with quick actions

### Tier 2: High Value (Implemented)

- **Multiple Habits + Focus Mode** - Track several habits, focus on one
- **Failure Playbooks** - Pre-set "If X, then Y" recovery plans
- **Zoom Out Stats** - Weekly/monthly perspective with trends
- **Weekly Review** - Sunday reflection prompts
- **Habit Stacking** - "After [ANCHOR], I will [NEW HABIT]"
- **Temptation Bundling** - Pair habits with enjoyment
- **Environment Design** - Cues to add, distractions to remove
- **Pre-Habit Rituals** - Mental preparation before habits

### Tier 3: Differentiating (Planned)

- Social accountability features
- Habit chains visualization
- Export data to CSV/JSON
- Cloud sync and backup
- Advanced analytics dashboard

## Project Structure

```
lib/
├── main.dart                         # App entry + GoRouter navigation
├── data/
│   ├── app_state.dart               # Central state (Provider) - multi-habit support
│   ├── notification_service.dart    # Push notifications with actions
│   ├── ai_suggestion_service.dart   # Context-aware habit suggestions
│   └── models/
│       ├── habit.dart               # Habit model with graceful metrics
│       └── user_profile.dart        # User identity profile
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart   # 6-step identity + habit setup
│   ├── today/
│   │   └── today_screen.dart        # Main screen - single/multi habit views
│   ├── stats/
│   │   └── stats_screen.dart        # Zoom out - weekly/monthly stats
│   └── settings/
│       └── settings_screen.dart     # App settings and info
└── widgets/
    ├── habit_selector.dart          # Multi-habit dropdown + focus mode
    ├── add_habit_dialog.dart        # Quick habit creation flow
    ├── habit_calendar.dart          # Visual completion calendar
    ├── reward_investment_dialog.dart # Post-completion celebration
    ├── pre_habit_ritual_dialog.dart  # Ritual countdown modal
    ├── never_miss_twice_dialog.dart  # Recovery prompts
    ├── weekly_review_dialog.dart     # Sunday reflection wizard
    └── suggestion_dialog.dart        # AI suggestion picker
```

## Data Model

### Habit
```dart
Habit {
  // Core
  id, name, identity, tinyVersion, createdAt

  // Implementation Intentions
  implementationTime, implementationLocation, anchorEvent

  // Make it Attractive
  temptationBundle, preHabitRitual

  // Environment Design
  environmentCue, environmentDistraction

  // Failure Playbooks
  failurePlaybooks: [{ obstacle, response }]

  // Graceful Consistency Metrics (NEVER reset)
  daysShowedUp, minimumVersionCount, neverMissTwiceWins
  completionHistory, currentStreak, lastCompletedDate

  // Computed
  gracefulConsistencyScore (0-100)
  rollingAdherencePercent (4-week)
}
```

### AppState (Multi-Habit Support)
```dart
AppState {
  // Multiple habits
  List<Habit> habits
  String? focusedHabitId  // null = show all

  // Getters
  focusedHabit, currentHabit (backward compat)
  isFocusMode, habitCount
  habitsCompletedTodayCount, allHabitsCompletedToday

  // Methods
  addHabit(), removeHabit(), updateHabit()
  setFocusedHabit(), getHabitById()
  completeHabitForToday(habitId?)
  isHabitCompletedToday(habitId?)
}
```

## Architecture

### State Management: Provider
- Central `AppState` holds all data
- `ChangeNotifier` pattern for reactive updates
- `Consumer` widgets rebuild automatically on changes

### Navigation: GoRouter
- Declarative routing with paths (`/`, `/today`, `/stats`, `/settings`)
- Redirect logic for onboarding flow

### Persistence: Hive
- Local NoSQL storage
- Automatic serialization/deserialization
- Backward-compatible data migrations

### AI Suggestions: Hybrid Architecture
- Remote LLM calls with 5-second timeout
- Local heuristic fallback (always works offline)
- Context-aware based on habit type, time, location

## How to Run

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code with Flutter extensions

### Development
```bash
# Clone repository
git clone <repository-url>
cd atomichabits

# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run on web
flutter run -d chrome
```

### Build for Production
```bash
# Android APK
flutter build apk --release

# iOS (requires Mac)
flutter build ios --release

# Web
flutter build web --release
```

## Testing the App

### User Journey Test
1. **Onboarding**: Create identity "I am a person who reads daily"
2. **Create habit**: "Read" with tiny version "Read one page"
3. **Set implementation**: Time 22:00, Location "In bed"
4. **Add stacking**: "After I brush my teeth"
5. **Environment design**: Cue "Put book on pillow", Distraction "Phone in kitchen"
6. **Add failure playbook**: "I'm too tired" -> "Read just one paragraph"
7. **Complete habit**: Tap "Mark as Complete"
8. **See reward flow**: Confetti + investment prompt
9. **Add second habit**: Use habit selector dropdown
10. **Check stats**: Tap insights icon for Zoom Out view
11. **Weekly review**: Appears on Sundays

### Edge Cases
- Missing a day triggers "Never Miss Twice" dialog
- Completing minimum version tracks separately
- Old single-habit data auto-migrates to multi-habit format
- Empty optional fields handled gracefully

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/data/app_state.dart` | Central state, multi-habit logic, persistence |
| `lib/data/models/habit.dart` | Habit data model, graceful metrics |
| `lib/features/today/today_screen.dart` | Main screen, single/multi views |
| `lib/features/onboarding/onboarding_screen.dart` | 6-step onboarding wizard |
| `lib/widgets/habit_selector.dart` | Focus mode, habit switching |
| `lib/widgets/never_miss_twice_dialog.dart` | Recovery prompts |
| `lib/widgets/weekly_review_dialog.dart` | Sunday reflection |

## Documentation

- `README.md` - This file (project overview)
- `IMPLEMENTATION_SUMMARY.md` - Detailed feature documentation
- `FEATURE_ROADMAP.md` - Feature tiers and future plans
- `AI_SUGGESTIONS_GUIDE.md` - AI system documentation
- `TESTING_GUIDE.md` - Comprehensive test scenarios

## Contributing

When adding features, ensure alignment with:
1. **Graceful Consistency** - Never punish users for missing
2. **Identity-First** - Reinforce "I am a person who..."
3. **Backward Compatibility** - Old data must still work
4. **The 4 Laws** - Make it Obvious, Attractive, Easy, Satisfying

## Technologies

- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.x** - Programming language
- **Provider** - State management
- **GoRouter** - Navigation
- **Hive** - Local persistence
- **confetti_widget** - Celebration animations
- **flutter_local_notifications** - Push notifications

## Resources

- [Atomic Habits by James Clear](https://jamesclear.com/atomic-habits)
- [Hooked by Nir Eyal](https://www.nirandfar.com/hooked/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)

---

Built with science-backed behavior change principles | Graceful Consistency > Fragile Streaks
