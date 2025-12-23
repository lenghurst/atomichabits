/// Supabase Configuration
/// 
/// Phase 15: Identity Foundation
/// Phase 16.2 + 16.4: Habit Contracts & Deep Links
/// Phase 27.1: OPSEC Protocol - Secure Runtime Key Injection
/// 
/// Configuration for Supabase backend integration.
/// 
/// SECURITY PROTOCOL:
/// - All secrets are injected at runtime via --dart-define-from-file
/// - NO hardcoded API keys or URLs in source code
/// - Local development: secrets.json (git-ignored)
/// - CI/CD: GitHub Secrets or Codemagic environment variables
/// 
/// To configure locally:
/// 1. Create `secrets.json` in the project root
/// 2. Add to .gitignore
/// 3. Configure .vscode/launch.json with --dart-define-from-file=secrets.json
/// 
/// To get these values:
/// 1. Go to https://supabase.com and create a project
/// 2. Navigate to Project Settings > API
/// 3. Copy the URL and anon key to secrets.json
class SupabaseConfig {
  /// Supabase project URL
  /// Format: https://[project-id].supabase.co
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Set via --dart-define=SUPABASE_URL=your_url
  );
  
  /// Supabase anonymous key (public)
  /// Safe to expose in client apps - RLS policies protect data
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // Set via --dart-define=SUPABASE_ANON_KEY=your_key
  );
  
  /// Check if Supabase is configured
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
  
  /// Alias for isConfigured (used in failsafe checks)
  static bool get isValid => isConfigured;
  
  /// Deep link redirect URL for OAuth
  /// Used for Google Sign-In and other OAuth providers
  static const String authRedirectUrl = 'io.supabase.atomichabits://login-callback/';
  
  /// Android package name for Google Sign-In
  /// CRITICAL: Must match applicationId in android/app/build.gradle.kts
  /// and the package name registered in Google Cloud Console
  static const String androidPackageName = 'co.thepact.app';
  
  /// iOS bundle ID for Google Sign-In
  /// CRITICAL: Must match PRODUCT_BUNDLE_IDENTIFIER in iOS project
  static const String iosBundleId = 'co.thepact.app';
  
  // Phase 16.4: Deep Links Configuration
  
  /// Production domain for deep links
  static const String productionDomain = 'atomichabits.app';
  
  /// Custom URL scheme for app links
  static const String urlScheme = 'atomichabits';
  
  /// Generate invite URL from code
  static String getInviteUrl(String inviteCode, {bool useCustomScheme = false}) {
    if (useCustomScheme) {
      return '$urlScheme://invite?c=$inviteCode';
    }
    return 'https://$productionDomain/invite?c=$inviteCode';
  }
  
  /// Parse invite code from URL
  static String? parseInviteCode(Uri uri) {
    // Handle both: atomichabits://invite?c=CODE and https://atomichabits.app/invite?c=CODE
    if (uri.queryParameters.containsKey('c')) {
      return uri.queryParameters['c'];
    }
    return null;
  }
}

/// Database table names
class SupabaseTables {
  static const String users = 'users';
  static const String habits = 'habits';
  static const String completions = 'habit_completions';
  static const String contracts = 'habit_contracts';
  static const String contractEvents = 'contract_events';
  
  // Phase 22: Witness Events (Real-time accountability)
  static const String witnessEvents = 'witness_events';
}

/// User tier levels for monetization
enum UserTier {
  free,      // Witness tier - can observe others
  builder,   // Single habit builder
  pro,       // Unlimited stacks + AI voice
}

extension UserTierExtension on UserTier {
  String get name {
    switch (this) {
      case UserTier.free:
        return 'free';
      case UserTier.builder:
        return 'builder';
      case UserTier.pro:
        return 'pro';
    }
  }
  
  static UserTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'builder':
        return UserTier.builder;
      case 'pro':
        return UserTier.pro;
      default:
        return UserTier.free;
    }
  }
}
