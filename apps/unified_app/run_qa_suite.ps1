# =========================================================
# Flutter QA Automation Suite Execution Script
# =========================================================

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "=================================================" -ForegroundColor Cyan
Write-Host " Starting QA Automation Suite for Bike Rental" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# 1. Ensure Dependencies
Write-Host "`n[1/4] Checking and fetching dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to fetch dependencies." -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "✅ Dependencies fetched." -ForegroundColor Green

# 2. Run Unit, Widget, and Golden Tests
Write-Host "`n[2/4] Running Unit, Widget, and Golden Tests..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Widget or Golden tests failed!" -ForegroundColor Red
    Write-Host "If golden tests failed due to missing baselines, run: flutter test --update-goldens" -ForegroundColor Yellow
    exit $LASTEXITCODE
}
Write-Host "✅ Widget and Golden tests passed." -ForegroundColor Green

# 3. Run E2E Integration Tests
Write-Host "`n[3/4] Running End-to-End Integration Tests..." -ForegroundColor Yellow
Write-Host "Make sure an Android emulator or device is running and connected." -ForegroundColor Yellow
flutter test integration_test/app_test.dart
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Integration tests failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "✅ Integration tests passed." -ForegroundColor Green

# 4. Ready for Release Build
Write-Host "`n[4/4] Finalizing..." -ForegroundColor Yellow
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "🎉 ALL TESTS PASSED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "You can now safely build the release APK:" -ForegroundColor Cyan
Write-Host "flutter build apk --release" -ForegroundColor White
Write-Host "=================================================" -ForegroundColor Cyan
