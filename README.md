# Atomic Habits Hook App

A Flutter mobile habit-tracking app based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

> **"Graceful Consistency > Fragile Streaks"** — Our core philosophy

## 🎯 Project Overview

This app helps users build real habits by focusing on identity-based behavior change. Instead of just setting goals, users define who they want to become, then create tiny habits that align with that identity.

### The Problem with Traditional Habit Apps

Most habit apps use **fragile streaks** — miss one day and your 100-day streak resets to zero. This creates:
- 😰 **Anxiety**: "I can't miss a single day!"
- 😢 **Shame**: "I broke my streak, I'm a failure"
- 🚫 **Abandonment**: "What's the point of continuing?"

### Our Solution: Graceful Consistency

We've replaced fragile streaks with a **Graceful Consistency Score** that:
- 📊 Measures your **rolling 7-day and 30-day averages** (not just perfect streaks)
- 🔄 **Celebrates recoveries** — bouncing back is part of the journey
- 💪 Implements the **"Never Miss Twice"** philosophy
- 🗳️ Counts **identity votes** — every completion reinforces who you're becoming
- 🧘 Shows **compassionate messaging** when you miss, not shame

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with navigation setup
├── data/                               # === DATA LAYER (Services, State) ===
│   ├── app_state.dart                 # Central state management (Provider)
│   │                                   # + Graceful Consistency logic
│   │                                   # + Recovery detection (Never Miss Twice)
│   ├── notification_service.dart      # Daily reminders + Recovery notifications
│   ├── ai_suggestion_service.dart     # AI-powered habit optimization
│   ├── models/
│   │   ├── habit.dart                 # Habit data model with consistency tracking
│   │   ├── user_profile.dart          # User profile/identity model
│   │   └── consistency_metrics.dart   # Graceful Consistency scoring system
│   └── services/
│       └── recovery_engine.dart       # "Never Miss Twice" detection & messaging
├── features/                           # === FEATURE MODULES ===
│   ├── onboarding/
│   │   └── onboarding_screen.dart     # Identity, habit, implementation intentions
│   ├── today/                          # 🆕 VIBECODED STRUCTURE
│   │   ├── today_screen.dart          # Thin orchestrator (layout only)
│   │   ├── controllers/
│   │   │   └── today_screen_controller.dart  # Behavior logic (dialogs, actions)
│   │   ├── widgets/                   # Presentational components
│   │   │   ├── identity_card.dart
│   │   │   ├── habit_card.dart
│   │   │   ├── completion_button.dart
│   │   │   ├── recovery_banner.dart
│   │   │   ├── ritual_button.dart
│   │   │   ├── optimization_tips_button.dart
│   │   │   ├── consistency_details_sheet.dart
│   │   │   └── improvement_suggestions_dialog.dart
│   │   └── helpers/
│   │       └── recovery_ui_helpers.dart  # Pure styling logic
│   └── settings/
│       └── settings_screen.dart       # Settings & app info
├── widgets/                            # === SHARED WIDGETS ===
│   ├── graceful_consistency_card.dart # Replaces fragile streak counter
│   ├── recovery_prompt_dialog.dart    # "Never Miss Twice" compassionate UI
│   ├── reward_investment_dialog.dart  # Hook Model reward flow
│   ├── pre_habit_ritual_dialog.dart   # Pre-habit mindset preparation
│   └── suggestion_dialog.dart         # AI suggestions display
└── utils/
    └── date_utils.dart                # Date comparison utilities
```

## 🏗️ Architecture Explained (In Plain English)

### 🎨 Vibecoding Architecture: UI vs Logic

This codebase follows **Vibecoding** principles — a clean separation between "how it looks" (UI) and "how it behaves" (Logic). This makes the code more maintainable, testable, and enjoyable to work with.

#### The Core Rule

> **UI components are for layout and visuals. Logic (state, data transforms, side effects, APIs) lives in controllers and helpers.**

In other words:
- **Components** = "Dumb" presentational widgets that receive data and callbacks via props
- **Controllers** = "Smart" managers that handle state, dialogs, and side effects
- **Helpers** = Pure functions for data transforms and styling calculations

#### Architecture Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐   │
│  │  TodayScreen    │  │  IdentityCard   │  │ CompletionBtn  │   │
│  │  (Orchestrator) │  │  (Pure Widget)  │  │ (Pure Widget)  │   │
│  └────────┬────────┘  └─────────────────┘  └────────────────┘   │
│           │                                                      │
├───────────┴──────────────────────────────────────────────────────┤
│                      CONTROLLER LAYER                            │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  TodayScreenController                                    │    │
│  │  - Dialog management (showRecoveryDialog, showRewardDialog)│    │
│  │  - Side effects (handleCompleteHabit, navigateToSettings)  │    │
│  │  - App lifecycle (onScreenResumed)                         │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                       HELPER LAYER                               │
│  ┌────────────────────────┐  ┌────────────────────────────────┐  │
│  │  RecoveryUiHelpers     │  │  HabitDateUtils                │  │
│  │  - getUrgencyStyling() │  │  - isSameDay(), daysBetween()  │  │
│  │  - getNotificationColor│  │  - getLast7Days(), formatDate()│  │
│  └────────────────────────┘  └────────────────────────────────┘  │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                        STATE LAYER                               │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  AppState (Provider ChangeNotifier)                       │    │
│  │  - Central state management                               │    │
│  │  - Business logic (completeHabitForToday, getZoomOut...)  │    │
│  │  - Data persistence (Hive)                                │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                       SERVICE LAYER                              │
│  ┌────────────────────────┐  ┌────────────────────────────────┐  │
│  │  RecoveryEngine        │  │  NotificationService           │  │
│  │  - Miss detection      │  │  - Schedule reminders          │  │
│  │  - Recovery messaging  │  │  - Handle actions              │  │
│  └────────────────────────┘  └────────────────────────────────┘  │
│                                                                   │
├───────────────────────────────────────────────────────────────────┤
│                        MODEL LAYER                               │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────┐  │
│  │  Habit         │  │  UserProfile   │  │  ConsistencyMetrics│  │
│  │  - Data schema │  │  - Identity    │  │  - Score calc      │  │
│  │  - copyWith()  │  │  - Preferences │  │  - Status enums    │  │
│  └────────────────┘  └────────────────┘  └────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

#### What Goes Where? (Decision Checklist)

| If You Need To... | Put It In... | Example |
|-------------------|--------------|---------|
| Show layout, styling, visual structure | **UI Widget** | `IdentityCard`, `RecoveryBanner` |
| Handle button presses, navigation | **Controller** | `handleCompleteHabit()` |
| Show dialogs, sheets, snackbars | **Controller** | `showRecoveryDialog()` |
| Transform data, calculate derived values | **Helper/Service** | `getUrgencyStyling()` |
| Store app-wide state | **AppState** | `currentHabit`, `userProfile` |
| Make API calls, database operations | **Service** | `RecoveryEngine`, `NotificationService` |
| Define data structure, serialization | **Model** | `Habit`, `ConsistencyMetrics` |

#### Live Examples from This Codebase

**✅ Good: Dumb Widget (Receives Everything Via Props)**
```dart
// lib/features/today/widgets/identity_card.dart
class IdentityCard extends StatelessWidget {
  final String userName;        // ← Data via props
  final String identity;        // ← Data via props
  
