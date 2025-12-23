// tool/diagnose_google_signin.dart
//
// Phase 27.25: Google Sign-In Five-Axis Diagnostic Tool
//
// This script performs a comprehensive check of all configuration
// required for Google Sign-In to work properly.
//
// Usage: dart run tool/diagnose_google_signin.dart
//
// Run this BEFORE attempting Google Sign-In to identify issues.

import 'dart:io';
import 'dart:convert';

void main() async {
  print('');
  print('╔═══════════════════════════════════════════════════════════════════════╗');
  print('║     GOOGLE SIGN-IN DIAGNOSTIC - FIVE AXIS VERIFICATION TOOL           ║');
  print('╚═══════════════════════════════════════════════════════════════════════╝');
  print('');

  var allPassed = true;
  final issues = <String>[];
  final fixes = <String>[];

  // ════════════════════════════════════════════════════════════════════════════
  // AXIS 1: secrets.json File Existence and Content
  // ════════════════════════════════════════════════════════════════════════════
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('AXIS 1: Configuration File (secrets.json)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  final secretsFile = File('secrets.json');
  Map<String, dynamic>? secrets;

  if (!secretsFile.existsSync()) {
    print('   ❌ secrets.json: FILE NOT FOUND');
    allPassed = false;
    issues.add('secrets.json file does not exist');
    fixes.add('Run: dart run tool/setup_secrets.dart');
  } else {
    print('   ✅ secrets.json: exists');
    try {
      final content = secretsFile.readAsStringSync();
      secrets = jsonDecode(content) as Map<String, dynamic>;
      print('   ✅ secrets.json: valid JSON');

      // Check required keys
      final requiredKeys = [
        'SUPABASE_URL',
        'SUPABASE_ANON_KEY',
        'GOOGLE_WEB_CLIENT_ID',
      ];

      for (final key in requiredKeys) {
        if (!secrets.containsKey(key) || secrets[key].toString().isEmpty) {
          print('   ❌ $key: MISSING or EMPTY');
          allPassed = false;
          issues.add('$key is missing or empty in secrets.json');
          fixes.add('Add "$key" to secrets.json');
        } else {
          final value = secrets[key].toString();
          final preview = value.length > 20 ? '${value.substring(0, 20)}...' : value;
          print('   ✅ $key: $preview');
        }
      }
    } catch (e) {
      print('   ❌ secrets.json: INVALID JSON - $e');
      allPassed = false;
      issues.add('secrets.json contains invalid JSON');
      fixes.add('Fix the JSON syntax in secrets.json');
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  // AXIS 2: Web Client ID Format Validation
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('AXIS 2: Google Web Client ID Validation');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (secrets != null && secrets.containsKey('GOOGLE_WEB_CLIENT_ID')) {
    final webClientId = secrets['GOOGLE_WEB_CLIENT_ID'].toString();

    if (!webClientId.endsWith('.apps.googleusercontent.com')) {
      print('   ❌ Format: Does not end with .apps.googleusercontent.com');
      allPassed = false;
      issues.add('GOOGLE_WEB_CLIENT_ID has invalid format');
      fixes.add('Ensure GOOGLE_WEB_CLIENT_ID ends with .apps.googleusercontent.com');
    } else {
      print('   ✅ Format: Valid (ends with .apps.googleusercontent.com)');
    }

    // Check if it might be an Android client ID (contains package name pattern)
    if (webClientId.contains('android:')) {
      print('   ⚠️  WARNING: This looks like an Android Client ID, not a Web Client ID');
      print('   ⚠️  You need the WEB application client ID for OIDC token handshake');
      issues.add('GOOGLE_WEB_CLIENT_ID appears to be an Android Client ID');
      fixes.add('Use the Web application Client ID from Google Cloud Console');
    }
  } else {
    print('   ⏭️  Skipped (no GOOGLE_WEB_CLIENT_ID found)');
  }

  // ════════════════════════════════════════════════════════════════════════════
  // AXIS 3: Package Name Alignment
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('AXIS 3: Package Name Alignment');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  const expectedPackage = 'co.thepact.app';

  // Check build.gradle.kts
  final buildGradle = File('android/app/build.gradle.kts');
  if (buildGradle.existsSync()) {
    final content = buildGradle.readAsStringSync();
    final applicationIdMatch = RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(content);
    if (applicationIdMatch != null) {
      final packageName = applicationIdMatch.group(1);
      if (packageName == expectedPackage) {
        print('   ✅ build.gradle.kts: applicationId = "$packageName"');
      } else {
        print('   ❌ build.gradle.kts: applicationId = "$packageName" (expected: $expectedPackage)');
        allPassed = false;
        issues.add('Package name mismatch in build.gradle.kts');
        fixes.add('Change applicationId to "$expectedPackage" in build.gradle.kts');
      }
    }
  } else {
    print('   ❌ build.gradle.kts: FILE NOT FOUND');
  }

  // Check supabase_config.dart
  final supabaseConfig = File('lib/config/supabase_config.dart');
  if (supabaseConfig.existsSync()) {
    final content = supabaseConfig.readAsStringSync();
    final packageMatch = RegExp(r"androidPackageName\s*=\s*'([^']+)'").firstMatch(content);
    if (packageMatch != null) {
      final packageName = packageMatch.group(1);
      if (packageName == expectedPackage) {
        print('   ✅ supabase_config.dart: androidPackageName = "$packageName"');
      } else {
        print('   ❌ supabase_config.dart: androidPackageName = "$packageName" (expected: $expectedPackage)');
        allPassed = false;
        issues.add('Package name mismatch in supabase_config.dart');
        fixes.add('Change androidPackageName to "$expectedPackage" in supabase_config.dart');
      }
    }
  } else {
    print('   ❌ supabase_config.dart: FILE NOT FOUND');
  }

  print('   📋 Google Cloud Console: Verify package is "$expectedPackage"');

  // ════════════════════════════════════════════════════════════════════════════
  // AXIS 4: SHA-1 Fingerprint
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('AXIS 4: SHA-1 Fingerprint (Manual Verification Required)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('   📋 Expected SHA-1: C6:B1:B4:D7:93:9B:6B:E8:EC:AD:BC:96:01:99:11:62:84:B6:5E:6A');
  print('');
  print('   To verify your current SHA-1:');
  print('   1. Run: cd android && ./gradlew signingReport');
  print('   2. Look for "SHA1:" under "Variant: debug"');
  print('   3. Compare to Google Cloud Console > Credentials > Android OAuth Client');
  print('');
  print('   ⚠️  If you are on a DIFFERENT MACHINE than where the SHA-1 was generated,');
  print('   ⚠️  you MUST add your machine\'s SHA-1 to Google Cloud Console.');

  // ════════════════════════════════════════════════════════════════════════════
  // AXIS 5: OAuth Consent Screen
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('AXIS 5: OAuth Consent Screen (Manual Verification Required)');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  print('   Check in Google Cloud Console > APIs & Services > OAuth consent screen:');
  print('');
  print('   1. Publishing status:');
  print('      - "Testing": Only Test Users can sign in');
  print('      - "In production": Anyone can sign in');
  print('');
  print('   2. If in "Testing" mode:');
  print('      - Your email MUST be in the "Test users" list');
  print('      - Add test users: OAuth consent screen > Test users > Add users');

  // ════════════════════════════════════════════════════════════════════════════
  // BONUS: Build Command Check
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('BONUS: Correct Build Command');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');
  print('   ✅ CORRECT build command:');
  print('      flutter clean && flutter pub get && flutter build apk --dart-define-from-file=secrets.json');
  print('');
  print('   ❌ WRONG (missing && before flutter build):');
  print('      flutter clean && flutter pub get flutter build apk --dart-define-from-file=secrets.json');
  print('');
  print('   ✅ CORRECT run command:');
  print('      flutter run --dart-define-from-file=secrets.json');

  // ════════════════════════════════════════════════════════════════════════════
  // SUMMARY
  // ════════════════════════════════════════════════════════════════════════════
  print('');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('DIAGNOSTIC SUMMARY');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  if (issues.isEmpty) {
    print('');
    print('   ✅ ALL AUTOMATED CHECKS PASSED');
    print('');
    print('   Manual verification still required for:');
    print('   - SHA-1 fingerprint (AXIS 4)');
    print('   - OAuth consent screen Test Users (AXIS 5)');
    print('');
  } else {
    print('');
    print('   ❌ ${issues.length} ISSUE(S) FOUND:');
    print('');
    for (var i = 0; i < issues.length; i++) {
      print('   ${i + 1}. ${issues[i]}');
      print('      FIX: ${fixes[i]}');
      print('');
    }
  }

  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  print('');

  exit(allPassed ? 0 : 1);
}
