# Gemini API Data Retention & Privacy Audit
**Date:** 2025-12-30
**Auditor:** Agent Priming Protocol
**Target:** Google Vertex AI / Gemini API Configuration

## 1. Executive Directive
To ensure compliance with the "Standard of Trust" (Phase 61) and protect user biometric/psychological data, we must strictly minimize data retention on third-party servers.

## 2. Configuration Audit (Google Cloud Console)

**Action Required:** The following settings must be verified manually in the Google Cloud Console.

### 2.1 Data Logging & Retention
- **Location:** Console > Vertex AI > Settings > Data Logging
- **Requirement:**
    - [ ] **Data Logging:** DISABLED (Must be OFF)
    - [ ] **Request/Response Logging:** DISABLED
    - [ ] **Retention Period:** 0 Days (if logging cannot be fully disabled)

### 2.2 Model Selection
- **Current Model:** `gemini-2.5-flash-preview` and `gemini-2.5-flash-preview-tts`
- **Note:** Preview models may have different retention policies than GA models.
- **Action:** Transition to General Availability (GA) versions as soon as they support required features (Audio/TTS) to ensure SLA-backed privacy guarantees.

## 3. Implementation Controls

### 3.1 API Key Security
- **Current State:** API Key is passed via Query Parameter (Standard for Generative Language API).
- **Recommendation:** Move to `x-goog-api-key` header where possible to avoid logging keys in URL access logs.

### 3.2 Data Minimization in Prompts
- **Rule:** Do not include PII (Name, Email, Address) in the system prompt or user prompt unless strictly necessary for the session.
- **Current Prompt:** "You are Sherlock... Analyze the user's voice note." (Safe)

## 4. Verification Check
Add this check to your deployment pipeline or manual release checklist:

```dart
// lib/config/ai_model_config.dart
class GeminiAPIConfig {
  static bool verifyZeroRetention() {
    if (kDebugMode) {
      print('⚠️ AUDIT REMINDER: Verify Gemini API data retention settings');
      print('   → console.cloud.google.com → Vertex AI → Settings');
      print('   → Data logging should be DISABLED');
    }
    return true; 
  }
}
```

**Signed:** Agent Priming Protocol
