# TIER 2 IMPROVEMENTS - IMPLEMENTATION GUIDE
## High Priority Enhancements (10 Items)

This document provides specific, actionable guidance for implementing Tier 2 improvements that will polish the app and prepare it for soft launch.

---

## 1. BOTTOM SHEET KEYBOARD HANDLING

**Current Problem:**
When booking a bike on detail screen, the bottom sheet with price and booking button doesn't reposition when keyboard appears, causing button to be hidden.

**Solution:**
```dart
// In bike_detail_screen.dart, modify bottomSheet widget:

bottomSheet: bikeAsync.hasValue && bikeAsync.value != null
    ? AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: MediaQuery.of(context).viewInsets, // THIS FIXES IT
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [/* existing shadow */],
        ),
        child: SafeArea(
          child: Row(
            children: [/* existing content */],
          ),
        ),
      )
    : null,
```

**Why This Works:**
- `MediaQuery.of(context).viewInsets` provides the keyboard height
- `AnimatedContainer` smoothly animates the adjustment
- `SafeArea` ensures content stays within bounds

**Impact:** 
- ✅ Button always visible during booking
- ✅ Smooth animation (not jarring)
- ✅ Professional feel

**Estimated Time:** 5 minutes
**Complexity:** Low

---

## 2. DATE PICKER CALENDAR VISUALIZATION

**Current Problem:**
Standard Material date picker is awkward for bike rental (need to select range, see booked dates, understand pricing).

**Implementation:**
```dart
// Create new file: lib/features/bikes/presentation/widgets/booking_calendar_picker.dart

class BookingCalendarPicker extends StatefulWidget {
  final DateTime selectedStart;
  final DateTime selectedEnd;
  final List<DateTime> bookedDates;
  final double pricePerDay;
  final Function(DateTimeRange) onDateRangeSelected;

  @override
  _BookingCalendarPickerState createState() => _BookingCalendarPickerState();
}

class _BookingCalendarPickerState extends State<BookingCalendarPicker> {
  late DateTime _focusedDay;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedRange = DateTimeRange(
      start: widget.selectedStart,
      end: widget.selectedEnd,
    );
  }

  bool _isDateBooked(DateTime date) {
    return widget.bookedDates.any((bookedDate) =>
      bookedDate.year == date.year &&
      bookedDate.month == date.month &&
      bookedDate.day == date.day
    );
  }

  bool _isDateInRange(DateTime date) {
    if (_selectedRange == null) return false;
    return date.isAfter(_selectedRange!.start) && 
           date.isBefore(_selectedRange!.end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Grid using table_calendar package
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(Duration(days: 90)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => _isDateInRange(day),
          rangeStartDay: _selectedRange?.start,
          rangeEndDay: _selectedRange?.end,
          rangeSelectionMode: RangeSelectionMode.toggledOn,
          onRangeSelected: (start, end, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              _selectedRange = DateTimeRange(start: start!, end: end!);
              widget.onDateRangeSelected(_selectedRange!);
            });
          },
          calendarBuilders: CalendarBuilders(
            // Red out booked dates
            disabledBuilder: (context, day, focusedDay) {
              if (_isDateBooked(day)) {
                return Container(
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${day.day}'),
                  ),
                );
              }
              return null;
            },
            // Highlight selected range in blue
            rangeHighlightBuilder: (context, day, isWithinRange) {
              if (isWithinRange) {
                return Container(
                  color: Colors.blue.withAlpha(50),
                  margin: EdgeInsets.all(2),
                );
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 16),
        // Price Breakdown
        if (_selectedRange != null)
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rental Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 12),
                _buildPriceLine('Duration', '${_selectedRange!.duration.inDays} days'),
                _buildPriceLine('Rate per day', '₹${widget.pricePerDay.toInt()}'),
                Divider(height: 16),
                _buildPriceLine(
                  'Total',
                  '₹${(widget.pricePerDay * _selectedRange!.duration.inDays).toInt()}',
                  isBold: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPriceLine(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
```

**Add Dependency:**
```yaml
# pubspec.yaml
dependencies:
  table_calendar: ^3.0.0
```

**Usage in bike_detail_screen.dart:**
```dart
// Replace the InkWell date picker with:
BookingCalendarPicker(
  selectedStart: _selectedDates?.start ?? DateTime.now(),
  selectedEnd: _selectedDates?.end ?? DateTime.now().add(Duration(days: 1)),
  bookedDates: [], // TODO: fetch from bike provider
  pricePerDay: bike.rentalPrice,
  onDateRangeSelected: (range) {
    setState(() => _selectedDates = range);
  },
)
```

**Impact:**
- ✅ Shows which dates are unavailable (booked)
- ✅ Easy range selection (tap start, tap end)
- ✅ Inline price calculation
- ✅ Prevents overbooking

