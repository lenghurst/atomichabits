/// AI Services Module
/// 
/// Phase 24: "Brain Surgery 2.0" - AI Tier Refactor
/// 
/// Tier Architecture:
/// - Tier 1: DeepSeek-V3 "The Architect" - Reasoning-heavy, cost-effective
/// - Tier 2: Claude 3.5 Sonnet "The Coach" - Empathetic, high EQ
/// - Tier 3: Gemini 2.5 Flash - Fallback
/// - Tier 4: Manual - No AI
/// 
/// Usage:
/// ```dart
/// import 'package:atomic_habits_hook_app/data/services/ai/ai.dart';
/// 
/// final aiManager = AIServiceManager();
/// await aiManager.startConversation(isPremiumUser: false, isBreakHabit: false);
/// ```
library;

export 'ai_service_manager.dart';
export 'deep_seek_service.dart';
export 'claude_service.dart';
