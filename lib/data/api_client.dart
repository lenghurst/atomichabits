import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// API error types for categorising failures
enum ApiErrorType {
  /// Network connectivity issues (no internet, DNS failure, etc.)
  network,

  /// Request timed out
  timeout,

  /// Server returned an error status code (4xx, 5xx)
  server,

  /// Response body couldn't be parsed as expected
  parse,

  /// Unknown or unexpected error
  unknown,
}

/// Result wrapper for API calls - encapsulates success or error
/// This prevents throwing exceptions and makes error handling explicit
class ApiResult<T> {
  final T? value;
  final ApiErrorType? errorType;
  final String? errorMessage;
  final int? statusCode;

  const ApiResult._({
    this.value,
    this.errorType,
    this.errorMessage,
    this.statusCode,
  });

  /// Create a successful result
  factory ApiResult.success(T value) {
    return ApiResult._(value: value);
  }

  /// Create an error result
  factory ApiResult.error({
    required ApiErrorType type,
    String? message,
    int? statusCode,
  }) {
    return ApiResult._(
      errorType: type,
      errorMessage: message,
      statusCode: statusCode,
    );
  }

  /// Check if the result is successful
  bool get isSuccess => value != null && errorType == null;

  /// Check if the result is an error
  bool get isError => errorType != null;
}

/// HTTP client for coach/LLM API endpoints
///
/// Usage:
/// ```dart
/// final client = ApiClient(baseUrl: 'https://api.example.com');
/// final result = await client.postJson<MyModel>(
///   '/api/endpoint',
///   body: {'key': 'value'},
///   parser: (json) => MyModel.fromJson(json),
/// );
///
/// if (result.isSuccess) {
///   // Use result.value
/// } else {
///   // Handle result.errorType and result.errorMessage
/// }
/// ```
class ApiClient {
  final String baseUrl;
  final Duration timeout;

  /// Create an API client
  ///
  /// [baseUrl] - Base URL without trailing slash (e.g., 'https://api.example.com')
  /// [timeout] - Request timeout (default: 5 seconds)
  const ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 5),
  });

  /// POST JSON to an endpoint and parse the response
  ///
  /// [path] - Relative path starting with / (e.g., '/api/coach/onboarding')
  /// [headers] - Optional additional headers (Content-Type: application/json is automatic)
  /// [body] - Request body (will be JSON-encoded)
  /// [parser] - Function to parse response JSON into type T
  ///
  /// Returns ApiResult<T> wrapping success value or error details
  Future<ApiResult<T>> postJson<T>({
    required String path,
    Map<String, String>? headers,
    Object? body,
    required T Function(dynamic json) parser,
  }) async {
    // Validate that baseUrl is configured
    if (baseUrl.isEmpty) {
      return ApiResult.error(
        type: ApiErrorType.network,
        message: 'API base URL not configured',
      );
    }

    try {
      // Build full URL
      final url = Uri.parse('$baseUrl$path');

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Make POST request with timeout
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(timeout);

      // Check status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ApiResult.error(
          type: ApiErrorType.server,
          message: 'Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Parse response body
      try {
        final json = jsonDecode(response.body);
        final value = parser(json);
        return ApiResult.success(value);
      } catch (e) {
        return ApiResult.error(
          type: ApiErrorType.parse,
          message: 'Failed to parse response: $e',
          statusCode: response.statusCode,
        );
      }

    } on TimeoutException {
      return ApiResult.error(
        type: ApiErrorType.timeout,
        message: 'Request timed out after ${timeout.inSeconds}s',
      );
    } on http.ClientException catch (e) {
      return ApiResult.error(
        type: ApiErrorType.network,
        message: 'Network error: $e',
      );
    } catch (e) {
      return ApiResult.error(
        type: ApiErrorType.unknown,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// GET JSON from an endpoint and parse the response
  ///
  /// Similar to postJson but uses GET method
  Future<ApiResult<T>> getJson<T>({
    required String path,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    if (baseUrl.isEmpty) {
      return ApiResult.error(
        type: ApiErrorType.network,
        message: 'API base URL not configured',
      );
    }

    try {
      // Build full URL with query parameters
      final uri = Uri.parse('$baseUrl$path');
      final url = queryParameters != null
          ? uri.replace(queryParameters: queryParameters)
          : uri;

      // Prepare headers
      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      // Make GET request with timeout
      final response = await http.get(
        url,
        headers: requestHeaders,
      ).timeout(timeout);

      // Check status code
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ApiResult.error(
          type: ApiErrorType.server,
          message: 'Server returned ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      // Parse response body
      try {
        final json = jsonDecode(response.body);
        final value = parser(json);
        return ApiResult.success(value);
      } catch (e) {
        return ApiResult.error(
          type: ApiErrorType.parse,
          message: 'Failed to parse response: $e',
          statusCode: response.statusCode,
        );
      }

    } on TimeoutException {
      return ApiResult.error(
        type: ApiErrorType.timeout,
        message: 'Request timed out after ${timeout.inSeconds}s',
      );
    } on http.ClientException catch (e) {
      return ApiResult.error(
        type: ApiErrorType.network,
        message: 'Network error: $e',
      );
    } catch (e) {
      return ApiResult.error(
        type: ApiErrorType.unknown,
        message: 'Unexpected error: $e',
      );
    }
  }
}
