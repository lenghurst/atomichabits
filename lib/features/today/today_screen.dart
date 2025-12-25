import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/router/app_routes.dart';
import '../../data/app_state.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_profile.dart';
import '../../widgets/graceful_consistency_card.dart';
import '../../widgets/pre_habit_ritual_dialog.dart';
import '../../widgets/guest_data_warning_banner.dart';
import 'widgets/identity_card.dart';
import 'widgets/habit_card.dart';
import 'widgets/completion_button.dart';
import 'widgets/recovery_banner.dart';
import 'widgets/ritual_button.dart';
import 'widgets/optimization_tips_button.dart';
import 'controllers/today_screen_controller.dart';

/// TodayScreen - Shows today's habit and graceful consistency metrics
/// 
/// **Phase 4: Multi-Habit Support**
/// - PageView for swiping between habits
/// - Navigation back to Dashboard
/// - Updates focused habit on swipe
/// 
/// **Vibecoding Architecture:**
/// This screen is now purely presentational following vibecoding rules:
/// - UI components handle "how it looks" (layout, styling)
/// - TodayScreenController handles "how it behaves" (dialogs, side effects)
/// - Helpers handle "how data is styled" (color logic, transforms)
/// 
/// **Implements:**
/// - Hook Model: Trigger → Action → Variable Reward → Investment
/// - Graceful Consistency Philosophy
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with WidgetsBindingObserver {
  late TodayScreenController _controller;
  PageController? _pageController;
  int _currentPageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize controller after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initController();
      _initPageController();
      _controller.onScreenResumed();
    });
  }
  
  void _initController() {
    final appState = Provider.of<AppState>(context, listen: false);
    _controller = TodayScreenController(
      context: context,
      appState: appState,
    );
  }
  
  void _initPageController() {
    final appState = Provider.of<AppState>(context, listen: false);
    // Find the index of the currently focused habit
    final currentHabit = appState.currentHabit;
    if (currentHabit != null) {
      _currentPageIndex = appState.habits.indexWhere((h) => h.id == currentHabit.id);
      if (_currentPageIndex < 0) _currentPageIndex = 0;
    }
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.onScreenResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Update controller reference when appState changes
        _controller = TodayScreenController(
          context: context,
          appState: appState,
        );
        
        final habits = appState.habits;
        
        if (habits.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(appState, null),
            body: SafeArea(
              child: _NoHabitView(onGoToOnboarding: () => context.go(AppRoutes.home)),
            ),
          );
        }
        
        return Scaffold(
          appBar: _buildAppBar(appState, habits.length > 1 ? habits : null),
          body: SafeArea(
            child: habits.length == 1
                ? _buildSingleHabitView(appState, habits[0])
                : _buildPageView(appState, habits),
          ),
        );
      },
    );
  }
  
  // ========== App Bar (Layout Only) ==========
  
  PreferredSizeWidget _buildAppBar(AppState appState, List<Habit>? multipleHabits) {
    return AppBar(
      leading: multipleHabits != null
          ? IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Dashboard',
              onPressed: () => context.go(AppRoutes.dashboard),
            )
          : null,
      title: multipleHabits != null
          ? _buildPageIndicator(multipleHabits.length)
          : const Text('Today'),
      centerTitle: true,
      actions: [
        // History button (Phase 5)
        IconButton(
          icon: const Icon(Icons.calendar_month_outlined),
          tooltip: 'History',
          onPressed: () => context.push(AppRoutes.history),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => appState.showTestNotification(),
          tooltip: 'Test notification',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }
  
  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPageIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPageIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
  
  // ========== Body (Layout Only) ==========
  
  Widget _buildSingleHabitView(AppState appState, Habit habit) {
    final profile = appState.userProfile;
    final isCompleted = appState.isHabitCompletedToday(habitId: habit.id);
    
    return _HabitView(
      habit: habit,
      profile: profile,
      isCompleted: isCompleted,
      appState: appState,
      controller: _controller,
    );
  }
  
  Widget _buildPageView(AppState appState, List<Habit> habits) {
    return PageView.builder(
      controller: _pageController,
      itemCount: habits.length,
      onPageChanged: (index) {
        setState(() => _currentPageIndex = index);
        // Update focused habit in AppState
        appState.setFocusHabit(habits[index].id);
      },
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = appState.isHabitCompletedToday(habitId: habit.id);
        
        return _HabitView(
          habit: habit,
          profile: appState.userProfile,
          isCompleted: isCompleted,
          appState: appState,
          controller: _controller,
        );
      },
    );
  }
}