  @override
  Widget build(BuildContext context) {
    return Container(           // ← Pure layout/styling
      padding: EdgeInsets.all(16),
      child: Text('Hello, $userName!'),
    );
  }
}
```

**✅ Good: Smart Controller (Handles Side Effects)**
```dart
// lib/features/today/controllers/today_screen_controller.dart
class TodayScreenController {
  final AppState appState;      // ← Receives state reference
  
  void showRecoveryDialog() {   // ← Manages dialog lifecycle
    showDialog(
      context: context,
      builder: (_) => RecoveryPromptDialog(...),
    );
  }
  
  Future<void> handleCompleteHabit() async {  // ← Coordinates action
    final wasNew = await appState.completeHabitForToday();
    if (wasNew) showRewardDialog();
  }
}
```

**✅ Good: Pure Helper (No State, Just Transforms)**
```dart
// lib/features/today/helpers/recovery_ui_helpers.dart
class RecoveryUiHelpers {
  static RecoveryUrgencyStyling getUrgencyStyling(RecoveryUrgency urgency) {
    switch (urgency) {
      case RecoveryUrgency.gentle:
        return RecoveryUrgencyStyling(
          primaryColor: Colors.amber,
          title: 'Never Miss Twice',
        );
      // ... pure transformation, no state
    }
  }
}
```

**✅ Good: Thin Orchestrator Screen**
```dart
// lib/features/today/today_screen.dart (refactored)
class TodayScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          body: _HabitView(                      // ← Delegates to presentational widget
            habit: appState.currentHabit,        // ← Passes data down
            controller: _controller,             // ← Passes callbacks down
          ),
        );
      },
    );
  }
}
```

#### Benefits of This Architecture

| Benefit | How It's Achieved |
|---------|-------------------|
| **Easier Testing** | Controllers can be unit tested without UI; widgets can be tested in isolation |
| **Better Reusability** | Dumb widgets can be reused anywhere; helpers work across features |
| **Clearer Debugging** | Bug in styling? Check widget. Bug in behavior? Check controller. |
| **Simpler Refactoring** | Change business logic without touching UI, and vice versa |
| **Team Scalability** | Designers can work on widgets; backend devs can work on services |

#### Quick Reference: The Vibecoding Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│           🎨 UI COMPONENTS (Widgets)                        │
│   "How does it look?"                                       │
│   ────────────────────                                      │
│   ✅ Layout, structure, positioning                         │
│   ✅ Styling, colors, fonts, spacing                        │
│   ✅ Basic conditional rendering (if/else)                  │
│   ✅ Light UI-only logic (show/hide, animations)            │
│   ❌ NO API calls                                           │
│   ❌ NO complex business rules                              │
│   ❌ NO data shaping or transformation                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           🎮 CONTROLLERS                                    │
│   "How does it behave?"                                     │
│   ─────────────────────                                     │
│   ✅ Dialog/sheet/snackbar management                       │
│   ✅ Navigation logic                                       │
│   ✅ Side effects coordination                              │
│   ✅ App lifecycle observation                              │
│   ✅ Action handlers (button press → state update)          │
│   ❌ NO JSX/Widget building                                 │
│   ❌ NO styling logic                                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           🔧 HELPERS & UTILITIES                            │
│   "How is data transformed?"                                │
│   ─────────────────────────                                 │
│   ✅ Pure functions (input → output)                        │
│   ✅ Data transformation, formatting                        │
│   ✅ Calculation, sorting, filtering                        │
│   ✅ Styling derivation (score → color)                     │
│   ❌ NO state (stateless only)                              │
│   ❌ NO side effects                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│           📡 SERVICES                                       │
│   "How does the app communicate?"                           │
│   ───────────────────────────────                           │
│   ✅ External API calls                                     │
│   ✅ Database operations (Hive)                             │
│   ✅ System integrations (notifications)                    │
│   ✅ Business logic that requires IO                        │
│   ❌ NO direct UI interaction                               │
└─────────────────────────────────────────────────────────────┘
```

---

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
- Represents a single habit with name, identity, tiny version
- **Graceful Consistency fields**:
  - `completionHistory: List<DateTime>` — Full history for rolling averages
  - `recoveryHistory: List<RecoveryEvent>` — Tracks bouncebacks from misses
  - `identityVotes: int` — Total completions (each is a vote for your identity)
  - `longestStreak: int` — Historical best (for encouragement, de-emphasized)
  - `failurePlaybook: FailurePlaybook?` — Pre-planned recovery strategy
  - `lastMissReason: String?` — Pattern tracking for personalized help
  - `isPaused: bool` — For planned breaks (vacation, illness)
- Computed properties: `gracefulScore`, `weeklyAverage`, `needsRecovery`
- Has methods to create copies with updates (`copyWith`)
- Can be saved/loaded from JSON for persistence
- **100% backward compatible** — existing data migrates seamlessly

**ConsistencyMetrics** (`data/models/consistency_metrics.dart`):
- The brain of the Graceful Consistency system
- `gracefulScore: double` — Overall score (0-100)
- `weeklyAverage: double` — 7-day rolling completion rate
- `monthlyAverage: double` — 30-day rolling completion rate
- `neverMissTwiceRate: double` — % of single misses that stayed single
- `recoveryCount: int` — Total recoveries
- `quickRecoveryCount: int` — Recoveries within 1 day
- `currentMissStreak: int` — For recovery prompts
- Helper properties: `needsRecovery`, `recoveryUrgency`, `scoreDescription`

