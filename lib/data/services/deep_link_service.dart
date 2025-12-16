import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../config/deep_link_config.dart';

/// Deep Link Service
/// 
/// Phase 21.1: "The Viral Engine" - Deep Links Infrastructure
/// 
/// Handles incoming deep links from:
/// - iOS Universal Links (apple-app-site-association)
/// - Android App Links (assetlinks.json)
/// - Custom URL scheme (atomichabits://)
/// 
/// Flow:
/// 1. User clicks link: https://atomichabits.app/c/ABCD1234
/// 2. OS opens app (if installed) or web fallback
/// 3. DeepLinkService receives URI
/// 4. Parses and navigates to appropriate screen
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
  
  /// Initialize the service and start listening for links
  Future<void> initialize({GoRouter? router}) async {
    _router = router;
    
    // Get initial link (app opened via deep link)
    await _handleInitialLink();
    
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
    notifyListeners();
  }
  
  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
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
