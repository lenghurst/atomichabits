// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Note: This test requires the app to be properly set up with mock data.
// Run with: flutter test integration_test/app_store_screenshots_test.dart

/// App Store Screenshot Test Suite - Phase 18: Release Engineering
/// 
/// Automates generation of screenshots for the App Store listing.
/// 
/// Key Scenes:
/// 1. "Never Miss Twice" - Recovery prompt showcasing graceful consistency
/// 2. "The Watchtower" - Contracts/Witness dashboard showing accountability
/// 3. "AI Architect" - Conversational onboarding demonstrating AI coaching
/// 
/// Usage:
/// ```bash
/// # Run on connected device/simulator
/// flutter test integration_test/app_store_screenshots_test.dart
/// 
/// # Or with specific device
/// flutter test integration_test/app_store_screenshots_test.dart -d <device_id>
/// ```
/// 
/// Screenshots are saved to: screenshots/ directory

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store Screenshots', () {
    // Directory to save screenshots
    final screenshotDir = 'screenshots';

    setUpAll(() async {
      // Create screenshots directory if it doesn't exist
      final dir = Directory(screenshotDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      // Initialize Hive for tests
      await Hive.initFlutter();
    });

    Future<void> takeScreenshot(String name) async {
      await binding.takeScreenshot('$screenshotDir/$name');
      print('📸 Screenshot saved: $screenshotDir/$name.png');
    }

    testWidgets('Screenshot 1: Never Miss Twice - Recovery Flow',
        (WidgetTester tester) async {
      // This screenshot showcases the "Never Miss Twice" philosophy
      // - Shows the recovery prompt after missing a day
      // - Highlights graceful consistency over fragile streaks
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _NeverMissTwiceScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('01_never_miss_twice');
    });

    testWidgets('Screenshot 2: The Watchtower - Witness Dashboard',
        (WidgetTester tester) async {
      // This screenshot showcases the accountability contracts feature
      // - Shows the tabbed view: "My Habits" and "Witnessing"
      // - Highlights progress tracking and nudge functionality
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _WatchtowerScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('02_watchtower_contracts');
    });

    testWidgets('Screenshot 3: AI Architect - Chat Coach',
        (WidgetTester tester) async {
      // This screenshot showcases the AI onboarding experience
      // - Shows conversational UI with habit coaching
      // - Demonstrates 2-minute rule and identity-based habits
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _AIArchitectScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('03_ai_architect_chat');
    });

    testWidgets('Screenshot 4: Chain Reaction - Habit Stacking',
        (WidgetTester tester) async {
      // This screenshot showcases the habit stacking feature
      // - Shows the "Chain Reaction" dialog after completing a habit
      // - Highlights momentum-based habit chaining
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _ChainReactionScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('04_chain_reaction_stacking');
    });

    testWidgets('Screenshot 5: Today View - Focus Mode',
        (WidgetTester tester) async {
      // This screenshot showcases the main today view
      // - Shows habit completion interface
      // - Highlights identity reinforcement and streak info
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _TodayViewScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('05_today_view');
    });

    testWidgets('Screenshot 6: Analytics Dashboard',
        (WidgetTester tester) async {
      // This screenshot showcases the analytics view
      // - Shows charts and consistency metrics
      // - Highlights long-term progress tracking
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          home: const _AnalyticsScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('06_analytics_dashboard');
    });

    // Dark mode variants
    testWidgets('Screenshot 7: Dark Mode - Today View',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: const _TodayViewScreenshot(),
        ),
      );

      await tester.pumpAndSettle();
      await takeScreenshot('07_dark_today_view');
    });
  });
}

// ============================================================
// MOCK SCREENSHOT WIDGETS
// ============================================================
// These widgets render static UI for screenshot purposes.
// They don't require full app initialization.
// ============================================================

