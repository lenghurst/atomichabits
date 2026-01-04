import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/deep_link_config.dart';

/// Witness Deep Link Service
/// 
/// Phase 22: "The Witness" - Share Intent Handling
/// 
/// Specialized service for generating and sharing witness invites via:
/// 1. WhatsApp (Direct Deep Link) - Lowest friction
/// 2. System Share Sheet (Fallback) - specialized for other apps
class WitnessDeepLinkService {
  
  /// Share invite via WhatsApp directly to bypass system sheet
  /// 
  /// Uses `whatsapp://send?text=...` scheme
  /// Falls back to system share if WhatsApp not installed
  static Future<void> shareViaWhatsApp({
    required String text,
    Function(String error)? onError,
  }) async {
    try {
      // 1. Encode the text to be URL-safe
      final encodedText = Uri.encodeComponent(text);
      
      // 2. Construct the WhatsApp URL
      // Note: "whatsapp://send" works on both Android and iOS
      final uri = Uri.parse('whatsapp://send?text=$encodedText');
      
      // 3. Check if WhatsApp is installed/can be launched
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (kDebugMode) {
          debugPrint('WitnessDeepLinkService: WhatsApp not installed, falling back to system share');
        }
        // Fallback: System Share
        await shareViaSystem(text: text);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessDeepLinkService: Error launching WhatsApp: $e');
      }
      onError?.call(e.toString());
      // Last resort fallback
      await shareViaSystem(text: text);
    }
  }
  
  /// Share via system share sheet (Platform default)
  static Future<void> shareViaSystem({required String text}) async {
    try {
      await Share.share(text);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WitnessDeepLinkService: Error sharing via system: $e');
      }
    }
  }
  
  /// Generate the standard invite message text
  /// 
  /// Template:
  /// 🤝 I just made a commitment and I need you to hold me accountable!
  /// "[HABIT_NAME]" — starting [DATE]
  /// Accept my invite: [DEEP_LINK_URL]
  static String generateShareText({
    required String habitName,
    required String inviteCode,
    required DateTime startDate,
  }) {
    final deepLinkUrl = DeepLinkConfig.getContractInviteUrl(inviteCode);
    final dateStr = _formatDate(startDate);
    
    return '🤝 I just made a commitment and I need you to hold me accountable!\n\n'
           '"$habitName" — starting $dateStr\n\n'
           'Accept my invite: $deepLinkUrl';
  }
  
  /// Format date as "January 15, 2026"
  static String _formatDate(DateTime date) {
    // We don't have intl package in this snippet context usually, 
    // but standard list is safer if not available.
    // However, project likely has intl. 
    // Using manual mapping to be dependency-safe or standard formatting if available.
    // For safety without verifying intl dependency in this file generation:
    
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
