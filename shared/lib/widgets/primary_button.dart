import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final bool isOutlined;
  final bool isSecondary;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
    this.isOutlined = false,
    this.isSecondary = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.isFullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: !widget.isOutlined
            ? AppTheme.cardShadow
            : [],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          onTapDown: (_) => _pressController.forward(),
          onTapCancel: () => _pressController.reverse(),
          borderRadius: BorderRadius.circular(16),
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 0.98).animate(
              CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: !widget.isOutlined
                    ? (widget.isSecondary
                        ? AppTheme.accentGradient
                        : AppTheme.primaryGradient)
                    : null,
                color: widget.isOutlined
                    ? Colors.transparent
                    : null,
                border: widget.isOutlined
                    ? Border.all(
                        color: widget.isSecondary
                            ? AppTheme.accentOrange
                            : AppTheme.primaryBlue,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            widget.leadingIcon!,
                            const SizedBox(width: 12),
                          ],
                          Text(
                            widget.text,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: widget.isOutlined
                                      ? (widget.isSecondary
                                          ? AppTheme.accentOrange
                                          : AppTheme.primaryBlue)
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          if (widget.trailingIcon != null) ...[
                            const SizedBox(width: 12),
                            widget.trailingIcon!,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
