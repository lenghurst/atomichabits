# HANDOFF PROMPT — Phase 27.8 Continuation

> **Date:** December 21, 2025  
> **Last Commit:** af9db32  
> **Status:** 🔴 BLOCKED - WebSocket Connection Failing  
> **Priority:** CRITICAL - NYE 2025 Launch Blocker

---

## 🚨 IMMEDIATE CONTEXT

**The Problem:** Voice interface WebSocket connection establishes but immediately closes.

**What We've Tried:**
1. ✅ Fixed WebSocket endpoint from REST API to BidiGenerateContent (commit af9db32)
2. ✅ Changed token parameter from `key=` to `access_token=`
3. ✅ Restored `models/` prefix in setup message
4. ✅ Deployed Supabase Edge Function for ephemeral tokens
5. ✅ Set GEMINI_API_KEY secret in Supabase
6. ✅ Added dev mode bypass to use API key directly (no auth required)

**Current Behavior:**
- Connection establishes (status: "Voice coach connected")
- Immediately closes (error: "Connection lost")
- Reconnects automatically
- Cycle repeats indefinitely

**User's Last Test:** APK built from commit `746f41f` (BEFORE the WebSocket fix)
- User needs to rebuild APK from commit `af9db32` to test the fix

---

## 📋 YOUR MISSION

### Primary Objective
**Fix the WebSocket connection so it stays open and can stream audio.**

### Step-by-Step Plan

#### 1. Verify User Has Latest Code
```bash
cd ~/atomichabits
git log --oneline -1
# Should show: af9db32 Phase 27.8: Fix Gemini Live API WebSocket Endpoint
```

If not, user needs to `git pull`.

#### 2. Rebuild APK
```bash
flutter build apk --debug --dart-define-from-file=secrets.json
```

#### 3. Test Voice Interface
- Install new APK
- Go to Settings → Developer Settings → Enable "Premium (Tier 2)"
- Tap "AI Coach" → Should route to Voice Coach
- Observe connection behavior

#### 4. If Still Failing, Debug Systematically

**A. Check WebSocket URL Format**
- File: `lib/data/services/gemini_live_service.dart`
- Line 700: `_buildWebSocketUrl()`
- Expected: `wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?access_token={token}`

**B. Check Setup Message Format**
- File: `lib/data/services/gemini_live_service.dart`
- Line 708: `_sendSetupMessage()`
- Expected model format: `models/gemini-2.0-flash-exp`
- Check if `responseModalities: ['AUDIO']` is correct

**C. Check Token Generation**
- In dev mode, token should be the Gemini API key directly
- Check line 680-695: `_getEphemeralToken()`
- Verify `kDebugMode` check is working

**D. Add Detailed Logging**
Add debug prints to see what's happening:
```dart
// In _handleMessage (line 741)
debugPrint('GeminiLiveService: Received message: $message');

// In _handleDisconnection (line ~220)
debugPrint('GeminiLiveService: Disconnected. Code: ${closeCode}, Reason: ${closeReason}');
```

**E. Check Gemini API Documentation**
- URL: https://ai.google.dev/api/live
- Verify our WebSocket URL matches their spec
- Check if `access_token` parameter is correct (might be `key` or in Authorization header)

**F. Try Alternative Authentication**
If `access_token` query parameter doesn't work, try Authorization header:
```dart
// In connect() method, add headers to WebSocket connection
_channel = WebSocketChannel.connect(
  Uri.parse(wsUrl),
  headers: {'Authorization': 'Bearer $token'},
);
```

---

## 📁 KEY FILES TO REVIEW

### Critical Files
1. **`lib/data/services/gemini_live_service.dart`** (Voice WebSocket service)
   - Lines 32-36: WebSocket endpoint configuration
   - Lines 698-701: URL builder
   - Lines 704-738: Setup message
   - Lines 741-800: Message handler

2. **`lib/features/onboarding/voice_onboarding_screen.dart`** (Voice UI)
   - Lines 62-90: Connection state handling
   - Lines 200-250: Error handling and fallback

3. **`lib/config/ai_model_config.dart`** (Model configuration)
   - Line 70: `tier2Model` value (should be `gemini-2.0-flash-exp`)
   - Lines 86-98: Live API configuration

