import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/demo/mock_data.dart';
import '../../../core/providers.dart';

// Bike model
class Bike {
  final String id;
  final String bikeName;
  final String brand;
  final String model;
  final String? category;
  final double rentalPrice;
  final double securityDeposit;
  final String availabilityStatus;
  final String? description;
  final String? color;
  final int engineCC;
  final String fuelType;
  final String transmission;
  final String? imageUrl;
  final String? registrationNumber;

  Bike({
    required this.id,
    required this.bikeName,
    required this.brand,
    required this.model,
    this.category,
    required this.rentalPrice,
    required this.securityDeposit,
    required this.availabilityStatus,
    this.description,
    this.color,
    this.engineCC = 0,
    this.fuelType = 'Petrol',
    this.transmission = 'Manual',
    this.imageUrl,
    this.registrationNumber,
  });

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'] ?? '',
      bikeName: json['bike_name'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      category: json['category'],
      rentalPrice: (json['rental_price'] ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] ?? 0).toDouble(),
      availabilityStatus: json['availability_status'] ?? 'Available',
      description: json['description'],
      color: json['color'],
      engineCC: json['engine_cc'] ?? 0,
      fuelType: json['fuel_type'] ?? 'Petrol',
      transmission: json['transmission'] ?? 'Manual',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      registrationNumber: json['registration_number'],
    );
  }
}

class BikeCategory {
  final String id;
  final String name;
  final String description;

  BikeCategory({required this.id, required this.name, required this.description});

  factory BikeCategory.fromJson(Map<String, dynamic> json) {
    return BikeCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

// Bikes state
class BikesState {
  final List<Bike> bikes;
  final List<BikeCategory> categories;
  final bool isLoading;
  final String? error;

  const BikesState({
    this.bikes = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  BikesState copyWith({
    List<Bike>? bikes,
    List<BikeCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return BikesState(
      bikes: bikes ?? this.bikes,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BikesNotifier extends StateNotifier<BikesState> {
  final ApiClient _apiClient;

  BikesNotifier(this._apiClient) : super(const BikesState());

  Future<void> loadBikes({int offset = 0, int limit = 20}) async {
    // Load demo data immediately for instant display
    MockData.initializeImages();
    final demoBikes = MockData.bikes.map((json) => Bike.fromJson(json)).toList();
    
    if (state.bikes.isEmpty) {
      state = state.copyWith(bikes: demoBikes, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }

    // Then try API in background - if it succeeds, replace with real data
    try {
      final response = await _apiClient.dio.get('/bikes', queryParameters: {
        'offset': offset,
        'limit': limit,
      });
      final List<dynamic> data = response.data['data'] ?? [];
      List<Bike> bikes = data.map((json) => Bike.fromJson(json)).toList();
      
      if (bikes.isNotEmpty) {
        state = state.copyWith(bikes: bikes, isLoading: false);
      }
    } catch (e) {
      // API failed - demo data already loaded, nothing to do
    }
  }

  Future<void> searchBikes(String query) async {
    MockData.initializeImages();
    // Search locally in demo data for instant results
    final demoBikes = MockData.bikes
        .where((b) => b['bike_name'].toString().toLowerCase().contains(query.toLowerCase()))
        .map((json) => Bike.fromJson(json)).toList();
    state = state.copyWith(bikes: demoBikes, isLoading: false);

    // Try API search in background
    try {
      final response = await _apiClient.dio.get('/bikes/search', queryParameters: {'q': query});
      final List<dynamic> data = response.data['data'] ?? [];
      List<Bike> bikes = data.map((json) => Bike.fromJson(json)).toList();
      
      if (bikes.isNotEmpty) {
        state = state.copyWith(bikes: bikes, isLoading: false);
      }
    } catch (e) {
      // API failed - local results already showing
    }
  }

  Future<void> loadCategories() async {
    try {
      final response = await _apiClient.dio.get('/bikes/categories');
      final List<dynamic> data = response.data is List ? response.data : [];
      final categories = data.map((json) => BikeCategory.fromJson(json)).toList();
      state = state.copyWith(categories: categories);
    } catch (_) {}
  }
}

final bikesProvider = StateNotifierProvider<BikesNotifier, BikesState>((ref) {
  return BikesNotifier(ref.read(apiClientProvider));
});

// Single bike detail provider
final bikeDetailProvider = FutureProvider.family<Bike?, String>((ref, bikeId) async {
  final apiClient = ref.read(apiClientProvider);
  try {
    final response = await apiClient.dio.get('/bikes/$bikeId');
    return Bike.fromJson(response.data);
  } catch (_) {
    try {
      MockData.initializeImages();
      final mock = MockData.bikes.firstWhere((b) => b['id'] == bikeId);
      return Bike.fromJson(mock);
    } catch (_) {
      return null;
    }
  }
});
