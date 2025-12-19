import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Feedback Service
/// 
/// Phase 20: "Destroyer Defense" - Risk Mitigation for High Performers
/// 
/// The Strategy:
/// 1. Bug Bounty: Find a bug → Get credited in CREDITS.md
/// 2. Roast Channel: Private venting before public destruction
/// 3. Alpha Shield: Manage expectations with prominent beta labels
/// 
/// Psychology: "If you ask for the roast, they feel heard, and the
/// anger dissipates before it hits public channels."
class FeedbackService {
  // === Configuration ===
  
  /// Email for bug reports and roasts
  /// Primary feedback channel - direct, personal, no account needed
  static const String feedbackEmail = 'support@thepact.co';
  
  /// Discord invite link
  /// NOTE: Intentionally null - email is the preferred feedback channel
  /// for direct, personal communication. Discord may be added later for
  /// community features but is not needed for Destroyer Defense.
  static const String? discordInvite = null;
  
  /// GitHub issues URL (if public)
  static const String? githubIssues = 'https://github.com/lenghurst/atomichabits/issues';
  
  /// App version info
  static PackageInfo? _packageInfo;
  
  /// Device info
  static String? _deviceInfo;
  
  /// Initialize service (call once at app start)
  static Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _deviceInfo = await _getDeviceInfo();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FeedbackService: Failed to get device info: $e');
      }
    }
  }
  
  /// Get device information for bug reports
  static Future<String> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return 'Android ${info.version.release} (SDK ${info.version.sdkInt})\n'
               '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return 'iOS ${info.systemVersion}\n'
               '${info.model}';
      }
    } catch (e) {
      // Fallback for web or other platforms
    }
    
    return 'Unknown Device';
  }
  
  /// Get app version string
  static String get appVersion {
    if (_packageInfo == null) return 'Unknown';
    return '${_packageInfo!.version}+${_packageInfo!.buildNumber}';
  }
  
  /// Generate bug report template
  static String generateBugReportTemplate({
    String? description,
    String? stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    String? userHandle,
  }) {
    return '''
🐛 BUG REPORT — The Pact

**App Version:** $appVersion
**Device:** ${_deviceInfo ?? 'Unknown'}
**Date:** ${DateTime.now().toIso8601String()}

---

**Reporter Handle (for CREDITS.md):**
${userHandle ?? '[Your name/handle here]'}

---

**Description:**
${description ?? '[What went wrong?]'}

**Steps to Reproduce:**
${stepsToReproduce ?? '''
1. [First step]
2. [Second step]
3. [Bug appears]
'''}

**Expected Behavior:**
${expectedBehavior ?? '[What should have happened?]'}

**Actual Behavior:**
${actualBehavior ?? '[What actually happened?]'}

---

*Thank you for helping improve the app! Your name will be added to CREDITS.md.*
''';
  }
  
  /// Generate roast template (spicier version)
  static String generateRoastTemplate({
    String? roast,
    String? suggestion,
    String? userHandle,
  }) {
    return '''
🔥 ROAST THE DEVELOPER — The Pact

**App Version:** $appVersion
**Device:** ${_deviceInfo ?? 'Unknown'}
**Date:** ${DateTime.now().toIso8601String()}

---

**Your Handle (for Hall of Roasts):**
${userHandle ?? '[Your name/handle here]'}

---

**The Roast:**
${roast ?? '[Tell me why this sucks. Be honest. Be brutal. Be constructive.]'}

**What Would Make It Not Suck:**
${suggestion ?? '[If you were the developer, what would you do differently?]'}

---

**Severity of Anger (1-10):** [  ]

**Would you recommend this app to an enemy?** [ ] Yes [ ] No [ ] Only if I hated them

---

*If your roast leads to a fix, you'll be immortalized in the Hall of Roasts.*
*Thank you for caring enough to be angry.*
''';
  }
  
  /// Open email client with bug report
  static Future<bool> sendBugReport({
    String? description,
    String? userHandle,
  }) async {
    final subject = Uri.encodeComponent('🐛 Bug Report: The Pact v$appVersion');
    final body = Uri.encodeComponent(generateBugReportTemplate(
      description: description,
      userHandle: userHandle,
    ));
    
    final uri = Uri.parse('mailto:$feedbackEmail?subject=$subject&body=$body');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FeedbackService: Failed to launch email: $e');
      }
    }
    
    return false;
  }
  
  /// Open email client with roast template
  static Future<bool> sendRoast({
    String? roast,
    String? userHandle,
  }) async {
    final subject = Uri.encodeComponent('🔥 Roast: The Pact v$appVersion');
    final body = Uri.encodeComponent(generateRoastTemplate(
      roast: roast,
      userHandle: userHandle,
    ));
    
    final uri = Uri.parse('mailto:$feedbackEmail?subject=$subject&body=$body');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FeedbackService: Failed to launch email: $e');
      }
    }
    
    return false;
  }
  
  /// Open GitHub issues (if available)
  static Future<bool> openGitHubIssues() async {
    if (githubIssues == null) return false;
    
    final uri = Uri.parse(githubIssues!);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FeedbackService: Failed to open GitHub: $e');
      }
    }
    
    return false;
  }
  
  /// Open Discord server (if available)
  static Future<bool> openDiscord() async {
    if (discordInvite == null) return false;
    
    final uri = Uri.parse(discordInvite!);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FeedbackService: Failed to open Discord: $e');
      }
    }
    
    return false;
  }
  
  /// Copy bug report to clipboard (fallback)
  static Future<void> copyBugReportToClipboard({
    String? description,
    String? userHandle,
  }) async {
    final template = generateBugReportTemplate(
      description: description,
      userHandle: userHandle,
    );
    
    await Clipboard.setData(ClipboardData(text: template));
  }
  
  /// Copy roast to clipboard (fallback)
  static Future<void> copyRoastToClipboard({
    String? roast,
    String? userHandle,
  }) async {
    final template = generateRoastTemplate(
      roast: roast,
      userHandle: userHandle,
    );
    
    await Clipboard.setData(ClipboardData(text: template));
  }
}