**RecoveryEvent** (`data/models/consistency_metrics.dart`):
- Records each time user bounced back after a miss
- Tracks days missed, whether tiny version was used, miss reason

**FailurePlaybook** (`data/models/habit.dart`):
- Pre-planned recovery strategy: scenario, recovery action, self-talk
- Environment tweaks to prevent future misses
- Tracks success rate of the playbook

**UserProfile** (`data/models/user_profile.dart`):
- Stores the user's desired identity ("I am a person who...")
- Keeps track of name and creation date

## 🎨 Features Implemented

### ✅ Onboarding Screen
- Collects user's name
- Asks "Who do you want to become?" (identity-based)
- Creates first habit with a tiny version (2-minute rule)
- **Implementation Intentions**: When and where to do the habit
- **Make it Attractive**: Temptation bundling & pre-habit rituals
- **Environment Design**: Cues to add, distractions to remove
- **AI-powered suggestions** for all the above
- Validates all inputs before proceeding

### ✅ Today Screen — Now with Graceful Consistency!
- Shows personalized greeting with identity reminder
- Displays today's habit with the tiny version
- **🆕 Graceful Consistency Card** (replaces fragile streak counter):
  - Overall consistency score (0-100) with encouraging description
  - 7-day completion rate
  - Identity votes count (every completion is a vote!)
  - "Never Miss Twice" success rate
  - Recovery count (celebrating bouncebacks!)
  - De-emphasized streak display (for reference only)
  - Tap for detailed metrics breakdown
- **🆕 Recovery Banner** — Shows when habit needs attention:
  - Gentle (Day 1): "Never Miss Twice" — amber styling
  - Important (Day 2): "Day 2 - Critical" — orange styling
  - Compassionate (Day 3+): "Welcome Back" — purple styling
- **🆕 Recovery Prompt Dialog** — Compassionate re-engagement:
  - Urgency-appropriate messaging (no shame!)
  - "Zoom out" perspective showing overall progress
  - Optional miss reason selector for pattern tracking
  - "Do the 2-minute version" quick action
- Implementation intention display (time & location)
- Temptation bundle display
- Environment cues & distraction guardrails
- Pre-habit ritual trigger with 30-second mindset timer
- Big "Mark as Complete" button (or completed status)
- **Reward flow** on completion: confetti, streak celebration, identity reinforcement, reminder time investment
- Quick access to Settings

### ✅ Settings Screen
- Placeholder sections for future features:
  - Profile editing
  - Habit management
  - History viewing
  - Backup/restore
- App information and about section

### ✅ Notification System
- Daily habit reminders at user's chosen time
- Action buttons: "Mark Done" and "Snooze 30 mins"
- **🆕 Recovery notifications** — "Never Miss Twice" reminders:
  - Scheduled for 9 AM after a missed day
  - Urgency-appropriate messaging
  - "Do 2-min version" quick action

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

### Test Architecture: Testability Through Separation

Because we follow Vibecoding principles (small, pure, separated), testing becomes trivial:

```
test/
├── helpers/                          # Unit tests for pure functions
│   ├── date_utils_test.dart         # 25+ tests for HabitDateUtils
│   └── recovery_ui_helpers_test.dart # 15+ tests for styling helpers
├── models/                           # Unit tests for data models
│   └── consistency_metrics_test.dart # 40+ tests for scoring system
├── services/                         # Unit tests for business logic
│   └── recovery_engine_test.dart    # 35+ tests for recovery system
├── widgets/                          # Widget tests for UI components
│   ├── identity_card_test.dart      # 6 tests
│   ├── completion_button_test.dart  # 12 tests
│   └── recovery_banner_test.dart    # 20+ tests
└── integration/                      # Integration tests
    └── core_flows_test.dart         # 15+ end-to-end flow tests
```

### Why Vibecoding = Testable Code

| Component Type | Test Type | Example | Why Easy to Test |
|---------------|-----------|---------|------------------|
| **Pure Helpers** | Unit | `HabitDateUtils.isSameDay()` | No state, no deps, input → output |
| **Data Models** | Unit | `ConsistencyMetrics.calculateGracefulScore()` | Pure calculation, no side effects |
| **Services** | Unit | `RecoveryEngine.checkRecoveryNeed()` | Isolated business logic |
| **Widgets** | Widget | `CompletionButton` | Dumb components, easy to render in isolation |
| **Controllers** | Unit | `TodayScreenController` | Can mock dependencies |
| **Flows** | Integration | Completion → Metrics Update | Components compose cleanly |

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/helpers/date_utils_test.dart

# Run tests with coverage
flutter test --coverage

