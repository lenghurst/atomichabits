import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';

/// Change / Reduce Habit Toolkit Screen
/// Implements the "Bad Habits & Substitution / Guardrails" module
///
/// Features:
/// - Substitution: find alternate behavior that meets same need
/// - Cue firewall & guardrails: remove or weaken triggers
/// - Bright-line rules: crisp "I don't..." rules (with progressive extremism)
/// - Temptation bundling: pair "need" with "want"
/// - Friction/impulse guardrails: add steps to bad behavior
class BadHabitScreen extends StatefulWidget {
  final String? habitId;

  const BadHabitScreen({super.key, this.habitId});

  @override
  State<BadHabitScreen> createState() => _BadHabitScreenState();
}

class _BadHabitScreenState extends State<BadHabitScreen> {
  bool _isLoadingSuggestions = false;
  Map<String, List<String>> _suggestions = {};

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    if (widget.habitId == null) return;

    setState(() => _isLoadingSuggestions = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final suggestions = await appState.getBadHabitSuggestions(widget.habitId!);

    if (mounted) {
      setState(() {
        _suggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final badHabits = appState.badHabits;
        final selectedHabit = widget.habitId != null
            ? appState.getHabitById(widget.habitId!)
            : (badHabits.isNotEmpty ? badHabits.first : null);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Change / Reduce Habits'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddBadHabitDialog(context, appState),
                tooltip: 'Add bad habit to change',
              ),
            ],
          ),
          body: badHabits.isEmpty
              ? _buildEmptyState(context, appState)
              : selectedHabit != null
                  ? _buildHabitDetail(context, appState, selectedHabit)
                  : _buildHabitList(context, appState, badHabits),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No bad habits to change',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Add a habit you want to reduce or change. We\'ll help you with substitution, cue firewalls, and bright-line rules.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddBadHabitDialog(context, appState),
              icon: const Icon(Icons.add),
              label: const Text('Add a habit to change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitList(BuildContext context, AppState appState, List<Habit> habits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.block, color: Colors.red.shade700),
            ),
            title: Text(habit.name),
            subtitle: Text(
              'Avoided ${habit.avoidedCount} times | ${habit.currentStreak} day streak',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BadHabitScreen(habitId: habit.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHabitDetail(BuildContext context, AppState appState, Habit habit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit header
          _buildHabitHeader(context, appState, habit),
          const SizedBox(height: 24),

          // Quick action: Mark as Avoided
          _buildAvoidedButton(context, appState, habit),
          const SizedBox(height: 24),

          // Substitution section
          _buildSubstitutionSection(context, appState, habit),
          const SizedBox(height: 24),

          // Cue Firewall section
          _buildCueFirewallSection(context, appState, habit),
          const SizedBox(height: 24),

          // Bright-line Rules section
          _buildBrightLineRulesSection(context, appState, habit),
          const SizedBox(height: 24),

          // Friction/Guardrails section
          _buildFrictionSection(context, appState, habit),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHabitHeader(BuildContext context, AppState appState, Habit habit) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block, color: Colors.red.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.check_circle,
                  label: '${habit.avoidedCount} avoided',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  icon: Icons.local_fire_department,
                  label: '${habit.currentStreak} day streak',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildAvoidedButton(BuildContext context, AppState appState, Habit habit) {
    final isAvoidedToday = habit.lastAvoidedDate != null &&
        DateTime.now().difference(habit.lastAvoidedDate!).inDays == 0;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isAvoidedToday
            ? null
            : () async {
                final success = await appState.avoidBadHabitForToday(habit.id);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Great job avoiding that habit!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
        icon: Icon(isAvoidedToday ? Icons.check : Icons.shield),
        label: Text(
          isAvoidedToday ? 'Avoided today!' : 'I avoided this habit today',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvoidedToday ? Colors.grey : Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSubstitutionSection(BuildContext context, AppState appState, Habit habit) {
    return _buildSection(
      title: 'Substitution',
      subtitle: 'Replace with a healthier behavior that meets the same need',
      icon: Icons.swap_horiz,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habit.substitutionBehavior != null && habit.substitutionBehavior!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      habit.substitutionBehavior!,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (habit.underlyingNeed != null && habit.underlyingNeed!.isNotEmpty)
            Text(
              'Underlying need: ${habit.underlyingNeed}',
              style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 12),
          _buildSuggestionChips(
            suggestions: _suggestions['substitution'] ?? [],
            isLoading: _isLoadingSuggestions,
            onSelected: (suggestion) {
              _showEditSubstitutionDialog(context, appState, habit, suggestion);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showEditSubstitutionDialog(context, appState, habit, null),
            icon: const Icon(Icons.edit),
            label: Text(habit.substitutionBehavior != null ? 'Edit substitution' : 'Add substitution'),
          ),
        ],
      ),
    );
  }

  Widget _buildCueFirewallSection(BuildContext context, AppState appState, Habit habit) {
    return _buildSection(
      title: 'Cue Firewall',
      subtitle: 'Identify and block triggers that lead to this habit',
      icon: Icons.security,
      color: Colors.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habit.cueFirewalls.isNotEmpty) ...[
            ...habit.cueFirewalls.map((firewall) => _buildFirewallTile(
                  context,
                  appState,
                  habit,
                  firewall,
                )),
            const SizedBox(height: 12),
          ],
          _buildSuggestionChips(
            suggestions: _suggestions['cueFirewall'] ?? [],
            isLoading: _isLoadingSuggestions,
            onSelected: (suggestion) {
              _showAddCueFirewallDialog(context, appState, habit, suggestion);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showAddCueFirewallDialog(context, appState, habit, null),
            icon: const Icon(Icons.add),
            label: const Text('Add trigger to avoid'),
          ),
        ],
      ),
    );
  }

  Widget _buildFirewallTile(
    BuildContext context,
    AppState appState,
    Habit habit,
    CueFirewall firewall,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_getCueTypeIcon(firewall.cueType), color: Colors.purple),
        title: Text(firewall.description),
        subtitle: firewall.avoidanceStrategy != null
            ? Text(firewall.avoidanceStrategy!)
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => appState.removeCueFirewall(habit.id, firewall.id),
        ),
      ),
    );
  }

