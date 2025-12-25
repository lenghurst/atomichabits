# Voice Coach Validation Protocol

> **Created:** 24 December 2025  
> **Updated:** 25 December 2025 (Oliver Backdoor implemented)  
> **Purpose:** End-to-end validation of Voice Coach (Tier 2) feature  
> **Target User:** oliver.longhurst@gmail.com  
> **Oliver Backdoor:** ✅ ACTIVE (auto-grants Tier 2 access)  
> **Language:** UK English

---

## Overview

The Voice Coach (Tier 2) feature sits behind two gates:

1. **Authentication** — Supabase/Google Sign-In
2. **Authorisation** — Premium/Tier 2 Status

This document provides the validation protocol to verify the end-to-end flow.

---

## Step 1: The "Auth Check" (The Bouncer)

**Expert:** The Security Auditor (AuthService)

Before testing the UI, verify the plumbing. Google Sign-In is fragile because it depends on SHA-1 keys in the Supabase/Google Cloud console matching your local debug keystore.

### Action: Run the Diagnostic Tool

```bash
flutter run lib/tool/diagnose_google_signin.dart
```

### What to Look For

The tool will guide you through:

1. **Package Name:** `co.thepact.app`
2. **Debug Keystore Location:** `~/.android/debug.keystore`
3. **SHA-1 Extraction Command:**
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
4. **Alternative (Gradle):**
   ```bash
   cd android && ./gradlew signingReport
   ```

### Verification

Ensure the SHA-1 fingerprint exists in:

- **Supabase Dashboard:** Authentication → Providers → Google
- **Google Cloud Console:** APIs & Services → Credentials → OAuth 2.0 Client IDs

If they don't match, the user will fail to log in with `PlatformException(sign_in_failed)`.

### Google Sign-In Configuration Checklist

| Location | Field | Value |
|----------|-------|-------|
| **secrets.json** | GOOGLE_WEB_CLIENT_ID | Web Client ID from Google Cloud |
| **Google Cloud** | Web Client redirect URI | `https://lwzvvaqgvcmsxblcglxo.supabase.co/auth/v1/callback` |
| **Google Cloud** | Android Client package name | `co.thepact.app` |
| **Google Cloud** | Android Client SHA-1 | Your debug keystore SHA-1 |
| **Supabase** | Client ID | Web Client ID (not Android!) |
| **Supabase** | Client Secret | Web Client Secret |
| **Supabase** | Authorised Client IDs | Android Client ID |

**Important:** The Supabase "Client ID" field takes the **Web** Client ID. The "Authorised Client IDs" field takes the **Android** Client ID.

---

## Step 2: The "Tier 2" Bypass (The VIP Pass)

**Expert:** The Architect (Atlas)

You are in a "Chicken and Egg" situation: You want to test the Voice Coach (Tier 2), but you likely haven't paid via the App Store in debug mode.

### Option A: Dev Tools Overlay (Recommended)

1. Navigate to the **Settings Screen**
2. Look for **"Developer Settings"** tile (often at the bottom)
3. If hidden: Tap the **app version number 7 times**
4. Inside Dev Tools, toggle **"Premium Mode (Tier 2)"** ON

### Option B: Triple-Tap Activation

Triple-tap on any screen title to open the Dev Tools overlay.

### Option C: Oliver Backdoor (✅ ALREADY IMPLEMENTED)

The Oliver Backdoor is **already active** in `lib/data/providers/user_provider.dart`:

```dart
// Phase 34.3: Oliver Backdoor for Tier 2 Verification
bool get isPremium {
  try {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser?.email == 'oliver.longhurst@gmail.com') {
      return true;
    }
  } catch (_) {}
  return _isPremium;
}
```

**⚠️ TODO: REMOVE BEFORE PRODUCTION DEPLOYMENT**

**Cleanup Command:**
```bash
grep -rn 'oliver.longhurst' lib/
```

---

## Step 3: The User Journey Walkthrough

**Expert:** The Domain Modeler (Domaina)

To verify the flow for `oliver.longhurst@gmail.com`, follow this exact "Happy Path":

### 3.1 Launch App

Ensure you are on the **"Hook Screen"** ("I want to become...").

### 3.2 Identity Gate

Select an Identity (e.g., "Athlete").

### 3.3 Auth Screen

1. Tap **"Sign in with Google"**
2. Select `oliver.longhurst@gmail.com`
3. **Success Indicator:** You land on the Dashboard or Onboarding

### 3.4 Tier Selection

- If you hit the `PactTierSelectorScreen`, you will see "Free" vs "Premium"
- **CRITICAL:** If you applied the Dev Tools toggle, the app might auto-detect you as Premium
- If not, tap **"Restore Purchase"** or use the Dev Tools toggle

### 3.5 Access Voice Coach

1. Navigate to the **Voice Coach Screen** (Microphone Icon)
2. **Verification:** If the screen loads and you see the "Listening" orb/UI, Tier 2 is active
3. **Failure Mode:** If you see a "Locked" or "Upgrade to Access" banner, the VIP Pass (Step 2) failed

---

## Step 4: Smoke Test Checklist

| Test | Expected Result | Status |
|------|-----------------|--------|
| Google Sign-In | Successful authentication | ☐ |
| Tier 2 Access | Voice Coach screen loads | ☐ |
| Voice Latency | Response < 500ms | ☐ |
| Context Memory | AI remembers previous conversation | ☐ |
| Background Security | Audio stops when app backgrounded | ☐ |

---

## Step 5: Post-Verification Cleanup

**Expert:** The Clean Coder (Uncle Bob)

Once Oliver has verified the flow:

1. **Revert** any hardcoded `if (email == ...)` check in UserProvider
2. **Keep** the `diagnose_google_signin.dart` tool — it's invaluable for future team members
3. **Document** any issues found in this file

---

## Troubleshooting

### PlatformException(sign_in_failed)

**Cause:** SHA-1 mismatch between local keystore and cloud config

**Solution:**
1. Run `keytool` command to get SHA-1
2. Copy to Supabase Dashboard → Auth → Google
3. Copy to Google Cloud Console → OAuth Client
4. Rebuild app

### Voice Coach Shows "Locked"

**Cause:** Premium/Tier 2 status not set

**Solution:**
1. Open Dev Tools (triple-tap or Settings)
2. Toggle "Premium Mode (Tier 2)" ON
3. Navigate to Voice Coach again

### Audio Not Working

**Cause:** Missing permissions

**Solution:**
1. Check `AndroidManifest.xml` has `RECORD_AUDIO` permission
2. Grant microphone permission when prompted
3. Restart app if needed

---

## Files Referenced

| File | Purpose |
|------|---------|
| `lib/tool/diagnose_google_signin.dart` | SHA-1 diagnostic tool |
| `lib/features/dev/dev_tools_overlay.dart` | Tier 2 bypass toggle |
| `lib/data/providers/user_provider.dart` | Premium status logic |
| `lib/features/onboarding/voice_coach_screen.dart` | Voice Coach UI |

---

## Council of Five Attribution

| Expert | Contribution |
|--------|--------------|
| **Security Auditor** | Auth Check protocol |
| **Atlas (Architect)** | Tier 2 bypass strategy |
| **Domaina (Domain Modeler)** | User journey walkthrough |
| **Uncle Bob (Clean Coder)** | Cleanup protocol |
