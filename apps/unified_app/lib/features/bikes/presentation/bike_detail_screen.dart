import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/widgets/primary_button.dart';
import 'package:shared/widgets/shimmer_loader.dart';
import 'package:shared/widgets/empty_state_widget.dart';
import '../providers/bike_provider.dart';
import '../../booking/providers/booking_provider.dart';

class BikeDetailScreen extends ConsumerStatefulWidget {
  final String bikeId;
  const BikeDetailScreen({super.key, required this.bikeId});

  @override
  ConsumerState<BikeDetailScreen> createState() => _BikeDetailScreenState();
}

class _BikeDetailScreenState extends ConsumerState<BikeDetailScreen> {
  DateTimeRange? _selectedDates;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final bikeAsync = ref.watch(bikeDetailProvider(widget.bikeId));

    return Scaffold(
      body: bikeAsync.when(
        loading: () => const Center(child: ShimmerLoader(width: double.infinity, height: 300)),
        error: (err, _) => Center(
          child: EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Failed to load',
            message: err.toString(),
            actionLabel: 'Go Back',
            onAction: () => context.pop(),
          ),
        ),
        data: (bike) {
          if (bike == null) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Not Found',
                message: 'This bike is no longer available.',
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'bike_img_${bike.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        bike.imageUrl != null
                            ? Image.network(bike.imageUrl!, fit: BoxFit.cover)
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceVariant,
                                child: const Icon(Icons.motorcycle, size: 100, color: Colors.grey),
                              ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Material(
                    shape: const CircleBorder(),
                    color: Colors.black.withOpacity(0.6),
                    child: InkWell(
                      onTap: () => context.pop(),
                      customBorder: const CircleBorder(),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bike.bikeName,
                                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bike.brand,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '₹${bike.rentalPrice.toStringAsFixed(0)}/day',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Specifications',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _specCard(Icons.speed_rounded, 'Engine', '${bike.engineCC > 0 ? bike.engineCC : "-"} CC')),
                          const SizedBox(width: 16),
                          Expanded(child: _specCard(Icons.local_gas_station_rounded, 'Fuel', bike.fuelType)),
                        ],
                      ),
                      if (bike.registrationNumber != null) ...[
                        const SizedBox(height: 16),
                        _specCard(Icons.assignment_rounded, 'Registration', bike.registrationNumber!),
                      ],
                      const SizedBox(height: 36),
                      Text(
                        'Rental Period',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final range = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                      primary: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              child: child!,
                            ),
                          );
                          if (range != null) {
                            setState(() => _selectedDates = range);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedDates != null 
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                : Colors.grey[300]!,
                              width: _selectedDates != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: _selectedDates != null
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                              : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.calendar_month_rounded, 
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dates',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      _selectedDates != null
                                          ? '${_formatDate(_selectedDates!.start)} - ${_formatDate(_selectedDates!.end)}'
                                          : 'Select pickup & return dates',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedDates != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_selectedDates!.duration.inDays}d',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 120), // padding for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: bikeAsync.hasValue && bikeAsync.value != null
          ? Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, -8)
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDates != null
                                ? '₹${(bikeAsync.value!.rentalPrice * _selectedDates!.duration.inDays).toStringAsFixed(0)}'
                                : '₹0',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: _isBooking ? 'Processing...' : 'Book Now',
                        isLoading: _isBooking,
                        onPressed: _selectedDates == null || _isBooking
                            ? null
                            : () => _handleBook(bikeAsync.value!.id),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _specCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}';

  Future<void> _handleBook(String bikeId) async {
    if (_selectedDates == null) return;
    
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildBookingConfirmationDialog(ctx, bikeId),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isBooking = true);
    try {
      await ref.read(bookingsProvider.notifier).createBooking(
        bikeId,
        _selectedDates!.start,
        _selectedDates!.end,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  Widget _buildBookingConfirmationDialog(BuildContext ctx, String bikeId) {
    final bike = ref.read(bikeDetailProvider(bikeId)).maybeWhen(
      data: (bike) => bike,
      orElse: () => null,
    );
    
    if (bike == null || _selectedDates == null) {
      return const SizedBox.shrink();
    }

    final totalPrice = bike.rentalPrice * _selectedDates!.duration.inDays;
    final taxAmount = totalPrice * 0.18; // 18% GST
    final finalAmount = totalPrice + taxAmount;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Your Booking',
                    style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bike.bikeName,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rental Period
                  _buildConfirmationRow(
                    ctx,
                    icon: Icons.calendar_month_rounded,
                    label: 'Rental Period',
                    value: '${_formatDate(_selectedDates!.start)} - ${_formatDate(_selectedDates!.end)}',
                  ),
                  const SizedBox(height: 16),
                  _buildConfirmationRow(
                    ctx,
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: '${_selectedDates!.duration.inDays} Days',
                  ),
                  const Divider(height: 32),
                  // Price Breakdown
                  _buildConfirmationRow(
                    ctx,
                    label: 'Rental (${_selectedDates!.duration.inDays}d × ₹${bike.rentalPrice.toInt()})',
                    value: '₹${totalPrice.toStringAsFixed(0)}',
                    isLabel: true,
                  ),
                  const SizedBox(height: 8),
                  _buildConfirmationRow(
                    ctx,
                    label: 'GST (18%)',
                    value: '₹${taxAmount.toStringAsFixed(0)}',
                    isLabel: true,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildConfirmationRow(
                      ctx,
                      label: 'Total Amount',
                      value: '₹${finalAmount.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Policy & Terms
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Cancellation Policy',
                              style: Theme.of(ctx).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Free cancellation within 48 hours\n• After 48h: 25% penalty\n• No refund within 24 hours of pickup',
                          style: Theme.of(ctx).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Checkbox Acceptance
                  StatefulBuilder(
                    builder: (ctx, setState) {
                      bool _accepted = false;
                      return Column(
                        children: [
                          CheckboxListTile(
                            value: _accepted,
                            onChanged: (value) {
                              setState(() => _accepted = value ?? false);
                            },
                            title: Text(
                              'I accept the cancellation policy and terms',
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(ctx).colorScheme.primary,
                                    disabledBackgroundColor: Colors.grey[400],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _accepted ? () => Navigator.pop(ctx, true) : null,
                                  child: const Text(
                                    'Confirm Booking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(
    BuildContext ctx, {
    IconData? icon,
    required String label,
    required String value,
    bool isLabel = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Theme.of(ctx).colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontWeight: isBold ? FontWeight.bold : (isLabel ? FontWeight.normal : FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Theme.of(ctx).colorScheme.primary : null,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
