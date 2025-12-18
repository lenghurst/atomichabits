# App Icon Update Guide

> **Status:** Ready for Execution  
> **Tool:** `flutter_launcher_icons` (v0.14.3)  
> **Config:** `flutter_launcher_icons.yaml`

---

## 1. Overview

This guide explains how to update the app icon for **The Pact** across Android, iOS, Web, and Windows. We use the `flutter_launcher_icons` package to automate the generation of all required sizes and formats.

## 2. Configuration Analysis

We have verified the configuration in `flutter_launcher_icons.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/branding/app_icon.png"
  min_sdk_android: 21
  adaptive_icon_background: "#673AB7"
  adaptive_icon_foreground: "assets/branding/app_icon.png"
  remove_alpha_ios: true
  web:
    generate: true
    image_path: "assets/branding/app_icon.png"
    background_color: "#673AB7"
    theme_color: "#673AB7"
  windows:
    generate: true
    image_path: "assets/branding/app_icon.png"
    icon_size: 48
```

**Key Findings:**
- **Source Image:** The tool looks for `assets/branding/app_icon.png`.
- **Adaptive Icons:** Android uses the same image for the foreground with a `#673AB7` (Deep Purple) background.
- **iOS:** Alpha channel is automatically removed (required by Apple).

## 3. Execution Steps (For Manus/Developer)

### Step 1: Replace Source Image
1.  Obtain the new high-resolution icon file (1024x1024 PNG recommended).
2.  Save it to: `assets/branding/app_icon.png`
    *   *Note: This overwrites the existing file.*

### Step 2: Run Generation Command
Execute the following command in the project root:

```bash
flutter pub run flutter_launcher_icons
```

**What this does:**
- Generates `mipmap-*` folders for Android.
- Generates `AppIcon.appiconset` for iOS.
- Generates `icons/` for Web.
- Generates `.ico` for Windows.
- Updates `AndroidManifest.xml` and `Info.plist` references if needed.

### Step 3: Manual Checks (Not covered by automation)
- **Splash Screens:** The package does *not* update splash screens.
    - **Android:** Check `android/app/src/main/res/drawable/launch_background.xml`.
    - **iOS:** Check `LaunchScreen.storyboard` in Xcode.
- **Notification Icons:** Android notification icons (monochrome) are separate.
    - Location: `android/app/src/main/res/drawable/ic_notification.png` (if custom).

## 4. Branch Management

Since this update affects binary assets and platform-specific configuration files across the entire project:

1.  **Commit Changes:**
    ```bash
    git add assets/branding/app_icon.png
    git add android/app/src/main/res/
    git add ios/Runner/Assets.xcassets/AppIcon.appiconset/
    git add web/icons/
    git add windows/runner/resources/
    git commit -m "chore: Update app icon assets"
    ```

2.  **Merge/Cherry-Pick:**
    *   If working on a feature branch, merge this commit into `main`.
    *   If maintaining multiple release branches (e.g., `release/v1.0`), cherry-pick this commit to ensure branding consistency.

---

**Ready to execute?** Just upload the new `app_icon.png` and run the command in Step 2.