**Estimated Time:** 40 minutes
**Complexity:** Medium

---

## 3. PRICE BREAKDOWN

**Current Problem:**
Booking shows only total price. Users don't understand what they're paying for.

**Solution:**
```dart
// Create new file: lib/features/bikes/presentation/widgets/price_breakdown_card.dart

class PriceBreakdownCard extends StatelessWidget {
  final double rentalPrice;
  final int durationDays;
  final double? discountPercent;
  final double? insurancePrice;
  final double taxRate; // typically 0.18 for 18% GST

  PriceBreakdownCard({
    required this.rentalPrice,
    required this.durationDays,
    this.discountPercent = 0.0,
    this.insurancePrice,
    this.taxRate = 0.18,
  });

  @override
  Widget build(BuildContext context) {
    final baseAmount = rentalPrice * durationDays;
    final discountAmount = baseAmount * (discountPercent ?? 0.0) / 100;
    final subtotal = baseAmount - discountAmount;
    final tax = subtotal * taxRate;
    final insurance = insurancePrice ?? 0.0;
    final total = subtotal + tax + insurance;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildBreakdownRow(
            context,
            label: 'Daily Rate',
            amount: rentalPrice,
            detail: '$durationDays days × ₹${rentalPrice.toInt()}',
          ),
          SizedBox(height: 8),
          if (discountPercent != null && discountPercent! > 0)
            _buildBreakdownRow(
              context,
              label: 'Discount',
              amount: -discountAmount,
              detail: '${discountPercent?.toInt()}% off',
              isDiscount: true,
            ),
          if (discountPercent != null && discountPercent! > 0)
            SizedBox(height: 8),
          _buildBreakdownRow(
            context,
            label: 'Subtotal',
            amount: subtotal,
          ),
          SizedBox(height: 8),
          _buildBreakdownRow(
            context,
            label: 'GST (18%)',
            amount: tax,
            detail: 'Taxes',
          ),
          if (insurance != null && insurance > 0) ...[
            SizedBox(height: 8),
            _buildBreakdownRow(
              context,
              label: 'Premium Insurance',
              amount: insurance,
            ),
          ],
          Divider(height: 20),
          _buildBreakdownRow(
            context,
            label: 'Total Amount',
            amount: total,
            isBold: true,
            isFinal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required String label,
    required double amount,
    String? detail,
    bool isBold = false,
    bool isFinal = false,
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: isDiscount ? Colors.green : null,
                ),
              ),
              if (detail != null)
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: isFinal
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
          child: Text(
            '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount 
                ? Colors.green 
                : (isFinal ? Theme.of(context).colorScheme.primary : null),
            ),
          ),
        ),
      ],
    );
  }
}
```

**Usage in bike_detail_screen.dart:**
```dart
// Add this inside the booking summary section:
PriceBreakdownCard(
  rentalPrice: bike.rentalPrice,
  durationDays: _selectedDates?.duration.inDays ?? 1,
  discountPercent: 0.0, // TODO: fetch discount if available
  insurancePrice: null, // TODO: add insurance option
)
```

**Impact:**
- ✅ Transparency builds trust
- ✅ Users understand all charges
- ✅ Reduces "surprise charges" complaints
- ✅ Shows discount value clearly

**Estimated Time:** 25 minutes
**Complexity:** Low

---

## 4. PERSONALIZED GREETINGS

**Current Problem:**
"Good Morning, Explorer!" is generic and doesn't actually personalize based on time or user.

**Solution:**
```dart
// Create new file: lib/features/home/presentation/widgets/personalized_greeting.dart

class PersonalizedGreeting extends StatelessWidget {
  final String userName;
  final int? totalRides;

  const PersonalizedGreeting({
    required this.userName,
    this.totalRides,
  });

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Late Night Rider';
    }
  }

  String _getMotivationalPhrase() {
    const phrases = [
      'Find your perfect ride today',
      'Ready for your next adventure?',
      'Let\'s hit the road',
      'Explore the city on two wheels',
      'Your next journey awaits',
      'Freedom starts here',
      'Where will you ride today?',
    ];
    
    return phrases[DateTime.now().day % phrases.length];
  }

  @override
  Widget build(BuildContext context) {
    final firstName = userName.split(' ').first;
    final greeting = _getTimeBasedGreeting();
    final phrase = _getMotivationalPhrase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,\n$firstName!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          phrase,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
          ),
        ),
        if (totalRides != null && totalRides! > 0) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You\'ve completed $totalRides rides! 🎉',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

**Usage in home_screen.dart:**
```dart
// Replace the static "Good Morning, Explorer!" with:
PersonalizedGreeting(
  userName: authState.user?['name'] ?? 'Rider',
  totalRides: bikesState.userStats?.totalRides,
)
```

**Impact:**
- ✅ Feels more personal
- ✅ Time-based relevance
- ✅ Gamification (shows ride count)
- ✅ Better user engagement

**Estimated Time:** 15 minutes
**Complexity:** Low

---

## 5. HOME SCREEN HERO BANNER

**Current Problem:**
Home screen goes straight to search → categories → bike list. No featured content or promotions.

**Solution:**
```dart
// Create new file: lib/features/home/presentation/widgets/promotional_banner.dart

