import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/deep_link_config.dart';

/// Deep Link Service
/// 
/// Phase 21.1: "The Viral Engine" - Deep Links Infrastructure
/// Phase 24: "The Clipboard Bridge" - Deferred Deep Linking
/// 
/// Handles incoming deep links from:
/// - iOS Universal Links (apple-app-site-association)
/// - Android App Links (assetlinks.json)
/// - Custom URL scheme (atomichabits://)
/// - [NEW] System Clipboard (deferred deep link fallback)
/// 
/// Flow:
/// 1. User clicks link: https://atomichabits.app/c/ABCD1234
/// 2. OS opens app (if installed) or web fallback
/// 3. DeepLinkService receives URI
/// 4. Parses and navigates to appropriate screen
/// 
/// Phase 24 "Clipboard Bridge" Flow:
/// 1. User A shares invite link (clipboard auto-populated)
/// 2. User B installs app, opens for first time
/// 3. Standard deep link check (getInitialLink) - may fail
/// 4. FALLBACK: Check clipboard for invite code pattern
/// 5. If found, route to WitnessAcceptScreen ("Side Door")
class DeepLinkService extends ChangeNotifier {
  static const _channel = MethodChannel('app.channel.shared.data');
  static const _eventChannel = EventChannel('app.channel.shared.data/events');
  
  // Stream subscriptions
  StreamSubscription? _linkSubscription;
  
  // Pending deep link (received before app fully loaded)
  DeepLinkData? _pendingDeepLink;
  
  // Last processed deep link
  DeepLinkData? _lastDeepLink;
  
  // Router reference for navigation
  GoRouter? _router;
  
  /// Pending deep link waiting to be handled
  DeepLinkData? get pendingDeepLink => _pendingDeepLink;
  
  /// Last processed deep link
  DeepLinkData? get lastDeepLink => _lastDeepLink;
  
  /// Whether an invite was detected from clipboard (Phase 24)
  bool _inviteFromClipboard = false;
  bool get inviteFromClipboard => _inviteFromClipboard;
  
  /// Initialize the service and start listening for links
  Future<void> initialize({GoRouter? router}) async {
    _router = router;
    
    // Get initial link (app opened via deep link)
    await _handleInitialLink();
    
    // Phase 24: Clipboard Bridge fallback
    // If no pending deep link from standard flow, check clipboard
    if (_pendingDeepLink == null) {
      await _checkClipboardForInvite();
    }
    
    // Listen for incoming links while app is running
    _startLinkListener();
  }
  
  /// Set the router for navigation
  void setRouter(GoRouter router) {
    _router = router;
    
    // Process any pending deep link
    if (_pendingDeepLink != null) {
      _handleDeepLink(_pendingDeepLink!);
      _pendingDeepLink = null;
    }
  }
  
