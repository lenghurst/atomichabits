import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/domain/archetypes/archetype.dart';
import 'package:atomic_habits_hook_app/domain/services/archetype_registry.dart';
import 'package:atomic_habits_hook_app/domain/entities/context_snapshot.dart';
import 'package:atomic_habits_hook_app/domain/entities/psychometric_profile.dart';
import 'package:atomic_habits_hook_app/domain/entities/weather_context.dart';

// Mock Context
final mockContext = ContextSnapshot(
  snapshotId: 'test',
  capturedAt: DateTime.now(),
  time: TimeContext.fromDateTime(DateTime.now()),
  history: HistoricalContext(
    currentStreak: 0,
    daysSinceMiss: 0,
    totalIdentityVotes: 0,
    identityFusionScore: 0.5,
    resilienceScore: 0.5,
    habitStrength: 0.5,
  ),
  biometrics: BiometricContext(
    capturedAt: DateTime.now(), 
    sleepMinutes: 300, 
    sleepZScore: -2.0, // Low sleep score for test
  ),
);

// Mock Profile
final mockProfile = PsychometricProfile(
  failureArchetype: 'PERFECTIONIST',
  coreValues: ['Excellence'],
  // traitScores removed
);

void main() {
  group('ArchetypeRegistry', () {
    test('returns correct archetype by ID', () {
      final perfectionist = ArchetypeRegistry.get('PERFECTIONIST');
      expect(perfectionist, isA<PerfectionistArchetype>());
      
      final rebel = ArchetypeRegistry.get('REBEL');
      expect(rebel, isA<RebelArchetype>());
    });

    test('returns default for unknown ID', () {
      final unknown = ArchetypeRegistry.get('UNKNOWN');
      expect(unknown, isA<PerfectionistArchetype>()); // Default
    });

    test('is case insensitive', () {
      final rebel = ArchetypeRegistry.get('rebel');
      expect(rebel, isA<RebelArchetype>());
    });
  });

  group('PerfectionistArchetype', () {
    final archetype = PerfectionistArchetype();

    test('shows empathy for low sleep', () {
      final greeting = archetype.getGreeting(mockContext, mockProfile);
      expect(greeting, contains("I know you're tired"));
    });

    test('validates effort on miss', () {
      final reaction = archetype.getMissReaction(mockContext, mockProfile);
      expect(reaction, contains("one miss doesn't ruin"));
    });
  });

  group('RebelArchetype', () {
    final archetype = RebelArchetype();

    test('emphasizes autonomy', () {
      final greeting = archetype.getGreeting(mockContext, mockProfile);
      expect(greeting, contains("your call"));
    });
  });
}
