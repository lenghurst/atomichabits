import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

/// Sound Service - Phase 18: "The Pulse"
/// 
/// Manages audio feedback for habit interactions.
/// "Juice it or lose it" - satisfying sounds make the app feel alive.
/// 
/// Sound Design Philosophy:
/// - Completion: Heavy, satisfying "clunk" - like closing a vault
/// - Recovery: Rising, triumphant tone - celebrating resilience  
/// - Contract Sign: Tick-tick-thud - building anticipation + confirmation
/// - Error: Soft, non-judgmental tone - mistakes happen
class SoundService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  
  bool _isEnabled = true;
  bool _isInitialized = false;
  
  /// Whether sound effects are enabled
  bool get isEnabled => _isEnabled;
  
  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the sound service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configure audio player for low latency
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      
      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('🔊 SoundService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔊 SoundService initialization failed: $e');
      }
    }
  }
  
  /// Enable or disable sound effects
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    notifyListeners();
    if (kDebugMode) {
      debugPrint('🔊 Sound ${enabled ? "enabled" : "disabled"}');
    }
  }
  
  /// Play completion sound - The satisfying "clunk"
  /// Used when: Habit completed, goal achieved
  Future<void> playComplete() async {
    await _playSound(SoundType.complete);
  }
  
  /// Play recovery sound - The triumphant rise
  /// Used when: Never Miss Twice recovery, getting back on track
  Future<void> playRecover() async {
    await _playSound(SoundType.recover);
  }
  
  /// Play contract sign sound - The commitment confirmation
  /// Used when: Contract created, witness joined
  Future<void> playSign() async {
    await _playSound(SoundType.sign);
  }
  
  /// Play nudge sound - The gentle reminder
  /// Used when: Witness sends nudge
  Future<void> playNudge() async {
    await _playSound(SoundType.nudge);
  }
  
  /// Play chain reaction sound - The momentum builder
  /// Used when: Stacked habit prompt appears
  Future<void> playChainReaction() async {
    await _playSound(SoundType.chainReaction);
  }
  
  /// Play success celebration sound
  /// Used when: Streak milestone, achievement unlocked
  Future<void> playCelebrate() async {
    await _playSound(SoundType.celebrate);
  }
  
  /// Internal method to play a sound
  Future<void> _playSound(SoundType type) async {
    if (!_isEnabled) return;
    
    try {
      final assetPath = _getSoundPath(type);
      
      // Check if the sound file exists
      try {
        await rootBundle.load('assets/sounds/$assetPath');
        await _player.play(AssetSource('sounds/$assetPath'));
        
        if (kDebugMode) {
          debugPrint('🔊 Playing: $assetPath');
        }
      } catch (e) {
        // Sound file doesn't exist, use system sound fallback
        if (kDebugMode) {
          debugPrint('🔊 Sound file not found: $assetPath, using system fallback');
        }
        _playSystemSound(type);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🔊 Sound playback error: $e');
      }
    }
  }
  
  /// Get the asset path for a sound type
  String _getSoundPath(SoundType type) {
    switch (type) {
      case SoundType.complete:
        return 'complete.mp3';
      case SoundType.recover:
        return 'recover.mp3';
      case SoundType.sign:
        return 'sign.mp3';
      case SoundType.nudge:
        return 'nudge.mp3';
      case SoundType.chainReaction:
        return 'chain.mp3';
      case SoundType.celebrate:
        return 'celebrate.mp3';
    }
  }
  
  /// Fallback to system haptic when sound file is missing
  void _playSystemSound(SoundType type) {
    // Use haptic feedback as fallback sound
    switch (type) {
      case SoundType.complete:
      case SoundType.celebrate:
        HapticFeedback.heavyImpact();
        break;
      case SoundType.recover:
      case SoundType.chainReaction:
        HapticFeedback.mediumImpact();
        break;
      case SoundType.sign:
        // Simulate tick-tick-thud with rapid haptics
        Future.delayed(Duration.zero, () => HapticFeedback.selectionClick());
        Future.delayed(const Duration(milliseconds: 100), () => HapticFeedback.selectionClick());
        Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
        break;
      case SoundType.nudge:
        HapticFeedback.lightImpact();
        break;
    }
  }
  
  /// Dispose of resources
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

/// Types of sounds in the app
enum SoundType {
  /// Habit completion - satisfying clunk
  complete,
  
  /// Recovery completion - triumphant rise
  recover,
  
  /// Contract signing - tick-tick-thud
  sign,
  
  /// Witness nudge - gentle ping
  nudge,
  
  /// Chain reaction prompt - momentum whoosh
  chainReaction,
  
  /// Celebration - fanfare
  celebrate,
}

/// Combined haptic and sound feedback patterns
/// 
/// These patterns combine haptic and sound for maximum "juice"
class FeedbackPatterns {
  /// Heavy completion feedback - The Clunk
  /// Combines: Heavy haptic + completion sound
  static Future<void> completion(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    await sound.playComplete();
  }
  
  /// Recovery feedback - The Rise
  /// Combines: Medium haptic + recovery sound
  static Future<void> recovery(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    await sound.playRecover();
  }
  
  /// Contract signing feedback - The Commitment
  /// Combines: Selection clicks + heavy thud + sign sound
  static Future<void> contractSign(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      // Tick-tick-tick buildup
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 80));
      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 120));
      // Heavy thud on confirm
      HapticFeedback.heavyImpact();
    }
    await sound.playSign();
  }
  
  /// Nudge feedback - The Ping
  /// Combines: Light haptic + nudge sound
  static Future<void> nudge(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    await sound.playNudge();
  }
  
  /// Chain reaction feedback - The Momentum
  /// Combines: Medium haptic + chain sound
  static Future<void> chainReaction(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    await sound.playChainReaction();
  }
  
  /// Celebration feedback - The Victory
  /// Combines: Heavy haptic + celebrate sound
  static Future<void> celebration(SoundService sound, {bool hapticsEnabled = true}) async {
    if (hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    await sound.playCelebrate();
  }
  
  /// Selection feedback - Quick acknowledgment
  static void selection({bool hapticsEnabled = true}) {
    if (hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }
  
  /// Error feedback - Non-judgmental acknowledgment
  static void error({bool hapticsEnabled = true}) {
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }
}
