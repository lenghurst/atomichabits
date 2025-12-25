import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:atomic_habits_hook_app/data/services/ai/deep_seek_service.dart';
// import 'package:atomic_habits_hook_app/data/models/chat_message.dart';  // Currently unused
import 'package:atomic_habits_hook_app/data/models/chat_conversation.dart';

/// Phase 24.D: "The Reality Check"
/// 
/// Unit tests for DeepSeekService using mock HTTP client.
/// These tests verify:
/// 1. API response parsing (JSON structure)
/// 2. Error handling (401, 500, timeout)
/// 3. Message formatting
/// 
/// Strategic Purpose:
/// - Verify the "Brain Transplant" works without live API keys
/// - Ensure JSON parsing matches DeepSeek V3's response format
/// - Prevent crashes on New Year's Day
void main() {
  group('DeepSeekService (Offline Simulation)', () {
    
    // ============================================================
    // SUCCESS SCENARIOS
    // ============================================================
    
    test('Returns content when API call is successful', () async {
      // 1. Setup Mock "Fake Internet"
      final mockResponse = {
        "id": "chatcmpl-abc123",
        "object": "chat.completion",
        "created": 1703123456,
        "model": "deepseek-chat",
        "choices": [
          {
            "index": 0,
            "message": {
              "role": "assistant",
              "content": "This is a simulated response from DeepSeek."
            },
            "finish_reason": "stop"
          }
        ],
        "usage": {
          "prompt_tokens": 10,
          "completion_tokens": 20,
          "total_tokens": 30
        }
      };

      final mockClient = MockClient((request) async {
        // Verify request structure
        expect(request.url.toString(), contains('api.deepseek.com'));
        expect(request.headers['Authorization'], 'Bearer TEST_KEY');
        expect(request.headers['Content-Type'], contains('application/json'));
        
        return http.Response(jsonEncode(mockResponse), 200);
      });

      // 2. Initialize Service with Mock
      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);

      // 3. Execute
      final result = await service.singleTurn(
        prompt: 'Hello',
        systemPrompt: 'You are a test bot',
      );

      // 4. Verify
      expect(result, "This is a simulated response from DeepSeek.");
    });

    test('Parses Recovery Plan JSON correctly', () async {
      // This test simulates the RecoveryEngine scenario
      // The AI returns a JSON object embedded in the response
      final recoveryPlanJson = {
        "headline": "Just put on your shoes",
        "action": "2-min walk around the block",
        "encouragement": "Yesterday was data, not defeat. Let's go!"
      };
      
      final mockResponse = {
        "choices": [
          {
            "message": {
              "content": jsonEncode(recoveryPlanJson)
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);

      final result = await service.singleTurn(
        prompt: 'Generate a recovery plan',
        systemPrompt: 'Return JSON only',
      );

      // Verify we can parse the JSON from the response
      final parsed = jsonDecode(result);
      expect(parsed['headline'], 'Just put on your shoes');
      expect(parsed['action'], '2-min walk around the block');
      expect(parsed['encouragement'], contains('data, not defeat'));
    });

    test('Handles multi-turn conversation correctly', () async {
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body);
        final messages = body['messages'] as List;
        
        // Verify conversation history is included
        expect(messages.length, greaterThan(1));
        
        return http.Response(jsonEncode({
          "choices": [
            {
              "message": {
                "content": "I see you said: ${messages.last['content']}"
              }
            }
          ]
        }), 200);
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);
      
      // Start conversation
      final conversation = await service.startConversation(
        type: ConversationType.onboarding,
        systemPrompt: 'You are a test bot',
      );
      
      // Send message
      final response = await service.sendMessage(
        userMessage: 'Hello, world!',
        conversation: conversation,
      );
      
      expect(response.content, contains('Hello, world!'));
      expect(response.isUser, false);
    });

    // ============================================================
    // ERROR SCENARIOS
    // ============================================================

    test('Throws exception on 401 Unauthorized', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": {"message": "Invalid API key"}}), 
          401
        );
      });

      final service = DeepSeekService(apiKey: 'BAD_KEY', client: mockClient);

      expect(
        () => service.singleTurn(prompt: 'Hello', systemPrompt: ''),
        throwsA(isA<DeepSeekException>()),
      );
    });

    test('Throws exception on 500 Server Error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": {"message": "Internal server error"}}), 
          500
        );
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);

      expect(
        () => service.singleTurn(prompt: 'Hello', systemPrompt: ''),
        throwsA(isA<DeepSeekException>()),
      );
    });

    test('Throws exception on 429 Rate Limit', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({"error": {"message": "Rate limit exceeded"}}), 
          429
        );
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);

      expect(
        () => service.singleTurn(prompt: 'Hello', systemPrompt: ''),
        throwsA(isA<DeepSeekException>()),
      );
    });

    // ============================================================
    // CONFIGURATION TESTS
    // ============================================================

    test('isConfigured returns false for empty API key', () {
      final service = DeepSeekService(apiKey: '', client: MockClient((r) async => http.Response('', 200)));
      expect(service.isConfigured, false);
    });

    test('isConfigured returns true for valid API key', () {
      final service = DeepSeekService(apiKey: 'sk-xxx', client: MockClient((r) async => http.Response('', 200)));
      expect(service.isConfigured, true);
    });

    // ============================================================
    // JSON PARSING EDGE CASES
    // ============================================================

    test('Handles UTF-8 characters in response', () async {
      final mockResponse = {
        "choices": [
          {
            "message": {
              "content": "你好！This is a test with émojis 🎉 and spëcial châräctérs."
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode(mockResponse), 
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);
      final result = await service.singleTurn(prompt: 'Hello', systemPrompt: '');

      expect(result, contains('你好'));
      expect(result, contains('🎉'));
      expect(result, contains('spëcial'));
    });

    test('Handles empty content gracefully', () async {
      final mockResponse = {
        "choices": [
          {
            "message": {
              "content": ""
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);
      final result = await service.singleTurn(prompt: 'Hello', systemPrompt: '');

      expect(result, '');
    });

    test('Handles very long response content', () async {
      final longContent = 'A' * 10000; // 10KB of text
      final mockResponse = {
        "choices": [
          {
            "message": {
              "content": longContent
            }
          }
        ]
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final service = DeepSeekService(apiKey: 'TEST_KEY', client: mockClient);
      final result = await service.singleTurn(prompt: 'Hello', systemPrompt: '');

      expect(result.length, 10000);
    });
  });
}
