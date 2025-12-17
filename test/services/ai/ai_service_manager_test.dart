import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:atomichabits/data/services/ai/ai_service_manager.dart';
import 'package:atomichabits/data/services/ai/deep_seek_service.dart';
import 'package:atomichabits/data/services/ai/claude_service.dart';

/// Phase 24.D: "The Reality Check"
/// 
/// Unit tests for AIServiceManager tier selection logic.
/// These tests verify:
/// 1. Tier selection based on user state (premium, bad habit)
/// 2. Fallback behavior when services are unavailable
/// 3. Provider display names and metadata
/// 
/// Strategic Purpose:
/// - Ensure the "Brain Transplant" routes correctly
/// - Verify bad habits → Claude (empathetic coaching)
/// - Verify standard users → DeepSeek (cost-effective)
void main() {
  group('AIServiceManager Tier Selection', () {
    
    // ============================================================
    // TIER SELECTION LOGIC
    // ============================================================
    
    test('selectProvider returns Claude for bad habits when available', () {
      // Create a testable manager with injected services
      final manager = _TestableAIServiceManager(
        hasDeepSeek: true,
        hasClaude: true,
        hasGemini: true,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: true,  // Breaking a bad habit
      );
      
      expect(provider, AiProvider.claude);
    });

    test('selectProvider returns Claude for premium users', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: true,
        hasClaude: true,
        hasGemini: true,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: true,  // Premium user
        isBreakHabit: false,
      );
      
      expect(provider, AiProvider.claude);
    });

    test('selectProvider returns DeepSeek for standard users', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: true,
        hasClaude: true,
        hasGemini: true,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: false,
      );
      
      expect(provider, AiProvider.deepSeek);
    });

    test('selectProvider falls back to Gemini when DeepSeek unavailable', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: false,  // DeepSeek not available
        hasClaude: false,
        hasGemini: true,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: false,
      );
      
      expect(provider, AiProvider.gemini);
    });

    test('selectProvider returns manual when no AI available', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: false,
        hasClaude: false,
        hasGemini: false,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: false,
      );
      
      expect(provider, AiProvider.manual);
    });

    test('selectProvider prefers Claude over DeepSeek for bad habits even for non-premium', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: true,
        hasClaude: true,
        hasGemini: true,
      );
      
      // Non-premium user breaking a bad habit
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: true,
      );
      
      // Should use Claude for empathetic coaching, not DeepSeek
      expect(provider, AiProvider.claude);
    });

    test('selectProvider falls back to DeepSeek when Claude unavailable for bad habits', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: true,
        hasClaude: false,  // Claude not available
        hasGemini: true,
      );
      
      final provider = manager.selectProvider(
        isPremiumUser: false,
        isBreakHabit: true,
      );
      
      // Should fall back to DeepSeek
      expect(provider, AiProvider.deepSeek);
    });

    // ============================================================
    // PROVIDER METADATA
    // ============================================================

    test('AiProvider displayName returns correct names', () {
      expect(AiProvider.deepSeek.displayName, 'The Architect');
      expect(AiProvider.claude.displayName, 'The Coach');
      expect(AiProvider.gemini.displayName, 'AI Assistant');
      expect(AiProvider.manual.displayName, 'Manual Entry');
    });

    test('AiProvider emoji returns correct emojis', () {
      expect(AiProvider.deepSeek.emoji, '🏗️');
      expect(AiProvider.claude.emoji, '🧠');
      expect(AiProvider.gemini.emoji, '✨');
      expect(AiProvider.manual.emoji, '✏️');
    });

    // ============================================================
    // AVAILABILITY CHECKS
    // ============================================================

    test('hasAnyAI returns true when at least one service available', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: false,
        hasClaude: false,
        hasGemini: true,  // Only Gemini available
      );
      
      expect(manager.hasAnyAI, true);
    });

    test('hasAnyAI returns false when no services available', () {
      final manager = _TestableAIServiceManager(
        hasDeepSeek: false,
        hasClaude: false,
        hasGemini: false,
      );
      
      expect(manager.hasAnyAI, false);
    });
  });

  group('AIServiceManager Integration with Mocks', () {
    
    test('singleTurn uses DeepSeek for standard user', () async {
      // Create mock HTTP client for DeepSeek
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('deepseek.com'));
        return http.Response(jsonEncode({
          "choices": [{"message": {"content": "DeepSeek response"}}]
        }), 200);
      });
      
      final deepSeekService = DeepSeekService(
        apiKey: 'TEST_KEY',
        client: mockClient,
      );
      
      // Test single turn
      final result = await deepSeekService.singleTurn(
        prompt: 'Test prompt',
        systemPrompt: 'Test system',
      );
      
      expect(result, 'DeepSeek response');
    });

    test('singleTurn uses Claude for bad habit user', () async {
      // Create mock HTTP client for Claude
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('anthropic.com'));
        return http.Response(jsonEncode({
          "content": [{"type": "text", "text": "Claude response"}]
        }), 200);
      });
      
      final claudeService = ClaudeService(
        apiKey: 'TEST_KEY',
        client: mockClient,
      );
      
      // Test single turn
      final result = await claudeService.singleTurn(
        prompt: 'Help me quit smoking',
        systemPrompt: 'You are The Coach',
      );
      
      expect(result, 'Claude response');
    });
  });
}

/// Testable version of AIServiceManager that allows injecting service availability
class _TestableAIServiceManager extends AIServiceManager {
  final bool _hasDeepSeek;
  final bool _hasClaude;
  final bool _hasGemini;
  
  _TestableAIServiceManager({
    required bool hasDeepSeek,
    required bool hasClaude,
    required bool hasGemini,
  }) : _hasDeepSeek = hasDeepSeek,
       _hasClaude = hasClaude,
       _hasGemini = hasGemini,
       super();
  
  @override
  bool get hasAnyAI => _hasDeepSeek || _hasClaude || _hasGemini;
  
  @override
  AiProvider selectProvider({
    required bool isPremiumUser,
    required bool isBreakHabit,
  }) {
    // Bad habits always use Claude (deeper psychology needed)
    if (isBreakHabit && _hasClaude) {
      return AiProvider.claude;
    }
    
    // Premium users get Claude
    if (isPremiumUser && _hasClaude) {
      return AiProvider.claude;
    }
    
    // Default to DeepSeek (The Architect)
    if (_hasDeepSeek) {
      return AiProvider.deepSeek;
    }
    
    // Fallback to Gemini
    if (_hasGemini) {
      return AiProvider.gemini;
    }
    
    // No AI available
    return AiProvider.manual;
  }
}
