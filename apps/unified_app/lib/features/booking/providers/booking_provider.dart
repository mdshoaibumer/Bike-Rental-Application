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
    if (!isPolling) state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/bookings');
      final List<dynamic> data = response.data['data'] ?? [];
      List<Booking> bookings = data.map((json) => Booking.fromJson(json)).toList();
      
      if (bookings.isEmpty) {
        // Fallback to rich demo data
        bookings = MockData.bookings.map((json) => Booking.fromJson(json)).toList();
      }
      
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      // Fallback to rich demo data
      final bookings = MockData.bookings.map((json) => Booking.fromJson(json)).toList();
      state = state.copyWith(bookings: bookings, isLoading: false, error: isPolling ? null : 'Using offline demo data');
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
      state = state.copyWith(error: 'Failed to create booking');
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _apiClient.dio.delete('/bookings/$bookingId');
      await loadBookings();
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to cancel booking');
      return false;
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, BookingsState>((ref) {
  return BookingsNotifier(ref.read(apiClientProvider));
});