/// Build status for Alpha Shield
enum BuildStatus {
  alpha,
  beta,
  releaseCandidate,
  production,
}

/// Alpha Shield Configuration
/// 
/// Manages expectations with prominent build status indicators.
/// "They will forgive ugly UI. They will not forgive data loss."
class AlphaShieldConfig {
  /// Current build status
  static const BuildStatus status = BuildStatus.alpha;
  
  /// Whether to show the alpha banner
  static const bool showBanner = true;
  
  /// Banner message based on status
  static String get bannerMessage {
    switch (status) {
      case BuildStatus.alpha:
        return 'ALPHA BUILD: Graceful Consistency Engine Active. UI is temporary.';
      case BuildStatus.beta:
        return 'BETA BUILD: Core features complete. Help us find bugs!';
      case BuildStatus.releaseCandidate:
        return 'RELEASE CANDIDATE: Final testing. Report any issues!';
      case BuildStatus.production:
        return ''; // No banner in production
    }
  }
  
  /// Banner color based on status
  static int get bannerColorValue {
    switch (status) {
      case BuildStatus.alpha:
        return 0xFFFF6B6B; // Coral red
      case BuildStatus.beta:
        return 0xFFFFD93D; // Warning yellow
      case BuildStatus.releaseCandidate:
        return 0xFF6BCB77; // Success green
      case BuildStatus.production:
        return 0x00000000; // Transparent
    }
  }
  
  /// Disclaimer for alpha/beta users
  static const String disclaimer = '''
This is an early access build of The Pact.

What to expect:
✅ Core habit tracking works
✅ Cloud sync enabled (your data is safe)
✅ AI coaching functional
⚠️ UI may be rough in places
⚠️ Some features are incomplete

What we need from you:
🐛 Report bugs → Settings → "Report a Bug"
🔥 Honest feedback → Settings → "Roast the Developer"
📣 Your name in CREDITS.md for helping!

Thank you for being a Founding Tester!
''';
  
  /// Short disclaimer for splash screen
  static const String shortDisclaimer = 
      'Alpha Build • Your data is safe • Help us improve';
}
