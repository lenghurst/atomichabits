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

    test('questions external motivation on miss', () {
      final reaction = archetype.getMissReaction(mockContext, mockProfile);
      expect(reaction, contains('Did you choose to skip'));
    });
  });

  group('ProcrastinatorArchetype', () {
    final archetype = ArchetypeRegistry.get('PROCRASTINATOR');

    test('offers small steps for greeting', () {
      final greeting = archetype.getGreeting(mockContext, mockProfile);
      expect(greeting, contains('Just 2 minutes')); // Actual: "Just 2 minutes. That's all..."
    });

    test('encourages starting small on miss', () {
      final reaction = archetype.getMissReaction(mockContext, mockProfile);
      expect(reaction, contains('Starting is the hardest part')); // Actual: "Starting is the hardest part. Tomorrow, just..."
    });
  });

  group('PeoplePleaserArchetype', () {
    final archetype = ArchetypeRegistry.get('PEOPLE_PLEASER');

    test('prioritizes Social Witness for greeting', () {
      final greeting = archetype.getGreeting(mockContext, mockProfile);
      expect(greeting, contains('Someone believes in you'));
    });

    test('reminds of social commitment on miss', () {
      final reaction = archetype.getMissReaction(mockContext, mockProfile);
      expect(reaction, contains('okay to disappoint yourself')); // Actual: "It's okay to disappoint yourself sometimes. But..."
    });
  });

  // Note: Testing HierarchicalBandit seeding requires inspecting private state or 
  // mocking the taxonomy, which is complex. Relying on integration verification.
}