  /// Handle initial deep link (app cold start)
  Future<void> _handleInitialLink() async {
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      
      if (initialLink != null && initialLink.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('DeepLinkService: Initial link received: $initialLink');
        }
        
        final uri = Uri.tryParse(initialLink);
        if (uri != null) {
          final data = DeepLinkConfig.parseUri(uri);
          if (data != null) {
            _pendingDeepLink = data;
            notifyListeners();
          }
        }
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('DeepLinkService: Error getting initial link: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeepLinkService: Error getting initial link: $e');
      }
    }
  }
  
  /// Start listening for incoming links
  void _startLinkListener() {
    _linkSubscription?.cancel();
    
    try {
      _linkSubscription = _eventChannel
          .receiveBroadcastStream()
          .listen(
            (dynamic link) {
              if (link is String && link.isNotEmpty) {
                if (kDebugMode) {
                  debugPrint('DeepLinkService: Link received: $link');
                }
                
                final uri = Uri.tryParse(link);
                if (uri != null) {
                  final data = DeepLinkConfig.parseUri(uri);
                  if (data != null) {
                    _handleDeepLink(data);
                  }
                }
              }
            },
            onError: (error) {
              if (kDebugMode) {
                debugPrint('DeepLinkService: Stream error: $error');
              }
            },
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeepLinkService: Error setting up stream: $e');
      }
    }
  }
  
  /// Handle a parsed deep link
  void _handleDeepLink(DeepLinkData data) {
    if (kDebugMode) {
      debugPrint('DeepLinkService: Handling deep link: $data');
    }
    
    _lastDeepLink = data;
    notifyListeners();
    
    // Navigate if router is available
    if (_router != null) {
      _navigateToRoute(data);
    } else {
      // Store as pending if router not yet available
      _pendingDeepLink = data;
    }
  }
  
  /// Navigate to the appropriate route
  void _navigateToRoute(DeepLinkData data) {
    if (_router == null) return;
    
    final route = data.targetRoute;
    
    if (kDebugMode) {
      debugPrint('DeepLinkService: Navigating to $route');
    }
    
    // Use go for full navigation, push for stack addition
    switch (data.type) {
      case DeepLinkType.contractInvite:
        // Push to preserve back navigation
        _router!.push(route);
        break;
      case DeepLinkType.nicheLanding:
        // Replace current route for landing pages
        _router!.go(route);
        break;
      case DeepLinkType.appRoute:
        _router!.go(route);
        break;
      case DeepLinkType.habitComplete:
        // Special handling for widget completions
        _router!.go('/today');
        break;
      case DeepLinkType.home:
        _router!.go('/');
        break;
    }
  }
  
  /// Manually handle a URI (useful for testing)
  void handleUri(Uri uri) {
    final data = DeepLinkConfig.parseUri(uri);
    if (data != null) {
      _handleDeepLink(data);
    }
  }
  
  /// Clear pending deep link
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
    _inviteFromClipboard = false;
    notifyListeners();
  }
  
  // ============================================================
  // Phase 24: "The Clipboard Bridge" - Deferred Deep Linking
  // ============================================================
  
  /// Regex patterns for detecting invite codes in clipboard text
  static final List<RegExp> _invitePatterns = [
    // https://atomichabits.app/join/CODE
    RegExp(r'atomichabits\.app/join/([a-zA-Z0-9]{6,12})'),
    // https://atomichabits.app/c/CODE
    RegExp(r'atomichabits\.app/c/([a-zA-Z0-9]{6,12})'),
    // https://atomichabits.app/invite?c=CODE
    RegExp(r'atomichabits\.app/invite\?c=([a-zA-Z0-9]{6,12})'),
    // atomichabits://invite?c=CODE
    RegExp(r'atomichabits://invite\?c=([a-zA-Z0-9]{6,12})'),
    // atomichabits://c/CODE
    RegExp(r'atomichabits://c/([a-zA-Z0-9]{6,12})'),
  ];
  
  /// Check system clipboard for invite codes
  /// 
  /// Phase 24: "The Clipboard Bridge"
  /// 
  /// This is our cost-effective deferred deep linking solution.
  /// When User A shares an invite link:
  /// 1. The share text is copied to clipboard
  /// 2. User B installs the app
  /// 3. On first launch, we check the clipboard for invite patterns
  /// 4. If found, we route directly to WitnessAcceptScreen
  /// 
  /// Cost: $0 (vs Branch.io at $X/month)
  /// Impact: Massive improvement to viral conversion
  Future<String?> checkClipboardForInvite() async {
    return _checkClipboardForInvite();
  }
  
  Future<String?> _checkClipboardForInvite() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      
      if (clipboardData?.text == null || clipboardData!.text!.isEmpty) {
        if (kDebugMode) {
          debugPrint('DeepLinkService: Clipboard empty or inaccessible');
        }
        return null;
      }
      
      final text = clipboardData.text!;
      
      if (kDebugMode) {
        debugPrint('DeepLinkService: Checking clipboard for invite code...');
        debugPrint('DeepLinkService: Clipboard content length: ${text.length}');
      }
      
      // Try each pattern
      for (final pattern in _invitePatterns) {
        final match = pattern.firstMatch(text);
        if (match != null && match.groupCount >= 1) {
          final inviteCode = match.group(1)!;
          
          if (kDebugMode) {
            debugPrint('DeepLinkService: Found invite code in clipboard: $inviteCode');
          }
          
          // Create a DeepLinkData for this invite
          _pendingDeepLink = DeepLinkData(
            type: DeepLinkType.contractInvite,
            inviteCode: inviteCode,
            rawUri: Uri.parse('atomichabits://c/$inviteCode'),
          );
          _inviteFromClipboard = true;
          notifyListeners();
          
          return inviteCode;
        }
      }
      
      if (kDebugMode) {
        debugPrint('DeepLinkService: No invite code found in clipboard');
      }
      return null;
      
    } on PlatformException catch (e) {
      // Clipboard access denied (common on iOS)
      if (kDebugMode) {
        debugPrint('DeepLinkService: Clipboard access denied: $e');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DeepLinkService: Error checking clipboard: $e');
      }
      return null;
    }
  }
  
  /// Check if there's a pending invite (from deep link or clipboard)
  /// 
  /// Use this in OnboardingOrchestrator to determine "Side Door" routing
  bool get hasPendingInvite => 
      _pendingDeepLink?.type == DeepLinkType.contractInvite;
  
  /// Get the pending invite code (if any)
  String? get pendingInviteCode => _pendingDeepLink?.inviteCode;
  
  /// Get the route for the pending deep link (if any)
  /// Returns null if no pending link or if it's not navigable
  String? get pendingRoute => _pendingDeepLink?.targetRoute;
  
  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
  
  // ============================================================
  // Phase 24: Share Helper Methods
  // ============================================================
  
  /// Copy invite link to clipboard before sharing
  /// 
  /// This ensures the "Clipboard Bridge" works:
  /// 1. Copy the full invite text to clipboard
  /// 2. Open system share sheet
  /// 3. Even if deep link fails, clipboard has the code
  static Future<void> copyInviteToClipboard({
    required String inviteCode,
    required String builderName,
    required String habitName,
  }) async {
    final shareText = _buildShareText(
      inviteCode: inviteCode,
      builderName: builderName,
      habitName: habitName,
    );
    
    await Clipboard.setData(ClipboardData(text: shareText));
    
    if (kDebugMode) {
      debugPrint('DeepLinkService: Copied invite to clipboard: $shareText');
    }
  }
  
  /// Build the share text for an invite
  static String _buildShareText({
    required String inviteCode,
    required String builderName,
    required String habitName,
  }) {
    final inviteUrl = DeepLinkConfig.buildContractInviteUrl(inviteCode);
    return '''🤝 I need a witness!

I'm committing to "$habitName" and I want you to hold me accountable.

Join my pact: $inviteUrl

- $builderName''';
  }
  
  /// Get the full share text for an invite (for share sheet)
  static String getShareText({
    required String inviteCode,
    required String builderName,
    required String habitName,
  }) {
    return _buildShareText(
      inviteCode: inviteCode,
      builderName: builderName,
      habitName: habitName,
    );
  }
}

/// Mixin for widgets that need to handle deep links
mixin DeepLinkHandler<T extends StatefulWidget> on State<T> {
  late final StreamSubscription _deepLinkSubscription;
  
  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }
  
  void _initDeepLinkListener() {
    // Override in implementing class
  }
  
  /// Called when a deep link is received
  void onDeepLinkReceived(DeepLinkData data);
  
  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    super.dispose();
  }
}
