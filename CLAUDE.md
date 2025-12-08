# CLAUDE.md - AI Assistant Guide for Atomic Habits Hook App

## Project Overview

**Atomic Habits Hook App** is a Flutter mobile habit-tracking application based on:
- **James Clear's Atomic Habits** (identity-based habits, 4 Laws of Behavior Change, 2-minute rule)
- **Nir Eyal's Hook Model** (Trigger → Action → Variable Reward → Investment)
- **B.J. Fogg's Behavior Model** (Behavior = Motivation × Ability × Prompt)

**Tech Stack:**
- Flutter 3.35.4 / Dart 3.9.2
- Provider 6.1.5+1 (State Management)
- GoRouter 14.0.0 (Navigation)
- Hive 2.2.3 (Local Persistence)
- Material Design 3 (UI)

**Current Version:** 1.0.0+1

---

## Codebase Structure

```
lib/
├── main.dart                           # App entry point, navigation setup
├── data/
│   ├── app_state.dart                  # Central state management (Provider)
│   ├── notification_service.dart       # Local notifications + scheduling
│   ├── ai_suggestion_service.dart      # AI suggestions (remote + local fallback)
│   └── models/
│       ├── habit.dart                  # Habit data model
│       └── user_profile.dart           # User identity model
├── features/
│   ├── onboarding/
│   │   └── onboarding_screen.dart      # First-time user setup
│   ├── today/
│   │   └── today_screen.dart           # Main habit tracking screen
│   └── settings/
│       └── settings_screen.dart        # Settings & app info
└── widgets/
    ├── suggestion_dialog.dart          # AI suggestion picker UI
    ├── pre_habit_ritual_dialog.dart    # Ritual countdown modal
    └── reward_investment_dialog.dart   # Post-completion investment flow

test/
└── widget_test.dart                    # Basic widget tests

assets/
└── icons/
    └── app_icon.png                    # App icon asset

Documentation:
├── README.md                           # User-facing project overview
├── IMPLEMENTATION_SUMMARY.md           # Feature implementation history
├── IMPLEMENTATION_SUMMARY_AI.md        # AI suggestion system details
├── ASYNC_SUGGESTIONS_UPGRADE.md        # Remote LLM integration guide
├── TESTING_GUIDE.md                    # Testing guide for new features
├── QUICK_TEST_GUIDE.md                 # Quick testing reference
├── AI_SUGGESTIONS_GUIDE.md             # AI suggestion system documentation
├── GITHUB_UPLOAD_SUMMARY.md            # GitHub upload notes
└── CLAUDE.md                           # This file
```

---

## Architecture & Key Patterns

### State Management: Provider Pattern

**Central State Object:** `AppState` (`lib/data/app_state.dart`)

**Pattern:**
```dart
// App initialization (main.dart:25-30)
ChangeNotifierProvider(
  create: (context) {
    final appState = AppState();
    appState.initialize();  // Load Hive data, schedule notifications
    return appState;
  },
  child: Consumer<AppState>(...),
)
```

**Key State Properties:**
- `UserProfile? _userProfile` - User identity ("I am a person who...")
- `Habit? _currentHabit` - Single habit (multiple habits not implemented)
- `bool _hasCompletedOnboarding` - Controls initial route
- `bool _isLoading` - Loading state during initialization
- `bool _shouldShowRewardFlow` - Controls reward modal visibility

**State Modification Pattern:**
```dart
// Always notify listeners after state changes
void completeHabitForToday(String investmentNote) {
  _currentHabit = _currentHabit!.copyWith(
    currentStreak: updatedStreak,
    lastCompletedDate: today,
  );
  _saveToStorage();  // Persist to Hive
  notifyListeners(); // Trigger UI rebuild
}
```

### Navigation: GoRouter

**Routes:**
- `/` - OnboardingScreen (first-time users)
- `/today` - TodayScreen (main habit tracker)
- `/settings` - SettingsScreen (placeholder)

**Navigation Pattern:**
```dart
// Navigate to screen
context.go('/today');

// Initial route determined by onboarding status (main.dart:61)
initialLocation: appState.hasCompletedOnboarding ? '/today' : '/'
```

### Data Persistence: Hive

**Storage Keys:**
- `hasCompletedOnboarding` (bool)
- `userProfile` (Map<String, dynamic>)
- `currentHabit` (Map<String, dynamic>)

