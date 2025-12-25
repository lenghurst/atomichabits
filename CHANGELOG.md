## [6.1.0] - 2025-12-25 - Phase 42: "Soul Capture Onboarding"

### Added
- **Sherlock Protocol:** AI extracts psychological traits through deduction, not direct questioning
- **Tool Schema:** `lib/config/ai_tools_config.dart` - `update_user_psychometrics` function declaration
- **Holy Trinity Fields:** `antiIdentityLabel`, `failureArchetype`, `resistanceLieLabel` + contexts in `PsychometricProfile`
- **Dynamic Prompts:** `lib/data/services/ai/prompt_factory.dart` - Injects user psychology into AI context
- **Session Modes:** `VoiceSessionMode.onboarding` and `VoiceSessionMode.coaching` in VoiceSessionManager

### Changed
- **GeminiLiveService:** Now supports tool calling via `onToolCall` callback and `sendToolResponse()` method
- **VoiceSessionManager:** Orchestrates onboarding with tools enabled, routes tool_call to PsychometricProvider
- **PsychometricProvider:** Added `updateFromToolCall()` for real-time Hive persistence
- **ai_prompts.dart:** Added `voiceOnboardingSystemPrompt` (Sherlock Protocol conversation flow)

### Technical Details
- Tool calls are saved **immediately** (Margaret Hamilton's crash recovery principle)
- Holy Trinity maps to user retention funnel: Day 1 (Anti-Identity), Day 7 (Failure Archetype), Day 30+ (Resistance Lie)
- AI uses 3-phase conversation: Describe → Deduce → Confirm & Save

---

## [6.0.9] - 2025-12-25 - Phase 41.3: "Documentation Overhaul"

### Documentation
- **README.md:** Extensively updated with the latest project status, tech stack, architecture diagrams, and developer tool usage.
- **AI_CONTEXT.md:** Updated to reflect the now-working Gemini Live API connection, the DeepSeek funding issue, and the completed navigation refactor.
- **ROADMAP.md:** Overhauled to set the next immediate priorities: fixing unit tests and static analysis issues, and preparing for a GitHub Actions build.

# CHANGELOG

All notable changes to The Pact will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.8] - 2025-12-25 - Phase 41.2: "Navigation Migration Complete"

### Changed
- Migrated all 44 remaining navigation calls to `AppRoutes` constants
- Updated 19 files across onboarding, contracts, settings, and witness features
- Zero string literal navigation calls remaining in codebase

### Fixed
- Invalid `/invite?c=` route → `AppRoutes.contractJoin(code)`
- Missing `/settings/account` route constant added
- Wrong API `Navigator.pushNamed` → `context.push()` in witness screens

### Documentation
- Updated README.md with Phase 41.2 status
- Updated AI_CONTEXT.md with migration summary
- Updated ROADMAP.md with detailed task breakdown

---

## [6.0.7] - 2025-12-25 - Phase 41: "Navigation Architecture"

### Added
- **Route Constants:** `lib/config/router/app_routes.dart` with centralised path definitions
- **Extracted Router:** `lib/config/router/app_router.dart` with GoRouter configuration
- **Redirect Logic:** Auth and onboarding guards for protected routes

### Changed
- **main.dart:** Reduced by ~180 lines (routes extracted to AppRouter)
- **Navigation Calls:** Now use `AppRoutes.dashboard` instead of `'/dashboard'`
- **habit_list_screen.dart:** Updated to use route constants
- **dev_tools_overlay.dart:** Updated to use route constants

### Improved
- Compile-time route validation
- IDE autocomplete for routes
- Single source of truth for navigation paths
- Refactoring safety (change path in one place)

---

## [6.0.6] - 2025-12-25 - Phase 40: "DeepSeek Optimization"

### Changed
- **DeepSeek JSON Mode:** Added `response_format: {'type': 'json_object'}` to force clean JSON output
- **System Prompt:** Added `### OUTPUT FORMAT` section requiring JSON responses
- Reduces Markdown pollution in AI responses

### Technical Details
- DeepSeek API now returns structured JSON instead of Markdown-wrapped responses
- System prompt must contain the word "JSON" for `json_object` mode to work
- Existing `AiResponseParser.sanitizeAndExtractJson()` remains as fallback

---

## [6.0.5] - 2025-12-25 - Phase 39 & 41: "Logging Consolidation & Security Fix"

### Security (CRITICAL)
- **REMOVED** Oliver Backdoor from `app_state.dart` and `user_provider.dart`
- Premium status now determined solely by stored value
- No more hardcoded email privileges

