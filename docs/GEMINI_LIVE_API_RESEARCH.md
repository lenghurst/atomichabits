# Gemini Live API Research Notes

**Date:** December 18, 2025  
**Source:** https://ai.google.dev/gemini-api/docs/live-guide

## Critical Findings

### 1. Model Name Correction

**CRITICAL:** The documentation states the correct model name is:
```
gemini-2.5-flash-native-audio-preview-12-2025
```

**NOT** `gemini-3.0-flash-exp` as specified in `AIModelConfig.dart`.

This is a significant discrepancy. The "Gemini 3" branding appears to be marketing terminology, while the actual API model identifier remains in the 2.5 series with native audio capabilities.

### 2. Connection Method

The Live API uses **WebSockets** for bidirectional streaming, accessed via the Google GenAI SDK:

```python
from google import genai

client = genai.Client()
model = "gemini-2.5-flash-native-audio-preview-12-2025"
config = {"response_modalities": ["AUDIO"]}

async with client.aio.live.connect(model=model, config=config) as session:
    # Bidirectional streaming here
```

### 3. Audio Format Requirements

| Direction | Format | Sample Rate | Channels |
|-----------|--------|-------------|----------|
| **Input** | 16-bit PCM, little-endian | 16kHz (native), any supported | Mono |
| **Output** | 16-bit PCM, little-endian | 24kHz | Mono |

MIME type for input: `audio/pcm;rate=16000`

### 4. Key API Methods

- `session.send_realtime_input(audio=msg)` - Send audio chunks
- `session.send_client_content(turns=message, turn_complete=True)` - Send text
- `session.receive()` - Async generator for responses
- `session.send_tool_response(function_responses=...)` - Send function call results

### 5. Native Audio Capabilities (v1alpha)

These features require `api_version: "v1alpha"`:

1. **Affective Dialog** - Emotion-aware responses
   ```python
   config = types.LiveConnectConfig(
       response_modalities=["AUDIO"],
       enable_affective_dialog=True
   )
   ```

2. **Proactive Audio** - Model decides when to respond
   ```python
   config = types.LiveConnectConfig(
       response_modalities=["AUDIO"],
       proactivity={'proactive_audio': True}
   )
   ```

3. **Thinking** - Dynamic reasoning (enabled by default)
   ```python
   config = types.LiveConnectConfig(
       response_modalities=["AUDIO"],
       thinking_config=types.ThinkingConfig(thinking_budget=1024)
   )
   ```

### 6. Voice Activity Detection (VAD)

Built-in VAD handles turn-taking automatically. The model detects when the user stops speaking and begins its response.

### 7. Transcription Support

Both input and output audio can be transcribed:

```python
config = {
    "response_modalities": ["AUDIO"],
    "output_audio_transcription": {},
    "input_audio_transcription": {},
}
```

### 8. Tool Support

| Tool | Supported |
|------|-----------|
| Search | Yes |
| Function calling | Yes |
| Google Maps | No |
| Code execution | No |
| URL context | No |

### 9. Voice Configuration

Voices can be configured via `speech_config`:

```python
config = {
    "response_modalities": ["AUDIO"],
    "speech_config": {
        "voice_config": {"prebuilt_voice_config": {"voice_name": "Kore"}}
    },
}
```

## Implementation Implications for The Pact

### Immediate Actions Required

1. **Update `AIModelConfig.dart`:**
   - Change `tier2Model` from `'gemini-3.0-flash-exp'` to `'gemini-2.5-flash-native-audio-preview-12-2025'`
   - Change `tier3Model` similarly if using Pro variant

2. **Create `GeminiLiveService` for Flutter:**
   - Cannot use Python SDK directly in Flutter
   - Need to use WebSocket connection directly or via Dart package
   - Consider `google_generative_ai` Flutter package capabilities

3. **Audio Pipeline:**
   - Input: 16kHz, 16-bit PCM, mono
   - Output: 24kHz, 16-bit PCM, mono
   - Use Flutter audio packages: `record`, `just_audio`, or platform channels

### Architecture Decision

**Option A: Server-to-Server**
- Flutter app sends audio to backend
- Backend proxies to Gemini Live API
- More secure (API key not in client)
- Higher latency

**Option B: Client-to-Server with Ephemeral Tokens**
- Flutter app connects directly to Gemini
- Use ephemeral tokens for security
- Lower latency (recommended for voice)
- Requires ephemeral token generation endpoint