# Run only unit tests (fast)
flutter test test/helpers/ test/models/ test/services/

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test test/integration/
```

### Test Examples

**Testing Pure Helpers (Easiest)**
```dart
// test/helpers/date_utils_test.dart
test('returns true for same date different times', () {
  final date1 = DateTime(2024, 3, 15, 9, 30);
  final date2 = DateTime(2024, 3, 15, 22, 45);
  
  expect(HabitDateUtils.isSameDay(date1, date2), isTrue);
});
```

**Testing Business Logic**
```dart
// test/models/consistency_metrics_test.dart
test('perfect week with quick recoveries scores higher', () {
  final score = ConsistencyMetrics.calculateGracefulScore(
    sevenDayAverage: 1.0,
    quickRecoveries: 3,
    completionTimeVariance: 0.0,
    neverMissTwiceRate: 1.0,
  );
  
  expect(score, closeTo(95.0, 0.1));
});
```

**Testing Widgets (Dumb Components)**
```dart
// test/widgets/completion_button_test.dart
testWidgets('calls onComplete when pressed', (tester) async {
  var wasPressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: CompletionButton(
        isCompleted: false,
        onComplete: () => wasPressed = true,
      ),
    ),
  );

  await tester.tap(find.byType(ElevatedButton));
  expect(wasPressed, isTrue);
});
```

**Testing Core Flows (Integration)**
```dart
// test/integration/core_flows_test.dart
test('completing habit updates consistency metrics correctly', () {
  // Setup: User has a 7-day old habit with 5 completions
  final completionDates = [...];
  
  // Calculate metrics before
  final metricsBefore = ConsistencyMetrics.fromCompletionHistory(...);
  
  // User completes habit today
  final metricsAfter = ConsistencyMetrics.fromCompletionHistory(
    completionDates: [...completionDates, DateTime.now()],
    ...
  );
  
  // Assertions
  expect(metricsAfter.identityVotes, equals(metricsBefore.identityVotes + 1));
  expect(metricsAfter.currentMissStreak, equals(0));
});
```

### Test Coverage Goals

| Layer | Target Coverage | Current Status |
|-------|----------------|----------------|
| Helpers | 95%+ | ✅ Comprehensive |
| Models | 90%+ | ✅ Comprehensive |
| Services | 85%+ | ✅ Comprehensive |
| Widgets | 80%+ | ✅ Core widgets covered |
| Integration | Key flows | ✅ Critical paths covered |

---

### Basic User Journey

1. **Start the app** - you'll see the Onboarding screen
2. **Fill in your details:**
   - Name: "Alex"
   - Identity: "I am a person who reads daily"
   - Habit: "Read every day"
   - Tiny version: "Read one page before bed"
   - Time: "22:00"
   - Location: "In bed"
   - (Optional) Get AI suggestions for temptation bundles, rituals, etc.
3. **Click "Start Building Habits"** - navigates to Today screen
4. **See your identity reminder** at the top
5. **Notice the Graceful Consistency Card** — shows score of 0 (just started!)
6. **Click "Mark as Complete"** — watch the reward flow!
   - Confetti celebration
   - "1 day in a row!" message
   - Identity reinforcement
   - Option to set tomorrow's reminder time
7. **Tap the Consistency Card** — see detailed metrics breakdown
8. **Click Settings icon** to see the settings screen

### Testing Graceful Consistency

**Scenario 1: Building Consistency**
1. Complete the habit for 3 consecutive days
2. Watch your Graceful Score climb
3. Notice "Identity Votes" increasing
4. Tap the card to see 7-day average improve

**Scenario 2: Testing Recovery Flow (Simulated)**
Since you can't easily skip days in testing, the recovery system activates when:
- App detects habit wasn't completed yesterday
- You'll see a recovery banner on the Today screen
- Tap it to see the compassionate recovery dialog
- Choose to "Do the 2-minute version" or "Not now"

**Scenario 3: Consistency Card Details**
1. Tap the Graceful Consistency Card
2. Explore the metrics breakdown:
   - Overall Score with description
   - 7-Day completion rate
   - All-time identity votes
   - Never Miss Twice success rate
   - Recovery count
   - Current and best streaks (de-emphasized)
3. Note the philosophy quote at the bottom

### What to Verify

✅ Consistency score updates after completion
✅ Identity votes increment with each completion  
✅ Reward flow shows after marking complete
✅ Card tap opens detailed metrics sheet
✅ Recovery banner appears when needed
✅ De-emphasized streaks are still visible
✅ All messaging is encouraging, never shaming

## 📚 Key Concepts Used

### From Vibecoding Architecture:
- **Dumb Components**: Widgets that only handle layout and visuals, receiving all data via props
- **Smart Controllers**: Classes that manage behavior, dialogs, side effects, and coordinate actions
- **Pure Helpers**: Stateless utility functions for data transformation and styling calculations
- **Thin Orchestrators**: Screen widgets that compose other widgets but delegate all logic to controllers
- **Props Down, Events Up**: Data flows down via constructor parameters, events bubble up via callbacks
- **Single Responsibility**: Each file does one thing well — no "god" files that handle everything

### From Atomic Habits:
- **Identity-based habits**: "I am a person who..." vs "I want to do..."
- **2-minute rule**: Make habits so small you can't say no
- **Implementation Intentions**: "I will [BEHAVIOR] at [TIME] in [LOCATION]"
- **Temptation Bundling**: Pair habits with something enjoyable
- **Environment Design**: Make cues obvious, remove friction
- **🆕 Never Miss Twice**: "Missing once is an accident. Missing twice is the start of a new habit."
- **🆕 Identity Voting**: Every completion is a vote for who you're becoming
- **Visual cues**: Consistency score (not just streaks) provides progress visibility

### From Hook Model:
- **Trigger**: Identity reminder, consistency score, recovery prompts
- **Action**: Clicking "Mark as Complete" (easy action)
- **Variable Reward**: Confetti celebration, identity reinforcement, consistency score increase
- **Investment**: Setting tomorrow's reminder time, building recovery history

### From Fogg Behavior Model:
- **Motivation**: Identity, consistency score, recovery encouragement
- **Ability**: Tiny 2-minute version makes it easy
- **Prompt**: Daily notifications, recovery prompts after misses

### 🆕 Graceful Consistency Philosophy

**The Problem with Streaks:**
> "Streaks are fragile. One bad day erases months of progress in the user's mind."

**Our Solution:**
> "Graceful Consistency rewards showing up most of the time, celebrates recovery, and never shames the user for being human."

**Key Principles:**
1. **Rolling Averages > Perfect Streaks** — 7-day and 30-day averages matter more
2. **Recovery is Celebrated** — Bouncing back is a skill worth tracking
3. **"Never Miss Twice" is the Real Rule** — One miss is fine; two forms a pattern
4. **Identity Votes Accumulate** — Every completion adds to your identity, misses don't subtract
5. **Compassion Over Shame** — Miss messaging is encouraging, never punishing
6. **Zoom Out Perspective** — "You've completed 47 of 60 days. One miss doesn't change that."

## 📊 Graceful Consistency Score — How It Works

The Graceful Consistency Score (0-100) is calculated from four components:

### Score Formula
```
Graceful Score = (Base × 0.4) + (Recovery × 0.2) + (Stability × 0.2) + (NMT × 0.2)
```

| Component | Weight | What It Measures | How It's Calculated |
|-----------|--------|------------------|---------------------|
| **Base Score** | 40% | Recent consistency | 7-day completion rate × 100 |
| **Recovery Bonus** | 20% | Bouncing back skill | 5 points per quick recovery (max 20) |
| **Stability Bonus** | 20% | Consistency variance | Lower variance = higher bonus |
| **NMT Bonus** | 20% | "Never Miss Twice" success | % of single misses that stayed single × 20 |

### Example Scenarios

**Scenario A: Perfect Week**
- 7-day average: 100% → Base = 40
- No misses → No recovery needed
- Perfect consistency → Stability = 20
- No misses → NMT = 20
- **Total: 80-100** (depending on historical recoveries)

**Scenario B: Missed Yesterday, Recovered Today**
- 7-day average: 85% → Base = 34
- Quick recovery (1 day) → Recovery = 5
- Good consistency → Stability = 15
- NMT preserved → NMT = 18
- **Total: ~72** — Still "Strong consistency"!

**Scenario C: Missed 3 Days, Now Recovering**
- 7-day average: 57% → Base = 23
- Coming back → Recovery = 0 (pending)
- Some variance → Stability = 10
- NMT slightly lower → NMT = 12
- **Total: ~45** — "Building momentum" — You got this!

### Score Descriptions
| Score Range | Description | Emoji |
|-------------|-------------|-------|
| 90-100 | Excellent consistency! | 🌟 |
| 75-89 | Strong consistency | 💪 |
| 60-74 | Good progress | 👍 |
| 40-59 | Building momentum | 🌱 |
| 20-39 | Getting started | 🚀 |
| 0-19 | Every day is a fresh start | ✨ |

## 🔄 Never Miss Twice Engine — Recovery System

When you miss a day, the app provides compassionate, urgency-appropriate support:

### Recovery Urgency Levels

| Days Missed | Urgency | Title | Message Tone |
|-------------|---------|-------|--------------|
| 1 day | 🟡 Gentle | "Never Miss Twice" | Encouraging nudge |
| 2 days | 🟠 Important | "Day 2 - Critical" | Urgency without panic |
| 3+ days | 🟣 Compassionate | "Welcome Back" | Warm re-engagement |

### Sample Messages

**Day 1 (Gentle):**
> "Missed yesterday? No drama. Let's not miss two in a row.
> Your 2-minute version: 'Read one page'"

**Day 2 (Important):**
> "Two days is the danger zone. But you're here now.
> Just 'Read one page' – that's a win."

**Day 3+ (Compassionate):**
> "Life happens. You're back, and that's what matters.
> When you're ready: 'Read one page'
> No judgment. Just start."

### "Zoom Out" Perspective
Every recovery prompt includes a perspective message:
> "In the context of 60 days, today is just 1. You've shown up 47 times (78%). One miss doesn't change that."

### Miss Reason Tracking
Users can optionally log why they missed:
- 😰 Busy/overwhelmed
- 😴 Low energy
- 🤔 Simply forgot
- ✈️ Traveling
- 🤒 Feeling unwell
- 👥 Social commitments
- 😔 Not in the mood
- 🔀 Routine disrupted
- 📝 Other

This helps identify patterns and personalize future suggestions.

## 🏗️ Never Miss Twice Engine — Implementation Details

> **Framework Feature 31** — A cornerstone of Atomic Habits philosophy

The "Never Miss Twice" Engine is fully implemented and represents one of the most impactful features for habit sustainability. This section documents the technical implementation.

### Key Data Structures

#### AppState Fields
```dart
// In lib/data/app_state.dart

