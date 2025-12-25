# Gemini Model Research - December 2025

> **Date:** 24 December 2025  
> **Source:** [Gemini API Models Documentation](https://ai.google.dev/gemini-api/docs/models)

---

## Key Finding: The Model Name is Correct

**CRITICAL DISCOVERY:** The model name `gemini-2.5-flash-native-audio-preview-12-2025` **IS STILL VALID** according to the official Gemini API documentation.

### Evidence

From the Gemini API documentation (accessed 24 December 2025):

**Gemini 2.5 Flash Live**

| Property | Value |
|----------|-------|
| **Model code** | `gemini-2.5-flash-native-audio-preview-12-2025` |
| **Supported data types** | Inputs: Audio, video, text<br>Output: Audio and text |
| **Input token limit** | 131,072 |
| **Output token limit** | 8,192 |
| **Live API** | Supported |
| **Function calling** | Supported |
| **Thinking** | Supported |
| **Latest update** | September 2025 |
| **Knowledge cutoff** | January 2025 |

### Available Versions

- **Preview:** `gemini-2.5-flash-native-audio-preview-12-2025` (December 2025 version)
- **Preview:** `gemini-2.5-flash-native-audio-preview-09-2025` (September 2025 version)

---

## Revised Hypothesis: Root Cause Analysis

Given that the model name is correct and still supported, the handshake timeout must be caused by something else.

### New Hypothesis 1: Endpoint Version Mismatch (HIGH PROBABILITY)

**Evidence:**
- The error log shows the endpoint is `v1beta`.
- The Gemini 2.5 Flash Live model was last updated in September 2025.
- The handshake protocol may have changed between `v1beta` and newer versions.

**Likelihood:** 90%

### New Hypothesis 2: Handshake Payload Format Error (HIGH PROBABILITY)

**Evidence:**
- The connection succeeds (92ms), so the endpoint is reachable.
- The handshake is sent (9ms), so the client is sending data.
- The server never responds with `setupComplete`, suggesting it's rejecting the handshake silently.
- This is consistent with a malformed handshake payload.

**Likelihood:** 85%

### New Hypothesis 3: Missing or Incorrect Configuration Fields (MEDIUM PROBABILITY)

**Evidence:**
- The error log shows `ThoughtSignature: none`, which suggests the thought signature is not being captured or sent correctly.
- Gemini 3 models require specific configuration fields (e.g., `thinking_level`, `thinking_config`).
- If these fields are missing or incorrectly formatted, the server may reject the handshake.

**Likelihood:** 70%

---

## Recommended Action Plan (Revised)

### Immediate Fixes (Priority 1)

1. **Add debug logging for the exact handshake payload being sent.**
   - Log the full JSON payload before sending it to the server.
   - Compare it to the official Gemini Live API examples.

2. **Verify the endpoint version.**
   - Check if the `v1beta` endpoint is still supported for the December 2025 model.
   - Try switching to `v1alpha` or `v1` if available.

3. **Verify the handshake payload format.**
   - Ensure all required fields are present (`model`, `generation_config`, `thinking_config`, etc.).
   - Ensure the `thinking_level` is set to `"MINIMAL"` (not `"minimal"`).
   - Ensure no deprecated fields (e.g., `temperature`) are included.

### Short-Term Improvements (Priority 2)

4. **Test with the September 2025 model as a fallback.**
   - Try `gemini-2.5-flash-native-audio-preview-09-2025` to see if it works.
   - If it does, the issue is specific to the December 2025 model.

5. **Add more granular logging to the `GeminiLiveService`.**
   - Log every WebSocket message received from the server.
   - Log the exact timing of each phase.

---

## Next Steps

1. **Read the `gemini_live_service.dart` file** to inspect the handshake payload.
2. **Add debug logging** to capture the exact JSON being sent.
3. **Test the fix** on a physical device.
4. **Update this document** with the results.