class PromotionalBanner extends StatefulWidget {
  final List<BannerData> banners;
  final VoidCallback onBannerTap;

  const PromotionalBanner({
    required this.banners,
    required this.onBannerTap,
  });

  @override
  _PromotionalBannerState createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Auto-rotate banners every 5 seconds
    Future.delayed(Duration(seconds: 5), _nextPage);
  }

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index % widget.banners.length);
          Future.delayed(Duration(seconds: 5), _nextPage);
        },
        itemBuilder: (context, index) {
          final banner = widget.banners[index % widget.banners.length];
          return _buildBannerCard(context, banner);
        },
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerData banner) {
    return GestureDetector(
      onTap: widget.onBannerTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [banner.color1, banner.color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: banner.color1.withAlpha(100),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                banner.icon,
                size: 140,
                color: Colors.white.withAlpha(30),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        banner.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  // CTA
                  if (banner.ctaText != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        banner.ctaText!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class BannerData {
  final String title;
  final String subtitle;
  final Color color1;
  final Color color2;
  final IconData icon;
  final String? ctaText;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.icon,
    this.ctaText,
  });
}
```

**Usage in home_screen.dart:**
```dart
// Add after SliverAppBar:
SliverToBoxAdapter(
  child: Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: PromotionalBanner(
      banners: [
        BannerData(
          title: 'Summer Special',
          subtitle: '20% off on all bikes',
          color1: Colors.orange,
          color2: Colors.deepOrange,
          icon: Icons.local_offer_rounded,
          ctaText: 'Explore',
        ),
        BannerData(
          title: 'Referral Bonus',
          subtitle: 'Earn ₹500 per friend',
          color1: Colors.purple,
          color2: Colors.pink,
          icon: Icons.people_rounded,
          ctaText: 'Share Now',
        ),
      ],
      onBannerTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promo activated!')),
        );
      },
    ),
  ),
)
```

**Impact:**
- ✅ Revenue opportunity (sponsored promotions)
- ✅ User engagement (rotating offers)
- ✅ Conversion boost (seasonal campaigns)
- ✅ Professional feel

**Estimated Time:** 30 minutes
**Complexity:** Medium

---

## 6. SEARCH FUNCTIONALITY ENHANCEMENT

**Current Problem:**
Search field is present but doesn't have real-time search, history, or trending features.

**Solution:**
```dart
// Modify lib/features/home/presentation/widgets/premium_search_field.dart

class EnhancedSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onFilterTap;
  final List<String> recentSearches;
  final List<String> trendingSearches;

  const EnhancedSearchField({
    required this.controller,
    required this.onSearch,
    required this.onFilterTap,
    this.recentSearches = const [],
    this.trendingSearches = const ['Electric Bikes', 'Mountain Bikes', 'Sports Bikes'],
  });

  @override
  _EnhancedSearchFieldState createState() => _EnhancedSearchFieldState();
}

class _EnhancedSearchFieldState extends State<EnhancedSearchField> {
  bool _showSuggestions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: (value) {
              setState(() => _showSuggestions = value.isNotEmpty);
              if (value.isNotEmpty) {
                widget.onSearch(value);
              }
            },
            onTap: () => setState(() => _showSuggestions = true),
            decoration: InputDecoration(
              hintText: 'Search bikes or brands...',
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() => _showSuggestions = false);
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        // Suggestions dropdown
        if (_showSuggestions && widget.controller.text.isEmpty)
          _buildSuggestionsDropdown(),
      ],
    );
  }

  Widget _buildSuggestionsDropdown() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.recentSearches.isNotEmpty)
            _buildSection('Recent', widget.recentSearches),
          if (widget.recentSearches.isNotEmpty &&
              widget.trendingSearches.isNotEmpty)
            Divider(height: 1),
          _buildSection('Trending', widget.trendingSearches),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items.map((item) => ListTile(
          dense: true,
          leading: Icon(
            title == 'Recent' ? Icons.history_rounded : Icons.trending_up_rounded,
            size: 18,
          ),
          title: Text(item, style: Theme.of(context).textTheme.bodySmall),
          onTap: () {
            widget.controller.text = item;
            setState(() => _showSuggestions = false);
            widget.onSearch(item);
          },
        )),
      ],
    );
  }
}
```

**Impact:**
- ✅ Faster search discovery
- ✅ Shows trending bikes
- ✅ Reduced typing
- ✅ Better conversion

**Estimated Time:** 25 minutes
**Complexity:** Low

---

## 7. STATUS BADGE STANDARDIZATION

**Current Problem:**
Status badges appear differently across Booking History, Home (bike cards), and Detail screens.

**Solution:**
```dart
// Create new file: lib/shared/widgets/status_badge.dart

