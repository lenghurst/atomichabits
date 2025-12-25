# Build Pipeline Guide

**Last Updated:** December 25, 2025
**Phase:** 38+

This document provides single-command build pipelines for The Pact app.

---

## 🎯 Single Command Build Pipeline

```bash
git pull origin main && flutter clean && flutter pub get && flutter build apk --dart-define-from-file=secrets.json && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-debug.apk
```

---

## 🔄 Command Breakdown

| Part | Operator | Purpose |
|------|----------|---------|
| `git pull origin main` | `&&` | Pull latest changes (stops on git error) |
| `flutter clean` | `&&` | Remove build artifacts (stops on clean error) |
| `flutter pub get` | `&&` | Fetch dependencies (stops on pub error) |
| `flutter build apk --dart-define-from-file=secrets.json` | `&&` | Build release APK (stops on build error) |
| `cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-debug.apk` | | Copy final APK to desktop |

---

## 📝 Alternative Versions

### Option A: With Progress Echoes (Recommended)

```bash
echo "🔄 Pulling latest changes..." && git pull origin main && \
echo "🧹 Cleaning build..." && flutter clean && \
echo "📦 Getting dependencies..." && flutter pub get && \
echo "🏗️  Building release APK..." && flutter build apk --dart-define-from-file=secrets.json && \
echo "📤 Copying APK to Desktop..." && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-debug.apk && \
echo "✅ Build complete! APK: ~/Desktop/ThePact-debug.apk"
```

### Option B: Debug Build Version

```bash
git pull origin main && flutter clean && flutter pub get && flutter build apk --debug --dart-define-from-file=secrets.json && cp build/app/outputs/flutter-apk/app-debug.apk ~/Desktop/ThePact-debug.apk
```

> **Note:** Adds `--debug` flag for testing without Supabase auth

### Option C: Shell Function (Add to `~/.bashrc` or `~/.zshrc`)

```bash
build_pact() {
    echo "Starting Pact build pipeline..."
    git pull origin main
    flutter clean
    flutter pub get 
    flutter build apk --dart-define-from-file=secrets.json
    cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-$(date +%Y%m%d_%H%M%S).apk
    echo "Build complete!"
}
```

Then just run: `build_pact`

---

## ⚡ Pro Tips

### 1. Error Handling
The `&&` operator ensures the chain stops if any command fails.

### 2. Timing
Add `time` at the beginning to measure total build duration:

```bash
time git pull origin main && flutter clean && flutter pub get && flutter build apk --dart-define-from-file=secrets.json && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-debug.apk
```

### 3. Parallel Downloads
Add `--parallel` to `pub get` for faster dependency resolution:

```bash
git pull origin main && flutter clean && flutter pub get --parallel && flutter build apk --dart-define-from-file=secrets.json && cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/ThePact-debug.apk
```

---

## 📱 Build Variants

| Variant | Flag | Use Case |
|---------|------|----------|
| Release | (default) | Production, Play Store |
| Debug | `--debug` | Testing voice without auth |
| Profile | `--profile` | Performance profiling |

---

## 🔐 secrets.json Structure

The `secrets.json` file should be in the project root with this structure:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-anon-key",
  "GEMINI_API_KEY": "your-gemini-key",
  "DEEPSEEK_API_KEY": "your-deepseek-key"
}
```

> **Warning:** Never commit `secrets.json` to version control!

---

## 🚀 Quick Reference

| Task | Command |
|------|---------|
| Full rebuild | Option A (with echoes) |
| Quick test | Option B (debug) |
| Automated builds | Option C (shell function) |
| CI/CD | Use GitHub Actions with secrets |
