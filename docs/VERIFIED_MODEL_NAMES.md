## Verified Gemini Model Names (December 2025)

**Source:** [Google AI Gemini API Changelog](https://ai.google.dev/gemini-api/docs/changelog)  
**Last Updated:** 23 December 2025  
**Phase:** 27.16 - Voice Service Token & Model Alignment

---

## Current Production Models

| Tier | Purpose | Model Name | Status | Availability |
|------|---------|------------|--------|--------------|
| **Tier 2** | Live API (Voice) | `gemini-live-2.5-flash-native-audio` | **Active (GA)** | Global |
| **Tier 2** | Text Chat | `gemini-2.5-flash` | Stable | Global |
| **Tier 3** | Deep Reasoning | `gemini-2.5-pro` | Stable | Global |
| **Preview** | Frontier | `gemini-3-flash-preview` | Preview (Dec 17, 2025) | Limited |

---

## Live API Model Names: Developer API vs Vertex AI

**CRITICAL:** There are **two different model names** for the Live API depending on which Google API you're using:

| API Provider | Model Name | Availability | Use Case |
|--------------|------------|--------------|----------|
| **Gemini Developer API** | `gemini-2.5-flash-native-audio-preview-12-2025` | US-only (Preview) | Direct API access with API key |
| **Vertex AI / Supabase** | `gemini-live-2.5-flash-native-audio` | Global (GA) | Enterprise/production deployments |

### Our Implementation

**The Pact uses**: `gemini-live-2.5-flash-native-audio` (Vertex AI style)

**Reason**: 
- ✅ Globally available (UK, US, and other regions)
- ✅ General Availability (GA) - more stable than preview
- ✅ Works with Supabase Edge Functions for ephemeral token generation
- ✅ Aligned with backend configuration in `get-gemini-ephemeral-token/index.ts`

**Configuration Locations:**
- **Frontend**: `lib/config/ai_model_config.dart:73`
- **Backend**: `supabase/functions/get-gemini-ephemeral-token/index.ts:30`

---

## Deprecated/Shutdown Models (DO NOT USE)

| Model Name | Shutdown Date | Replacement |
|------------|---------------|-------------|
| `gemini-2.0-flash-live-001` | December 9, 2025 | `gemini-live-2.5-flash-native-audio` |
| `gemini-live-2.5-flash-preview` | December 9, 2025 | `gemini-live-2.5-flash-native-audio` |
| `gemini-2.5-flash-image-preview` | January 15, 2026 | `gemini-2.5-flash` |
| `gemini-2.5-flash-native-audio-preview-12-2025` | Not deprecated, but US-only | `gemini-live-2.5-flash-native-audio` (for global) |

---

## Key Findings

### 1. Marketing vs Technical Reality

- **Marketing Name**: "Gemini 3 Flash"
- **Technical Name (Preview)**: `gemini-3-flash-preview` (not stable, limited availability)
- **Technical Name (Production)**: `gemini-2.5-flash` (stable, recommended)
- **For Live API Production**: Use `gemini-live-2.5-flash-native-audio` (GA, global)

### 2. Live API Native Audio Evolution

| Version | Model Name | Status |
|---------|------------|--------|
| September 2025 | `gemini-live-2.5-flash-preview` | ❌ Deprecated (Dec 9, 2025) |
| December 2025 (Preview) | `gemini-2.5-flash-native-audio-preview-12-2025` | ⚠️ US-only |
| December 2025 (GA) | `gemini-live-2.5-flash-native-audio` | ✅ **Current (Global)** |

### 3. Frontend-Backend Alignment (Critical)

**IMPORTANT:** The frontend model name **MUST match** the backend model name, otherwise ephemeral token authentication will fail.

**Current Alignment:**
```dart
// Frontend (lib/config/ai_model_config.dart:73)
static const String tier2Model = 'gemini-live-2.5-flash-native-audio';
```

```typescript
// Backend (supabase/functions/get-gemini-ephemeral-token/index.ts:30)
const LIVE_API_MODEL = 'gemini-live-2.5-flash-native-audio'
```

✅ **Status**: Aligned correctly as of Phase 27.16

### 4. Architecture Decisions

- ✅ **Approved "Split Brain" Architecture**: DeepSeek (Tier 1) + Gemini (Tier 2/3)
- ❌ **Claude References Removed**: No Anthropic dependency in production code
- ✅ **Global Availability**: Using GA model ensures worldwide access

---

## Testing & Verification

### How to Verify Model Name

1. **Check Frontend Configuration:**
   ```bash
   grep "tier2Model" lib/config/ai_model_config.dart
   ```
   Expected: `gemini-live-2.5-flash-native-audio`

2. **Check Backend Configuration:**
   ```bash
   grep "LIVE_API_MODEL" supabase/functions/get-gemini-ephemeral-token/index.ts
   ```
   Expected: `gemini-live-2.5-flash-native-audio`

3. **Verify Alignment:**
   Both should return the same model name.

### Common Errors

| Error Message | Cause | Solution |
|---------------|-------|----------|
| `models/gemini-2.5-flash-native-audio-preview-12-2025 is not found for API version v1alpha` | Frontend using preview model, backend using GA model | Align frontend with backend |
| `Token is null: No Supabase session` | User not logged in and no dev API key | Log in or add GEMINI_API_KEY to secrets.json |
| `HANDSHAKE_TIMEOUT` | Model mismatch or invalid token | Check frontend-backend alignment |

---

## References

- [Google AI Gemini API Changelog](https://ai.google.dev/gemini-api/docs/changelog)
- [Gemini Live API Documentation](https://ai.google.dev/gemini-api/docs/live)
- [Firebase AI Logic (Flutter SDK)](https://firebase.google.com/docs/ai-logic)
- Internal: `docs/GEMINI_LIVE_API_RESEARCH.md`

---

## Change Log

| Date | Phase | Change |
|------|-------|--------|
| 19 Dec 2025 | Initial | Created with preview model name |
| 23 Dec 2025 | 27.16 | Updated to GA model name, added API provider distinction |
