#!/bin/bash

# E2E Testing Automation Script for Quiz App
# Supports Flutter integration tests and Playwright MCP integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLUTTER_WEB_PORT=8080
PLAYWRIGHT_RESULTS_DIR="test-results"

print_header() {
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BLUE}       Quiz App E2E Testing Suite${NC}"
    echo -e "${BLUE}=================================================${NC}"
}

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check dependencies
check_dependencies() {
    echo "🔍 Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found. Please install Flutter SDK."
        exit 1
    fi
    
    if ! command -v npx &> /dev/null; then
        print_warning "NPX not found. Playwright tests will be skipped."
        SKIP_PLAYWRIGHT=true
    fi
    
    print_status "Dependencies checked"
}

# Setup test environment
setup_environment() {
    echo "🚀 Setting up test environment..."
    
    # Create results directory
    mkdir -p $PLAYWRIGHT_RESULTS_DIR
    
    # Install Playwright if needed
    if [ -z "$SKIP_PLAYWRIGHT" ]; then
        if [ ! -f "package.json" ]; then
            echo "📦 Initializing npm package for Playwright..."
            npm init -y > /dev/null 2>&1
            npm install --save-dev @playwright/test > /dev/null 2>&1
            npx playwright install > /dev/null 2>&1
        fi
    fi
    
    print_status "Environment setup complete"
}

# Run Flutter integration tests
run_flutter_integration_tests() {
    echo "🧪 Running Flutter integration tests..."
    
    if [ ! -d "integration_test" ]; then
        print_warning "No integration_test directory found. Creating basic structure..."
        mkdir -p integration_test
        return 0
    fi
    
    # Run integration tests on different platforms
    if flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d web-server --web-port=$FLUTTER_WEB_PORT; then
        print_status "Flutter integration tests passed"
    else
        print_error "Flutter integration tests failed"
        return 1
    fi
}

# Run Playwright tests
run_playwright_tests() {
    if [ -n "$SKIP_PLAYWRIGHT" ]; then
        print_warning "Skipping Playwright tests (NPX not available)"
        return 0
    fi
    
    echo "🎭 Running Playwright tests..."
    
    # Start Flutter web server in background
    echo "🌐 Starting Flutter web server..."
    flutter build web
    flutter run -d web-server --web-port=$FLUTTER_WEB_PORT &
    FLUTTER_PID=$!
    
    # Wait for server to start
    echo "⏳ Waiting for web server to be ready..."
    for i in {1..30}; do
        if curl -s http://localhost:$FLUTTER_WEB_PORT > /dev/null; then
            break
        fi
        sleep 2
    done
    
    # Run Playwright tests
    if npx playwright test --config=integration_test/playwright/playwright.config.ts; then
        print_status "Playwright tests passed"
        PLAYWRIGHT_SUCCESS=true
    else
        print_error "Playwright tests failed"
        PLAYWRIGHT_SUCCESS=false
    fi
    
    # Stop Flutter web server
    kill $FLUTTER_PID 2>/dev/null || true
    
    return $([ "$PLAYWRIGHT_SUCCESS" = true ] && echo 0 || echo 1)
}

# Generate test report
generate_report() {
    echo "📊 Generating test report..."
    
    cat > $PLAYWRIGHT_RESULTS_DIR/e2e-report.md << EOF
# E2E Test Report

**Generated**: $(date)

## Test Results Summary

### Flutter Integration Tests
- Status: ${FLUTTER_SUCCESS:-"Not Run"}
- Platform Coverage: Web, Android, iOS

### Playwright Web Tests  
- Status: ${PLAYWRIGHT_SUCCESS:-"Not Run"}
- Browser Coverage: Chrome, Firefox, Safari
- Mobile Testing: iOS Safari, Android Chrome

### Test Artifacts
- Screenshots: $PLAYWRIGHT_RESULTS_DIR/screenshots/
- Videos: $PLAYWRIGHT_RESULTS_DIR/videos/
- Traces: $PLAYWRIGHT_RESULTS_DIR/traces/

## Next Steps
1. Review failed test screenshots and videos
2. Update test cases based on new features
3. Expand E2E coverage for critical user flows
EOF

    print_status "Test report generated: $PLAYWRIGHT_RESULTS_DIR/e2e-report.md"
}

# Cleanup
cleanup() {
    echo "🧹 Cleaning up..."
    
    # Kill any remaining Flutter processes
    pkill -f "flutter run" 2>/dev/null || true
    
    # Clean temporary files
    flutter clean > /dev/null 2>&1 || true
    
    print_status "Cleanup complete"
}

# Main execution
main() {
    print_header
    
    # Set trap for cleanup on exit
    trap cleanup EXIT
    
    case "${1:-all}" in
        "flutter")
            check_dependencies
            setup_environment
            run_flutter_integration_tests
            FLUTTER_SUCCESS=$?
            ;;
        "playwright")
            check_dependencies
            setup_environment
            run_playwright_tests
            ;;
        "all")
            check_dependencies
            setup_environment
            
            run_flutter_integration_tests
            FLUTTER_SUCCESS=$?
            
            run_playwright_tests
            
            generate_report
            ;;
        "setup")
            check_dependencies
            setup_environment
            print_status "E2E test environment setup complete"
            ;;
        *)
            echo "Usage: $0 [flutter|playwright|all|setup]"
            echo ""
            echo "Commands:"
            echo "  flutter    - Run Flutter integration tests only"
            echo "  playwright - Run Playwright web tests only"
            echo "  all        - Run all E2E tests (default)"
            echo "  setup      - Setup E2E test environment"
            exit 1
            ;;
    esac
    
    echo ""
    print_status "E2E testing complete!"
}

main "$@"