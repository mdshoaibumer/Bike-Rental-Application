# Performance Optimization Guide

## Flutter App Optimization

### 1. Build Performance
- **Release builds**: Always test with `flutter build apk --release` for production
- **Code splitting**: Enable code splitting for faster initial load
- **Tree shaking**: Automatic removal of unused code in release builds

### 2. Runtime Performance

#### Memory Management
```dart
// Good: Dispose resources
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// Avoid: Memory leaks from unclosed resources
```

#### Image Optimization
- Use `Image.asset()` with `cacheHeight` and `cacheWidth`
- Compress images to appropriate resolutions
- Use `.png` for transparency, `.jpg` for photos

#### State Management
- Use Riverpod's caching for data fetching
- Implement proper state invalidation
- Use `select()` for precise rebuilds

### 3. UI Performance

#### Widget Optimization
```dart
// Good: Separate immutable parts
class OptimizedList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ItemTile(key: ValueKey(index)),
    );
  }
}

// Avoid: Rebuilding entire lists
class IneffectiveList extends StatefulWidget { }
```

#### Rendering
- Use `const` constructors where possible
- Implement `shouldRebuild` in custom painters
- Avoid expensive widgets in build methods

### 4. Network Optimization

#### API Calls
```dart
// Implement caching
final bikesProvider = FutureProvider((ref) async {
  return ref.watch(apiClientProvider).getBikes();
});

// Use request debouncing
final searchProvider = FutureProvider.family((ref, query) async {
  return Future.delayed(const Duration(milliseconds: 300))
    .then((_) => ref.watch(apiClientProvider).search(query));
});
```

#### Data Synchronization
- Batch API requests
- Implement request queuing
- Use pagination for large datasets

### 5. Build Size Optimization

#### APK Size Reduction
- Remove debug symbols: `--release` flag
- Enable ProGuard/R8 obfuscation
- Split APKs by architecture

#### Code Optimization
- Remove unused dependencies
- Use dynamic feature modules
- Lazy load features

### 6. Animations & Transitions

#### Smooth Animations
```dart
// Optimal: Use GPU-accelerated properties
AnimatedBuilder(
  animation: controller,
  builder: (context, child) {
    return Transform.translate(
      offset: Offset(0, controller.value * 100),
      child: child,
    );
  },
)

// Avoid: Expensive repaints
CustomPaint(painter: ExpensivePainter())
```

### 7. Theme Performance

#### Efficient Theme Application
- Cache theme colors
- Use const constructors for theme data
- Avoid unnecessary rebuilds on theme changes

### 8. Database Performance

#### Efficient Queries
- Index frequently queried fields
- Use pagination
- Implement proper filtering

### 9. Monitoring & Profiling

#### Flutter DevTools
```bash
# Launch with performance monitoring
flutter run --profile

# Memory profiling
flutter run --profile --track-widget-creation
```

#### Performance Metrics
- Frame rendering time (target: 16ms for 60fps)
- Memory usage
- CPU usage
- Network latency

### 10. Platform-Specific Optimizations

#### Android
- Enable multidex
- Use release builds
- Implement native performance-critical code in Kotlin

#### iOS
- Use Metal for graphics
- Enable bitcode
- Optimize bundle size

## Benchmarking

### Key Metrics
- **FCP (First Contentful Paint)**: < 1s
- **LCP (Largest Contentful Paint)**: < 2.5s
- **INP (Interaction to Next Paint)**: < 200ms
- **CLS (Cumulative Layout Shift)**: < 0.1

### Testing Performance
```bash
# Run performance tests
flutter test --track-widget-creation

# Generate performance profiles
flutter run -d android --profile
```

## Best Practices Checklist

- [ ] All widgets use const constructors
- [ ] Images are properly cached and compressed
- [ ] Animations use GPU-accelerated properties
- [ ] No memory leaks in dispose methods
- [ ] Efficient state management with proper invalidation
- [ ] API responses are cached appropriately
- [ ] Large lists use ListView.builder
- [ ] Network requests are debounced
- [ ] Release builds tested before deployment
- [ ] Performance metrics monitored post-deployment