**Pattern:**
```dart
// Save to Hive
await _dataBox!.put('currentHabit', _currentHabit!.toJson());

// Load from Hive
final habitJson = _dataBox!.get('currentHabit');
if (habitJson != null) {
  _currentHabit = Habit.fromJson(Map<String, dynamic>.from(habitJson));
}
```

**Important:** Always use `Map<String, dynamic>.from()` when reading JSON from Hive to avoid type casting issues.

### AI Suggestion System

**Architecture:** Remote LLM with local heuristic fallback

**Flow:**
1. User clicks "Get ideas" button
2. Show loading indicator
3. Try remote LLM endpoint (5s timeout)
4. If remote fails/empty → fallback to local heuristics
5. Display suggestions in dialog

**Service Methods (all async):**
```dart
// In ai_suggestion_service.dart
Future<List<String>> getTemptationBundleSuggestions(Habit habit) async
Future<List<String>> getPreHabitRitualSuggestions(Habit habit) async
Future<List<String>> getEnvironmentCueSuggestions(Habit habit) async
Future<List<String>> getEnvironmentDistractionSuggestions(Habit habit) async
```

**AppState Wrapper Methods:**
```dart
// Easy UI access without passing habit data
List<String> getTemptationBundleSuggestionsForCurrentHabit()
Map<String, List<String>> getAllSuggestionsForCurrentHabit() // Combined
```

**Remote Endpoint Configuration:**
```dart
// lib/data/ai_suggestion_service.dart:18
static const String _remoteLlmEndpoint = 'https://example.com/api/habit-suggestions';
static const Duration _remoteTimeout = Duration(seconds: 5);
```

### Notification System

**Service:** `NotificationService` (`lib/data/notification_service.dart`)

**Scheduled Notifications:**
- Daily reminder at implementation time
- Notification body includes temptation bundle when present
- Action buttons: "Complete" / "Later"

**Pattern:**
```dart
// Schedule notifications (called after onboarding)
await _notificationService.scheduleHabitReminder(
  habit: currentHabit,
  identity: userProfile.identity,
);

// Handle notification actions
_notificationService.onNotificationAction = (action, habitId) {
  if (action == 'complete') {
    // Mark habit as complete
  }
};
```

---

## Data Models

### Habit Model (`lib/data/models/habit.dart`)

**Core Fields:**
- `String id` - Unique identifier
- `String name` - Habit name ("Read one page")
- `String tinyVersion` - 2-minute rule version ("Open my book")
- `String? implementationTime` - Time of day ("21:00")
- `String? implementationLocation` - Location ("Living room")
- `int currentStreak` - Consecutive days completed
- `DateTime? lastCompletedDate` - Last completion timestamp

**Optional Enhancement Fields (v1.1):**
- `String? temptationBundle` - Enjoyable pairing ("Have tea while reading")
- `String? preHabitRitual` - Mental preparation ("Take 3 deep breaths")
- `String? environmentCue` - Visual trigger ("Put book on pillow at 21:45")
- `String? environmentDistraction` - Removal cue ("Charge phone in kitchen")

**Investment Tracking:**
- `List<String> investmentNotes` - User reflections after completions

**Methods:**
- `copyWith({...})` - Create updated copy (immutability pattern)
- `toJson()` / `fromJson()` - Serialization for Hive persistence

**Important:** All optional fields use `as String?` in `fromJson()` for backward compatibility.

### UserProfile Model (`lib/data/models/user_profile.dart`)

**Fields:**
- `String name` - User's name
- `String identity` - Identity statement ("I am a person who reads every day")
- `DateTime createdAt` - Profile creation timestamp

---

## Development Workflows

### Adding a New Feature

1. **Identify affected layers:**
   - Data model changes? → Update `lib/data/models/`
   - State changes? → Update `lib/data/app_state.dart`
   - UI changes? → Update `lib/features/*/` screens
   - New widget? → Create in `lib/widgets/`

2. **Follow immutability pattern:**
   ```dart
   // Bad: Mutating state directly
   _currentHabit.streak++;

   // Good: Using copyWith
   _currentHabit = _currentHabit!.copyWith(
     currentStreak: _currentHabit!.currentStreak + 1,
   );
   ```

3. **Always persist state changes:**
   ```dart
   _currentHabit = updatedHabit;
   await _saveToStorage();  // Persist to Hive
   notifyListeners();       // Trigger UI rebuild
   ```

4. **Update serialization if model changes:**
   - Add new field to model
   - Update `toJson()` to include new field
   - Update `fromJson()` with null safety (`as Type?`)
   - Test backward compatibility

