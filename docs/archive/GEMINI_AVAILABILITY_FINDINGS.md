# Gemini API Availability Findings (December 25, 2025)

## Regional Availability

**United Kingdom is LISTED as available** ✅

The official docs at https://ai.google.dev/gemini-api/docs/available-regions confirm UK is in the list.

## Model Name Confirmed

From official changelog (December 12, 2025):
> Released `gemini-2.5-flash-native-audio-preview-12-2025`, a new native audio model for the Live API.

**Model name is CORRECT** ✅

## Endpoint Version

From https://ai.google.dev/api/live:
> Note: The URL is for version **v1beta**.

**We fixed this to v1beta** ✅

## Remaining Issues to Check

1. **Endpoint display still shows v1alpha** - User hasn't rebuilt after pull
2. **API Key validity** - Need to verify key format and permissions
3. **ThoughtSignature** - May need to be removed from display or handled differently
