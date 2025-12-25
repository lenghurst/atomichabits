# Gemini Live API - WebSocket Schema (Official Reference)

**Source:** https://ai.google.dev/api/live
**Date:** December 25, 2025

## Critical Finding

The official `generationConfig` schema does **NOT** include `thinkingBudget` or `thinkingConfig`:

```json
{
  "model": string,
  "generationConfig": {
    "candidateCount": integer,
    "maxOutputTokens": integer,
    "temperature": number,
    "topP": number,
    "topK": integer,
    "presencePenalty": number,
    "frequencyPenalty": number,
    "responseModalities": [string],
    "speechConfig": object,
    "mediaResolution": object
  },
  "systemInstruction": string,
  "tools": [object]
}
```

## Valid Fields in generationConfig

| Field | Type | Notes |
|-------|------|-------|
| candidateCount | integer | |
| maxOutputTokens | integer | |
| temperature | number | ⚠️ Don't use < 1.0 for native audio |
| topP | number | |
| topK | integer | |
| presencePenalty | number | |
| frequencyPenalty | number | |
| responseModalities | [string] | e.g., ["AUDIO"] |
| speechConfig | object | Voice configuration |
| mediaResolution | object | |

## NOT Valid Fields

- ❌ `thinkingConfig` - Causes "Unknown name" error
- ❌ `thinkingBudget` - NOT in official schema (likely SDK-only)
- ❌ `outputAudioTranscription` - May need to be at setup level, not in generationConfig
- ❌ `inputAudioTranscription` - May need to be at setup level, not in generationConfig

## Setup Message Structure

The setup message wraps the config in a `setup` key:

```json
{
  "setup": {
    "model": "models/gemini-2.5-flash-native-audio-preview-12-2025",
    "generationConfig": {
      "responseModalities": ["AUDIO"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Kore"
          }
        }
      }
    },
    "systemInstruction": "..."
  }
}
```

## Recommended Fix (Applied in Phase 34.4d)

Remove ALL non-standard fields from generationConfig:
1. ✅ Removed `thinkingBudget` (not in schema)
2. ✅ Removed `thinkingConfig` (not in schema)
3. ✅ Removed `outputAudioTranscription` (may need different location)
4. ✅ Removed `inputAudioTranscription` (may need different location)
5. ✅ Keep only official fields: responseModalities, speechConfig

## Minimal Working Config (Phase 34.4d)

```json
{
  "setup": {
    "model": "models/gemini-2.5-flash-native-audio-preview-12-2025",
    "generationConfig": {
      "responseModalities": ["AUDIO"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Kore"
          }
        }
      }
    },
    "systemInstruction": {
      "parts": [{"text": "Your system prompt here"}]
    }
  }
}
```
