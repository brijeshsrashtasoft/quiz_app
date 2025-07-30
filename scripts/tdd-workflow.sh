#!/bin/bash

# TDD Workflow Automation Script
# Provides automated test-driven development workflow for Flutter

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$PROJECT_ROOT/test"
COVERAGE_DIR="$PROJECT_ROOT/coverage"
MIN_COVERAGE=80

echo -e "${BLUE}🚀 TDD Workflow Automation${NC}"
echo "================================="

# Function to display help
show_help() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  init                 Initialize TDD environment"
    echo "  red <test_file>      Run failing tests (Red phase)"
    echo "  green <test_file>    Run tests to verify they pass (Green phase)"
    echo "  refactor <test_file> Run tests during refactoring (Blue phase)"
    echo "  watch [pattern]      Watch files and auto-run tests"
    echo "  coverage             Generate and display coverage report"
    echo "  clean                Clean test artifacts"
    echo "  validate             Validate test structure and coverage"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -v, --verbose       Verbose output"
    echo "  -f, --filter        Filter tests by pattern"
    echo ""
    echo "Examples:"
    echo "  $0 init"
    echo "  $0 red test/unit/authentication/user_repository_test.dart"
    echo "  $0 watch 'authentication/*'"
    echo "  $0 coverage"
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found. Please install Flutter.${NC}"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        echo -e "${RED}❌ Not in a Flutter project directory.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
}

# Function to initialize TDD environment
init_tdd() {
    echo -e "${YELLOW}🔧 Initializing TDD environment...${NC}"
    
    # Create test directory structure if it doesn't exist
    mkdir -p "$TEST_DIR"/{unit,widget,integration,mocks,helpers,fixtures}
    
    # Create coverage directory
    mkdir -p "$COVERAGE_DIR"
    
    # Install dependencies
    echo -e "${YELLOW}📦 Installing test dependencies...${NC}"
    cd "$PROJECT_ROOT"
    flutter pub get
    
    # Generate initial mocks if needed
    if [ -f "$PROJECT_ROOT/test/mocks.dart" ]; then
        echo -e "${YELLOW}🏗️  Generating mocks...${NC}"
        dart run build_runner build --delete-conflicting-outputs
    fi
    
    echo -e "${GREEN}✅ TDD environment initialized${NC}"
}

# Function to run tests in Red phase (expecting failures)
run_red_phase() {
    local test_file="$1"
    echo -e "${RED}🔴 TDD RED PHASE: Running failing tests${NC}"
    echo "Test file: $test_file"
    
    cd "$PROJECT_ROOT"
    
    if [ -n "$test_file" ]; then
        flutter test "$test_file" --reporter=expanded || {
            echo -e "${RED}✅ Expected: Tests failed (this is correct for RED phase)${NC}"
            return 0
        }
        echo -e "${YELLOW}⚠️  Warning: Tests passed - they should fail in RED phase${NC}"
    else
        flutter test --reporter=expanded || {
            echo -e "${RED}✅ Expected: Some tests failed (this is correct for RED phase)${NC}"
            return 0
        }
    fi
}

# Function to run tests in Green phase (expecting passes)
run_green_phase() {
    local test_file="$1"
    echo -e "${GREEN}🟢 TDD GREEN PHASE: Running tests to verify they pass${NC}"
    echo "Test file: $test_file"
    
    cd "$PROJECT_ROOT"
    
    if [ -n "$test_file" ]; then
        if flutter test "$test_file" --reporter=expanded; then
            echo -e "${GREEN}✅ Success: Tests passed (GREEN phase complete)${NC}"
        else
            echo -e "${RED}❌ Error: Tests failed - need to write minimal code to pass${NC}"
            exit 1
        fi
    else
        if flutter test --reporter=expanded; then
            echo -e "${GREEN}✅ Success: All tests passed (GREEN phase complete)${NC}"
        else
            echo -e "${RED}❌ Error: Some tests failed - need to fix implementation${NC}"
            exit 1
        fi
    fi
}

# Function to run tests during refactoring phase
run_refactor_phase() {
    local test_file="$1"
    echo -e "${BLUE}🔵 TDD REFACTOR PHASE: Running tests during refactoring${NC}"
    echo "Test file: $test_file"
    
    cd "$PROJECT_ROOT"
    
    # Run static analysis first
    echo -e "${YELLOW}🔍 Running static analysis...${NC}"
    flutter analyze --no-pub
    
    # Run tests
    if [ -n "$test_file" ]; then
        if flutter test "$test_file" --reporter=expanded; then
            echo -e "${GREEN}✅ Success: Tests still pass after refactoring${NC}"
        else
            echo -e "${RED}❌ Error: Refactoring broke tests - revert changes${NC}"
            exit 1
        fi
    else
        if flutter test --reporter=expanded; then
            echo -e "${GREEN}✅ Success: All tests still pass after refactoring${NC}"
        else
            echo -e "${RED}❌ Error: Refactoring broke tests - revert changes${NC}"
            exit 1
        fi
    fi
}

