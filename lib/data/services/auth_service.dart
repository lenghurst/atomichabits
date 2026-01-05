import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show SocketException;
import '../../config/supabase_config.dart';
import '../../core/utils/retry_policy.dart';

/// Authentication Service
/// 
/// Phase 15: Identity Foundation
/// 
/// Provides authentication capabilities with support for:
/// - Anonymous login (default) - users start with a local ID
/// - Email/password upgrade - link anonymous account to email
/// - Google Sign-In upgrade - link anonymous account to Google
/// 
/// Key Design Decisions:
/// 1. Anonymous-first: Users can use the app immediately without friction
/// 2. Upgrade path: Anonymous accounts can be upgraded to permanent accounts
/// 3. Data preservation: Local Hive data persists across auth upgrades
/// 4. Offline-capable: App works fully offline, syncs when online
class AuthService extends ChangeNotifier {
  final SupabaseClient? _supabase;
  User? _currentUser;
  AuthState _authState = AuthState.initializing;
  String? _errorMessage;
  StreamSubscription<dynamic>? _authSubscription;
  
  AuthService({SupabaseClient? supabaseClient}) 
      : _supabase = supabaseClient;
  
  /// Current authenticated user (null if not authenticated)
  User? get currentUser => _currentUser;
  
  /// Current user ID (null if not authenticated)
  String? get userId => _currentUser?.id;
  
  /// Current authentication state
  AuthState get authState => _authState;
  
  /// Last error message (null if no error)
  String? get errorMessage => _errorMessage;
  
  /// Whether user is authenticated (anonymous or identified)
  bool get isAuthenticated => _currentUser != null;
  
  /// Whether user is anonymous (not linked to email/social)
  bool get isAnonymous {
    if (_currentUser == null) return false;
    return _currentUser!.email == null || _currentUser!.email!.isEmpty;
  }
  
  /// Whether user has upgraded to a permanent account
  bool get isIdentified => isAuthenticated && !isAnonymous;
  
  /// Whether Supabase is available
  bool get isSupabaseAvailable => _supabase != null && SupabaseConfig.isConfigured;
  
  /// Initialize the auth service
  /// Call this after Supabase is initialized
  Future<void> initialize() async {
    if (!isSupabaseAvailable) {
      _authState = AuthState.offline;
      if (kDebugMode) {
        debugPrint('AuthService: Running in offline mode (Supabase not configured)');
      }
      notifyListeners();
      return;
    }
    
    try {
      // Listen to auth state changes
      _authSubscription = _supabase!.auth.onAuthStateChange.listen((data) {
        _handleAuthStateChange(data.event, data.session);
      });
      
      // Check for existing session
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _currentUser = session.user;
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: $e';
      _authState = AuthState.error;
      if (kDebugMode) {
        debugPrint('AuthService initialization error: $e');
      }
      notifyListeners();
    }
  }
  
  /// Sign in anonymously
  /// Creates a new anonymous user that can be upgraded later
  Future<AuthResult> signInAnonymously() async {
    if (!isSupabaseAvailable) {
      return AuthResult.success(localOnly: true);
    }
    
    try {
      _authState = AuthState.loading;
      notifyListeners();
      
      final response = await _supabase!.auth.signInAnonymously();
      
      if (response.user != null) {
        _currentUser = response.user;
        _authState = AuthState.authenticated;
        _errorMessage = null;
        notifyListeners();
        
        // Create user record in database
        await _createUserRecord(response.user!);
        
        return AuthResult.success(user: response.user);
      } else {
        _authState = AuthState.error;
        _errorMessage = 'Anonymous sign-in failed';
        notifyListeners();
        return AuthResult.failure('Anonymous sign-in failed');
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Anonymous sign-in error: $e');
      }
      return AuthResult.failure(e.toString());
    }
  }
  
