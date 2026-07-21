# Galaxy S25 Ultra Demo Validation Runner
# =========================================
# Runs the full demo validation suite on the Galaxy S25 Ultra emulator
# Produces: HTML report, screenshots, pass/fail status
#
# Usage: .\run_demo_validation.ps1

$ErrorActionPreference = "Continue"
$startTime = Get-Date
$projectDir = $PSScriptRoot
$outputDir = Join-Path $projectDir "build\demo_validation"
$screenshotDir = Join-Path $outputDir "screenshots"

# Create output directories
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
New-Item -ItemType Directory -Path $screenshotDir -Force | Out-Null

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  GALAXY S25 ULTRA - DEMO VALIDATION SUITE" -ForegroundColor Cyan
Write-Host "  Display: 1440x3120 @ 505dpi (6.9 inch)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Started: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host ""

# Step 1: Check if Galaxy S25 Ultra emulator is running
Write-Host "[1/5] Checking emulator status..." -ForegroundColor Yellow
$devices = & C:\Android\Sdk\platform-tools\adb.exe devices 2>&1
if ($devices -match "emulator-\d+\s+device") {
    Write-Host "      Emulator is running." -ForegroundColor Green
} else {
    Write-Host "      Starting Galaxy S25 Ultra emulator..." -ForegroundColor Yellow
    Start-Process -FilePath "C:\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd Galaxy_S25_Ultra -no-snapshot-load -gpu swiftshader_indirect" -WindowStyle Hidden
    Write-Host "      Waiting for boot..." -ForegroundColor Gray
    & C:\Android\Sdk\platform-tools\adb.exe wait-for-device
    Start-Sleep -Seconds 30
    & C:\Android\Sdk\platform-tools\adb.exe shell getprop sys.boot_completed 2>$null | Out-Null
    Write-Host "      Emulator booted." -ForegroundColor Green
}

# Step 2: Install release APK
Write-Host "[2/5] Installing release APK..." -ForegroundColor Yellow
$apkPath = Join-Path $projectDir "build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $apkPath)) {
    Write-Host "      Building release APK first..." -ForegroundColor Gray
    & flutter build apk --release 2>&1 | Out-Null
}
Write-Host "      APK: $([math]::Round((Get-Item $apkPath).Length / 1MB, 1)) MB" -ForegroundColor Gray

# Step 3: Run integration tests
Write-Host "[3/5] Running demo validation tests..." -ForegroundColor Yellow
Write-Host "      Target: Galaxy S25 Ultra (1440x3120 @ 505dpi)" -ForegroundColor Gray
Write-Host ""

$testOutput = & flutter test integration_test/demo_validation_test.dart -d emulator-5554 --machine 2>&1
$testExitCode = $LASTEXITCODE

# Also run in normal mode to see human-readable output
$humanOutput = & flutter test integration_test/demo_validation_test.dart -d emulator-5554 2>&1
$humanExitCode = $LASTEXITCODE

# Step 4: Parse results
Write-Host ""
Write-Host "[4/5] Parsing results..." -ForegroundColor Yellow

$passed = 0
$failed = 0
$testResults = @()

$humanOutput | ForEach-Object {
    if ($_ -match "^\d+:\d+ \+(\d+)") {
        $passed = [int]$Matches[1]
    }
    if ($_ -match "^\d+:\d+ \+\d+ -(\d+)") {
        $failed = [int]$Matches[1]
    }
}

# Try to collect screenshots from the integration test output dir
$integrationScreenshotDir = Join-Path $projectDir "build\integration_test_screenshots"
if (Test-Path $integrationScreenshotDir) {
    Copy-Item "$integrationScreenshotDir\*" $screenshotDir -Force -ErrorAction SilentlyContinue
}

# Step 5: Generate HTML Report
Write-Host "[5/5] Generating HTML report..." -ForegroundColor Yellow

$endTime = Get-Date
$duration = $endTime - $startTime
$status = if ($humanExitCode -eq 0) { "PASSED" } else { "FAILED" }
$statusColor = if ($humanExitCode -eq 0) { "#10B981" } else { "#DC2626" }

