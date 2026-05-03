import 'package:flutter_test/flutter_test.dart';
import 'package:packright/models/index.dart';

void main() {
  group('Trip Model', () {
    test('Trip creation with auto-generated ID', () {
      final trip = Trip(description: 'Test trip');
      expect(trip.id, isNotEmpty);
      expect(trip.description, equals('Test trip'));
      expect(trip.createdAt, isNotNull);
    });

    test('Trip toJson and fromJson round-trip', () {
      final original = Trip(description: '7 days in Bali');
      final json = original.toJson();
      final restored = Trip.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.description, equals(original.description));
    });

    test('Trip copyWith', () {
      final trip = Trip(description: 'Original');
      final updated = trip.copyWith(description: 'Updated');

      expect(updated.id, equals(trip.id));
      expect(updated.description, equals('Updated'));
    });
  });

  group('PackingItem Model', () {
    test('PackingItem creation', () {
      final item = PackingItem(
        tripId: 'trip123',
        name: 'Passport',
        category: 'documents',
      );

      expect(item.id, isNotEmpty);
      expect(item.tripId, equals('trip123'));
      expect(item.name, equals('Passport'));
      expect(item.isChecked, equals(false));
    });

    test('PackingItem toggle checked state', () {
      final item = PackingItem(
        tripId: 'trip123',
        name: 'Sunscreen',
      );

      final updated = item.copyWith(isChecked: true);
      expect(updated.isChecked, equals(true));
      expect(item.isChecked, equals(false)); // Original unchanged
    });

    test('PackingItem toJson and fromJson round-trip', () {
      final original = PackingItem(
        tripId: 'trip123',
        name: 'Passport',
        category: 'documents',
        quantity: 1,
        notes: 'Keep in carry-on',
      );

      final json = original.toJson();
      final restored = PackingItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.category, equals(original.category));
      expect(restored.quantity, equals(original.quantity));
      expect(restored.notes, equals(original.notes));
    });
  });
}
