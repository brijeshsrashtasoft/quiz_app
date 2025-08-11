#!/bin/bash

# Integration Tests Runner Script
# Provides convenient ways to run various integration test scenarios

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
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

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Flutter version
    flutter --version
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_error "Not in Flutter project root directory"
        exit 1
    fi
    
    # Check if integration_test directory exists
    if [ ! -d "integration_test" ]; then
        print_error "integration_test directory not found"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Clean and get dependencies
setup_project() {
    print_info "Setting up project..."
    flutter clean
    flutter pub get
    print_success "Project setup completed"
}

# Analyze integration tests
analyze_tests() {
    print_info "Analyzing integration tests..."
    flutter analyze integration_test/
    
    if [ $? -eq 0 ]; then
        print_success "Integration tests analysis passed"
    else
        print_error "Integration tests analysis failed"
        exit 1
    fi
}

# Run specific integration test
run_test() {
    local test_file=$1
    local timeout_mins=${2:-5} # Default 5 minutes timeout
    print_info "Running integration test: $test_file (max ${timeout_mins} minutes)"
    
    # Use gtimeout if available (from coreutils), otherwise just run without timeout
    if command -v gtimeout >/dev/null 2>&1; then
        gtimeout "${timeout_mins}m" flutter test "$test_file" --timeout=none
        local exit_code=$?
        
        if [ $exit_code -eq 124 ]; then
            print_error "Test timed out after ${timeout_mins} minutes: $test_file"
            return 1
        fi
    else
        flutter test "$test_file" --timeout=none
        local exit_code=$?
    fi
    
    if [ $exit_code -eq 0 ]; then
        print_success "Test completed successfully: $test_file"
    else
        print_error "Test failed: $test_file"
        return 1
    fi
}

# Run all integration tests
run_all_tests() {
    print_info "Running all integration tests..."
    
    local failed_tests=()
    
    # Run basic flow test first (fastest)
    if ! run_test "integration_test/basic_flow_test.dart" 3; then
        failed_tests+=("basic_flow_test.dart")
    fi
    
    # Run authentication test
    if ! run_test "integration_test/authentication_test.dart" 5; then
        failed_tests+=("authentication_test.dart")
    fi
    
    # Run comprehensive hosting test (might take longer)
    if ! run_test "integration_test/quiz_hosting_integration_test.dart" 10; then
        failed_tests+=("quiz_hosting_integration_test.dart")
    fi
    
    # Run quiz game flow test (longest)
    if ! run_test "integration_test/quiz_game_flow_test.dart" 10; then
        failed_tests+=("quiz_game_flow_test.dart")
    fi
    
    # Report results
    if [ ${#failed_tests[@]} -eq 0 ]; then
        print_success "All integration tests passed!"
    else
        print_error "The following tests failed:"
        for test in "${failed_tests[@]}"; do
            echo "  - $test"
        done
        exit 1
    fi
}

# Run tests on device (requires connected device/emulator)
run_on_device() {
    local test_file=$1
    print_info "Running integration test on device: $test_file"
    
    # Check if device is connected
    if ! flutter devices | grep -q "device"; then
        print_error "No device connected. Please connect a device or start an emulator."
        exit 1
    fi
    
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target="$test_file"
    
    if [ $? -eq 0 ]; then
        print_success "Device test completed successfully: $test_file"
    else
        print_error "Device test failed: $test_file"
        exit 1
    fi
}

# Show test coverage (if available)
show_coverage() {
    print_info "Generating test coverage..."
    
    flutter test --coverage integration_test/
    
    if [ -f "coverage/lcov.info" ]; then
        print_success "Coverage report generated: coverage/lcov.info"
        
        # If lcov is installed, generate HTML report
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            print_success "HTML coverage report: coverage/html/index.html"
        fi
    else
        print_warning "Coverage report not generated"
    fi
}

# Show usage information
show_usage() {
    echo "Integration Tests Runner"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  -a, --all              Run all integration tests"
    echo "  -b, --basic            Run basic flow test only"
    echo "  --auth                 Run authentication test only"
    echo "  -f, --flow             Run quiz game flow test only"
    echo "  -h, --hosting          Run comprehensive hosting test only"
    echo "  -d, --device [TEST]    Run test on connected device/emulator"
    echo "  -c, --coverage         Run tests with coverage"
    echo "  -s, --setup            Setup project dependencies"
    echo "  --analyze              Analyze integration tests only"
    echo "  --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all                          # Run all integration tests"
    echo "  $0 --flow                         # Run quiz game flow test"
    echo "  $0 --device integration_test/quiz_game_flow_test.dart"
    echo "  $0 --coverage                     # Run with coverage"
}

# Main script logic
main() {
    case "$1" in
        -a|--all)
            check_prerequisites
            setup_project
            analyze_tests
            run_all_tests
            ;;
        -b|--basic)
            check_prerequisites
            setup_project
            analyze_tests
            run_test "integration_test/basic_flow_test.dart" 3
            ;;
        --auth)
            check_prerequisites
            setup_project
            analyze_tests
            run_test "integration_test/authentication_test.dart" 5
            ;;
        -f|--flow)
            check_prerequisites
            setup_project
            analyze_tests
            run_test "integration_test/quiz_game_flow_test.dart" 10
            ;;
        -h|--hosting)
            check_prerequisites
            setup_project
            analyze_tests
            run_test "integration_test/quiz_hosting_integration_test.dart" 10
            ;;
        -d|--device)
            if [ -z "$2" ]; then
                print_error "Please specify test file for device testing"
                show_usage
                exit 1
            fi
            check_prerequisites
            setup_project
            run_on_device "$2"
            ;;
        -c|--coverage)
            check_prerequisites
            setup_project
            analyze_tests
            show_coverage
            ;;
        -s|--setup)
            check_prerequisites
            setup_project
            ;;
        --analyze)
            check_prerequisites
            analyze_tests
            ;;
        --help)
            show_usage
            ;;
        *)
            if [ -z "$1" ]; then
                print_info "No option specified. Running all integration tests..."
                check_prerequisites
                setup_project
                analyze_tests
                run_all_tests
            else
                print_error "Unknown option: $1"
                show_usage
                exit 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"