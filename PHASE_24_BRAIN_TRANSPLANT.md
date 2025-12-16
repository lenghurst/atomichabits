# Phase 24: The Brain Transplant

> **Status:** ✅ Complete  
> **Date:** December 2025  
> **PR:** #13 (genspark_ai_developer branch)

## Overview

Successfully refactored the app to use the new **AIServiceManager** architecture, replacing direct `GeminiChatService` usage throughout the codebase. This enables the multi-tier AI strategy with DeepSeek-V3, Claude 3.5 Sonnet, and Gemini 2.5 Flash.

## Architecture Change

### Before (Old Architecture)
```
UI Components → GeminiChatService (hardcoded) → Gemini API
```

### After (New Architecture)
```
UI Components → AIServiceManager → Tier Selection Logic
                                  ├─ DeepSeek-V3 (Tier 1: The Architect)
                                  ├─ Claude 3.5 Sonnet (Tier 2: The Coach)
                                  ├─ Gemini 2.5 Flash (Tier 3: Fallback)
                                  └─ Manual Mode (Tier 4: No AI)
```

## Tier Selection Logic

1. **Bad Habit Breaking** → Claude (deeper psychology needed)
2. **Premium User** → Claude (premium experience)
3. **Standard User** → DeepSeek (cost-effective reasoning)
4. **DeepSeek Fails** → Gemini (automatic fallback)
5. **All Fail** → Manual mode

## Files Modified

### 1. `lib/main.dart`
**Changes:**
- Replaced `GeminiChatService` import with `AIServiceManager`
- Updated initialization: `AIServiceManager()` instead of `GeminiChatService(...)`
- Changed provider from `Provider<GeminiChatService>` to `ChangeNotifierProvider<AIServiceManager>`
- Updated `WeeklyReviewService` proxy provider
- Updated `OnboardingOrchestrator` proxy provider

**Key Code:**
```dart
// Phase 24: Initialize AI Service Manager (The Brain Transplant)
final aiServiceManager = AIServiceManager();

// Provider setup
ChangeNotifierProvider<AIServiceManager>.value(value: widget.aiServiceManager),

// Proxy providers now use AIServiceManager
ProxyProvider<AIServiceManager, WeeklyReviewService>(...)
ChangeNotifierProxyProvider<AIServiceManager, OnboardingOrchestrator>(...)
```

### 2. `lib/data/services/onboarding/onboarding_orchestrator.dart`
**Changes:**
- Replaced `GeminiChatService _geminiService` with `AIServiceManager _aiServiceManager`
- Updated constructor parameter
- Modified `magicWandComplete()` to use tier-based AI selection
- Updated `startConversation()` to support `isBreakHabit` parameter
- Refactored `_sendWithTimeout()` to use `AIServiceManager.sendMessage()`

**Key Code:**
```dart
// Constructor
OnboardingOrchestrator({
  required AIServiceManager aiServiceManager,
  ...
}) : _aiServiceManager = aiServiceManager;

// Start conversation with tier selection
_conversation = await _aiServiceManager.startConversation(
  isPremiumUser: false, // TODO: Get from user profile
  isBreakHabit: isBreakHabit,
  type: ConversationType.onboarding,
);

// Send message (no need to pass conversation, managed internally)
final response = await _aiServiceManager.sendMessage(
  userMessage: message,
);
```

### 3. `lib/data/services/weekly_review_service.dart`
**Changes:**
- Replaced `GeminiChatService _geminiService` with `AIServiceManager _aiServiceManager`
- Updated constructor parameter
- Modified `generateReview()` to use `singleTurn()` method with tier selection

**Key Code:**
```dart
// Constructor
WeeklyReviewService(this._aiServiceManager);

// Single-turn AI request
final aiResponse = await _aiServiceManager.singleTurn(
  prompt: prompt,
  isPremiumUser: false, // TODO: Get from user profile
  isBreakHabit: habit.isBreakHabit,
);
```

## Benefits

### 1. **Cost Optimization**
- DeepSeek-V3 is ~10x cheaper than Claude for standard users
- Automatic fallback prevents failed requests

### 2. **Quality Improvement**
- Claude's empathy for bad habit breaking
- DeepSeek's reasoning for structured habit design
- Gemini's speed as reliable fallback

### 3. **Future-Proof Architecture**
- Easy to add new AI providers
- Centralized tier logic
- Premium tier ready for monetization

### 4. **Automatic Failover**
- If DeepSeek fails → automatically tries Gemini
- No user-facing errors
- Graceful degradation

## Testing Checklist

- [ ] Magic Wand feature (onboarding auto-fill)
- [ ] Conversational onboarding chat
- [ ] Weekly review generation
- [ ] Bad habit detection triggers Claude
- [ ] DeepSeek failure triggers Gemini fallback
- [ ] Manual mode works when no AI available

## TODO Items

### Immediate
- [ ] Add user premium status detection (currently hardcoded to `false`)
- [ ] Test with real API keys for all three providers
- [ ] Verify fallback logic in production

### Future
- [ ] Add analytics to track which AI tier is used most
- [ ] Implement cost tracking per user
- [ ] Add A/B testing framework for AI quality comparison

## Migration Notes

### For Developers
- **No breaking changes** to UI components
- All AI calls now go through `AIServiceManager`
- `GeminiChatService` still exists as Tier 3 fallback (do not delete)

### For QA
- Test all onboarding flows (Magic Wand + Conversational)
- Test weekly review generation
- Test with different habit types (build vs break)

## Related Files

- `lib/data/services/ai/ai_service_manager.dart` - The new brain (created in PR #13)
- `lib/data/services/ai/deep_seek_service.dart` - DeepSeek integration
- `lib/data/services/ai/claude_service.dart` - Claude integration
- `lib/data/services/gemini_chat_service.dart` - Now used as fallback only
- `lib/config/ai_model_config.dart` - Tier configuration

## Verification

Run these commands to verify the refactoring:

```bash
# Should return only one comment reference (not actual usage)
grep -r "GeminiChatService" lib/main.dart lib/data/services/onboarding/ lib/data/services/weekly_review_service.dart

# Should show AIServiceManager usage
grep -r "AIServiceManager" lib/main.dart lib/data/services/onboarding/ lib/data/services/weekly_review_service.dart
```

## Conclusion

The "Brain Transplant" is complete. The app now uses a sophisticated multi-tier AI architecture that:
- Reduces costs with DeepSeek
- Improves quality with Claude for complex cases
- Maintains reliability with Gemini fallback
- Enables future premium monetization

**Next Steps:** Wire up the "Install Referrer" viral loop (Step B from the original strategy document).
