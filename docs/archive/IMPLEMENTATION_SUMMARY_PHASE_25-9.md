## Implementation Summary: Phase 25.9 - The Shadow Board Critique

**Date:** 18 December 2025
**Author:** Manus AI (Lead AI Architect)

This document summarises the critical changes implemented in response to the Shadow Board SME critique. The focus of this phase was to harden the application against real-world failures, enhance the user experience, and inject proven growth and retention mechanics.

### 1. Network Resilience: Circuit Breaker & Failover (Uncle Bob & James Bach)

In response to feedback from **Uncle Bob** and **James Bach**, the `GeminiLiveService` has been completely re-architected for resilience.

- **Circuit Breaker Pattern:** The service now includes a robust circuit breaker (`maxRetries = 3`, `retryDelay = 2 seconds`) that automatically detects WebSocket connection failures.
- **Automatic Failover:** If the Gemini Live API (native voice) fails repeatedly, the system now automatically falls back to a text-based interaction using the `GeminiChatService` and a standard Text-to-Speech (TTS) engine. This ensures the user can always interact with the coach, even during a partial outage.
- **Reconnection Logic:** The service will attempt to reconnect to the WebSocket in the background, allowing for seamless session resumption if the network recovers.

| File | Change Description |
| :--- | :--- |
| `lib/data/services/gemini_live_service.dart` | Rewritten to include circuit breaker, reconnection logic, and automatic failover to `GeminiChatService` + TTS. |

### 2. Code Quality & Testability (Uncle Bob)

**Uncle Bob** noted the tight coupling in the `ExperimentationService`. This has been resolved by refactoring the service to use dependency injection.

- **Provider Interfaces:** Introduced `StorageProvider` and `AnalyticsProvider` abstract interfaces.
- **Dependency Injection:** The `ExperimentationService` now depends on these interfaces, not concrete implementations like `SharedPreferences` or `SupabaseClient`.
- **Testability:** This change allows for proper unit testing with mock providers (`InMemoryStorageProvider`, `NoOpAnalyticsProvider`), decoupling the business logic from the infrastructure.

| File | Change Description |
| :--- | :--- |
| `lib/data/services/experimentation_service.dart` | Refactored to use `StorageProvider` and `AnalyticsProvider` interfaces for dependency injection. Added production and test implementations. |

### 3. Growth Hacking: The Viral Wallet Pass (Sean Ellis)

Following **Sean Ellis's** directive, the Google Wallet pass is now a Trojan Horse for growth.

- **Dynamic Referral Code:** The `create-wallet-pass` Supabase Edge Function now generates a unique referral code for each user.
- **QR Code Deep Link:** This referral code is embedded directly into the QR code on the Google Wallet pass. When scanned, it creates a deep link (`https://thepact.co/c/<code>`) that drives new users to the app with the referral code automatically applied.

| File | Change Description |
| :--- | :--- |
| `supabase/functions/create-wallet-pass/index.ts` | Updated to generate/retrieve a user referral code and embed it in the QR code value and links module. |

### 4. Retention: Variable Rewards (Nir Eyal)

To combat response fatigue, as highlighted by **Nir Eyal**, a variable reward system has been implemented for AI interactions.

- **Coach Personas:** Created six distinct AI coach personas (Stoic, Drill Sergeant, Empathetic, etc.), each with a unique tone and prompt modifier.
- **Weighted Randomisation:** A `PersonaSelector` utility now uses a weighted randomisation algorithm to select a persona for each voice session. This prevents repetition and introduces unpredictability.
- **Contextual Selection:** The selection logic is weighted based on user context (e.g., favouring an empathetic coach after a missed habit).

| File | Change Description |
| :--- | :--- |
| `lib/config/ai_prompts.dart` | Added `CoachPersona` enum, `PersonaSelector` utility, and a new `voiceSession` prompt that injects the selected persona. |

### 5. User Experience: Haptics & VAD (Don Norman)

**Don Norman's** feedback on the importance of sensory feedback has been addressed.

- **Complex Haptic Patterns:** Created a new `HapticPatterns` utility to provide complex, multi-stage vibration patterns for key events like the Wax Seal signing ceremony.
- **VAD Visual Feedback:** The `GeminiLiveService` now exposes a `VoiceActivityState` stream. The UI can now listen to this stream to provide immediate visual feedback (e.g., a pulsing microphone icon) the moment the user starts speaking, even before the audio is sent to the server.

| File | Change Description |
| :--- | :--- |
| `lib/utils/haptic_patterns.dart` | New utility for creating complex, timed haptic feedback for key app events. |
| `lib/features/witness/witness_accept_screen.dart` | (Updated in next commit) Will be updated to use `HapticPatterns.waxSealStamp()`. |

### 6. Strategy: The Model Kill Switch (Peter Thiel)

To mitigate platform risk, as per **Peter Thiel's** recommendation, a model-agnostic kill switch system has been implemented.

- **Provider Abstraction:** The `AIModelConfig` now acts as a provider abstraction layer.
- **Remote Configurable Kill Switches:** Added kill switches for the global AI, Gemini, DeepSeek, and the voice feature. These can be toggled remotely via Supabase Remote Config.
- **Automatic Failover Chain:** The `selectTier` logic now implements a failover chain: if Gemini is killed, it falls back to DeepSeek; if DeepSeek is killed, it falls back to Gemini; if both are killed, it falls back to manual mode.

| File | Change Description |
| :--- | :--- |
| `lib/config/ai_model_config.dart` | Added kill switch flags, remote config update logic, and failover logic in the `selectTier` method. |

All changes have been committed and pushed to the `main` branch. The application is now significantly more robust, engaging, and strategically sound.