### Documentation Files
4. **`docs/GOOGLE_OAUTH_SETUP.md`** (OAuth setup guide)
5. **`AI_CONTEXT.md`** (Current architecture state)
6. **`ROADMAP.md`** (What's blocking, what's next)

---

## 🔍 DEBUGGING CHECKLIST

### Before Making Changes
- [ ] Read `AI_CONTEXT.md` (current state)
- [ ] Read `ROADMAP.md` (known issues)
- [ ] Check latest commit: `git log --oneline -1`
- [ ] Verify user has rebuilt APK from commit `af9db32`

### Debugging Steps
- [ ] Add detailed logging to WebSocket connection
- [ ] Check WebSocket close code and reason
- [ ] Verify token format (should be Gemini API key in dev mode)
- [ ] Test WebSocket URL manually (use online WebSocket tester)
- [ ] Check Gemini API documentation for changes
- [ ] Try alternative authentication methods

### If You Fix It
- [ ] Test voice interface end-to-end
- [ ] Update `AI_CONTEXT.md` with solution
- [ ] Update `ROADMAP.md` (move from "In Progress" to "Completed")
- [ ] Commit with clear message explaining the fix
- [ ] Push to GitHub

### If Still Blocked
- [ ] Document what you tried
- [ ] Update `AI_CONTEXT.md` with new findings
- [ ] Suggest alternative approaches
- [ ] Consider fallback: skip voice for NYE launch, use text chat only

---

## 🎯 SUCCESS CRITERIA

**Voice interface is working when:**
1. ✅ WebSocket connection stays open (no immediate disconnect)
2. ✅ Setup message is accepted by Gemini API
3. ✅ Connection state shows "Connected" without errors
4. ✅ No reconnection loop

**Next steps after WebSocket works:**
1. Implement audio capture (microphone permissions)
2. Stream audio to Gemini via WebSocket
3. Play back audio responses
4. Test end-to-end voice flow

---

## 🚩 RED FLAGS

**If you see these, stop and ask user:**
1. User hasn't rebuilt APK from commit `af9db32`
2. Gemini API key is invalid or expired
3. Gemini Live API has changed endpoints/format
4. WebSocket library has compatibility issues

---

## 📞 CONTEXT FOR USER

**What Oliver Knows:**
- Voice interface is critical for NYE launch
- WebSocket connection is failing despite endpoint fix
- User has latest code (commit af9db32) but hasn't rebuilt APK yet
- Dev mode bypass is working (no auth required)
- Supabase Edge Function is deployed and configured

**What Oliver Needs:**
- Voice interface working ASAP
- Clear explanation of what was wrong and how it was fixed
- Confidence that voice will work for NYE launch

**Oliver's Patience Level:**
- Frustrated but willing to test
- Wants to see progress, not just "try rebuilding again"
- Open to alternative approaches if voice is too complex

---

## 🎁 BONUS POINTS

**If you have time and voice is working:**
1. Implement microphone permissions
2. Add audio capture and streaming
3. Test with real voice input
4. Polish the voice UI (waveform, better status indicators)

**If voice is still blocked:**
1. Propose a fallback plan (text chat only for NYE)
2. Estimate time to fix voice properly
3. Suggest phased rollout (voice for beta users first)

---

## 📚 REFERENCE LINKS

- **Gemini Live API Docs:** https://ai.google.dev/api/live
- **WebSocket Spec:** https://ai.google.dev/gemini-api/docs/live
- **Supabase Project:** https://supabase.com/dashboard/project/lwzvvaqgvcmsxblcglxo
- **GitHub Repo:** https://github.com/lenghurst/atomichabits

---

## 🤝 HANDOFF PROTOCOL

**When you start:**
1. Acknowledge this handoff prompt
2. Confirm you've read AI_CONTEXT.md and ROADMAP.md
3. Ask user if they've rebuilt APK from commit `af9db32`

**When you finish:**
1. Update AI_CONTEXT.md with changes
2. Update ROADMAP.md with progress
3. Commit all changes to main branch
4. Report to user: "Session complete. Changes pushed. Docs updated."

---

**Good luck! 🚀**

_— Previous AI Agent (Manus Session, Dec 21 2025)_
