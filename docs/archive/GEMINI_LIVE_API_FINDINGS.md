# Gemini Live API - Key Findings (Dec 25, 2025)

## Error Analysis

**Error Message:**
```
SOCKET_CLOSED
Connection Closed During: WAITING_FOR_SERVER_READY
Code: 1007 | Reason: Invalid JSON payload received.
Unknown name "thinkingConfig" at 'setup': Cannot find field.
Model: gemini-2.5-flash-native-audio-preview-12-2025
Auth: API Key
Endpoint: v1alpha
ThoughtSignature: none
```

## Root Cause

The `thinkingConfig` field we're sending in the setup message is **NOT a valid field** for the WebSocket setup message.

## Official Documentation Findings

From https://ai.google.dev/gemini-api/docs/live-guide:

### Correct Setup Config Structure (Python SDK)

```python
model = "gemini-2.5-flash-native-audio-preview-12-2025"
config = {
    "response_modalities": ["AUDIO"],
    "output_audio_transcription": {},
    "input_audio_transcription": {},
    "speech_config": {
        "voice_config": {"prebuilt_voice_config": {"voice_name": "Kore"}}
    },
}
```

### Thinking Configuration (from docs)

The docs mention thinking is configured via `thinkingBudget` parameter, NOT `thinkingConfig`:

> "The thinkingBudget parameter guides the model on the number of thinking tokens to use when generating a response. You can disable thinking by setting thinkingBudget to 0."

### Key Differences from Our Implementation

| Our Code | Official Docs |
|----------|---------------|
| `thinkingConfig: { thinkingLevel: 'MINIMAL' }` | `thinkingBudget: 0` (to disable) |
| `responseModalities: ['AUDIO']` | `response_modalities: ["AUDIO"]` |
| `outputAudioTranscription: {}` | `output_audio_transcription: {}` |

## WebSocket vs SDK

The official docs use the Python SDK which handles the setup message internally.
Our code sends raw WebSocket JSON which must match the exact protobuf schema.

## Recommended Fix

1. **Remove `thinkingConfig` entirely** - it's not a valid field in the raw WebSocket setup
2. If thinking control is needed, use `thinkingBudget` (but verify exact field name for WebSocket)
3. Keep the config minimal to match official examples

## Minimal Working Config

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
      "parts": [{"text": "..."}]
    },
    "outputAudioTranscription": {},
    "inputAudioTranscription": {}
  }
}
```
