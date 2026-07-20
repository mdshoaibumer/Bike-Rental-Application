import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium success animation with checkmark and confetti-like effect
class SuccessAnimation extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final bool showConfetti;
  final String? message;
  final String? subtitle;

  const SuccessAnimation({
    Key? key,
    this.duration = const Duration(milliseconds: 1200),
    this.onComplete,
    this.showConfetti = true,
    this.message,
    this.subtitle,
  }) : super(key: key);

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with TickerProviderStateMixin {
  late AnimationController _checkmarkController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late List<AnimationController> _confettiControllers;

  @override
  void initState() {
    super.initState();
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _confettiControllers = List.generate(
      widget.showConfetti ? 6 : 0,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 1200),
        vsync: this,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _checkmarkController.forward();
    _scaleController.forward();
    _fadeController.forward();

    for (var controller in _confettiControllers) {
      controller.forward();
    }

    Future.delayed(widget.duration, () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _checkmarkController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    for (var controller in _confettiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          if (widget.showConfetti)
            ..._buildConfettiParticles(),
          // Main success circle with checkmark
          ScaleTransition(
            scale: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.successGreen.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CheckmarkPainter(
                  progress: _checkmarkController,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ),
          // Message and subtitle
          if (widget.message != null || widget.subtitle != null)
            Positioned(
              bottom: -100,
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _fadeController,
                    curve: const Interval(0.5, 1.0),
                  ),
                ),
                child: Column(
                  children: [
                    if (widget.message != null)
                      Text(
                        widget.message!,
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (widget.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          widget.subtitle!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildConfettiParticles() {
    const colors = [
      AppTheme.primaryBlue,
      AppTheme.accentOrange,
      AppTheme.successGreen,
      AppTheme.warningAmber,
      AppTheme.errorRed,
    ];

    return List.generate(
      _confettiControllers.length,
      (index) {
        final angle = (360 / _confettiControllers.length) * index;
        final radians = angle * 3.14159 / 180;
        final distance = 150.0;
        final endX = distance * (radians % 1 == 0 ? 1 : 0);
        final endY = distance * (radians % 1 == 0 ? 1 : 0);

        return Positioned(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(
              CurvedAnimation(
                parent: _confettiControllers[index],
                curve: const Interval(0.6, 1.0),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(endX / 150, endY / 150),
              ).animate(
                CurvedAnimation(
                  parent: _confettiControllers[index],
                  curve: Curves.easeOut,
                ),
              ),
              child: RotationTransition(
                turns: _confettiControllers[index],
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors[index % colors.length],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final Animation<double> progress;
  final Color strokeColor;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.strokeColor,
    this.strokeWidth = 4.0,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final pathProgress = progress.value;

    if (pathProgress < 0.5) {
      // First part of checkmark (bottom-left to middle)
      final localProgress = pathProgress / 0.5;
      path.moveTo(centerX - 18, centerY + 5);
      path.lineTo(
        centerX - 18 + (18 * localProgress),
        centerY + 5 - (25 * localProgress),
      );
    } else {
      // Full first part
      path.moveTo(centerX - 18, centerY + 5);
      path.lineTo(centerX, centerY - 20);

      // Second part of checkmark (middle to top-right)
      final localProgress = (pathProgress - 0.5) / 0.5;
      path.lineTo(
        centerX + (24 * localProgress),
        centerY - 20 - (20 * localProgress),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) => true;
}
