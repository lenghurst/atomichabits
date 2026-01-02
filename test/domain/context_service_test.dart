import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/domain/services/context_service.dart';
import 'package:atomic_habits_hook_app/domain/services/jitai_context_service.dart';
import 'package:atomic_habits_hook_app/domain/entities/context_snapshot.dart';
import 'package:atomic_habits_hook_app/domain/entities/weather_context.dart';
import 'package:atomic_habits_hook_app/data/models/habit.dart';
// import 'package:atomic_habits_hook_app/data/services/weather_service.dart'; 

// Mock Context Service
class MockContextService extends ContextService {
  MockContextService({super.weatherService});

  @override
  Future<ContextSnapshot> getSnapshot({
    required Habit habit,
    List<Habit>? allHabits,
    List<String> activePatterns = const [],
  }) async {
    final now = DateTime.now();
    return ContextSnapshot(
      snapshotId: 'mock_${now.millisecondsSinceEpoch}',
      capturedAt: now,
      time: TimeContext.fromDateTime(now),
      history: HistoricalContext(
        currentStreak: 5,
        daysSinceMiss: 0,
        totalIdentityVotes: 10,
        identityFusionScore: 0.8,
        resilienceScore: 0.7,
        habitStrength: 0.6,
      ),
      biometrics: BiometricContext(
        capturedAt: now,
        sleepMinutes: 420, // 7 hours
        hrvSdnn: 50.0,
      ),
    );
  }
}

void main() {
  group('JITAIContextService', () {
    test('enriches snapshot with Z-scores', () async {
      final mockBase = MockContextService();
      final jitaiService = JITAIContextService(baseService: mockBase);

      // 1. Initialize (load baselines, effectively empty for now)
      await jitaiService.initialize();

      // 2. Get Snapshot
      // Create valid habit
      final habit = Habit(
        id: '1', 
        name: 'Test Habit', 
        identity: 'Reader',
        tinyVersion: 'Read 1 page',
        createdAt: DateTime.now(),
        implementationTime: '09:00',
        implementationLocation: 'Home',
      ); 
      
      final snapshot = await jitaiService.getEnrichedSnapshot(habit: habit);

      expect(snapshot.biometrics, isNotNull);
      expect(snapshot.biometrics!.sleepZScore, 0.0);
    });

    test('applies thermostat override', () async {
      final mockBase = MockContextService();
      final jitaiService = JITAIContextService(baseService: mockBase);
      final habit = Habit(
        id: '1', 
        name: 'Test Habit', 
        identity: 'Reader',
        tinyVersion: 'Read 1 page',
        createdAt: DateTime.now(),
        implementationTime: '09:00',
        implementationLocation: 'Home',
      ); 

      jitaiService.setVulnerabilityOverride(0.9);

      final snapshot = await jitaiService.getEnrichedSnapshot(habit: habit);
      expect(snapshot.userVulnerabilityOverride, 0.9);
    });
  });
}
