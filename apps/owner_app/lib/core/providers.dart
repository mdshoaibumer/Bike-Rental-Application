import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/storage/secure_storage.dart';

// Core providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient.instance);
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

// Auth State
class OwnerAuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;

  const OwnerAuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.user,
  });

  OwnerAuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
  }) {
    return OwnerAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
    );
  }
}

class OwnerAuthNotifier extends StateNotifier<OwnerAuthState> {
  final ApiClient _api;
  final SecureStorage _storage;

  OwnerAuthNotifier(this._api, this._storage) : super(const OwnerAuthState());

  Future<void> checkAuth() async {
    final token = await _storage.getToken();
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> sendOtp(String mobile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.post('/auth/send-otp', data: {
        'mobile': mobile,
        'role': 'OWNER',
      });
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String mobile, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.post('/auth/verify-otp', data: {
        'mobile': mobile,
        'otp': otp,
        'role': 'OWNER',
      });
      final data = response.data as Map<String, dynamic>;
      await _storage.saveToken(data['access_token']);
      if (data['refresh_token'] != null) {
        await _storage.saveRefreshToken(data['refresh_token']);
      }
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: data['user'],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.deleteAll();
    state = const OwnerAuthState();
  }
}

final ownerAuthProvider =
    StateNotifierProvider<OwnerAuthNotifier, OwnerAuthState>((ref) {
  return OwnerAuthNotifier(
    ref.read(apiClientProvider),
    ref.read(secureStorageProvider),
  );
});

// Dashboard stats
class DashboardStats {
  final int totalBikes;
  final int availableBikes;
  final int activeRentals;
  final int pendingBookings;
  final double todayRevenue;
  final double monthlyRevenue;

  const DashboardStats({
    this.totalBikes = 0,
    this.availableBikes = 0,
    this.activeRentals = 0,
    this.pendingBookings = 0,
    this.todayRevenue = 0,
    this.monthlyRevenue = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalBikes: json['total_bikes'] ?? 0,
      availableBikes: json['available_bikes'] ?? 0,
      activeRentals: json['active_rentals'] ?? 0,
      pendingBookings: json['pending_bookings'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
    );
  }
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final response = await api.get('/owner/dashboard');
    return DashboardStats.fromJson(response.data);
  } catch (_) {
    return const DashboardStats();
  }
});

// Owner bikes management
class OwnerBike {
  final String id;
  final String name;
  final String? category;
  final double rentalPrice;
  final double securityDeposit;
  final String availabilityStatus;
  final String? registrationNumber;

  OwnerBike({
    required this.id,
    required this.name,
    this.category,
    required this.rentalPrice,
    required this.securityDeposit,
    required this.availabilityStatus,
    this.registrationNumber,
  });

  factory OwnerBike.fromJson(Map<String, dynamic> json) {
    return OwnerBike(
      id: json['id'] ?? '',
      name: json['bike_name'] ?? json['name'] ?? '',
      category: json['category'],
      rentalPrice: (json['rental_price'] ?? 0).toDouble(),
      securityDeposit: (json['security_deposit'] ?? 0).toDouble(),
      availabilityStatus: json['availability_status'] ?? 'Available',
      registrationNumber: json['registration_number'],
    );
  }
}

class OwnerBikesState {
  final List<OwnerBike> bikes;
  final bool isLoading;
  final String? error;

  const OwnerBikesState({
    this.bikes = const [],
    this.isLoading = false,
    this.error,
  });

  OwnerBikesState copyWith({
    List<OwnerBike>? bikes,
    bool? isLoading,
    String? error,
  }) {
    return OwnerBikesState(
      bikes: bikes ?? this.bikes,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OwnerBikesNotifier extends StateNotifier<OwnerBikesState> {
  final ApiClient _api;

  OwnerBikesNotifier(this._api) : super(const OwnerBikesState());

  Future<void> loadBikes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/bikes?limit=100');
      final list = (response.data as List)
          .map((e) => OwnerBike.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(bikes: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBike({
    required String name,
    required String category,
    required double rentalPrice,
    required double securityDeposit,
    required String registrationNumber,
  }) async {
    await _api.post('/bikes', data: {
      'bike_name': name,
      'category': category,
      'rental_price': rentalPrice,
      'security_deposit': securityDeposit,
      'registration_number': registrationNumber,
    });
    await loadBikes();
  }

  Future<void> toggleAvailability(String id, String currentStatus) async {
    final newStatus = currentStatus == 'Available' ? 'Maintenance' : 'Available';
    await _api.patch('/bikes/$id/availability', data: {'status': newStatus});
    await loadBikes();
  }

  Future<void> deleteBike(String id) async {
    await _api.delete('/bikes/$id');
    await loadBikes();
  }
}

final ownerBikesProvider =
    StateNotifierProvider<OwnerBikesNotifier, OwnerBikesState>((ref) {
  return OwnerBikesNotifier(ref.read(apiClientProvider));
});

// Owner bookings
class OwnerBooking {
  final String id;
  final String customerName;
  final String bikeName;
  final String status;
  final String pickupDate;
  final String returnDate;
  final double amount;

  OwnerBooking({
    required this.id,
    required this.customerName,
    required this.bikeName,
    required this.status,
    required this.pickupDate,
    required this.returnDate,
    required this.amount,
  });

  factory OwnerBooking.fromJson(Map<String, dynamic> json) {
    return OwnerBooking(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? 'Unknown',
      bikeName: json['bike_name'] ?? 'Unknown',
      status: json['booking_status'] ?? 'PENDING',
      pickupDate: json['pickup_date'] ?? '',
      returnDate: json['return_date'] ?? '',
      amount: (json['final_amount'] ?? 0).toDouble(),
    );
  }
}

class OwnerBookingsState {
  final List<OwnerBooking> bookings;
  final bool isLoading;
  final String? error;

  const OwnerBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  OwnerBookingsState copyWith({
    List<OwnerBooking>? bookings,
    bool? isLoading,
    String? error,
  }) {
    return OwnerBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OwnerBookingsNotifier extends StateNotifier<OwnerBookingsState> {
  final ApiClient _api;

  OwnerBookingsNotifier(this._api) : super(const OwnerBookingsState());

  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _api.get('/bookings?limit=50');
      final list = (response.data as List)
          .map((e) => OwnerBooking.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(bookings: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveBooking(String id) async {
    await _api.patch('/bookings/$id/approve');
    await loadBookings();
  }

  Future<void> rejectBooking(String id) async {
    await _api.patch('/bookings/$id/reject');
    await loadBookings();
  }

  Future<void> markPickedUp(String id) async {
    await _api.patch('/bookings/$id/pickup');
    await loadBookings();
  }

  Future<void> markReturned(String id) async {
    await _api.patch('/bookings/$id/return');
    await loadBookings();
  }

  Future<void> completeBooking(String id) async {
    await _api.patch('/bookings/$id/complete');
    await loadBookings();
  }
}

final ownerBookingsProvider =
    StateNotifierProvider<OwnerBookingsNotifier, OwnerBookingsState>((ref) {
  return OwnerBookingsNotifier(ref.read(apiClientProvider));
});