### Running the App

**Web (Development):**
```bash
cd /home/user/atomichabits
flutter run -d web-server --web-port 5060 --web-hostname 0.0.0.0
```

**Android APK (Release):**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Hot Reload:** Press `r` in terminal during `flutter run`
**Hot Restart:** Press `R` in terminal

### Testing

**Run all tests:**
```bash
flutter test
```

**Analyze code:**
```bash
flutter analyze
```

**Web testing limitations:**
- Notifications don't appear in browser (permission granted but not delivered)
- Use Android APK for full notification testing

**Test data reset (web):**
1. Open DevTools (F12)
2. Application > IndexedDB > Delete `habit_data` database
3. Refresh page

**Key test scenarios:** See `TESTING_GUIDE.md` for comprehensive test cases

---

## Key Conventions

### Code Style

**Imports:** Group by SDK → packages → relative
```dart
import 'package:flutter/material.dart';         // Flutter SDK
import 'package:provider/provider.dart';        // Pub packages
import '../data/app_state.dart';                // Relative imports
```

**Naming:**
- Classes: `PascalCase` (e.g., `AppState`, `TodayScreen`)
- Methods/variables: `camelCase` (e.g., `completeHabitForToday`, `currentHabit`)
- Private members: `_underscorePrefixed` (e.g., `_currentHabit`, `_saveToStorage`)
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE` for static consts

**Widget Keys:** Use `const` constructors when possible for performance
```dart
const OnboardingScreen({super.key});
```

### State Management Rules

1. **Never mutate state directly** - Always use `copyWith()` or create new instances
2. **Always call `notifyListeners()`** after state changes
3. **Always persist changes** to Hive via `_saveToStorage()`
4. **Check null safety** before accessing nullable fields

### Error Handling

**Pattern:**
```dart
try {
  await riskyOperation();
} catch (e) {
  if (kDebugMode) {
    debugPrint('Error description: $e');
  }
  // Fail gracefully - return empty/default values
  return [];
}
```

**Never crash the app** - Always provide fallback behavior

### UI Patterns

**Loading states:**
```dart
if (appState.isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

**Consumer pattern for reactive UI:**
```dart
Consumer<AppState>(
  builder: (context, appState, child) {
    final habit = appState.currentHabit;
    return Text(habit?.name ?? 'No habit');
  },
)
```

**Modal dialogs:**
```dart
await showDialog<String>(
  context: context,
  builder: (context) => SuggestionDialog(suggestions: suggestions),
);
```

---

## Common Tasks

### Adding a New Field to Habit Model

1. **Add field to class:**
   ```dart
   // lib/data/models/habit.dart
   final String? newField;
   ```

2. **Update constructor:**
   ```dart
   Habit({
     required this.id,
     // ... existing fields
     this.newField,
   });
   ```

3. **Update copyWith:**
   ```dart
   Habit copyWith({
     // ... existing fields
     String? newField,
   }) {
     return Habit(
       // ... existing fields
       newField: newField ?? this.newField,
     );
   }
   ```

4. **Update toJson:**
   ```dart
   Map<String, dynamic> toJson() {
     return {
       // ... existing fields
       'newField': newField,
     };
   }
   ```

5. **Update fromJson:**
   ```dart
   factory Habit.fromJson(Map<String, dynamic> json) {
     return Habit(
       // ... existing fields
       newField: json['newField'] as String?,
     );
   }
   ```

6. **Update UI to display/edit the field**

### Scheduling Notifications

```dart
// In app_state.dart after onboarding completion
await _notificationService.scheduleHabitReminder(
  habit: _currentHabit!,
  identity: _userProfile!.identity,
);
```

### Accessing Suggestions in UI

```dart
// Single category
final suggestions = await Provider.of<AppState>(context, listen: false)
  .getTemptationBundleSuggestionsForCurrentHabit();

// All categories (for "Get optimization tips")
final allSuggestions = await Provider.of<AppState>(context, listen: false)
  .getAllSuggestionsForCurrentHabit();
```

### Showing Reward Flow After Completion

```dart
// In app_state.dart
_shouldShowRewardFlow = true;
notifyListeners();

// In today_screen.dart (Consumer builder)
if (appState.shouldShowRewardFlow) {
  Future.microtask(() => _showRewardInvestmentFlow(context));
}
```

---

## Important Files Reference

### Critical Files (Always Read Before Modifying)

**State Management:**
- `lib/data/app_state.dart` - Central state, persistence, notifications
- `lib/data/models/habit.dart` - Core data model

**Main Screens:**
- `lib/features/onboarding/onboarding_screen.dart` - User setup flow
- `lib/features/today/today_screen.dart` - Main habit tracker

**Services:**
- `lib/data/notification_service.dart` - Local notifications
- `lib/data/ai_suggestion_service.dart` - AI suggestions (remote + local)

**Entry Point:**
- `lib/main.dart` - App initialization, routing

### Configuration Files

**Dependencies:**
- `pubspec.yaml` - Package dependencies (Provider, GoRouter, Hive, etc.)

**Linting:**
- `analysis_options.yaml` - Dart analyzer configuration (uses `flutter_lints`)

**Build Configuration:**
- `android/app/build.gradle.kts` - Android build settings
- `ios/Runner.xcodeproj/` - iOS build settings
- `web/index.html` - Web entry point

---

## Behavioral Psychology Principles

### Atomic Habits (James Clear)

**Identity-Based Habits:**
- User defines identity ("I am a person who...")
- Habit reinforces identity
- Every completion is a "vote" for that identity

**2-Minute Rule:**
- `tinyVersion` field makes habit so small it's easy to start
- Example: "Read one page" instead of "Read 30 minutes"

**4 Laws of Behavior Change:**
1. **Make it Obvious** → Implementation intention (time + location)
2. **Make it Attractive** → Temptation bundling
3. **Make it Easy** → 2-minute version
4. **Make it Satisfying** → Streak counter, confetti reward

### Hook Model (Nir Eyal)

**Trigger:**
- Daily notification at implementation time
- Visual streak counter

**Action:**
- "Mark as Complete" button (easy action)
- Pre-habit ritual (mental preparation)

**Variable Reward:**
- Confetti animation on completion
- Streak increases
- Progress visibility

**Investment:**
- Post-completion reflection question
- Investment notes stored in habit

### Fogg Behavior Model

**B = MAP (Behavior = Motivation × Ability × Prompt)**

- **Motivation:** Identity alignment, visible streak
- **Ability:** 2-minute tiny version
- **Prompt:** Daily notification, environment cues

---

## Current Limitations & Future Enhancements

### Known Limitations

- **Single habit support** - Only one habit at a time
- **No habit editing** - Must restart onboarding to change habit
- **No history view** - Can't see past completions (only streak count)
- **Web notifications** - Don't actually appear in browser
- **No habit deletion** - Must clear IndexedDB manually

### Planned Features (Not Implemented)

- [ ] Multiple habits support
- [ ] Habit editing screen
- [ ] Calendar view of completions
- [ ] Weekly/monthly analytics
- [ ] Habit stacking (link habits together)
- [ ] Backup/restore to cloud
- [ ] Real LLM integration for suggestions (currently placeholder endpoint)

---

## Git Workflow

### Branching Strategy

**Development Branch:**
```
claude/claude-md-miwrrmtea3gwmbnz-017kMduF188rzrBtiM17bC2m
```

**Important:** Always develop on this branch, not main/master.

### Commit Pattern

**Message Style:** Based on repository history
```
feat: Add new feature description
fix: Fix bug description
refactor: Code improvement description
```

**Examples from history:**
- `feat: Upgrade to async suggestion system with remote LLM + local fallback`
- `feat: Add AI suggestion system for habit optimization`
- `Add Atomic Habits app with persistence and implementation intentions`

### Pushing Changes

```bash
# Push to designated branch
git push -u origin claude/claude-md-miwrrmtea3gwmbnz-017kMduF188rzrBtiM17bC2m

# CRITICAL: Branch must start with 'claude/' and match session ID
# Otherwise push fails with 403 HTTP code

# If network errors occur, retry up to 4 times with exponential backoff (2s, 4s, 8s, 16s)
```

---

## Debugging Tips

### Common Issues

**Issue:** "Navigator operation requested with a context that does not include a Navigator"
- **Cause:** Using `context` before MaterialApp is built
- **Fix:** Wrap navigation in `Future.microtask()` or use `WidgetsBinding.instance.addPostFrameCallback`

**Issue:** "type 'X' is not a subtype of type 'Y' in type cast"
- **Cause:** Hive returns `LinkedHashMap` instead of `Map<String, dynamic>`
- **Fix:** Use `Map<String, dynamic>.from(json)` when reading from Hive

**Issue:** Habit data not persisting after app restart
- **Cause:** Forgot to call `_saveToStorage()` after state change
- **Fix:** Always call `await _saveToStorage()` after modifying habit/profile

**Issue:** UI not updating after state change
- **Cause:** Forgot to call `notifyListeners()`
- **Fix:** Always call `notifyListeners()` after state mutations

### Debug Logging

**Pattern used throughout codebase:**
```dart
if (kDebugMode) {
  debugPrint('Debug message: $variable');
}
```

**Check console logs for:**
- Hive initialization: "Loaded from storage: ..."
- Notification scheduling: "Notification scheduled for ..."
- AI suggestions: "Fetching remote suggestions..." / "Using local fallback"

### Flutter DevTools

**Access:** When running `flutter run`, open URL shown in console

**Useful tabs:**
- **Widget Inspector** - View widget tree
- **Performance** - Check for jank/frame drops
- **Logging** - See all `debugPrint` output
- **App Size** - Analyze bundle size

---

## Dependencies Explained

### Core Dependencies

**provider: 6.1.5+1**
- State management solution
- Uses `ChangeNotifier` pattern
- `Consumer` widgets auto-rebuild on state changes

**go_router: 14.0.0**
- Declarative routing
- Web URL support
- Type-safe navigation

**hive: 2.2.3 + hive_flutter: 1.1.0**
- Fast NoSQL database
- Stores JSON-serializable data
- Key-value storage pattern

**shared_preferences: 2.5.3**
- Simple key-value persistence (not actively used, Hive preferred)

**flutter_local_notifications: 18.0.1**
- Cross-platform local notifications
- Scheduled notifications
- Action buttons support

**timezone: 0.9.4**
- Required for scheduled notifications
- Converts between timezones

**confetti: 0.7.0**
- Celebration animation on habit completion
- Used in reward flow

**http: 1.5.0**
- HTTP client for remote LLM suggestions
- Used in `ai_suggestion_service.dart`

### Dev Dependencies

**flutter_lints: 5.0.0**
- Recommended Dart/Flutter lints
- Enforces best practices

---

## When Making Changes

### Checklist Before Modifying Code

1. **Read the relevant files first** - Never propose changes to code you haven't read
2. **Understand the state flow** - How does this change affect AppState?
3. **Check persistence** - Does this need to be saved to Hive?
4. **Consider backward compatibility** - Will old data still work?
5. **Update documentation** - Modify this file if architecture changes

### After Making Changes

1. **Run `flutter analyze`** - Should have 0 errors (info warnings OK)
2. **Test on web** - Verify functionality works
3. **Test data persistence** - Refresh page, check data survives
4. **Test onboarding → completion flow** - Ensure full journey works
5. **Update IMPLEMENTATION_SUMMARY.md** if adding features

### Code Review Self-Check

- [ ] No direct state mutations (use `copyWith`)
- [ ] `notifyListeners()` called after state changes
- [ ] `_saveToStorage()` called when persistence needed
- [ ] Null safety checked (`?.`, `??`, `!` used appropriately)
- [ ] Error handling with try-catch and `kDebugMode` logging
- [ ] No unnecessary imports
- [ ] Const constructors used where possible
- [ ] Loading states handled in async operations

---

## Quick Command Reference

```bash
# Development
flutter run -d web-server --web-port 5060 --web-hostname 0.0.0.0
flutter analyze
flutter test

# Build
flutter build apk --release
flutter build web

# Dependencies
flutter pub get
flutter pub upgrade
flutter pub outdated

# Clean build
flutter clean
flutter pub get
flutter run

# Git
git status
git add .
git commit -m "feat: Description"
git push -u origin claude/claude-md-miwrrmtea3gwmbnz-017kMduF188rzrBtiM17bC2m
```

---

## Additional Resources

**Documentation Files:**
- `README.md` - User-facing project overview
- `TESTING_GUIDE.md` - Comprehensive testing scenarios
- `ASYNC_SUGGESTIONS_UPGRADE.md` - Remote LLM integration details
- `AI_SUGGESTIONS_GUIDE.md` - AI suggestion system guide

**External Links:**
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter Package](https://pub.dev/packages/go_router)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Atomic Habits by James Clear](https://jamesclear.com/atomic-habits)

---

**Last Updated:** 2025-12-08
**Codebase Version:** 1.0.0+1
**Flutter Version:** 3.35.4
**Dart Version:** 3.9.2