class StatusBadge extends StatelessWidget {
  final String status;
  final StatusType type; // booking, bike, kyc
  final Size size; // small, medium, large

  const StatusBadge({
    required this.status,
    required this.type,
    this.size = Size.medium,
  });

  Color get _color {
    final upperStatus = status.toUpperCase();
    
    // Booking statuses
    if (type == StatusType.booking) {
      switch (upperStatus) {
        case 'CONFIRMED': return Colors.green;
        case 'ACTIVE': return Colors.blue;
        case 'COMPLETED': return Colors.grey;
        case 'CANCELLED': return Colors.red;
        case 'PENDING': return Colors.orange;
        default: return Colors.grey;
      }
    }
    
    // Bike availability statuses
    if (type == StatusType.bike) {
      switch (upperStatus) {
        case 'AVAILABLE': return Colors.teal;
        case 'RENTED': return Colors.orange;
        case 'MAINTENANCE': return Colors.red;
        case 'UNAVAILABLE': return Colors.grey;
        default: return Colors.grey;
      }
    }
    
    // KYC statuses
    if (type == StatusType.kyc) {
      switch (upperStatus) {
        case 'APPROVED': return Colors.green;
        case 'PENDING': return Colors.orange;
        case 'REJECTED': return Colors.red;
        default: return Colors.grey;
      }
    }
    
    return Colors.grey;
  }

  IconData get _icon {
    final upperStatus = status.toUpperCase();
    
    if (upperStatus == 'CONFIRMED' || upperStatus == 'APPROVED' || upperStatus == 'AVAILABLE') {
      return Icons.check_circle;
    } else if (upperStatus == 'PENDING' || upperStatus == 'MAINTENANCE') {
      return Icons.schedule;
    } else if (upperStatus == 'REJECTED' || upperStatus == 'CANCELLED' || upperStatus == 'UNAVAILABLE') {
      return Icons.cancel;
    } else if (upperStatus == 'ACTIVE' || upperStatus == 'RENTED') {
      return Icons.timer;
    }
    
    return Icons.info;
  }

  double get _fontSize {
    switch (size) {
      case Size.small:
        return 10;
      case Size.medium:
        return 12;
      case Size.large:
        return 14;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: _color.withAlpha(25),
        border: Border.all(color: _color.withAlpha(100)),
        borderRadius: BorderRadius.circular(size == Size.large ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _color, size: _fontSize),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case Size.small:
        return EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case Size.medium:
        return EdgeInsets.symmetric(horizontal: 10, vertical: 6);
      case Size.large:
        return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }
}

enum StatusType { booking, bike, kyc }
enum Size { small, medium, large }
```

**Usage:**
```dart
// Instead of various status implementations:
StatusBadge(
  status: booking.bookingStatus,
  type: StatusType.booking,
  size: Size.medium,
)
```

**Impact:**
- ✅ Visual consistency across app
- ✅ Easier maintenance
- ✅ Professional feel
- ✅ Accessibility improvements

**Estimated Time:** 20 minutes
**Complexity:** Low

---

## 8-10: QUICK WINS

**8. Loading State Skeletons** (10 mins)
- Ensure skeleton loader height = final card height
- Verify aspect ratios match (0.75 not 0.85)

**9. Empty State Personalization** (15 mins)
- "No bookings yet" → "You haven't rented any bikes yet. Explore our fleet and book your first ride!"
- Show relevant CTAs

**10. Dark Mode Consistency** (20 mins)
- Audit all text colors
- Ensure 4.5:1 contrast ratio minimum
- Test gradients in both light/dark

---

## TIER 2 SUMMARY

| Item | Time | Complexity | Impact |
|------|------|-----------|--------|
| 1. Bottom Sheet Keyboard | 5 min | Low | High |
| 2. Calendar Picker | 40 min | Medium | High |
| 3. Price Breakdown | 25 min | Low | High |
| 4. Personalized Greetings | 15 min | Low | Medium |
| 5. Hero Banner | 30 min | Medium | Medium |
| 6. Search Enhancement | 25 min | Low | Medium |
| 7. Status Badges | 20 min | Low | Medium |
| 8-10. Quick Wins | 45 min | Low | Medium |
| **TOTAL** | **205 min** | | **Very High** |

**Timeline:** 3-4 hours implementation + 1-2 hours testing = 1-2 day sprint

