# Device Testing Protocol (dt.md)
Last Updated: Dec 29, 2025

## 1. Golden Command Chain
Always test on physical hardware using a clean build state to avoid "Stale Native Bridge" errors.

```bash
# Clean, Get, and Run on Target Device
git pull origin main && \
flutter clean && \
flutter pub get && \
flutter run --debug --dart-define-from-file=secrets.json
```

## 2. Core Verification Matrix (Phase 59)

### 2.1. The "Amber Unlock" Test
- **Action**: Speak a complex question to Sherlock.
- **Success Criteria**: The Orb MUST transition from Amber (Thinking) to Purple (Speaking) within 100ms of audio starting.
- **Log Indicators**: `VoiceSessionManager: ⚡ Force-Switching UI to Speaking`.
- **Known Issue (Dec 29)**: Desynchronization observed. UI may flicker or get stuck in Amber if network latency > 200ms.

### 2.2. Interruption Snappiness Test
- **Action**: Tap the microphone button while the AI is speaking.
- **Success Criteria**: Audio MUST cease immediately (<50ms). No "Ghost Echo" or trailing buffer.

### 2.3. Echo Cancellation (AEC) Test
- **Action**: Set device volume to 100%. Speak while the AI is responding.
- **Success Criteria**: The AI should not "hear itself" or respond to its own playback.
- **Implementation**: Uses `flutter_webrtc` anchor on Android to force "Voice Communication" mode.

### 2.4. Safety Gate Test
- **Action**: Try to interrupt the AI within the first 0.1s - 0.4s of it starting to speak.
- **Success Criteria**: The input should be ignored.
- **Log Indicator**: `VoiceSessionManager: 🛡️ Input Ignored (Safety Gate active)`.

## 3. WebSocket Error Recovery (Code 1007)
If the app disconnects with Code 1007:
1. Verify `turns: []` is present in the turn commitment payload (GeminiLiveService.dart).
2. Check that `mime_type` is NOT in the setup handshake if tools are enabled.
3. Check for illegal characters in `secrets.json`.

## 4. Hardware Baseline: Xiaomi Redmi (24115RA8EG)
- **Primary Target**: Focus for all low-latency tuning.
- **Critical Fix**: Requires the "Safety Fuse" (WebRTC Anchor) to force hardware DSP into VOIP mode for reliable AEC.