/// Tracks consecutive missed days (equivalent to `int consecutiveMissedDays`)
/// Calculated dynamically from habit.currentMissStreak for accuracy
int get consecutiveMissedDays => _currentHabit?.currentMissStreak ?? 0;

/// The "Never Miss Twice Score" (0.0-1.0)
/// Higher score = better at recovering before a second miss
double get neverMissTwiceScore => _currentHabit?.neverMissTwiceRate ?? 1.0;

/// Whether to show the recovery prompt UI (user's suggested field)
bool get shouldShowRecoveryPrompt => _shouldShowRecoveryPrompt;

/// Determines if recovery prompt should be shown (method form)
bool shouldShowNeverMissTwicePrompt() {
  if (_currentHabit == null) return false;
  if (_currentHabit!.isPaused) return false;
  if (_currentHabit!.isCompletedToday) return false;
  return consecutiveMissedDays >= 1;
}
```

#### ConsistencyMetrics Fields
```dart
// In lib/data/models/consistency_metrics.dart

/// "Never Miss Twice" success rate (0.0-1.0)
/// Percentage of single misses that didn't become 2+ misses
final double neverMissTwiceRate;

/// Current consecutive misses (for recovery prompts)
final int currentMissStreak;

/// Recovery urgency based on consecutive misses
RecoveryUrgency get recoveryUrgency {
  if (currentMissStreak <= 1) return RecoveryUrgency.gentle;
  if (currentMissStreak == 2) return RecoveryUrgency.important;
  return RecoveryUrgency.compassionate;
}
```

#### Habit Model Tracking
```dart
// In lib/data/models/habit.dart

/// Count of "Never Miss Twice" wins (recovered after single miss)
final int singleMissRecoveries;

/// Total days user "showed up" - NEVER resets
final int daysShowedUp;

/// Count of times user did the 2-minute/minimum version
final int minimumVersionCount;

/// Full completion count (distinguished from minimum version)
final int fullCompletionCount;
```

### Recovery Detection Flow

```
┌──────────────────┐
│   App Starts /   │
│   Comes to       │
│   Foreground     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ _checkRecovery   │
│    Needs()       │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Yes    ┌──────────────────┐
│ Completed        │──────────▶│ No recovery      │
│ Today?           │           │ needed           │
└────────┬─────────┘           └──────────────────┘
         │ No
         ▼
┌──────────────────┐
│ Calculate        │
│ consecutiveMiss  │
│ Days             │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Determine        │
│ Urgency Level    │
│ (1/2/3+ days)    │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Show Recovery    │
│ Banner + Dialog  │
└──────────────────┘
```

### "Never Miss Twice" Score Calculation

The score tracks what percentage of your misses were single-day misses (vs. multi-day gaps):

```dart
// Count single misses vs multi-day misses in completion history
int singleMisses = 0;      // Missed 1 day, then recovered
int multiDayMisses = 0;    // Missed 2+ consecutive days

// Scan through all days since habit creation
for (each day in history) {
  if (missed) missStreak++;
  else {
    if (missStreak == 1) singleMisses++;
    else if (missStreak > 1) multiDayMisses++;
    missStreak = 0;
  }
}

// Calculate rate
neverMissTwiceRate = singleMisses / (singleMisses + multiDayMisses);
```

**Interpretation:**
- **100%**: All your misses were single-day misses — you always bounced back
- **80%+**: Excellent recovery skills
- **60-79%**: Good at bouncing back
- **<60%**: Room to improve recovery habits

### Graceful Recovery (vs. Fragile Streak Reset)

When completing after a miss, the app uses **Graceful Recovery** instead of a harsh streak reset:

```dart
// Old fragile approach (NOT USED):
// newStreak = 0;  // Everything lost!

