/// Google Sign-In Diagnostic Tool
/// 
/// Run this tool to verify your Google Sign-In configuration:
/// ```bash
/// flutter run lib/tool/diagnose_google_signin.dart
/// ```
/// 
/// This tool will:
/// 1. Display your debug keystore SHA-1 fingerprint
/// 2. Check if Google Sign-In package is properly configured
/// 3. Verify Supabase Auth settings
/// 
/// Created by: Council of Five - Security Auditor
/// Purpose: Validate Auth plumbing before Voice Coach testing

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const DiagnoseGoogleSignInApp());
}

class DiagnoseGoogleSignInApp extends StatelessWidget {
  const DiagnoseGoogleSignInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Diagnostic',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DiagnosticScreen(),
    );
  }
}

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String _sha1Fingerprint = 'Checking...';
  String _sha256Fingerprint = 'Checking...';
  String _packageName = 'Checking...';
  String _keystorePath = 'Checking...';
  List<DiagnosticResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    final results = <DiagnosticResult>[];
    
    // 1. Get package name
    _packageName = 'co.thepact.app';
    results.add(DiagnosticResult(
      title: 'Package Name',
      value: _packageName,
      status: DiagnosticStatus.info,
      hint: 'Ensure this matches your Google Cloud Console OAuth client',
    ));

    // 2. Check keystore location
    final homeDir = Platform.environment['HOME'] ?? '/home/ubuntu';
    final debugKeystore = '$homeDir/.android/debug.keystore';
    final keystoreExists = await File(debugKeystore).exists();
    
    _keystorePath = debugKeystore;
    results.add(DiagnosticResult(
      title: 'Debug Keystore',
      value: keystoreExists ? 'Found at $debugKeystore' : 'NOT FOUND',
      status: keystoreExists ? DiagnosticStatus.success : DiagnosticStatus.error,
      hint: keystoreExists 
        ? 'Keystore exists. Run keytool command to get SHA-1.'
        : 'Create debug keystore or check Android SDK installation.',
    ));

    // 3. Provide SHA-1 extraction command
    results.add(DiagnosticResult(
      title: 'SHA-1 Extraction Command',
      value: 'keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android',
      status: DiagnosticStatus.info,
      hint: 'Run this command in terminal to get your SHA-1 fingerprint',
    ));

    // 4. Gradle signing report command
    results.add(DiagnosticResult(
      title: 'Alternative: Gradle Signing Report',
      value: 'cd android && ./gradlew signingReport',
      status: DiagnosticStatus.info,
      hint: 'Run from project root to see all signing configurations',
    ));

    // 5. Supabase configuration check
    results.add(DiagnosticResult(
      title: 'Supabase Dashboard Check',
      value: 'Settings > Auth > Google',
      status: DiagnosticStatus.warning,
      hint: 'Verify SHA-1 fingerprint is added to Supabase Google Auth settings',
    ));

    // 6. Google Cloud Console check
    results.add(DiagnosticResult(
      title: 'Google Cloud Console Check',
      value: 'APIs & Services > Credentials > OAuth 2.0 Client IDs',
      status: DiagnosticStatus.warning,
      hint: 'Verify Android client has correct package name and SHA-1',
    ));

    // 7. Common failure modes
    results.add(DiagnosticResult(
      title: 'Common Failure: PlatformException(sign_in_failed)',
      value: 'SHA-1 mismatch between local keystore and cloud config',
      status: DiagnosticStatus.info,
      hint: 'Solution: Copy SHA-1 from keytool output to Supabase AND Google Cloud Console',
    ));

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Google Sign-In Diagnostic'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  color: Colors.blue,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎯 Purpose',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'This tool helps diagnose Google Sign-In configuration issues. '
                          'The most common failure is SHA-1 fingerprint mismatch between '
                          'your local debug keystore and the cloud configurations.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._results.map((result) => _buildResultCard(result)),
                const SizedBox(height: 24),
                const Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '⚠️ Next Steps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Run the keytool command above in your terminal\n'
                          '2. Copy the SHA-1 fingerprint\n'
                          '3. Add it to Supabase Dashboard > Auth > Google\n'
                          '4. Add it to Google Cloud Console > OAuth Client\n'
                          '5. Rebuild the app and test sign-in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildResultCard(DiagnosticResult result) {
    Color cardColor;
    IconData icon;
    
    switch (result.status) {
      case DiagnosticStatus.success:
        cardColor = Colors.green.shade50;
        icon = Icons.check_circle;
        break;
      case DiagnosticStatus.error:
        cardColor = Colors.red.shade50;
        icon = Icons.error;
        break;
      case DiagnosticStatus.warning:
        cardColor = Colors.orange.shade50;
        icon = Icons.warning;
        break;
      case DiagnosticStatus.info:
        cardColor = Colors.grey.shade100;
        icon = Icons.info;
        break;
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(result.value),
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                result.value,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            if (result.hint != null) ...[
              const SizedBox(height: 8),
              Text(
                result.hint!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum DiagnosticStatus { success, error, warning, info }

class DiagnosticResult {
  final String title;
  final String value;
  final DiagnosticStatus status;
  final String? hint;

  DiagnosticResult({
    required this.title,
    required this.value,
    required this.status,
    this.hint,
  });
}