### Changed
- **Unified logging system**: All logs now go through `AppLogger`
- `AppLogger` automatically writes to `LogBuffer` for in-app console
- `LogBuffer` now uses structured `LogEntry` with severity levels
- `DebugConsoleView` shows level-based coloring (debug=grey, info=green, warning=orange, error=red)

### Removed
- **Deleted** `lib/utils/developer_logger.dart` (replaced by `AppLogger`)
- Removed all `DevLog` usages across the codebase

### Migration
- `DevLog.voice()` → `_logger.info()`
- `DevLog.error()` → `_logger.error()`
- `DevLog.setEnabled()` → `AppLogger.globalEnabled = `

---

## [6.0.4] - 2025-12-25 - Phase 38: "In-App Log Console"

### Added
- **LogBuffer Singleton:** Centralized logging buffer (`lib/core/logging/log_buffer.dart`) that stores last 1000 log entries
- **DebugConsoleView Widget:** Terminal-like UI for viewing live logs with VS Code dark theme styling
- **View Gemini Logs Button:** Added to DevToolsOverlay for one-click access to connection logs
- **Verbose Connection Logging:** GeminiLiveService now logs every step with emojis for easy scanning

### Features
- Real-time log updates via `ValueListenableBuilder`
- One-click "Copy All" to clipboard for debugging
- Clear logs button
- Error highlighting (red text for failures)
- Auto-scroll to latest logs
- Separator lines for new connection attempts

### Technical Details
- Logs include: Endpoint, Model, Headers, Token status, Handshake result
- Error logs include diagnostic hints (e.g., "Check: API Key permissions, Billing enabled")
- Integrates with existing `_addDebugLog()` method for backward compatibility

---

## [6.0.3] - 2025-12-25 - Phase 37: "Production-Ready Connection"

### Improved
- **Honest User-Agent Header:** Replaced Python client spoofing with honest `Dart/3.5 (flutter); co.thepact.app/6.0.3` header
- **Explicit Handshake Verification:** Added `await _channel!.ready` to ensure WebSocket handshake completes before proceeding
- **Granular Error Handling:** Distinguish between `HandshakeException` (server rejection) and `SocketException` (network failure)
- **Defensive URL Validation:** Added assert statements to catch configuration errors early

### Technical Details
- The honest User-Agent builds trust with Web Application Firewalls (WAFs) and is sustainable long-term
- `HandshakeException` → "Google refused connection" (Red Light in future Dev Tools)
- `SocketException` → "Check your internet" (Yellow Light in future Dev Tools)
- Based on Genspark feedback identifying Python spoofing as technical debt

---

## [6.0.2] - 2025-12-25 - Phase 36: "Header Injection Fix"

### Fixed
- **CRITICAL: 403 Forbidden Error:** Fixed WebSocket connection being rejected by Google Front End (GFE)
- Root cause: Dart's default WebSocket client was missing headers that GFE expects for protocol fingerprinting
- Solution: Use `IOWebSocketChannel.connect()` with explicit `Host` and `User-Agent` headers
- Added `User-Agent: goog-python-genai/0.1.0` to mimic the working Python client
- See `docs/PHASE_36_ERROR_ANALYSIS.md` for the full "5 Whys" reasoning framework analysis

### Technical Details
- The GFE performs strict protocol fingerprinting and rejects connections that don't "look" like legitimate clients
- Python's `websockets` library automatically sets these headers, but Dart's `web_socket_channel` does not
- This fix adds the import `package:web_socket_channel/io.dart` and uses `IOWebSocketChannel.connect()` with custom headers

---

## [6.0.1] - 2025-12-25 - Phase 35: "ThinkingConfig Hotfix"

### Fixed
- **Gemini Live API Connection:** Fixed a critical bug causing WebSocket connection failure with the error "Unknown name 'thinkingConfig'". The `thinkingConfig` payload was being sent at the wrong level in the setup message. It has been moved inside `generationConfig` to comply with the official Google API schema. [1]

[1]: https://ai.google.dev/api/generate-content#ThinkingConfig

## [6.0.0] - 2025-12-21 - Phase 27: "Voice First Pivot"

### In Progress
- Audio recording implementation for voice interface
- Google OAuth configuration for production

## [6.0.0] - 2025-12-21 - Phase 27: "Voice First Pivot"

### Added - Voice-First Conversational AI Coaching

This release transforms onboarding from text-based to **voice-first conversational AI coaching**.

