# Voice Connection Verification Checklist

**Phase:** 46
**Purpose:** Verify Voice Architecture Simplification and OpenAI/Gemini connectivity

---

## 🎯 Success Metric

> **Accurate Latency Results.** If the diagnostics tool works, you should see:
> - ✅ Real latency values for both providers in milliseconds
> - ✅ A calculated recommendation based on network performance
> - ✅ Successful connection logs for both in the console

---

## 📋 Pre-Flight Checklist

Before testing, ensure:

- [ ] `secrets.json` exists in project root with valid `GEMINI_API_KEY` and/or `DEEPSEEK_API_KEY` (OpenAI path)
- [ ] Billing is enabled for both providers
- [ ] Direct WebSocket connection is used (Supabase Edge Function path removed)

---

## 🔨 Step 1: Build the App

Run the build pipeline:

```bash
flutter run --debug --dart-define-from-file=secrets.json
```

---

## 🧪 Step 2: Test the Connection (Real Network Diagnostics)

1. **Launch the app** on a device or emulator
2. **Triple-tap** any screen title to open DevTools
3. **Tap "Test Voice Connection"** (outined speed icon)
4. **Result:** A snackbar should appear showing the recommended provider (gemini or openai) based on real latency tests.

---

## 📊 Step 3: Capture Logs

1. **Open DevTools** (triple-tap screen title)
2. **Tap "View Voice Logs"** button (green, terminal icon)
3. **Verify** that both Gemini and OpenAI connection attempts appear in the log buffer with handshake details.

---

## 🔍 Step 4: Analyze Results

### Scenario A: Balanced Success ✅
Logs show successful handshakes for both. Recommendation picks the one with lower latency.

### Scenario B: Provider Failure ⚠️
One provider fails (e.g., missing API key or 403 error). The tool correctly identifies the working provider.

### Scenario C: Both Fail ❌
Total connectivity failure. Check internet and `secrets.json`.

---

## 📝 Log Template for Bug Reports

When reporting issues, include:

```
=== Voice Connection Report ===
Date: [YYYY-MM-DD HH:MM]
App Version: 0.27.6-dev
Phase: 46

--- Connection Logs ---
[Paste logs from In-App Voice Console here]

--- Hardware ---
Device: [e.g., Pixel 7]
OS: [e.g., Android 14]
================================
```
