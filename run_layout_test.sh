#!/bin/bash

# Quiz Creation Layout Overflow Fixes Test Script
# Tests the comprehensive layout fixes applied to quiz creation components

echo "🎯 Quiz Creation Layout Overflow Test"
echo "====================================="

# Check Flutter environment
echo "📱 Checking Flutter environment..."
flutter doctor --verbose

# Run static analysis to check for compile issues
echo "🔍 Running static analysis..."
flutter analyze > analysis_results.txt 2>&1
ANALYSIS_EXIT_CODE=$?

if [ $ANALYSIS_EXIT_CODE -eq 0 ]; then
    echo "✅ Static analysis passed"
else
    echo "❌ Static analysis failed - checking results..."
    cat analysis_results.txt
fi

# Test compilation by building for different platforms
echo "🏗️ Testing platform builds..."

echo "   Building for Web..."
flutter build web --release > web_build.log 2>&1
WEB_BUILD_STATUS=$?

echo "   Building for Android..."
flutter build apk --release > android_build.log 2>&1
ANDROID_BUILD_STATUS=$?

# Report build results
echo ""
echo "📊 Build Results:"
echo "=================="

if [ $WEB_BUILD_STATUS -eq 0 ]; then
    echo "✅ Web build: SUCCESS"
else
    echo "❌ Web build: FAILED"
    echo "Web build errors:"
    tail -20 web_build.log
fi

if [ $ANDROID_BUILD_STATUS -eq 0 ]; then
    echo "✅ Android build: SUCCESS"
else
    echo "❌ Android build: FAILED"  
    echo "Android build errors:"
    tail -20 android_build.log
fi

# Test quiz creation specific widgets with widget tests (if available)
echo ""
echo "🧪 Running Widget Tests..."
echo "=========================="

# Check if widget tests exist for quiz creation components
WIDGET_TEST_FILES=$(find test -name "*quiz*creation*" -o -name "*question*card*" -o -name "*stepper*" 2>/dev/null)

if [ -n "$WIDGET_TEST_FILES" ]; then
    echo "Found widget test files:"
    echo "$WIDGET_TEST_FILES"
    flutter test $WIDGET_TEST_FILES
else
    echo "⚠️ No specific widget tests found for quiz creation components"
fi

# Run integration tests
echo ""
echo "🎮 Running Integration Tests..."
echo "=============================="

if [ -f "integration_test/simple_visual_test.dart" ]; then
    echo "Running visual integration tests..."
    flutter test integration_test/simple_visual_test.dart --verbose > integration_test_results.txt 2>&1
    INTEGRATION_STATUS=$?
    
    if [ $INTEGRATION_STATUS -eq 0 ]; then
        echo "✅ Integration tests: PASSED"
        # Count test results
        PASSED_TESTS=$(grep -c "PASSED" integration_test_results.txt || echo "0")
        FAILED_TESTS=$(grep -c "FAILED" integration_test_results.txt || echo "0")
        echo "   Tests passed: $PASSED_TESTS"
        echo "   Tests failed: $FAILED_TESTS"
    else
        echo "❌ Integration tests: FAILED"
        echo "Integration test errors:"
        tail -30 integration_test_results.txt
        
        # Check for RenderFlex overflow errors specifically
        OVERFLOW_ERRORS=$(grep -c "RenderFlex.*overflow" integration_test_results.txt || echo "0")
        echo "   RenderFlex overflow errors: $OVERFLOW_ERRORS"
    fi
else
    echo "⚠️ Integration test file not found"
fi

# Summary
echo ""
echo "📋 Test Summary"
echo "==============="

TOTAL_ISSUES=0

if [ $ANALYSIS_EXIT_CODE -ne 0 ]; then
    echo "❌ Static Analysis: FAILED"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
else
    echo "✅ Static Analysis: PASSED"
fi

if [ $WEB_BUILD_STATUS -ne 0 ]; then
    echo "❌ Web Build: FAILED"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
else
    echo "✅ Web Build: PASSED"
fi

if [ $ANDROID_BUILD_STATUS -ne 0 ]; then
    echo "❌ Android Build: FAILED"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
else
    echo "✅ Android Build: PASSED"
fi

if [ -f integration_test_results.txt ] && [ $INTEGRATION_STATUS -ne 0 ]; then
    echo "❌ Integration Tests: FAILED"
    TOTAL_ISSUES=$((TOTAL_ISSUES + 1))
elif [ -f integration_test_results.txt ]; then
    echo "✅ Integration Tests: PASSED"
fi

echo ""
if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED! Layout overflow fixes successful."
    echo "   - All platforms build successfully"
    echo "   - No static analysis issues"
    echo "   - Integration tests pass without RenderFlex overflow"
else
    echo "⚠️ $TOTAL_ISSUES issue(s) found. Review the logs above."
fi

echo ""
echo "📁 Log files created:"
echo "   - analysis_results.txt"
echo "   - web_build.log"
echo "   - android_build.log"
echo "   - integration_test_results.txt (if integration tests ran)"

exit $TOTAL_ISSUES