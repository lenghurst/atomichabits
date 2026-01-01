import 'package:flutter/material.dart';
import '../../../data/models/voice_session_config.dart';
import '../voice_coach_screen.dart';

/// Step 9: Oracle Coach Screen (Gold/White Theme)
/// 
/// Purpose:
/// - Voice-first interaction to set the Vision/Future Self.
/// - Wraps the unified VoiceCoachScreen with specific mode.
class OracleCoachScreen extends StatelessWidget {
  const OracleCoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return VoiceCoachScreen(
      config: VoiceSessionConfig.oracle,
    );
  }
}
