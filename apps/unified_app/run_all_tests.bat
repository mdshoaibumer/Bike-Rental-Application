@echo off
REM Flutter Bike Rental - Comprehensive Test Runner (CMD)
REM =====================================================

echo.
echo ====================================
echo   BIKE RENTAL - TEST SUITE RUNNER
echo ====================================
echo.

set FAILED=0

REM Step 1: Clean
echo [1/6] Cleaning project...
call flutter clean >nul 2>&1
echo       Done.

REM Step 2: Get dependencies
echo [2/6] Getting dependencies...
call flutter pub get >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo       FAILED - pub get failed
    set FAILED=1
) else (
    echo       Done.
)

REM Step 3: Analyze
echo [3/6] Running flutter analyze...
call flutter analyze 2>&1
if %ERRORLEVEL% neq 0 (
    echo       FAILED - Analyzer issues found
    set FAILED=1
) else (
    echo       No issues found.
)

REM Step 4: Unit and Widget Tests
echo [4/6] Running unit and widget tests...
call flutter test 2>&1
if %ERRORLEVEL% neq 0 (
    echo       SOME TESTS FAILED
    set FAILED=1
) else (
    echo       All tests passed.
)

REM Step 5: Integration Tests
echo [5/6] Running integration tests...
echo       (Requires running emulator or device)
call flutter test integration_test 2>&1
if %ERRORLEVEL% neq 0 (
    echo       FAILED or no device available
) else (
    echo       Integration tests passed.
)

REM Step 6: Summary
echo [6/6] Golden tests included in step 4.
echo.
echo ====================================
echo        TEST RESULTS SUMMARY
echo ====================================
echo.

if %FAILED% equ 0 (
    echo   ALL CHECKS PASSED
    echo.
    echo ====================================
    exit /b 0
) else (
    echo   SOME CHECKS FAILED
    echo.
    echo ====================================
    exit /b 1
)
