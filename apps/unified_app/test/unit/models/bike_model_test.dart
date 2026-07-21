import 'package:flutter_test/flutter_test.dart';
import 'package:unified_app/features/bikes/providers/bike_provider.dart';
import '../../test_helpers/test_data.dart';

void main() {
  group('Bike Model', () {
    test('fromJson creates a Bike with all fields', () {
      final json = TestData.bikeJson();
      final bike = Bike.fromJson(json);

      expect(bike.id, 'bike_1');
      expect(bike.bikeName, 'Royal Enfield Classic 350');
      expect(bike.brand, 'Royal Enfield');
      expect(bike.model, 'Classic 350');
      expect(bike.category, 'Cruiser');
      expect(bike.rentalPrice, 1200.0);
      expect(bike.securityDeposit, 3000.0);
      expect(bike.availabilityStatus, 'Available');
      expect(bike.engineCC, 349);
      expect(bike.fuelType, 'Petrol');
      expect(bike.transmission, 'Manual');
      expect(bike.registrationNumber, 'KA-01-HH-1234');
    });

    test('fromJson handles null/missing values gracefully', () {
      final json = <String, dynamic>{
        'id': null,
        'bike_name': null,
      };
      final bike = Bike.fromJson(json);

      expect(bike.id, '');
      expect(bike.bikeName, '');
      expect(bike.brand, '');
      expect(bike.rentalPrice, 0.0);
      expect(bike.engineCC, 0);
      expect(bike.fuelType, 'Petrol');
      expect(bike.transmission, 'Manual');
    });

    test('fromJson handles integer rental price (JSON number type)', () {
      final json = TestData.bikeJson();
      json['rental_price'] = 1200; // int instead of double
      final bike = Bike.fromJson(json);

      expect(bike.rentalPrice, 1200.0);
    });

    test('fromJson reads image_url from alternative key imageUrl', () {
      final json = TestData.bikeJson();
      json.remove('image_url');
      json['imageUrl'] = 'https://example.com/bike.jpg';
      final bike = Bike.fromJson(json);

      expect(bike.imageUrl, 'https://example.com/bike.jpg');
    });
  });

  group('BikeCategory Model', () {
    test('fromJson creates a BikeCategory', () {
      final json = {
        'id': 'cat_1',
        'name': 'Sport',
        'description': 'Sport bikes',
      };
      final category = BikeCategory.fromJson(json);

      expect(category.id, 'cat_1');
      expect(category.name, 'Sport');
      expect(category.description, 'Sport bikes');
    });

    test('fromJson handles empty JSON', () {
      final category = BikeCategory.fromJson({});

      expect(category.id, '');
      expect(category.name, '');
      expect(category.description, '');
    });
  });

  group('BikesState', () {
    test('initial state has empty bikes and not loading', () {
      const state = BikesState();

      expect(state.bikes, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('copyWith updates only specified fields', () {
      const state = BikesState();
      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.bikes, isEmpty);
      expect(updated.error, isNull);
    });

    test('copyWith can set error', () {
      const state = BikesState();
      final updated = state.copyWith(error: 'Network error');

      expect(updated.error, 'Network error');
    });
  });
}