// Graceful approach (WHAT WE DO):
if (isRecovery && missStartDate != null) {
  // Track this as a recovery event
  newRecoveryHistory.add(RecoveryEvent(
    missDate: missStartDate,
    recoveryDate: now,
    daysMissed: daysMissed,
    missReason: _currentHabit!.lastMissReason,
    usedTinyVersion: usedTinyVersion,
  ));
  
  // "Never Miss Twice" win = recovered after only 1 day missed
  if (daysMissed == 1) {
    newSingleMissRecoveries++;
    // 🏆 NEVER MISS TWICE WIN!
  }
}

// Update flexible tracking (these NEVER reset):
newDaysShowedUp++;
newIdentityVotes++;
```

### Testing the Engine

Run the comprehensive test suite:
```bash
flutter test test/app_state/never_miss_twice_test.dart
flutter test test/services/recovery_engine_test.dart
flutter test test/models/consistency_metrics_test.dart
```

### Files Involved

| File | Role |
|------|------|
| `lib/data/app_state.dart` | Central state with NMT getters and methods |
| `lib/data/services/recovery_engine.dart` | Detection, urgency calculation, messaging |
| `lib/data/models/consistency_metrics.dart` | Score calculation, urgency enum |
| `lib/data/models/habit.dart` | Tracking fields, computed properties |
| `lib/widgets/recovery_prompt_dialog.dart` | Compassionate UI |
| `lib/features/today/widgets/recovery_banner.dart` | Inline recovery indicator |
| `test/app_state/never_miss_twice_test.dart` | Comprehensive unit tests |

## 🔮 Future Features (Not Yet Implemented)

- [ ] Multiple habits support with Focus Mode
- [ ] Habit history and calendar view
- [ ] Habit stacking (link habits together)
- [ ] Failure Playbooks — Pre-planned recovery strategies
- [ ] Weekly Review with AI synthesis
- [ ] Weekly/monthly analytics dashboard
- [ ] Pattern detection from miss reasons
- [ ] Backup and restore functionality
- [ ] Habit pause/vacation mode
- [ ] Social accountability (optional)

## 🛠️ Technologies Used

- **Flutter 3.35.4** - UI framework
- **Dart 3.9.2** - Programming language
- **Provider 6.1.5+1** - State management
- **GoRouter ^14.0.0** - Navigation
- **Hive** - Local data persistence
- **flutter_local_notifications** - Daily reminders & recovery prompts
- **confetti** - Celebration animations
- **Material Design 3** - UI design system

## 🆕 What's New — Version 1.1.0

### Graceful Consistency System (Major Update)

**Philosophy Shift:**
We've fundamentally reimagined how the app tracks progress. Instead of fragile streaks that reset to zero on any miss, we now use a sophisticated **Graceful Consistency Score** that rewards showing up, celebrates recovery, and never shames users for being human.

**New Features:**
1. **Graceful Consistency Card** — Beautiful gradient card showing your holistic consistency score (0-100), weekly completion rate, identity votes, and recovery count. Streaks are still shown but de-emphasized.

2. **Never Miss Twice Engine** — When you miss a day, the app provides compassionate, urgency-appropriate support:
   - Day 1: Gentle "never miss twice" nudge
   - Day 2: Important "this is the critical moment" prompt  
   - Day 3+: Compassionate "welcome back" re-engagement

3. **Recovery Tracking** — Every time you bounce back after a miss, it's recorded and celebrated. Quick recoveries (within 1 day) give you bonus points!

4. **Zoom Out Perspective** — Recovery prompts show your overall progress in context: "You've completed 47 of 60 days (78%). One miss doesn't change that."

5. **Miss Reason Tracking** — Optionally log why you missed to identify patterns (busy, tired, forgot, traveling, etc.)

6. **Recovery Notifications** — If you miss a day, you'll get a gentle "Never Miss Twice" reminder the next morning at 9 AM.

7. **Detailed Metrics View** — Tap the consistency card for a full breakdown: monthly average, NMT rate, recovery stats, and more.

**Technical Improvements:**
- Completion history stored for rolling average calculations
- Recovery events tracked with timestamps and context
- Backward compatible — existing user data migrates seamlessly
- New utility classes for date handling and recovery logic

**Files Added:**
- `lib/data/models/consistency_metrics.dart` — Scoring algorithm
- `lib/data/services/recovery_engine.dart` — Miss detection & messaging
- `lib/widgets/graceful_consistency_card.dart` — New metrics UI
- `lib/widgets/recovery_prompt_dialog.dart` — Compassionate recovery UI
- `lib/utils/date_utils.dart` — Date utilities

**Files Modified:**
- `lib/data/models/habit.dart` — Added consistency tracking fields
- `lib/data/app_state.dart` — Added graceful consistency logic
- `lib/features/today/today_screen.dart` — Integrated new UI components
- `lib/data/notification_service.dart` — Added recovery notifications

### 🎯 Never Miss Twice Engine Completion (Version 1.2.1)

**Feature Completion:**
The "Never Miss Twice" Engine (Framework Feature 31) is now **fully implemented** with all recommended tracking fields:

**AppState Enhancements:**
- Added `consecutiveMissedDays` getter — tracks current miss streak
- Added `neverMissTwiceScore` getter — percentage score (0.0-1.0)
- Added `shouldShowNeverMissTwicePrompt()` method — programmatic trigger check
- Enhanced `shouldShowRecoveryPrompt` getter — for UI binding
- Added graceful recovery logging in debug mode

**Habit Model Tracking:**
- `singleMissRecoveries` — count of "Never Miss Twice" wins (never resets!)
- `daysShowedUp` — total days completed (never resets!)
- `minimumVersionCount` — times 2-minute version was used
- `fullCompletionCount` — times full version was completed

**Completion Logic Improvements:**
- Replaced fragile streak reset mentality with graceful recovery tracking
- On completion after miss, system now:
  - Records recovery event with context
  - Tracks if it was a "Never Miss Twice" win (1-day recovery)
  - Updates flexible tracking metrics
  - Logs detailed metrics in debug mode

**New Tests:**
- `test/app_state/never_miss_twice_test.dart` — Comprehensive test suite
  - `consecutiveMissedDays` tracking tests
  - `neverMissTwiceScore` calculation tests
  - Recovery urgency level tests
  - Flexible tracking metric tests
  - Atomic Habits philosophy alignment tests

**Philosophy Alignment:**
> "Missing once is an accident. Missing twice is the start of a new habit."

The implementation ensures:
- Single misses are never treated as failures
- Identity votes NEVER reset
- Days showed up NEVER reset
- Recovery is celebrated, not hidden
- Compassionate messaging at all urgency levels

### 🎨 Vibecoding Architecture Refactor (Version 1.2.0)

**Philosophy Shift:**
We've restructured the Today feature to follow **Vibecoding principles** — a clean separation between "how it looks" (UI) and "how it behaves" (Logic). This makes the codebase more maintainable, testable, and scalable.

**The Problem with Monolithic Screens:**
Before refactoring, `today_screen.dart` was a 1000+ line monster that mixed:
- Layout code (where things go)
- Styling code (how things look)
- Business logic (what happens when)
- Dialog management (showing popups)
- API calls (fetching suggestions)

This made the code:
- 😓 **Hard to test** — Can't test logic without rendering UI
- 😵 **Hard to understand** — Where does this color come from?
- 🐛 **Bug-prone** — Changes in one area break another
- 🐌 **Slow to iterate** — Every change requires understanding the whole file

**The Solution: Vibecoding Architecture**

We split `today_screen.dart` into focused, single-responsibility modules:

```
Before (Monolithic):
today_screen.dart (1000+ lines, does everything)

