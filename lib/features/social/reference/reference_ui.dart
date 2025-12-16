import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/habit_circle.dart';

/// Social & Norms Layer Screen
/// Implements the "Social / Community / Norms" module
///
/// Features:
/// - People cues for habits ("When I'm with X, I do Y")
/// - Small Habit Circles / groups (shared habits, check-ins)
/// - Local champions / guides (Mozambique model)
/// - Simple group dashboards with norm messages
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Social & Community'),
              centerTitle: true,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'People Cues', icon: Icon(Icons.people)),
                  Tab(text: 'Habit Circles', icon: Icon(Icons.group_work)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _PeopleCuesTab(appState: appState),
                _HabitCirclesTab(appState: appState),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tab for managing people cues
class _PeopleCuesTab extends StatelessWidget {
  final AppState appState;

  const _PeopleCuesTab({required this.appState});

  @override
  Widget build(BuildContext context) {
    final habitsWithPeopleCues = appState.habits
        .where((h) => h.peopleCues.isNotEmpty)
        .toList();

    return Scaffold(
      body: habitsWithPeopleCues.isEmpty
          ? _buildEmptyState(context)
          : _buildPeopleCuesList(context, habitsWithPeopleCues),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPeopleCueDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add People Cue'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No people cues yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              '"When I\'m with X, I do Y"\n\nLink habits to the people you spend time with.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleCuesList(BuildContext context, List<Habit> habits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      habit.habitType == HabitType.good
                          ? Icons.check_circle
                          : Icons.block,
                      color: habit.habitType == HabitType.good
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        habit.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...habit.peopleCues.map((cue) => _buildPeopleCueTile(
                      context,
                      habit,
                      cue,
                    )),
                TextButton.icon(
                  onPressed: () => _showAddPeopleCueForHabitDialog(context, habit),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add person'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeopleCueTile(BuildContext context, Habit habit, PeopleCue cue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cue.isPositive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: cue.isPositive ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: cue.isPositive ? Colors.green : Colors.orange,
            radius: 16,
            child: Icon(
              cue.isPositive ? Icons.thumb_up : Icons.warning,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'With ${cue.person}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  cue.behavior,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red,
            onPressed: () => appState.removePeopleCue(habit.id, cue.id),
          ),
        ],
      ),
    );
  }

  void _showAddPeopleCueDialog(BuildContext context) {
    final habits = appState.habits;
    if (habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a habit first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select a habit'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return ListTile(
                  leading: Icon(
                    habit.habitType == HabitType.good
                        ? Icons.check_circle
                        : Icons.block,
                    color: habit.habitType == HabitType.good
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(habit.name),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _showAddPeopleCueForHabitDialog(context, habit);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPeopleCueForHabitDialog(BuildContext context, Habit habit) {
    final personController = TextEditingController();
    final behaviorController = TextEditingController();
    bool isPositive = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add person for "${habit.name}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Who influences this habit?'),
                const SizedBox(height: 12),
                TextField(
                  controller: personController,
                  decoration: const InputDecoration(
                    labelText: 'Person or group',
                    hintText: 'e.g., Sarah, Running group, Coworkers',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: behaviorController,
                  decoration: const InputDecoration(
                    labelText: 'What happens with them?',
                    hintText: 'e.g., We always go running together',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Is this influence positive?'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Positive'),
                        value: true,
                        groupValue: isPositive,
                        onChanged: (v) => setDialogState(() => isPositive = true),
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Negative'),
                        value: false,
                        groupValue: isPositive,
                        onChanged: (v) => setDialogState(() => isPositive = false),
                        dense: true,
                      ),
                    ),
                  ],
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
                if (personController.text.isNotEmpty &&
                    behaviorController.text.isNotEmpty) {
                  final cue = PeopleCue(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    person: personController.text,
                    behavior: behaviorController.text,
                    isPositive: isPositive,
                  );
                  appState.addPeopleCue(habit.id, cue);
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
}

/// Tab for managing habit circles
class _HabitCirclesTab extends StatelessWidget {
  final AppState appState;

  const _HabitCirclesTab({required this.appState});

  @override
  Widget build(BuildContext context) {
    final circles = appState.habitCircles;

    return Scaffold(
      body: circles.isEmpty
          ? _buildEmptyState(context)
          : _buildCirclesList(context, circles),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCircleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Circle'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_work_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No habit circles yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Create a small group to share habits and check in together. Social support makes habits stick.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCirclesList(BuildContext context, List<HabitCircle> circles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: circles.length,
      itemBuilder: (context, index) {
        final circle = circles[index];
        return _buildCircleCard(context, circle);
      },
    );
  }

  Widget _buildCircleCard(BuildContext context, HabitCircle circle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showCircleDetailDialog(context, circle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      circle.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${circle.memberCount} members',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (circle.championName != null)
                    Chip(
                      avatar: const Icon(Icons.star, size: 16),
                      label: Text(circle.championName!),
                      backgroundColor: Colors.amber.shade100,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Norm message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.format_quote, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        circle.generatedNormMessage,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.check_circle,
                    value: '${circle.totalCompletionsThisWeek}',
                    label: 'This week',
                  ),
                  _buildStatColumn(
                    icon: Icons.local_fire_department,
                    value: circle.averageStreakDays.toStringAsFixed(1),
                    label: 'Avg streak',
                  ),
                  _buildStatColumn(
                    icon: Icons.people,
                    value: '${circle.activeMemberCount}',
                    label: 'Active',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showCreateCircleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final normController = TextEditingController();
    CheckInFrequency selectedFrequency = CheckInFrequency.weekly;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Habit Circle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Circle name',
                    hintText: 'e.g., Morning Runners, Book Club',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'What is this circle about?',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: normController,
                  decoration: const InputDecoration(
                    labelText: 'Norm message (optional)',
                    hintText: 'e.g., Around here, we walk after lunch',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Check-in frequency:'),
                ...CheckInFrequency.values.map((freq) {
                  return RadioListTile<CheckInFrequency>(
                    title: Text(freq.displayName),
                    value: freq,
                    groupValue: selectedFrequency,
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedFrequency = v);
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
                if (nameController.text.isNotEmpty) {
                  final circle = HabitCircle(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: descriptionController.text,
                    createdAt: DateTime.now(),
                    normMessage: normController.text.isNotEmpty
                        ? normController.text
                        : null,
                    checkInFrequency: selectedFrequency,
                    members: [
                      CircleMember(
                        id: 'self',
                        name: appState.userProfile?.name ?? 'You',
                        joinedAt: DateTime.now(),
                      ),
                    ],
                  );
                  appState.createHabitCircle(circle);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCircleDetailDialog(BuildContext context, HabitCircle circle) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(circle.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (circle.description.isNotEmpty) ...[
                Text(circle.description),
                const SizedBox(height: 16),
              ],
              const Text(
                'Members',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...circle.members.map((member) => ListTile(
                    leading: CircleAvatar(
                      child: Text(member.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(member.name),
                    subtitle: Text('${member.currentStreak} day streak'),
                    trailing: member.isActive
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  )),
              const SizedBox(height: 16),
              const Text(
                'Shared Habits',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (circle.sharedHabitIds.isEmpty)
                const Text('No shared habits yet')
              else
                ...circle.sharedHabitIds.map((habitId) {
                  final habit = appState.getHabitById(habitId);
                  return habit != null
                      ? ListTile(
                          leading: const Icon(Icons.check_circle),
                          title: Text(habit.name),
                        )
                      : const SizedBox.shrink();
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              appState.deleteHabitCircle(circle.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Circle'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
