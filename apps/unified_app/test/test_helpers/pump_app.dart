import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/theme/app_theme.dart';

/// Pumps a widget wrapped in MaterialApp with theme for widget testing
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    List<Override> overrides = const [],
    Size? surfaceSize,
  }) async {
    if (surfaceSize != null) {
      view.physicalSize = surfaceSize;
      view.devicePixelRatio = 1.0;
      addTearDown(() => view.resetPhysicalSize());
    }

    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: Scaffold(body: widget),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  Future<void> pumpAppWithScaffold(
    Widget widget, {
    ThemeMode themeMode = ThemeMode.light,
    List<Override> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: widget,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

/// Standard device sizes for responsive testing
class TestDeviceSizes {
  static const smallPhone = Size(320, 568); // iPhone SE
  static const mediumPhone = Size(375, 812); // iPhone X
  static const largePhone = Size(428, 926); // iPhone 14 Pro Max
  static const tablet = Size(768, 1024); // iPad
}
