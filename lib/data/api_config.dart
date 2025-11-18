/// API configuration for coach/LLM endpoints
///
/// This file manages the base URL for the external coaching API.
/// The backend is hosted separately and accessed over HTTPS.
///
/// CONFIGURATION:
/// - To enable remote API: Pass --dart-define=COACH_API_BASE_URL=https://your-api.com
/// - Without config: App runs in local-only mode with heuristic fallbacks
///
/// EXAMPLES:
/// ```bash
/// # Local mode (no backend)
/// flutter run
///
/// # Development backend
/// flutter run --dart-define=COACH_API_BASE_URL=http://10.0.2.2:3000
///
/// # Production backend
/// flutter run --dart-define=COACH_API_BASE_URL=https://api.yourapp.com
/// ```

/// Base URL for the coach/LLM API
///
/// Set via --dart-define=COACH_API_BASE_URL=<url> at build/run time
/// Defaults to empty string, which triggers local-only fallback mode
const String apiBaseUrl = String.fromEnvironment(
  'COACH_API_BASE_URL',
  defaultValue: '',
);

/// Check if the remote API is configured
///
/// Returns true if apiBaseUrl is set, false if running in local-only mode
bool get isApiConfigured => apiBaseUrl.isNotEmpty;

/// Get a configured API base URL for logging/debugging
String get apiBaseUrlForDisplay =>
    isApiConfigured ? apiBaseUrl : '(not configured - using local fallbacks)';