#### The Core Philosophy
**"Talk to your coach like a friend, not a form."**

Traditional habit apps rely on long forms. The Pact uses **real-time voice** powered by Gemini Live API.

#### New Features

**Voice Interface (Phase 27.5)**
- **VoiceOnboardingScreen**: MVP voice interface with microphone button
- **GeminiLiveService**: WebSocket connection to Gemini Live API
  - Real-time audio streaming (PCM 16-bit)
  - Circuit breaker pattern for graceful degradation
  - Automatic reconnection with exponential backoff
- **Routing Logic**: Premium users → Voice, Free users → Text
- **Supabase Edge Function**: `get-gemini-ephemeral-token` for secure auth

**Developer Tools (Phase 27.6)**
- **DevToolsOverlay**: Comprehensive testing toolkit
  - Triple-tap gesture to open (debug builds only)
  - Toggle Premium Mode (Tier 2) instantly
  - View AI status (tier, availability, kill switches)
  - Quick navigation to any screen
  - Skip Onboarding button for testing
  - Copy Debug Info for bug reports
- **Settings Access**: Gear icon on ALL onboarding screens
  - No need to create a habit first!

**Dev Mode Bypass (Phase 27.7)**
- **Direct API Key Usage**: Voice works without authentication in debug builds
- **Fallback Logic**: If Edge Function fails, use API key directly
- **Testing Friendly**: Rapid iteration without OAuth setup

**Documentation (Phase 27.7)**
- **GOOGLE_OAUTH_SETUP.md**: Complete OAuth configuration guide
  - SHA-1 fingerprint included
  - Step-by-step for Google Cloud Console
  - Supabase provider setup

### Changed

**AI Architecture**
- **Tier 1 (Free)**: DeepSeek-V3 → Text Chat
- **Tier 2 (Premium)**: Gemini 2.0 Flash → **Voice Coach** (NEW)

**Routing**
- Default route now checks `devModePremium` setting
- Premium users routed to `/voice-onboarding`
- Free users routed to `/` (text chat)

**Branding (Phase 27.4)**
- Updated all user-facing text from "Atomic Habits" to "The Pact"
- Conversational onboarding greetings use "The Pact coach"
- Manual onboarding title: "Welcome to The Pact"

**App Icon (Phase 27.4)**
- Replaced default Flutter icon with handshake logo
- Blue-to-pink gradient (brand colors)
- Updated all Android icon sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)

### Fixed

**Critical Bugs (Phase 27.1-27.4)**
- **Ghost Habits**: Fixed habits appearing in dashboard but not in database
- **DeepSeek Routing**: Fixed Tier 1 routing to wrong AI model
- **Error Messages**: Fixed escaped string showing literal `${result.error}`

**Voice Interface (Phase 27.5)**
- Added fallback dialog when voice unavailable
- Improved error handling for connection failures
- Added reconnection logic with exponential backoff

### Technical Details

**New Files**
- `lib/features/onboarding/voice_onboarding_screen.dart` - Voice interface UI
- `lib/data/services/gemini_live_service.dart` - WebSocket voice service
- `lib/features/dev/dev_tools_overlay.dart` - Developer tools
- `supabase/functions/get-gemini-ephemeral-token/index.ts` - Edge Function
- `docs/GOOGLE_OAUTH_SETUP.md` - OAuth setup guide

**Modified Files**
- `lib/main.dart` - Added `/voice-onboarding` route
- `lib/features/settings/settings_screen.dart` - Fixed error messages
- `lib/features/onboarding/conversational_onboarding_screen.dart` - Added Settings icon
- `lib/features/onboarding/onboarding_screen.dart` - Added Settings icon
- `android/app/src/main/res/mipmap-*/ic_launcher.png` - New app icon

**Dependencies**
- No new packages added (uses existing `web_socket_channel`, `supabase_flutter`)

### Breaking Changes

**None** - All changes are backward compatible. Users can still use text chat (Tier 1).

---

## [5.7.0] - 2025-12-17 - Phase 24: "The Red Carpet"

### Added - Zero-Friction Onboarding + Rebrand

**Rebranding: "The Pact"**
- Domain: `thepact.co`
- App Name: "Pact" (iOS + Android)
- Package ID: `co.thepact.app`
- Landing Page: React app deployed to Netlify

**Brain Transplant: AI Refactor**
- **Tier 1 (Default)**: DeepSeek-V3 for reasoning
- **Tier 2 (Premium)**: Claude 3.5 Sonnet for coaching
