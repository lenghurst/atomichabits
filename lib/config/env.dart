/// Environment configuration
/// 
/// Values are injected at build time using --dart-define-from-file=secrets.json
class Env {
  /// Gemini API Key for AI services
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  
  /// OpenAI API Key (Optional fallback)
  static const String openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  /// Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  /// AI Proxy Endpoint (for suggestion service)
  static const String aiProxyEndpoint = String.fromEnvironment('AI_PROXY_ENDPOINT');
}