  IconData _getCueTypeIcon(CueType type) {
    switch (type) {
      case CueType.time:
        return Icons.access_time;
      case CueType.place:
        return Icons.place;
      case CueType.people:
        return Icons.people;
      case CueType.emotion:
        return Icons.emoji_emotions;
      case CueType.action:
        return Icons.touch_app;
    }
  }

  Widget _buildBrightLineRulesSection(BuildContext context, AppState appState, Habit habit) {
    return _buildSection(
      title: 'Bright-Line Rules',
      subtitle: 'Crisp "I don\'t..." rules with no exceptions',
      icon: Icons.rule,
      color: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habit.brightLineRules.isNotEmpty) ...[
            ...habit.brightLineRules.map((rule) => _buildRuleTile(
                  context,
                  appState,
                  habit,
                  rule,
                )),
            const SizedBox(height: 12),
          ],
          _buildSuggestionChips(
            suggestions: _suggestions['brightLineRule'] ?? [],
            isLoading: _isLoadingSuggestions,
            onSelected: (suggestion) {
              _showAddBrightLineRuleDialog(context, appState, habit, suggestion);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showAddBrightLineRuleDialog(context, appState, habit, null),
            icon: const Icon(Icons.add),
            label: const Text('Add rule'),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleTile(
    BuildContext context,
    AppState appState,
    Habit habit,
    BrightLineRule rule,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.rule,
          color: _getIntensityColor(rule.intensity),
        ),
        title: Text(
          rule.rule,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(_getIntensityLabel(rule.intensity)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => appState.removeBrightLineRule(habit.id, rule.id),
        ),
      ),
    );
  }

  Color _getIntensityColor(RuleIntensity intensity) {
    switch (intensity) {
      case RuleIntensity.gentle:
        return Colors.green;
      case RuleIntensity.moderate:
        return Colors.orange;
      case RuleIntensity.strict:
        return Colors.deepOrange;
      case RuleIntensity.absolute:
        return Colors.red;
    }
  }

  String _getIntensityLabel(RuleIntensity intensity) {
    switch (intensity) {
      case RuleIntensity.gentle:
        return 'Gentle (starting point)';
      case RuleIntensity.moderate:
        return 'Moderate';
      case RuleIntensity.strict:
        return 'Strict';
      case RuleIntensity.absolute:
        return 'Absolute (no exceptions)';
    }
  }

  Widget _buildFrictionSection(BuildContext context, AppState appState, Habit habit) {
    return _buildSection(
      title: 'Friction / Guardrails',
      subtitle: 'Add steps between trigger and behavior',
      icon: Icons.speed,
      color: Colors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (habit.frictionSteps > 0 || (habit.frictionDescription?.isNotEmpty ?? false)) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stairs, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        '${habit.frictionSteps} steps added',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (habit.frictionDescription != null && habit.frictionDescription!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(habit.frictionDescription!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _buildSuggestionChips(
            suggestions: _suggestions['friction'] ?? [],
            isLoading: _isLoadingSuggestions,
            onSelected: (suggestion) {
              _showEditFrictionDialog(context, appState, habit, suggestion);
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showEditFrictionDialog(context, appState, habit, null),
            icon: const Icon(Icons.edit),
            label: Text(habit.frictionSteps > 0 ? 'Edit friction' : 'Add friction'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips({
    required List<String> suggestions,
    required bool isLoading,
    required Function(String) onSelected,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Loading suggestions...'),
          ],
        ),
      );
    }

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return ActionChip(
          label: Text(
            suggestion.length > 40 ? '${suggestion.substring(0, 40)}...' : suggestion,
            style: const TextStyle(fontSize: 12),
          ),
          onPressed: () => onSelected(suggestion),
        );
      }).toList(),
    );
  }

  // ========== DIALOGS ==========

  void _showAddBadHabitDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final needController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add habit to change'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'What habit do you want to change?',
                  hintText: 'e.g., Scrolling social media',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: needController,
                decoration: const InputDecoration(
                  labelText: 'What need does this habit meet? (optional)',
                  hintText: 'e.g., Boredom, Stress relief, Connection',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final habit = Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  identity: 'I am someone who doesn\'t ${nameController.text.toLowerCase()}',
                  tinyVersion: 'Wait 10 seconds before giving in',
                  habitType: HabitType.bad,
                  createdAt: DateTime.now(),
                  implementationTime: '00:00',
                  implementationLocation: '',
                  underlyingNeed: needController.text.isNotEmpty ? needController.text : null,
                );
                appState.addHabit(habit);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditSubstitutionDialog(
    BuildContext context,
    AppState appState,
    Habit habit,
    String? initialValue,
  ) {
    final substitutionController = TextEditingController(
      text: initialValue ?? habit.substitutionBehavior ?? '',
    );
    final needController = TextEditingController(text: habit.underlyingNeed ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Substitution Behavior'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What healthier behavior can meet the same need?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: substitutionController,
                decoration: const InputDecoration(
                  labelText: 'Substitution',
                  hintText: 'e.g., Drink sparkling water instead',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: needController,
                decoration: const InputDecoration(
                  labelText: 'Underlying need',
                  hintText: 'e.g., Relaxation, Social connection',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.updateSubstitution(
                habit.id,
                substitutionController.text,
                needController.text.isNotEmpty ? needController.text : null,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddCueFirewallDialog(
    BuildContext context,
    AppState appState,
    Habit habit,
    String? initialValue,
  ) {
    final descriptionController = TextEditingController(text: initialValue ?? '');
    final strategyController = TextEditingController();
    CueType selectedType = CueType.time;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Trigger to Avoid'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('What type of trigger is this?'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: CueType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.name.toUpperCase()),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedType = type);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Describe the trigger',
                    hintText: 'e.g., Friday evenings, When stressed',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: strategyController,
                  decoration: const InputDecoration(
                    labelText: 'How will you avoid it? (optional)',
                    hintText: 'e.g., Leave phone in another room',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descriptionController.text.isNotEmpty) {
                  final firewall = CueFirewall(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    cueType: selectedType,
                    description: descriptionController.text,
                    avoidanceStrategy: strategyController.text.isNotEmpty
                        ? strategyController.text
                        : null,
                  );
                  appState.addCueFirewall(habit.id, firewall);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBrightLineRuleDialog(
    BuildContext context,
    AppState appState,
    Habit habit,
    String? initialValue,
  ) {
    final ruleController = TextEditingController(text: initialValue ?? '');
    RuleIntensity selectedIntensity = RuleIntensity.moderate;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Bright-Line Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a clear rule with no ambiguity',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ruleController,
                  decoration: const InputDecoration(
                    labelText: 'Your rule',
                    hintText: 'e.g., I don\'t drink on weekdays',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Rule intensity:'),
                const SizedBox(height: 8),
                ...RuleIntensity.values.map((intensity) {
                  return RadioListTile<RuleIntensity>(
                    title: Text(_getIntensityLabel(intensity)),
                    value: intensity,
                    groupValue: selectedIntensity,
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedIntensity = value);
                      }
                    },
                    dense: true,
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (ruleController.text.isNotEmpty) {
                  final rule = BrightLineRule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    rule: ruleController.text,
                    intensity: selectedIntensity,
                    createdAt: DateTime.now(),
                  );
                  appState.addBrightLineRule(habit.id, rule);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFrictionDialog(
    BuildContext context,
    AppState appState,
    Habit habit,
    String? initialValue,
  ) {
    final stepsController = TextEditingController(
      text: habit.frictionSteps > 0 ? habit.frictionSteps.toString() : '3',
    );
    final descriptionController = TextEditingController(
      text: initialValue ?? habit.frictionDescription ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Friction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Make the bad habit harder to do by adding steps between the urge and the action.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stepsController,
                decoration: const InputDecoration(
                  labelText: 'Number of steps',
                  hintText: 'e.g., 3',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'What friction are you adding?',
                  hintText: 'e.g., Keep snacks in garage, delete app',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(stepsController.text) ?? 0;
              appState.updateFriction(
                habit.id,
                steps,
                descriptionController.text.isNotEmpty
                    ? descriptionController.text
                    : null,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
