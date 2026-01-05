import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:atomic_habits_hook_app/data/providers/psychometric_provider.dart';
import 'package:atomic_habits_hook_app/data/repositories/psychometric_repository.dart';
import 'package:atomic_habits_hook_app/domain/services/psychometric_engine.dart';
import 'package:atomic_habits_hook_app/domain/entities/psychometric_profile.dart';

// Generate mocks
import '../helpers/test_mocks.mocks.dart';

void main() {
  group('PsychometricProvider Tests', () {
    late PsychometricProvider provider;
    late MockPsychometricRepository mockRepo;
    late MockPsychometricEngine mockEngine;

    setUp(() {
      mockRepo = MockPsychometricRepository();
      mockEngine = MockPsychometricEngine();
      provider = PsychometricProvider(mockRepo, mockEngine);
      
      // Stub saveProfile to do nothing (or return Future.value())
      when(mockRepo.saveProfile(any)).thenAnswer((_) async {});
    });

    test('updateFromToolCall updates identity and failure traits correctly', () async {
      // ARRANGE
      final toolArgs = {
        'anti_identity_label': 'The Drifter',
        'anti_identity_context': 'Drifts through life without purpose.',
        'failure_archetype': 'Procrastination',
        'failure_trigger_context': 'Overwhelmed by large tasks.',
        'resistance_lie_label': 'I will do it tomorrow',
        'resistance_lie_context': 'Avoiding discomfort now.',
        'inferred_fears': ['Fear of failure', 'Fear of success']
      };

      // ACT
      await provider.updateFromToolCall(toolArgs);

      // ASSERT
      expect(provider.profile.antiIdentityLabel, 'The Drifter');
      expect(provider.profile.antiIdentityContext, 'Drifts through life without purpose.');
      expect(provider.profile.failureArchetype, 'Procrastination');
      expect(provider.profile.failureTriggerContext, 'Overwhelmed by large tasks.');
      expect(provider.profile.resistanceLieLabel, 'I will do it tomorrow');
      expect(provider.profile.resistanceLieContext, 'Avoiding discomfort now.');
      expect(provider.profile.inferredFears, contains('Fear of failure'));
      expect(provider.profile.inferredFears, contains('Fear of success'));
      
      // Verify repository save called
      verify(mockRepo.saveProfile(any)).called(1);
    });

    test('updateFromToolCall handles partial updates', () async {
      // ARRANGE
      // First, set initial state
      await provider.updateFromToolCall({'anti_identity_label': 'Initial Identity'});
      
      final partialArgs = {
        'failure_archetype': 'New Failure',
      };

      // ACT
      await provider.updateFromToolCall(partialArgs);

      // ASSERT
      // Should preserve old value
      expect(provider.profile.antiIdentityLabel, 'Initial Identity');
      // Should update new value
      expect(provider.profile.failureArchetype, 'New Failure');
    });

    test('hasHolyTrinity returns true when all 3 traits are present', () async {
      // ACT
      await provider.updateFromToolCall({
        'anti_identity_label': 'Anti-ID',
        'failure_archetype': 'Failure-Arch',
        'resistance_lie_label': 'Lie',
      });

      // ASSERT
      expect(provider.hasHolyTrinity, isTrue);
      expect(provider.isOnboardingComplete, isTrue);
    });

    test('hasHolyTrinity returns false when traits are missing', () async {
      // ACT
      await provider.updateFromToolCall({
        'anti_identity_label': 'Anti-ID',
        // Missing failure_archetype
        'resistance_lie_label': 'Lie',
      });

      // ASSERT
      expect(provider.hasHolyTrinity, isFalse);
    });
  });
}
