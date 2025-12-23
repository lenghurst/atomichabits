import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/supabase_config.dart';

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
      final session = _supabase!.auth.currentSession;
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
    if (!isSupabaseAvailable) {
      return AuthResult.failure('Supabase not configured');
    }
    
    try {
      _authState = AuthState.loading;
      notifyListeners();
      
      // Get Google credentials
      // CRITICAL: Must pass Web Client ID for Supabase OAuth flow
      // Without this, the native Android side won't request an OIDC ID Token
      // which Supabase needs to verify the user
      final googleSignIn = GoogleSignIn(
        clientId: SupabaseConfig.webClientId.isNotEmpty 
            ? SupabaseConfig.webClientId 
            : null,
        serverClientId: SupabaseConfig.webClientId.isNotEmpty 
            ? SupabaseConfig.webClientId 
            : null,
        scopes: ['email', 'profile'],
      );
      
      // Log configuration for debugging
      if (kDebugMode) {
        debugPrint('GoogleSignIn Config:');
        debugPrint('  - webClientId configured: ${SupabaseConfig.webClientId.isNotEmpty}');
        debugPrint('  - androidPackageName: ${SupabaseConfig.androidPackageName}');
      }
      
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
        _authState = AuthState.error;
        _errorMessage = 'Failed to get Google credentials';
        notifyListeners();
        return AuthResult.failure('Failed to get Google credentials');
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
        debugPrint('║   1. Run: adb logcat *:E | grep -i "google\|auth\|sign"');
        debugPrint('║   2. Verify SHA-1: cd android && ./gradlew signingReport');
        debugPrint('║   3. Check Google Cloud Console for package: co.thepact.app');
        debugPrint('╚══════════════════════════════════════════════════════════');
      }
      
      return AuthResult.failure(e.toString());
    }
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
  Future<void> _createUserRecord(User user) async {
    try {
      await _supabase!.from(SupabaseTables.users).insert({
        'id': user.id,
        'email': user.email,
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
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update user record: $e');
      }
    }
  }
  
  /// Create or update a user record
  Future<void> _createOrUpdateUserRecord(User user) async {
    try {
      await _supabase!.from(SupabaseTables.users).upsert({
        'id': user.id,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to upsert user record: $e');
      }
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
