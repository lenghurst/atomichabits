## Verified Gemini Model Names (December 2025)

**Source:** [Google AI Gemini API Changelog](https://ai.google.dev/gemini-api/docs/changelog)
**Date Verified:** 19 December 2025

### Current Production Models

| Tier | Purpose | Model Name | Status |
|------|---------|------------|--------|
| **Tier 2** | Live API (Voice) | `gemini-2.5-flash-native-audio-preview-12-2025` | Active (Dec 12, 2025) |
| **Tier 2** | Text Chat | `gemini-2.5-flash` | Stable |
| **Tier 3** | Deep Reasoning | `gemini-2.5-pro` | Stable |
| **Preview** | Frontier | `gemini-3-flash-preview` | Preview (Dec 17, 2025) |

### Deprecated/Shutdown Models (DO NOT USE)

| Model Name | Shutdown Date |
|------------|---------------|
| `gemini-2.0-flash-live-001` | December 9, 2025 |
| `gemini-live-2.5-flash-preview` | December 9, 2025 |
| `gemini-2.5-flash-image-preview` | January 15, 2026 |

### Key Findings

1. **Marketing vs Technical Reality:**
   - Marketing: "Gemini 3 Flash"
   - Technical: `gemini-3-flash-preview` (preview only, not stable)
   - For production Live API: Use `gemini-2.5-flash-native-audio-preview-12-2025`

2. **Live API Native Audio:**
   - The December 2025 release is `gemini-2.5-flash-native-audio-preview-12-2025`
   - This replaces the older September version

3. **No Claude in Architecture:**
   - The approved "Split Brain" architecture uses only DeepSeek and Gemini
   - Claude references must be removed from the codebase