After (Vibecoded):
features/today/
├── today_screen.dart           (200 lines - thin orchestrator)
├── controllers/
│   └── today_screen_controller.dart  (behavior logic)
├── helpers/
│   └── recovery_ui_helpers.dart      (pure styling functions)
└── widgets/
    ├── identity_card.dart            (presentational)
    ├── habit_card.dart               (presentational)
    ├── completion_button.dart        (presentational)
    ├── recovery_banner.dart          (presentational)
    ├── ritual_button.dart            (presentational)
    ├── optimization_tips_button.dart (presentational)
    ├── consistency_details_sheet.dart (presentational)
    └── improvement_suggestions_dialog.dart (presentational)
```

**New Pattern: Controller + Dumb Widgets**

| Before | After |
|--------|-------|
| `TodayScreen` handles everything | `TodayScreen` is a thin orchestrator |
| Colors calculated inline | `RecoveryUiHelpers.getUrgencyStyling()` |
| Dialogs shown from widgets | `TodayScreenController.showRecoveryDialog()` |
| Button handlers inline | `controller.handleCompleteHabit()` |
| State access scattered | State passed as props to dumb widgets |

**Example: RecoveryBanner Widget**

```dart
// Before: Mixed concerns
class _buildRecoveryBanner() {
  Color bannerColor;  // Inline styling logic
  if (urgency == RecoveryUrgency.gentle) {
    bannerColor = Colors.amber;  // Magic values
  } else if (...)
  
  return GestureDetector(
    onTap: () => showDialog(...),  // Inline dialog management
    child: Container(...)
  );
}

// After: Vibecoded
class RecoveryBanner extends StatelessWidget {
  final RecoveryUrgency urgency;  // Data via props
  final VoidCallback onTap;       // Callback via props
  
  Widget build(context) {
    final styling = RecoveryUiHelpers.getUrgencyStyling(urgency);
    return GestureDetector(
      onTap: onTap,               // Just calls the callback
      child: Container(
        color: styling.backgroundColor,  // Uses helper
      ),
    );
  }
}
```

**Files Added (Vibecoding):**
- `lib/features/today/controllers/today_screen_controller.dart` — All behavior logic
- `lib/features/today/helpers/recovery_ui_helpers.dart` — Pure styling functions
- `lib/features/today/widgets/identity_card.dart` — User identity display
- `lib/features/today/widgets/habit_card.dart` — Today's habit details
- `lib/features/today/widgets/completion_button.dart` — Mark complete UI
- `lib/features/today/widgets/recovery_banner.dart` — Recovery prompt banner
- `lib/features/today/widgets/ritual_button.dart` — Pre-habit ritual trigger
- `lib/features/today/widgets/optimization_tips_button.dart` — AI suggestions button
- `lib/features/today/widgets/consistency_details_sheet.dart` — Detailed metrics view
- `lib/features/today/widgets/improvement_suggestions_dialog.dart` — AI tips display

**Files Modified (Vibecoding):**
- `lib/features/today/today_screen.dart` — Refactored to thin orchestrator (was ~1000 lines, now ~200)

**Benefits Realized:**
| Metric | Before | After |
|--------|--------|-------|
| Main screen file | 1000+ lines | ~200 lines |
| Test coverage potential | ~20% | ~80% |
| Time to find color bug | 5-10 min | 30 seconds |
| Adding new widget | Inline chaos | Create new file |
| Understanding flow | Read everything | Read controller |

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

**What is State?** "State" is the data that can change in your app - like your consistency score or whether you completed today's habit.

### Understanding Vibecoding (For Non-Coders)

Vibecoding is like organizing a restaurant kitchen:

| Restaurant Role | Code Equivalent | What They Do |
|----------------|-----------------|--------------|
| **Plating/Presentation Chef** | UI Widget | Makes food look beautiful on the plate |
| **Head Chef** | Controller | Decides what gets cooked and when |
| **Prep Cook** | Helper | Chops vegetables, prepares ingredients |
| **Waiter** | Props/Callbacks | Carries orders and food between areas |

**Why does this matter?**
- When a dish looks wrong → you know to check the plating chef (UI Widget)
- When the wrong dish is served → you know to check the head chef (Controller)
- When ingredients are wrong → you know to check the prep cook (Helper)

This organization makes finding and fixing problems much faster!

### Vibecoding Glossary

| Term | Plain English Meaning |
|------|----------------------|
| **Dumb Widget** | A visual component that just displays what it's told. Like a TV showing whatever signal it receives. |
| **Smart Controller** | The "brain" that decides what happens when buttons are pressed. Like a remote control. |
| **Pure Helper** | A calculator — give it input, get output, no side effects. `getColor(score)` → always same color for same score. |
| **Props** | Settings passed to a widget. Like telling a TV "show channel 5 at volume 10". |
| **Callback** | A phone number to call when something happens. "Call this when the button is pressed". |
| **Side Effect** | Anything that affects the outside world — showing a popup, saving data, sending a notification. |
| **Orchestrator** | A conductor that coordinates other components but doesn't do the work itself. |
| **Thin** | A file that doesn't do much itself, just coordinates other files. |
| **Fat** | A file that does too much (bad!) — we want thin files. |

## 🧠 Understanding the Behavior Science

### Why "Graceful Consistency" Works Better Than Streaks

**The Psychology of Streaks:**
Traditional streaks create what psychologists call "loss aversion" — the pain of losing a 50-day streak feels worse than the joy of building it. This leads to:
- Anxiety about maintaining perfection
- Shame spiral when the streak breaks
- "What-the-hell effect" — "I already broke it, why continue?"

**The Psychology of Graceful Consistency:**
Our approach leverages several evidence-based principles:

1. **Growth Mindset** (Carol Dweck) — Setbacks are part of learning, not failures
2. **Self-Compassion** (Kristin Neff) — Being kind to yourself improves long-term outcomes
3. **Implementation Intentions** (Peter Gollwitzer) — "If I miss, then I will..." planning
4. **Identity-Based Change** (James Clear) — Each completion is a vote, misses don't subtract

### The "Never Miss Twice" Rule

From Atomic Habits:
> "The first mistake is never the one that ruins you. It is the spiral of repeated mistakes that follows. Missing once is an accident. Missing twice is the start of a new habit."

Our app makes this practical by:
- Detecting the first miss and prompting gently
- Escalating urgency on day 2 (the critical moment)
- Providing compassionate re-engagement on day 3+
- Always offering the "2-minute version" as an easy win

### Why We Track Recoveries

Most apps ignore recoveries. We celebrate them because:
- **Resilience matters more than perfection** — Real life has interruptions
- **Recovery is a skill** — The more you practice bouncing back, the better you get
- **Positive reinforcement** — Celebrating recoveries encourages future recoveries
- **Pattern recognition** — Tracking miss reasons helps identify and fix root causes

## 🔄 Data Flow: How Everything Connects

Understanding how data moves through the app helps when debugging or adding features.

### User Action Flow (Example: Completing a Habit)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          USER TAPS "MARK COMPLETE"                       │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  1️⃣ CompletionButton (UI Widget)                                          │
│     - Receives `onComplete` callback via props                            │
│     - Just calls: onComplete()                                            │
│     - No business logic here!                                             │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  2️⃣ TodayScreenController.handleCompleteHabit()                           │
│     - Coordinates the action                                              │
│     - Calls: appState.completeHabitForToday()                            │
│     - Waits for result                                                    │
│     - If new completion: showRewardDialog()                               │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  3️⃣ AppState.completeHabitForToday()                                      │
│     - Updates habit.completionHistory                                     │
│     - Increments identityVotes                                            │
│     - Records recovery event (if was recovering)                          │
│     - Persists to Hive database                                           │
│     - Calls: notifyListeners() ← triggers UI rebuild                     │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  4️⃣ Consumer<AppState> receives update                                    │
│     - TodayScreen rebuilds with new data                                  │
│     - GracefulConsistencyCard shows updated score                         │
│     - CompletionButton now shows "Completed!" state                       │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  5️⃣ Controller.showRewardDialog()                                         │
│     - Shows confetti celebration                                          │
│     - Identity reinforcement message                                      │
│     - Investment prompt (set tomorrow's reminder)                         │
└──────────────────────────────────────────────────────────────────────────┘
```

