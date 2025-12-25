# Phase 38: In-App Log Console

**Date:** December 25, 2025
**Status:** Implemented
**Purpose:** Provide full visibility into Gemini Live connection process with one-click debugging

## Overview

Phase 38 implements an In-App Log Console that acts as a "black box recorder" for the Gemini Live connection. This allows developers and testers to:

1. See exactly what's happening during connection attempts
2. Copy all logs with one click for debugging
3. Distinguish between different types of failures

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     LogBuffer (Singleton)                    │
│  lib/core/logging/log_buffer.dart                           │
│  - Stores last 1000 log entries                             │
│  - ValueNotifier for UI updates                             │
│  - add(), clear(), allLogs, addSeparator()                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   GeminiLiveService                          │
│  lib/data/services/gemini_live_service.dart                 │
│  - Logs every connection step                               │
│  - Uses _addDebugLog() which writes to LogBuffer            │
│  - Verbose: headers, URL, status, errors                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   DebugConsoleView                           │
│  lib/features/dev/debug_console_view.dart                   │
│  - Terminal-like UI (VS Code dark theme)                    │
│  - Real-time updates via ValueListenableBuilder             │
│  - Copy All / Clear buttons                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   DevToolsOverlay                            │
│  lib/features/dev/dev_tools_overlay.dart                    │
│  - "View Gemini Logs" button opens DebugConsoleView         │
│  - Access: Triple-tap on any screen title                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Files Created/Modified

### New Files

| File | Purpose |
|------|---------|
| `lib/core/logging/log_buffer.dart` | Centralized log storage singleton |
| `lib/features/dev/debug_console_view.dart` | Terminal-like log viewer widget |
| `docs/PHASE_38_LOG_CONSOLE.md` | This documentation |

### Modified Files

| File | Changes |
|------|---------|
| `lib/data/services/gemini_live_service.dart` | Added LogBuffer integration, verbose logging |
| `lib/features/dev/dev_tools_overlay.dart` | Added "View Gemini Logs" button |
| `CHANGELOG.md` | Added Phase 38 entry |

---

## Log Format

Each log entry follows this format:
```
[HH:mm:ss.SSS] {icon} [Source] Message
```

### Icons

| Icon | Meaning |
|------|---------|
| ℹ️ | Info (normal log) |
| ❌ | Error |
| 🚀 | Starting |
| 🔑 | Authentication |
| ✅ | Success |
| 📡 | Network |
| 🎯 | Target/Model |
| 📋 | Headers |
| ⏳ | Waiting |
| ⛔ | Rejected |
| 🔍 | Diagnostic hint |

### Example Log Output

```
═══════════════ NEW CONNECTION ATTEMPT ═══════════════
[14:32:15.123] ℹ️ [GeminiLive] 🚀 Starting connection sequence...
[14:32:15.124] ℹ️ [GeminiLive] 🔑 Fetching authentication token...
[14:32:15.456] ℹ️ [GeminiLive] ✅ Token acquired (API Key)
[14:32:15.457] ℹ️ [GeminiLive] 🔗 Building WebSocket URL...
[14:32:15.458] ℹ️ [GeminiLive] 📡 Endpoint: wss://generativelanguage.googleapis.com/ws/...
[14:32:15.459] ℹ️ [GeminiLive] 🎯 Model: gemini-2.5-flash-native-audio-preview-12-2025
[14:32:15.460] ℹ️ [GeminiLive] 📋 Headers: {Host: ..., User-Agent: Dart/3.5 (flutter); co.thepact.app/6.0.4}
[14:32:15.461] ℹ️ [GeminiLive] ⏳ Opening WebSocket connection...
[14:32:16.789] ℹ️ [GeminiLive] ✅ WebSocket handshake successful
```

### Error Example

```
[14:32:16.789] ❌ [GeminiLive] ⛔ HANDSHAKE REJECTED: HandshakeException: ...
[14:32:16.790] ❌ [GeminiLive] 🔍 Check: API Key permissions, Billing enabled, or Geo-blocking
```

---

## Usage

### Accessing the Log Console

1. **Triple-tap** on any screen title to open DevToolsOverlay
2. Tap **"View Gemini Logs"** button (green, with terminal icon)
3. The log console opens as a bottom sheet

### Copying Logs for Debugging

1. Open the log console
2. Tap the **copy icon** in the toolbar
3. Paste into a bug report, chat, or email

### Clearing Logs

1. Open the log console
2. Tap the **trash icon** in the toolbar
3. Logs are cleared (useful before a fresh connection attempt)

---

## Integration with Existing Code

The `_addDebugLog()` method in `GeminiLiveService` was updated to also write to `LogBuffer`:

```dart
void _addDebugLog(String entry, {bool isError = false}) {
  // ... existing code ...
  
  // PHASE 38: Also write to centralized LogBuffer for In-App Console
  _logBuffer.add('GeminiLive', entry, isError: isError);
}
```

This ensures backward compatibility with any existing code that uses `debugLog` getter.

---

## Future Enhancements

1. **Filter by source** - Show only GeminiLive, Auth, Network, etc.
2. **Search logs** - Find specific keywords
3. **Export to file** - Save logs to device storage
4. **Log levels** - Debug, Info, Warning, Error
5. **Timestamp toggle** - Show/hide timestamps
