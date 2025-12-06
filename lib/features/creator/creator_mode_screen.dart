import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/creator_session.dart';

/// Creator Mode Screen
/// Implements the "Creative Work / Quantity Over Quality" module
///
/// Features:
/// - Quantity-first mode for creative work (writing, music, design, code, photos)
/// - Session types: generate vs refine (deliberate practice vs mechanical reps)
/// - WordStar-style focus workspace for creative sessions
/// - Weekly review emphasizing volume + learnings, not "was it good?"
class CreatorModeScreen extends StatelessWidget {
  final String? habitId;

  const CreatorModeScreen({super.key, this.habitId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final creatorHabits = appState.habits
            .where((h) => h.isCreatorModeEnabled)
            .toList();

        final selectedHabit = habitId != null
            ? appState.getHabitById(habitId!)
            : (creatorHabits.isNotEmpty ? creatorHabits.first : null);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Creator Mode'),
            centerTitle: true,
            actions: [
              if (appState.habits.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showEnableCreatorModeDialog(context, appState),
                  tooltip: 'Enable Creator Mode for a habit',
                ),
            ],
          ),
          body: creatorHabits.isEmpty
              ? _buildEmptyState(context, appState)
              : selectedHabit != null && selectedHabit.isCreatorModeEnabled
                  ? _CreatorHabitDetail(habit: selectedHabit, appState: appState)
                  : _buildHabitList(context, appState, creatorHabits),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.create, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Creator Mode habits',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Creator Mode helps you focus on quantity over quality for creative work.\n\n'
              '"The ceramics teacher announced on opening day that students would be graded on '
              'the quantity of pots they made, not the quality. The quantity group made the best pots."',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (appState.habits.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _showEnableCreatorModeDialog(context, appState),
                icon: const Icon(Icons.add),
                label: const Text('Enable Creator Mode'),
              )
            else
              Text(
                'Create a habit first, then enable Creator Mode',
                style: TextStyle(color: Colors.grey.shade500),
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
        final summary = appState.getWeeklySummary(habit.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Icon(Icons.create, color: Colors.deepPurple.shade700),
            ),
            title: Text(habit.name),
            subtitle: Text(
              '${summary.totalReps} reps this week | ${habit.totalReps} total',
            ),
            trailing: CircularProgressIndicator(
              value: summary.weeklyGoalProgress.clamp(0, 1),
              backgroundColor: Colors.grey.shade200,
              strokeWidth: 4,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatorModeScreen(habitId: habit.id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEnableCreatorModeDialog(BuildContext context, AppState appState) {
    final nonCreatorHabits = appState.habits
        .where((h) => !h.isCreatorModeEnabled && h.habitType == HabitType.good)
        .toList();

    if (nonCreatorHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All habits already have Creator Mode enabled')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enable Creator Mode'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: nonCreatorHabits.length,
            itemBuilder: (context, index) {
              final habit = nonCreatorHabits[index];
              return ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(habit.name),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showConfigureCreatorModeDialog(context, appState, habit);
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
      ),
    );
  }

  void _showConfigureCreatorModeDialog(BuildContext context, AppState appState, Habit habit) {
    final goalController = TextEditingController(text: '10');
    final unitController = TextEditingController(text: 'reps');
    final workspaceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Configure Creator Mode for "${habit.name}"'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Focus on volume, not quality. Set a weekly rep goal.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  labelText: 'Weekly rep goal',
                  hintText: 'e.g., 10, 50, 100',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Rep unit',
                  hintText: 'e.g., words, photos, sketches, lines',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: workspaceController,
                decoration: const InputDecoration(
                  labelText: 'Minimal workspace (optional)',
                  hintText: 'e.g., Just Notepad, phone in other room',
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
              final goal = int.tryParse(goalController.text) ?? 10;
              appState.enableCreatorMode(
                habit.id,
                weeklyRepGoal: goal,
                repUnit: unitController.text,
                workspace: workspaceController.text.isNotEmpty
                    ? workspaceController.text
                    : null,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }
}

/// Detail view for a creator mode habit
class _CreatorHabitDetail extends StatefulWidget {
  final Habit habit;
  final AppState appState;

  const _CreatorHabitDetail({required this.habit, required this.appState});

  @override
  State<_CreatorHabitDetail> createState() => _CreatorHabitDetailState();
}

class _CreatorHabitDetailState extends State<_CreatorHabitDetail> {
  int _sessionReps = 0;

  @override
  Widget build(BuildContext context) {
    final summary = widget.appState.getWeeklySummary(widget.habit.id);
    final activeSession = widget.appState.activeCreatorSession;
    final isSessionActive = activeSession != null && activeSession.habitId == widget.habit.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          _buildHeaderCard(context, summary),
          const SizedBox(height: 24),

          // Active session or start session
          if (isSessionActive)
            _buildActiveSession(context, activeSession)
          else
            _buildStartSessionSection(context),
          const SizedBox(height: 24),

          // Weekly progress
          _buildWeeklyProgress(context, summary),
          const SizedBox(height: 24),

          // Recent sessions
          _buildRecentSessions(context),
          const SizedBox(height: 24),

          // Disable creator mode
          Center(
            child: TextButton.icon(
              onPressed: () => _showDisableDialog(context),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Disable Creator Mode'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, CreatorWeeklySummary summary) {
    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.create, color: Colors.deepPurple.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.habit.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  value: '${widget.habit.totalReps}',
                  label: 'Total Reps',
                  icon: Icons.numbers,
                ),
                _buildStatColumn(
                  value: '${summary.totalReps}',
                  label: 'This Week',
                  icon: Icons.calendar_today,
                ),
                _buildStatColumn(
                  value: '${(summary.weeklyGoalProgress * 100).toInt()}%',
                  label: 'Goal',
                  icon: Icons.flag,
                ),
              ],
            ),
            if (widget.habit.creatorWorkspace != null &&
                widget.habit.creatorWorkspace!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.desktop_windows, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Workspace: ${widget.habit.creatorWorkspace}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStartSessionSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start a Session',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSessionTypeButton(
                    context,
                    type: CreatorSessionType.generate,
                    title: 'Create',
                    subtitle: 'Quantity mode',
                    icon: Icons.bolt,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSessionTypeButton(
                    context,
                    type: CreatorSessionType.refine,
                    title: 'Refine',
                    subtitle: 'Quality mode',
                    icon: Icons.auto_fix_high,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTypeButton(
    BuildContext context, {
    required CreatorSessionType type,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _startSession(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSession(BuildContext context, CreatorSession session) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  session.sessionType == CreatorSessionType.generate
                      ? Icons.bolt
                      : Icons.auto_fix_high,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Session Active: ${session.sessionType.displayName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${session.duration.inMinutes} minutes',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reps completed',
                hintText: 'How many ${widget.habit.tinyVersion}?',
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _sessionReps = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _endSession(),
                icon: const Icon(Icons.check),
                label: const Text('End Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, CreatorWeeklySummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: summary.weeklyGoalProgress.clamp(0, 1),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                summary.goalMet ? Colors.green : Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${summary.totalReps} / ${widget.habit.weeklyRepGoal} reps',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (summary.goalMet)
                  const Chip(
                    label: Text('Goal Met!'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    icon: Icons.play_circle,
                    value: '${summary.sessionsCompleted}',
                    label: 'Sessions',
                  ),
                ),
                Expanded(
                  child: _buildMiniStat(
                    icon: Icons.timer,
                    value: summary.focusTimeDisplay,
                    label: 'Focus time',
                  ),
                ),
              ],
            ),
            if (summary.learnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Learnings this week:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...summary.learnings.take(3).map((learning) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('- '),
                        Expanded(child: Text(learning)),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    final sessions = widget.appState.getSessionsForHabit(widget.habit.id);
    final recentSessions = sessions.take(5).toList();

    if (recentSessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Sessions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...recentSessions.map((session) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    session.sessionType == CreatorSessionType.generate
                        ? Icons.bolt
                        : Icons.auto_fix_high,
                    color: session.sessionType == CreatorSessionType.generate
                        ? Colors.orange
                        : Colors.blue,
                  ),
                  title: Text('${session.repsCompleted} reps'),
                  subtitle: Text(
                    '${session.duration.inMinutes} min | ${_formatDate(session.startedAt)}',
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  void _startSession(CreatorSessionType type) {
    widget.appState.startCreatorSession(
      widget.habit.id,
      sessionType: type,
    );
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final learningsController = TextEditingController();

        return AlertDialog(
          title: const Text('End Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You completed $_sessionReps reps this session.'),
              const SizedBox(height: 16),
              TextField(
                controller: learningsController,
                decoration: const InputDecoration(
                  labelText: 'What did you learn? (optional)',
                  hintText: 'Any insights or observations...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.appState.endCreatorSession(
                  repsCompleted: _sessionReps,
                  learnings: learningsController.text.isNotEmpty
                      ? learningsController.text
                      : null,
                );
                Navigator.pop(dialogContext);
                setState(() => _sessionReps = 0);
              },
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );
  }

  void _showDisableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disable Creator Mode?'),
        content: const Text(
          'Your session history and rep count will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.appState.disableCreatorMode(widget.habit.id);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }
}
