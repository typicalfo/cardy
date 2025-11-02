import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/models/business_card.dart';
import '../../lib/services/card_service.dart';

void main() {
  group('CardService', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Card Storage Operations', () {
      test('should save and retrieve cards', () async {
        const card1 = BusinessCard(
          id: 'card1',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '123-456-7890',
        );

        const card2 = BusinessCard(
          id: 'card2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '098-765-4321',
          company: 'Tech Corp',
        );

        // Save cards
        await CardService.saveCard(card1);
        await CardService.saveCard(card2);

        // Retrieve all cards
        final cards = await CardService.getCards();
        
        expect(cards.length, 2);
        expect(cards.contains(card1), true);
        expect(cards.contains(card2), true);
      });

      test('should update existing card', () async {
        const originalCard = BusinessCard(
          id: 'update-test',
          name: 'Original Name',
          email: 'original@example.com',
          phone: '111-222-3333',
        );

        // Save original card
        await CardService.saveCard(originalCard);

        // Update card
        final updatedCard = originalCard.copyWith(
          name: 'Updated Name',
          company: 'Updated Company',
        );
        await CardService.saveCard(updatedCard);

        // Retrieve cards
        final cards = await CardService.getCards();
        
        expect(cards.length, 1);
        expect(cards.first.name, 'Updated Name');
        expect(cards.first.company, 'Updated Company');
        expect(cards.first.email, 'original@example.com'); // Unchanged
      });

      test('should delete card by ID', () async {
        const card1 = BusinessCard(
          id: 'delete-test-1',
          name: 'Card 1',
          email: 'card1@example.com',
          phone: '111-111-1111',
        );

        const card2 = BusinessCard(
          id: 'delete-test-2',
          name: 'Card 2',
          email: 'card2@example.com',
          phone: '222-222-2222',
        );

        // Save cards
        await CardService.saveCard(card1);
        await CardService.saveCard(card2);

        // Delete one card
        await CardService.deleteCard('delete-test-1');

        // Retrieve cards
        final cards = await CardService.getCards();
        
        expect(cards.length, 1);
        expect(cards.first.id, 'delete-test-2');
      });

      test('should get card by ID', () async {
        const card = BusinessCard(
          id: 'get-by-id-test',
          name: 'Get By ID',
          email: 'getbyid@example.com',
          phone: '333-333-3333',
          company: 'Test Company',
        );

        // Save card
        await CardService.saveCard(card);

        // Get card by ID
        final retrievedCard = await CardService.getCardById('get-by-id-test');
        
        expect(retrievedCard, isNotNull);
        expect(retrievedCard!.id, 'get-by-id-test');
        expect(retrievedCard.name, 'Get By ID');
        expect(retrievedCard.company, 'Test Company');
      });

      test('should return null for non-existent card ID', () async {
        final card = await CardService.getCardById('non-existent-id');
        expect(card, isNull);
      });
    });

    group('Default Card Management', () {
      test('should set and get default card ID', () async {
        const defaultCardId = 'default-card-123';
        
        // Set default card
        await CardService.setDefaultCardId(defaultCardId);
        
        // Get default card
        final retrievedId = await CardService.getDefaultCardId();
        
        expect(retrievedId, defaultCardId);
      });

      test('should return null when no default card is set', () async {
        final defaultId = await CardService.getDefaultCardId();
        expect(defaultId, isNull);
      });

      test('should get default card object', () async {
        const card1 = BusinessCard(
          id: 'default-obj-1',
          name: 'Default Card',
          email: 'default@example.com',
          phone: '444-444-4444',
        );

        const card2 = BusinessCard(
          id: 'default-obj-2',
          name: 'Non-Default Card',
          email: 'nondefault@example.com',
          phone: '555-555-5555',
        );

        // Save cards
        await CardService.saveCard(card1);
        await CardService.saveCard(card2);

        // Set default card
        await CardService.setDefaultCardId('default-obj-1');

        // Get default card object
        final defaultCard = await CardService.getDefaultCard();
        
        expect(defaultCard, isNotNull);
        expect(defaultCard!.id, 'default-obj-1');
        expect(defaultCard.name, 'Default Card');
      });

      test('should return null when default card ID does not exist', () async {
        // Set default card ID without saving the card
        await CardService.setDefaultCardId('non-existent-default');
        
        final defaultCard = await CardService.getDefaultCard();
        expect(defaultCard, isNull);
      });
    });

    group('Utility Methods', () {
      test('should correctly detect when cards exist', () async {
        // Initially no cards
        expect(await CardService.hasCards(), false);

        // Add a card
        const card = BusinessCard(
          id: 'has-cards-test',
          name: 'Test Card',
          email: 'test@example.com',
          phone: '666-666-6666',
        );
        await CardService.saveCard(card);

        // Now cards exist
        expect(await CardService.hasCards(), true);
      });

      test('should clear all cards', () async {
        const card1 = BusinessCard(
          id: 'clear-test-1',
          name: 'Card 1',
          email: 'card1@example.com',
          phone: '777-777-7777',
        );

        const card2 = BusinessCard(
          id: 'clear-test-2',
          name: 'Card 2',
          email: 'card2@example.com',
          phone: '888-888-8888',
        );

        // Save cards
        await CardService.saveCard(card1);
        await CardService.saveCard(card2);
        await CardService.setDefaultCardId('clear-test-1');

        // Verify cards exist
        expect(await CardService.hasCards(), true);
        expect(await CardService.getDefaultCardId(), 'clear-test-1');

        // Clear all cards
        await CardService.clearAllCards();

        // Verify everything is cleared
        expect(await CardService.hasCards(), false);
        expect(await CardService.getDefaultCardId(), isNull);
      });
    });

    group('Error Handling', () {
      test('should handle corrupted data gracefully', () async {
        // Simulate corrupted data in SharedPreferences
        SharedPreferences.setMockInitialValues({
          'business_cards': 'invalid json data',
        });

        // Should not throw exception
        final cards = await CardService.getCards();
        expect(cards, isEmpty);
      });

      test('should handle missing cards key', () async {
        // SharedPreferences without cards key
        SharedPreferences.setMockInitialValues({});

        final cards = await CardService.getCards();
        expect(cards, isEmpty);
      });
    });
  });
}