**Recommendation:** Option B with Supabase Edge Function for ephemeral token generation.

## References

- [Live API Get Started](https://ai.google.dev/gemini-api/docs/live)
- [Live API Capabilities Guide](https://ai.google.dev/gemini-api/docs/live-guide)
- [Tool Use with Live API](https://ai.google.dev/gemini-api/docs/live-tools)
- [Session Management](https://ai.google.dev/gemini-api/docs/live-sessions)
- [Ephemeral Tokens](https://ai.google.dev/gemini-api/docs/live-ephemeral-tokens)


## Ephemeral Tokens (Client-Side Authentication)

**Source:** https://ai.google.dev/gemini-api/docs/ephemeral-tokens

### Overview

Ephemeral tokens are short-lived authentication tokens for accessing the Gemini API through WebSockets. They are designed for **client-to-server** implementations where the mobile app connects directly to Gemini.

### Token Lifecycle

1. Client (Flutter app) authenticates with backend (Supabase)
2. Backend requests ephemeral token from Gemini API
3. Gemini API issues short-lived token
4. Backend sends token to client
5. Client uses token as API key for WebSocket connection

### Token Creation (Server-Side - Python)

```python
import datetime
from google import genai

now = datetime.datetime.now(tz=datetime.timezone.utc)

client = genai.Client(
    http_options={'api_version': 'v1alpha'}
)

token = client.auth_tokens.create(
    config = {
        'uses': 1,  # Single session only
        'expire_time': now + datetime.timedelta(minutes=30),  # Default 30 min
        'new_session_expire_time': now + datetime.timedelta(minutes=1),  # Default 1 min
        'http_options': {'api_version': 'v1alpha'},
    }
)

# Return token.name to client
```

### Locked Configuration (Enhanced Security)

```python
token = client.auth_tokens.create(
    config = {
        'uses': 1,
        'live_connect_constraints': {
            'model': 'gemini-2.5-flash-native-audio-preview-12-2025',
            'config': {
                'session_resumption': {},
                'temperature': 0.7,
                'response_modalities': ['AUDIO']
            }
        },
        'http_options': {'api_version': 'v1alpha'},
    }
)
```

### Client Usage (JavaScript/Dart)

```javascript
const ai = new GoogleGenAI({
    apiKey: token.name  // Use ephemeral token as API key
});

const session = await ai.live.connect({
    model: 'gemini-2.5-flash-native-audio-preview-12-2025',
    config: { responseModalities: ['AUDIO'] },
    callbacks: { ... },
});
```

### Key Constraints

| Parameter | Default | Description |
|-----------|---------|-------------|
| `uses` | 1 | Number of sessions token can start |
| `expire_time` | 30 minutes | Total token lifetime |
| `new_session_expire_time` | 1 minute | Window to start new session |

### Architecture for The Pact

**Recommended Flow:**

1. **Supabase Edge Function:** `create-gemini-token`
   - Authenticates user via Supabase Auth
   - Calls Gemini API to create ephemeral token
   - Returns token to Flutter client

2. **Flutter Client:**
   - Requests token from Edge Function
   - Connects to Gemini Live API via WebSocket
   - Streams audio bidirectionally

3. **Session Resumption:**
   - Sessions timeout after 10 minutes
   - Use `sessionResumption` to reconnect with same token
   - Token remains valid within `expire_time` window

### Security Best Practices

- Set short expiration duration
- Verify backend authentication before issuing tokens
- Lock tokens to specific model/config when possible
- Never expose long-lived API keys client-side


## Flutter/Dart Implementation (Firebase AI Logic SDK)

**Source:** https://firebase.google.com/docs/ai-logic/live-api

### Key Finding: Official Flutter SDK Support

Firebase AI Logic provides **native Dart/Flutter support** for the Gemini Live API. This is the recommended approach for The Pact.

### Model Names by Provider

| Provider | Model Name |
|----------|------------|
| Gemini Developer API | `gemini-2.5-flash-native-audio-preview-12-2025` |
| Vertex AI Gemini API | `gemini-live-2.5-flash-native-audio` |

### Dart Implementation Code

```dart
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:your_audio_recorder_package/your_audio_recorder_package.dart';

// Initialize the Gemini Developer API backend service
// Create a `liveGenerativeModel` instance with a model that supports the Live API
final liveModel = FirebaseAI.googleAI().liveGenerativeModel(
  model: 'gemini-2.5-flash-native-audio-preview-12-2025',
  // Configure the model to respond with audio
  liveGenerationConfig: LiveGenerationConfig(
    responseModalities: [ResponseModalities.audio],
  ),
);

_session = await liveModel.connect();

final audioRecordStream = _audioRecorder.startRecordingStream();
// Map the Uint8List stream to InlineDataPart stream
final mediaChunkStream = audioRecordStream.map((data) {
  return InlineDataPart('audio/pcm', data);
});

await _session.startMediaStream(mediaChunkStream);

// In a separate thread, receive the audio response from the model
await for (final message in _session.receive()) {
  // Process the received message
}
```

### Key SDK Classes

- `FirebaseAI.googleAI()` - Initialize Firebase AI with Google AI backend
- `liveGenerativeModel()` - Create Live API model instance
- `LiveGenerationConfig` - Configure response modalities
- `liveModel.connect()` - Establish WebSocket session
- `session.startMediaStream()` - Stream audio input
- `session.receive()` - Async stream of responses
- `InlineDataPart` - Audio data wrapper with MIME type

### Audio Format Requirements

- **Input:** 16-bit PCM, 16kHz, mono (`audio/pcm`)
- **Output:** 16-bit PCM, 24kHz, mono

### Dependencies Required

```yaml
dependencies:
  firebase_core: ^latest
  firebase_ai: ^latest  # Firebase AI Logic SDK
  # Audio recording package (platform-specific)
```

### Architecture Recommendation for The Pact

**Option 1: Firebase AI Logic (Recommended)**
- Use `firebase_ai` package directly
- Handles WebSocket connection internally
- Integrated with Firebase Auth for security
- No need for custom ephemeral token endpoint

**Option 2: Direct WebSocket + Ephemeral Tokens**
- Create Supabase Edge Function for token generation
- Use `web_socket_channel` package in Flutter
- More control but more complexity
- Better for non-Firebase backends

### Implementation Notes

1. The Firebase AI Logic SDK abstracts the WebSocket complexity
2. Audio streaming uses Dart Streams for reactive programming
3. Response handling is async iterator-based
4. Session management is handled automatically


## Phase 35: `thinkingConfig` Hotfix (2025-12-25)

### Problem: WebSocket Connection Failure

Following the implementation of the `GeminiLiveService`, the WebSocket connection was failing with the following error:

```
Connection Closed During: WAITING_FOR_SERVER_READY
Code: 1006 | Reason: Abnormal Closure
```

And the server logs indicated:

```
Unknown name 'thinkingConfig': Cannot find field.
```

### Investigation

1.  **Initial Hypothesis:** The `thinkingConfig` field name was incorrect (camelCase vs. snake_case) or not supported by the `gemini-2.5-flash-native-audio-preview-12-2025` model.
2.  **Documentation Review:** A thorough review of the official Google AI API documentation for the `BidiGenerateContentSetup` message and `GenerationConfig` object was conducted.
    -   [Live API - WebSockets API reference](https://ai.google.dev/api/live)
    -   [Generating content - `GenerationConfig`](https://ai.google.dev/api/generate-content#generationconfig)
3.  **Critical Finding:** The documentation revealed that `thinkingConfig` is a valid field, but it must be nested **inside** the `generationConfig` object, not at the same level.

### The Fix

The `_sendSetupMessage` method in `lib/data/services/gemini_live_service.dart` was modified to move the `thinkingConfig` object into its correct location within the `generationConfig` map.

**Incorrect Structure (Before):**

```dart
final setupConfig = {
  'setup': {
    'model': '...',
    'generationConfig': {
      // ...
    },
    // WRONG: thinkingConfig at the same level as generationConfig
    'thinkingConfig': {
      'thinkingLevel': 'MINIMAL',
    },
  }
};
```

**Correct Structure (After):**

```dart
final setupConfig = {
  'setup': {
    'model': '...',
    'generationConfig': {
      'responseModalities': ['AUDIO'],
      'speechConfig': { ... },
      // CORRECT: thinkingConfig is nested inside generationConfig
      'thinkingConfig': {
        'thinkingLevel': 'MINIMAL',
      },
    },
    // ...
  }
};
```

### Outcome

This change aligns the WebSocket setup payload with the official API schema, resolving the "Unknown name" error and allowing the connection to be established successfully. The fix was committed and pushed to the `main` branch.

**Commit:** `969cb1d2e1c7f1e6b3f4e1b8a9d9b8e0c8d7f3e1`