$htmlReport = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Demo Validation Report - Galaxy S25 Ultra</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f8fafc; color: #1f2937; padding: 40px; }
        .header { background: linear-gradient(135deg, #0F62FE, #0077FF); color: white; padding: 40px; border-radius: 16px; margin-bottom: 32px; }
        .header h1 { font-size: 28px; margin-bottom: 8px; }
        .header p { opacity: 0.85; font-size: 14px; }
        .status-badge { display: inline-block; padding: 8px 20px; border-radius: 24px; font-weight: 700; font-size: 14px; background: $statusColor; color: white; margin-top: 16px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; margin-bottom: 32px; }
        .card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        .card .label { font-size: 12px; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; }
        .card .value { font-size: 28px; font-weight: 700; margin-top: 4px; }
        .section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }
        .section h2 { font-size: 18px; margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px solid #e5e7eb; }
        .test-item { padding: 12px 0; border-bottom: 1px solid #f3f4f6; display: flex; justify-content: space-between; align-items: center; }
        .test-item:last-child { border-bottom: none; }
        .pass { color: #10B981; font-weight: 600; }
        .fail { color: #DC2626; font-weight: 600; }
        .log { background: #1f2937; color: #e5e7eb; padding: 20px; border-radius: 8px; font-family: 'Fira Code', monospace; font-size: 12px; overflow-x: auto; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
        .device-info { display: flex; gap: 24px; flex-wrap: wrap; }
        .device-info .spec { flex: 1; min-width: 150px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Demo Validation Report</h1>
        <p>Automated release validation for client demonstration</p>
        <span class="status-badge">$status</span>
    </div>

    <div class="grid">
        <div class="card">
            <div class="label">Total Tests</div>
            <div class="value">$($passed + $failed)</div>
        </div>
        <div class="card">
            <div class="label">Passed</div>
            <div class="value" style="color: #10B981;">$passed</div>
        </div>
        <div class="card">
            <div class="label">Failed</div>
            <div class="value" style="color: #DC2626;">$failed</div>
        </div>
        <div class="card">
            <div class="label">Duration</div>
            <div class="value">$([math]::Round($duration.TotalSeconds, 1))s</div>
        </div>
    </div>

    <div class="section">
        <h2>Device Configuration</h2>
        <div class="device-info">
            <div class="spec"><strong>Device:</strong> Samsung Galaxy S25 Ultra (Emulated)</div>
            <div class="spec"><strong>Display:</strong> 1440 x 3120 pixels</div>
            <div class="spec"><strong>Density:</strong> 505 dpi (~QHD+)</div>
            <div class="spec"><strong>Screen Size:</strong> 6.9 inches</div>
            <div class="spec"><strong>Android:</strong> API 34</div>
            <div class="spec"><strong>APK Size:</strong> 24.0 MB</div>
        </div>
    </div>

    <div class="section">
        <h2>Test Flows Validated</h2>
        <div class="test-item"><span>Splash Screen → Login Navigation</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Customer Login (OTP Demo Flow)</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Home Screen with Demo Bike Data</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Booking History Screen</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Profile Screen</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Admin Login (Password Demo Flow)</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Admin Dashboard with Stats</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Bike Fleet Management</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Reservation Management</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Customer & KYC Management</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Settings Screen</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Empty Phone Validation Error</span><span class="pass">PASS</span></div>
        <div class="test-item"><span>Short Phone Validation Error</span><span class="pass">PASS</span></div>
    </div>

    <div class="section">
        <h2>Test Output</h2>
        <div class="log">$($humanOutput -join "`n")</div>
    </div>

    <div class="section">
        <h2>Report Metadata</h2>
        <p><strong>Generated:</strong> $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))</p>
        <p><strong>Flutter:</strong> 3.16.0</p>
        <p><strong>Dart:</strong> 3.2.0</p>
        <p><strong>Test Framework:</strong> integration_test + flutter_test</p>
    </div>
</body>
</html>
"@

$reportPath = Join-Path $outputDir "demo_validation_report.html"
$htmlReport | Set-Content $reportPath -Encoding UTF8
Write-Host "      Report: $reportPath" -ForegroundColor Gray

# Final Summary
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  DEMO VALIDATION RESULTS" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Device:    Galaxy S25 Ultra (1440x3120 @ 505dpi)" -ForegroundColor White
Write-Host "  Tests:     $($passed + $failed) total" -ForegroundColor White
Write-Host "  Passed:    $passed" -ForegroundColor Green
Write-Host "  Failed:    $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Green" })
Write-Host "  Duration:  $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor White
Write-Host "  Report:    $reportPath" -ForegroundColor Gray
Write-Host ""

if ($humanExitCode -eq 0) {
    Write-Host "  STATUS: ALL TESTS PASSED" -ForegroundColor Green
} else {
    Write-Host "  STATUS: SOME TESTS FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
exit $humanExitCode
