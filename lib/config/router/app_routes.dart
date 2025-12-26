/// App Route Constants
/// 
/// Phase 41: Navigation Architecture Improvement
/// 
/// Centralised route path definitions to:
/// - Eliminate string duplication across codebase
/// - Enable compile-time refactoring safety
/// - Provide IDE autocomplete for routes
/// - Single source of truth for all navigation paths
library;

/// Centralised route path constants for The Pact app
/// 
/// Usage:
/// ```dart
/// context.go(AppRoutes.dashboard);
/// context.push(AppRoutes.habitEdit(habit.id));
/// ```
abstract class AppRoutes {
  // ============================================================
  // ONBOARDING ROUTES
  // ============================================================
  
  /// Root route - Value Proposition Screen (Hook)
  static const String home = '/';
  
  /// Voice-first onboarding with Gemini Live
  static const String voiceOnboarding = '/onboarding/voice';
  
  /// Text chat onboarding with DeepSeek
  static const String chatOnboarding = '/onboarding/chat';
  
  /// Manual form-based onboarding (Tier 4 fallback)
  static const String manualOnboarding = '/onboarding/manual';
  
  /// Identity declaration screen (Phase 27.17)
  static const String identityOnboarding = '/onboarding/identity';
  
  /// Witness investment screen
  static const String witnessOnboarding = '/onboarding/witness';
  
  /// Tier selection screen
  static const String tierOnboarding = '/onboarding/tier';
  
  /// Pact Reveal screen (Phase 43: Variable Reward)
  /// Shows the Pact Identity Card after Sherlock Protocol completes
  static const String pactReveal = '/onboarding/pact-reveal';

  /// Sherlock Permission Screen (The Data Handshake)
  /// Requests sensitive scopes (Calendar, YouTube) progressively
  static const String sherlockPermissions = '/onboarding/sherlock-permissions';
  
  // ============================================================
  // NICHE LANDING PAGES (Side Doors)
  // ============================================================
  
  /// Developer niche: r/programming, HackerNews
  static const String devs = '/devs';
  
  /// Writer niche: r/writing, Medium
  static const String writers = '/writers';
  
  /// Scholar niche: r/GradSchool, academic Twitter
  static const String scholars = '/scholars';
  
  /// Language learner niche: Duolingo refugees
  static const String languages = '/languages';
  
  /// Indie maker niche: IndieHackers
  static const String makers = '/makers';
  
  // ============================================================
  // MAIN APP ROUTES
  // ============================================================
  
  /// Dashboard - Multi-habit list (Phase 4)
  static const String dashboard = '/dashboard';
  
  /// Today - Focus mode for single habit
  static const String today = '/today';
  
  /// Settings screen
  static const String settings = '/settings';
  
  /// History - Calendar view (Phase 5)
  static const String history = '/history';
  
  /// Analytics - Dashboard with charts (Phase 10)
  static const String analytics = '/analytics';
  
  /// Data Management - Backup & Restore (Phase 11)
  static const String dataManagement = '/data-management';
  
  /// Account settings section (for guest upgrade prompts)
  /// Note: Currently redirects to main settings screen
  static const String settingsAccount = '/settings';
  
  // ============================================================
  // HABIT ROUTES
  // ============================================================
  
  /// Add new habit via conversational onboarding
  static const String habitAdd = '/habit/add';
  
  /// Edit habit properties + stacking (Phase 13)
  /// 
  /// Usage: `context.push(AppRoutes.habitEdit(habit.id))`
  static String habitEdit(String habitId) => '/habit/$habitId/edit';
  
  // ============================================================
  // CONTRACT ROUTES (Phase 16)
  // ============================================================
  
  /// Contracts list screen
  static const String contracts = '/contracts';
  
  /// Create new contract
  static const String contractCreate = '/contracts/create';
  
  /// Create contract with pre-selected habit
  /// 
  /// Usage: `context.push(AppRoutes.contractCreateWithHabit(habitId))`
  static String contractCreateWithHabit(String habitId) => 
      '/contracts/create?habitId=$habitId';
  
  /// Join contract via invite code (Phase 16.4)
  /// 
  /// Usage: `context.go(AppRoutes.contractJoin(inviteCode))`
  static String contractJoin(String inviteCode) => '/contracts/join/$inviteCode';
  
  // ============================================================
  // WITNESS ROUTES (Phase 22)
  // ============================================================
  
  /// Witness dashboard
  static const String witness = '/witness';
  
  /// Accept witness invitation
  /// 
  /// Usage: `context.go(AppRoutes.witnessAccept(inviteCode))`
  static String witnessAccept(String inviteCode) => '/witness/accept/$inviteCode';
  
  // ============================================================
  // ROUTE LISTS (for guards and validation)
  // ============================================================
  
  /// Routes that don't require authentication
  static const List<String> publicRoutes = [
    home,
    devs,
    writers,
    scholars,
    languages,
    makers,
    voiceOnboarding,
    chatOnboarding,
    manualOnboarding,
    identityOnboarding,
    witnessOnboarding,
    tierOnboarding,
    pactReveal,
    sherlockPermissions,
  ];
  
  /// Routes that require premium subscription
  static const List<String> premiumRoutes = [
    voiceOnboarding,
    witness,
  ];
  
  /// All niche landing page routes
  static const List<String> nicheRoutes = [
    devs,
    writers,
    scholars,
    languages,
    makers,
  ];
  
  /// Main app routes (post-onboarding)
  static const List<String> mainAppRoutes = [
    dashboard,
    today,
    settings,
    history,
    analytics,
    dataManagement,
    contracts,
  ];
}
