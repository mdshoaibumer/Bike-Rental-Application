# Flutter Bike Rental - Comprehensive Test Runner
# ==================================================
param(
    [switch]$SkipClean,
    [switch]$SkipIntegration,
    [switch]$Coverage
)

$ErrorActionPreference = "Continue"
$startTime = Get-Date
$failedSteps = @()
$totalTests = 0
$passedTests = 0
$failedTests = 0

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "  BIKE RENTAL - TEST SUITE RUNNER" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Started: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))`n" -ForegroundColor Gray

# Step 1: Clean (optional)
if (-not $SkipClean) {
    Write-Host "[1/6] Cleaning project..." -ForegroundColor Yellow
    flutter clean 2>&1 | Out-Null
    Write-Host "      Done." -ForegroundColor Green
} else {
    Write-Host "[1/6] Skipping clean." -ForegroundColor Gray
}

# Step 2: Get dependencies
Write-Host "[2/6] Getting dependencies..." -ForegroundColor Yellow
$pubGetOutput = flutter pub get 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "      FAILED - pub get failed" -ForegroundColor Red
    $failedSteps += "pub get"
} else {
    Write-Host "      Done." -ForegroundColor Green
}

# Step 3: Flutter analyze
Write-Host "[3/6] Running flutter analyze..." -ForegroundColor Yellow
$analyzeOutput = flutter analyze 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "      FAILED - Analyzer issues found:" -ForegroundColor Red
    $analyzeOutput | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }
    $failedSteps += "analyze"
} else {
    Write-Host "      No issues found." -ForegroundColor Green
}

# Step 4: Unit & Widget Tests
Write-Host "[4/6] Running unit & widget tests..." -ForegroundColor Yellow
if ($Coverage) {
    $testOutput = flutter test --coverage 2>&1
} else {
    $testOutput = flutter test 2>&1
}
$testExitCode = $LASTEXITCODE

# Parse test results
$testResultLine = $testOutput | Select-String -Pattern "(\d+) tests? passed" | Select-Object -Last 1
$testFailLine = $testOutput | Select-String -Pattern "(\d+) tests? failed" | Select-Object -Last 1

if ($testResultLine) {
    $passedMatch = [regex]::Match($testResultLine.Line, "(\d+) tests? passed")
    if ($passedMatch.Success) { $passedTests = [int]$passedMatch.Groups[1].Value }
}

# Also parse the flutter test summary format: "XX:XX +N ~N -N"
$summaryLine = $testOutput | Select-String -Pattern "\+(\d+)" | Select-Object -Last 1
if ($summaryLine) {
    $plusMatch = [regex]::Match($summaryLine.Line, "\+(\d+)")
    $minusMatch = [regex]::Match($summaryLine.Line, "-(\d+)")
    if ($plusMatch.Success) { $passedTests = [int]$plusMatch.Groups[1].Value }
    if ($minusMatch.Success) { $failedTests = [int]$minusMatch.Groups[1].Value }
}

$totalTests = $passedTests + $failedTests

if ($testExitCode -ne 0) {
    Write-Host "      SOME TESTS FAILED" -ForegroundColor Red
    $failedSteps += "unit/widget tests"
} else {
    Write-Host "      All tests passed ($passedTests)" -ForegroundColor Green
}

# Step 5: Integration Tests (if not skipped)
if (-not $SkipIntegration) {
    Write-Host "[5/6] Running integration tests..." -ForegroundColor Yellow
    Write-Host "      (Requires running emulator or device)" -ForegroundColor Gray
    $integrationOutput = flutter test integration_test 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "      FAILED or no device available" -ForegroundColor Yellow
        $failedSteps += "integration tests"
    } else {
        Write-Host "      Integration tests passed." -ForegroundColor Green
    }
} else {
    Write-Host "[5/6] Skipping integration tests." -ForegroundColor Gray
}

# Step 6: Golden Tests (part of flutter test, already run)
Write-Host "[6/6] Golden tests included in step 4." -ForegroundColor Green

# Summary
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n====================================" -ForegroundColor Cyan
Write-Host "        TEST RESULTS SUMMARY" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Tests Passed:  $passedTests" -ForegroundColor Green
Write-Host "  Tests Failed:  $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host "  Total Tests:   $totalTests" -ForegroundColor White

if ($Coverage -and (Test-Path "coverage/lcov.info")) {
    $lines = Get-Content "coverage/lcov.info" | Select-String "LF:" | ForEach-Object { [int]($_ -replace "LF:", "") }
    $hit = Get-Content "coverage/lcov.info" | Select-String "LH:" | ForEach-Object { [int]($_ -replace "LH:", "") }
    $totalLines = ($lines | Measure-Object -Sum).Sum
    $hitLines = ($hit | Measure-Object -Sum).Sum
    if ($totalLines -gt 0) {
        $coveragePct = [math]::Round(($hitLines / $totalLines) * 100, 1)
        Write-Host "  Coverage:      $coveragePct%" -ForegroundColor Cyan
    }
}

Write-Host "  Duration:      $($duration.TotalSeconds.ToString('F1'))s" -ForegroundColor White
Write-Host ""

if ($failedSteps.Count -gt 0) {
    Write-Host "  Failed Steps:" -ForegroundColor Red
    $failedSteps | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "  ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    exit 0
}
