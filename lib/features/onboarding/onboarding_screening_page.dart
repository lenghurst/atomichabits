import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';

/// Onboarding Screening Page
///
/// Phase 25.1: The Pre-Flight Check
///
/// A 3-step PageView that captures high-level user intent before the voice session.
/// This solves the "Cold Start" problem by giving the AI context to open with.
///
/// Flow:
/// 1. The Mission (Intent)
/// 2. The Enemy (Obstacle)
/// 3. The Witness Vibe (Persona)
class OnboardingScreeningPage extends StatefulWidget {
  const OnboardingScreeningPage({super.key});

  @override
  State<OnboardingScreeningPage> createState() => _OnboardingScreeningPageState();
}

class _OnboardingScreeningPageState extends State<OnboardingScreeningPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Storage for answers
  String? _selectedMission;
  String? _selectedEnemy;
  String? _selectedVibe;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishScreening();
    }
  }

  void _finishScreening() {
    // Navigate to Voice Coach with the captured context
    // Ensure we pass a strongly typed Map<String, String> to avoid runtime cast errors
    final Map<String, String> screeningData = {
      'mission': _selectedMission ?? 'Unknown',
      'enemy': _selectedEnemy ?? 'Unknown',
      'vibe': _selectedVibe ?? 'friend',
    };

    context.push(
      AppRoutes.voiceOnboarding,
      extra: screeningData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // slate-900
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Prevent swiping without selection
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildMissionStep(),
                  _buildEnemyStep(),
                  _buildVibeStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionStep() {
    return _ScreeningStep(
      title: "What brings you to The Pact?",
      subtitle: "We'll tailor the protocol to your goal.",
      options: [
        _OptionCard(
          id: 'build',
          label: "Build a new habit",
          description: "Start something positive.",
          icon: Icons.add_circle_outline,
          isSelected: _selectedMission == 'build',
          onTap: () {
            setState(() => _selectedMission = 'build');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'break',
          label: "Break a bad habit",
          description: "Stop something negative.",
          icon: Icons.remove_circle_outline,
          isSelected: _selectedMission == 'break',
          onTap: () {
            setState(() => _selectedMission = 'break');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'restore',
          label: "Get my life together",
          description: "General order and discipline.",
          icon: Icons.restart_alt,
          isSelected: _selectedMission == 'restore',
          onTap: () {
            setState(() => _selectedMission = 'restore');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
      ],
    );
  }

  Widget _buildEnemyStep() {
    return _ScreeningStep(
      title: "What usually stops you?",
      subtitle: "Know your enemy to defeat him.",
      options: [
        _OptionCard(
          id: 'forget',
          label: "I forget",
          description: "It slips my mind.",
          icon: Icons.question_mark,
          isSelected: _selectedEnemy == 'forget',
          onTap: () {
            setState(() => _selectedEnemy = 'forget');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'lazy',
          label: "I get lazy / tired",
          description: "Lack of energy or motivation.",
          icon: Icons.bedtime,
          isSelected: _selectedEnemy == 'lazy',
          onTap: () {
            setState(() => _selectedEnemy = 'lazy');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'busy',
          label: "I'm too busy",
          description: "Lack of time.",
          icon: Icons.hourglass_empty,
          isSelected: _selectedEnemy == 'busy',
          onTap: () {
            setState(() => _selectedEnemy = 'busy');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'perfectionism',
          label: "I quit if I miss a day",
          description: "All-or-nothing thinking.",
          icon: Icons.cancel,
          isSelected: _selectedEnemy == 'perfectionism',
          onTap: () {
            setState(() => _selectedEnemy = 'perfectionism');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
      ],
    );
  }

  Widget _buildVibeStep() {
    return _ScreeningStep(
      title: "How should I hold you accountable?",
      subtitle: "Choose your AI Witness persona.",
      options: [
        _OptionCard(
          id: 'friend',
          label: "Compassionate Friend",
          description: "Warm, forgiving, 'try again'.",
          icon: Icons.favorite_border,
          isSelected: _selectedVibe == 'friend',
          onTap: () {
            setState(() => _selectedVibe = 'friend');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'sage',
          label: "Stoic Sage",
          description: "Focus on the system, not the goal.",
          icon: Icons.balance,
          isSelected: _selectedVibe == 'sage',
          onTap: () {
            setState(() => _selectedVibe = 'sage');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
        _OptionCard(
          id: 'sergeant',
          label: "Drill Sergeant",
          description: "No excuses. Get it done.",
          icon: Icons.military_tech,
          isSelected: _selectedVibe == 'sergeant',
          onTap: () {
            setState(() => _selectedVibe = 'sergeant');
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) _nextPage();
            });
          },
        ),
      ],
    );
  }
}

class _ScreeningStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> options;

  const _ScreeningStep({
    required this.title,
    required this.subtitle,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) => options[index],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF22C55E).withOpacity(0.1)
              : const Color(0xFF1E293B),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF22C55E)
                : const Color(0xFF334155),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF22C55E),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
