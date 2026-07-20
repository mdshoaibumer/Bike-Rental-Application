import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium price breakdown widget displaying itemized charges
class PriceBreakdown extends StatefulWidget {
  final List<PriceItem> items;
  final String? discountCode;
  final double discountAmount;
  final String currencySymbol;
  final bool expandable;

  const PriceBreakdown({
    Key? key,
    required this.items,
    this.discountCode,
    this.discountAmount = 0,
    this.currencySymbol = '\$',
    this.expandable = true,
  }) : super(key: key);

  @override
  State<PriceBreakdown> createState() => _PriceBreakdownState();
}

class _PriceBreakdownState extends State<PriceBreakdown>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return widget.items.fold(0, (sum, item) => sum + item.amount);
  }

  double get _total {
    return _subtotal - widget.discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.expandable
              ? () {
                  setState(() => _expanded = !_expanded);
                  if (_expanded) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${widget.items.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${widget.currencySymbol}${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.expandable)
                      RotationTransition(
                        turns: Tween<double>(begin: 0, end: 0.5)
                            .animate(_animationController),
                        child: const Icon(Icons.expand_more_rounded),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_expanded && widget.expandable)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                ...widget.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${widget.currencySymbol}${item.amount.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (widget.discountAmount > 0) ...[
                  const Divider(height: 16),
                  if (widget.discountCode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Discount',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.successGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  widget.discountCode ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppTheme.successGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '-${widget.currencySymbol}${widget.discountAmount.toStringAsFixed(2)}',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.currencySymbol}${_total.toStringAsFixed(2)}',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class PriceItem {
  final String label;
  final double amount;
  final String? description;

  PriceItem({
    required this.label,
    required this.amount,
    this.description,
  });
}
