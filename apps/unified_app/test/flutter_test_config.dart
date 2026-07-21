import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Allow runtime fetching - silently fails in test env without network
  GoogleFonts.config.allowRuntimeFetching = true;

  // Load bundled fonts for golden comparisons
  await loadAppFonts();
  return testMain();
}
