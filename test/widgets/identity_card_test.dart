import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atomic_habits_hook_app/features/today/widgets/identity_card.dart';

/// Widget Tests for IdentityCard
/// 
/// These tests verify the presentational widget renders correctly.
/// Dumb widgets are easy to test - just check if props show up in the UI.
void main() {
  group('IdentityCard', () {
    testWidgets('displays user name with greeting', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: 'Alex',
              identity: 'I am a reader',
            ),
          ),
        ),
      );

      expect(find.text('Hello, Alex! 👋'), findsOneWidget);
    });

    testWidgets('displays identity text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: 'Alex',
              identity: 'I am a person who reads daily',
            ),
          ),
        ),
      );

      expect(find.text('I am a person who reads daily'), findsOneWidget);
    });

    testWidgets('has star icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: 'Alex',
              identity: 'I am a reader',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('has container with rounded corners', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: 'Alex',
              identity: 'I am a reader',
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      
      expect(decoration.borderRadius, equals(BorderRadius.circular(12)));
    });

    testWidgets('renders with long identity text', (tester) async {
      const longIdentity = 'I am a person who reads every day, exercises regularly, eats healthy, and maintains positive relationships';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: 'Alex',
              identity: longIdentity,
            ),
          ),
        ),
      );

      expect(find.text(longIdentity), findsOneWidget);
    });

    testWidgets('renders with special characters in name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IdentityCard(
              userName: "José O'Connor",
              identity: 'I am focused',
            ),
          ),
        ),
      );

      expect(find.text("Hello, José O'Connor! 👋"), findsOneWidget);
    });
  });
}
