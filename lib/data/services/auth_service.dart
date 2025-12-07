import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Result of an authentication operation
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.failure(String message) => AuthResult(
        success: false,
        errorMessage: message,
      );
}

/// Service for handling Firebase Authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current user (null if not signed in)
  User? get currentUser => _auth.currentUser;

  /// Whether user is signed in
  bool get isSignedIn => currentUser != null;

  /// Whether current user is anonymous (guest)
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  /// User's display name
  String? get displayName => currentUser?.displayName;

  /// User's email
  String? get email => currentUser?.email;

  /// User's photo URL
  String? get photoUrl => currentUser?.photoURL;

  /// User's unique ID
  String? get userId => currentUser?.uid;

  // ============ Email/Password Authentication ============

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign up error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  // ============ Google Sign In ============

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return AuthResult.failure('Sign in cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return AuthResult.failure('Failed to sign in with Google');
    }
  }

  // ============ Anonymous (Guest) Authentication ============

  /// Sign in anonymously as a guest
  Future<AuthResult> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      return AuthResult.success(credential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Anonymous sign in error: $e');
      return AuthResult.failure('Failed to continue as guest');
    }
  }

  /// Link anonymous account to email/password
  Future<AuthResult> linkAnonymousToEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (currentUser == null || !currentUser!.isAnonymous) {
        return AuthResult.failure('No anonymous user to link');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential =
          await currentUser!.linkWithCredential(credential);

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Link account error: $e');
      return AuthResult.failure('Failed to link account');
    }
  }

  /// Link anonymous account to Google
  Future<AuthResult> linkAnonymousToGoogle() async {
    try {
      if (currentUser == null || !currentUser!.isAnonymous) {
        return AuthResult.failure('No anonymous user to link');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await currentUser!.linkWithCredential(credential);

      return AuthResult.success(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Link to Google error: $e');
      return AuthResult.failure('Failed to link to Google');
    }
  }

  // ============ Sign Out ============

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // ============ Account Management ============

  /// Delete the current user's account
  Future<AuthResult> deleteAccount() async {
    try {
      if (currentUser == null) {
        return AuthResult.failure('No user signed in');
      }

      await currentUser!.delete();
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return AuthResult.failure(
          'Please sign out and sign in again before deleting your account',
        );
      }
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Delete account error: $e');
      return AuthResult.failure('Failed to delete account');
    }
  }

  /// Update user's display name
  Future<AuthResult> updateDisplayName(String name) async {
    try {
      if (currentUser == null) {
        return AuthResult.failure('No user signed in');
      }

      await currentUser!.updateDisplayName(name);
      return AuthResult.success(currentUser!);
    } catch (e) {
      debugPrint('Update display name error: $e');
      return AuthResult.failure('Failed to update name');
    }
  }

  // ============ Helper Methods ============

  /// Convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String code) {
    switch (code) {
      // Email/Password errors
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      // Google Sign In errors
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';

      // Network errors
      case 'network-request-failed':
        return 'Network error. Please check your connection.';

      // Anonymous linking errors
      case 'credential-already-in-use':
        return 'This credential is already linked to another account.';
      case 'provider-already-linked':
        return 'This account is already linked.';

      default:
        return 'An error occurred. Please try again.';
    }
  }
}
