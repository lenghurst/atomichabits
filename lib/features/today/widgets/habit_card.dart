import 'package:flutter/material.dart';

/// HabitCard - Displays the current habit details
/// 
/// Purely presentational widget following vibecoding principles.
/// All data comes via props, no business logic inside.
/// 
/// **Phase 12: Bad Habit Protocol**
/// For break habits (isBreakHabit=true):
/// - Shows substitution plan instead of "Start tiny"
/// - Different color scheme (purple instead of amber)
/// - Different header icon (block instead of check)
class HabitCard extends StatelessWidget {
  final String habitName;
  final String tinyVersion;
  final String implementationTime;
  final String implementationLocation;
  final String? temptationBundle;
  final String? environmentCue;
  final String? environmentDistraction;
  final bool isCompleted;
  final bool isBreakHabit;
  final String? substitutionPlan;
  
  const HabitCard({
    super.key,
    required this.habitName,
    required this.tinyVersion,
    required this.implementationTime,
    required this.implementationLocation,
    this.temptationBundle,
    this.environmentCue,
    this.environmentDistraction,
    required this.isCompleted,
    this.isBreakHabit = false,
    this.substitutionPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTinyVersionBox(),
            const SizedBox(height: 12),
            _buildImplementationBox(),
            if (_hasTemptationBundle) ...[
              const SizedBox(height: 12),
              _buildTemptationBundleBox(),
            ],
            if (_hasEnvironmentDesign) ...[
              const SizedBox(height: 12),
              _buildEnvironmentBox(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    // Phase 12: Different icons and colors for break habits
    final completedColor = isBreakHabit ? Colors.purple : Colors.green;
    final completedIcon = isBreakHabit ? Icons.shield : Icons.check_circle;
    final incompleteIcon = isBreakHabit ? Icons.block_outlined : Icons.circle_outlined;
    
    return Row(
      children: [
        Icon(
          isCompleted ? completedIcon : incompleteIcon,
          size: 32,
          color: isCompleted ? completedColor : (isBreakHabit ? Colors.purple.shade200 : Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBreakHabit)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'BREAKING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Text(
                habitName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTinyVersionBox() {
    // Phase 12: Show substitution plan for break habits
    if (isBreakHabit && substitutionPlan != null && substitutionPlan!.isNotEmpty) {
      return _InfoBox(
        color: Colors.purple.shade50,
        icon: Icons.swap_horiz,
        iconColor: Colors.purple,
        text: 'Instead, I will: $substitutionPlan',
      );
    }
    
    return _InfoBox(
      color: isBreakHabit ? Colors.purple.shade50 : Colors.amber.shade50,
      icon: isBreakHabit ? Icons.block : Icons.timer,
      iconColor: isBreakHabit ? Colors.purple : Colors.amber,
      text: isBreakHabit ? 'Avoiding: $tinyVersion' : 'Start tiny: $tinyVersion',
    );
  }
  
  Widget _buildImplementationBox() {
    return _InfoBox(
      color: Colors.blue.shade50,
      icon: Icons.access_time,
      iconColor: Colors.blue,
      text: 'Planned: $implementationTime in $implementationLocation',
      fontWeight: FontWeight.w500,
    );
  }
  
  Widget _buildTemptationBundleBox() {
    return _InfoBox(
      color: Colors.pink.shade50,
      icon: Icons.favorite,
      iconColor: Colors.pink,
      text: 'Bundled with: $temptationBundle',
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );
  }
  
  Widget _buildEnvironmentBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(
                'Environment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          if (environmentCue != null && environmentCue!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _EnvironmentRow(
              icon: Icons.lightbulb,
              iconColor: Colors.orange,
              text: 'Cue: $environmentCue',
            ),
          ],
          if (environmentDistraction != null && environmentDistraction!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _EnvironmentRow(
              icon: Icons.block,
              iconColor: Colors.red,
              text: 'Distraction guardrail: $environmentDistraction',
            ),
          ],
        ],
      ),
    );
  }
  
  bool get _hasTemptationBundle =>
      temptationBundle != null && temptationBundle!.isNotEmpty;
  
  bool get _hasEnvironmentDesign =>
      (environmentCue != null && environmentCue!.isNotEmpty) ||
      (environmentDistraction != null && environmentDistraction!.isNotEmpty);
}

/// Reusable info box widget
class _InfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  
  const _InfoBox({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row widget for environment design items
class _EnvironmentRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  
  const _EnvironmentRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
