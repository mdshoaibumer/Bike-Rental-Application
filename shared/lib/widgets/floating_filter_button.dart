import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium floating action button for filtering
class FloatingFilterButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;
  final bool animate;

  const FloatingFilterButton({
    Key? key,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
    this.animate = true,
  }) : super(key: key);

  @override
  State<FloatingFilterButton> createState() => _FloatingFilterButtonState();
}

class _FloatingFilterButtonState extends State<FloatingFilterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    if (widget.animate) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: widget.onTap,
        backgroundColor: AppTheme._primaryBlue,
        elevation: 8,
        child: Stack(
          children: [
            RotationTransition(
              turns: _rotateAnimation,
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            if (widget.showBadge && widget.badgeCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme._errorRed,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.cardShadow,
                  ),
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  child: Text(
                    widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
