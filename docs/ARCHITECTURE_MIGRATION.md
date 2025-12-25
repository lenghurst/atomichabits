# Architecture Migration Guide: AppState → Domain Providers

## Overview

This document outlines the migration from the monolithic `AppState` to the new domain-specific provider architecture. This refactoring was designed by a 5-expert panel to address:

1. **Atlas (Architect)**: Fragile manual provider linking → ProxyProvider
2. **Flux (State Specialist)**: Monolithic state → Domain-specific providers
3. **Uncle Bob (Clean Coder)**: Hive coupling → Repository Pattern
4. **Domaina (Domain Modeler)**: Anemic models → Rich domain entities
5. **Speedy (Performance)**: Sequential init → Parallel initialization

## New Architecture

```
lib/
├── data/
│   ├── repositories/           # NEW: Infrastructure layer
│   │   ├── settings_repository.dart      (Interface)
│   │   ├── hive_settings_repository.dart (Implementation)
│   │   ├── user_repository.dart
│   │   ├── hive_user_repository.dart
│   │   ├── habit_repository.dart
│   │   ├── hive_habit_repository.dart
│   │   ├── psychometric_repository.dart
│   │   └── hive_psychometric_repository.dart
│   │
│   ├── providers/              # NEW: State management layer
│   │   ├── settings_provider.dart
│   │   ├── user_provider.dart
│   │   ├── habit_provider.dart
│   │   └── psychometric_provider.dart
│   │
│   └── app_state.dart          # LEGACY: Will be deprecated
│
├── domain/
│   ├── entities/               # NEW: Pure domain models
│   │   └── psychometric_profile.dart
│   │
│   └── services/               # NEW: Domain logic
│       └── psychometric_engine.dart
```

## Migration Strategy: The Strangler Pattern

Rather than a big-bang replacement, we use the "Strangler Fig" pattern:

1. **Phase 1** ✅ COMPLETE: Create new providers alongside AppState
2. **Phase 2** ✅ COMPLETE (Shadow Wiring): Providers initialised in main.dart but not consumed
3. **Phase 3** (Post-NYE): Wire providers with ProxyProvider, migrate screens
4. **Phase 4** (Q1 2026): Deprecate AppState entirely

> **Current Status (Phase 34.4):** New providers are shadow-wired in main.dart. UI still consumes AppState. Oliver Backdoor is in AppState.isPremium (not UserProvider) because UI reads from AppState.

## Phase 2: Updated main.dart

Replace the current initialization with parallel repository initialization:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupGlobalErrorHandling();
  await Hive.initFlutter();
  
  // === PHASE 1: Initialize Infrastructure (Repositories) ===
  final settingsRepo = HiveSettingsRepository();
  final userRepo = HiveUserRepository();
  final habitRepo = HiveHabitRepository();
  final psychometricRepo = HivePsychometricRepository();
  
  // Parallel initialization (Speedy's recommendation)
  await Future.wait([
    settingsRepo.init(),
    userRepo.init(),
    habitRepo.init(),
    psychometricRepo.init(),
  ]);

  // === PHASE 2: Initialize Providers with Repositories ===
  final settingsProvider = SettingsProvider(settingsRepo);
  final userProvider = UserProvider(userRepo);
  final habitProvider = HabitProvider(habitRepo, NotificationService());
  final psychometricProvider = PsychometricProvider(
    psychometricRepo, 
    PsychometricEngine(),
  );
  
  // Parallel provider initialization
  await Future.wait([
    settingsProvider.initialize(),
    userProvider.initialize(),
    habitProvider.initialize(),
    psychometricProvider.initialize(),
  ]);

  // === PHASE 3: Link Dependencies ===
  // Initial sync of user profile to habit provider
  habitProvider.updateUserProfile(userProvider.userProfile);

  // ... rest of initialization (Supabase, AI, etc.) ...

  runApp(
    MultiProvider(
      providers: [
        // NEW: Domain-specific providers
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: userProvider),
        
        // Use ProxyProvider to safely inject User into Habit (Atlas's recommendation)
        ChangeNotifierProxyProvider<UserProvider, HabitProvider>(
          create: (_) => habitProvider,
          update: (_, user, habit) => habit!..updateUserProfile(user.userProfile),
        ),
        
        ChangeNotifierProvider.value(value: psychometricProvider),
        
        // LEGACY: Keep AppState for backward compatibility during migration
        ChangeNotifierProvider.value(value: appState),
        
        // ... other providers ...
      ],
      child: MyApp(...),
    ),
  );
}
```

## Phase 3: Migrating Screens

### Before (Using AppState):
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final habit = appState.currentHabit;
    final settings = appState.settings;
    
    return ...;
  }
}
```

### After (Using Domain Providers):
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    final habit = habitProvider.currentHabit;
    final settings = settingsProvider.settings;
    
    return ...;
  }
}
```

## PsychometricProfile Integration

The `PsychometricProfile` is the key innovation for LLM context. Use it in AI services:

```dart
class GeminiChatService {
  final PsychometricProvider _psychometricProvider;
  
  Future<String> chat(String userMessage) async {
    final systemPrompt = _psychometricProvider.llmSystemPrompt;
    
    // Inject psychometric context into every AI call
    final response = await _gemini.generateContent([
      Content.system(systemPrompt),
      Content.text(userMessage),
    ]);
    
    return response.text;
  }
}
```

## Testing Benefits

With the Repository pattern, testing is now trivial:

```dart
class MockSettingsRepository implements SettingsRepository {
  AppSettings? _settings;
  
  @override
  Future<void> init() async {}
  
  @override
  Future<AppSettings?> getSettings() async => _settings;
  
  @override
  Future<void> saveSettings(AppSettings s) async => _settings = s;
}

test('SettingsProvider loads from repository', () async {
  final mockRepo = MockSettingsRepository();
  final provider = SettingsProvider(mockRepo);
  
  await provider.initialize();
  
  expect(provider.isLoading, false);
});
```

## Timeline

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Create repository layer | ✅ Complete |
| 2 | Create domain providers | ✅ Complete |
| 3 | Create PsychometricProfile | ✅ Complete |
| 4 | Wire into main.dart | 🔄 Ready (post-NYE) |
| 5 | Migrate screens | 📋 Planned |
| 6 | Remove AppState | 📋 Planned |

## Files Created

- `lib/data/repositories/settings_repository.dart`
- `lib/data/repositories/hive_settings_repository.dart`
- `lib/data/repositories/user_repository.dart`
- `lib/data/repositories/hive_user_repository.dart`
- `lib/data/repositories/habit_repository.dart`
- `lib/data/repositories/hive_habit_repository.dart`
- `lib/data/repositories/psychometric_repository.dart`
- `lib/data/repositories/hive_psychometric_repository.dart`
- `lib/data/providers/settings_provider.dart`
- `lib/data/providers/user_provider.dart`
- `lib/data/providers/habit_provider.dart`
- `lib/data/providers/psychometric_provider.dart`
- `lib/domain/entities/psychometric_profile.dart`
- `lib/domain/services/psychometric_engine.dart`