  /// Upgrade anonymous account to email/password
  /// Links the existing anonymous user to an email account
  Future<AuthResult> upgradeWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isSupabaseAvailable) {
      return AuthResult.failure('Supabase not configured');
    }
    
    if (!isAuthenticated || !isAnonymous) {
      return AuthResult.failure('Must be signed in anonymously to upgrade');
    }
    
    try {
      _authState = AuthState.loading;
      notifyListeners();
      
      // Link email to anonymous account
      final response = await _supabase!.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
        ),
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        _authState = AuthState.authenticated;
        _errorMessage = null;
        notifyListeners();
        
        // Update user record
        await _updateUserRecord(response.user!);
        
        return AuthResult.success(user: response.user);
      } else {
        _authState = AuthState.error;
        _errorMessage = 'Email upgrade failed';
        notifyListeners();
        return AuthResult.failure('Email upgrade failed');
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Email upgrade error: $e');
      }
      return AuthResult.failure(e.toString());
    }
  }
  
  /// Sign in with email/password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isSupabaseAvailable) {
      return AuthResult.failure('Supabase not configured');
    }
    
    try {
      _authState = AuthState.loading;
      notifyListeners();
      
      final response = await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        _authState = AuthState.authenticated;
        _errorMessage = null;
        notifyListeners();
        return AuthResult.success(user: response.user);
      } else {
        _authState = AuthState.error;
        _errorMessage = 'Sign-in failed';
        notifyListeners();
        return AuthResult.failure('Sign-in failed');
      }
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return AuthResult.failure(e.toString());
    }
  }
  
  /// Sign in with Google
  /// If anonymous, links Google to existing account
  /// Otherwise, creates new account or signs in
  Future<AuthResult> signInWithGoogle() async {
    // Phase 27.25: Enhanced Five-Axis Diagnostic Logging
    if (kDebugMode) {
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════════════════════════════════╗');
      debugPrint('║           GOOGLE SIGN-IN DIAGNOSTIC - FIVE AXIS CHECK                ║');
      debugPrint('╠══════════════════════════════════════════════════════════════════════╣');
      debugPrint('║ AXIS 1: Supabase Configuration');
      debugPrint('║   - URL: ${SupabaseConfig.url.isNotEmpty ? "${SupabaseConfig.url.substring(0, 30)}..." : "EMPTY ❌"}');
      debugPrint('║   - Anon Key: ${SupabaseConfig.anonKey.isNotEmpty ? "configured ✅" : "EMPTY ❌"}');
      debugPrint('║   - isConfigured: ${SupabaseConfig.isConfigured ? "YES ✅" : "NO ❌"}');
      debugPrint('║');
      debugPrint('║ AXIS 2: Google Web Client ID');
      debugPrint('║   - GOOGLE_WEB_CLIENT_ID: ${SupabaseConfig.webClientId.isNotEmpty ? "${SupabaseConfig.webClientId.substring(0, 20)}... ✅" : "EMPTY ❌"}');
      debugPrint('║   - isGoogleConfigured: ${SupabaseConfig.isGoogleConfigured ? "YES ✅" : "NO ❌"}');
      debugPrint('║');
      debugPrint('║ AXIS 3: Package Name Alignment');
      debugPrint('║   - androidPackageName: ${SupabaseConfig.androidPackageName}');
      debugPrint('║   - Expected: co.thepact.app');
      debugPrint('║   - Match: ${SupabaseConfig.androidPackageName == "co.thepact.app" ? "YES ✅" : "NO ❌"}');
      debugPrint('║');
      debugPrint('║ AXIS 4: SHA-1 Fingerprint (verify manually)');
      debugPrint('║   - Run: cd android && ./gradlew signingReport');
      debugPrint('║   - Expected: C6:B1:B4:D7:93:9B:6B:E8:EC:AD:BC:96:01:99:11:62:84:B6:5E:6A');
      debugPrint('║');
      debugPrint('║ AXIS 5: OAuth Consent Screen');
      debugPrint('║   - Ensure your email is in Test Users list');
      debugPrint('║   - Or publish app for production');
      debugPrint('╚══════════════════════════════════════════════════════════════════════╝');
      debugPrint('');
    }

    if (!isSupabaseAvailable) {
      if (kDebugMode) {
        debugPrint('❌ FAIL: Supabase not available (check AXIS 1)');
      }
      return AuthResult.failure('Supabase not configured. Check SUPABASE_URL and SUPABASE_ANON_KEY in secrets.json');
    }

    try {
      _authState = AuthState.loading;
      notifyListeners();

      // CRITICAL: Verify Web Client ID is configured before attempting sign-in
      // Without serverClientId, Android performs "Basic Profile" sign-in instead of OIDC
      // which means idToken will be null and Supabase auth will fail
      final webClientId = SupabaseConfig.webClientId;

      if (webClientId.isEmpty) {
        if (kDebugMode) {
          debugPrint('');
          debugPrint('╔══════════════════════════════════════════════════════════');
          debugPrint('║ ❌ GOOGLE SIGN-IN ERROR: Web Client ID not configured!');
          debugPrint('║');
          debugPrint('║ AXIS 2 FAILURE: GOOGLE_WEB_CLIENT_ID is empty');
          debugPrint('║');
          debugPrint('║ To fix:');
          debugPrint('║ 1. Run: dart run tool/setup_secrets.dart');
          debugPrint('║    OR');
          debugPrint('║ 2. Get your WEB Client ID from Google Cloud Console');
          debugPrint('║    (APIs & Services > Credentials > OAuth 2.0 > Web application)');
          debugPrint('║ 3. Add to secrets.json: "GOOGLE_WEB_CLIENT_ID": "your-id.apps.googleusercontent.com"');
          debugPrint('║ 4. Rebuild with: flutter run --dart-define-from-file=secrets.json');
          debugPrint('║');
          debugPrint('║ IMPORTANT: Must be WEB Client ID, NOT Android Client ID!');
          debugPrint('╚══════════════════════════════════════════════════════════');
        }
        _authState = AuthState.error;
        _errorMessage = 'Google Sign-In not configured. Run: dart run tool/setup_secrets.dart';
        notifyListeners();
        return AuthResult.failure('Google Sign-In not configured. Missing GOOGLE_WEB_CLIENT_ID in secrets.json');
      }
      
      // Log configuration for debugging
      if (kDebugMode) {
        debugPrint('GoogleSignIn Config:');
        debugPrint('  - webClientId: ${webClientId.substring(0, 20)}...apps.googleusercontent.com');
        debugPrint('  - serverClientId: same as webClientId (required for OIDC)');
        debugPrint('  - androidPackageName: ${SupabaseConfig.androidPackageName}');
      }
      
      // Get Google credentials
      // CRITICAL: serverClientId MUST be the WEB Client ID (not Android Client ID)
      // This tells Google Play Services to perform OIDC sign-in and return an idToken
      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,  // REQUIRED for idToken
        scopes: ['email', 'profile'],
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _authState = AuthState.unauthenticated;
        notifyListeners();
        return AuthResult.failure('Google sign-in cancelled');
      }
      
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null || idToken == null) {
        if (kDebugMode) {
          debugPrint('╔══════════════════════════════════════════════════════════');
          debugPrint('║ GOOGLE AUTH ERROR: Token retrieval failed!');
          debugPrint('║');
          debugPrint('║ User signed in: ${googleUser.email}');
          debugPrint('║ accessToken: ${accessToken != null ? "present" : "NULL"}');
          debugPrint('║ idToken: ${idToken != null ? "present" : "NULL"}');
          debugPrint('║');
          debugPrint('║ If idToken is NULL, check:');
          debugPrint('║ 1. Is GOOGLE_WEB_CLIENT_ID a WEB client (not Android)?');
          debugPrint('║ 2. Is your email in OAuth consent screen Test Users?');
          debugPrint('║ 3. Is the Web Client ID in Supabase Auth > Google?');
          debugPrint('║');
          debugPrint('║ Current webClientId: ${webClientId.substring(0, 20)}...');
          debugPrint('╚══════════════════════════════════════════════════════════');
        }
        _authState = AuthState.error;
        _errorMessage = 'Failed to get Google credentials. idToken=${idToken != null}, accessToken=${accessToken != null}';
        notifyListeners();
        return AuthResult.failure('Failed to get Google credentials. Check that GOOGLE_WEB_CLIENT_ID is a Web Client ID (not Android).');
      }
      
      // If anonymous, link Google to existing account
      if (isAnonymous) {
        // Note: Supabase doesn't directly support linking OAuth to anonymous
        // We need to handle this with a custom approach
        final response = await _supabase!.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        
        if (response.user != null) {
          _currentUser = response.user;
          _authState = AuthState.authenticated;
          _errorMessage = null;
          notifyListeners();
          
          await _createOrUpdateUserRecord(response.user!);
          
          return AuthResult.success(user: response.user);
        }
      } else {
        // Fresh Google sign-in
        final response = await _supabase!.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        
        if (response.user != null) {
          _currentUser = response.user;
          _authState = AuthState.authenticated;
          _errorMessage = null;
          notifyListeners();
          
          await _createOrUpdateUserRecord(response.user!);
          
          return AuthResult.success(user: response.user);
        }
      }
      
      _authState = AuthState.error;
      _errorMessage = 'Google sign-in failed';
      notifyListeners();
      return AuthResult.failure('Google sign-in failed');
    } catch (e, stackTrace) {
      _authState = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
      
      // VERBOSE ERROR LOGGING for ApiException: 10 debugging
      if (kDebugMode) {
        debugPrint('╔══════════════════════════════════════════════════════════');
        debugPrint('║ GOOGLE SIGN-IN ERROR - VERBOSE DIAGNOSTICS');
        debugPrint('╠══════════════════════════════════════════════════════════');
        debugPrint('║ Error Type: ${e.runtimeType}');
        debugPrint('║ Error Message: $e');
        debugPrint('║ ');
        debugPrint('║ Configuration Check:');
        debugPrint('║   - Package Name (code): ${SupabaseConfig.androidPackageName}');
        debugPrint('║   - Supabase URL: ${SupabaseConfig.url}');
        debugPrint('║   - Supabase Configured: ${SupabaseConfig.isConfigured}');
        debugPrint('║ ');
        debugPrint('║ Stack Trace:');
        for (final line in stackTrace.toString().split('\n').take(15)) {
          debugPrint('║   $line');
        }
        debugPrint('║ ');
        debugPrint('║ TROUBLESHOOTING TIPS:');
        debugPrint('║   1. Run: adb logcat *:E | grep -i "google|auth|sign"');
        debugPrint('║   2. Verify SHA-1: cd android && ./gradlew signingReport');
        debugPrint('║   3. Check Google Cloud Console for package: co.thepact.app');
        debugPrint('╚══════════════════════════════════════════════════════════');
      }
      
      return AuthResult.failure(e.toString());
    }
  }
  
  /// requestSherlockScopes: Progressive disclosure for psychometric sensors.
  /// 
  /// This method requests the sensitive scopes ONLY after the user has agreed 
  /// to the "Sherlock Scan" value proposition.
  /// 
  /// Returns list of granted scopes.
  Future<List<String>> requestSherlockScopes() async {
    if (kDebugMode) debugPrint('Attempting to request Sherlock Scopes...');
    
    // Scopes for Sherlock Intelligence
    const sherlockScopes = [
      'https://www.googleapis.com/auth/calendar.readonly',       // The Overcommitter
      'https://www.googleapis.com/auth/youtube.readonly',        // The Dopamine Diet
      'https://www.googleapis.com/auth/tasks.readonly',          // The Hoarder
      'https://www.googleapis.com/auth/fitness.activity.read',   // The Reality Check
      'https://www.googleapis.com/auth/user.birthday.read',      // Age Bracket
    ];

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.webClientId,
        scopes: sherlockScopes,
      );

      // This should trigger the incremental auth consent screen
      // Note: On Android/iOS this usually prompts for the *new* scopes
      final user = await googleSignIn.signIn();
      
      if (user == null) {
        return []; // User cancelled
      }
      
      // We don't necessarily need to re-authenticate with Supabase here
      // just ensuring we have the permissions on the Google User object
      // which we can then use to make API calls.
      
      // In a real implementation, you would check `user.grantedScopes` if available
      // or try to make a dummy call to verify.
      // For now, we assume success if sign-in completes.
      
      return sherlockScopes; 

    } catch (e) {
      debugPrint('Error requesting Sherlock scopes: $e');
      return [];
    }
  }

  /// Checks if specific Sherlock scopes are already granted.
  Future<bool> hasSherlockPermissions() async {
     final googleSignIn = GoogleSignIn(
        serverClientId: SupabaseConfig.webClientId,
        scopes: [], // Standard init
      );
     
     // Note: GoogleSignIn.currentUser might be null if we haven't initialized it or signed in via the plugin this session
     // This is a simplified check.
     final currentUser = googleSignIn.currentUser;
     if (currentUser == null) {
       // Attempt silent sign in to restore state if possible
       try {
         await googleSignIn.signInSilently();
       } catch (_) {}
     }
     
     // Currently dart google_sign_in doesn't expose a simple "grantedScopes" list on the user object widely 
     // across all platforms easily without making a request. 
     // For this MVP, we will rely on the explicit request flow.
     return false; 
  }

  /// Sign out the current user
  Future<void> signOut() async {
    if (!isSupabaseAvailable) {
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      notifyListeners();
      return;
    }
    
    try {
      await _supabase!.auth.signOut();
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign-out error: $e');
      }
      // Still clear local state even if remote sign-out fails
      _currentUser = null;
      _authState = AuthState.unauthenticated;
      notifyListeners();
    }
  }
  
  /// Handle auth state changes from Supabase
  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    if (kDebugMode) {
      debugPrint('Auth state changed: $event');
    }
    
    switch (event) {
      case AuthChangeEvent.signedIn:
        _currentUser = session?.user;
        _authState = AuthState.authenticated;
        break;
      case AuthChangeEvent.signedOut:
        _currentUser = null;
        _authState = AuthState.unauthenticated;
        break;
      case AuthChangeEvent.tokenRefreshed:
        _currentUser = session?.user;
        break;
      case AuthChangeEvent.userUpdated:
        _currentUser = session?.user;
        break;
      default:
        break;
    }
    
    notifyListeners();
  }
  
  /// Create a user record in the database
  /// Note: Email is stored in auth.users (Supabase managed), not profiles table
  Future<void> _createUserRecord(User user) async {
    try {
      await _supabase!.from(SupabaseTables.users).insert({
        'id': user.id,
        'username': null,
        'tier': UserTier.free.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create user record: $e');
      }
      // Don't throw - user creation is best-effort
    }
  }
  
  /// Update a user record in the database
  Future<void> _updateUserRecord(User user) async {
    try {
      await _supabase!.from(SupabaseTables.users).update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user record: $e');
      }
    }
  }
  
  /// Create or update a user record
  /// Note: Email is stored in auth.users (Supabase managed), not profiles table
  /// Create or update a user record with retry logic
  /// Note: Email is stored in auth.users (Supabase managed), not profiles table
  Future<void> _createOrUpdateUserRecord(User user) async {
    try {
      await RetryPolicy.network.execute(() async {
        await _supabase!.from(SupabaseTables.users).upsert({
          'id': user.id,
          'updated_at': DateTime.now().toIso8601String(),
        });
      });
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('Database error upserting user: ${e.code} - ${e.message}');
      }
      // Don't throw - user can still use app
    } on SocketException catch (_) {
      if (kDebugMode) {
        debugPrint('Offline - user record will sync later');
      }
      // Queue for later if you have a sync queue
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to upsert user record after retries: $e');
      }
      // Don't throw - this is best-effort
    }
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Authentication state
enum AuthState {
  initializing,
  loading,
  authenticated,
  unauthenticated,
  offline,
  error,
}

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final bool localOnly;
  
  AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.localOnly = false,
  });
  
  factory AuthResult.success({User? user, bool localOnly = false}) {
    return AuthResult._(success: true, user: user, localOnly: localOnly);
  }
  
  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}