/// Screenshot 1: Never Miss Twice Recovery Prompt
class _NeverMissTwiceScreenshot extends StatelessWidget {
  const _NeverMissTwiceScreenshot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Recovery prompt card
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology_outlined,
                      size: 48,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Never Miss Twice',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Missing once is an accident.\nMissing twice is a new habit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You missed yesterday - no problem!',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Getting back on track today matters more than a perfect streak.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Do the 2-Minute Version'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('93%', 'Never Miss\nTwice Rate', Colors.green),
                _buildStat('87', 'Days\nShowed Up', Colors.blue),
                _buildStat('94%', 'Graceful\nScore', Colors.purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Screenshot 2: The Watchtower - Contracts Dashboard
class _WatchtowerScreenshot extends StatelessWidget {
  const _WatchtowerScreenshot();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contracts'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'My Habits (2)'),
              Tab(icon: Icon(Icons.visibility), text: 'Witnessing (1)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Habits tab
            _buildMyHabitsTab(),
            // Witnessing tab
            _buildWitnessingTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New Contract'),
        ),
      ),
    );
  }

  Widget _buildMyHabitsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildContractCard(
          title: 'Read 10 pages daily',
          status: 'Active',
          statusColor: Colors.green,
          completionRate: 85,
          streak: 12,
          witnessName: 'Sarah',
        ),
        const SizedBox(height: 12),
        _buildContractCard(
          title: 'Morning meditation',
          status: 'Pending',
          statusColor: Colors.orange,
          completionRate: 0,
          streak: 0,
          witnessName: null,
        ),
      ],
    );
  }

  Widget _buildWitnessingTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWitnessCard(
          title: 'Exercise 2 min',
          builderName: 'Mike',
          status: 'Active',
          completionRate: 72,
          streak: 5,
        ),
      ],
    );
  }

  Widget _buildContractCard({
    required String title,
    required String status,
    required Color statusColor,
    required int completionRate,
    required int streak,
    String? witnessName,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (streak > 0)
                  Text(
                    '🔥 $streak day streak',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (completionRate > 0) ...[
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 8),
              Text(
                '$completionRate% completion rate',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
            if (witnessName == null)
              Row(
                children: [
                  const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for witness to join',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWitnessCard({
    required String title,
    required String builderName,
    required String status,
    required int completionRate,
    required int streak,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(builderName[0]),
                ),
                const SizedBox(width: 8),
                Text(
                  builderName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  '🔥 $streak',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                completionRate >= 70 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.rocket_launch, size: 16),
              label: const Text('Send Nudge'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screenshot 3: AI Architect - Chat Coach
class _AIArchitectScreenshot extends StatelessWidget {
  const _AIArchitectScreenshot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Habit'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AI message
                _buildAIMessage(
                  "Hi! I'm your habit coach. What's one small habit you'd like to build?",
                ),
                const SizedBox(height: 12),
                // User message
                _buildUserMessage("I want to exercise every day"),
                const SizedBox(height: 12),
                // AI response with thinking
                _buildAIMessage(
                  "That's a great goal! 💪\n\n"
                  "Let me help you make it stick. \"Exercise every day\" is a bit ambitious to start.\n\n"
                  "Following the 2-Minute Rule:\n"
                  "• Instead of \"exercise for 30 minutes\"\n"
                  "• Start with \"do 2 minutes of stretching\"\n\n"
                  "What's the tiniest version you could do even on your hardest days?",
                  showThinking: true,
                ),
                const SizedBox(height: 12),
                // User message
                _buildUserMessage("Put on my workout clothes"),
                const SizedBox(height: 12),
                // AI response
                _buildAIMessage(
                  "Perfect! 🎯\n\n"
                  "\"Put on workout clothes\" is brilliant because:\n"
                  "• It takes under 2 minutes\n"
                  "• It triggers the full behavior\n"
                  "• It's impossible to fail\n\n"
                  "When will you do this? (e.g., \"Right after I wake up\")",
                ),
              ],
            ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your response...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text, {bool showThinking = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.deepPurple,
          child: const Icon(Icons.psychology, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showThinking) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb, size: 12, color: Colors.purple.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'Applying 2-Minute Rule...',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(text),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildUserMessage(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 40),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

/// Screenshot 4: Chain Reaction - Habit Stacking
class _ChainReactionScreenshot extends StatelessWidget {
  const _ChainReactionScreenshot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with glow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.link,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Chain Reaction!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'ve built momentum!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Completed badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Put on workout clothes',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Chain link
                const Icon(Icons.link, color: Colors.green, size: 24),
                
                const SizedBox(height: 16),
                
                // Next habit card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Continue your momentum with',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🏃', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 8),
                          Text(
                            '2 min stretching',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Just: Touch your toes twice',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Let's Do It"),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Not right now',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Screenshot 5: Today View - Focus Mode
class _TodayViewScreenshot extends StatelessWidget {
  const _TodayViewScreenshot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Identity statement
            Card(
              color: Colors.deepPurple.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'I am someone who takes care of my health',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Every vote counts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Habit card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('🏃', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'Morning Exercise',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Put on workout clothes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatChip('🔥', '12', 'Streak'),
                        _buildStatChip('📅', '87', 'Days'),
                        _buildStatChip('🗳️', '94', 'Votes'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Complete button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle_outline, size: 24),
                        label: const Text(
                          'Mark Complete',
                          style: TextStyle(fontSize: 18),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Implementation intention
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'After I wake up, at 7:00 AM in my bedroom',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Screenshot 6: Analytics Dashboard
class _AnalyticsScreenshot extends StatelessWidget {
  const _AnalyticsScreenshot();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graceful Score Card
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Graceful Score',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '94',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            'Better than fragile streaks',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 0.94,
                        strokeWidth: 10,
                        backgroundColor: Colors.deepPurple.shade100,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('87', 'Days\nShowed Up', Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('93%', 'Weekly\nAverage', Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('12', 'Current\nStreak', Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('95%', 'Never Miss\nTwice Rate', Colors.amber),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Weekly chart placeholder
            const Text(
              'Last 7 Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDayBar('M', 1.0, true),
                    _buildDayBar('T', 1.0, true),
                    _buildDayBar('W', 0.0, false),
                    _buildDayBar('T', 1.0, true),
                    _buildDayBar('F', 1.0, true),
                    _buildDayBar('S', 1.0, true),
                    _buildDayBar('S', 0.5, true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBar(String day, double value, bool completed) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 30,
              height: 80 * value,
              decoration: BoxDecoration(
                color: completed ? Colors.green : Colors.red.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: completed ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
