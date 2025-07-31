#!/bin/bash

# E2E Test Runner Script for Quiz App
# This script runs integration tests on different platforms

set -e

echo "🧪 Quiz App E2E Test Runner"
echo "============================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites (removed chrome and geckodriver checks for now)
print_status "Checking prerequisites..."

if ! command_exists flutter; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

if ! command_exists dart; then
    print_error "Dart is not installed or not in PATH"
    exit 1
fi

print_success "Prerequisites check passed"

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Check for test files
if [ ! -d "integration_test" ]; then
    print_error "integration_test directory not found"
    exit 1
fi

# Default values
PLATFORM="all"
DEVICE=""
VERBOSE=false
TEST_FILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -t|--test)
            TEST_FILE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -p, --platform PLATFORM  Target platform (web, android, ios, all)"
            echo "  -d, --device DEVICE      Specific device to run tests on"
            echo "  -t, --test TEST_FILE     Specific test file to run"
            echo "  -v, --verbose           Enable verbose output"
            echo "  -h, --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Run all tests on all platforms"
            echo "  $0 --platform web                    # Run tests on web only"
            echo "  $0 --test splash_screen_test.dart    # Run specific test file"
            echo "  $0 --device chrome --verbose         # Run on Chrome with verbose output"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Set verbose flag for Flutter commands
FLUTTER_VERBOSE=""
if [ "$VERBOSE" = true ]; then
    FLUTTER_VERBOSE="--verbose"
fi

# Function to run tests on web platform
run_web_tests() {
    print_status "Running E2E tests on Web platform..."
    
    # Check if Chrome is available (optional for now)
    if command_exists google-chrome || command_exists google-chrome-stable || command_exists chromium-browser; then
        print_success "Chrome browser found"
    else
        print_warning "Chrome browser not found, tests may not run properly on web"
    fi
    
    if [ -n "$TEST_FILE" ]; then
        flutter test integration_test/"$TEST_FILE" -d web-server $FLUTTER_VERBOSE
    else
        flutter test integration_test/ -d web-server $FLUTTER_VERBOSE
    fi
}

# Function to run tests on Android
run_android_tests() {
    print_status "Running E2E tests on Android platform..."
    
    # Check for Android devices/emulators
    if command_exists adb; then
        ANDROID_DEVICES=$(adb devices | grep -w "device" | wc -l)
        if [ "$ANDROID_DEVICES" -eq 0 ]; then
            print_warning "No Android devices found. Please start an emulator or connect a device."
            return 1
        else
            print_success "Found $ANDROID_DEVICES Android device(s)"
        fi
    else
        print_warning "ADB not found. Android SDK may not be properly configured."
        return 1
    fi
    
    if [ -n "$DEVICE" ]; then
        if [ -n "$TEST_FILE" ]; then
            flutter test integration_test/"$TEST_FILE" -d "$DEVICE" $FLUTTER_VERBOSE
        else
            flutter test integration_test/ -d "$DEVICE" $FLUTTER_VERBOSE
        fi
    else
        if [ -n "$TEST_FILE" ]; then
            flutter test integration_test/"$TEST_FILE" -d android $FLUTTER_VERBOSE
        else
            flutter test integration_test/ -d android $FLUTTER_VERBOSE
        fi
    fi
}

# Function to run tests on iOS (macOS only)
run_ios_tests() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "iOS testing is only available on macOS"
        return 1
    fi
    
    print_status "Running E2E tests on iOS platform..."
    
    # Check for iOS simulators
    if command_exists xcrun; then
        IOS_SIMS=$(xcrun simctl list devices | grep "Booted" | wc -l)
        if [ "$IOS_SIMS" -eq 0 ]; then
            print_warning "No iOS simulators running. Please start an iOS simulator."
            return 1
        else
            print_success "Found running iOS simulator(s)"
        fi
    else
        print_warning "Xcode command line tools not found."
        return 1
    fi
    
    if [ -n "$DEVICE" ]; then
        if [ -n "$TEST_FILE" ]; then
            flutter test integration_test/"$TEST_FILE" -d "$DEVICE" $FLUTTER_VERBOSE
        else
            flutter test integration_test/ -d "$DEVICE" $FLUTTER_VERBOSE
        fi
    else
        if [ -n "$TEST_FILE" ]; then
            flutter test integration_test/"$TEST_FILE" -d ios $FLUTTER_VERBOSE
        else
            flutter test integration_test/ -d ios $FLUTTER_VERBOSE
        fi
    fi
}

# Main execution
print_status "Starting E2E tests..."
print_status "Platform: $PLATFORM"
if [ -n "$DEVICE" ]; then
    print_status "Device: $DEVICE"
fi
if [ -n "$TEST_FILE" ]; then
    print_status "Test file: $TEST_FILE"
fi

FAILED_PLATFORMS=""

case $PLATFORM in
    web)
        if ! run_web_tests; then
            FAILED_PLATFORMS="web"
        fi
        ;;
    android)
        if ! run_android_tests; then
            FAILED_PLATFORMS="android"
        fi
        ;;
    ios)
        if ! run_ios_tests; then
            FAILED_PLATFORMS="ios"
        fi
        ;;
    all)
        print_status "Running tests on all available platforms..."
        
        # Web tests
        if ! run_web_tests; then
            FAILED_PLATFORMS="web"
        fi
        
        # Android tests (if available)
        if ! run_android_tests; then
            if [ -n "$FAILED_PLATFORMS" ]; then
                FAILED_PLATFORMS="$FAILED_PLATFORMS, android"
            else
                FAILED_PLATFORMS="android"
            fi
        fi
        
        # iOS tests (if on macOS)
        if ! run_ios_tests; then
            if [ -n "$FAILED_PLATFORMS" ]; then
                FAILED_PLATFORMS="$FAILED_PLATFORMS, ios"
            else
                FAILED_PLATFORMS="ios"
            fi
        fi
        ;;
    *)
        print_error "Unknown platform: $PLATFORM"
        print_error "Supported platforms: web, android, ios, all"
        exit 1
        ;;
esac

# Summary
echo ""
echo "============================"
if [ -n "$FAILED_PLATFORMS" ]; then
    print_warning "Tests completed with some failures on: $FAILED_PLATFORMS"
    print_status "Check the output above for details"
    exit 1
else
    print_success "All E2E tests completed successfully! 🎉"
fi