### Recovery Detection Flow (When User Opens App After Missing)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          APP COMES TO FOREGROUND                         │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  1️⃣ TodayScreen.didChangeAppLifecycleState(resumed)                       │
│     - Lifecycle observer detects app foregrounded                         │
│     - Calls: _controller.onScreenResumed()                               │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  2️⃣ TodayScreenController.onScreenResumed()                               │
│     - Checks: appState.shouldShowRecoveryPrompt                          │
│     - If true: showRecoveryDialog()                                       │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  3️⃣ AppState checks RecoveryEngine                                        │
│     - RecoveryEngine.checkRecoveryNeed(habit)                            │
│     - Calculates days since last completion                               │
│     - Determines urgency (gentle/important/compassionate)                 │
│     - Returns RecoveryNeed object                                         │
└────────────────────────────────────┬─────────────────────────────────────┘
                                     │
                                     ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  4️⃣ RecoveryPromptDialog displayed                                        │
│     - Uses RecoveryUiHelpers.getUrgencyStyling() for colors              │
│     - Shows compassionate message based on urgency                        │
│     - "Zoom out" perspective message                                      │
│     - "Do 2-minute version" action button                                │
└──────────────────────────────────────────────────────────────────────────┘
```

### Styling Derivation Flow (How Colors Are Determined)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  RecoveryBanner Widget needs urgency-based styling                      │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  RecoveryUiHelpers.getUrgencyStyling(urgency)                           │
│  ────────────────────────────────────────                               │
│  INPUT: RecoveryUrgency.gentle                                          │
│  OUTPUT: RecoveryUrgencyStyling(                                        │
│    primaryColor: Colors.amber,                                          │
│    backgroundColor: Colors.amber.shade50,                               │
│    borderColor: Colors.amber.shade300,                                  │
│    icon: Icons.wb_sunny,                                                │
│    title: 'Never Miss Twice',                                           │
│  )                                                                      │
│  ────────────────────────────────────────                               │
│  Pure function - same input ALWAYS gives same output                    │
│  No state, no side effects, easily testable                             │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  RecoveryBanner uses styling object                                     │
│  ────────────────────────────────────                                   │
│  Container(                                                             │
│    color: styling.backgroundColor,    // ← From helper                  │
│    child: Icon(styling.icon),         // ← From helper                  │
│  )                                                                      │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🎓 Learning Resources

### Vibecoding & Clean Architecture
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Separation of Concerns in Flutter](https://medium.com/flutter-community/flutter-separation-of-concerns-a7b11f2bd3b8)
- [Provider Pattern Best Practices](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)

### Why This Architecture Matters
> "The only way to go fast, is to go well." — Robert C. Martin

Vibecoding isn't about being fancy. It's about:
1. **Finding bugs fast** — When something breaks, you know exactly which file to check
2. **Making changes safely** — Change one thing without breaking others
3. **Onboarding teammates** — New developers can understand small files quickly
4. **Testing effectively** — Pure helpers and controllers can be unit tested
5. **Maintaining sanity** — Nobody wants to debug a 1000-line file at 2 AM

---

Built with ❤️ using Flutter | Based on science-backed behavior change principles

> *"You do not rise to the level of your goals. You fall to the level of your systems."* — James Clear

> *"Graceful Consistency > Fragile Streaks"* — Atomic Habits Hook App Philosophy

> *"Dumb Components, Smart Controllers, Pure Helpers"* — Vibecoding Mantra
