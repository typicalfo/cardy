import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/business_card.dart';

void main() {
  group('BusinessCard', () {
    test('should create BusinessCard with required fields', () {
      const card = BusinessCard(
        id: 'test-id',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '123-456-7890',
      );

      expect(card.id, 'test-id');
      expect(card.name, 'John Doe');
      expect(card.email, 'john@example.com');
      expect(card.phone, '123-456-7890');
      expect(card.company, '');
      expect(card.title, '');
      expect(card.website, '');
      expect(card.isDefault, false);
    });

    test('should create BusinessCard with all fields', () {
      const card = BusinessCard(
        id: 'test-id',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '098-765-4321',
        company: 'Tech Corp',
        title: 'Software Engineer',
        website: 'https://techcorp.com',
        isDefault: true,
      );

      expect(card.id, 'test-id');
      expect(card.name, 'Jane Smith');
      expect(card.email, 'jane@example.com');
      expect(card.phone, '098-765-4321');
      expect(card.company, 'Tech Corp');
      expect(card.title, 'Software Engineer');
      expect(card.website, 'https://techcorp.com');

      expect(card.isDefault, true);
    });

    test('should copy BusinessCard with new values', () {
      const original = BusinessCard(
        id: 'original-id',
        name: 'Original Name',
        email: 'original@example.com',
        phone: '111-222-3333',
      );

      final copied = original.copyWith(
        name: 'Updated Name',
        company: 'New Company',
      );

      expect(copied.id, 'original-id'); // ID should remain the same
      expect(copied.name, 'Updated Name');
      expect(copied.email, 'original@example.com'); // Unchanged
      expect(copied.phone, '111-222-3333'); // Unchanged
      expect(copied.company, 'New Company');
    });

    test('should serialize to JSON correctly', () {
      const card = BusinessCard(
        id: 'json-test',
        name: 'JSON User',
        email: 'json@example.com',
        phone: '555-123-4567',
        company: 'JSON Corp',
        title: 'Developer',
        website: 'https://jsoncorp.com',

        isDefault: true,
      );

      final json = card.toJson();

      expect(json['id'], 'json-test');
      expect(json['name'], 'JSON User');
      expect(json['email'], 'json@example.com');
      expect(json['phone'], '555-123-4567');
      expect(json['company'], 'JSON Corp');
      expect(json['title'], 'Developer');
      expect(json['website'], 'https://jsoncorp.com');

      expect(json['isDefault'], true);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'deserialize-test',
        'name': 'Deserialize User',
        'email': 'deserialize@example.com',
        'phone': '777-888-9999',
        'company': 'Deserialize Inc',
        'title': 'Tester',
        'website': 'https://deserialize.com',

        'isDefault': false,
      };

      final card = BusinessCard.fromJson(json);

      expect(card.id, 'deserialize-test');
      expect(card.name, 'Deserialize User');
      expect(card.email, 'deserialize@example.com');
      expect(card.phone, '777-888-9999');
      expect(card.company, 'Deserialize Inc');
      expect(card.title, 'Tester');
      expect(card.website, 'https://deserialize.com');

      expect(card.isDefault, false);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'minimal-test',
        'name': 'Minimal User',
        'email': 'minimal@example.com',
        'phone': '000-111-2222',
        // Missing optional fields
      };

      final card = BusinessCard.fromJson(json);

      expect(card.id, 'minimal-test');
      expect(card.name, 'Minimal User');
      expect(card.email, 'minimal@example.com');
      expect(card.phone, '000-111-2222');
      expect(card.company, ''); // Default value
      expect(card.title, ''); // Default value
      expect(card.website, ''); // Default value

      expect(card.isDefault, false); // Default value
    });

    test('should implement equality correctly', () {
      const card1 = BusinessCard(
        id: 'equality-test',
        name: 'Test User',
        email: 'test@example.com',
        phone: '123-456-7890',
      );

      const card2 = BusinessCard(
        id: 'equality-test',
        name: 'Test User',
        email: 'test@example.com',
        phone: '123-456-7890',
      );

      const card3 = BusinessCard(
        id: 'different-id',
        name: 'Test User',
        email: 'test@example.com',
        phone: '123-456-7890',
      );

      expect(card1, equals(card2));
      expect(card1, isNot(equals(card3)));
    });

    test('should have correct toString implementation', () {
      const card = BusinessCard(
        id: 'tostring-test',
        name: 'String User',
        email: 'string@example.com',
        phone: '555-666-7777',
        company: 'String Corp',
      );

      final stringRepresentation = card.toString();
      
      expect(stringRepresentation, contains('String User'));
      expect(stringRepresentation, contains('string@example.com'));
      expect(stringRepresentation, contains('String Corp'));
    });
  });
}