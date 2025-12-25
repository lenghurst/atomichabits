# Gemini Live Connection Verification Checklist

**Phase:** 38+
**Purpose:** Verify the 403 Forbidden fix is working

---

## 🎯 Success Metric

> **The error should CHANGE.** If the fix works, the "403 Forbidden" at handshake should be replaced by either:
> - ✅ A **successful connection**, OR
> - ⚠️ A **different, later error** (e.g., 400 about generationConfig)

This proves you've passed the GFE's fingerprint check.

---

## 📋 Pre-Flight Checklist

Before testing, ensure:

- [ ] `secrets.json` exists in project root with valid `GEMINI_API_KEY`
- [ ] API key has Gemini API enabled in Google Cloud Console
- [ ] Billing is enabled on the Google Cloud project
- [ ] No VPN or proxy that might cause geo-blocking

---

## 🔨 Step 1: Build the App

Run the full build pipeline:

```bash
git pull origin main && \
flutter clean && \
flutter pub get && \
flutter build apk --debug --dart-define-from-file=secrets.json
```

Or use the debug variant for faster builds:

```bash
flutter run --debug --dart-define-from-file=secrets.json
```

---

## 🧪 Step 2: Test the Connection

1. **Launch the app** on a device or emulator
2. **Triple-tap** any screen title to open DevTools
3. **Enable Premium Mode** (toggle ON)
4. **Navigate to Voice Coach** (tap "Voice Coach" chip)
5. **Tap the microphone button** to trigger connection

---

## 📊 Step 3: Capture Logs

1. **Open DevTools** (triple-tap screen title)
2. **Tap "View Gemini Logs"** button (green, terminal icon)
3. **Tap the copy icon** to copy all logs
4. **Paste logs** for analysis

---

## 🔍 Step 4: Analyze Results

### Scenario A: Success ✅

Logs show:
```
✅ WebSocket handshake successful
✅ Setup complete
```

**Result:** The fix worked! Voice coach is operational.

### Scenario B: Different Error ⚠️

Logs show:
```
✅ WebSocket handshake successful
❌ [Later error about setup/config]
```

**Result:** The 403 fix worked! The new error is a different issue (likely setup payload).

### Scenario C: Still 403 ❌

Logs show:
```
⛔ HANDSHAKE REJECTED: HandshakeException: Connection refused (403)
```

**Result:** The 403 persists. Proceed to Escalation Path.

---

## 🚨 Escalation Path (If 403 Persists)

### Step E1: Verify API Key with curl

Test the API key directly (bypasses Flutter entirely):

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

| Result | Meaning |
|--------|---------|
| JSON with "candidates" | API key works, problem is Flutter networking |
| 403 Forbidden | API key issue (permissions, billing, or invalid) |
| 400 Bad Request | API key works but request format wrong |

### Step E2: Test Pure dart:io WebSocket

If curl works but Flutter fails, the issue is in `web_socket_channel`. Test with raw `dart:io`:

```dart
import 'dart:io';

void testRawWebSocket() async {
  final uri = Uri.parse('wss://generativelanguage.googleapis.com/ws/...');
  final socket = await WebSocket.connect(
    uri.toString(),
    headers: {
      'Host': 'generativelanguage.googleapis.com',
      'User-Agent': 'Dart/3.5 (flutter); co.thepact.app/6.0.4',
    },
  );
  print('Connected: ${socket.readyState}');
}
```

### Step E3: Native MethodChannel (Nuclear Option)

If all else fails, implement platform-native WebSockets:

- **Android:** OkHttp via MethodChannel
- **iOS:** URLSessionWebSocketTask via MethodChannel

This uses Google's own tested network stacks on each platform.

---

## 📝 Log Template for Bug Reports

When reporting issues, include:

```
=== Gemini Live Connection Report ===
Date: [YYYY-MM-DD HH:MM]
App Version: 6.0.4
Phase: 38

--- Device Info ---
Device: [e.g., Pixel 7]
OS: [e.g., Android 14]
Flutter: [e.g., 3.24.0]

--- Connection Logs ---
[Paste logs from In-App Console here]

--- curl Test Result ---
[Paste curl output here]

--- Additional Notes ---
[Any other relevant information]
================================
```

---

## ✅ Verification Complete

Once you've confirmed the connection works (Scenario A or B), the Gemini Live integration is operational. If you hit Scenario C, follow the escalation path and share the results for further diagnosis.
