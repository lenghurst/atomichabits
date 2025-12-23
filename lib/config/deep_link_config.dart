/// Deep Link Configuration
/// 
/// Phase 21.1: Deep Links Infrastructure - "The Viral Engine"
/// 
/// Handles Universal Links (iOS) and App Links (Android) for:
/// - Contract invites: thepact.co/invite?c=CODE
/// - Contract preview: thepact.co/c/CODE
/// - Niche landing pages: thepact.co/devs, /writers, etc.
/// 
/// Architecture:
/// - Production: https://thepact.co/...
/// - Custom scheme fallback: thepact://...
/// - Web fallback: Opens app store if app not installed
library;

/// Deep link configuration and URL builders
class DeepLinkConfig {
  // ============================================================
  // DOMAIN CONFIGURATION
  // ============================================================
  
  /// Production domain for Universal Links / App Links
  static const String productionDomain = 'thepact.co';
  
  /// Custom URL scheme for fallback deep links
  static const String customScheme = 'thepact';
  
  /// Apple App ID (Team ID + Bundle ID)
  /// Required for apple-app-site-association
  /// Format: TEAMID.bundleId
  static const String appleAppId = 'XXXXXXXXXX.co.thepact.app';
  
  /// Android package name for assetlinks.json
  static const String androidPackage = 'co.thepact.app';
  
  /// SHA256 fingerprint for Android App Links verification
  /// Generate with: keytool -list -v -keystore your-keystore.jks
  static const String androidSha256 = 'YOUR_SHA256_FINGERPRINT';
  
  // ============================================================
  // URL PATH PATTERNS
  // ============================================================
  
  /// Contract invite paths
  static const String invitePathShort = '/c';      // /c/ABCD1234
  static const String invitePathLong = '/invite';   // /invite?c=ABCD1234
  static const String joinPath = '/join';           // /join/ABCD1234
  
  /// Niche landing page paths (Phase 19 Side Door)
  static const List<String> nichePaths = [
    '/devs',
    '/writers', 
    '/scholars',
    '/languages',
    '/makers',
  ];
  
  /// App routes that should be deep-linkable
  static const List<String> appRoutes = [
    '/dashboard',
    '/today',
    '/settings',
    '/history',
    '/analytics',
    '/contracts',
  ];
  
  // ============================================================
  // URL BUILDERS
  // ============================================================
  
  /// Generate contract invite URL (Universal Link)
  /// 
  /// Returns: https://thepact.co/c/ABCD1234
  static String getContractInviteUrl(String inviteCode) {
    return 'https://$productionDomain$invitePathShort/$inviteCode';
  }
  
  /// Phase 24.E: Generate Web Anchor URL (The Trojan Horse)
  /// 
  /// This URL hits the React landing page which:
  /// - Mobile: Detects OS and redirects to App Store with referrer
  /// - Desktop: Shows landing page with invite banner + email capture
  /// 
  /// Returns: https://thepact.co/join/ABCD1234
  static String getWebAnchorUrl(String inviteCode) {
    return 'https://$productionDomain$joinPath/$inviteCode';
  }
  
  /// Generate contract invite URL with query param (fallback)
  /// 
  /// Returns: https://thepact.co/invite?c=ABCD1234
  static String getContractInviteUrlWithQuery(String inviteCode) {
    return 'https://$productionDomain$invitePathLong?c=$inviteCode';
  }
  
  /// Generate custom scheme URL (fallback for deep linking)
  /// 
  /// Returns: thepact://invite?c=ABCD1234
  static String getCustomSchemeUrl(String inviteCode) {
    return '$customScheme://invite?c=$inviteCode';
  }
  
  /// Generate niche landing page URL
  /// 
  /// Returns: https://thepact.co/devs
  static String getNicheLandingUrl(String nichePath) {
    if (!nichePath.startsWith('/')) {
      nichePath = '/$nichePath';
    }
    return 'https://$productionDomain$nichePath';
  }
  
  // ============================================================
  // URL PARSERS
  // ============================================================
  
  /// Parse deep link URI to extract route and parameters
  static DeepLinkData? parseUri(Uri uri) {
    // Handle custom scheme: atomichabits://...
    if (uri.scheme == customScheme) {
      return _parseCustomScheme(uri);
    }
    
    // Handle Universal Links: https://atomichabits.app/...
    if (uri.host == productionDomain || 
        uri.host == 'www.$productionDomain') {
      return _parseUniversalLink(uri);
    }
    
    return null;
  }
  
