import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PremiumNavItem> items;
  final Color? backgroundColor;
  final double elevation;
  final bool showLabels;

  const PremiumNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.elevation = 8,
    this.showLabels = true,
  }) : assert(items.length >= 2 && items.length <= 5);

  @override
  State<PremiumNavigationBar> createState() => _PremiumNavigationBarState();
}

class _PremiumNavigationBarState extends State<PremiumNavigationBar>
    with SingleTickerProviderStateMixin {
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    _animationControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(PremiumNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationControllers[oldWidget.currentIndex].reverse();
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            (isDark ? const Color(0xFF1E1E1E) : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: widget.elevation,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(context, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index) {
    final item = widget.items[index];
    final isSelected = widget.currentIndex == index;
    final animation = _animationControllers[index];

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onTap(index);
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(12),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppTheme.primaryBlue.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryBlue.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      size: 24,
                    ),
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 4),
                    FadeTransition(
                      opacity: animation,
                      child: Text(
                        item.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumNavItem {
  final IconData icon;
  final String label;
  final String route;

  const PremiumNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
