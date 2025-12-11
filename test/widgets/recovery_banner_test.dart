import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/features/today/widgets/recovery_banner.dart';
import 'package:atomic_habits_hook_app/data/models/consistency_metrics.dart';

/// Widget Tests for RecoveryBanner
/// 
/// These tests verify the recovery banner renders correctly for each urgency level
/// and that styling is properly applied from the helper.
void main() {
  group('RecoveryBanner', () {
    // ========== Gentle Urgency Tests ==========
    group('gentle urgency', () {
      testWidgets('shows Never Miss Twice title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Never Miss Twice'), findsOneWidget);
      });

      testWidgets('shows sunny icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      });

      testWidgets('uses amber colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        // Find the outer container
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        
        // Should use amber shade background
        expect(decoration.color, equals(Colors.amber.shade50));
      });
    });

    // ========== Important Urgency Tests ==========
    group('important urgency', () {
      testWidgets('shows Day 2 - Critical title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.important,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Day 2 - Critical'), findsOneWidget);
      });

      testWidgets('shows warning icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.important,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.warning_amber), findsOneWidget);
      });

      testWidgets('uses orange colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.important,
                onTap: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.color, equals(Colors.orange.shade50));
      });
    });

    // ========== Compassionate Urgency Tests ==========
    group('compassionate urgency', () {
      testWidgets('shows Welcome Back title', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.compassionate,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Welcome Back'), findsOneWidget);
      });

      testWidgets('shows heart icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.compassionate,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.favorite), findsOneWidget);
      });

      testWidgets('uses purple colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.compassionate,
                onTap: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.color, equals(Colors.purple.shade50));
      });
    });

    // ========== Common Features ==========
    group('common features', () {
      testWidgets('shows tap to see plan subtitle', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.text('Tap to see your comeback plan'), findsOneWidget);
      });

      testWidgets('shows chevron right icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('calls onTap when pressed', (tester) async {
        var wasTapped = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(wasTapped, isTrue);
      });

      testWidgets('has rounded corners', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
      });

      testWidgets('has border', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecoveryBanner(
                urgency: RecoveryUrgency.gentle,
                onTap: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(Container).first,
          ),
        );
        final decoration = container.decoration as BoxDecoration;
        
        expect(decoration.border, isNotNull);
      });
    });

    // ========== All Urgency Levels Test ==========
    group('urgency level rendering', () {
      for (final urgency in RecoveryUrgency.values) {
        testWidgets('renders correctly for $urgency', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RecoveryBanner(
                  urgency: urgency,
                  onTap: () {},
                ),
              ),
            ),
          );

          // Should not throw errors
          expect(find.byType(RecoveryBanner), findsOneWidget);
          
          // Should have gesture detector
          expect(find.byType(GestureDetector), findsOneWidget);
          
          // Should have a title
          expect(
            find.byWidgetPredicate((widget) =>
              widget is Text &&
              widget.style?.fontWeight == FontWeight.bold,
            ),
            findsWidgets,
          );
        });
      }
    });
  });
}
