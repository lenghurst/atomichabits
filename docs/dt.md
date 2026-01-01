# Device Testing Protocol (dt.md)
> **Primary Source of Truth for Physical Device Verification.**
> *replaces DEVICE_TESTING.md and VERIFICATION_CHECKLIST.md*

## 🚨 The Golden Command Chain (GCC)

When the user says **"run gcc"**, they are instructing the AI Agent to execute the following strictly defined process:

1.  **Commit to Main** (CRITICAL):
    *   The Agent MUST commit all current changes to the `main` branch *before* running any build commands.
    *   This ensures version control safety and a clean state for the pull operation.
2.  **Execute Command**:
    ```bash
    git pull origin main && flutter clean && flutter pub get && flutter run --debug --dart-define-from-file=secrets.json
    ```
3.  **Monitor Build**: Wait for the Gradle/Xcode build to complete.
4.  **Handle Installation**:
    *   **Xiaomi Devices**: The Agent must explicitly warn the user to **watch their phone screen** for the "Install via USB" prompt and tap "Allow".
5.  **Live Logging**: Once launched, the Agent must monitor and stream the stdout logs for relevant tags.

**Agent Response Template (Chain of Thought):**
> "Initiating Golden Command Chain (GCC)...
>
> 1.  **Committing Changes**: [Status: Done] - Secured latest work to `main`.
> 2.  **Environment Sync**: [Status: Running] - Pulling, Cleaning, and Resolving Dependencies...
> 3.  **Build & Install**: [Status: Pending] - Building APK for [Device Name].
>
> **ACTION REQUIRED:** Please unlock your device and tap 'Allow' / 'Install' if prompted.
>
> **Live Logs:** Streaming application output..."

---

## 1. Prerequisites

*   **Physical Device:** Android (Developer Mode ON) or iOS Device.
*   **Connection:** USB Cable (preferred) or WiFi Debugging.
*   **Secrets:** `secrets.json` must exist in the project root with valid API keys.
*   **Agent Responsibility:** The device is physically connected to the host. The Agent executes commands on the host.

---

## 2. Hotfix Workflow (Live Coding)

Once the app is running via GCC, use these keys in the terminal (or ask the Agent) to update without rebuilding:

| Key | Action | Use Case |
| :---: | :--- | :--- |
| **`r`** | **Hot Reload** | UI changes, logic tweaks within methods. Preserves app state. |
| **`R`** | **Hot Restart** | App initialization changes (`main()`, Providers). Resets app state. |
| **`d`** | **Detach** | Stop listening but keep app running. |
| **`q`** | **Quit** | Stop the app. |

---

## 3. Verification Matrices

### 3.1. Phase 59: Voice Protocol (Golden Path)

**Core Objective:** Verify Ultra-Low Latency Audio & "Unified Source of Truth" State.

#### A. The "Amber Unlock" Test
*   **Action**: Speak a complex question to Sherlock.
*   **Success Criteria**: The Orb MUST transition from Amber (Thinking) to Purple (Speaking) **immediately** when audio data arrives.
*   **Log Verification**:
    1. `StreamVoicePlayer: [TRACE] 📥 Chunk Received` (Audio arrived)
    2. `StreamVoicePlayer: [TRACE] State Update -> true` (UI signaled to switch)
    3. `VoiceSessionManager: 🗣️ Player Reported Speaking` (UI switching)
    *   **Pass**: All 3 logs appear within ~10-20ms of each other.
    *   **Fail**: Log 3 appears significantly later than Log 1.

#### B. Interruption Snappiness
*   **Action**: Tap the microphone button while the AI is speaking.
*   **Success Criteria**: Audio MUST cease immediately (<50ms). No "Ghost Echo" or trailing buffer.

#### C. Echo Cancellation (AEC)
*   **Action**: Set device volume to 100%. Speak while the AI is responding.
*   **Success Criteria**: The AI should not "hear itself" or respond to its own playback.
*   **Implementation**: Uses `flutter_webrtc` anchor on Android to force "Voice Communication" mode.

#### D. Safety Gate
*   **Action**: Try to interrupt the AI within the first 0.1s - 0.4s of it starting to speak.
*   **Success Criteria**: The input should be ignored.
*   **Log Indicator**: `VoiceSessionManager: 🛡️ Input Ignored (Safety Gate active)`.

### 3.2. Phase 46: Connectivity & Diagnostics

**Objective:** Verify OpenAI/Gemini connectivity and latency.

1.  **Launch App**: Open on device.
2.  **Open DevTools**: Triple-tap any screen title.
3.  **Run Test**: Tap "Test Voice Connection" (speed icon).
4.  **Verify**:
    *   ✅ Real latency values displayed.
    *   ✅ Recommended provider shown.
    *   ✅ Connection logs visible in "View Voice Logs" console.

---

## 4. Troubleshooting & Specifics

### Xiaomi Devices (Redmi, POCO)
*   **Issue**: `INSTALL_FAILED_USER_RESTRICTED`
*   **Fix**: You *must* insert a SIM card (once) to enable "Install via USB" in Developer Options.
*   **Runtime**: The OS will prompt "Install via USB?" every time `flutter run` installs a new APK. You must tap "Allow" within ~5 seconds or the install fails.

### WebSocket Error 1007
*   **Cause**: Invalid payload or mismatched Protocol.
*   **Fix**:
    1. Verify `turns: []` is present in turn commitment.
    2. Ensure `mime_type` is absent in Setup Handshake if tools are active.
    3. Check `secrets.json` for illegal characters.
