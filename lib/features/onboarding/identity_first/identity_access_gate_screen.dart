import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/app_state.dart';
import '../../../data/services/auth_service.dart';
import '../../../utils/developer_logger.dart';

/// Identity Access Gate Screen
/// 
/// The first onboarding screen based on Figma designs.
/// Features:
/// - Identity declaration: "Who are you committed to becoming?"
/// - OAuth authentication (Google, Apple)
/// - Email fallback authentication
/// - Developer Mode toggle (top-left corner)
/// 
/// Design System:
/// - Colors: Slate Gray (#334155), Electric Green (#22C55E)
/// - Typography: Bold hierarchy, Inter font
/// - Layout: Asymmetric, bold accents
class IdentityAccessGateScreen extends StatefulWidget {
  const IdentityAccessGateScreen({super.key});

  @override
  State<IdentityAccessGateScreen> createState() => _IdentityAccessGateScreenState();
}

class _IdentityAccessGateScreenState extends State<IdentityAccessGateScreen> {
  final _identityController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _showEmailAuth = false;
  bool _isSignUp = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identityController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    DevLog.voice('User initiated Google Sign-In');

    try {
      final authService = context.read<AuthService>();
      final result = await authService.signInWithGoogle();

      if (result.success && mounted) {
        DevLog.voice('✅ Google Sign-In successful');
        // Save identity to user profile
        if (_identityController.text.isNotEmpty) {
          final appState = context.read<AppState>();
          final profile = appState.userProfile.copyWith(
            identity: _identityController.text.trim(),
          );
          await appState.updateUserProfile(profile);
        }
        
        // Navigate to next onboarding screen
        context.go('/onboarding/witness');
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Google sign-in failed';
        });
        DevLog.error('❌ Google Sign-In failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      DevLog.error('❌ Google Sign-In error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    DevLog.voice('User initiated Email Auth (${_isSignUp ? "Sign Up" : "Sign In"})');

    try {
      final authService = context.read<AuthService>();
      final result = _isSignUp
          ? await authService.upgradeWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await authService.signInWithEmail(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

      if (result.success && mounted) {
        DevLog.voice('✅ Email Auth successful');
        // Save identity
        if (_identityController.text.isNotEmpty) {
          final appState = context.read<AppState>();
          final profile = appState.userProfile.copyWith(
            identity: _identityController.text.trim(),
          );
          await appState.updateUserProfile(profile);
        }
        
        context.go('/onboarding/witness');
      } else {
        setState(() {
          _errorMessage = result.error ?? 'Authentication failed';
        });
        DevLog.error('❌ Email Auth failed: ${result.error}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      DevLog.error('❌ Email Auth error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleDeveloperMode() {
    final appState = context.read<AppState>();
    final newSettings = appState.settings.copyWith(
      developerMode: !appState.settings.developerMode,
    );
    appState.updateSettings(newSettings);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.settings.developerMode 
              ? 'Developer Mode Disabled' 
              : 'Developer Mode Enabled',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDeveloperMode = appState.settings.developerMode;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: Stack(
        children: [
          // Background gradient accents
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 384,
              height: 384,
              decoration: BoxDecation(
                color: const Color(0xFF06B6D4).withOpacity(0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF06B6D4).withOpacity(0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Developer Mode Toggle (top-left)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand mark
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      
                      // Developer Mode Toggle
                      GestureDetector(
                        onTap: _toggleDeveloperMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDeveloperMode
                                ? const Color(0xFF22C55E).withOpacity(0.2)
                                : const Color(0xFF1E293B),
                            border: Border.all(
                              color: isDeveloperMode
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF334155),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.code,
                                size: 16,
                                color: isDeveloperMode
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'DEV',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDeveloperMode
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Identity Declaration Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Identity First" badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          border: Border.all(color: const Color(0xFF334155)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'IDENTITY FIRST',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22C55E),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Main headline
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -0.02,
                            color: Color(0xFFF8FAFC),
                          ),
                          children: [
                            TextSpan(text: 'Who are you '),
                            TextSpan(
                              text: 'committed',
                              style: TextStyle(color: Color(0xFF22C55E)),
                            ),
                            TextSpan(text: ' to becoming?'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Identity input
                      TextField(
                        controller: _identityController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF8FAFC),
                          letterSpacing: -0.01,
                        ),
                        decoration: InputDecoration(
                          hintText: 'A Runner',
                          hintStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569).withOpacity(0.6),
                            letterSpacing: -0.01,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF334155),
                              width: 2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF334155),
                              width: 2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF22C55E),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Subtext
                      const Text(
                        'This isn\'t just a login. It\'s the first step in becoming that person.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF94A3B8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Authentication Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF334155).withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // "Secure Your Commitment" label
                      const Text(
                        'SECURE YOUR COMMITMENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Error message
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626).withOpacity(0.1),
                            border: Border.all(color: const Color(0xFFDC2626)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // OAuth or Email Auth
                      if (!_showEmailAuth) ...[
                        // Google Sign-In Button
                        _OAuthButton(
                          onPressed: _isLoading ? null : _handleGoogleSignIn,
                          icon: Icons.g_mobiledata,
                          label: 'Continue with Google',
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 16),

                        // "Use email instead" button
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showEmailAuth = true;
                            });
                          },
                          icon: const Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          label: const Text(
                            'Use email instead',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Email Auth Form
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Email address',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF22C55E),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFF22C55E),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Submit button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0F172A),
                                    ),
                                  ),
                                )
                              : Text(
                                  _isSignUp ? 'Create Account' : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Toggle sign up/sign in
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign in'
                                : 'Need an account? Sign up',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isLoading;

  const _OAuthButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: const Color(0xFFF8FAFC),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF8FAFC)),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}
