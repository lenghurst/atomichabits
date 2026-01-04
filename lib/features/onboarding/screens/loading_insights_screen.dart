import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../config/router/app_routes.dart';
import '../../../data/app_state.dart';
import '../../../data/models/onboarding_data.dart';
import '../../../data/services/onboarding/onboarding_orchestrator.dart';
import '../../../domain/services/onboarding_insights_service.dart';

/// Theatre page that captures JITAI signals and displays personalized insights
///
/// This is the moment to:
/// 1. Capture context (weather, calendar, time)
/// 2. Initialize population priors for the user's archetype
/// 3. Generate and display personalized insights
/// 4. Build trust by showing we understand them from day one
class LoadingInsightsScreen extends StatefulWidget {
  const LoadingInsightsScreen({super.key});

  @override
  State<LoadingInsightsScreen> createState() => _LoadingInsightsScreenState();
}

class _LoadingInsightsScreenState extends State<LoadingInsightsScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinnerController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final OnboardingInsightsService _insightsService = OnboardingInsightsService();

  String _statusText = 'Analyzing your timing preferences...';
  List<OnboardingInsight> _insights = [];
  int _currentInsightIndex = -1;
  bool _showInsights = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    _spinnerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Use addPostFrameCallback to safely access Provider after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInsightsCapture();
    });
  }

  Future<void> _runInsightsCapture() async {
    if (!mounted) return;

    // Safely get onboarding data from orchestrator after widget is built
    OnboardingOrchestrator? orchestrator;
    AppState? appState;
    try {
      orchestrator = context.read<OnboardingOrchestrator?>();
      appState = context.read<AppState?>();
    } catch (e) {
      // Provider not found - proceed without orchestrator data
    }
    final habitData = orchestrator?.extractedData;

    // Build habits list from available data
    final habits = <OnboardingData>[];
    if (habitData != null) {
      habits.add(habitData);
    }

    // Get witness status from user profile
    final witnessName = appState?.userProfile?.witnessName;
    final hasWitnesses = witnessName != null &&
        witnessName.isNotEmpty &&
        witnessName != 'Myself';

    // Get motivation/bigWhy from orchestrator data or habit data
    final bigWhy = habitData?.motivation;

    // Capture signals and generate insights
    await for (final status in _insightsService.captureSignals(
      habits: habits,
      hasWitnesses: hasWitnesses,
      bigWhy: bigWhy,
    )) {
      if (!mounted) return;
      setState(() => _statusText = status);

      if (status == 'Ready') {
        _insights = _insightsService.insights;
        await _showInsightsSequence();
      }
    }
  }

  Future<void> _showInsightsSequence() async {
    if (!mounted || _insights.isEmpty) {
      _navigateNext();
      return;
    }

    setState(() => _showInsights = true);

    // Show each insight with animation
    for (var i = 0; i < _insights.length && i < 4; i++) {
      if (!mounted) return;

      setState(() => _currentInsightIndex = i);
      _fadeController.forward(from: 0);
      _slideController.forward(from: 0);

      // Hold each insight for 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      await _fadeController.reverse();
    }

    // Brief pause before navigation
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isComplete = true);
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateNext();
    }
  }

  void _navigateNext() {
    if (mounted) {
      context.replace(AppRoutes.onboardingTierSelection);
    }
  }

  @override
  void dispose() {
    _spinnerController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Spinner
              _buildSpinner(),

              const SizedBox(height: 48),

              // Status text or insight
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showInsights && _currentInsightIndex >= 0
                    ? _buildInsightCard(_insights[_currentInsightIndex])
                    : _buildStatusText(),
              ),

              const Spacer(flex: 3),

              // Progress indicator
              _buildProgressIndicator(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner() {
    return AnimatedBuilder(
      animation: _spinnerController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _spinnerController.value * 2 * 3.14159,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.transparent,
                  _isComplete ? Colors.green : Colors.deepPurpleAccent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: _isComplete
                    ? const Icon(
                        Icons.check,
                        color: Colors.green,
                        size: 32,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusText() {
    return Text(
      _statusText,
      key: ValueKey(_statusText),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white70,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInsightCard(OnboardingInsight insight) {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOut,
        )),
        child: Container(
          key: ValueKey(insight.label),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getCategoryColor(insight.category).withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category label
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForHint(insight.iconHint),
                    size: 16,
                    color: _getCategoryColor(insight.category),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    insight.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(insight.category),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main insight
              Text(
                insight.insight,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),

              if (insight.detail != null) ...[
                const SizedBox(height: 12),
                Text(
                  insight.detail!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],

              // Confidence indicator
              const SizedBox(height: 16),
              _buildConfidenceBar(insight.confidence),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBar(double confidence) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Confidence',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: _getConfidenceColor(confidence),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    if (!_showInsights || _insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _insights.length.clamp(0, 4),
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentInsightIndex
                ? Colors.deepPurpleAccent
                : Colors.white.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(SignalCategory category) {
    switch (category) {
      case SignalCategory.context:
        return Colors.blue;
      case SignalCategory.intent:
        return Colors.green;
      case SignalCategory.baseline:
        return Colors.orange;
      case SignalCategory.population:
        return Colors.purple;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getIconForHint(String hint) {
    switch (hint) {
      case 'schedule':
        return Icons.schedule;
      case 'psychology':
        return Icons.psychology;
      case 'sensors':
        return Icons.sensors;
      case 'shield':
        return Icons.shield;
      case 'verified':
        return Icons.verified;
      case 'person':
        return Icons.person;
      default:
        return Icons.auto_awesome;
    }
  }
}