# Function to watch files and auto-run tests
watch_tests() {
    local pattern="$1"
    echo -e "${YELLOW}👁️  Watching for file changes...${NC}"
    echo "Pattern: ${pattern:-'all files'}"
    
    if command -v fswatch &> /dev/null; then
        # Use fswatch if available (macOS)
        fswatch -o "$PROJECT_ROOT/lib" "$PROJECT_ROOT/test" | while read f; do
            echo -e "${BLUE}🔄 File change detected, running tests...${NC}"
            run_green_phase
        done
    else
        echo -e "${YELLOW}⚠️  fswatch not found. Install it for file watching: brew install fswatch${NC}"
        echo -e "${YELLOW}💡 Alternatively, run tests manually with each change${NC}"
    fi
}

# Function to generate and display coverage report
generate_coverage() {
    echo -e "${YELLOW}📊 Generating coverage report...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Run tests with coverage
    flutter test --coverage
    
    # Generate HTML coverage report if genhtml is available
    if command -v genhtml &> /dev/null; then
        echo -e "${YELLOW}🌐 Generating HTML coverage report...${NC}"
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}📊 Coverage report generated: coverage/html/index.html${NC}"
        
        # Open in browser if on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open coverage/html/index.html
        fi
    else
        echo -e "${YELLOW}💡 Install lcov for HTML reports: sudo apt-get install lcov${NC}"
    fi
    
    # Display coverage summary
    if [ -f "coverage/lcov.info" ]; then
        echo -e "${YELLOW}📈 Coverage Summary:${NC}"
        
        # Calculate coverage percentage (simplified)
        local lines_found=$(grep -c "^DA:" coverage/lcov.info || echo "0")
        local lines_hit=$(grep "^DA:" coverage/lcov.info | grep -v ",0$" | wc -l || echo "0")
        
        if [ "$lines_found" -gt 0 ]; then
            local coverage_percent=$((lines_hit * 100 / lines_found))
            echo "Lines covered: $lines_hit / $lines_found"
            echo "Coverage: $coverage_percent%"
            
            if [ "$coverage_percent" -ge "$MIN_COVERAGE" ]; then
                echo -e "${GREEN}✅ Coverage meets minimum requirement ($MIN_COVERAGE%)${NC}"
            else
                echo -e "${RED}❌ Coverage below minimum requirement ($MIN_COVERAGE%)${NC}"
                echo -e "${YELLOW}💡 Add more tests to improve coverage${NC}"
            fi
        fi
    fi
}

# Function to clean test artifacts
clean_tests() {
    echo -e "${YELLOW}🧹 Cleaning test artifacts...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Remove coverage files
    rm -rf coverage/
    
    # Remove test cache
    rm -rf .dart_tool/test/
    
    # Remove generated files
    find . -name "*.mocks.dart" -delete
    find . -name "*.g.dart" -path "*/test/*" -delete
    
    echo -e "${GREEN}✅ Test artifacts cleaned${NC}"
}

# Function to validate test structure and coverage
validate_tests() {
    echo -e "${YELLOW}🔍 Validating test structure...${NC}"
    
    cd "$PROJECT_ROOT"
    
    local issues=0
    
    # Check test directory structure
    echo -e "${YELLOW}📁 Checking test directory structure...${NC}"
    
    required_dirs=("unit" "widget" "integration" "helpers")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$TEST_DIR/$dir" ]; then
            echo -e "${RED}❌ Missing directory: test/$dir${NC}"
            ((issues++))
        fi
    done
    
    # Check for test files
    echo -e "${YELLOW}🧪 Checking for test files...${NC}"
    
    test_count=$(find "$TEST_DIR" -name "*_test.dart" | wc -l)
    if [ "$test_count" -eq 0 ]; then
        echo -e "${RED}❌ No test files found${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✅ Found $test_count test files${NC}"
    fi
    
    # Run static analysis on tests
    echo -e "${YELLOW}🔍 Running static analysis on tests...${NC}"
    
    if flutter analyze test/; then
        echo -e "${GREEN}✅ Test files pass static analysis${NC}"
    else
        echo -e "${RED}❌ Test files have analysis issues${NC}"
        ((issues++))
    fi
    
    # Check coverage
    if [ -f "coverage/lcov.info" ]; then
        echo -e "${YELLOW}📊 Checking coverage...${NC}"
        generate_coverage > /dev/null
    else
        echo -e "${YELLOW}⚠️  No coverage data found. Run tests with coverage first.${NC}"
    fi
    
    # Summary
    if [ "$issues" -eq 0 ]; then
        echo -e "${GREEN}✅ All validations passed${NC}"
    else
        echo -e "${RED}❌ Found $issues issues${NC}"
        exit 1
    fi
}

# Main script logic
main() {
    case "${1:-help}" in
        init)
            check_prerequisites
            init_tdd
            ;;
        red)
            check_prerequisites
            run_red_phase "$2"
            ;;
        green)
            check_prerequisites
            run_green_phase "$2"
            ;;
        refactor)
            check_prerequisites
            run_refactor_phase "$2"
            ;;
        watch)
            check_prerequisites
            watch_tests "$2"
            ;;
        coverage)
            check_prerequisites
            generate_coverage
            ;;
        clean)
            clean_tests
            ;;
        validate)
            check_prerequisites
            validate_tests
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Handle command line arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

main "$@"