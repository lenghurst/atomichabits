# Google OAuth Setup for The Pact

This guide walks through setting up Google Sign-In for The Pact app with Supabase.

## Prerequisites

- Google Cloud Console account
- Supabase project (ID: `lwzvvaqgvcmsxblcglxo`)
- Your app's SHA-1 fingerprint (see below)

## Your App Details

- **Package Name:** `co.thepact.app`
- **Debug SHA-1:** `C6:B1:B4:D7:93:9B:6B:E8:EC:AD:BC:96:01:99:11:62:84:B6:5E:6A`
- **Debug SHA-256:** `43:7E:05:7C:22:74:44:D8:2F:67:69:B7:21:C8:03:5B:75:20:EA:D6:1A:92:58:5B:06:60:3F:A9:54:B0:1C:9A`

## Step 1: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable the **Google+ API** (or People API)
4. Go to **APIs & Services → Credentials**

### Create OAuth 2.0 Client IDs

You need TWO client IDs:

#### A) Web Client (for Supabase)
1. Click **Create Credentials → OAuth client ID**
2. Application type: **Web application**
3. Name: `The Pact - Supabase`
4. Authorized redirect URIs: 
   - `https://lwzvvaqgvcmsxblcglxo.supabase.co/auth/v1/callback`
5. Click **Create**
6. **Save the Client ID and Client Secret** - you'll need these for Supabase

#### B) Android Client (for the app)
1. Click **Create Credentials → OAuth client ID**
2. Application type: **Android**
3. Name: `The Pact - Android`
4. Package name: `co.thepact.app`
5. SHA-1 certificate fingerprint: `C6:B1:B4:D7:93:9B:6B:E8:EC:AD:BC:96:01:99:11:62:84:B6:5E:6A`
6. Click **Create**

## Step 2: Supabase Dashboard Setup

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/lwzvvaqgvcmsxblcglxo/auth/providers)
2. Find **Google** in the providers list
3. Toggle **Enable Sign in with Google**
4. Enter:
   - **Client ID:** (from Web Client above)
   - **Client Secret:** (from Web Client above)
5. Click **Save**

## Step 3: Configure OAuth Consent Screen

In Google Cloud Console:

1. Go to **APIs & Services → OAuth consent screen**
2. User Type: **External**
3. Fill in:
   - App name: `The Pact`
   - User support email: your email
   - Developer contact: your email
4. Scopes: Add `email` and `profile`
5. Test users: Add your email for testing
6. Click **Save and Continue**

## Step 4: Download google-services.json (Optional)

If you're using Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Add your Android app with package name `co.thepact.app`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

**Note:** For Supabase-only auth, you may not need this file. The `google_sign_in` Flutter package can work with just the OAuth client IDs.

## Step 5: Update Android Configuration

In `android/app/build.gradle.kts`, ensure you have:

```kotlin
defaultConfig {
    applicationId = "co.thepact.app"
    // ... other config
}
```

## Testing

1. Build the app: `flutter build apk --debug --dart-define-from-file=secrets.json`
2. Install on device
3. Go to Settings → Cloud Sync → Sign in with Google
4. Select your Google account
5. You should see "Signed in with Google!" toast

## Troubleshooting - The Five-Axis Problem

When Google Sign-In fails, run the diagnostic tool first:
```bash
dart run tool/diagnose_google_signin.dart
```

### AXIS 1: secrets.json Configuration
- **Symptom**: "Supabase not configured" or immediate failure
- **Check**: Does `secrets.json` exist? Run `ls secrets.json`
- **Fix**: Run `dart run tool/setup_secrets.dart`

### AXIS 2: Web Client ID (Most Common Issue)
- **Symptom**: "Google Sign-In not configured" or idToken is NULL
- **Check**: Is `GOOGLE_WEB_CLIENT_ID` in secrets.json a **WEB** Client ID?
- **CRITICAL**: Must be "Web application" type, NOT "Android" type
- **Fix**:
  1. Go to Google Cloud Console > APIs & Services > Credentials
  2. Find OAuth 2.0 Client ID with type "Web application"
  3. Copy that Client ID to secrets.json

### AXIS 3: Package Name Mismatch
- **Symptom**: ApiException: 10 or silent failure
- **Check**: Package name must be `co.thepact.app` everywhere:
  - `android/app/build.gradle.kts`: applicationId
  - `lib/config/supabase_config.dart`: androidPackageName
  - Google Cloud Console: Android OAuth Client

### AXIS 4: SHA-1 Fingerprint Mismatch
- **Symptom**: Google account picker doesn't appear
- **Check**: Your machine's SHA-1 vs Google Cloud Console
- **Get your SHA-1**: `cd android && ./gradlew signingReport`
- **Fix**: Add your SHA-1 to Google Cloud Console Android OAuth Client

### AXIS 5: OAuth Consent Screen
- **Symptom**: "Access blocked" or consent fails
- **Check**: Is your email in Test Users? (if app is in Testing mode)
- **Fix**:
  1. Google Cloud Console > OAuth consent screen
  2. Add your email to "Test users"
  3. Or publish app for production

### "Google sign-in cancelled"
- User cancelled, or SHA-1 mismatch (AXIS 4)
- Verify SHA-1 matches your debug keystore

### Build Command Error
**WRONG** (missing `&&`):
```bash
flutter pub get flutter build apk --dart-define-from-file=secrets.json
```

**CORRECT**:
```bash
flutter clean && flutter pub get && flutter build apk --dart-define-from-file=secrets.json
```

## Dev Mode Bypass

For testing the voice interface without Google Sign-In:

The app now includes a **DEV MODE BYPASS** that uses the Gemini API key directly when:
- Running a debug build
- User is not authenticated
- Gemini API key is configured

This allows testing the voice interface without setting up Google OAuth.