  static DeepLinkData? _parseCustomScheme(Uri uri) {
    final path = uri.host; // In custom scheme, path is in host
    
    // atomichabits://invite?c=CODE
    if (path == 'invite' || path == 'join') {
      final inviteCode = uri.queryParameters['c'];
      if (inviteCode != null && inviteCode.isNotEmpty) {
        return DeepLinkData(
          type: DeepLinkType.contractInvite,
          inviteCode: inviteCode,
          originalUri: uri,
        );
      }
    }
    
    // atomichabits://complete?habitId=ID
    if (path == 'complete') {
      final habitId = uri.queryParameters['habitId'];
      if (habitId != null) {
        return DeepLinkData(
          type: DeepLinkType.habitComplete,
          habitId: habitId,
          originalUri: uri,
        );
      }
    }
    
    return null;
  }
  
  static DeepLinkData? _parseUniversalLink(Uri uri) {
    final pathSegments = uri.pathSegments;
    
    if (pathSegments.isEmpty) {
      return DeepLinkData(
        type: DeepLinkType.home,
        originalUri: uri,
      );
    }
    
    final firstSegment = pathSegments.first;
    
    // /c/CODE or /invite/CODE
    if (firstSegment == 'c' || firstSegment == 'invite' || firstSegment == 'join') {
      String? inviteCode;
      
      // Path-based: /c/ABCD1234
      if (pathSegments.length > 1) {
        inviteCode = pathSegments[1];
      }
      
      // Query-based: /invite?c=ABCD1234
      inviteCode ??= uri.queryParameters['c'];
      
      if (inviteCode != null && inviteCode.isNotEmpty) {
        return DeepLinkData(
          type: DeepLinkType.contractInvite,
          inviteCode: inviteCode,
          originalUri: uri,
        );
      }
    }
    
    // Niche landing pages: /devs, /writers, etc.
    if (nichePaths.contains('/$firstSegment')) {
      return DeepLinkData(
        type: DeepLinkType.nicheLanding,
        nichePath: '/$firstSegment',
        originalUri: uri,
      );
    }
    
    // App routes: /dashboard, /settings, etc.
    if (appRoutes.contains('/$firstSegment')) {
      return DeepLinkData(
        type: DeepLinkType.appRoute,
        route: '/$firstSegment',
        originalUri: uri,
      );
    }
    
    // Contracts routes
    if (firstSegment == 'contracts') {
      if (pathSegments.length > 1 && pathSegments[1] == 'join') {
        // /contracts/join/ABCD1234
        final inviteCode = pathSegments.length > 2 ? pathSegments[2] : null;
        if (inviteCode != null) {
          return DeepLinkData(
            type: DeepLinkType.contractInvite,
            inviteCode: inviteCode,
            originalUri: uri,
          );
        }
      }
      return DeepLinkData(
        type: DeepLinkType.appRoute,
        route: '/contracts',
        originalUri: uri,
      );
    }
    
    return null;
  }
  
  // ============================================================
  // VALIDATION
  // ============================================================
  
  /// Validate invite code format
  /// Format: 8 alphanumeric characters
  static bool isValidInviteCode(String code) {
    return RegExp(r'^[A-Z0-9]{8}$').hasMatch(code.toUpperCase());
  }
}

/// Types of deep links the app can handle
enum DeepLinkType {
  home,           // Root app route
  contractInvite, // Join a habit contract
  habitComplete,  // Complete a habit (from widget)
  nicheLanding,   // Side door landing page
  appRoute,       // Direct app route (dashboard, settings, etc.)
}

/// Parsed deep link data
class DeepLinkData {
  final DeepLinkType type;
  final String? inviteCode;
  final String? habitId;
  final String? nichePath;
  final String? route;
  final Uri originalUri;
  
  const DeepLinkData({
    required this.type,
    this.inviteCode,
    this.habitId,
    this.nichePath,
    this.route,
    required this.originalUri,
  });
  
  /// Get the Flutter route to navigate to
  String get targetRoute {
    switch (type) {
      case DeepLinkType.home:
        return '/';
      case DeepLinkType.contractInvite:
        return '/contracts/join/$inviteCode';
      case DeepLinkType.habitComplete:
        return '/today';
      case DeepLinkType.nicheLanding:
        return nichePath ?? '/';
      case DeepLinkType.appRoute:
        return route ?? '/dashboard';
    }
  }
  
  @override
  String toString() {
    return 'DeepLinkData(type: $type, inviteCode: $inviteCode, habitId: $habitId, '
           'nichePath: $nichePath, route: $route, uri: $originalUri)';
  }
}
