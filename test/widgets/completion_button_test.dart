import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/features/today/widgets/completion_button.dart';

/// Widget Tests for CompletionButton
/// 
/// These tests verify the button renders correctly in both states
/// and that callbacks are properly invoked.
void main() {
  group('CompletionButton', () {
    // ========== Not Completed State ==========
    group('when not completed', () {
      testWidgets('shows Mark as Complete text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: false,
                onComplete: () {},
              ),
            ),
          ),
        );

        expect(find.text('Mark as Complete ✓'), findsOneWidget);
      });

      testWidgets('has green background', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: false,
                onComplete: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final style = button.style!;
        
        // Check background color is green
        expect(
          style.backgroundColor?.resolve({}),
          equals(Colors.green),
        );
      });

      testWidgets('calls onComplete when pressed', (tester) async {
        var wasPressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: false,
                onComplete: () => wasPressed = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });

      testWidgets('is full width', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CompletionButton(
                  isCompleted: false,
                  onComplete: () {},
                ),
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, equals(double.infinity));
      });
    });

    // ========== Completed State ==========
    group('when completed', () {
      testWidgets('shows Completed for today! text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: true,
                onComplete: () {},
              ),
            ),
          ),
        );

        expect(find.textContaining('Completed for today'), findsOneWidget);
      });

      testWidgets('shows check circle icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: true,
                onComplete: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('does not show button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: true,
                onComplete: () {},
              ),
            ),
          ),
        );

        expect(find.byType(ElevatedButton), findsNothing);
      });

      testWidgets('has green border', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CompletionButton(
                isCompleted: true,
                onComplete: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).first);
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.border?.top.color, equals(Colors.green));
      });
    });

    // ========== State Transitions ==========
    group('state transitions', () {
      testWidgets('switches from button to status when completed', (tester) async {
        var isCompleted = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => CompletionButton(
                  isCompleted: isCompleted,
                  onComplete: () => setState(() => isCompleted = true),
                ),
              ),
            ),
          ),
        );

        // Initially shows button
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsNothing);

        // Tap to complete
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Now shows completed status
        expect(find.byType(ElevatedButton), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });
  });
}
