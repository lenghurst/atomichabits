# CHANGELOG

All notable changes to The Pact will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
- Multi-model architecture with fallbacks

**The Standard Protocol: Install Referrer API**
- Added `play_install_referrer` package
- Automatic invite acceptance after install
- Hard Bypass routing to WitnessAcceptScreen

**The Trojan Horse: React Landing Page**
- Created `landing_page/` with React + Vite + Tailwind
- OS detection and smart redirects
- Deployed to Netlify with auto-deploy

### Changed

**Deep Link Domain**
- Old: `atomichabits.app`
- New: `thepact.co`

**AI Provider**
- Old: Gemini 2.5 Flash (single model)
- New: DeepSeek-V3 + Claude 3.5 (multi-model)

---

## [5.6.0] - 2025-12-16 - Phase 22: "The Witness"

### Added - Social Accountability Loop

**The Core Loop**
1. Builder completes habit
2. Witness gets instant notification
3. Witness sends High Five (emoji reaction)
4. Builder gets social validation dopamine hit
5. If drifting: Witness can send preemptive nudge

**New Features**
- **WitnessService**: Real-time accountability relationship management
- **WitnessEvent Model**: Comprehensive event system
- **High Five System**: Quick emoji reactions
- **Witness Dashboard**: Central hub for accountability
- **Deep Link Integration**: Seamless invite flow
- **Enhanced Notifications**: Witness-specific channels

---

## [5.0.0] - 2025-12-10 - Phase 15: "Identity Foundation"

### Added - Anonymous-First Auth + Cloud Sync

**Authentication**
- Anonymous login (default)
- Email/password upgrade
- Google Sign-In upgrade
- Supabase integration

**Cloud Sync**
- Automatic backup to Supabase
- Conflict resolution (last-write-wins)
- Guest data warning banner

---

## [4.0.0] - 2025-12-01 - Phase 10-14: Analytics & Intelligence

### Added

**Analytics Dashboard**
- Graceful Consistency charts
- Completion rate trends
- Milestone tracking

**Pattern Detection**
- AI-powered insight cards
- Miss event tracking
- Recovery suggestions

**Habit Stacking**
- Chain Reaction prompts
- Stack detection
- Momentum building

---

## [3.0.0] - 2025-11-15 - Phase 7-9: AI & Widgets

### Added

**Weekly Review with AI**
- AI-powered weekly insights
- Personalized recommendations
- Progress summaries

**Home Screen Widgets**
- One-tap habit completion
- Android + iOS support
- Real-time sync

---

## [2.0.0] - 2025-11-01 - Phase 4-6: Multi-Habit & Polish

### Added

**Multi-Habit Engine**
- CRUD operations for multiple habits
- Focus Mode (swipe between habits)
- Dashboard with habit cards

**History & Calendar**
- Calendar view with completion dots
- Stats and milestones
- Historical data

**Settings & Polish**
- Theme toggle (light/dark)
- Notification settings
- Sound and haptics controls

---

## [1.0.0] - 2025-10-15 - Phase 1-3: Foundation

### Added - Core Habit Tracking

**Single Habit Tracking**
- Identity-based onboarding
- Graceful Consistency metrics
- Never Miss Twice recovery engine

**AI Suggestions**
- Local heuristics
- Async remote fallback
- Magic Wand auto-fill

**Atomic Habits Framework**
- Temptation bundling
- Pre-habit rituals
- Environment design
- Daily notifications

---

## Version History Summary

| Version | Date | Phase | Key Feature |
|---------|------|-------|-------------|
| **6.0.0** | 2025-12-21 | 27 | Voice First Pivot |
| 5.7.0 | 2025-12-17 | 24 | The Red Carpet + Rebrand |
| 5.6.0 | 2025-12-16 | 22 | The Witness (Social) |
| 5.0.0 | 2025-12-10 | 15 | Identity Foundation (Auth) |
| 4.0.0 | 2025-12-01 | 10-14 | Analytics & Intelligence |
| 3.0.0 | 2025-11-15 | 7-9 | AI & Widgets |
| 2.0.0 | 2025-11-01 | 4-6 | Multi-Habit & Polish |
| 1.0.0 | 2025-10-15 | 1-3 | Foundation |

---

## Semantic Versioning

- **Major** (X.0.0): Breaking changes, new architecture
- **Minor** (0.X.0): New features, backward compatible
- **Patch** (0.0.X): Bug fixes, minor improvements

---

**Last Updated:** December 21, 2025  
**Current Version:** 6.0.0 (Phase 27.7)  
**Next Version:** 6.1.0 (Phase 27.8 - Audio Recording)
