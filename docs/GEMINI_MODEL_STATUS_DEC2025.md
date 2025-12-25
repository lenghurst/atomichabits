# Gemini Model Status - December 2025

> **Source:** https://ai.google.dev/gemini-api/docs/changelog
> **Retrieved:** 25 December 2025

## Current Live API Models

### Active Models (December 2025)

| Model Name | Released | Status | Notes |
|------------|----------|--------|-------|
| `gemini-2.5-flash-native-audio-preview-12-2025` | Dec 12, 2025 | ✅ ACTIVE | Latest native audio model for Live API |
| `gemini-2.5-flash-native-audio-preview-09-2025` | Sep 2025 | ✅ ACTIVE | Previous stable version |

### Shut Down Models (DO NOT USE)

| Model Name | Shut Down Date | Replacement |
|------------|----------------|-------------|
| `gemini-2.0-flash-live-001` | Dec 9, 2025 | Use `gemini-2.5-flash-native-audio-preview-12-2025` |
| `gemini-live-2.5-flash-preview` | Dec 9, 2025 | Use `gemini-2.5-flash-native-audio-preview-12-2025` |

## Critical Finding

**Our current config uses:** `gemini-live-2.5-flash-native-audio`

This model name does NOT appear in the official changelog. The **correct model name** from official docs:

```python
# From official Google AI docs (December 2025):
MODEL = "gemini-2.5-flash-native-audio-preview-12-2025"
```

Alternative stable version:
- `gemini-2.5-flash-native-audio-preview-09-2025`

## Action Required

Update `lib/config/ai_model_config.dart`:
```dart
// OLD (potentially incorrect):
static const String tier2Model = 'gemini-live-2.5-flash-native-audio';

// NEW (verified December 2025):
static const String tier2Model = 'gemini-2.5-flash-native-audio-preview-12-2025';
```

## Other December 2025 Updates

- **Dec 17:** Gemini 3 Flash Preview (`gemini-3-flash-preview`) launched
- **Dec 12:** New native audio model released
- **Dec 11:** Interactions API Beta launched
- **Dec 10:** TTS model enhancements
- **Dec 9:** Old Live API models shut down
