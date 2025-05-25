@echo off
REM Test Runner Script for SupplyLine MRO Suite Mobile (Windows)
REM This script runs various types of tests and generates reports

setlocal enabledelayedexpansion

REM Function to print status messages
:print_status
echo [INFO] %~1
goto :eof

:print_success
echo [SUCCESS] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

REM Check if Flutter is installed
:check_flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    call :print_error "Flutter is not installed or not in PATH"
    exit /b 1
)
call :print_status "Flutter is available"
flutter --version
goto :eof

REM Get dependencies
:get_dependencies
call :print_status "Getting Flutter dependencies..."
flutter pub get
if errorlevel 1 (
    call :print_error "Failed to install dependencies"
    exit /b 1
)
call :print_success "Dependencies installed successfully"
goto :eof

REM Run code generation
:run_code_generation
call :print_status "Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    call :print_warning "Code generation failed or not needed"
) else (
    call :print_success "Code generation completed successfully"
)
goto :eof

REM Run static analysis
:run_analysis
call :print_status "Running static analysis..."
flutter analyze
if errorlevel 1 (
    call :print_error "Static analysis failed"
    exit /b 1
)
call :print_success "Static analysis passed"
goto :eof

REM Check code formatting
:check_formatting
call :print_status "Checking code formatting..."
dart format --output=none --set-exit-if-changed .
if errorlevel 1 (
    call :print_error "Code formatting issues found. Run 'dart format .' to fix"
    exit /b 1
)
call :print_success "Code formatting is correct"
goto :eof

REM Run unit tests
:run_unit_tests
call :print_status "Running unit tests..."
flutter test --coverage --reporter=expanded
if errorlevel 1 (
    call :print_error "Unit tests failed"
    exit /b 1
)
call :print_success "Unit tests passed"
goto :eof

REM Run integration tests
:run_integration_tests
call :print_status "Running integration tests..."
if exist "integration_test" (
    flutter test integration_test/
    if errorlevel 1 (
        call :print_error "Integration tests failed"
        exit /b 1
    )
    call :print_success "Integration tests passed"
) else (
    call :print_warning "No integration tests found"
)
goto :eof

REM Generate coverage report
:generate_coverage_report
if exist "coverage\lcov.info" (
    call :print_status "Coverage data found"
    call :print_status "Install lcov or use online tools to generate HTML coverage reports"
) else (
    call :print_warning "No coverage data found"
)
goto :eof

REM Run security checks
:run_security_checks
call :print_status "Running security checks..."
flutter pub deps --json > deps.json

call :print_status "Checking for hardcoded secrets..."
findstr /r /s /i "password secret key token" lib\*.dart | findstr /v "TODO FIXME" >nul
if errorlevel 1 (
    call :print_success "No obvious hardcoded secrets found"
) else (
    call :print_warning "Potential hardcoded secrets found. Please review."
)

if exist deps.json del deps.json
goto :eof

REM Run performance tests
:run_performance_tests
call :print_status "Running performance tests..."
if exist "test\performance" (
    flutter test test\performance\
    if errorlevel 1 (
        call :print_error "Performance tests failed"
        exit /b 1
    )
    call :print_success "Performance tests passed"
) else (
    call :print_warning "No performance tests found"
)
goto :eof

REM Clean up
:cleanup
call :print_status "Cleaning up..."
flutter clean
if exist coverage rmdir /s /q coverage
if exist deps.json del deps.json
goto :eof

REM Main execution
:main
call :print_status "Starting SupplyLine MRO Suite Mobile Test Runner"
call :print_status "=============================================="

REM Parse command line arguments
set RUN_ALL=true
set RUN_ANALYSIS=false
set RUN_TESTS=false
set RUN_INTEGRATION=false
set RUN_SECURITY=false
set RUN_PERFORMANCE=false
set CLEAN=false

:parse_args
if "%1"=="--analysis" (
    set RUN_ANALYSIS=true
    set RUN_ALL=false
    shift
    goto parse_args
)
if "%1"=="--tests" (
    set RUN_TESTS=true
    set RUN_ALL=false
    shift
    goto parse_args
)
if "%1"=="--integration" (
    set RUN_INTEGRATION=true
    set RUN_ALL=false
    shift
    goto parse_args
)
if "%1"=="--security" (
    set RUN_SECURITY=true
    set RUN_ALL=false
    shift
    goto parse_args
)
if "%1"=="--performance" (
    set RUN_PERFORMANCE=true
    set RUN_ALL=false
    shift
    goto parse_args
)
if "%1"=="--clean" (
    set CLEAN=true
    shift
    goto parse_args
)
if "%1"=="--help" (
    echo Usage: %0 [options]
    echo Options:
    echo   --analysis      Run only static analysis
    echo   --tests         Run only unit tests
    echo   --integration   Run only integration tests
    echo   --security      Run only security checks
    echo   --performance   Run only performance tests
    echo   --clean         Clean build artifacts
    echo   --help          Show this help message
    exit /b 0
)
if not "%1"=="" (
    call :print_error "Unknown option: %1"
    exit /b 1
)

REM Clean if requested
if "%CLEAN%"=="true" (
    call :cleanup
    exit /b 0
)

REM Check prerequisites
call :check_flutter
if errorlevel 1 exit /b 1

call :get_dependencies
if errorlevel 1 exit /b 1

call :run_code_generation

REM Run selected tests
if "%RUN_ALL%"=="true" (
    call :check_formatting
    if errorlevel 1 exit /b 1
    
    call :run_analysis
    if errorlevel 1 exit /b 1
    
    call :run_unit_tests
    if errorlevel 1 exit /b 1
    
    call :generate_coverage_report
    
    call :run_integration_tests
    if errorlevel 1 exit /b 1
    
    call :run_security_checks
    
    call :run_performance_tests
    if errorlevel 1 exit /b 1
) else (
    if "%RUN_ANALYSIS%"=="true" (
        call :check_formatting
        if errorlevel 1 exit /b 1
        call :run_analysis
        if errorlevel 1 exit /b 1
    )
    
    if "%RUN_TESTS%"=="true" (
        call :run_unit_tests
        if errorlevel 1 exit /b 1
        call :generate_coverage_report
    )
    
    if "%RUN_INTEGRATION%"=="true" (
        call :run_integration_tests
        if errorlevel 1 exit /b 1
    )
    
    if "%RUN_SECURITY%"=="true" (
        call :run_security_checks
    )
    
    if "%RUN_PERFORMANCE%"=="true" (
        call :run_performance_tests
        if errorlevel 1 exit /b 1
    )
)

call :print_success "All tests completed successfully!"
exit /b 0

REM Call main function
call :main %*
