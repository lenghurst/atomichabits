# Device Testing & Hotfix Workflow

> **Purpose:** Standard procedure for running the app on a physical device to verify features (like Voice AI) that don't work on simulators, and applying code changes in real-time.

## 1. Prerequisites

- **Physical Device:** Android (Developer Mode ON) or iOS Device.
- **Connection:** USB Cable (preferred) or WiFi Debugging.
- **Secrets:** `secrets.json` must exist in the project root.

## 2. The "Golden" Build Command

Use this single command to ensure a clean state, fresh dependencies, and correct configuration before launching.

```bash
git pull origin main && flutter clean && flutter pub get && flutter run --debug --dart-define-from-file=secrets.json
```

**Breakdown:**
1.  `git pull origin main`: Ensures you are on the latest code.
2.  `flutter clean`: Removes stale build artifacts (critical for native crashes).
3.  `flutter pub get`: Refreshes dependencies.
4.  `flutter run --debug`: Runs in Debug mode (allows Hot Reload/Restart).
5.  `--dart-define-from-file=secrets.json`: Injects API keys safely.

## 3. Applying Hotfixes (Hot Reload/Restart)

Once the app is running in the terminal session, you can update the code without rebuilding.

| Key | Action | Use Case |
| :---: | :--- | :--- |
| **`r`** | **Hot Reload** | UI changes, logic tweaks within methods. Preserves app state. |
| **`R`** | **Hot Restart** | App initialization changes (`main()`, `initState`, Providers, Global Variables). Resets app state. |
| **`d`** | **Detach** | Stop listening but keep app running (logs stop). |
| **`q`** | **Quit** | Stop the app. |

## 4. Debugging via Logs

To see custom logs (like `[VERIFY]` tags):

1.  **Terminal:** standard output shows `debugPrint` and `print` statements.
2.  **DevTools Overlay:** Triple-tap the screen title in the app to open the internal log console.

## 5. Troubleshooting Connection

- **Device not found?** Run `flutter devices` to check visibility.
- **Build fails?** Verify `secrets.json` syntax and native build requirements (Xcode/Gradle).
- **Audio issues?** Check `AI_CONTEXT.md` > "Audio Playback" section for speaker enforcement logic.
