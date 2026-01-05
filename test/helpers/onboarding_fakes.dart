import 'package:flutter/material.dart';
import 'package:atomic_habits_hook_app/data/app_state.dart';
import 'package:atomic_habits_hook_app/data/providers/psychometric_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/user_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/settings_provider.dart';
import 'package:atomic_habits_hook_app/data/providers/habit_provider.dart';
import 'package:atomic_habits_hook_app/data/services/onboarding/onboarding_orchestrator.dart';
import 'package:atomic_habits_hook_app/data/services/voice_session_manager.dart';
import 'package:atomic_habits_hook_app/domain/entities/psychometric_profile.dart';
import 'package:atomic_habits_hook_app/data/models/user_profile.dart';
import 'package:atomic_habits_hook_app/features/onboarding/state/onboarding_state.dart';
import 'package:atomic_habits_hook_app/config/router/app_routes.dart';
import 'package:atomic_habits_hook_app/data/models/chat_message.dart';
import 'package:atomic_habits_hook_app/data/services/gemini_chat_service.dart';

// --- FAKES & MOCKS ---

class FakeGeminiChatService implements GeminiChatService {
  @override
  String get apiKey => "fake_api_key";

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAppState extends ChangeNotifier implements AppState {
  bool _hasCompletedOnboarding = false;
  // Default to true for testing to avoid guard friction unless explicitly testing guards
  bool _hasMicrophonePermission = true; 
  bool _hasNotificationPermission = true;
  bool _bypassGuards = true; // Use this to skip guards in integration tests

  @override
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  
  @override
  bool get hasMicrophonePermission => _hasMicrophonePermission;
  
  @override
  bool get hasNotificationPermission => _hasNotificationPermission;
  
  // Test helper to re-enable guards if needed
  void setBypassGuards(bool value) {
    _bypassGuards = value;
    notifyListeners();
  }

  void setCompletedOnboarding(bool value) {
    _hasCompletedOnboarding = value;
    notifyListeners();
  }

  void setMicrophonePermission(bool value) {
    _hasMicrophonePermission = value;
    notifyListeners();
  }
  
  void setNotificationPermission(bool value) {
    _hasNotificationPermission = value;
    notifyListeners();
  }
  
  @override
  String? checkCommitment(String location) {
    if (_bypassGuards) return null;

    // Replicating basic guard logic for testing
    if (location.startsWith('/onboarding/oracle') || location.startsWith('/onboarding/screening')) {
       if (_hasCompletedOnboarding) return null;
       if (!_hasMicrophonePermission || !_hasNotificationPermission) {
          return AppRoutes.misalignment;
       }
    }
    return null;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakePsychometricProvider extends ChangeNotifier implements PsychometricProvider {
  PsychometricProfile _profile = PsychometricProfile();
  
  @override
  PsychometricProfile get profile => _profile;
  
  @override
  bool get isLoading => false;
  
  void setProfile(PsychometricProfile p) {
    _profile = p;
    notifyListeners();
  }
  
  void updateProfileForTesting({
    String? antiIdentityLabel,
    String? failureArchetype,
    String? resistanceLieLabel,
  }) {
    _profile = _profile.copyWith(
      antiIdentityLabel: antiIdentityLabel ?? _profile.antiIdentityLabel,
      failureArchetype: failureArchetype ?? _profile.failureArchetype,
      resistanceLieLabel: resistanceLieLabel ?? _profile.resistanceLieLabel,
    );
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserProvider extends ChangeNotifier implements UserProvider {
  UserProfile _user = UserProfile(
    identity: 'Test',
    name: 'Test User',
    createdAt: DateTime.now(),
  );
  
  @override
  UserProfile? get userProfile => _user;
  
  @override
  bool get hasCompletedOnboarding => false;

  // Mocking the method called at end of onboarding
  Future<void> completeOnboarding() async {
    // No-op for test
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettingsProvider extends ChangeNotifier implements SettingsProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHabitProvider extends ChangeNotifier implements HabitProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Fixed: Extends ChangeNotifier to satisfy Provider requirements
class FakeVoiceSessionManager extends ChangeNotifier implements VoiceSessionManager {
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isThinking = false;
  String? _currentSystemPrompt;

  @override
  List<ChatMessage> get messages => _messages;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isThinking => _isThinking;

  @override
  bool get isSessionComplete => false;

  void setSystemPrompt(String prompt) {
    _currentSystemPrompt = prompt;
  }

  void addSystemGreeting(String greeting) {
    _messages.add(ChatMessage.sherlock(text: greeting));
    notifyListeners();
  }

  Future<void> sendText(String text) async {
    _messages.add(ChatMessage.user(content: text));
    notifyListeners();
    // Simulate AI response
    _isThinking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _isThinking = false;
    _messages.add(ChatMessage.sherlock(text: "Fake AI Response to: $text"));
    notifyListeners();
  }

  Future<void> startRecording() async {
    _isRecording = true;
    notifyListeners();
  }

  Future<void> stopRecordingAndSend() async {
    _isRecording = false;
    notifyListeners();
    // Simulate voice message processing
    _messages.add(ChatMessage.userVoice(audioPath: "fake/path.aac", duration: const Duration(seconds: 5)));
    notifyListeners();
    
    _isThinking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 100));
    _isThinking = false;
    _messages.add(ChatMessage.sherlock(text: "Fake AI processing done."));
    notifyListeners();
  }
  
  void resetSession() {
    _messages.clear();
    _isRecording = false;
    _isThinking = false;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  Future<void> cleanupSession() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOnboardingOrchestrator extends ChangeNotifier implements OnboardingOrchestrator {
  Future<String?> checkForDeferredDeepLink() async => null;
  
  // Support conversational test
  bool get isAiAvailable => true;
  String getHookGreeting() => "Hello test user!";
  void setHookVariant(String v) {}
  String getHookIdentityPrompt(String name) => "Nice to meet you $name";
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeOnboardingState extends ChangeNotifier implements OnboardingState {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
