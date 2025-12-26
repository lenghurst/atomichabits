## [6.4.0] - 2025-12-26 - Phase 46: "Voice Architecture Simplification"

### Architecture
- **Simplified Voice Stack:** Removed Supabase Edge Function dependency for voice tokens; defaulting to direct API key usage for launch.
- **Provider Abstraction:** Introduced `VoiceApiService` interface to support multiple AI providers (Gemini, OpenAI).
- **OpenAI Integration:** Added `OpenAILiveService` implementing the OpenAI Realtime API (WebSocket).
- **Diagnostics Tool:** Implemented real network latency testing in `VoiceProviderSelector` to compare provider performance.

### Added
- **VoiceApiService:** New abstract interface for voice communication.
- **OpenAILiveService:** Implementation of OpenAI Realtime API.
- **Diagnostics Tool:** Triple-tap header -> DevTools -> "Test Voice Connection" now pings real servers.
- **Latency Metrics:** `measureLatency()` added to all voice services.

### Changed
- **VoiceSessionManager:** Updated to use `VoiceApiService` and dynamically select provider based on configuration.
- **GeminiLiveService:** Refactored to implement `VoiceApiService` and added `measureLatency()`.
- **DevToolsOverlay:** Updated "View Logs" and added "Test Voice Connection".

---

## [6.3.4] - 2025-12-26 - Phase 45: "Cloud Sync Preparation"

### Architecture
- **Sync-Ready Psychometrics:** `PsychometricProfile` now tracks its own sync state to prepare for upcoming Supabase integration
- **Dirty State Management:** `PsychometricProvider` automatically marks profiles as "not synced" whenever modifications occur (via tools or user input)

### Added
- **PsychometricProfile:** Added `isSynced` (bool) and `lastUpdated` (DateTime) fields
- **PsychometricRepository:** Added `markAsSynced()` method to interface and Hive implementation
- **Unit Tests:** Created `psychometric_sync_test.dart` to verify state transitions

### Changed
- **PsychometricProfile:** Removed `const` constructor to support `DateTime.now()` as default `lastUpdated` timestamp
- **PactRevealScreen:** Updated fallback profile to use `static final` instead of `const`

---

## [6.3.3] - 2025-12-26 - Phase 45: "User Data Unification & Flow Fix"

### Architecture
- **Unified User Data:** `isPremium` status moved from standalone Hive key to `UserProfile` model
- **Migration Engine:** `HiveUserRepository` automatically migrates legacy data on next launch
- **Source of Truth:** `UserProvider` now relies solely on `UserProfile` for premium status

### Fixed
- **Onboarding Route Gap:** `PactRevealScreen` (the "Magic Moment") was disconnected from the manual onboarding flow.
- **Navigation Loop:** Both `PactTierSelectorScreen` (manual flow) and `ConversationalOnboardingScreen` (chat flow) now correctly route to `PactRevealScreen` before entering the Dashboard.

### Changed
- **UserProfile:** Added `isPremium` field (defaults to false)
- **UserProvider:** Removed `_isPremium` state, now derived from profile
- **HiveUserRepository:** Added migration logic in `getProfile()`
- **Registration Deferral:** `AppState.completeOnboarding()` is now solely handled by `PactRevealScreen`, ensuring the variable reward is always seen.

### Technical Details (The Strangler Pattern)
- Simplifies state management by having a single source of truth for user identity
- Resolves data fragmentation between Identity and Subscription status
- Prepares for eventual removal of legacy `AppState`