/// View shown when no habit is set
class _NoHabitView extends StatelessWidget {
  final VoidCallback onGoToOnboarding;
  
  const _NoHabitView({required this.onGoToOnboarding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habit set yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete onboarding to create your first habit',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onGoToOnboarding,
            child: const Text('Go to Onboarding'),
          ),
        ],
      ),
    );
  }
}

/// Main habit view - purely presentational, delegates actions to controller
class _HabitView extends StatelessWidget {
  final Habit habit;
  final UserProfile? profile;
  final bool isCompleted;
  final AppState appState;
  final TodayScreenController controller;
  
  const _HabitView({
    required this.habit,
    required this.profile,
    required this.isCompleted,
    required this.appState,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phase 24: Guest Data Warning Banner
          // Shows for anonymous users with active pacts
          GuestDataWarningBanner(
            onSignUp: () => context.push(AppRoutes.settingsAccount),
          ),
          
          // Identity reminder
          if (profile != null) ...[
            IdentityCard(
              userName: profile!.name,
              identity: profile!.identity,
            ),
            const SizedBox(height: 32),
          ],

          // Section title
          _SectionTitle(title: 'Your Habit for Today'),
          const SizedBox(height: 16),

          // Habit card
          HabitCard(
            habitName: habit.name,
            tinyVersion: habit.tinyVersion,
            implementationTime: habit.implementationTime,
            implementationLocation: habit.implementationLocation,
            temptationBundle: habit.temptationBundle,
            environmentCue: habit.environmentCue,
            environmentDistraction: habit.environmentDistraction,
            isCompleted: isCompleted,
            // Phase 12: Bad Habit Protocol
            isBreakHabit: habit.isBreakHabit,
            substitutionPlan: habit.substitutionPlan,
          ),
          const SizedBox(height: 24),

          // Consistency section
          _SectionTitle(title: 'Your Consistency'),
          const SizedBox(height: 16),

          GracefulConsistencyCard(
            metrics: habit.consistencyMetrics,
            identityVotes: habit.identityVotes,
            showDetailedMetrics: true,
            onTap: () => controller.showConsistencyDetails(habit),
          ),
          const SizedBox(height: 24),

          // Recovery banner (if needed)
          if (!isCompleted && habit.needsRecovery && appState.currentRecoveryNeed != null) ...[
            RecoveryBanner(
              urgency: appState.currentRecoveryNeed!.urgency,
              onTap: () => controller.showRecoveryDialog(),
            ),
            const SizedBox(height: 24),
          ],

          // Pre-habit ritual button
          if (!isCompleted && _hasPreHabitRitual) ...[
            RitualButton(
              onPressed: () => _showPreHabitRitual(context),
            ),
            const SizedBox(height: 16),
          ],

          // Completion button
          CompletionButton(
            isCompleted: isCompleted,
            onComplete: () => controller.handleCompleteHabit(),
            // Phase 12: Bad Habit Protocol
            isBreakHabit: habit.isBreakHabit,
          ),
          const SizedBox(height: 24),
          
          // Optimization tips button
          OptimizationTipsButton(
            onPressed: () => controller.showImprovementSuggestions(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  bool get _hasPreHabitRitual =>
      habit.preHabitRitual != null && habit.preHabitRitual!.isNotEmpty;
  
  void _showPreHabitRitual(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => PreHabitRitualDialog(
        ritualText: habit.preHabitRitual!,
        onDismiss: () => Navigator.of(dialogContext).pop(),
      ),
    );
  }
}

/// Simple section title widget
class _SectionTitle extends StatelessWidget {
  final String title;
  
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
