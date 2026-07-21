import 'package:flutter_test/flutter_test.dart';
import 'package:unified_app/features/bikes/providers/bike_provider.dart';
import '../../test_helpers/test_data.dart';

/// Tests for search and filter logic used throughout the app.
/// The bike search filters by bike_name (case-insensitive contains match).
/// The admin bike management filters by name AND category.

// Simulates the search logic from BikesNotifier.searchBikes (fallback path)
List<Bike> searchBikes(List<Bike> bikes, String query) {
  if (query.isEmpty) return bikes;
  return bikes
      .where((b) => b.bikeName.toLowerCase().contains(query.toLowerCase()))
      .toList();
}

// Simulates the filter logic from BikeManagementScreen
List<Bike> filterBikes(List<Bike> bikes, String searchQuery, String category) {
  return bikes.where((bike) {
    final matchesSearch =
        bike.bikeName.toLowerCase().contains(searchQuery.toLowerCase());
    final matchesCategory = category == 'All' || bike.category == category;
    return matchesSearch && matchesCategory;
  }).toList();
}

void main() {
  late List<Bike> testBikes;

  setUp(() {
    testBikes = [
      Bike.fromJson(TestData.bikeJson(id: '1', bikeName: 'Royal Enfield Classic 350', category: 'Cruiser')),
      Bike.fromJson(TestData.bikeJson(id: '2', bikeName: 'KTM Duke 390', category: 'Sport')),
      Bike.fromJson(TestData.bikeJson(id: '3', bikeName: 'Honda Activa 6G', category: 'Scooter')),
      Bike.fromJson(TestData.bikeJson(id: '4', bikeName: 'Bajaj Pulsar NS200', category: 'Sport')),
      Bike.fromJson(TestData.bikeJson(id: '5', bikeName: 'Royal Enfield Himalayan', category: 'Cruiser')),
    ];
  });

  group('Bike Search', () {
    test('empty query returns all bikes', () {
      final result = searchBikes(testBikes, '');
      expect(result.length, 5);
    });

    test('search by brand name (case insensitive)', () {
      final result = searchBikes(testBikes, 'royal enfield');
      expect(result.length, 2);
      expect(result[0].bikeName, contains('Royal Enfield'));
      expect(result[1].bikeName, contains('Royal Enfield'));
    });

    test('search by partial model name', () {
      final result = searchBikes(testBikes, 'duke');
      expect(result.length, 1);
      expect(result[0].bikeName, 'KTM Duke 390');
    });

    test('search with uppercase input works', () {
      final result = searchBikes(testBikes, 'HONDA');
      expect(result.length, 1);
      expect(result[0].bikeName, 'Honda Activa 6G');
    });

    test('search with no match returns empty', () {
      final result = searchBikes(testBikes, 'Tesla');
      expect(result, isEmpty);
    });

    test('search with single character', () {
      final result = searchBikes(testBikes, 'K');
      // KTM Duke 390 matches
      expect(result.length, 1);
    });
  });

  group('Bike Category Filter', () {
    test('filter All returns all matching search', () {
      final result = filterBikes(testBikes, '', 'All');
      expect(result.length, 5);
    });

    test('filter by Sport category', () {
      final result = filterBikes(testBikes, '', 'Sport');
      expect(result.length, 2);
      expect(result.every((b) => b.category == 'Sport'), isTrue);
    });

    test('filter by Cruiser category', () {
      final result = filterBikes(testBikes, '', 'Cruiser');
      expect(result.length, 2);
    });

    test('filter by Scooter category', () {
      final result = filterBikes(testBikes, '', 'Scooter');
      expect(result.length, 1);
      expect(result[0].bikeName, 'Honda Activa 6G');
    });

    test('filter by non-existent category returns empty', () {
      final result = filterBikes(testBikes, '', 'Electric');
      expect(result, isEmpty);
    });

    test('combined search + category filter', () {
      final result = filterBikes(testBikes, 'Royal', 'Cruiser');
      expect(result.length, 2);
    });

    test('search that matches but wrong category returns empty', () {
      final result = filterBikes(testBikes, 'Honda', 'Sport');
      expect(result, isEmpty);
    });
  });
}
