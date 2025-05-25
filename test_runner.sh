#!/bin/bash

# Test Runner Script for SupplyLine MRO Suite Mobile
# This script runs various types of tests and generates reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Flutter version:"
    flutter --version
}

# Function to get dependencies
get_dependencies() {
    print_status "Getting Flutter dependencies..."
    flutter pub get
    
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
}

# Function to run code generation
run_code_generation() {
    print_status "Running code generation..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    if [ $? -eq 0 ]; then
        print_success "Code generation completed successfully"
    else
        print_warning "Code generation failed or not needed"
    fi
}

# Function to run static analysis
run_analysis() {
    print_status "Running static analysis..."
    flutter analyze
    
    if [ $? -eq 0 ]; then
        print_success "Static analysis passed"
    else
        print_error "Static analysis failed"
        exit 1
    fi
}

# Function to check code formatting
check_formatting() {
    print_status "Checking code formatting..."
    dart format --output=none --set-exit-if-changed .
    
    if [ $? -eq 0 ]; then
        print_success "Code formatting is correct"
    else
        print_error "Code formatting issues found. Run 'dart format .' to fix"
        exit 1
    fi
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    flutter test --coverage --reporter=expanded
    
    if [ $? -eq 0 ]; then
        print_success "Unit tests passed"
    else
        print_error "Unit tests failed"
        exit 1
    fi
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    if [ -d "integration_test" ]; then
        flutter test integration_test/
        
        if [ $? -eq 0 ]; then
            print_success "Integration tests passed"
        else
            print_error "Integration tests failed"
            exit 1
        fi
    else
        print_warning "No integration tests found"
    fi
}

# Function to generate coverage report
generate_coverage_report() {
    if [ -f "coverage/lcov.info" ]; then
        print_status "Generating coverage report..."
        
        # Install lcov if not available
        if ! command -v lcov &> /dev/null; then
            print_warning "lcov not installed. Install it to generate HTML coverage reports"
            return
        fi
        
        # Generate HTML coverage report
        genhtml coverage/lcov.info -o coverage/html
        
        if [ $? -eq 0 ]; then
            print_success "Coverage report generated in coverage/html/"
            
            # Calculate coverage percentage
            COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | grep -o '[0-9.]*%' | head -1)
            print_status "Test coverage: $COVERAGE"
        else
            print_error "Failed to generate coverage report"
        fi
    else
        print_warning "No coverage data found"
    fi
}

# Function to run security checks
run_security_checks() {
    print_status "Running security checks..."
    
    # Check for known vulnerabilities in dependencies
    flutter pub deps --json > deps.json
    
    # Basic security checks (can be extended with more tools)
    print_status "Checking for hardcoded secrets..."
    if grep -r "password\|secret\|key\|token" lib/ --include="*.dart" | grep -v "// TODO\|// FIXME"; then
        print_warning "Potential hardcoded secrets found. Please review."
    else
        print_success "No obvious hardcoded secrets found"
    fi
    
    rm -f deps.json
}

# Function to run performance tests
run_performance_tests() {
    print_status "Running performance tests..."
    if [ -d "test/performance" ]; then
        flutter test test/performance/
        
        if [ $? -eq 0 ]; then
            print_success "Performance tests passed"
        else
            print_error "Performance tests failed"
            exit 1
        fi
    else
        print_warning "No performance tests found"
    fi
}

# Function to clean up
cleanup() {
    print_status "Cleaning up..."
    flutter clean
    rm -rf coverage/
    rm -f deps.json
}

# Main function
main() {
    print_status "Starting SupplyLine MRO Suite Mobile Test Runner"
    print_status "=============================================="
    
    # Parse command line arguments
    RUN_ALL=true
    RUN_ANALYSIS=false
    RUN_TESTS=false
    RUN_INTEGRATION=false
    RUN_SECURITY=false
    RUN_PERFORMANCE=false
    CLEAN=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --analysis)
                RUN_ANALYSIS=true
                RUN_ALL=false
                shift
                ;;
            --tests)
                RUN_TESTS=true
                RUN_ALL=false
                shift
                ;;
            --integration)
                RUN_INTEGRATION=true
                RUN_ALL=false
                shift
                ;;
            --security)
                RUN_SECURITY=true
                RUN_ALL=false
                shift
                ;;
            --performance)
                RUN_PERFORMANCE=true
                RUN_ALL=false
                shift
                ;;
            --clean)
                CLEAN=true
                shift
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --analysis      Run only static analysis"
                echo "  --tests         Run only unit tests"
                echo "  --integration   Run only integration tests"
                echo "  --security      Run only security checks"
                echo "  --performance   Run only performance tests"
                echo "  --clean         Clean build artifacts"
                echo "  --help          Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Clean if requested
    if [ "$CLEAN" = true ]; then
        cleanup
        exit 0
    fi
    
    # Check prerequisites
    check_flutter
    get_dependencies
    run_code_generation
    
    # Run selected tests
    if [ "$RUN_ALL" = true ] || [ "$RUN_ANALYSIS" = true ]; then
        check_formatting
        run_analysis
    fi
    
    if [ "$RUN_ALL" = true ] || [ "$RUN_TESTS" = true ]; then
        run_unit_tests
        generate_coverage_report
    fi
    
    if [ "$RUN_ALL" = true ] || [ "$RUN_INTEGRATION" = true ]; then
        run_integration_tests
    fi
    
    if [ "$RUN_ALL" = true ] || [ "$RUN_SECURITY" = true ]; then
        run_security_checks
    fi
    
    if [ "$RUN_ALL" = true ] || [ "$RUN_PERFORMANCE" = true ]; then
        run_performance_tests
    fi
    
    print_success "All tests completed successfully!"
}

# Run main function
main "$@"
