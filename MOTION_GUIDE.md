# Premium Motion & Micro-interactions Guide

## Motion Philosophy
Animations enhance user experience through natural, purposeful motion that:
- Provides feedback for user interactions
- Clarifies relationships between UI elements
- Maintains visual continuity
- Targets 60 FPS performance on all devices

## Animation Timing Curves

### Standard Transitions (200-300ms)
```dart
CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)
// Used for: button presses, card selections, menu opens
```

### Hero Animations (400-600ms)
```dart
CurvedAnimation(parent: controller, curve: Curves.easeOutBack)
// Used for: logo reveals, page transitions, important elements
```

### Emphasis Animations (500-800ms)
```dart
CurvedAnimation(parent: controller, curve: Curves.elasticOut)
// Used for: favorites toggle, success celebrations, achievements
```

### Smooth Scrolling (250-350ms)
```dart
CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic)
// Used for: scroll-triggered animations, parallax effects
```

## Micro-interaction Patterns

### 1. Button Press Response
- Scale: 1.0 → 0.98 (press down)
- Duration: 200ms
- Curve: Curves.easeOut
- Feedback: Light haptic (HapticFeedback.lightImpact)

### 2. Card Hover/Lift Effect
- Elevation: 0 → 8dp
- Scale: 1.0 → 1.02
- Duration: 300ms
- Curve: Curves.easeOutQuad

### 3. Favorite Toggle
- Scale: 1.0 → 1.3 → 1.0
- Rotation: 0 → 360°
- Duration: 600ms
- Curve: Curves.elasticOut

### 4. Success State
- Confetti particles fall
- Success badge emerges with scale animation
- Background dims slightly
- Auto-dismiss after 2 seconds

### 5. Loading State
- Rotating progress indicator
- Optional shimmer effect on skeleton loaders
- Percentage counter animates from 0-100

## Implementation Examples

### Premium Button Animation
```dart
ScaleTransition(
  scale: Tween<double>(begin: 1.0, end: 0.98).animate(
    CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
  ),
  child: InkWell(
    onTapDown: (_) {
      _pressController.forward();
      HapticFeedback.lightImpact();
    },
    onTapCancel: () => _pressController.reverse(),
    child: // button content
  ),
)
```

### Card Lift Animation
```dart
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(0, -8 * _animation.value),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 8 + (12 * _animation.value),
              color: Colors.black.withValues(alpha: 0.1 + (0.1 * _animation.value)),
            ),
          ],
        ),
        child: child,
      ),
    );
  },
  child: // card content
)
```

### Page Transition
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(1.0, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  )),
  child: FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(_controller),
    child: // page content
  ),
)
```

## Performance Guidelines

### Do's
- Use AnimatedBuilder for performance
- Keep animations under 300ms for standard interactions
- Use SingleTickerProviderStateMixin for single animations
- Dispose controllers properly in dispose()
- Test on low-end devices

### Don'ts
- Avoid nested animations exceeding 800ms
- Don't animate high-frequency properties (like scroll position)
- Avoid multiple AnimationControllers without purpose
- Don't use opacity animations for every transition
- Never skip disposing controllers

## Accessibility Considerations

```dart
// Respect user's motion preferences
bool reduceMotion = MediaQuery.of(context).disableAnimations;

Duration animationDuration = reduceMotion 
    ? const Duration(milliseconds: 100)
    : const Duration(milliseconds: 300);
```

## Testing Animations

```dart
// In tests, control animation manually
testWidgets('button animation', (tester) async {
  // Disable animations for testing
  addTearDown(tester.binding.window.physicsTestBindings.postFrameCallbacksFlushDuration = Duration.zero);
  
  // Verify animation targets
  expect(find.byType(ScaleTransition), findsOneWidget);
});
```

## Common Animation Patterns

| Action | Duration | Curve | Feedback |
|--------|----------|-------|----------|
| Button Press | 200ms | easeOut | Scale 0.98 + Haptic |
| Menu Open | 300ms | easeOutBack | Slide + Fade |
| Page Transition | 400ms | easeOutCubic | Slide + Fade |
| Favorite Toggle | 600ms | elasticOut | Scale + Rotation |
| Success State | 1200ms | elasticOut | Confetti + Scale |
| Loading Spinner | 1500ms | linear | Continuous Rotation |

---

**Remember**: Animation is not decoration. Every motion should serve a purpose and enhance user understanding of the app's structure and functionality.
