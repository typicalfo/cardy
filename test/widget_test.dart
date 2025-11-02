import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cardy/main.dart';
import 'package:cardy/models/business_card.dart';
import 'package:cardy/services/card_service.dart';

void main() {
  group('Business Card App Widget Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should show empty state when no cards exist', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));

      // Verify we're on gallery screen
      expect(find.text('My Business Cards'), findsOneWidget);
      
      // Verify empty state is shown
      expect(find.text('No business cards yet'), findsOneWidget);
      expect(find.text('Create your first business card to start networking'), findsOneWidget);
      expect(find.text('Create Business Card'), findsOneWidget);
    });

    testWidgets('should navigate to edit screen when create button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));

      // Tap create button
      await tester.tap(find.text('Create Business Card'));
      await tester.pumpAndSettle();

      // Verify we're on edit screen
      expect(find.text('Edit Business Card'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should show search bar in gallery', (WidgetTester tester) async {
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));

      // Verify search bar is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search business cards...'), findsOneWidget);
    });

    testWidgets('should filter cards when searching', (WidgetTester tester) async {
      // Add test cards
      const card1 = BusinessCard(
        id: 'search-test-1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '123-456-7890',
        company: 'Tech Corp',
      );

      const card2 = BusinessCard(
        id: 'search-test-2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '098-765-4321',
        company: 'Design Inc',
      );

      await CardService.saveCard(card1);
      await CardService.saveCard(card2);

      // Build app
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      // Should only show John's card
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsNothing);
    });

    testWidgets('should show no results when search has no matches', (WidgetTester tester) async {
      // Add test card
      const card = BusinessCard(
        id: 'no-results-test',
        name: 'Test User',
        email: 'test@example.com',
        phone: '111-222-3333',
      );

      await CardService.saveCard(card);

      // Build app
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Enter search query with no matches
      await tester.enterText(find.byType(TextField), 'NonExistent');
      await tester.pump();

      // Should show no results message
      expect(find.text('No cards found'), findsOneWidget);
      expect(find.text('Try adjusting your search terms'), findsOneWidget);
      expect(find.text('Clear Search'), findsOneWidget);
    });

    testWidgets('should clear search when clear button is tapped', (WidgetTester tester) async {
      // Add test card
      const card = BusinessCard(
        id: 'clear-search-test',
        name: 'Test User',
        email: 'test@example.com',
        phone: '111-222-3333',
      );

      await CardService.saveCard(card);

      // Build app
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();

      // Verify search is active
      expect(find.text('Test User'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verify search field is cleared
      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, '');
    });

    testWidgets('should navigate to card view when card is tapped', (WidgetTester tester) async {
      // Add test card
      const card = BusinessCard(
        id: 'card-view-test',
        name: 'View Test',
        email: 'view@example.com',
        phone: '555-555-5555',
        company: 'View Corp',
      );

      await CardService.saveCard(card);

      // Build app
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Tap on card
      await tester.tap(find.text('View Test'));
      await tester.pumpAndSettle();

      // Verify we're on card screen
      expect(find.text('View Test'), findsOneWidget);
      expect(find.text('view@example.com'), findsOneWidget);
      expect(find.text('555-555-5555'), findsOneWidget);
      expect(find.text('View Corp'), findsOneWidget);
    });

    testWidgets('should show default badge on default card', (WidgetTester tester) async {
      // Add test cards
      const card1 = BusinessCard(
        id: 'default-badge-1',
        name: 'Default Card',
        email: 'default@example.com',
        phone: '111-111-1111',
      );

      const card2 = BusinessCard(
        id: 'default-badge-2',
        name: 'Regular Card',
        email: 'regular@example.com',
        phone: '222-222-2222',
      );

      await CardService.saveCard(card1);
      await CardService.saveCard(card2);
      await CardService.setDefaultCardId('default-badge-1');

      // Build app
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Verify default badge is shown
      expect(find.text('Default'), findsOneWidget);
      
      // Verify it's on the correct card
      expect(find.text('Default Card'), findsOneWidget);
      expect(find.text('Regular Card'), findsOneWidget);
    });

    testWidgets('should handle app initialization correctly', (WidgetTester tester) async {
      // Test with no cards - should go to gallery
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();
      
      expect(find.text('My Business Cards'), findsOneWidget);
      expect(find.text('No business cards yet'), findsOneWidget);
    });

    testWidgets('should show responsive layout', (WidgetTester tester) async {
      // Add multiple test cards
      for (int i = 0; i < 5; i++) {
        final card = BusinessCard(
          id: 'responsive-test-$i',
          name: 'Card $i',
          email: 'card$i@example.com',
          phone: '123-456-789$i',
        );
        await CardService.saveCard(card);
      }

      // Test mobile layout (default)
      await tester.pumpWidget(const BusinessCardApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Should show list view on mobile
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Card 0'), findsOneWidget);
      expect(find.text('Card 1'), findsOneWidget);
    });
  });
}
