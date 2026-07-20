import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A premium search field with animation and advanced features
class PremiumSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool enableVoiceSearch;
  final VoidCallback? onVoiceSearch;
  final bool enableFilter;
  final VoidCallback? onFilterTap;
  final InputDecoration? decoration;

  final ValueChanged<String>? onSubmitted;
  
  const PremiumSearchField({
    Key? key,
    this.controller,
    this.hintText = 'Search bikes...',
    this.onChanged,
    this.onClear,
    this.enableVoiceSearch = true,
    this.onVoiceSearch,
    this.enableFilter = true,
    this.onFilterTap,
    this.decoration,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<PremiumSearchField> createState() => _PremiumSearchFieldState();
}

class _PremiumSearchFieldState extends State<PremiumSearchField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    setState(() => _isFocused = focused);
    if (focused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: _isFocused ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFocused ? AppTheme.elevatedShadow : AppTheme.cardShadow,
        ),
        padding: _isFocused ? const EdgeInsets.all(2) : EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: widget.onSubmitted,
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
            },
            decoration: widget.decoration ??
                InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.accentOrange,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _controller.clear();
                            widget.onClear?.call();
                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      if (widget.enableVoiceSearch)
                        GestureDetector(
                          onTap: widget.onVoiceSearch,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.mic_rounded,
                              color: AppTheme.accentOrange,
                              size: 20,
                            ),
                          ),
                        ),
                      if (widget.enableFilter)
                        GestureDetector(
                          onTap: widget.onFilterTap,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.tune_rounded,
                              color: AppTheme.accentOrange,
                              size: 20,
                            ),
                          ),
                        ),
                      if (!widget.enableFilter && !widget.enableVoiceSearch)
                        const SizedBox(width: 8),
                    ],
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
