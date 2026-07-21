# Implementation Plan - Stable Demo-Ready Flutter Environment

This plan details the steps to verify and stabilize the Flutter development environment for a client demo, focusing on minimal changes and stability as per user guidelines.

## User Review Required

> [!IMPORTANT]
> I will switch the Flutter channel to `stable`. This resolves the "unknown channel" warning in `flutter doctor`. I will only upgrade the SDK version if `flutter analyze` or `flutter run` fails due to SDK-specific bugs.

> [!IMPORTANT]
> I will create a Pixel 8 Pro emulator with Android 15 (API 35). This requires downloading the system image if not present.

## Proposed Changes

### 1. Flutter SDK Stability
- Switch to the `stable` channel: `flutter channel stable`.
- **Reason**: Fixes the "unknown channel" warning and ensures the SDK is in a known good state.

### 2. Dependency & Analysis
- Run `flutter pub get` in `apps/unified_app` and `shared`.
- Run `flutter analyze` to verify Riverpod, GoRouter, and Material 3 compatibility.
- **Action**: Only upgrade dependencies if analysis reveals errors that cannot be fixed otherwise.

### 3. Android & Gradle Configuration
- Verify compatibility of JDK 21 with the current Gradle (7.5) and AGP versions.
- **Action**: If `flutter run` fails due to JDK/Gradle mismatch, I will perform the *minimal* necessary upgrade (e.g., updating AGP or Gradle wrapper to a version that supports JDK 21).

### 4. Emulator Setup (Pixel 8 Pro, API 35)
- Search for API 35 system images: `sdkmanager --list`.
- Install image if missing: `sdkmanager "system-images;android-35;google_apis;x86_64"`.
- Create AVD: `avdmanager create avd -n Pixel_8_Pro_API_35 -k "system-images;android-35;google_apis;x86_64" -d "pixel_8_pro"`.
- Launch: `flutter emulators --launch Pixel_8_Pro_API_35`.

### 5. Final Verification
- `flutter doctor -v`
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter run`

## Verification Plan

### Automated Tests
- `flutter analyze` - Must pass with no errors.
- `flutter test` - Must pass all existing tests.

### Manual Verification
- `flutter run` - App must launch and run on the new Pixel 8 Pro emulator.
- `flutter doctor` - No critical issues remaining.
