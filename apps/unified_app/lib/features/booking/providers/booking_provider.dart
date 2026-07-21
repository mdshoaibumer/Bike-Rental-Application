import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/network/api_client.dart';
import 'package:shared/demo/mock_data.dart';
import '../../../core/providers.dart';

class Booking {
  final String id;
  final String bookingNumber;
  final String bikeId;
  final String pickupDate;
  final String returnDate;
  final int durationDays;
  final double price;
  final double deposit;
  final double taxes;
  final double finalAmount;
  final String bookingStatus;
  final String paymentStatus;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.bikeId,
    required this.pickupDate,
    required this.returnDate,
    required this.durationDays,
    required this.price,
    required this.deposit,
    required this.taxes,
    required this.finalAmount,
    required this.bookingStatus,
    required this.paymentStatus,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      bookingNumber: json['booking_number'] ?? '',
      bikeId: json['bike_id'] ?? '',
      pickupDate: json['pickup_date'] ?? '',
      returnDate: json['return_date'] ?? '',
      durationDays: json['duration_days'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      deposit: (json['deposit'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      finalAmount: (json['final_amount'] ?? 0).toDouble(),
      bookingStatus: json['booking_status'] ?? 'PENDING',
      paymentStatus: json['payment_status'] ?? 'PENDING',
    );
  }
}

class BookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  const BookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
  });

  BookingsState copyWith({List<Booking>? bookings, bool? isLoading, String? error}) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookingsNotifier extends StateNotifier<BookingsState> {
  final ApiClient _apiClient;
  Timer? _pollingTimer;

  BookingsNotifier(this._apiClient) : super(const BookingsState()) {
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!state.isLoading) loadBookings(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadBookings({bool isPolling = false}) async {
    // Load demo data immediately for instant display
    if (!isPolling && state.bookings.isEmpty) {
      final demoBookings = MockData.bookings.map((json) => Booking.fromJson(json)).toList();
      state = state.copyWith(bookings: demoBookings, isLoading: false);
    }

    // Try API in background
    try {
      final response = await _apiClient.dio.get('/bookings');
      final List<dynamic> data = response.data['data'] ?? [];
      List<Booking> bookings = data.map((json) => Booking.fromJson(json)).toList();
      
      if (bookings.isNotEmpty) {
        state = state.copyWith(bookings: bookings, isLoading: false);
      }
    } catch (e) {
      // API failed - demo data already loaded
      if (state.bookings.isEmpty) {
        final demoBookings = MockData.bookings.map((json) => Booking.fromJson(json)).toList();
        state = state.copyWith(bookings: demoBookings, isLoading: false);
      }
    }
  }

  Future<bool> createBooking(String bikeId, DateTime pickupDate, DateTime returnDate) async {
    try {
      await _apiClient.dio.post('/bookings', data: {
        'bike_id': bikeId,
        'pickup_date': pickupDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
      });
      await loadBookings();
      return true;
    } catch (e) {
      // Demo mode: simulate successful booking when API is unavailable
      final days = returnDate.difference(pickupDate).inDays;
      final bike = MockData.bikes.firstWhere(
        (b) => b['id'] == bikeId,
        orElse: () => MockData.bikes.first,
      );
      final price = (bike['rental_price'] as double) * days;
      final newBooking = Booking.fromJson({
        'id': 'demo_${DateTime.now().millisecondsSinceEpoch}',
        'booking_number': 'BRN${20000 + state.bookings.length}',
        'bike_id': bikeId,
        'pickup_date': pickupDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
        'duration_days': days,
        'price': price,
        'deposit': bike['security_deposit'],
        'taxes': price * 0.18,
        'final_amount': price + (price * 0.18),
        'booking_status': 'CONFIRMED',
        'payment_status': 'PAID',
      });
      state = state.copyWith(
        bookings: [newBooking, ...state.bookings],
        isLoading: false,
      );
      return true;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _apiClient.dio.delete('/bookings/$bookingId');
      await loadBookings();
      return true;
    } catch (e) {
      // Demo mode: remove booking locally
      final updated = state.bookings.where((b) => b.id != bookingId).toList();
      state = state.copyWith(bookings: updated);
      return true;
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, BookingsState>((ref) {
  return BookingsNotifier(ref.read(apiClientProvider));
});
